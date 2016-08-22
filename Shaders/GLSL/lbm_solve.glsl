//ALL CREDIT TO NDEL https://www.shadertoy.com/view/4dK3zG

#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos2;

uniform sampler2D sDetailMap1;
uniform sampler2D sDetailMap2;
//varying vec4 vScreenPos4;

#ifdef COMPILEPS

//map distribution functions to texture coordinates
//4 texels are used to store the 9 distribution functions in one cell
#define f0(x,y) texture2D(sDiffMap, (vec2(2*x,2*y)+0.5)/(1.0/cGBufferInvSize)).r;
#define f1(x,y) texture2D(sDiffMap, (vec2(2*x,2*y)+0.5)/(1.0/cGBufferInvSize)).g;
#define f2(x,y) texture2D(sDiffMap, (vec2(2*x,2*y)+0.5)/(1.0/cGBufferInvSize)).b;
#define f3(x,y) texture2D(sDiffMap, (vec2(2*x+1,2*y)+0.5)/(1.0/cGBufferInvSize)).r;
#define f4(x,y) texture2D(sDiffMap, (vec2(2*x+1,2*y)+0.5)/(1.0/cGBufferInvSize)).g;
#define f5(x,y) texture2D(sDiffMap, (vec2(2*x+1,2*y)+0.5)/(1.0/cGBufferInvSize)).b;
#define f6(x,y) texture2D(sDiffMap, (vec2(2*x,2*y+1)+0.5)/(1.0/cGBufferInvSize)).r;
#define f7(x,y) texture2D(sDiffMap, (vec2(2*x,2*y+1)+0.5)/(1.0/cGBufferInvSize)).g;
#define f8(x,y) texture2D(sDiffMap, (vec2(2*x,2*y+1)+0.5)/(1.0/cGBufferInvSize)).b;
#define solid(x,y) texture2D(sDiffMap, ( vec2(2*x+1,2*y+1)+0.5) / (1.0/cGBufferInvSize) ).r;

#define VEL 1.0

#endif


highp float rand(vec2 co)
{
	highp float a = 12.9898;
	highp float b = 78.233;
	highp float c = 43758.5453;
	highp float dt= dot(co.xy ,vec2(a,b));
	highp float sn= mod(dt,3.14);
	return fract(sin(sn) * c);
}

void PS()
{
	//get the contribution pass
	//sDetailMap1

	//get the actual resolution
	vec2 res = 1.0/cGBufferInvSize;
		//vec2 pix = (gl_FragCoord+1.0)-0.5;
		//vec2 half = res-1.0;//make it so we land in the middle of a pixel
		//vec2 pix = (vTexCoord*half)+0.5;//fragcoord at half pixel
		//vec2 hpix = pix*(1.0/half);//normalized

	//relaxation time
	float w = 1.95;
	//fragColor=texture2D(iChannel0, fragCoord/iResolution.xy);
	int LatSizeX = int(res.x/2.0);
	int LatSizeY = int(res.y/2.0);
	//4 texels per voxel
	//all 4 pixels do the same computations
	int ix = int(floor(gl_FragCoord.x/2.0));
	int iy = int(floor(gl_FragCoord.y/2.0));
	if( ix >= LatSizeX || iy >= LatSizeY )
	{
			return;
	}
	int itx = int(gl_FragCoord.x) - 2*ix;
	int ity = int(gl_FragCoord.y) - 2*iy;
	float f0,f1,f2,f3,f4,f5,f6,f7,f8; //distribution functions
	float rho, vx, vy; //moments
	float solid = solid(ix,iy);
	f0 = f0(ix,iy);
	
	vec2 center = res/2.0;
	vec2 dir = normalize(gl_FragCoord.xy-center);

	//-------------
	if( (cElapsedTimePS<=0.0) || (f0==0.0) ) //initialisation
	{
			rho = 1.0;
			
			vx = VEL*dir.x*cDeltaTimePS;
			vy = VEL*dir.y*cDeltaTimePS;
			
			float sq_term = -1.5 * (vx*vx+vy*vy);
			f0 = 4./9. *rho*(1. + sq_term);
			f1 = 1./9. *rho*(1. + 3.*vx      + 4.5*vx*vx             + sq_term);
			f2 = 1./9. *rho*(1. - 3.*vx      + 4.5*vx*vx             + sq_term);
			f3 = 1./9. *rho*(1. + 3.*vy      + 4.5*vy*vy             + sq_term);
			f4 = 1./9. *rho*(1. - 3.*vy      + 4.5*vy*vy             + sq_term);
			f5 = 1./36.*rho*(1. + 3.*( vx+vy)+ 4.5*( vx+vy)*( vx+vy) + sq_term);
			f6 = 1./36.*rho*(1. - 3.*( vx+vy)+ 4.5*( vx+vy)*( vx+vy) + sq_term);
			f7 = 1./36.*rho*(1. + 3.*(-vx+vy)+ 4.5*(-vx+vy)*(-vx+vy) + sq_term);
			f8 = 1./36.*rho*(1. - 3.*(-vx+vy)+ 4.5*(-vx+vy)*(-vx+vy) + sq_term);

			if( distance(vec2(50.0,LatSizeY/2),vec2(ix,iy)) < 10.0 )
					solid = 1.0;
			else
					solid = 0.0;

			for(int i=0; i<1028; i++)
		        {
		        	highp float px = rand(vec2(0.23,0.44)*float(i));
		            	highp float py = rand(vec2(0.81,0.19)*float(i));
		            	if( distance(vec2(px,py)*res,vec2(ix,iy)) < 1.0 )
		            		solid = 1.0;
		        }
	}
	else
	{
			//=== STREAMING STEP (PERIODIC) =======================
			int xplus  = ((ix==LatSizeX-1) ? (0) : (ix+1));
			int xminus = ((ix==0) ? (LatSizeX-1) : (ix-1));
			int yplus  = ((iy==LatSizeY-1) ? (0) : (iy+1));
			int yminus = ((iy==0) ? (LatSizeY-1) : (iy-1));

			//f0 = f0( ix    ,iy    );
			f1 = f1( xminus,iy    );
			f2 = f2( xplus ,iy    );
			f3 = f3( ix    ,yminus);
			f4 = f4( ix    ,yplus );
			f5 = f5( xminus,yminus);
			f6 = f6( xplus ,yplus );
			f7 = f7( xplus ,yminus);
			f8 = f8( xminus,yplus );

			//=== COMPUTE MOMENTS =================================
			//density
			rho = f0+f1+f2+f3+f4+f5+f6+f7+f8;
			//velocity
			vx = 1./rho*(f1-f2+f5-f6-f7+f8);
			vy = 1./rho*(f3-f4+f5-f6+f7-f8);
			//velocity cap for stability
			float norm = sqrt(vx*vx+vy*vy);
			if(norm>0.2)
			{
					vx *= 0.2/norm;
					vy *= 0.2/norm;
			}
			if(ix==0||ix==LatSizeX-1 || iy==0 || iy==LatSizeY-1)//boundary condition
			{
					rho = 1.0;
					
					
					vx = VEL*dir.x*cDeltaTimePS;
					vy = VEL*dir.y*cDeltaTimePS;
					//vx = 0.0;
					//vy = 0.0;
					w = 1.0;
			}
			//if( iMouse.w>0.01 && distance(iMouse.xy/2.0,vec2(ix,iy)) < 2.0)
			//    solid = 1.0;
			if( solid>0.5 )
			{
					rho = 1.0;
					vx  = 0.0;
					vy  = 0.0;
					w = 1.0;
			}

			float sq_term = -1.5 * (vx*vx+vy*vy);
			float f0eq = 4./9. *rho*(1. + sq_term);
			float f1eq = 1./9. *rho*(1. + 3.*vx      + 4.5*vx*vx             + sq_term);
			float f2eq = 1./9. *rho*(1. - 3.*vx      + 4.5*vx*vx             + sq_term);
			float f3eq = 1./9. *rho*(1. + 3.*vy      + 4.5*vy*vy             + sq_term);
			float f4eq = 1./9. *rho*(1. - 3.*vy      + 4.5*vy*vy             + sq_term);
			float f5eq = 1./36.*rho*(1. + 3.*( vx+vy)+ 4.5*( vx+vy)*( vx+vy) + sq_term);
			float f6eq = 1./36.*rho*(1. - 3.*( vx+vy)+ 4.5*( vx+vy)*( vx+vy) + sq_term);
			float f7eq = 1./36.*rho*(1. + 3.*(-vx+vy)+ 4.5*(-vx+vy)*(-vx+vy) + sq_term);
			float f8eq = 1./36.*rho*(1. - 3.*(-vx+vy)+ 4.5*(-vx+vy)*(-vx+vy) + sq_term);
			//=== RELAX TOWARD EQUILIBRIUM ========================
			f0 = (1.-w) * f0 + w * f0eq;
			f1 = (1.-w) * f1 + w * f1eq;
			f2 = (1.-w) * f2 + w * f2eq;
			f3 = (1.-w) * f3 + w * f3eq;
			f4 = (1.-w) * f4 + w * f4eq;
			f5 = (1.-w) * f5 + w * f5eq;
			f6 = (1.-w) * f6 + w * f6eq;
			f7 = (1.-w) * f7 + w * f7eq;
			f8 = (1.-w) * f8 + w * f8eq;
		}
								
		if(itx==0&&ity==0)//stores f0,f1,f2
			gl_FragColor = vec4(f0,f1,f2,1.0);
		else if(itx==1&&ity==0)//stores f3,f4,f5
			gl_FragColor = vec4(f3,f4,f5,1.0);
		else if(itx==0&&ity==1)//stores f6,f7,f8
			gl_FragColor = vec4(f6,f7,f8,1.0);
		else //stores rho,vx,vy
			gl_FragColor = vec4(solid,vx,vy,1.0);

}