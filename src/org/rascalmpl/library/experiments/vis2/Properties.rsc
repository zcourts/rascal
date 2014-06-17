module experiments::vis2::Properties

import Node;
import List;
import IO;

data FProperty =
      pos(int xpos, int ypos)
    | size(int xsize, int ysize)
    | gap(int xgap, int ygap)
    
    // lines
    
	| lineWidth(int n)
	| lineColor(str c)
	| lineStyle(list[int] dashes)
	| lineOpacity(real op)
	
	// areas
	| fillColor(str c)
	| fillColor(str() sc)
	| fillOpacity(real op)
	| rounded(int rx, int ry)
	| align(HAlign xalign, VAlign yalign)
	
	// fonts and text
	
	| font(str fontName)
	| fontSize(int fontSize)
	| fontBaseline(str s)
	| textAngle(num  r)
	
	// data sets	
	
	| dataset(list[num] values1)
	| dataset(lrel[num,num] values2)
	;
	
data HAlign = left() | hcenter() | right();

data VAlign = top() | vcenter() | bottom();
	
public alias FProperties = list[FProperty];

FProperties getDefaultProperties() = []; //[size(50,50), gap(0,0)];

FProperties combine(FProperty fp, FProperties fps) = [fp, *fps];

FProperties combine(FProperties fps1, FProperties fps2) = fps1 + fps2;

// Bounding box

data BBox = bbox(int x, int y, int width, int height);

Pos getPos(BBox bb) = <bb.x, bb.y>;

Size getSize(BBox bb) = <bb.width, bb.height>;

// size 

alias Size 	= tuple[int width, int height];

bool hasSize(FProperties fps) {
	for(fp <- fps)
		if (size(int xsize, int ysize) := fp) return true;
	return false;
}	

Size getSize(FProperties fps, Size def) {
	for(fp <- fps)
		if (size(int xsize, int ysize) := fp) return <xsize, ysize>;
	return def;
}

Size getSize(FProperties fps) = getSize(fps, <0,0>);

// gap

alias Gap 	= tuple[int width, int height];

bool hasGap(FProperties fps, Size def) {
	for(fp <- fps)
		if (gap(int width, int height) := fp) return true;
	return false;
}

Size getGap(FProperties fps, Size def) {
	for(fp <- fps)
		if (gap(int width, int height) := fp) return <width, height>;
	return def;
}

Size getGap(FProperties fps)  = getGap(fps, <0,0>);

// pos 

alias Pos = tuple[int x, int y];

bool hasPos(FProperties fps) {
	for(fp <- fps)
		if (pos(int x, int y) := fp) return true;
	return false;
}	

Pos getPos(FProperties fps, Pos def) {
	for(fp <- fps)
		if (pos(int xpos, int ypos) := fp) return <xpos, ypos>;
	return def;
}

Size getPos(FProperties fps)  = getPos(fps, <0,0>);

alias Align	= tuple[HAlign xalign, VAlign yalign];

Align getAlign(FProperties fps, Align def) {
	for(fp <- fps)
		if (align(HAlign xalign, VAlign yalign) := fp) return <xalign, yalign>;
	return def;
}

Align getAlign(FProperties fps) = getAlign(fps, <hcenter(), vcenter()>);

// Translate properties to a javascript map

str trPropsContent(FProperties fps) {
	seen = {};
	res = for(fp <- fps){
		attr = getName(fp);
		if(attr notin seen){
			seen += attr;
			t = trProp(fp);
			if(t != "")
				append t;
		}
	}
	return intercalate(", ", res);
}

str trProps(FProperties fps) = "{ <trPropsContent(fps)> }";

str trProp(pos(int xpos, int ypos)) 		= "";
//str trProp(size(int xsize, int ysize))	= "width: <xsize>, height <ysize>";
str trProp(gap(int width, int height)) 		= "";
str trProp(align(HAlign xalign, VAlign yalign)) 	
											= "";
str trProp(lineWidth(int n)) 				= "stroke_width: <n>";
str trProp(lineStyle(list[int] dashes))		= "stroke_dasharray: <dashes>";
str trProp(fillColor(str s)) 				{ r = "fill: \"<s>\""; println("fillColor, constant: <r>"); return r; }
str trProp(fillColor(str() sc)) 			{ r = "fill: \"<sc()>\""; println("fillColor, computed: <r>"); return r; }

str trProp(lineColor(str s))				= "stroke:\"<s>\"";
str trProp(lineOpacity(real r))				= "stroke_opacity:\"<r>\"";
str trProp(fillOpacity(real r))				= "fill_opacity:\"<r>\"";
str trProp(rounded(int rx, int ry))			= "rx: <rx>, ry: <ry>";
str trProp(dataset(list[num] values1)) 		= "dataset: <values1>";
str trProp(dataset(lrel[num,num] values2))	= "dataset: [" + intercalate(",", ["[<v1>,<v2>]" | <v1, v2> <- values2]) + "]";

str trProp(font(str fontName))				= "font: \"<fontName>\"";
str trProp(fontSize(int fontSize))			= "font_size: <fontSize>";
str trProp(fontBaseline(str s))				= "???";
str trProp(textAngle(num  r))				= "???";

default str trProp(FProperty fp) 			= (size(int xsize, int ysize) := fp) ? "width: <xsize>, height: <ysize>" : "unknown: <fp>";