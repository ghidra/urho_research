const int ATTRNAME_WIDTH = 150;
const int ATTR_HEIGHT = 19;

UIElement@ CreateSlider(const String&in name)
{
    UIElement@ container = UIElement();
    LineEdit@ attrEdit = CreateAttributeLineEdit(container);
    CreateDragSlider(attrEdit);

    //SubscribeToEvent(attrEdit, "TextChanged", "EditAttribute");
    //SubscribeToEvent(attrEdit, "TextFinished", "EditAttribute");

    return container;
}

LineEdit@ CreateAttributeLineEdit(UIElement@ parent)
{
    LineEdit@ attrEdit = LineEdit();
    parent.AddChild(attrEdit);
    attrEdit.dragDropMode = DD_TARGET;
    attrEdit.style = "EditorAttributeEdit";
    attrEdit.SetFixedHeight(ATTR_HEIGHT - 2);
    //attrEdit.vars["Index"] = index;
    //attrEdit.vars["SubIndex"] = subIndex;
    //SetAttributeEditorID(attrEdit, serializables);

    return attrEdit;
}

void CreateDragSlider(LineEdit@ parent)
{
    Button@ dragSld = Button();
    dragSld.style = "EditorDragSlider";
    dragSld.SetFixedHeight(ATTR_HEIGHT - 3);
    dragSld.SetFixedWidth(dragSld.height);
    dragSld.SetAlignment(HA_RIGHT, VA_TOP);
    dragSld.focusMode = FM_NOTFOCUSABLE;
    parent.AddChild(dragSld);

    //SubscribeToEvent(dragSld, "DragBegin", "LineDragBegin");
    //SubscribeToEvent(dragSld, "DragMove", "LineDragMove");
    //SubscribeToEvent(dragSld, "DragEnd", "LineDragEnd");
    //SubscribeToEvent(dragSld, "DragCancel", "LineDragCancel");
}