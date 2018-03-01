SliceLayout is a little utility to take a saved FlowJo layout image and chop it up into component images based upon the original layout definition.  Only mac FlowJo workspaces are supported currently.

    Usage: java -jar SliceLayout.jar image.png workspace.xml layout-name out-dir

The graph bounding boxes are read from the workspace.xml layout for the given layout name.  The bounding box isn't captured so we try to union the annotation and graph rects together (with a little fudge factor).  The algorithm is dumb and will most likely break in the future.  The graph name and axes are read to create a unique and readable filename:

    population~path~parts (x-axis, y-axis).png

Population names are separated by ~ and compensated axis names are prepended with "comp-".
