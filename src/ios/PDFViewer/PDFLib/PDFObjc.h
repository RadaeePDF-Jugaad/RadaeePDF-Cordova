//
//  PDFDoc.h
//  PDFViewer
//
//  Created by Radaee on 12-9-18.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFIOS.h"
#pragma once

typedef struct _PDF_TEXT_RET_
{
	int num_unicodes;
	int num_lines;
}PDF_TEXT_RET;

@interface RDPDFSign : NSObject
{
	PDF_SIGN m_sign;
}
@property (readonly)PDF_SIGN handle;
-(id)init:(PDF_SIGN)sign;
/**
 * @brief sign date time
 * @return date time.
 */
-(NSString *)issue;
/**
 * @brief get sign subject
 * @return sign subject
 */
-(NSString *)subject;
/**
 * @brief get sign version
 * @return sign version
 */
-(long)version;
/**
 * @brief get signer name.
 * @return name string.
 */
-(NSString *)name;
/**
 * @brief get sign reason
 * @return reason string
 */
-(NSString *)reason;
/**
 * @brief get sign location.
 * @return location description.
 */
-(NSString *)location;
/**
 * @brief get sign contact string
 * @return contact address or phone.
 */
-(NSString *)contact;
/**
 * @brief get sign date time
 * @return date time.
 */
-(NSString *)modTime;
@end

@interface RDPDFDIB : NSObject
{
    PDF_DIB m_dib;
}
@property (readonly) PDF_DIB handle;
/**
 *	@brief	create a DIB object
 *
 *	@param 	width 	width in pixels
 *	@param 	height 	height in pixels
 */
-(id)init:(int)width :(int)height;
/**
 *	@brief	resize a DIB object
 *
 *	@param 	newWidth 	width in pixels
 *	@param 	newHeight 	height in pixels
 */
-(void)resize:(int)newWidth :(int)newHeight;
/**
 *	@brief	get pixels data.
 */
-(void *)data;
/**
 *	@brief	get width.
 *
 *	@return width in pixels
 */
-(int)width;
/**
 *	@brief	get height.
 *
 *	@return height in pixels
 */
-(int)height;
-(void)erase:(int)color;
-(CGImageRef)image;
@end

@interface RDPDFObj : NSObject
{
	PDF_OBJ m_obj;
}
@property(readonly) PDF_OBJ handle;
-(id)init :(PDF_OBJ)obj;
/**
 * @brief get type of object
 * @return object type as following:
 * null = 0,
 * boolean = 1,
 * int = 2,
 * real = 3,
 * string = 4,
 * name = 5,
 * array = 6,
 * dictionary = 7,
 * reference = 8,
 * stream = 9,
 * others unknown.,
 */
-(int)getType;
/**
 * @brief get int value from object.
 * @return int value.
 */
-(int)getIntVal;
/**
 * @brief get boolean value from object.
 * @return boolean value.
 */
-(bool)getBoolVal;
/**
 * @brief get float value from object.
 * @return float value.
 */
-(float)getRealVal;
/**
 * @brief get cross reference from object.
 * @return cross reference item.
 */
-(PDF_OBJ_REF)getReferenceVal;
/**
 * @brief get name value from object.
 * @return name value.
 */
-(NSString *)getNameVal;
/**
 * @brief get string value from object.
 * @return ascii string value.
 */
-(NSString *)getAsciiStringVal;
/**
 * @brief get string value from object.
 * @return Unicode string value.
 */
-(NSString *)getTextStringVal;
/**
 * @brief get string value from object.
 * @param plen binary string length
 * @return binary string value.
 */
-(const unsigned char *)getHexStrngVal :(int *)plen;
/**
 * @brief set int value to object, and set object type to int.
 * @param v int value
 */
-(void)setIntVal:(int)v;
/**
 * @brief set boolean value to object, and set object type to boolean.
 * @param v boolean value
 */
-(void)setBoolVal:(bool)v;
/**
 * @brief set float value to object, and set object type to float.
 * @param v float value
 */
-(void)setRealVal:(float)v;
/**
 * @brief set cross reference to object, and set object type to reference.
 * @param v cross reference
 */
-(void)setReferenceVal:(PDF_OBJ_REF)v;
/**
 * @brief set name value to object, and set object type to name.
 * @param v name value
 */
-(void)setNameVal:(NSString *)v;
/**
 * @brief set ascii string value to object, and set object type to string.
 * @param v ascii string value
 */
-(void)setAsciiStringVal:(NSString *)v;
/**
 * @brief set unicode string value to object, and set object type to string.
 * @param v unicode string value
 */
-(void)setTextStringVal:(NSString *)v;
/**
 * @brief set binary string value to object, and set object type to string.
 * @param v binary string value
 * @param len binary string length
 */
-(void)setHexStringVal:(unsigned char *)v :(int)len;
-(void)setDictionary;
/**
 * @brief get item count of dictionary or stream obj
 * @return count.
 */
-(int)dictGetItemCount;
/**
 * @brief get item name of dictionary or stream by index
 * @param index 0 based index value.
 * @return tag of item.
 */
-(NSString *)dictGetItemTag:(int)index;
/**
 * @brief get item of dictionary or stream by index
 * @param index 0 based index value.
 * @return PDF object data.
 */
-(RDPDFObj *)dictGetItemByIndex:(int)index;
/**
 * @brief get item of dictionary or stream by tag
 * @param tag name same as dictGetItemTag
 * @return PDF object data.
 */
-(RDPDFObj *)dictGetItemByTag:(NSString *)tag;
/**
 * @brief set empty object to item by tag.
 * u can use DictGetItem(key) to get object, after DictSetItem.
 * @param tag name same as dictGetItemTag
 */
-(void)dictSetItem:(NSString *)tag;
/**
 *  @brief  remove item by tag
 *  @param  tag tag of item, same as dictGetItemTag
 */
-(void)dictRemoveItem:(NSString *)tag;
-(void)setArray;
/**
 * @brief get item count of array
 * @return count.
 */
-(int)arrayGetItemCount;
/**
 * @brief get item of array by index.
 * @param index 0 based index.
 * @return PDF object data.
 */
-(RDPDFObj *)arrayGetItem:(int)index;
/**
 * @brief add an empty object to tail of array.
 * you can use arrayGetItem(arrayGetItemCount() - 1) to get Object after arrayAppendItem()
 */
-(void)arrayAppendItem;
/**
 * @brief insert an empty object to array by position.
 * you can use arrayGetItem(index) to get Object after arrayInsertItem()
 * @param index 0 based index
 */
-(void)arrayInsertItem:(int)index;
/**
 * @brief remove an item from array
 * @param index 0 based index.
 */
-(void)arrayRemoveItem:(int)index;
/**
 * @brief remove all items from array.
 */
-(void)arrayClear;
@end

@interface RDPDFOutline : NSObject
{
    PDF_OUTLINE m_handle;
    PDF_DOC m_doc;
}
@property (readonly) PDF_OUTLINE handle;

/**
 *	@brief	create an Outline object.
 *			this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	outline handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_OUTLINE)handle;
/**
 *	@brief	get next sibling outline.
 */
-(RDPDFOutline *)next;
/**
 *	@brief	get first child outline.
 */
-(RDPDFOutline *)child;
/**
 *	@brief	get dest pageno.
 *
 *	@return	0 based page NO.
 */
-(int)dest;
/**
 *	@brief	get title of this outline.
 *
 *	@return	title string.
 */
-(NSString *)label;
/**
 * @brief get file link path of Outline
 * @return file link path string or null.
 */
-(NSString *)fileLink;
/**
 * @brief get url string of Outline
 * @return url string or null.
 */
-(NSString *)url;
/**
 *	@brief	remove this outline from PDF Document.
 */
-(bool)removeFromDoc;
/**
 * @brief insert outline after of this Outline.
 * a premium license is needed for this method.
 * @param label output value: label text ot outline item.
 * @param pageno 0 based page NO.
 * @param top y in PDF coordinate
 * @return true or false
 */
-(bool)addNext:(NSString *)label :(int)pageno :(float)top;
/**
 * @brief insert outline as first child of this Outline.
 * a premium license is needed for this method.
 * @param label output value: label text ot outline item.
 * @param pageno 0 based page NO.
 * @param top y in PDF coordinate
 * @return true or false
 */
-(bool)addChild:(NSString *)label :(int)pageno :(float)top;
@end

@interface RDPDFDocFont : NSObject
{
    PDF_DOC_FONT m_handle;
    PDF_DOC m_doc;
}
@property (readonly) PDF_DOC_FONT handle;
/**
 *	@brief	create an Font object.
 *			this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	FONT handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_DOC_FONT)handle;
/**
 * @brief get font ascent
 * @return ascent based in 1, for example: 0.88f
 */
-(float)ascent;
/**
 * @brief get font descent
 * @return descent based in 1, for example: -0.12f
 */
-(float)descent;
@end

@interface RDPDFDocGState : NSObject
{
    PDF_DOC_GSTATE m_handle;
    PDF_DOC m_doc;
}
@property (readonly) PDF_DOC_GSTATE handle;
/**
 *	@brief	create an Graphic State object.
 *			this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	GState handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_DOC_GSTATE)handle;
/**
 *	@brief	set alpha value for stroke.
 *
 *	@param	alpha	alpha value in range [0, 255].
 *
 *	@return true or false.
 */
-(bool)setStrokeAlpha :(int)alpha;
/**
 *	@brief	set alpha value for fill.
 *
 *	@param	alpha	alpha value in range [0, 255].
 *
 *	@return true or false.
 */
-(bool)setFillAlpha :(int)alpha;
/**
 * @brief set dash for stroke operation.
 * @param dash dash array, if null, means set to solid.
 * @param dash_cnt dash array length    
 * @param phase phase value, mostly, it is 0.
 * @return true or false.
 * eaxmple:
 * [2, 1], 0  means 2 on, 1 off, 2 on, 1 off, …
 * [2, 1], 0.5 means 1.5 on, 1 off, 2 on 1 off, …
 * for more details, plz see PDF-Reference 1.7 (4.3.2) Line Dash Pattern.
 */
-(bool)setStrokeDash:(const float *)dash : (int)dash_cnt : (float)phase;
/**
 * @brief set blend mode to graphic state.
 * @param bmode 2:Multipy
 * 3:Screen
 * 4:Overlay
 * 5:Darken
 * 6:Lighten
 * 7:ColorDodge
 * 8:ColorBurn
 * 9:Difference
 * 10:Exclusion
 * 11:Hue
 * 12:Saturation
 * 13:Color
 * 14:Luminosity
 * others:Normal
 * @return true or false.
 */
-(bool)setBlendMode :(int)bmode;
@end

@interface RDPDFDocImage : NSObject
{
    PDF_DOC_IMAGE m_handle;
    PDF_DOC m_doc;
}
@property (readonly) PDF_DOC_IMAGE handle;
/**
 *	@brief	create an Image object.
 *			this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	IMAGE handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_DOC_IMAGE)handle;
@end


@interface RDPDFFinder : NSObject
{
	PDF_FINDER m_handle;
}
/**
 *	@brief	create an finder object.
 *			this method is not supplied for developers, but invoked inner.
 *
 *	@param	handle	FINDER handle.
 *
 */
-(id)init:(PDF_FINDER)handle;
/**
 *	@brief	get found count.
 *
 *	@return	how many times found for special key string.
 */
-(int)count;
/**
 * @brief get char index in page, by find index.
 * to invoke this function, developers should call Page_objsStart before.
 * @param find_index find index, range: [0, RDPDFFinder.count() - 1].
 * @return char index in page, range: [0, RDPDFPage.objsCount() - 1].
 */
-(int)objsIndex:(int)find_index;
/**
 * @brief get char end index in page, by find index.
 * to invoke this function, developers should call Page_objsStart before.
 * @param finder returned from Page_findOpen
 * @param index find index, range: [0, RDPDFFinder.coun() - 1].
 * @return char index in page, range: [0, RDPDFPage.objsCount() - 1].
 */
-(int)objsEnd:(int)find_index;
@end

@interface RDPDFPath : NSObject
{
	PDF_PATH m_handle;
}
@property (readonly) PDF_PATH handle;
/**
 *	@brief	create a path object may includes some contours.
 */
-(id)init;
/**
 * @brief move to operation
 * @param x x value
 * @param y y value
 */
-(void)moveTo:(float)x :(float)y;
/**
 * @brief move to operation
 * @param x x value
 * @param y y value
 */
-(void)lineTo:(float)x :(float)y;
/**
 * @brief append cubic curve line to path
 *
 */
-(void)CurveTo:(float)x1 :(float)y1 :(float)x2 :(float)y2 :(float)x3 :(float)y3;
/**
 * @brief close current contour.
 */
-(void)closePath;
/**
 * @brief get node count
 * @return node count
 */
-(int)nodesCount;
/**
 * @brief	get each node, by index
 *			example:
 *			PDF_POINT pt;
 *			int type = [RDPDFPath node:index:&pt];
 *
 * @param	index	range [0, RDPDFPath.nodesCount - 1]
 * @param	pt	an output value.
 *
 * @return	node type:
 * 0: move to
 * 1: line to
 * 3: curve to, index, index + 1, index + 2 are points for this operation.
 * 4: close operation
 */
-(int)node:(int)index :(PDF_POINT *)pt;
@end

@interface RDPDFInk : NSObject
{
	PDF_INK m_handle;
}
@property (readonly) PDF_INK handle;
/**
 *	@brief	create an ink object.
 *
 *	@param	line_width	ink width.
 *	@param	color	ink color in format: 0xAARRGGBB, AA is alpha, RR is Red, GG is Green, BB is Blue.
 */
-(id)init:(float)line_width :(int)color;
/**
 * @brief invoked when touch down.
 */
-(void)onDown:(float)x :(float)y;
/**
 * @brief invoked when moving.
 */
-(void)onMove:(float)x :(float)y;
/**
 * @brief invoked when touch up.
 */
-(void)onUp:(float)x :(float)y;
/**
 * @brief get node count for ink.
 * @return nodes count
 */
-(int)nodesCount;
/**
 * @brief	get each node, by index
 *			example:
 *			PDF_POINT pt;
 *			int node_type = [RDPDFInk node:index:&pt];
 *
 * @param	index	range [0, RDPDFInk.nodesCount - 1]
 * @param	pt	an output value.
 *
 * @return	node type:
 * 0: move to
 * 1: line to
 * 2: quad to, index, index + 1 are points for this operation.
 * 3: curve to, index, index + 1, index + 2 are points for this operation.
 * 4: close operation
 */
-(int)node:(int)index :(PDF_POINT *)pt;
@end

@interface RDPDFMatrix : NSObject
{
    PDF_MATRIX m_mat;
}
@property (readonly) PDF_MATRIX handle;
/**
 *	@brief	create a Matrix object.
 *			formula like:
 *			x1 = x * sacalex + orgx;
 *			y1 = y * sacaley + orgy;
 *
 *	@param	scalex	scale value in x direction.
 *	@param	scaley	scale value in y direction.
 *	@param	orgx	orgin x.
 *	@param	orgy	orgin y.
 */
-(id)init:(float)scalex :(float)scaley :(float)orgx :(float)orgy;
/**
 *	@brief	create a Matrix object.
 *
 *			formula like:
 *			x1 = x * xx + y * xy + x0;
 *			y1 = y * yy + x * yx + y0;
 *
 */
-(id)init:(float)xx :(float)yx :(float)xy :(float)yy :(float)x0 :(float)y0;
-(void)invert;
-(void)transformPath:(RDPDFPath *)path;
-(void)transformInk:(RDPDFInk *)ink;
-(void)transformRect:(PDF_RECT *)rect;
-(void)transformPoint:(PDF_POINT *)point;
@end

@interface RDPDFPageContent : NSObject
{
	PDF_PAGECONTENT m_handle;
}
@property (readonly) PDF_PAGECONTENT handle;
/**
 * @brief create page content object
 */
-(id)init;
/**
 * @brief save current graphic state
 */
-(void)gsSave;
/**
 * @brief restore graphic state
 */
-(void)gsRestore;
/**
 * @brief set graphic state, like alpha values.
 */
-(void)gsSet:(PDF_PAGE_GSTATE) gs;
/**
 * @brief concat current matrix
 */
-(void)gsCatMatrix:(RDPDFMatrix *) mat;
/**
 * @brief text section begin
 */
-(void)textBegin;
/**
 * @brief text section end
 */
-(void)textEnd;
/**
 * @brief draw an image
 *
 * @param img image object returned from RDPDFPage.newImageXXX.
 */
-(void)drawImage:(PDF_PAGE_IMAGE) img;
/**
 * @brief PDF operator: show form.
 * @param frm Form object created by RDPDFPage.addResForm()
 */
-(void)drawForm:(PDF_PAGE_FORM)form;
/**
 * @brief draw text
 *
 * @param text text to draw
 */
-(void)drawText:(NSString *)text;
/**
 * @brief show text with special width
 * @param text text to show.
 * @param align 0:left, 1: middle, 2:right
 * @param width bounding width to draw text
 * @return line count of this text drawing.
 */
-(int)drawText:(NSString*)text : (int)align : (float)width;
/**
 * @brief show text with special width and max line count.
 * @param text text to show.
 * @param align 0:left, 1: middle, 2:right
 * @param width bounding width to draw text
 * @param max_lines max line count of this drawing
 * @return 2 element as [count of unicodes have drawn, line count have drawn].
 */
-(PDF_TEXT_RET)drawText:(NSString*)text : (int)align : (float)width : (int)max_lines;
/**
 * @brief stroke the path
 *
 * @param path path to stroke
 */
-(void)strokePath:(RDPDFPath *) path;
/**
 * @brief fill the path
 *
 * @param path path to fill
 * @param winding true if use winding rule, or even-odd rule.
 */
-(void)fillPath:(RDPDFPath *)path :(bool) winding;
/**
 * @brief set the path to clip
 *
 * @param path path to clip
 * @param winding true if use winding rule, or even-odd rule.
 */
-(void)clipPath:(RDPDFPath *)path :(bool) winding;
/**
 * @brief set fill color
 *
 * @param color formatted as 0xRRGGBB
 */
-(void)setFillColor:(int) color;
/**
 * @brief set stroke color
 *
 * @param color formatted as 0xRRGGBB
 */
-(void)setStrokeColor:(int) color;
/**
 * @brief PDF operator: set line cap
 * @param cap 0:butt, 1:round: 2:square
 */
-(void)setStrokeCap:(int) cap;
/**
 * @brief PDF operator: set line join
 * @param join 0:miter, 1:round, 2:bevel
 */
-(void)setStrokeJoin:(int) join;
/**
 * @brief PDF operator: set line width
 * @param w line width in PDF coordinate
 */
-(void)setStrokeWidth:(float) w;
/**
 * @brief PDF operator: set miter limit.
 * @param miter miter limit.
 */
-(void)setStrokeMiter:(float) miter;
/**
 * @brief set stroke dash of square/circle/ink/line/ploygon/polyline/free text/text field annotation.
 * for free text or text field annotation: dash of edit-box border
 * you need render page again to show modified annotation.
 * this method require professional or premium license
 * @param page returned from Document_getPage
 * @param annot annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 * @param dash stroke dash array units.
 * @param cnt stroke dash array length.
 * @return true or false
 */
-(void)setStrokeDash:(const float*)dash : (int)dash_cnt : (float)phase;
/**
 * @brief PDF operator: set char space(extra space between chars).
 * @param space char space
 */
-(void)textSetCharSpace:(float) space;
/**
 * @brief PDF operator: set word space(extra space between words spit by blank char ' ' ).
 * @param space word space.
 */
-(void)textSetWordSpace:(float) space;
/**
 * @brief PDF operator: set text leading, height between 2 text lines.
 * @param leading leading in PDF coordinate
 */
-(void)textSetLeading:(float) leading;
/**
 * @brief PDF operator: set text rise
 * @param rise rise value
 */
-(void)textSetRise:(float) rise;
/**
 * @brief PDF operator: set horizon scale for chars.
 * @param scale 100 means scale value 1.0f
 */
-(void)textSetHScale:(int) scale;
/**
 * @brief PDF operator: new a text line
 */
-(void)textNextLine;
/**
 * @brief PDF operator: move text position relative to previous line
 * @param x in PDF coordinate add to previous line position
 * @param y in PDF coordinate add to previous line position
 */
-(void)textMove:(float) x :(float) y;
/**
 * @brief set text font
 * @param font ResFont object created by Page.AddResFont()
 * @param size text size in PDF coordinate.
 */
-(void)textSetFont:(PDF_PAGE_FONT) font :(float) size;
/**
 * @brief PDF operator: set text render mode.
 * @param mode values as below:
 *			0: filling
 *			1: stroke
 *			2: fill and stroke
 *			3: do nothing
 *			4: fill and set clip path
 *			5: stroke and set clip path
 *			6: fill/stroke/clip
 *			7: set clip path.
 */
-(void)textSetRenderMode:(int) mode;
@end


@interface RDPDFDocForm : NSObject
{
	PDF_DOC_FORM m_handle;
	PDF_DOC m_doc;
}
@property(readonly) PDF_DOC_FORM handle;
/**
 *	@brief	create a Form object.
 *			this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	GState handle.
 *
 */
-(id)init:(PDF_DOC)doc : (PDF_DOC_FORM)handle;
/**
 * @brief add font as resource of form.
 * a premium license is required for this method.
 * @param font returned by Document_NewFontCID()
 * @return resource handle
 */
-(PDF_PAGE_FONT)addResFont :(RDPDFDocFont *)font;
/**
 * @brief add image as resource of form.
 * a premium license is required for this method.
 * @param image returned by Document_NewImage
 * @return resource handle
 */
-(PDF_PAGE_IMAGE)addResImage :(RDPDFDocImage *)img;
/**
 * @brief add Graphic State as resource of form.
 * a premium license is required for this method.
 * @param gs  returned by Document_newGState()
 * @return resource handle
 */
-(PDF_PAGE_GSTATE)addResGState : (RDPDFDocGState *)gs;
/**
 * @brief add sub-form as resource of form.
 * a premium license is required for this method.
 * @param form destination form
 * @return resource handle
 */
-(PDF_PAGE_FORM)addResForm : (RDPDFDocForm *)form;
/**
 * @brief set content of form, need a box defined in form
 * the box define edge of form area, which PageContent object includes.
 * @param x x of form's box
 * @param y y of form's box
 * @param w width of form's box
 * @param h height of form's box
 * @param content PageContent object.
 */
-(void)setContent : (float)x : (float)y : (float)w : (float)h : (RDPDFPageContent *)content;
/**
 * @brief set this form as transparency.
 * @param isolate set to isolate, mostly are false.
 * @param knockout set to knockout, mostly are false.
 */
-(void)setTransparency :(bool)isolate :(bool)knockout;
@end


@class RDPDFPage;
@interface RDPDFAnnot : NSObject
{
	PDF_ANNOT m_handle;
	PDF_PAGE m_page;
}
@property (readonly) PDF_ANNOT handle;
/**
 * @brief	create an annotation object, 
 *			this method is not supplied for developers, but invoked inner.
 */
-(id)init:(PDF_PAGE)page :(PDF_ANNOT)handle;
/**
 * @brief advanced function to get reference of annotation object.
 * this method require premium license.
 * @return reference
 */
-(PDF_OBJ_REF)advanceGetRef;
/**
 * @brief advanced function to reload annotation object, after advanced methods update annotation object data.
 * this method require premium license.
 */
-(void)advanceReload;
/**
 * @brief	get annotation type.
 *			this method valid in professional or premium version
 * @return type as these values:
 * 0:  unknown
 * 1:  text
 * 2:  link
 * 3:  free text
 * 4:  line
 * 5:  square
 * 6:  circle
 * 7:  polygon
 * 8:  polyline
 * 9:  text hilight
 * 10: text under line
 * 11: text squiggly
 * 12: text strikeout
 * 13: stamp
 * 14: caret
 * 15: ink
 * 16: popup
 * 17: file attachment
 * 18: sound
 * 19: movie
 * 20: widget
 * 21: screen
 * 22: print mark
 * 23: trap net
 * 24: water mark
 * 25: 3d object
 * 26: rich media
 */
-(int)type;
/**
 * @brief data from annotation.
 * a premium license is required for this method.
 * @param buf data pointer
 * @param len data buffer size
 * @return -1: if the export failed, otherwise: export success.
 */
-(int)export :(unsigned char *)buf : (int)len;
/**
 * @brief sign the empty field and save the PDF file.
 * if the signature field is not empty(signed), it will return failed.
 * this method require premium license.
 * @param appearence appearance icon for signature
 * RDPDFDocForm object return from RDPDFDoc.newForm      
 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
 * @param pswd password to open cert file.
 * @param name signer name string.
 * @param reason sign reason will write to signature.
 * @param location signature location will write to signature.
 * @param contact contact info will write to signature.
 * @return 0 mean OK
 * -1: generate parameters error.
 * -2: it is not signature field, or field has already signed.
 * -3: invalid annotation data.
 * -4: save PDF file failed.
 * -5: cert file open failed.
 */
-(int)signField :(RDPDFDocForm *)appearence :(NSString *)cert_file :(NSString *)pswd :(NSString*)name :(NSString *)reason :(NSString *)location :(NSString *)contact;
/**
 * @brief	get annotation field type in acroForm.
 *			this method valid in premium version
 * @return type as these values:
 * 0: unknown
 * 1: button field
 * 2: text field
 * 3: choice field
 * 4: signature field
 */
-(int)fieldType;
/**
 * @brief get annotation field flag in acroForm.
 * this method require premium license
 * @return flag&1 : read-only
 * flag&2 : is required
 * flag&4 : no export.
 */
-(int)fieldFlag;
/**
 *	@brief	get name of this annotation, example: "EditBox1[0]".
 *			this method valid in premium version
 */
-(NSString *)fieldName;
/**
 * @brief get name of the annotation.
 * this method require premium license
 * @return null if it is not field, or name of the annotation, example: "EditBox1[0]".
 */
-(NSString *)fieldNameWithNO;
/**
 *	@brief	get full name of this annotation, example: "Form1.EditBox1".
 *			this method valid in premium version
 */
-(NSString *)fieldFullName;
/**
 *	@brief	get full name of this annotation with more details, example: "Form1[0].EditBox1[0]".
 *			this method valid in premium version
 */
-(NSString *)fieldFullName2;
/**
 * @brief get jsvascript action of fields
 * this method require premium license.
 * @param idx action index:
 * 0:'K' performed when the user types a keystroke
 * 1:'F' to be performed before the field is formatted to display its current value.
 * 2:'V' to be performed when the field’s value is changed
 * 3:'C' to be performed to recalculate the value of this field when that of another field changes.
 * @return javsscript of field's action, mostly a java-script like:
 * AFDate_FormatEx("dd/mm/yy");
 * most common java script function invoked as:
 * AFNumber_Format
 * AFDate_Format
 * AFTime_Format
 * AFSpecial_Format
 * AFPercent_Format
 * and so on.
 */
-(NSString *)getFieldJS:(int)idx;
/**
 * @brief check if position and size of the annotation is locked?
 * this method valid in professional or premium version
 * @return true if locked, or not locked.
 */
-(bool)isLocked;
/**
 * @brief set lock status for the annotation.
 * this method valid in professional or premium version.
 * @param lock lock status to be set.
 */
-(void)setLocked:(bool)lock;
/**
 * @brief get annotation's name("NM" entry).
 * this method require professional or premium license
 * @return name string.
 */
-(NSString *)getName;
/**
 * @brief set annotation's name("NM" entry).
 * this method require professional or premium license
 * @param name name string to be set.
 * @return true or false.
 */
-(bool)setName:(NSString *)name;
/**
 * @brief is this annotation read-only?
 * @return if annotation is field, return field property. otherwise return annotation property.
 */
-(bool)isReadonly;
/**
 * @brief if annotation is field, then set field property
 * otherwise, set annotation property.
 * @param read_only true or false.
 */
-(void)setReadonly:(bool)readonly;
/**
 * @brief check whether the annotation is hide.
 * @return true or false.
 */
-(bool)isHidden;
/**
 * @brief set hide status for annotation.
 * this method valid in professional or premium version.
 * you need render page again to show modified annotation.
 * @param hide true or false.
 */
-(bool)setHidden:(bool)hide;
-(bool)render:(RDPDFDIB *)dib :(int)back_color;
/**
 * @brief get annotation's box rectangle.
 *			this method valid in professional or premium version
 * @param rect fill 4 elements: left, top, right, bottom in PDF coordinate system
 */
-(void)getRect:(PDF_RECT *)rect;
/**
 * @brief set annotation's box rectangle.
 * this method valid in professional or premium version.
 * you shall render page after this invoked, to resize or move annotation.
 * @param rect rect in PDF coordinate system
 */
-(void)setRect:(const PDF_RECT *)rect;
/**
 * @brief get modify DateTime of Annotation.
 * this method require professional or premium license
 * @return DateTime String object
 * format as (D:YYYYMMDDHHmmSSOHH'mm') where:
 * YYYY is the year
 * MM is the month
 * DD is the day (01–31)
 * HH is the hour (00–23)
 * mm is the minute (00–59)
 * SS is the second (00–59)
 * O is the relationship of local time to Universal Time (UT), denoted by one of the characters +, −, or Z (see below)
 * HH followed by ' is the absolute value of the offset from UT in hours (00–23)
 * mm followed by ' is the absolute value of the offset from UT in minutes (00–59)
 * more details see PDF-Reference-1.7 section 3.8.3
 */
-(NSString *)getModDate;
/**
 * @brief get modify DateTime of Annotation.
 * this method require professional or premium license
 * @param mdate DateTime String object
 * format as (D:YYYYMMDDHHmmSSOHH'mm') where:
 * YYYY is the year
 * MM is the month
 * DD is the day (01–31)
 * HH is the hour (00–23)
 * mm is the minute (00–59)
 * SS is the second (00–59)
 * O is the relationship of local time to Universal Time (UT), denoted by one of the characters +, −, or Z (see below)
 * HH followed by ' is the absolute value of the offset from UT in hours (00–23)
 * mm followed by ' is the absolute value of the offset from UT in minutes (00–59)
 * more details see PDF-Reference-1.7 section 3.8.3
 * @return true or false
 */
-(bool)setModDate:(NSString *)mdate;
/**
* @brief get markup annotation's rectangles.
* this method valid in professional or premium version.
* @param rects rects in PDF coordinate system, as out values.
* @param cnt count of rects allocated.
* @return rects count that markup annotation has.
*/
-(int)getMarkupRects:(PDF_RECT *)rects : (int)cnt;
/**
 * @brief get annotation index.
 * @return annotation index
 */
-(int)getIndex;
/**
 * @brief get Path object from Ink annotation.
 * this method require professional or premium license
 * @return a new Path object, you need invoke Path_destroy() to free memory.
 */
-(RDPDFPath *)getInkPath;
/**
 * @brief set Path to Ink annotation.
 * you need render page again to show modified annotation.
 * this method require professional or premium license
 * @param path Path object.
 * @return true or false.
 */
-(bool)setInkPath:(RDPDFPath *)path;
/**
 * @brief get Path object from Polygon annotation.
 * this method require professional or premium license
 * @return a new Path object, you need invoke Path_destroy() to free memory.
 */
-(RDPDFPath *)getPolygonPath;
/**
 * @brief set Path to Polygon annotation.
 * you need render page again to show modified annotation.
 * this method require professional or premium license
 * @param path Path object.
 * @return true or false.
 */
-(bool)setPolygonPath:(RDPDFPath *)path;
/**
 * @brief get Path object from Polyline annotation.
 * this method require professional or premium license
 * @return a new Path object, you need invoke Path_destroy() to free memory.
 */
-(RDPDFPath *)getPolylinePath;
/**
 * @brief set Path to Polyline annotation.
 * you need render page again to show modified annotation.
 * this method require professional or premium license
 * @param path PDF_PATH object.
 * @return true or false.
 */
-(bool)setPolylinePath:(RDPDFPath *)path;
/**
 * @brief get line style of line or polyline annotation.
 * this method require professional or premium license
 * @return (ret >> 16) is style of end point, (ret & 0xffff) is style of start point.
 */
-(int)getLineStyle;
/**
 * @brief set line style of line or polyline annotation.
 * this method require professional or premium license
 * @param style (style >> 16) is style of end point, (style & 0xffff) is style of start point.
 * @return true or false.
 */
-(bool)setLineStyle:(int)style;
/**
 * @brief get point of line annotation.
 * this method require professional or premium license
 * @param idx 0: start point, others: end point.
 * @return PDF_POINT object, array as [x,y], or null.
 */
-(PDF_POINT)getLinePoint:(int)idx;
-(bool)setLinePoint:(float) x1 :(float) y1 :(float) x2 :(float) y2;

/**
 * @brief get fill color of square/circle/highlight/line/ploygon/polyline/sticky text/free text annotation.
 * this method valid in professional or premium version
 * @return color value formatted as 0xAARRGGBB, if 0 returned, means false.
 */
-(int)getFillColor;
/**
 * @brief set fill color of square/circle/highlight/line/ploygon/polyline/sticky text/free text annotation.
 * you need render page again to show modified annotation.
 * this method valid in professional or premium version
 * @param color color value formatted as 0xAARRGGBB, if alpha channel is too less or 0, return false.
 * @return true or false
 */
-(bool)setFillColor:(int)color;
/**
 * @brief get stroke color of square/circle/ink/line/underline/Squiggly/strikeout/ploygon/polyline/free text annotation.
 * this method valid in professional or premium version
 * @return color value formatted as 0xAARRGGBB, if 0 returned, means false.
 */
-(int)getStrokeColor;
/**
 * @brief set stroke color of square/circle/ink/line/underline/Squiggly/strikeout/ploygon/polyline/free text annotation.
 * you need render page again to show modified annotation.
 * this method valid in professional or premium version
 * @param color color value formatted as 0xAARRGGBB, if alpha channel is too less or 0, return false.
 * @return true or false
 */
-(bool)setStrokeColor:(int)color;
/**
 * @brief get stroke width of square/circle/ink/line/ploygon/polyline/free text annotation.
 * for free text annotation: width of edit-box border.
 * this method valid in professional or premium version
 * @return width value in PDF coordinate, or 0 if error.
 */
-(float)getStrokeWidth;
/**
 * @brief set stroke width of square/circle/ink/line/ploygon/polyline/free text annotation.
 * for free text annotation: width of edit-box border
 * you need render page again to show modified annotation.
 * this method valid in professional or premium version.
 * @param width stroke width in PDF coordinate.
 * @return true or false
 */
-(bool)setStrokeWidth:(float)width;
-(int)getStrokeDash:(float*)dashs : (int)dashs_max;
/**
 * @brief set stroke dash of square/circle/ink/line/ploygon/polyline/free text/text field annotation.
 * for free text or text field annotation: dash of edit-box border
 * you need render page again to show modified annotation.
 * this method require professional or premium license
 * @param dash stroke dash array units.
 * @param cnt stroke dash array length.
 * @return true or false
 */
-(bool)setStrokeDash:(float *)dash : (int)cnt;
/**
 * @brief get icon value for sticky text note/file attachment annotation.
 * this method valid in professional or premium version
 * @return icon value depends on annotation type.
 * For sticky text note:
 * 0: Note
 * 1: Comment
 * 2: Key
 * 3: Help
 * 4: NewParagraph
 * 5: Paragraph
 * 6: Insert
 * 7: Check
 * 8: Circle
 * 9: Cross
 *
 * For file attachment:
 * 0: PushPin
 * 1: Graph
 * 2: Paperclip
 * 3: Tag
 *
		 * For Rubber Stamp:
		 *  0: "Draft"(default icon)
		 *  1: "Approved"
		 *  2: "Experimental"
		 *  3: "NotApproved"
		 *  4: "AsIs"
		 *  5: "Expired"
		 *  6: "NotForPublicRelease"
		 *  7: "Confidential"
		 *  8: "Final"
		 *  9: "Sold"
		 * 10: "Departmental"
		 * 11: "ForComment"
		 * 12: "TopSecret"
		 * 13: "ForPublicRelease"
		 * 14: "Accepted"
		 * 15: "Rejected"
		 * 16: "Witness"
		 * 17: "InitialHere"
		 * 18: "SignHere"
		 * 19: "Void"
		 * 20: "Completed"
		 * 21: "PreliminaryResults"
		 * 22: "InformationOnly"
		 * 23: "End"
 */
-(int)getIcon;
/**
 * @brief set icon for sticky text note/file attachment annotation.
 * you need render page again to show modified annotation.
 * this method valid in professional or premium version
 * @param icon icon value depends on annotation type.
 * For sticky text note:
 * 0: Note
 * 1: Comment
 * 2: Key
 * 3: Help
 * 4: NewParagraph
 * 5: Paragraph
 * 6: Insert
 * 7: Check
 * 8: Circle
 * 9: Cross
 *
 * For file attachment:
 * 0: PushPin
 * 1: Graph
 * 2: Paperclip
 * 3: Tag
 *
		 * For Rubber Stamp:
		 *  0: "Draft"(default icon)
		 *  1: "Approved"
		 *  2: "Experimental"
		 *  3: "NotApproved"
		 *  4: "AsIs"
		 *  5: "Expired"
		 *  6: "NotForPublicRelease"
		 *  7: "Confidential"
		 *  8: "Final"
		 *  9: "Sold"
		 * 10: "Departmental"
		 * 11: "ForComment"
		 * 12: "TopSecret"
		 * 13: "ForPublicRelease"
		 * 14: "Accepted"
		 * 15: "Rejected"
		 * 16: "Witness"
		 * 17: "InitialHere"
		 * 18: "SignHere"
		 * 19: "Void"
		 * 20: "Completed"
		 * 21: "PreliminaryResults"
		 * 22: "InformationOnly"
		 * 23: "End"
 * @return true or false.
 */
-(bool)setIcon:(int)icon;
/**
 * @brief set customized icon for: sticky text note/file attachment annotation, and unsigned signature field.
 * @param icon_name customized icon name.
 * @param icon DocForm object return from RDPDFDoc.newForm
 * @return true or false.
 */
-(bool)setIcon2:(NSString *)icon_name :(RDPDFDocForm *)icon;
/**
 * @brief get annotation's destination.
 * this method valid in professional or premium version
 * @return 0 based page NO, or -1 if failed.
 */
-(int)getDest;
/**
 * @brief get annotation's URL link string.
 * this method valid in professional or premium version
 * @return string of URL, or null
 */
-(NSString *)getURI;
/**
 * @brief get annotation's java-script string.
 * this method require professional or premium license
 * @return string of java-script, or null.
 */
-(NSString *)getJS;
/**
 * @brief get additional action, for java script.
 * @param idx ievent type as below:
 * 0:(Optional; PDF 1.2) An action to be performed when the cursor enters the annotation’s active area.
 * 1:(Optional; PDF 1.2) An action to be performed when the cursor exits the annotation’s active area.
 * 2 (Optional; PDF 1.2) An action to be performed when the mouse button is pressed inside the annotation’s active area. (The name D stands for "down.")
 * 3:(Optional; PDF 1.2) An action to be performed when the mouse button is released inside the annotation’s active area. (The name U stands for "up.")
 * 4:(Optional; PDF 1.2; widget annotations only) An action to be performed when the annotation receives the input focus.
 * 5:(Optional; PDF 1.2; widget annotations only) (Uppercase B, lowercase L) An action to be performed when the annotation loses the input focus. (The name Bl stands for "blurred.")
 * 6:(Optional; PDF 1.5) An action to be performed when the page containing the annotation is opened (for example, when the user navigates to it from the next or previous page or by means of a link annotation or outline item). The action is executed after the O action in the page’s additional-actions dictionary (see Table 8.45) and the OpenAction entry in the document catalog (see Table 3.25), if such actions are present.
 * 7:(Optional; PDF 1.5) An action to be performed when the page containing the annotation is closed (for example, when the user navigates to the next or previous page, or follows a link annotation or outline item). The action is executed before the C action in the page’s additional-actions dictionary (see Table 8.45), if present.
 * 8:(Optional; PDF 1.5) An action to be performed when the page containing the annotation becomes visible in the viewer application’s user interface.
 * 9:(Optional; PDF 1.5) An action to be performed when the page containing the annotation is no longer visible in the viewer application’s user interface.
 *  @return string of java-script, or null.
 */
-(NSString *)getAdditionalJS :(int)idx;
/**
 * @brief get annotation's 3D object name.
 * this method valid in professional or premium version
 * @return name of the 3D object, or null
 */
-(NSString *)get3D;
/**
 * @brief get annotation's movie name.
 * this method valid in professional or premium version
 * @return name of the movie, or null
 */
-(NSString *)getMovie;
/**
 * @brief get annotation's sound name.
 * this method valid in professional or premium version
 * @return name of the audio, or null
 */
-(NSString *)getSound;
/**
 * @brief get annotation's attachment name.
 * this method valid in professional or premium version
 * @return name of the attachment, or null
 */
-(NSString *)getAttachment;
-(NSString *)getRendition;
/**
 * @brief get annotation's 3D data. must be *.u3d format.
 * this method valid in professional or premium version
 * @param save_file full path name to save data.
 * @return true if save_file created, or false.
 */
-(bool)get3DData:(NSString *)save_file;
/**
 * @brief get annotation's movie data.
 * this method valid in professional or premium version
 * @param save_file full path name to save data.
 * @return true if save_file created, or false.
 */
-(bool)getMovieData:(NSString *)save_file;
/**
 * @brief get annotation's sound data.
 * this method valid in professional or premium version
 * @param paras paras[0] == 0, if formated audio file(*.mp3 ...).
 * @param save_file full path name to save data.
 * @return true if save_file created, or false.
 */
-(bool)getSoundData:(int *)paras :(NSString *)save_file;
/**
 * @brief get annotation's attachment data.
 * this method valid in professional or premium version
 * @param save_file full path name to save data.
 * @return true if save_file created, or false.
 */
-(bool)getAttachmentData:(NSString *)save_file;
-(bool)getRenditionData:(NSString *)save_file;
/**
 * @brief get item count of RichMedia annotation.
 * this method require professional or premium license.
 * @return count of items, or -1 if not RichMedia annotation, and no premium license actived.
 */
-(int)getRichMediaItemCount;
/**
 * @brief get actived item of RichMedia annotation.
 * this method require professional or premium license.
 * @return index of actived item, or -1 if not RichMedia annotation, and no premium license actived.
 */
-(int)getRichMediaItemActived;
/**
 * @brief get content type of an item of RichMedia annotation.
 * this method require professional or premium license.
 * @param idx range in [0, RDPDFAnnot.getRichMediaItemCount()]
 * @return type of item:
 * -1: unknown or error.
 * 0: Video.
 * 1：Sound.
 * 2:Flash file object.
 * 3:3D file object.
 */
-(int)getRichMediaItemType:(int) idx;
/**
 * @brief return asset name of content of an item of RichMedia annotation.
 * this method require professional or premium license.
 * @param idx range in [0, RDPDFAnnot.getRichMediaItemCount()]
 * @return asset name, or null.
 * asset name example: "VideoPlayer.swf"
 */
-(NSString *)getRichMediaItemAsset:(int) idx;
/**
 * @brief return parameters of an item of RichMedia annotation.
 * this method require professional or premium license.
 * @param idx range in [0, RDPDFAnnot.getRichMediaItemCount()]
 * @return parameter string, or null.
 * parameter example: "source=myvideo.mp4&skin=SkinOverAllNoFullNoCaption.swf&skinAutoHide=true&skinBackgroundColor=0x5F5F5F&skinBackgroundAlpha=0.75&volume=1.00"
 */
-(NSString *)getRichMediaItemPara:(int) idx;
/**
 * @brief return source of an item of RichMedia annotation.
 * this method require professional or premium license.
 * @param idx range in [0, RDPDFAnnot.getRichMediaItemCount()]
 * @return parameter string, or null.
 * parameter example: "source=myvideo.mp4&skin=SkinOverAllNoFullNoCaption.swf&skinAutoHide=true&skinBackgroundColor=0x5F5F5F&skinBackgroundAlpha=0.75&volume=1.00"
 * the source is "source=myvideo.mp4", return string is "myvideo.mp4"
 */
-(NSString *)getRichMediaItemSource:(int) idx;
/**
 * @brief save source of an item of RichMedia annotation to a file.
 * this method require professional or premium license.
 * @param idx range in [0, RDPDFAnnot.getRichMediaItemCount()]
 * @param save_path absolute path to save file, like "/sdcard/app_data/myvideo.mp4"
 * @return true or false.
 */
-(bool)getRichMediaItemSourceData:(int) idx :(NSString *)save_path;
/**
 * @brief save an asset to a file.
 * this method require professional or premium license.
 * @param asset asset name in RichMedia assets list.
 * @param save_path absolute path to save file, like "/sdcard/app_data/myvideo.mp4"
 * @return true or false.
 * example:
 * GetRichMediaItemAsset(0) return player window named as "VideoPlayer.swf"
 * GetRichMediaItemPara(0) return "source=myvideo.mp4&skin=SkinOverAllNoFullNoCaption.swf&skinAutoHide=true&skinBackgroundColor=0x5F5F5F&skinBackgroundAlpha=0.75&volume=1.00".
 * so we has 3 assets in item[0]:
 * 1."VideoPlayer.swf"
 * 2."myvideo.mp4"
 * 3."SkinOverAllNoFullNoCaption.swf"
 */
-(bool)getRichMediaData :(NSString *)asset :(NSString *)save_path;
/**
 * @brief get annotation's file link path string.
 * this method require professional or premium license
 * @return string of link path, or null
 */
-(NSString*)getFileLink;
/**
 * @brief get popup Annotation associate to this annotation.
 * @return Popup Annotation, or null, if this annotation is Popup Annotation, then return same as this.
 */
-(RDPDFAnnot *)getPopup;
/**
 * @brief get open status for Popup Annotation.
 * if this annotation is not popup annotation, it return Popup annotation open status, which associate to this annotation.
 * this method require professional or premium license.
 * @return true or false.
 */
-(bool)getPopupOpen;
-(int)getReplyCount;
-(RDPDFAnnot*)getReply :(int)idx;
/**
 * @brief get annotation's popup subject.
 * this method valid in professional or premium version
 * @return subject string or null if failed.
 */
-(NSString *)getPopupSubject;
/**
 * @brief get annotation's popup text.
 * this method valid in professional or premium version.
 * @return text string or null if failed.
 */
-(NSString *)getPopupText;
/**
 * @brief get text of popup label annotation.
 * to invoke this function, developers should call RDPDFPage.objsStart or RDPDFAnnot.render before.
 * @return String value of label or null.
 */
-(NSString *)getPopupLabel;
/**
 * @brief set open status for Popup Annotation.
 * if this annotation is not popup annotation, it set Popup annotation open status, which associate to this annotation.
 * this method require professional or premium license.
 * @param open set annotation open status
 * @return true or false.
 */
-(bool)setPopupOpen :(bool)open;
/**
 * @brief set annotation's popup subject.
 * this method valid in professional or premium version
 * @param val subject string
 * @return true or false
 */
-(bool)setPopupSubject:(NSString *)val;
/**
 * @brief set annotation's popup text.
 * this method valid in professional or premium version
 * @param val text string
 * @return true or false
 */
-(bool)setPopupText:(NSString *)val;
/**
 * @brief set text of popup label annotation.
 * to invoke this function, developers should call RDPDFPage.objsStart or RDPDFAnnot.render before.
 * this function valid in professional or premium license.
 * you should re-render page to display modified data.
 * @param val text string
 * @return true or false
 */
-(bool)setPopupLabel:(NSString *)val;
/**
 * @brief get type of edit-box.
 * this method valid in premium version
 * @return -1: this annotation is not text-box.
 * 1: normal single line.
 * 2: password.
 * 3: MultiLine edit area.
 */
-(int)getEditType;
/**
 * @brief get position and size of edit-box.
 * for FreeText annotation, position of edit-box is not the position of annotation.
 * so this function is needed for edit-box.
 * this method valid in premium version
 * @param rect 4 elements in order: left, top, right, bottom, in PDF coordinate.
 * @return true or false
 */
-(bool)getEditRect:(PDF_RECT *)rect;
/**
 * @brief get text size of edit-box.
 * this method valid in premium version
 * @return size of text, in PDF coordinate system.
 */
-(float)getEditTextSize;
/**
 * @brief set text size of edit-box and edit field.
 * this method require premium license
 * @param fsize font size to set.
 * @return true or false.
 */
-(bool)setEditTextSize:(float)fsize;
/**
 * @brief get text align of edit-box.
 * this method valid in premium version
 * @return align of text, 0:left, 1:center, 2:right.
 */
-(int)getEditTextAlign;
/**
 * @brief set text align of edit-box and edit field.
 * this method require premium license
 * @param align text align value, 0: left, 1: center, 2: right.
 * @return true or false.
 */
-(bool)setEditTextAlign:(int)align;
/**
 * @brief get contents of edit-box.
 * this method valid in premium version
 * @return content in edit-box
 */
-(NSString *)getEditText;
/**
 * @brief set contents of edit-box.
 * you should re-render page to display modified data.
 * this method valid in premium version
 * @param val contents to be set.in MultiLine mode: '\r' or '\n' means change line.in password mode the edit box always display "*".
 * @return true or false.
 */
-(bool)setEditText:(NSString *)val;
/**
 * @brief set font of edittext.
 * you should re-render page to display modified data.
 * this method require premium license.
 * @param  font    DocFont object from RDPDFDoc.newFontCID().
 * @return true or false.
 */
-(bool)setEditFont:(RDPDFDocFont *)font;
/**
 * @brief get text color for edit-box annotation. 
 * include text field and free-text.
 * this method require premium license
 * @return 0 or color, format as 0xAARRGGBB.
 */
-(int)getEditTextColor;
/**
 * @brief set text color for edit-box annotation.include text field and free-text
 * this method require premium license
 * @param color color format as 0xRRGGBB, alpha channel are ignored.
 * @return true or false.
 */
-(bool)setEditTextColor:(int)color;
/**
 * @brief get item count of combo-box.
 * this method valid in premium version
 * @return -1: this is not combo. otherwise: items count.
 */
-(int)getComboItemCount;
/**
 * @brief get an item of combo-box.
 * this method valid in premium version
 * @param index 0 based item index. range:[0, RDPDFAnnot.getComboItemCount()-1]
 * @return null if this is not combo-box, "" if no item selected, otherwise the item selected.
 */
-(NSString *)getComboItem :(int)index;
/**
 * @brief get export value of combo-box.
 * this method require premium license
 * @param index 0 based item index. range:[0, RDPDFAnnot.getComboItemCount()-1]
 * @return String value or null
 */
-(NSString *)getComboItemVal :(int)index;
/**
 * @brief get current selected item index of combo-box.
 * this method valid in premium version
 * @return -1 if this is not combo-box or no item selected, otherwise the item index that selected.
 */
-(int)getComboSel;
/**
 * @brief set current selected.
 * you should re-render page to display modified data.
 * this method valid in premium version
 * @param index 0 based item index to set.
 * @return true or false.
 */
-(bool)setComboSel:(int)index;
/**
 * @brief can list select more than 1 item?
 * @return true or false.
 */
-(bool)isMultiSel;
/**
 * @brief get item count of list-box.
 * this method valid in premium version
 * @return -1: this is not a list. otherwise: items count.
 */
-(int)getListItemCount;
/**
 * @brief get an item of list-box.
 * this method valid in premium version
 * @param index 0 based item index. range:[0, RDPDFAnnot.getListItemCount()-1]
 * @return null if this is not list-box, "" if no item selected, otherwise the item selected.
 */
-(NSString *)getListItem:(int)index;
/**
 * @brief get export value of list-box item.
 * this method require premium license
 * @param index 0 based item index. range:[0, RDPDFAnnot.getListItemCount()-1]
 * @return String value or null.
 */
-(NSString *)getListItemVal:(int)index;
/**
 * @brief get selected indexes of list-box.
 * this method valid in premium version
 * @return -1 if it is not a list-box, or no items selected if return 0.
 */
-(int)getListSels:(int *)sels :(int)sels_max;
/**
 * @brief set selects of list-box
 * this method valid in premium version
 * @param sels 0 based indexes of items.
 * @return true or false
 */
-(bool)setListSels:(const int *)sels :(int)sels_cnt;
/**
 * @brief get status of check-box and radio-box.
 * this method valid in premium version
 * @return -1 if annotation is not valid control.
 * 0 if check-box is unchecked.
 * 1 if check-box checked.
 * 2 if radio-box is unchecked.
 * 3 if radio-box checked.
 */
-(int)getCheckStatus;
/**
 * @brief set value to check-box.
 * you should re-render page to display modified data.
 * this method valid in premium version
 * @param check true or false.
 * @return true or false.
 */
-(bool)setCheckValue:(bool)check;
/**
 * @brief check the radio-box and deselect others in radio group.
 * you should re-render page to display modified data.
 * this method valid in premium version
 * @return true or false.
 */
-(bool)setRadio;
/**
 * @brief check if the annotation is reset button?
 * this method valid in premium version
 * @return true or false.
 */
-(bool)getReset;
/**
 * @brief perform the button and reset the form.
 * you should re-render page to display modified data.
 * this method valid in premium version
 * @return true or false.
 */
-(bool)setReset;
/**
 * @brief get annotation submit target.
 * this method valid in premium version
 * @return null if this is not submit button.
 */
-(NSString *)getSubmitTarget;
/**
 * @brief get annotation submit parameters.
 * mail mode: return whole XML string for form data.
 * other mode: url data likes: "para1=xxx&para2=xxx".
 * this method valid in premium version
 * @return null if this is not submit button.
 */
-(NSString *)getSubmitPara;
/**
 * @brief remove annotation
 * you should re-render page to display modified data.
 * this method valid in professional or premium version
 * @return true or false
 */
-(bool)removeFromPage;
/**
 * @brief flate single annotation
 * you should render page again to display modified data.
 * this method require professional or premium license
 * @return true or false
 */
-(bool)flateFromPage;
/**
 * @brief get status of signature field.
 * this method require premium license
 * @return -1 if this is not signature field
 * 0 if not signed.
 * 1 if signed.
 */
-(int)getSignStatus;
/**
 * @brief get signature field object.
 * this method require premium license
 * @return PDF Sign object
 */
-(RDPDFSign *)getSign;
/**
 * @brief move annotation to another page.
 * this method require professional or premium license.
 * this method just like invoke RDPDFPage.copyAnnot() and RDPDFAnnot.removeFromPage(), but less data generated.
 * Notice: ObjsStart shall be invoked for page.
 * @param page page destination. returned from RDPDFDoc.page().
 * @param rect [left, top, right, bottom] in PDF coordinate in destination page.
 * @return true or false.
 */
-(bool)MoveToPage:(RDPDFPage *)page :(const PDF_RECT *)rect;
- (BOOL)canMoveAnnot;
-(PDF_OBJ_REF)getRef;

@end

@interface RDPDFPage : NSObject
{
    PDF_PAGE m_page;
}
@property (readonly) PDF_PAGE handle;
/**
 * @brief create RDPDFPage object, this method is not supplied for developers, but invoked inner.
 *
 */
-(id)init:(PDF_PAGE) hand;
/**
 * @brief advanced function to get reference of annotation object.
 * this method require premium license.
 * @return reference
 */
-(PDF_OBJ_REF)advanceGetRef;
/**
 * @brief advanced function to reload annotation object, after advanced methods update annotation object data.
 * this method require premium license.
 */
-(void)advanceReload;
/**
 * @brief annotation from memory(byte array)
 * a premium license is required for this method.
 * @param rect [left, top, right, bottom] in PDF coordinate. which is the import annotation's position.
 * @param data data returned from RDPDFPage.export()
 * @param data_len data length
 * @return true or false.
 */
-(bool)importAnnot:(const PDF_RECT *)rect :(const unsigned char *)dat :(int)dat_len;
/**
 * @brief render thumb image to dib object.
 * the image always scale and displayed in center of dib.
 * @param dib DIB to render
 * @return true if the page has thumb image, or false.
 */
-(bool)renderThumb:(RDPDFDIB *)dib;
/**
 * @brief prepare to render, this method just erase DIB to white.
 */
-(void)renderPrepare:(RDPDFDIB *)dib;
/**
 * @brief render page to dib object. this function returned for cancelled or finished.
 * before render, you need invoke RenderPrePare.
 * @param dib DIB object to render. obtained by Global.dibGet().
 * @param mat Matrix object define scale, rotate, translate operations.
 * @param quality render quality applied to Image rendering.
 * 0: draft
 * 1: normal
 * 2: best quality.
 * @return true or false.
 */
-(bool)render:(RDPDFDIB *)dib :(RDPDFMatrix *)mat :(int)quality;
/**
 * @brief set page status to cancelled and cancel render function.
 */
-(void)renderCancel;
/**
 * @brief check if page rendering is finished.
 * @return true or false
 */
-(bool)renderIsFinished;
/**
 * @brief Start Reflow.
 * this method require professional or premium license
 * @param width input width, function calculate height.
 * @param scale scale base to 72 DPI, 2.0 means 144 DPI. the reflowed text will displayed in scale
 * @return the height that reflow needed.
 */
-(float)reflowPrepare:(float)width :(float)scale;
/**
 * @brief Reflow to Bitmap object.
 * this method require professional or premium license
 * @param dib dib object to reflow
 * @param orgx origin x coordinate
 * @param orgy origin y coordinate
 * @return true or false
 */
-(bool)reflow:(RDPDFDIB *)dib :(float)orgx :(float)orgy;
/**
 * @brief get rotate degree for page, example: 0 or 90
 * @return rotate degree for page
 */
-(int)getRotate;
/**
 * @brief remove all annotations and display it as normal content on page.
 * this method require premium license.
 * @return true or false
 */
-(bool)flatAnnots;
/**
 * @brief Sign and save the PDF file.
 * this method required premium license, and signed feature native libs, which has bigger size.
 * @param appearence appearance icon for signature
 * DocForm object return from newForm    
 * @param box RECT for sign field
 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
 * @param pswd password to open cert file.
 * @param name signer name string.
 * @param reason sign reason will write to signature.
 * @param location signature location will write to signature.
 * @param contact contact info will write to signature.
 * @return 0 mean OK
 * -1: generate parameters error.
 * -2: it is not signature field, or field has already signed.
 * -3: invalid annotation data.
 * -4: save PDF file failed.
 * -5: cert file open failed.
 */
-(int)sign :(RDPDFDocForm *)appearence :(const PDF_RECT *)box :(NSString *)cert_file :(NSString *)pswd :(NSString*)name :(NSString *)reason :(NSString *)location :(NSString *)contact;
/**
 * @brief get text objects to memory.
 * a standard license is required for this method
 */
-(void)objsStart:(bool)rtol;
/**
 * @brief get chars count in this page. this can be invoked after ObjsStart
 * a standard license is required for this method
 * @return count or 0 if ObjsStart not invoked.
 */
-(int)objsCount;
/**
 * @brief get string from range. this can be invoked after ObjsStart
 * @param from 0 based unicode index.
 * @param to 0 based unicode index.
 * @return string or null.
 */
-(NSString *)objsString:(int)from :(int)to;
/**
 * @brief get index aligned by word. this can be invoked after ObjsStart
 * @param index 0 based unicode index.
 * @param dir if dir < 0,  get start index of the word. otherwise get last index of the word.
 * @return new index value.
 */
-(int)objsAlignWord:(int)index :(int)dir;
/**
 * @brief get char's box in PDF coordinate system, this can be invoked after ObjsStart
 * @param index 0 based unicode index.
 * @param rect return 4 elements for PDF rectangle.
 */
-(void)objsCharRect:(int)index :(PDF_RECT *)rect;
/**
 * @brief get char index nearest to point
 * @param x point as [x,y] in PDF coordinate.
 * @param y point as [x,y] in PDF coordinate.
 * @return char index or -1 failed.
 */
-(int)objsGetCharIndex:(float)x :(float)y;
/**
 * @brief create a find session. this can be invoked after ObjsStart
 * @param key key string to find.
 * @param match_case match case?
 * @param whole_word match whole word?
 * @return handle of find session, or 0 if no found.
 */
-(RDPDFFinder *)find:(NSString *)key :(bool)match_case :(bool)whole_word;
/**
 * @brief create a find session. this can be invoked after ObjsStart
 * this function treats line break as blank char.
 * @param key key string to find.
 * @param match_case match case?
 * @param whole_word match whole word?
 * @param skip_blank skip blank?
 * @return handle of find session, or 0 if no found.
 */
-(RDPDFFinder *)find2:(NSString *)key :(bool)match_case :(bool)whole_word :(bool)skip_blanks;
/**
 * @brief get annotations count in this page.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @return count
 */
-(int)annotCount;
/**
 * @brief get annotations by index.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param index 0 based index value. range:[0, GetAnnotCount()-1]
 * @return handle of annotation, valid until Close invoked.
 */
-(RDPDFAnnot *)annotAtIndex:(int)index;
/**
 * @brief get annotations by PDF point.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param x x value in PDF coordinate system.
 * @param y y value in PDF coordinate system.
 * @return handle of annotation, valid until Close invoked.
 */
-(RDPDFAnnot *)annotAtPoint:(float)x :(float)y;
/**
 * @brief get annotation by name.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method require professional or premium license
 * @param name name string in "NM" entry of annotation.
 * @return Annotation object, valid until Page.Close invoked.
 */
-(RDPDFAnnot *)annotByName:(NSString *)name;
/**
 * @brief clone an annotation object to this page.
 * this method need a professional or premium license.
 * @param annot annotation object returned from RDPDFPage.annotAtIndex or RDPDFPage.annotAtPoint
 * Annotation object must be in this document.
 * @param rect [left, top, right, bottom] in PDF coordinate.
 * @return true or false.
 */
-(bool)copyAnnot:(RDPDFAnnot *)annot :(const PDF_RECT *)rect;
-(bool)addAnnot:(PDF_OBJ_REF)ref :(int)index;

-(bool)addAnnotPopup:(RDPDFAnnot *)parent :(const PDF_RECT *)rect :(bool)open;
/**
 * @brief add a text-markup annotation to page.
 * you should re-render page to display modified data.
 * this can be only invoked after ObjsStart.
 * this method valid in professional or premium version
 * @param index1 first char index
 * @param index2 second char index
 * @param type type as following:
 * 0: Highlight
 * 1: Underline
 * 2: StrikeOut
 * 3: Highlight without round corner
 * 4: Squiggly underline.
 * @return true or false.
 */
-(bool)addAnnotMarkup:(int)index1 :(int)index2 :(int)type :(int) color;
/**
 * @brief add hand-writing to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param ink Ink object in PDF coordinate.
 * @return true or false.
 */
-(bool)addAnnotInk:(RDPDFInk *)ink;
/**
 * @brief add goto-page link to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param rect link area rect [left, top, right, bottom] in PDF coordinate.
 * @param dest 0 based pageno to jump.
 * @param top y coordinate in PDF coordinate, page.height is top of page. and 0 is bottom of page.
 * @return true or false.
 */
-(bool)addAnnotGoto:(const PDF_RECT *)rect :(int)dest :(float)top;
/**
 * @brief add URL link to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param rect link area rect [left, top, right, bottom] in PDF coordinate.
 * @param uri url address, example: "http://www.radaee.com/en"
 * @return true or false
 */
-(bool)addAnnotURI:(NSString *)uri :(const PDF_RECT *)rect;
/**
 * @brief add line to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param pt1 start point in PDF coordinate, 2 elements for x,y
 * @param pt2 end point in PDF coordinate, 2 elements for x,y
 * @param style1 style for start point:
 * 0: None
 * 1: Arrow
 * 2: Closed Arrow
 * 3: Square
 * 4: Circle
 * 5: Butt
 * 6: Diamond
 * 7: Reverted Arrow
 * 8: Reverted Closed Arrow
 * 9: Slash
 * @param style2 style for end point, values are same as style1.
 * @param width line width in DIB coordinate
 * @param color line color. same as addAnnotRect.
 * @param icolor fill color, used to fill arrows of the line.
 * @return true or false.
 */
-(bool)addAnnotLine:(const PDF_POINT *)pt1 :(const PDF_POINT *)pt2 :(int) style1 :(int) style2 :(float) width :(int) color :(int) icolor;
/**
 * @brief add rectangle to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param rect 4 elements for left, top, right, bottom in PDF coordinate system
 * @param width line width in PDF coordinate.
 * @param color rectangle color, formated as 0xAARRGGBB
 * @param icolor fill color in rectangle, formated as 0xAARRGGBB, if alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
 * @return true or false
 */
-(bool)addAnnotRect:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor;
/**
 * @brief add ellipse to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param rect 4 elements for left, top, right, bottom in PDF coordinate system
 * @param width line width in PDF coordinate
 * @param color ellipse color, formated as 0xAARRGGBB
 * @param icolor fill color in ellipse, formated as 0xAARRGGBB, if alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
 * @return true or false
 */
-(bool)addAnnotEllipse:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor;
/**
 * @brief add polygon to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method require professional or premium license
 * @param path must be a set of unclosed lines. do not container any move-to operation except the first point in the path.
 * @param color stroke color formated as 0xAARRGGBB.
 * @param fill_color fill color, formated as 0xAARRGGBB. if AA == 0, no fill operations, otherwise alpha value is same to stroke color.
 * @param width stroke width in PDF coordinate
 * @return true or false.
 * the added annotation can be obtained by RDPDFPage.annotAtIndex(RDPDFPage.annotCount()- 1), if this method return true.
 */
-(bool)addAnnotPolygon:(RDPDFPath *)path :(int) color :(int) fill_color :(float) width;
/**
 * @brief add polyline to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method require professional or premium license
 * @param path must be a set of unclosed lines. do not container any move-to operation except the first point in the path.
 * @param style1 style for start point:
 * 0: None
 * 1: Arrow
 * 2: Closed Arrow
 * 3: Square
 * 4: Circle
 * 5: Butt
 * 6: Diamond
 * 7: Reverted Arrow
 * 8: Reverted Closed Arrow
 * 9: Slash
 * @param style2 style for end point, values are same as style1.
 * @param color stroke color formated as 0xAARRGGBB.
 * @param fill_color fill color, formated as 0xAARRGGBB. if AA == 0, no fill operations, otherwise alpha value is same to stroke color.
 * @param width stroke width in PDF coordinate
 * @return true or false.
 * the added annotation can be obtained by RDPDFPage.annotAtIndex(RDPDFPage.annotCount()- 1), if this method return true.
 */
-(bool)addAnnotPolyline:(RDPDFPath *)c :(int) style1 :(int) style2 :(int) color :(int) fill_color :(float) width;
/**
 * @brief add a sticky text annotation to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param pt 2 elements: x, y in PDF coordinate system.
 * @return true or false.
 */
-(bool)addAnnotNote:(const PDF_POINT *)pt;
	/**
	 * @brief add an Rubber Stamp to page.
	 * you should re-render page to display modified data.
	 * this can be invoked after ObjsStart or Render or RenderToBmp.
	 * this method valid in professional or premium version
	 * @param rect icon area rect [left, top, right, bottom] in PDF coordinate.
	 * @param icon predefined value as below:
	 *  0: "Draft"(default icon)
	 *  1: "Approved"
	 *  2: "Experimental"
	 *  3: "NotApproved"
	 *  4: "AsIs"
	 *  5: "Expired"
	 *  6: "NotForPublicRelease"
	 *  7: "Confidential"
	 *  8: "Final"
	 *  9: "Sold"
	 * 10: "Departmental"
	 * 11: "ForComment"
	 * 12: "TopSecret"
	 * 13: "ForPublicRelease"
	 * 14: "Accepted"
	 * 15: "Rejected"
	 * 16: "Witness"
	 * 17: "InitialHere"
	 * 18: "SignHere"
	 * 19: "Void"
	 * 20: "Completed"
	 * 21: "PreliminaryResults"
	 * 22: "InformationOnly"
	 * 23: "End"
	 * @return true or false.
	 * the added annotation can be obtained by Page.GetAnnot(Page.GetAnnotCount() - 1), if this method return true.
	 */
-(bool)addAnnotStamp:(int)icon :(const PDF_RECT *)rect;
/**
 * @brief add bitmap annotation to page
 * to invoke this function, developers should call RDPDFPage.objsStart or RDPDFPage.render before.
 * this function valid in professional or premium license.
 * you should re-render page to display modified data.
 * @param matrix Matrix object passed to RDPDFPage.render
 * @param dimg bitmap data, must be in RGBA color space.
 * @param rect rect in PDF coordinate.
 * @return true or false
 */
-(bool)addAnnotBitmap0:(RDPDFMatrix *)mat :(RDPDFDocImage *)dimage :(const PDF_RECT *)rect;
-(bool)addAnnotBitmap:(RDPDFDocImage *)dimage : (const PDF_RECT *)rect;
/**
 * @brief  add a RichMedia annotation to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method require professional or premium license, and RDPDFDoc.setCache invoked.
 * @param  path_player     path-name to flash player. example: "/sdcard/VideoPlayer.swf", "/sdcard/AudioPlayer.swf"
 * @param  path_content    path-name to RichMedia content. example: "/sdcard/video.mp4", "/sdcard/audio.mp3"
 * @param  type 0: Video, 1: Audio, 2: Flash, 3: 3D
 * Video like *.mpg, *.mp4 ...
 * Audio like *.mp3 ...
 * @param  dimage DocImage object return from RDPDFDoc.NewImage.
 * @param  rect 4 elements: left, top, right, bottom in PDF coordinate system.
 *  @return true or false.
 */
-(bool)addAnnotRichMedia:(NSString *)path_player :(NSString *)path_content :(int)type :(RDPDFDocImage *)dimage :(const PDF_RECT *)rect;
/**
 * @brief add a file as an attachment to page.
 * you should re-render page to display modified data.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param att absolute path name to the file.
 * @param icon icon display to the page. values as:
 * 0: PushPin
 * 1: Graph
 * 2: Paperclip
 * 3: Tag
 * @param rect 4 elements: left, top, right, bottom in PDF coordinate system.
 * @return true or false.
*/
-(bool)addAnnotAttachment:(NSString *)att :(int)icon :(const PDF_RECT *)rect;
/**
 * @brief add a font as resource of this page.
 * a premium license is required for this method.
 * @param font font object created by RDPDFDoc.newFontCID
 * @return ResFont or null.
 */
-(PDF_PAGE_FONT)addResFont:(RDPDFDocFont *)font;
/**
 * @brief add an image as resource of this page.
 * a premium license is required for this method.
 * @param image image object created by RDPDFDoc.newImageXXX
 * @return null means failed.
 */
-(PDF_PAGE_IMAGE)addResImage:(RDPDFDocImage *)image;
/**
 * @brief add GraphicState as resource of this page.
 * a premium license is required for this method.
 * @param gstate ExtGraphicState created by RDPDFDoc.newGState();
 * @return null means failed.
 */
-(PDF_PAGE_GSTATE)addResGState:(RDPDFDocGState *)gstate;
/**
 * @brief add Form as resource of this page.
 * a premium license is required for this method.
 * @param form Form created by RDPDFDoc.NewForm
 * @return null means failed.
 */
-(PDF_PAGE_FORM)addResForm:(RDPDFDocForm *)form;
/**
 * @brief add content stream to this page.
 * a premium license is required for this method.
 * @param content PageContent object called PageContent.create().
 * @return true or false.
 */
-(bool)addContent:(RDPDFPageContent *)content :(bool)flush;
/**
 * @brief add an edit-box.
 * to invoke this function, developers should call RDPDFPage.objsStart or RPDFPage.render before.
 * this function valid in premium license.
 * @param rect rect in PDF coordinate.
 * @return true or false
 */
-(bool)addAnnotEditText:(const PDF_RECT *)rect;
@end

@interface RDPDFImportCtx : NSObject
{
    PDF_DOC m_doc;
	PDF_IMPORTCTX m_handle;
}
-(id)init:(PDF_DOC)doc :(PDF_IMPORTCTX)handle;
/**
 * @brief import a page to dest document.
 * a premium license is required for this method.
 * @param src_no 0 based page NO. from source Document that passed to ImportStart.
 * @param dst_no 0 based page NO. to insert in dest document object.
 * @return true or false.
 */
-(bool)import:(int)src_no :(int)dst_no;
@end

@interface RDPDFDoc : NSObject
{
    PDF_DOC m_doc;
}
@property (readonly) PDF_DOC handle;
/**
 * @brief a static method set open flag.
 * the flag is a global setting, which effect all Document_OpenXXX() methods.
 * @param flag (flag&1) : load linearzied hint table.
 * (flag&2) : if bit set, mean all pages considered as same size, and SDK will only read first page object in open time, and set all pages size same to first page.
 * (flag&2) only works when (flag&1) is set.
 */
+(void)setOpenFlag:(int)flag;
/**
 * @brief open document.
 * first time, SDK try password as user password, and then try password as owner password.
 * @param path PDF file to be open.
 * @param password password or null if not need password.
 * @return error code:
 * 0:succeeded, and continue
 * -1:need input password
 * -2:unknown encryption
 * -3:damaged or invalid format
 * -10:access denied or invalid file path
 * others:unknown error
 */
-(int)open:(NSString *)path :(NSString *)password;
/**
 * @brief open document in memory.
 * first time, SDK try password as user password, and then try password as owner password.
 * @param data data for whole PDF file in byte array. developers should retain array data, till document closed.
 * @param data_size data array length
 * @param password password or null.
 * @return error code:
 * 0:succeeded, and continue
 * -1:need input password
 * -2:unknown encryption
 * -3:damaged or invalid format
 * -10:access denied or invalid file path
 * others:unknown error
 */
-(int)openMem:(void *)data :(int)data_size :(NSString *)password;
/**
 * @brief open document from stream.
 * first time, SDK try password as user password, and then try password as owner password.
 * @param stream PDFStream object.
 * @param password password or null.
 * @return error code:
 * 0:succeeded, and continue
 * -1:need input password
 * -2:unknown encryption
 * -3:damaged or invalid format
 * -10:access denied or invalid file path
 * others:unknown error
 */
-(int)openStream:(id<PDFStream>)stream :(NSString *)password;
/**
 * @brief open PDF and decrypt PDF using public-key.
 * this feature only enabled on signed feature version. which native libs has bigger size.
 * @param path PDF file path
 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
 * @param password password to open cert file.
 * @return error code:
 * 0:succeeded, and continue
 * -1:need input password
 * -2:unknown encryption
 * -3:damaged or invalid format
 * -10:access denied or invalid file path
 * others:unknown error
 */
-(int)openWithCert:(NSString *)path :(NSString *)cert_file :(NSString *)password;
/**
 * @brief open document from memory and decrypt PDF using public-key.
 * this feature only enabled on signed feature version. which native libs has bigger size.
 * @param data data for whole PDF file in byte array. developers should retain array data, till document closed.
 * @param data_size data array length
 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
 * @param password password to open cert file.
 * @return error code:
 * 0:succeeded, and continue
 * -1:need input password
 * -2:unknown encryption
 * -3:damaged or invalid format
 * -10:access denied or invalid file path
 * others:unknown error
 */
-(int)openMemWithCert:(void *)data :(int)data_size : (NSString *)cert_file :(NSString *)password;
/**
 * @brief open document from stream and decrypt PDF using public-key.
 * first time, SDK try password as user password, and then try password as owner password.
 * @param stream PDFStream object.
 * @param password password or null.
 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
 * @return err error code:
 * 0:succeeded, and continue
 * -1:need input password
 * -2:unknown encryption
 * -3:damaged or invalid format
 * -10:access denied or invalid file path
 * others:unknown error
 */
-(int)openStreamWithCert:(id<PDFStream>)stream : (NSString *)cert_file :(NSString *)password;
/**
 * @brief get linearizied status.
 * @return 0: linearized header not loaded or no linearized header.(if setOpenFlag(0); cause always return 0)
 * 1: there is linearized header, but linearized entry checked as failed.
 * 2: there is linearized header, linearized entry checked succeeded, but hint table is damaged.
 * 3. linearized header loaded succeeded.
 */
-(int)getLinearizedStatus;
/**
 * @brief create a empty PDF document
 * @param path path to create
 * @return 0 or less than 0 means failed, same as Open.
 */
-(int)create:(NSString *)path;
/**
 * @brief advanced function to get reference of catalog object(root object of PDF).
 * this method require premium license.
 * @return PDF cross reference to new object, using RDPDFDoc.advanceGetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceGetRef;
/**
 * @brief advanced function to reload document objects.
 * this method require premium license.
 * all pages object return from RDPDFDoc.Page() shall not available, after this method invoked.
 */
-(void)advanceReload;
/**
 * @brief advanced function to create a stream using zflate compression(zlib).
 * stream byte contents can't modified, once created.
 * the byte contents shall auto compress and encrypt by native library.
 * this method require premium license, and need RDPDFDoc.setCache() invoked.
 * @param source source data
 * @param len source length
 * @return PDF cross reference to new object, using advanceGetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewFlateStream:(const unsigned char *)source :(int)len;
/**
 * @brief advanced function to create a stream using raw data.
 * if u pass compressed data to this method, u shall modify dictionary of this stream.
 * like "Filter" and other item from dictionary.
 * the byte contents shall auto encrypt by native library, if document if encrypted.
 * this method require premium license, and need RDPDFDoc.setCache() invoked.
 * @param source source data
 * @param len source length
 * @return PDF cross reference to new object, using advanceGetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewRawStream:(const unsigned char *)source :(int)len;
/**
 * @brief advanced function to create an empty indirect object to edit.
 * this method require premium license.
 * @return PDF cross reference to new object, using advanceGetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewIndirectObj;
/**
 * @brief advanced function to create an indirect object, and then copy source object to this indirect object.
 * this method require premium license.
 * @param obj source object to be copied.
 * @return PDF cross reference to new object, using advanceGetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewIndirectObjAndCopy :(RDPDFObj *)obj;
/**
 * @brief advanced function to get object from Document to edit.
 * this method require premium license.
 * @param ref PDF cross reference ID, which got from:
 * RDPDFDoc.advanceNewIndirectObj()
 * RDPDFDoc.advanceNewFlateStream()
 * RDPDFDoc.advanceNewRawStream()
 * @return PDF Object or null.
 */
-(RDPDFObj *)advanceGetObj:(PDF_OBJ_REF)ref;

/**
 * @brief set cache file to PDF.
 * a professional or premium license is required for this method.
 * @param path a path to save some temporary data, compressed images and so on
 * @return true or false
 */
-(bool)setCache:(NSString *)path;
/**
 * @brief set page rotate.
 * a premium license is required for this method.
 * @param pageno 0 based page NO.
 * @param degree rotate angle in degree, must be 90 * n.
 * @return true or false
 */
-(bool)setPageRotate: (int)pageno : (int)degree;
/**
 * @brief run javascript, NOTICE:considering some complex js, this method is not thread-safe.
 * this method require premium license, it always return false if using other license type.
 * @param js javascript string, can't be null.
 * @param del delegate for javascript running, can't be null.
 * @return if js or del is null, or no premium license actived, return false.
 * if success running, return true.
 * otherwise, an exception shall throw to java.
 */
-(bool)runJS:(NSString *)js :(id<PDFJSDelegate>)del;
/**
 * @brief verify the signature
 * a premium license is required for this method.
 * @param sign signature object from getSign()
 * @return 0 if verify OK, others are error.
 */
-(int)verifySign:(RDPDFSign *)sign;
/**
 * @brief check if document can be modified or saved.
 * this always return false, if no license actived.
 * @return true or false.
 */
-(bool)canSave;
/**
 * @brief is document encrypted?
 * @return true or false.
 */
-(bool)isEncrypted;
/**
 * @brief get embed files count, for document level.
 * this method require premium license, it always return 0 if using other license type.
 * @return embed files count
 */
-(int)getEmbedFileCount;
/**
 * @brief get name of embed file.
 * @param idx range in [0, RDPDFDoc.getEmbedFileCount()]
 * @return name of embed file
 */
-(NSString *)getEmbedFileName:(int)idx;
/**
 * @brief get Description of embed file.
 * @param idx range in [0, RDPDFDoc.getEmbedFileCount()]
 * @return Description of embed file
 */
-(NSString *)getEmbedFileDesc:(int)idx;
/**
 * @brief get embed file data, and save to save_path
 * @param idx range in [0, RDPDFDoc.getEmbedFileCount()]
 * @param path absolute path to save embed file.
 * @return true or false.
 */
-(bool)getEmbedFileData:(int)idx :(NSString *)path;
/**
 * @brief get java script count, for document level.
 * this method require premium license, it always return 0 if using other license type.
 * @return count
 */ 
-(int)getJSCount;
/**
 * @brief get name of javascript.
 * @param idx range in [0, RDPDFDoc.getJSCount()]
 * @return name of javascript
 */
-(NSString *)getJSName:(int)idx;
/**
 * @brief get javascript.
 * @param idx range in [0, RDPDFDoc.getJSCount()]
 * @return javascript string
 */
-(NSString *)getJS:(int)idx;
/**
 * @brief export form data as xml string.
 * this method require premium license.
 * @return xml string or null.
 */
-(NSString *)exportForm;
/**
 * @brief get XMP string from document.
 * @return null or XML string.
 */
-(NSString *)getXMP;
/**
 * @brief set XMP string from document.
 * this method require premium license.
 * @param xmp xmp string to set.
 * @return true or false.
 */
- (bool)setXMP:(NSString *)xmp;
/**
 * @brief save the document.
 * this always return false, if no license actived or standard license actived.
 * @return true or false
 */
-(bool)save;
/**
 * @brief save as the document to another file. it remove any security information.
 * this always return false, if no license actived or standard license actived.
 * @param dst path to save.
 * @param rem_sec to remove security handler.
 * @return true or false.
 */
-(bool)saveAs:(NSString *)dst :(bool)rem_sec;
/**
*	@brief	encrypt PDF file as another file. this function require premium license.
*
*	@param 	dst 	full path to save.
*	@param  upswd	user password.
*	@param  opswd	owner password.
*	@param  perm	permission to set, see PDF reference or Document_getPermission().
*	@param  method	reserved.
*	@param	fid		file ID to be set. must be 32 bytes long.
*	@return	true or false.
*/
-(bool)encryptAs:(NSString *)dst : (NSString *)upswd : (NSString *)opswd : (int)perm : (int)method : (unsigned char *)fid;
/**
 * @brief get meta data for document.
 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate".
 * or you can pass any key that self-defined.
 * @return Meta string value, or null.
 */
-(NSString *)meta:(NSString *)tag;
/**
 * @brief set meta data for document.
 * this method valid only in premium version.
 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate".
 * or you can pass any key that self-defined.
 * @param val string value.
 * @return true or false.
 */
-(bool)setMeta:(NSString *)tag :(NSString *)val;
/**
* @brief get ID of PDF file.
* @param buf receive 32 bytes as PDF ID, must be 32 bytes long.
* @return true or false.
*/
-(bool)PDFID:(unsigned char *)buf;
/**
 * @brief get pages count.
 * @return pages count.
 */
-(int)pageCount;
/**
 * @brief get max width and max height of all pages.
 * @return 2 elements container width and height values, or null if failed.
 */
-(PDF_SIZE)getPagesMaxSize;
/**
 * @brief get a Page object for page NO.
 * @param pageno 0 based page NO. range:[0, RDPDFDoc.pageCount()-1]
 * @return Page object
 */
-(RDPDFPage *)page:(int) pageno;
/**
 * @brief get page width by page NO.
 * @param pageno 0 based page NO. range:[0, RDPDFDoc.pageCount()-1]
 * @return width value.
 */
-(float)pageWidth:(int) pageno;
/**
 * @brief get page height by page NO.
 * @param pageno 0 based page NO. range:[0, RDPDFDoc.pageCount()-1]
 * @return height value.
 */
-(float)pageHeight:(int) pageno;
/**
 *  @brief get label of page
 *  @param pageno 0 based page index number
 *  @return json string or pure text. for json: name is style name of number.
 *  for example:
 *  {"D":2} is "2"
 *  {"R":3} is "III"
 *  {"r":4} is "iv"
 *  {"A":5} is "E"
 *  {"a":6} is "f"
 *  for pure text: the text is the label.
 */
-(NSString *)pageLabel:(int)pageno;
/**
 * @brief get first root outline item.
 * @return handle value of first root outline item. or null if no outlines.
 */
-(RDPDFOutline *)rootOutline;
/**
 * @brief  new a root outline to document, it insert first root outline to Document.
 * the old first root outline, shall be next of this outline.
 * @param label label to display
 * @param pageno pageno to jump
 * @param top y position in PDF coordinate
 * @return true or false
 */
-(bool)newRootOutline: (NSString *)label :(int) pageno :(float) top;
/**
 * @brief create a font object, used to write texts.
 * a premium license is required for this method.
 * @param name
 *		font name exists in font list.
 *		using Global.getFaceCount(), Global.getFaceName() to enumerate fonts.
 * @param style
 *   (style&1) means bold
 *   (style&2) means Italic
 *   (style&8) means embed
 *   (style&16) means vertical writing, mostly used in Asia fonts.
 * @return DocFont object or null is failed.
 */
-(RDPDFDocFont *)newFontCID: (NSString *)name :(int) style;
/**
 * @brief create a ExtGraphicState object, used to set alpha values.
 * a premium license is required for this method.
 * @return DocGState object or null.
 */
-(RDPDFDocGState *)newGState;
/**
 * @brief new a form from Document level.
 * this method require RDPDFDoc.setCache invoked.
 * @return DocForm object or null.
 */
-(RDPDFDocForm *)newForm;
/**
 * @brief insert a page to Document
 * if pageno >= page_count, it do same as append.
 * otherwise, insert to pageno.
 * a premium license is required for this method.
 * @param pageno 0 based page NO.
 * @param w page width in PDF coordinate
 * @param h page height in PDF coordinate
 * @return Page object or null means failed.
 */
-(RDPDFPage *)newPage:(int) pageno :(float) w :(float) h;
/**
 * @brief Start import operations, import page from src
 * a premium license is required for this method.
 * you shall maintenance the source Document object until all pages are imported and ImportContext.Destroy() invoked. 
 * @param src_doc source Document object that opened.
 * @return a context object used in ImportPage. 
 */
-(RDPDFImportCtx *)newImportCtx:(RDPDFDoc *)src_doc;
/**
 * @brief move the page to other position.
 * a premium license is required for this method.
 * @param pageno1 page NO, move from
 * @param pageno2 page NO, move to
 * @return true or false
 */
-(bool)movePage:(int)pageno1 :(int)pageno2;
/**
 * @brief remove page by page NO.
 * a premium license is required for this method.
 * @param pageno 0 based page NO.
 * @return true or false
 */
-(bool)removePage:(int)pageno;
/**
 * @brief create an image from CGImageRef Bitmap object.
 * @param img CGImageRef Bitmap object
 * @param has_alpha generate alpha channel information?
 * @return RDPDFDocImage object or null.
 */
-(RDPDFDocImage *)newImage:(CGImageRef)img : (bool)has_alpha;
/**
 * @brief create an image from CGImageRef Bitmap object.
 * this method will generate an image with alpha channel.
 * @param img CGImageRef Bitmap object
 * @param matte matte value.
 * @return RDPDFDocImage object or null.
 */
-(RDPDFDocImage *)newImage2:(CGImageRef)img : (unsigned int)matte;
/**
 * @brief create an image from JPEG/JPG file.
 * supported image color space:
 * --GRAY
 * --RGB
 * --CMYK
 * a professional or premium license is required for this method.
 * @param path path to JPEG file.
 * @return DocImage object or null.
 */
-(RDPDFDocImage *)newImageJPEG:(NSString *)path;
/**
 * @brief create an image from JPX/JPEG 2k file.
 * a professional or premium license is required for this method.
 * @param path path to JPX file.
 * @return DocImage object or null.
 */
-(RDPDFDocImage *)newImageJPX:(NSString *)path;
@end
