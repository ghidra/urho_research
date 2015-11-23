#!/usr/bin/env bash
export LD_LIBRARY_PATH=/mill3d/server/apps/GCC/gcc-4.8.1/lib64
if [ $# -eq 0 ]; then echo "what script should i run?"; else /mill3d/work/jimmyg/urho/Urho_DYN/bin/Urho3DPlayer /Scripts/$1.as -pp /mill3d/work/jimmyg/urho/Urho_DYN/bin -p "CoreData;Data;Research"; fi
