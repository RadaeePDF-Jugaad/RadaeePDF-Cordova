//
//  RDRDPDFDoc.h
//  PDFViewer
//
//  Created by Radaee on 12-9-18.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFIOS.h"
//#import "RDVGlobal.h"
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
/**
 *  @brief  Init signature object.
 *
 *  @return Signature object.
 */
-(id)init:(PDF_SIGN)sign;
/**
 *  @brief  Get signature's issue.
 *
 *  @return Signature's issue string value.
 */
-(NSString *)issue;
/**
 *  @brief  Get signature's subject.
 *
 *  @return Signature's subject string value.
 */
-(NSString *)subject;
/**
 *  @brief  Get signature's version.
 *
 *  @return Signature's version.
 */
-(long)version;
/**
 *  @brief  Get signer's name.
 *
 *  @return Signer's name.
 */
-(NSString *)name;
/**
 *  @brief  Get signer's reason.
 *
 *  @return Signer's reason string value.
 */
-(NSString *)reason;
/**
 *  @brief  Get signer's location.
 *
 *  @return Signer's location string value.
 */
-(NSString *)location;
/**
 *  @brief  Get signer's contact.
 *
 *  @return Signer's contact string value.
 */
-(NSString *)contact;
/**
 *  @brief  Get signature's date time.
 *
 *  @return Signature's date time string value.
 */
-(NSString *)modTime;
@end

@interface RDPDFDIB : NSObject
{
    PDF_DIB m_dib;
}
@property (readonly) PDF_DIB handle;
/**
 *	@brief	Create a DIB object.
 *
 *	@param 	width 	Width in pixels.
 *	@param 	height 	Height in pixels.
 *
 *  @return DIB object.
 */
-(id)init:(int)width :(int)height;
/**
 *	@brief	Resize a DIB object.
 *
 *	@param 	newWidth 	Width in pixels.
 *	@param 	newHeight 	Height in pixels.
 */
-(void)resize:(int)newWidth :(int)newHeight;
/**
 *	@brief	Get pixels data.
 */
-(void *)data;
/**
 *	@brief	Get width.
 *
 *	@return Width in pixels.
 */
-(int)width;
/**
 *	@brief	Get height.
 *
 *	@return Height in pixels.
 */
-(int)height;
/**
 *  @brief  Set erase color.
 *
 *  @param  color   Color hex value.
 *
 */
-(void)erase:(int)color;
/**
 *  @brief  Get DIB's ImageRef object.
 *
 *  @return DIB's ImageRef object.
 */
-(CGImageRef)image;
@end

@interface RDPDFObj : NSObject
{
	PDF_OBJ m_obj;
}
@property(readonly) PDF_OBJ handle;
/**
 *  @brief  Create PDFObj's object.
 *
 *  @param obj  PDFObj's handle.
 *
 *  @return PDFObj object.
 */
-(id)init:(PDF_OBJ)obj;
/**
 *  @brief  Get PDFObj's type.
 *
 *  @return Type int value.
 */
-(int)getType;
/**
 *  @brief  Get PDFObj's int value.
 *
 *  @return PDFObj's int value.
 */
-(int)getIntVal;
/**
 *  @brief  Get PDFObj's bool value.
 *
 *  @return PDFObj's bool value.
 */
-(bool)getBoolVal;
/**
 *  @brief  Get PDFObj's float value.
 *
 *  @return PDFObj's float value.
 */
-(float)getRealVal;
/**
 *  @brief  Get PDFObj's object reference.
 *
 *  @return PDFObj's object reference.
 */
-(PDF_OBJ_REF)getReferenceVal;
/**
 *  @brief  Get PDFObj's name value.
 *
 *  @return PDFObj's name string value.
 */
-(NSString *)getNameVal;
/**
 *  @brief  Get PDFObj's ASCII value.
 *
 *  @return PDFObj's ASCII value.
 */
-(NSString *)getAsciiStringVal;
/**
 *  @brief  Get PDFObj's text value.
 *
 *  @return PDFObj's text string value.
 */
-(NSString *)getTextStringVal;
/**
 *  @brief  Get PDFObj's binary value.
 *
 *  @param  plen    Binary's string length.
 *
 *  @return PDFObj's hex string value.
 */
-(const unsigned char *)getHexStrngVal :(int *)plen;
/**
 *  @brief  Set PDFObj's int value.
 *
 *  @param  v   Int value.
 */
-(void)setIntVal:(int)v;
/**
 *  @brief  Set PDFObj's bool value.
 *
 *  @param  v   Bool value.
 */
-(void)setBoolVal:(bool)v;
/**
 *  @brief  Set PDFObj's float value.
 *
 *  @param  v   Float value.
 */
-(void)setRealVal:(float)v;
/**
 *  @brief  Set PDFObj's object reference value.
 *
 *  @param  v   Object reference.
 */
-(void)setReferenceVal:(PDF_OBJ_REF)v;
/**
 *  @brief  Set PDFObj's name value.
 *
 *  @param  v   Name value.
 */
-(void)setNameVal:(NSString *)v;
/**
 *  @brief  Set PDFObj's ASCII value.
 *
 *  @param  v   ASCII value.
 */
-(void)setAsciiStringVal:(NSString *)v;
/**
 *  @brief  Set PDFObj's text value.
 *
 *  @param  v   Text value.
 */
-(void)setTextStringVal:(NSString *)v;
/**
 *  @brief  Set PDFObj's binary value.
 *
 *  @param  v   Binary value.
 *  @param  len    Binary's string length.
 */
-(void)setHexStringVal:(unsigned char *)v :(int)len;
/**
 *  @brief  Set PDFObj's dictionary.
 */
-(void)setDictionary;
/**
 *  @brief  Get PDFObj dictionary's item count.
 *
 *  @return  Item count.
 */
-(int)dictGetItemCount;
/**
 *  @brief  Get PDFObj dictionary's item tag at index.
 *
 *  @param  v   Index int value.
 *
 *  @return Item's tag string value.
 */
-(NSString *)dictGetItemTag:(int)index;
/**
 *  @brief  Get PDFObj dictionary's  item at index.
 *
 *  @param  index   Index int value.
 *
 *  @return PDFObj item.
 */
-(RDPDFObj *)dictGetItemByIndex:(int)index;
/**
 *  @brief  Get PDFObj dictionary's item by tag.
 *
 *  @param  tag   Tag string value.
 *
 *  @return PDFObj item.
 */
-(RDPDFObj *)dictGetItemByTag:(NSString *)tag;
/**
 *  @brief  Set PDFObj item in dictionary by tag.
 *
 *  @param  tag   Tag string value.
 */
-(void)dictSetItem:(NSString *)tag;
/**
 *  @brief  Remove PDFObj dictionary's item by tag.
 *
 *  @param  tag   Tag string value.
 */
-(void)dictRemoveItem:(NSString *)tag;
/**
 *  @brief  Set PDFObj's array.
 */
-(void)setArray;
/**
 *  @brief  Get PDFObj array's item count.
 *
 *  @return  Item count.
 */
-(int)arrayGetItemCount;
/**
 *  @brief  Get PDFObj array's item at index.
 *
 *  @param  index   Index int value.
 *
 *  @return PDFObj item.
 */
-(RDPDFObj *)arrayGetItem:(int)index;
/**
 *  @brief  Append PDFObj item in array.
 */
-(void)arrayAppendItem;
/**
 *  @brief  Insert PDFObj item in array at index.
 *
 *  @param  index   Index int value.
 */
-(void)arrayInsertItem:(int)index;
/**
 *  @brief  Remove PDFObj item in array at index.
 *
 *  @param  index   Index int value.
 */
-(void)arrayRemoveItem:(int)index;
/**
 *  @brief  Clear PDFObj array
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
 *	@brief	Create an Outline object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	Outline handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_OUTLINE)handle;
/**
 *	@brief	Get next sibling outline.
 */
-(RDPDFOutline *)next;
/**
 *	@brief	Get first child outline.
 */
-(RDPDFOutline *)child;
/**
 *	@brief	Get destination pageno.
 *
 *	@return	0 based page number.
 */
-(int)dest;
/**
 *	@brief	Get selected outline's title.
 *
 *	@return	Title string.
 */
-(NSString *)label;
/**
 *  @brief  Get selected outline's file link.
 *
 *  @return File link string.
 */
-(NSString *)fileLink;
/**
 *  @brief  Get selected outline's url.
 *
 *  @return Url string.
 */
-(NSString *)url;
/**
 *	@brief	Remove selected outline from PDF Document.
 */
-(bool)removeFromDoc;
/**
 *  @brief  Insert outline after selected outline.
            WARNING: a premium license is required for this method.
 *
 *  @param  label   New outline's label.
 *  @param  pageno   New outline's 0 based page number.
 *  @param  label   New outline's top (y in PDF coordinates).
 *
 *  @return true or false.
 */
-(bool)addNext:(NSString *)label :(int)pageno :(float)top;
/**
 *  @brief  Insert outline as  selected outline's child.
            WARNING: a premium license is required for this method.
 *
 *  @param  label   New outline's label.
 *  @param  pageno   New outline's 0 based page number.
 *  @param  label   New outline's top (y in PDF coordinates).
 *
 *  @return true or false.
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
 *	@brief	Create an Font object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	Font handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_DOC_FONT)handle;
/**
 *  @brief  Get Font object's ascent value
 *
 *  @return Font object's ascent value based in 1 (for example: 0.88f).
 */
-(float)ascent;
/**
 *  @brief  Get Font object's descent value.
 *
 *  @return Font object's descent value based in 1 (for example: -0.12f).
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
 *	@brief	Create a Graphic State object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	Graphic State handle.
 *
 */
-(id)init:(PDF_DOC)doc :(PDF_DOC_GSTATE)handle;
/**
 *	@brief	Set stroke's alpha value.
 *
 *	@param	alpha	Alpha value in range [0, 255].
 *
 *	@return true or false.
 */
-(bool)setStrokeAlpha :(int)alpha;
/**
 *	@brief	Set fill's alpha value
 *
 *	@param	alpha       Alpha value in range [0, 255].
 *
 *	@return true or false.
 */
-(bool)setFillAlpha :(int)alpha;
/**
 *  @brief  Set stroke operation's dash.
 *
 *  @param  dash     Dash array. If null means set to solid.
 *  @param dash_cnt     Dash count.
 *  @param phase    Phase value. Mostly it is 0.
 *
 *  @return true or false.
 */
-(bool)setStrokeDash:(const float *)dash : (int)dash_cnt : (float)phase;
/**
 *  @brief  Set blend mode
 *
 *  @param  bmode   Blend mode:
                     2:Multipy
                     3:Screen
                     4:Overlay
                     5:Darken
                     6:Lighten
                     7:ColorDodge
                     8:ColorBurn
                     9:Difference
                     10:Exclusion
                     11:Hue
                     12:Saturation
                     13:Color
                     14:Luminosity
                     others:Normal
 *
 *  @return true or false.
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
 *	@brief	Create an Image object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	Image handle.
 *
 *  @return Image object.
 */
-(id)init:(PDF_DOC)doc :(PDF_DOC_IMAGE)handle;
@end


@interface RDPDFFinder : NSObject
{
	PDF_FINDER m_handle;
}
/**
 *	@brief	Create an finder object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 *	@param	handle	Finder handle.
 *
 *  @return Finder object
 */
-(id)init:(PDF_FINDER)handle;
/**
 *	@brief	Get found count.
 *
 *	@return	Found count for special key string.
 */
-(int)count;
/**
 *	@brief Get found location by index.
 *
 *	@param find_index       Index value in range [0, RDPDFFinder.count - 1].
 *
 *	@return	Index value in range [0, RDPDFPage.objsCount - 1].
 */
-(int)objsIndex:(int)find_index;
/**
 *  @brief Get found location by index.
 *
 *  @param find_index    Index value in range [0, RDPDFFinder.count - 1].
 *
 *  @return  Index value in range [0, RDPDFPage.objsCount - 1].
 */
-(int)objsEnd:(int)find_index;
@end

@interface RDPDFPath : NSObject
{
	PDF_PATH m_handle;
}
@property (readonly) PDF_PATH handle;
/**
 *	@brief	Create a path object may includes some contours.
 */
-(id)init;
/**
 *  @brief Move to operation.
 *
 *  @param x    x position in PDF coordinates.
 *  @param y    y position in PDF coordinates.
 */
-(void)moveTo:(float)x :(float)y;
/**
 *  @brief Line to operation.
 *
 *  @param x    x position in PDF coordinates.
 *  @param y    y position in PDF coordinates.
 */
-(void)lineTo:(float)x :(float)y;
/**
 *  @brief Append cubic curve line to path.
 *
 *  @param x1    x position in PDF coordinates.
 *  @param y1    y position in PDF coordinates.
 *  @param x2    x position in PDF coordinates.
 *  @param y2    y position in PDF coordinates.
 *  @param x3    x position in PDF coordinates.
 *  @param y3    y position in PDF coordinates.
 */
-(void)CurveTo:(float)x1 :(float)y1 :(float)x2 :(float)y2 :(float)x3 :(float)y3;
/**
 *  @brief Close current contour.
 */
-(void)closePath;
/**
 *  @brief Get nodes count.
 *
 *  @return Nodes count.
 */
-(int)nodesCount;
/**
 * @brief	Get each node by index
 *			Example:
 *			PDF_POINT pt;
 *			int type = [PDFPath node:index:&pt];
 *
 * @param	index	Range [0, PDFPath.nodesCount - 1]
 * @param	pt	Output value.
 *
 * @return	Node type:
 *          0: move to
 *          1: line to
 *          3: curve to, index, index + 1, index + 2 are points for this operation.
 *          4: close operation
 */
-(int)node:(int)index :(PDF_POINT *)pt;
@end

@interface RDPDFInk : NSObject
{
	PDF_INK m_handle;
}
@property (readonly) PDF_INK handle;
/**
 *	@brief	Create an ink object.
 *
 *	@param	line_width      Ink width.
 *	@param	color       Ink color in hex format: 0xAARRGGBB (AA is alpha, RR is Red, GG is Green, BB is Blue).
 *
 *  @return Ink object.
 */
-(id)init:(float)line_width :(int)color;
/**
 *  @brief  Invoked on touch down event.
 *
 *  @param  x    x position in PDF coordinates.
 *  @param  y    y position in PDF coordinates.
 */
-(void)onDown:(float)x :(float)y;
/**
 *  @brief Invoked on moving event.
 *
 *  @param x    x position in PDF coordinates.
 *  @param y    y position in PDF coordinates.
 */
-(void)onMove:(float)x :(float)y;
/**
 *  @brief Invoked on touch up event.
 *
 *  @param x    x position in PDF coordinates.
 *  @param y    y position in PDF coordinates.
 */
-(void)onUp:(float)x :(float)y;
/**
 *  @brief Get nodes count.
 *
 *  @return Nodes count.
 */
-(int)nodesCount;
/**
 * @brief	Get each node by index.
 *			Example:
 *			PDF_POINT pt;
 *			int node_type = [RDPDFInk node:index:&pt];
 *
 * @param	index	Range [0, RDPDFInk.nodesCount - 1]
 * @param	pt      Output value.
 *
 * @return	Node type:
 *          0: move to
 *          1: line to
 *          2: quad to, index, index + 1 are points for this operation.
 *          3: curve to, index, index + 1, index + 2 are points for this operation.
 *          4: close operation
 */
-(int)node:(int)index :(PDF_POINT *)pt;
@end

@interface RDPDFMatrix : NSObject
{
    PDF_MATRIX m_mat;
}
@property (readonly) PDF_MATRIX handle;
/**
 *	@brief	Create a Matrix object.
 *			Formula like:
 *			x1 = x * scalex + orgx;
 *			y1 = y * scaley + orgy;
 *
 *	@param	scalex	Scale value in x direction.
 *	@param	scaley	Scale value in y direction.
 *	@param	orgx	Orgin x.
 *	@param	orgy	Orgin y.
 *
 *  @return Matrix object.
 */
-(id)init:(float)scalex :(float)scaley :(float)orgx :(float)orgy;
/**
 *   @brief  Create a Matrix object.
 *           constructor for full values.
             Transform formula like:
             new_x = (xx * x + xy * y) + x0;
             new_y = (yx * x + yy * y) + y0;
             For composed with rotate and scale, values like:
             xx = scalex * cos(a);
             yx = scaley * sin(a);
             xy = scalex * sin(-a);
             yy = scaley * cos(-a);
             Where "a" is rotate angle in radian.
 *
 *   @param  xx    scalex * cos(a)
 *   @param  yx    scaley * sin(a)
 *   @param  xy    scalex * cos(-a)
 *   @param  yy    scaley * sin(-a)
 *   @param  x0    Offset add to x.
 *   @param  y0    Offset add to y.
 *
 *  @return Matrix object.
 */
-(id)init:(float)xx :(float)yx :(float)xy :(float)yy :(float)x0 :(float)y0;
/**
 *  @brief Invert matrix object.
 */
-(void)invert;
/**
 *  @brief Transform path.
 *  @param path Path object to be transformed.
 */
-(void)transformPath:(RDPDFPath *)path;
/**
 *  @brief Transform ink.
 *  @param ink Ink object to be transformed.
 */
-(void)transformInk:(RDPDFInk *)ink;
/**
 *  @brief Transform rect.
 *  @param rect Rect object to be transformed.
 */
-(void)transformRect:(PDF_RECT *)rect;
/**
 *  @brief Transform point.
 *  @param point Point object to be transformed.
 */
-(void)transformPoint:(PDF_POINT *)point;
@end

@interface RDPDFPageContent : NSObject
{
	PDF_PAGECONTENT m_handle;
}
@property (readonly) PDF_PAGECONTENT handle;
/**
 *  @brief Create page content object.
 *
 *  @return Page content object.
 */
-(id)init;
/**
 *  @brief Save current graphic state.
 */
-(void)gsSave;
/**
 *  @brief Restore graphic state.
 */
-(void)gsRestore;
/**
 *  @brief Set graphic state, like alpha values.
 */
-(void)gsSet:(PDF_PAGE_GSTATE) gs;
/**
 *  @brief Concat current matrix.
 *  @param mat Current matrix object.
 */
-(void)gsCatMatrix:(RDPDFMatrix *) mat;
/**
 *  @brief Text section begin.
 */
-(void)textBegin;
/**
 *  @brief Text section end.
 */
-(void)textEnd;
/**
 *  @brief Draw an image.
 *
 *  @param img  Image object.
 */
-(void)drawImage:(PDF_PAGE_IMAGE) img;
/**
 *  @brief Draw a form.
 *
 *  @param img  Form object.
 */
-(void)drawForm:(PDF_PAGE_FORM)form;
/**
 * @brief Draw text.
 *
 * @param text Text to show.
 */
-(void)drawText:(NSString *)text;
/**
 * @brief Draw text.
 *
 * @param text    Text to show.
 * @param align  Text alignment:
                0: left
                1: middle
                2: right
 * @param width  Bounding width to draw text.
 *
 * @return 1 or 0 (success or failure).
 */
-(int)drawText:(NSString*)text : (int)align : (float)width;
/**
 * @brief Draw text.
 *
 * @param text    Text to show.
 * @param align  Text alignment:
                0: left
                1: middle
                2: right
 * @param width  Bounding width to draw text.
 * @param max_lines  Max line count of this drawing.
 *
 * @return Text reference object.
 */
-(PDF_TEXT_RET)drawText:(NSString*)text : (int)align : (float)width : (int)max_lines;
/**
 * @brief Stroke the path.
 *
 * @param path  Path to stroke.
 */
-(void)strokePath:(RDPDFPath *) path;
/**
 * @brief Fill the path.
 *
 * @param path  Path to fill.
 * @param winding   Winding value (set as true if use winding rule, false if even-odd rule).
 */
-(void)fillPath:(RDPDFPath *)path :(bool) winding;
/**
 * @brief Set the path to clip.
 *
 * @param path  Path to clip.
 * @param winding   Winding value (set as true if use winding rule, false if even-odd rule).
 */
-(void)clipPath:(RDPDFPath *)path :(bool) winding;
/**
 * @brief Set fill color.
 *
 * @param color Hex color value (0xRRGGBB).
 */
-(void)setFillColor:(int) color;
/**
 * @brief Set stroke color.
 *
 * @param color Hex color value (0xRRGGBB).
 */
-(void)setStrokeColor:(int) color;
/**
 * @brief PDF operator: set line cap.
 *
 * @param cap  cap type:
 *            0: butt
 *            1: round
 *            2: square
 */
-(void)setStrokeCap:(int) cap;
/**
 * @brief PDF operator: set line join.
 * @param join  join type:
 *             0: miter
 *             1: round
 *             2: bevel
 */
-(void)setStrokeJoin:(int) join;
/**
 * @brief PDF operator: set line width.
 * @param w     Line width in PDF coordinate.
 */
-(void)setStrokeWidth:(float) w;
/**
 * @brief PDF operator: set miter limit.
 * @param miter  Miter limit.
 */
-(void)setStrokeMiter:(float) miter;
/**
 * @brief PDF operator: set char space(extra space between chars).
 * @param space  Char space.
 */
-(void)textSetCharSpace:(float) space;
/**
 * @brief PDF operator: set word space (extra space between words spit by blank char).
 * @param space  Word space.
 */
-(void)textSetWordSpace:(float) space;
/**
 * @brief PDF operator: set text leading (height between 2 text lines).
 * @param leading   Leading in PDF coordinate.
 */
-(void)textSetLeading:(float) leading;
/**
 * @brief PDF operator: set text rise.
 * @param rise  Rise value.
 */
-(void)textSetRise:(float) rise;
/**
 * @brief PDF operator: set horizon scale for chars.
 * @param scale  Scale value. 100 means scale value 1.0f.
 */
-(void)textSetHScale:(int) scale;
/**
 * @brief PDF operator: add new text line.
 */
-(void)textNextLine;
/**
 * @brief PDF operator: move text position relative to previous line.
 * @param x   x in PDF coordinate added to previous line position.
 * @param y   y in PDF coordinate added to previous line position.
 */
-(void)textMove:(float) x :(float) y;
/**
 * @brief Set text font.
 * @param font  ResFont object created by Page.AddResFont().
 * @param size  Text size in PDF coordinate.
 */
-(void)textSetFont:(PDF_PAGE_FONT) font :(float) size;
/**
 * @brief PDF operator: set text render mode.
 * @param mode  Render mode value:
 *			   0: filling
 *			   1: stroke
 *			   2: fill and stroke
 *			   3: do nothing
 *			   4: fill and set clip path
 *			   5: stroke and set clip path
 *			   6: fill/stroke/clip
 *			   7: set clip path.
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
 *	@brief	Create a Form object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 *	@param	doc	Document handle.
 *	@param	handle	GState handle.
 *
 *  @return Form object.
 */
-(id)init:(PDF_DOC)doc : (PDF_DOC_FORM)handle;
/**
 *  @brief  Add font as form's resource.
 *
 *  @param  font    Font object.
 *
 *  @return Font resource handle.
 */
-(PDF_PAGE_FONT)addResFont :(RDPDFDocFont *)font;
/**
 *  @brief  Add image as form's resource.
 *
 *  @param  img    Image object.
 *
 *  @return Image resource handle.
 */
-(PDF_PAGE_IMAGE)addResImage :(RDPDFDocImage *)img;
/**
 *  @brief  Add graphic state as form's resource.
 *
 *  @param  gs    Graphic state object.
 *
 *  @return Graphic state resource handle.
 */
-(PDF_PAGE_GSTATE)addResGState : (RDPDFDocGState *)gs;
/**
 *  @brief  Add sub-form as form's resource.
 *
 *  @param  form    Sub-form state object.
 *
 *  @return Sub-form state resource handle.
 */
-(PDF_PAGE_FORM)addResForm : (RDPDFDocForm *)form;
/**
 *  @brief  Set form's content. It needs a box defined in form.
            The box define form area's edge, which PageContent object includes.
 *
 *  @param  x    Form box's x.
 *  @param  y    Form box's y.
 *  @param  w    Form box's width.
 *  @param  h    Form box's height.
 *  @param  content    Page content object.
 *
 */
-(void)setContent : (float)x : (float)y : (float)w : (float)h : (RDPDFPageContent *)content;
/**
 *  @brief  Set this form as transparency.
 *
 *  @param  isolate    Set to isolate. Mostly it is false.
 *  @param  knockout    Set to knockout. Mostly it is false.
 *
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
 * @brief	Create an annotation object.
 *			WARNING: this method is not supplied for developers, but invoked inner.
 *
 * @param   page    Page object where annotion will be placed.
 * @param   handle      Annotation handle.
 *
 * @return Annotation object.
 */
-(id)init:(PDF_PAGE)page :(PDF_ANNOT)handle;
/**
 * @brief   Advanced function to get annotation object's reference.
            WARNING: this method require premium license.
 *
 * @return  PDF object reference.
 */
-(PDF_OBJ_REF)advanceGetRef;
/**
 * @brief   Advanced function to reload annotation object, called after advanced methods update annotation object data.
            WARNING: this method require premium license.
 */
-(void)advanceReload;
/**
 * @brief	Get annotation type.
 *			WARNING: this method is valid in professional or premium version.
 *
 * @return  Type as these values:
 *          0:  unknown
 *          1:  text
 *          2:  link
 *          3:  free text
 *          4:  line
 *          5:  square
 *          6:  circle
 *          7:  polygon
 *          8:  polyline
 *          9:  text hilight
 *          10: text under line
 *          11: text squiggly
 *          12: text strikeout
 *          13: stamp
 *          14: caret
 *          15: ink
 *          16: popup
 *          17: file attachment
 *          18: sound
 *          19: movie
 *          20: widget
 *          21: screen
 *          22: print mark
 *          23: trap net
 *          24: water mark
 *          25: 3d object
 *          26: rich media.
 *
 *  @return Annoratation type int value.
 */
-(int)type;
/**
 *  @brief  Export selected annotation object.
 *  @param  buf     Buffer char value.
 *  @param  len     Byte char's length value.
 */
-(int)export :(unsigned char *)buf : (int)len;
/**
 *  @brief  Add sign to signature filed annotation.
 *  @param  appearence  Sign field's appearence.
 *  @param  cert_file   Signature certification file's path.
 *  @param  pswd    Certification file's password.
 *  @param  name    Signer's name.
 *  @param  reason    Signer's reason.
 *  @param  location    Signer's location.
 *  @param  contact     Signer's contact.
 *
 *  @return 1 or 0 (success or failure).
 */
-(int)signField :(RDPDFDocForm *)appearence :(NSString *)cert_file :(NSString *)pswd :(NSString*)name :(NSString *)reason :(NSString *)location :(NSString *)contact;
/**
 * @brief	Get annotation field type in acroForm.
 *			WARNING: this method is valid in premium version.
 * @return  Type value:
 *          0: unknown
 *          1: button field
 *          2: text field
 *          3: choice field
 *          4: signature field.
 */
-(int)fieldType;
/**
 * @brief   Get annotation field type in acroForm.
 *          WARNING: this method is valid in premium version.
 * @return  Flag value.
 */
-(int)fieldFlag;
/**
 *	@brief	Get selected annotation's name (example: "EditBox1[0]").
 *			WARNING: this method is valid in premium version.
 *
 *  @return Field name string.
 */
-(NSString *)fieldName;
/**
 *  @brief  Get selected annotation's name with name's index.
 *          WARNING: this method is valid in premium version.
 *
 *  @return Field name string.
 */
-(NSString *)fieldNameWithNO;
/**
 *	@brief	Get selected annotation's full name (example: "Form1.EditBox1").
 *			WARNING: this method is valid in premium version.
 *  @return Field full name string.
 */
-(NSString *)fieldFullName;
/**
 *	@brief	Get selected annotation's full name with more details (example: "Form1[0].EditBox1[0]").
 *			WARNING: this method is valid in premium version.
 *  @return Field full name string.
 */
-(NSString *)fieldFullName2;
/**
 *  @brief  Get selected annotation's javascript.
 *  @return Javascrpit string.
 */
-(NSString *)getFieldJS:(int)idx;
/**
 * @brief  Check if selected annotation's position and size are locked.
 *         WARNING: this method is valid in professional or premium version.
 * @return true if locked, false if not locked.
 */
-(bool)isLocked;
/**
 * @brief Set selected annotation's lock status.
 *        WARNING: this method is valid in professional or premium version.
 * @param lock  Lock status to be set.
 */
-(void)setLocked:(bool)lock;
/**
 * @brief Get selected annotation's name
 *
 * @return Annotation's name string.
 */
-(NSString *)getName;
/**
 * @brief Set selected annotation's name
 * @param name  Name string to be set.
 *
 * @return true or false.
 */
-(bool)setName:(NSString *)name;
/**
 * @brief  Check if selected annotation is readonly.
 *         WARNING: this method is valid in professional or premium version.
 * @return true if is readonly, false if not.
 */
-(bool)isReadonly;
/**
 * @brief Set selected annotation's readonly status.
 *        WARNING: this method is valid in professional or premium version.
 * @param readonly  Readonly status to be set.
 */
-(void)setReadonly:(bool)readonly;
/**
 * @brief Check whether the annotation is hide.
 * @return true or false.
 */
-(bool)isHidden;
/**
 * @brief set hide status for annotation.
 * WARNING: this method is valid in professional or premium version.
 * WARNING: you need render page again to show modified annotation.
 * @param hide true or false.
 */
-(bool)setHidden:(bool)hide;
/**
 * @brief Render page to dib object. This function returned for cancelled or finished.
 *        Before render, you need invoke RenderPrepare.
 * @param dib dib object to render.
 * @param back_color dib object's background in hex color.
 *
 * @return true or false.
 */
-(bool)render:(RDPDFDIB *)dib :(int)back_color;
/**
 * @brief Get annotation's box rectangle.
 *		  WARNING: this method is valid in professional or premium version.
 * @param rect Rect objcet with 4 elements: left, top, right, bottom in PDF coordinate system
 */
-(void)getRect:(PDF_RECT *)rect;
/**
 * @brief Set annotation's box rectangle.
 *        WARNING: this method is valid in professional or premium version.
 *        WARNING: you shall render page after this method invoked to resize or move annotation.
 * @param rect Rect object in PDF coordinate system
 */
-(void)setRect:(const PDF_RECT *)rect;
/**
 * @brief Get selected annotation's sign date time.
 *
 * @return Sign's date time string value.
 */
-(NSString *)getModDate;
/**
 * @brief Set selected annotation's sign date time.
 * @param mdate Sign's date time string value
 *
 * @return true or false.
 */
-(bool)setModDate:(NSString *)mdate;
/**
 * @brief Get markup annotation's rectangles.
 *        WARNING: this method is valid in professional or premium version.
 * @param rects rects in PDF coordinate system as out values.
 * @param cnt Rects allocated's count.
 * @return Rects count that markup annotation has.
*/
-(int)getMarkupRects:(PDF_RECT *)rects : (int)cnt;
/**
 * @brief Get selected annotation's index.
 *
 * @return Annotation's index.
 */
-(int)getIndex;
/**
 * @brief Get selected annotation's ink path.
 *
 * @return Annotation's ink path.
 */
-(RDPDFPath *)getInkPath;
/**
 * @brief Set selected annotation's ink path.
 * @param path Annotation's ink path.
 * @return true or false.
 */
-(bool)setInkPath:(RDPDFPath *)path;
/**
 * @brief Get selected annotation's polygon path.
 *
 * @return Annotation's polygon path.
 */
-(RDPDFPath *)getPolygonPath;
/**
 * @brief Set selected annotation's polygon path.
 * @param path Annotation's polygon path.
 * @return true or false.
 */
-(bool)setPolygonPath:(RDPDFPath *)path;
/**
 * @brief Get selected annotation's polyline path.
 *
 * @return Annotation's polyline path.
 */
-(RDPDFPath *)getPolylinePath;
/**
 * @brief Set selected annotation's polyline path.
 * @param path Annotation's polyline path.
 * @return true or false.
 */
-(bool)setPolylinePath:(RDPDFPath *)path;
/**
 * @brief Get selected annotation's line style.
 *
 * @return Annotation's line style.
 */
-(int)getLineStyle;
/**
 * @brief Set selected annotation's line style.
 * @param path Annotation's line style.
 * @return true or false.
 */
-(bool)setLineStyle:(int)style;
/**
 * @brief Get annotation's fill color.
 * WARNING: this method is valid for square/circle/highlight/line/ploygon/polyline/sticky text/free text annotation.
 * WARNING: this method is valid in professional or premium version.
 * @return color value formatted as 0xAARRGGBB, if 0 returned, means false.
 */
-(int)getFillColor;
/**
 * @brief Set annotation's fill color.
 * WARNING: this method is valid for square/circle/highlight/line/ploygon/polyline/sticky text/free text annotation.
 * WARNING: you need render page again to show modified annotation.
 * WARNING: this method is valid in professional or premium version.
 * @param color Color value formatted as 0xAARRGGBB. If alpha channel is too less or 0 return false.
 * @return true or false.
 */
-(bool)setFillColor:(int)color;
/**
 * @brief Get annotation's stroke color.
 * WARNING: this method is valid for square/circle/ink/line/underline/Squiggly/strikeout/ploygon/polyline/free text annotation.
 * WARNING: this method is valid in professional or premium version.
 * @return color value formatted as 0xAARRGGBB, if 0 returned, means false.
 */
-(int)getStrokeColor;
/**
 * @brief Set annotation's stroke color.
 * WARNING: this method is valid for square/circle/ink/line/underline/Squiggly/strikeout/ploygon/polyline/free text annotation.
 * WARNING: you need render page again to show modified annotation.
 * WARNING: this method is valid in professional or premium version.
 * @param color Color value formatted as 0xAARRGGBB. If alpha channel is too less or 0 return false.
 * @return true or false.
 */
-(bool)setStrokeColor:(int)color;
/**
 * @brief Get annotation's stroke width (for free text annotation: width of edit-box border).
 * WARNING: this method is valid for square/circle/ink/line/ploygon/polyline/free text annotation.
 * WARNING: this method is valid in professional or premium version.
 * @return Width value in PDF coordinate. On error it returns 0.
 */
-(float)getStrokeWidth;
/**
 * @brief Set annotation's stroke width (for free text annotation: width of edit-box border).
 * WARNING: this method is valid for square/circle/ink/line/ploygon/polyline/free text annotation.
 * WARNING: you need render page again to show modified annotation.
 * WARNING: this method is valid in professional or premium version.
 * @param width Stroke width in PDF coordinate.
 * @return true or false.
 */
-(bool)setStrokeWidth:(float)width;
/**
 * @brief Get dash for stroke operation.
 * @param dashs Dashes value.
 * @param dashs_max Max dashes value.
 *
 * @return Stroke dash value.
 */
-(int)getStrokeDash:(float*)dashs : (int)dashs_max;
/**
 * @brief Set dash for stroke operation.
 * @param dash Dash value.
 * @param cnt Dashes' count.
 *
 * @return true or false.
 */
-(bool)setStrokeDash:(float *)dash : (int)cnt;
/**
 * @brief Get annotation's icon value.
 * WARNING: this method is valid for sticky text note/file attachment annotation.
 * WARNING: this method is valid in professional or premium version.
 * @return Icon value depends on annotation type.
 *         For sticky text note:
 *         0: Note
 *         1: Comment
 *         2: Key
 *         3: Help
 *         4: NewParagraph
 *         5: Paragraph
 *         6: Insert
 *         7: Check
 *         8: Circle
 *         9: Cross
 *
 *         For file attachment:
 *         0: PushPin
 *         1: Graph
 *         2: Paperclip
 *         3: Tag
 *
 *         For Rubber Stamp:
 *         0: "Draft"(default icon)
 *         1: "Approved"
 *         2: "Experimental"
 *         3: "NotApproved"
 *         4: "AsIs"
 *         5: "Expired"
 *         6: "NotForPublicRelease"
 *         7: "Confidential"
 *         8: "Final"
 *         9: "Sold"
 *        10: "Departmental"
 *        11: "ForComment"
 *        12: "TopSecret"
 *        13: "ForPublicRelease"
 *        14: "Accepted"
 *        15: "Rejected"
 *        16: "Witness"
 *        17: "InitialHere"
 *        18: "SignHere"
 *        19: "Void"
 *        20: "Completed"
 *        21: "PreliminaryResults"
 *        22: "InformationOnly"
 *        23: "End"
 */
-(int)getIcon;
/**
 * @brief Set annotation's icon value.
 * WARNING: this method is valid for sticky text note/file attachment annotation.
 * WARNING: this method is valid in professional or premium version.
 * @param icon Icon value depends on annotation type.
 *         For sticky text note:
 *         0: Note
 *         1: Comment
 *         2: Key
 *         3: Help
 *         4: NewParagraph
 *         5: Paragraph
 *         6: Insert
 *         7: Check
 *         8: Circle
 *         9: Cross
 *
 *         For file attachment:
 *         0: PushPin
 *         1: Graph
 *         2: Paperclip
 *         3: Tag
 *
 *         For Rubber Stamp:
 *         0: "Draft"(default icon)
 *         1: "Approved"
 *         2: "Experimental"
 *         3: "NotApproved"
 *         4: "AsIs"
 *         5: "Expired"
 *         6: "NotForPublicRelease"
 *         7: "Confidential"
 *         8: "Final"
 *         9: "Sold"
 *        10: "Departmental"
 *        11: "ForComment"
 *        12: "TopSecret"
 *        13: "ForPublicRelease"
 *        14: "Accepted"
 *        15: "Rejected"
 *        16: "Witness"
 *        17: "InitialHere"
 *        18: "SignHere"
 *        19: "Void"
 *        20: "Completed"
 *        21: "PreliminaryResults"
 *        22: "InformationOnly"
 *        23: "End"
 *  @return true or false.
 */
-(bool)setIcon:(int)icon;
/**
 * @brief Set annotation's icon value.
 * WARNING: this method is valid for sticky text note/file attachment annotation.
 * WARNING: this method is valid in professional or premium version.
 * @param icon_name Icon name string value.
 * @param icon Doc form icon object.
 * 
 *  @return true or false.
 */
-(bool)setIcon2:(NSString *)icon_name :(RDPDFDocForm *)icon;
/**
 * @brief Get annotation's destination.
 * WARNING: this method is valid in professional or premium version.
 * @return 0 based page number. If failed returns -1.
 */
-(int)getDest;
/**
 * @brief Get annotation's URL link string.
 * WARNING: this method is valid in professional or premium version.
 * @return URL string value.
 */
-(NSString *)getURI;
/**
 * @brief Get annotation's javascript string.
 * WARNING: this method is valid in professional or premium version.
 * @return Jacavscript string value.
 */
-(NSString *)getJS;
/**
 * @brief Get annotation's additional javascript string.
 * WARNING: this method is valid in professional or premium version.
 * @param idx Javascript index (range in [0-GetJSCount()])
 * @return Jacavscript string value.
 */
-(NSString *)getAdditionalJS :(int)idx;
/**
 * @brief Get annotation's 3D object name.
 * WARNING: this method is valid in professional or premium version.
 * @return 3D object's name.
 */
-(NSString *)get3D;
/**
 * @brief Get annotation's movie name.
 * WARNING: this method is valid in professional or premium version.
 * @return Movie's name.
 */
-(NSString *)getMovie;
/**
 * @brief Get annotation's sound name.
 * WARNING: this method is valid in professional or premium version.
 * @return Audio's name.
 */
-(NSString *)getSound;
/**
 * @brief Get annotation's attachment name.
 * WARNING: this method is valid in professional or premium version.
 * @return Attachment name.
 */
-(NSString *)getAttachment;
/**
 * @brief Get annotation's 3D data.
 * WARNING: it must be *.u3d format.
 * WARNING: this method is valid in professional or premium version.
 * @param save_file full path name to save data.
 * @return true if save_file created, false on failure.
 */
-(bool)get3DData:(NSString *)save_file;
/**
 * @brief Get annotation's movie data.
 * WARNING: this method is valid in professional or premium version.
 * @param save_file full path name to save data.
 * @return true if save_file created, false on failure.
 */
-(bool)getMovieData:(NSString *)save_file;
/**
 * @brief Get annotation's sound data.
 * WARNING: this method is valid in professional or premium version.
 * @param paras paras[0] == 0, if formated audio file(*.mp3 ...).
 * @param save_file full path name to save data.
 * @return true if save_file created, false on failure.
 */
-(bool)getSoundData:(int *)paras :(NSString *)save_file;
/**
 * @brief Get annotation's attachment data.
 * WARNING: this method is valid in professional or premium version.
 * @param save_file full path name to save data.
 * @return true if save_file created, false on failure.
 */
-(bool)getAttachmentData:(NSString *)save_file;
/**
 * @brief Get annotation's rich media item count.
 * 
 * @return Rich media item count.
 */
-(int)getRichMediaItemCount;
/**
 * @brief Get annotation's rich media item activated.
 * 
 * @return Rich media item activated value.
 */
-(int)getRichMediaItemActived;
/**
 * @brief Get annotation's rich media item activated type.
 * @param idx Rich media item index in range [0-richMediaItemCount].
 * 
 * @return Rich media item activated type.
 */
-(int)getRichMediaItemType:(int) idx;
/**
 * @brief Get annotation's rich media item asset.
 * @param idx Rich media item index in range [0-richMediaItemCount].
 * 
 * @return Rich media item asset string value.
 */
-(NSString *)getRichMediaItemAsset:(int) idx;
/**
 * @brief Get annotation's rich media item param.
 * @param idx Rich media item index in range [0-richMediaItemCount].
 * 
 * @return Rich media item param string value.
 */
-(NSString *)getRichMediaItemPara:(int) idx;
/**
 * @brief Get annotation's rich media item source.
 * @param idx Rich media item index in range [0-richMediaItemCount].
 * 
 * @return Rich media item source string value.
 */
-(NSString *)getRichMediaItemSource:(int) idx;
/**
 * @brief Get annotation's rich media item source data.
 * @param idx Rich media item index in range [0-richMediaItemCount].
 * @param save_file full path name to save data.
 * 
 * @return true if save_file created, false on failure.
 */
-(bool)getRichMediaItemSourceData:(int) idx :(NSString *)save_path;
/**
 * @brief Get annotation's rich media item source data.
 * @param asset Rich media asset string value.
 * @param save_file full path name to save data.
 * 
 * @return true if save_file created, false on failure.
 */
-(bool)getRichMediaData :(NSString *)asset :(NSString *)save_path;
/**
 * @brief Get annotation's file link.
 * 
 * @return File link string value.
 */
-(NSString*)getFileLink;
/**
 * @brief Get annotation's popup.
 * 
 * @return Popup object.
 */
-(RDPDFAnnot *)getPopup;
/**
 * @brief Get annotation's popup open status.
 * 
 * @return true (open) or false (closed).
 */
-(bool)getPopupOpen;
/**
 * @brief Get annotation's popup subject.
 * WARNING: this method is valid in professional or premium version.
 * @return Subject string.
 */
-(NSString *)getPopupSubject;
/**
 * @brief Get annotation's popup text.
 * WARNING: this method is valid in professional or premium version.
 * @return Text string
 */
-(NSString *)getPopupText;
/**
 * @brief Get annotation's popup label text.
 * WARNING: this method is valid in professional or premium version.
 * @return Label text string.
 */
-(NSString *)getPopupLabel;
/**
 * @brief Set annotation's popup open status.
 * WARNING: this method is valid in professional or premium version.
 * @param open Open status.
 * 
 * @return true or false.
 */
-(bool)setPopupOpen :(bool)open;
/**
 * @brief Set annotation's popup subject.
 * WARNING: this method is valid in professional or premium version.
 * @param val Subject string.
 * 
 * @return true or false.
 */
-(bool)setPopupSubject:(NSString *)val;
/**
 * @brief Set annotation's popup text.
 * WARNING: this method is valid in professional or premium version.
 * @param val Text string.
 * 
 * @return true or false.
 */
-(bool)setPopupText:(NSString *)val;
/**
 * @brief Set annotation's popup label text.
 * WARNING: this method is valid in professional or premium version.
 * @param val Text string.
 * 
 * @return true or false.
 */
-(bool)setPopupLabel:(NSString *)val;
/**
 * @brief Get edit-box type.
 * WARNING: this method is valid in premium version.
 * 
 * @return -1: this annotation is not text-box.
 *          1: normal single line.
 *          2: password.
 *          3: MultiLine edit area.
 */
-(int)getEditType;
/**
 * @brief get position and size of edit-box.
 * WARNING: for FreeText annotation, position of edit-box is not the position of annotation, so this function is needed for edit-box.
 * WARNING: this method is valid in premium version.
 * @param rect 4 elements in order: left, top, right, bottom, in PDF coordinate.
 * 
 * @return true or false.
 */
-(bool)getEditRect:(PDF_RECT *)rect;
/**
 * @brief Get text size of edit-box.
 * WARNING: this method is valid in premium version.
 * 
 * @return Text size in PDF coordinate system.
 */
-(float)getEditTextSize;
/**
 * @brief Set text size of edit-box.
 * WARNING: this method is valid in premium version.
 * @param fsize Text size to be set.
 * 
 * @return Text size in PDF coordinate system.
 */
-(bool)setEditTextSize:(float)fsize;
/**
 * @brief Get text align of edit-box.
 * WARNING: this method is valid in premium version.
 * 
 * @return Text align. 
 *         0:left
 *         1:center
 *         2:right.
 */
-(int)getEditTextAlign;
/**
 * @brief Set edit-box's text align.
 * WARNING: this method is valid in premium version.
 * @param align Text align. 
 *         0:left
 *         1:center
 *         2:right.
 * @return true or false.
 */
-(bool)setEditTextAlign:(int)align;
/**
 * @brief Get edit-box's content.
 * WARNING: this method is valid in premium version.
 * @return Edit-box's content.
 */
-(NSString *)getEditText;
/**
 * @brief Set edit-box's content.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in premium version.
 * @param val Contents to be set. 
 *            - In MultiLine mode: '\r' or '\n' means change line. 
 *            - In password mode the edit box always display "*".
 * @return true or false.
 */
-(bool)setEditText:(NSString *)val;
/**
 * @brief Set edit-box's font.
 * WARNING: this method is valid in premium version.
 * @param font Selected font object.
 * 
 * @return true or false.
 */
-(bool)setEditFont:(RDPDFDocFont *)font;
/**
 * @brief Get edit-box's color.
 * WARNING: this method is valid in premium version.
 * @return Edit-box's color hex int value.
 */
-(int)getEditTextColor;
/**
 * @brief Get edit-box's color.
 * WARNING: this method is valid in premium version.
 * @param color Color to be set in hex int value.
 * 
 * @return true or false.
 */
-(bool)setEditTextColor:(int)color;
/**
 * @brief Get combo-box's item count.
 * WARNING: this method is valid in premium version.
 * @return Items count. If this is not combo-box returns -1.
 */
-(int)getComboItemCount;
/**
 * @brief Get combo-box's specific item.
 * WARNING: this method is valid in premium version.
 * @param index 0 based item index. range:[0, getComboItemCount()-1].
 * 
 * @return Selected item. It returns null if this is not combo-box, "" if no item selected.
 */
-(NSString *)getComboItem :(int)index;
/**
 * @brief Get combo-box's specific item value.
 * WARNING: this method is valid in premium version.
 * @param index 0 based item index. range:[0, getComboItemCount()-1].
 * 
 * @return Selected item value.
 */
-(NSString *)getComboItemVal :(int)index;
/**
 * @brief Get combo-box's current selected index.
 * WARNING: this method is valid in premium version.
 * @return Selected index. It returns -1 if this is not combo-box or no item selected.
 */
-(int)getComboSel;
/**
 * @brief Set current selected.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in premium version.
 * @param index 0 based item index to be set.
 * 
 * @return true or false.
 */
-(bool)setComboSel:(int)index;
/**
 * @brief Check if selected combo-box is multisel enabled.
 * WARNING: this method is valid in premium version.
 * @return true or false.
 */
-(bool)isMultiSel;
/**
 * @brief get item count of list-box.
 * WARNING: this method is valid in premium version.
 * @return -1: this is not a list. otherwise: items count.
 */
-(int)getListItemCount;
/**
 * @brief Get list-box's selected item.
 * WARNING: this method is valid in premium version.
 * @param index 0 based item index. range:[0, getListItemCount()-1].
 * 
 * @return Selected item. It returns null if this is not list-box, "" if no item selected.
 */
-(NSString *)getListItem:(int)index;
/**
 * @brief Get list-box's selected item value.
 * WARNING: this method is valid in premium version.
 * @param index 0 based item index. range:[0, getListItemCount()-1].
 * 
 * @return Selected item value.
 */
-(NSString *)getListItemVal:(int)index;
/**
 * @brief Get list-box's selected indexes.
 * WARNING: this method is valid in premium version.
 * @param sels 0 based items' indexes.
 * @param sels_max Items' max value.
 * 
 * @return Selected items count. It returns -1 if it is not a list-box or returns 0 if no items selected.
 */
-(int)getListSels:(int *)sels :(int)sels_max;
/**
 * @brief Set list-box's selected items.
 * WARNING: this method is valid in premium version.
 * @param sels 0 based items' indexes.
 * @param sels_max List-box's items count.
 * 
 * @return true or false.
 */
-(bool)setListSels:(const int *)sels :(int)sels_cnt;
/**
 * @brief Get check-box's and radio-box's status.
 * WARNING: this method is valid in premium version.
 * @param sels 0 based items' indexes.
 * @param sels_max List-box's items count.
 * 
 * @return  Status int value:
 *          -1 if annotation is not valid control.
 *          0 if check-box is unchecked.
 *          1 if check-box checked.
 *          2 if radio-box is unchecked.
 *          3 if radio-box checked.
 */
-(int)getCheckStatus;
/**
 * @brief Set value to check-box.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in premium version.
 * @param check Boolean check value.
 * 
 * @return true or false.
 */
-(bool)setCheckValue:(bool)check;
/**
 * @brief Check the radio-box and deselect others in radio group.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in premium version.
 * @return true or false.
 */
-(bool)setRadio;
/**
 * @brief Check if the annotation is reset button.
 * WARNING: this method is valid in premium version.
 * @return true or false.
 */
-(bool)getReset;
/**
 * @brief Perform the button and reset the form.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in premium version.
 * @return true or false.
 */
-(bool)setReset;
/**
 * @brief get annotation submit target.
 * WARNING: this method is valid in premium version.
 * @return null if this is not submit button.
 */
-(NSString *)getSubmitTarget;
/**
 * @brief Get annotation submit parameters.
 *        - Mail mode: return whole XML string for form data.
 *        - Other mode: url data likes: "para1=xxx&para2=xxx".
 * WARNING: this method is valid in premium version.
 * @return Submit paramerers. It returns null if this is not submit button.
 */
-(NSString *)getSubmitPara;
/**
 * @brief Remove annotation.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in professional or premium version.
 * @return true or false.
 */
-(bool)removeFromPage;
/**
 * @brief Flate annotation in page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this method is valid in professional or premium version.
 * @return true or false.
 */
-(bool)flateFromPage;
/**
 * @brief Get sign annotation's status.
 * WARNING: this method is valid in professional or premium version.
 * @return Status int value.
 */
-(int)getSignStatus;
/**
 * @brief Get annotation's signature.
 * WARNING: this method is valid in professional or premium version.
 * @return Signature object.
 */
-(RDPDFSign *)getSign;
/**
 * @brief Move annotation from page to other.
 * WARNING: this method is valid in professional or premium version.
 * @param page Page number where move selected annotation.
 * @param rect New annotation's rect in pdf coordinates.
 * 
 * @return true or false.
 */
-(bool)MoveToPage:(RDPDFPage *)page :(const PDF_RECT *)rect;
/**
 * @brief Check if annot can be moved.
 * @return true or false.
 */
- (BOOL)canMoveAnnot;
/**
 * @brief Check if annot is locked.
 * @return true or false.
 */
- (BOOL)isAnnotLocked;
/**
 * @brief Check if annot is readonly.
 * @return true or false.
 */
- (BOOL)isAnnotReadOnly;
/**
 * @brief Get annotation's object reference.
 * @return Annotation's object reference.
 */
-(PDF_OBJ_REF)getRef;

@end

@interface RDPDFPage : NSObject
{
    PDF_PAGE m_page;
}
@property (readonly) PDF_PAGE handle;
/**
 * @brief create RDPDFPage object.
 * WARNING: this method is not supplied for developers, but invoked inner.
 *
 */
-(id)init:(PDF_PAGE) hand;
/**
 * @brief   Advanced function to get page object's reference.
            WARNING: this method require premium license.
 *
 * @return  PDF object reference.
 */
-(PDF_OBJ_REF)advanceGetRef;
/**
 * @brief   Advanced function to reload page object, called after advanced methods update annotation object data.
            WARNING: this method require premium license.
 */
-(void)advanceReload;
/**
 * @brief   Import annotation from data in rect.
 * @param   rect Rect in pdf cooridinates where place annotation.
 * @param   dat Annotation's bytes data.
 * @param   dat_len Annotation's data lenght limit value.
 *
 * @return  true or false.
 */
-(bool)importAnnot:(const PDF_RECT *)rect :(const unsigned char *)dat :(int)dat_len;
/**
 * @brief Reneder page's thumb.
 * @param dib DIB object.
 */
-(bool)renderThumb:(RDPDFDIB *)dib;
/**
 * @brief Prepare to render, this method just erase DIB to white.
 */
-(void)renderPrepare:(RDPDFDIB *)dib;
/**
 * @brief render page to dib object. this function returned for cancelled or finished.
 * WARNING: before render, you need invoke RenderPrepare.
 * @param dib DIB object to render obtained by Global.dibGet().
 * @param mat Matrix object define scale, rotate, translate operations.
 * @param quality Render quality applied to Image rendering:
 *                0: draft
 *                1: normal
 *                2: best quality.
 * @return true or false.
 */
-(bool)render:(RDPDFDIB *)dib :(RDPDFMatrix *)mat :(int)quality;
/**
 * @brief Set page status to cancelled and cancel render function.
 */
-(void)renderCancel;
/**
 * @brief Check if page rendering is finished.
 * @return true or false.
 */
-(bool)renderIsFinished;
/**
 * @brief Prepare page's reflow. 
 * @param width
 * @param scale Scale value.
 * 
 * @return float value.
 */
-(float)reflowPrepare:(float)width :(float)scale;
/**
 * @brief Reflow page to DIB
 * WARNING: this method require professional or premium license.
 * @param dib DIB object to render.
 * @param orgx Origin x coordinate.
 * @param orgy Origin y coordinate.
 * 
 * @return true or false.
 */
-(bool)reflow:(RDPDFDIB *)dib :(float)orgx :(float)orgy;
/**
 * @brief Get rotate degree for page (for example 0 or 90).
 * @return Rotate int value.
 */ 
-(int)getRotate;
/**
 * @brief Flat all annotations in page. 
 * @return float value
 */
-(bool)flatAnnots;
/**
 * @brief Sign and save the PDF file.
 * WARNING: this method required premium license and signed feature native libs, which has bigger size.
 * @param appearence Signature's appearence object.
 * @param box Annotation's rect where place signature.
 * @param cert_file Certification file's path.
 * @param pswd Certification file password.
 * @param name Signer's name string value.
 * @param reason Signer's reason string value.
 * @param location Signer's location string value.
 * @param contact Signer's contact string value.
 * 
 * @return 1 or 0.
 */
-(int)sign :(RDPDFDocForm *)appearence :(const PDF_RECT *)box :(NSString *)cert_file :(NSString *)pswd :(NSString*)name :(NSString *)reason :(NSString *)location :(NSString *)contact;
/**
 * @brief Get pages' text objects to memory.
 * WARNING: a standard license is required for this method.
 */
-(void)objsStart;
/**
 * @brief Get chars count in this page. This can be invoked after ObjsStart.
 * WARNING: a standard license is required for this method.
 * @return Chars count. If ObjsStart not invoked returns 0.
 */
-(int)objsCount;
/**
 * @brief Get string from range. This can be invoked after ObjsStart.
 * @param from 0 based unicode index.
 * @param to 0 based unicode index.
 * @return String value.
 */
-(NSString *)objsString:(int)from :(int)to;
/**
 * @brief Get index aligned by word. This can be invoked after ObjsStart
 * @param index 0 based unicode index.
 * @param dir Selector's direction. If dir < 0, it gets start index of the word. Otherwise it gets last index of the word.
 * @return New index value.
 */
-(int)objsAlignWord:(int)index :(int)dir;
/**
 * @brief Get char's box in PDF coordinate system. This can be invoked after ObjsStart
 * @param index 0 based unicode index.
 * @param rect Rect object in PDF coordinates. This will be the output value.
 */
-(void)objsCharRect:(int)index :(PDF_RECT *)rect;
/**
 * @brief Get char index nearest to point.
 * @param x point as [x,y] in PDF coordinate.
 * @param y point as [x,y] in PDF coordinate.
 * 
 * @return Char index. On failure returns -1.
 */
-(int)objsGetCharIndex:(float)x :(float)y;
/**
 * @brief Create a find session. This can be invoked after ObjsStart.
 * @param key Key string to find.
 * @param match_case Match case option.
 * @param whole_word Match whole word option.
 * 
 * @return Find session's handle. On no results found returns 0.
 */
-(RDPDFFinder *)find:(NSString *)key :(bool)match_case :(bool)whole_word;
/**
 * @brief Create a find session. This can be invoked after ObjsStart.
 * @param key Key string to find.
 * @param match_case Match case option.
 * @param whole_word Match whole word option.
 * @param skip_blanks Skip blank spaces option.
 * 
 * @return Find session's handle. On no results found returns 0.
 */
-(RDPDFFinder *)find2:(NSString *)key :(bool)match_case :(bool)whole_word :(bool)skip_blanks;
/**
 * @brief Get page's annotation count. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @return Annotation count.
 */
-(int)annotCount;
/**
 * @brief Get annotations at index. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param index 0 based index value. Range:[0, GetAnnotCount()-1].
 * 
 * @return Annotation's handle. It's valid until Close method invoked.
 */
-(RDPDFAnnot *)annotAtIndex:(int)index;
/**
 * @brief Get annotations by PDF point. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param x x value in PDF coordinate system.
 * @param y y value in PDF coordinate system.
 * 
 * @return Annotation's handle. It's valid until Close method invoked.
 */
-(RDPDFAnnot *)annotAtPoint:(float)x :(float)y;
/**
 * @brief Get annotations by name. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param x Annotation's name string value.
 * 
 * @return Annotation's handle. It's valid until Close method invoked.
 */
-(RDPDFAnnot *)annotByName:(NSString *)name;
/**
 * @brief Copy annotation. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param annor Annotation that will be copied.
 * @param rect Annotation copy's rect.
 * 
 * @return true or false.
 */
-(bool)copyAnnot:(RDPDFAnnot *)annot :(const PDF_RECT *)rect;
/**
 * @brief Add annotation. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param ref New annotation's object reference.
 * @param index New annotation's index.
 * 
 * @return true or false.
 */
-(bool)addAnnot:(PDF_OBJ_REF)ref :(int)index;
/**
 * @brief Add annotation popup. This can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param parent Popup's annotation parent.
 * @param rect Popup annotation's rect.
 * @param open Popup open status.
 * 
 * @return true or false.
 */
-(bool)addAnnotPopup:(RDPDFAnnot *)parent :(const PDF_RECT *)rect :(bool)open;
/**
 * @brief Add a text-markup annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be only invoked after ObjsStart.
 * WARNING: this method is valid in professional or premium version.
 * @param index1 first char index.
 * @param index2 second char index.
 * @param type type as following:
 *             0: Highlight
 *             1: Underline
 *             2: StrikeOut
 *             3: Highlight without round corner
 *             4: Squiggly underline.
 * 
 * @return true or false.
 */
-(bool)addAnnotMarkup:(int)index1 :(int)index2 :(int)type :(int) color;
/**
 * @brief Add hand-writing annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param ink Ink object in PDF coordinate.
 * 
 * @return true or false.
 */
-(bool)addAnnotInk:(RDPDFInk *)ink;
/**
 * @brief Add goto-page link annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param rect Link area rect [left, top, right, bottom] in PDF coordinate.
 * @param dest 0 based pageno to jump.
 * @param top y coordinate in PDF coordinate. page.height is page's top and 0 page's bottom.
 * 
 * @return true or false.
 */
-(bool)addAnnotGoto:(const PDF_RECT *)rect :(int)dest :(float)top;
/**
 * @brief Add URL link annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param rect Link area rect [left, top, right, bottom] in PDF coordinate.
 * @param uri Url address (for example: "http://www.radaee.com/en").
 * 
 * @return true or false.
 */
-(bool)addAnnotURI:(NSString *)uri :(const PDF_RECT *)rect;
/**
 * @brief Add line annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param pt1 Start point in PDF coordinate. 2 elements: [x, y].
 * @param pt2 End point in PDF coordinate. 2 elements: [x, y].
 * @param style1 Start point's style:
 *               0: None
 *               1: Arrow
 *               2: Closed Arrow
 *               3: Square
 *               4: Circle
 *               5: Butt
 *               6: Diamond
 *               7: Reverted Arrow
 *               8: Reverted Closed Arrow
 *               9: Slash
 * @param style2 End point's style. Values are same as style1.
 * @param width Line width in DIB coordinate
 * @param color Line color hex int value.
 * @param icolor Fill color used to fill arrows of the line.
 * 
 * @return true or false.
 */
-(bool)addAnnotLine:(const PDF_POINT *)pt1 :(const PDF_POINT *)pt2 :(int) style1 :(int) style2 :(float) width :(int) color :(int) icolor;
/**
 * @brief Add rectangle to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param rect 4 elements for left, top, right, bottom in PDF coordinate system.
 * @param width Line width in PDF coordinate.
 * @param color Rectangle color, formatted as 0xAARRGGBB.
 * @param icolor Fill color in rectangle, formated as 0xAARRGGBB. If alpha channel is 0 means no fill operation, otherwise alpha channel are ignored.
 * 
 * @return true or false.
 */
-(bool)addAnnotRect:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor;
/**
 * @brief Add ellipse to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param rect 4 elements for left, top, right, bottom in PDF coordinate system.
 * @param width Line width in PDF coordinate.
 * @param color Ellipse color, formatted as 0xAARRGGBB.
 * @param icolor Fill color in ellipse, formated as 0xAARRGGBB. If alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
 * 
 * @return true or false.
 */
-(bool)addAnnotEllipse:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor;
/**
 * @brief Add polygon to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param path Polygon's path. It must be a closed contour.
 * @param color Polygon color, formatted as 0xAARRGGBB.
 * @param fill_color Fill color in ellipse, formated as 0xAARRGGBB. If alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
 * @param width Line width in PDF coordinate.
 * 
 * @return true or false.
 */
-(bool)addAnnotPolygon:(RDPDFPath *)path :(int) color :(int) fill_color :(float) width;
/**
 * @brief Add polyline to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param path Polyline's path. It must be a set of unclosed lines. Do not container any move-to operation except the first point in the path.
 * @param style1 Style for start point:
 *               0: None
 *               1: Arrow
 *               2: Closed Arrow
 *               3: Square
 *               4: Circle
 *               5: Butt
 *               6: Diamond
 *               7: Reverted Arrow
 *               8: Reverted Closed Arrow
 *               9: Slash
 * @param style2 Style for end point. Values are the same of start point.
 * @param color Polyline color, formatted as 0xAARRGGBB.
 * @param fill_color Fill color in ellipse, formated as 0xAARRGGBB. If alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
 * @param width Line width in PDF coordinate.
 * 
 * @return true or false.
 */
-(bool)addAnnotPolyline:(RDPDFPath *)path :(int) style1 :(int) style2 :(int) color :(int) fill_color :(float) width;
/**
 * @brief Add a sticky text annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param pt Annotation's point. 2 elements: [x, y] in PDF coordinate system.
 * 
 * @return true or false.
 */
-(bool)addAnnotNote:(const PDF_POINT *)pt;
/**
 * @brief add an Rubber Stamp to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param rect Icon area's rect [left, top, right, bottom] in PDF coordinate.
 * @param icon Predefined value as below:
 *             0: "Draft"(default icon)
 *             1: "Approved"
 *             2: "Experimental"
 *             3: "NotApproved"
 *             4: "AsIs"
 *             5: "Expired"
 *             6: "NotForPublicRelease"
 *             7: "Confidential"
 *             8: "Final"
 *             9: "Sold"
 *            10: "Departmental"
 *            11: "ForComment"
 *            12: "TopSecret"
 *            13: "ForPublicRelease"
 *            14: "Accepted"
 *            15: "Rejected"
 *            16: "Witness"
 *            17: "InitialHere"
 *            18: "SignHere"
 *            19: "Void"
 *            20: "Completed"
 *            21: "PreliminaryResults"
 *            22: "InformationOnly"
 *            23: "End"
 * @return true or false. If this method return true, the added annotation can be obtained by Page.GetAnnot(Page.GetAnnotCount() - 1), .
 */
-(bool)addAnnotStamp:(int)icon :(const PDF_RECT *)rect;
/**
 * @brief Add a bitmap object as an annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method require professional or premium license, and Document.SetCache() invoked.
 * @param mat Annotation's matrix object.
 * @param dimage DocImage object return from Document.NewImage∗()
 * @param rect Annotation area's rect [left, top, right, bottom] in PDF coordinate.
 * 
 * @return true or false.
*/
-(bool)addAnnotBitmap0:(RDPDFMatrix *)mat :(RDPDFDocImage *)dimage :(const PDF_RECT *)rect;
/**
 * @brief Add a bitmap object as an annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method require professional or premium license, and Document.SetCache() invoked.
 * @param dimage DocImage object return from Document.NewImage∗()
 * @param rect Annotation area's rect [left, top, right, bottom] in PDF coordinate.
 * 
 * @return true or false.
*/
-(bool)addAnnotBitmap:(RDPDFDocImage *)dimage : (const PDF_RECT *)rect;
/**
 * @brief Add a RichMedia annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method require professional or premium license, and Document.SetCache() invoked.
 * @param path_player Path name to flash player (example: ”/sdcard/VideoPlayer.swf”, ”/sdcard/AudioPlayer.swf”).
 * @param path_content Path name to RichMedia content (example: ”/sdcard/video.mp4”, ”/sdcard/audio.mp3”).
 * @param type Type value:
 *             0: Video (like ∗.mpg, ∗.mp4...)
 *             1: Audio (like ∗.mp3 ...)
 *             2: Flash
 *             3: 3D
 * @param dimage DocImage object return from Document.NewImage∗(); 
 * @param rect Annotation area's rect [left, top, right, bottom] in PDF coordinate.
 * 
 * @return true or false.
*/
-(bool)addAnnotRichMedia:(NSString *)path_player :(NSString *)path_content :(int)type :(RDPDFDocImage *)dimage :(const PDF_RECT *)rect;
/**
 * @brief Add a file as an attachment to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param att Absolute path name to the file.
 * @param icon Icon display to the page. values as:
 *             0: PushPin
 *             1: Graph
 *             2: Paperclip
 *             3: Tag
 * @param rect 4 elements: left, top, right, bottom in PDF coordinate system.
 * 
 * @return true or false.
*/
-(bool)addAnnotAttachment:(NSString *)att :(int)icon :(const PDF_RECT *)rect;
/**
 * @brief Add a font as resource of this page.
 * WARNING: a premium license is required for this method.
 * @param font Font object created by RDRDPDFDoc.newFontCID.
 * 
 * @return Font resource.
 */
-(PDF_PAGE_FONT)addResFont:(RDPDFDocFont *)font;
/**
 * @brief Add an image as resource of this page.
 * WARNING: a premium license is required for this method.
 * @param image Image object created by RDRDPDFDoc.newImageXXX.
 * 
 * @return Image resource. Null means failed.
 */
-(PDF_PAGE_IMAGE)addResImage:(RDPDFDocImage *)image;
/**
 * @brief Add GraphicState as resource of this page.
 * WARNING: a premium license is required for this method.
 * @param gstate ExtGraphicState created by RDRDPDFDoc.newGState();
 * 
 * @return GraphicState resource. Null means failed.
 */
-(PDF_PAGE_GSTATE)addResGState:(RDPDFDocGState *)gstate;
/**
 * @brief Add sub-form as resource of form.
 * @param form Form object returned by Document.NewForm()
 * 
 * @return Sub-form resource.
*/
-(PDF_PAGE_FORM)addResForm:(RDPDFDocForm *)form;
/**
 * @brief Add content stream to this page.
 * WARNING: a premium license is required for this method.
 * @param content PageContent object called PageContent.create().
 * 
 * @return true or false.
 */
-(bool)addContent:(RDPDFPageContent *)content :(bool)flush;
/**
 * @brief Add edit text annotation to page.
 * WARNING: you should re-render page to display modified data.
 * WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 * WARNING: this method is valid in professional or premium version.
 * @param rect 4 elements: left, top, right, bottom in PDF coordinate system.
 * 
 * @return true or false.
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
 * @brief Import a page to dest document.
 * WARNING: a premium license is required for this method.
 * @param src_no 0 based page number from source Document that passed to ImportStart.
 * @param dst_no 0 based page number to insert in destination document object.
 * 
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
 * @brief Set open flag.
 * WARNING: the flag is a global setting, which effect all Document.OpenXXX() methods.
 * @param flag Flag value:
 *             (flag&1):load linearzied hint table.
 *             (flag&2):if bit set, mean all pages considered as same size, and SDK will only read first page object in open time, and set all pages size same to first page.
 *             (flag&2):only works when (flag&1) is set.
 */
+(void)setOpenFlag:(int)flag;
/**
 * @brief Open document.
 * WARNING: first time, SDK try password as user password, and then try password as owner password.
 * @param path PDF file to be open.
 * @param password Password or null if not need password.
 * @return Error code value:
 *         0:succeeded, and continue
 *         1:need input password
 *         2:unknown encryption
 *         3:damaged or invalid format
 *        10:access denied or invalid file path
 *    Others:unknown error
 */
-(int)open:(NSString *)path :(NSString *)password;
/**
 * @brief Open document in memory.
 * WARNING: first time, SDK try password as user password, and then try password as owner password.
 * @param data Data for whole PDF file in byte array. Developers should retain array data until document closed.
 * @param data_size Byte array's data size.
 * @param password Password or null if not need password.
 * @return Error code value:
 *         0:succeeded, and continue
 *         1:need input password
 *         2:unknown encryption
 *         3:damaged or invalid format
 *        10:access denied or invalid file path
 *    Others:unknown error
 */
-(int)openMem:(void *)data :(int)data_size :(NSString *)password;
/**
 * @brief Open document from stream.
 * WARNING: first time, SDK try password as user password, and then try password as owner password.
 * @param stream PDFStream object.
 * @param password Password or null if not need password.
 * @return Error code value:
 *         0:succeeded, and continue
 *         1:need input password
 *         2:unknown encryption
 *         3:damaged or invalid format
 *        10:access denied or invalid file path
 *    Others:unknown error
 */
-(int)openStream:(id<PDFStream>)stream :(NSString *)password;
/**
 * @brief Open and decrypt document using public key.
 * WARNING: this feature only enabled on signed feature version which native libs has bigger size.
 * @param path PDF file to be open.
 * @param cert_file Certification file path (like .p12 or .pfx file, DER encoded file).
 * @param password Certification file's password.
 * @return Error code value:
 *         0:succeeded, and continue
 *         1:need input password
 *         2:unknown encryption
 *         3:damaged or invalid format
 *        10:access denied or invalid file path
 *    Others:unknown error
 */
-(int)openWithCert:(NSString *)path :(NSString *)cert_file :(NSString *)password;
/**
 * @brief Open and decrypt document in memory using public key.
 * WARNING: this feature only enabled on signed feature version which native libs has bigger size.
 * @param data Data for whole PDF file in byte array. Developers should retain array data until document closed.
 * @param data_size Byte array's data size.
 * @param cert_file Certification file path (like .p12 or .pfx file, DER encoded file).
 * @param password Certification file's password.
 * @return Error code value:
 *         0:succeeded, and continue
 *         1:need input password
 *         2:unknown encryption
 *         3:damaged or invalid format
 *        10:access denied or invalid file path
 *    Others:unknown error
 */
-(int)openMemWithCert:(void *)data :(int)data_size : (NSString *)cert_file :(NSString *)password;
/**
 * @brief Open and decrypt stream document using public key.
 * WARNING: this feature only enabled on signed feature version which native libs has bigger size.
 * @param stream PDFStream object.
 * @param cert_file Certification file path (like .p12 or .pfx file, DER encoded file).
 * @param password Certification file's password.
 * @return Error code value:
 *         0:succeeded, and continue
 *         1:need input password
 *         2:unknown encryption
 *         3:damaged or invalid format
 *        10:access denied or invalid file path
 *    Others:unknown error
 */
-(int)openStreamWithCert:(id<PDFStream>)stream : (NSString *)cert_file :(NSString *)password;
/**
 * @brief Get linearized status.
 * @return Linearized status:
 *         0: linearized header not loaded or no linearized header.(if setOpenFlag(0); always return 0)
 *         1: there is linearized header, but linearized entry checked as failed.
 *         2: there is linearized header, linearized entry checked succeeded, but hint table is damaged.
 */
-(int)getLinearizedStatus;
/**
 * @brief Create empty PDF document.
 * @param path Path to create
 * @return 0 or less than 0 means failed, same as Open.
 */
-(int)create:(NSString *)path;
/**
 * @brief   Advanced function to get document object's reference.
 * WARNING: this method require premium license.
 * 
 * @return  PDF object reference.
 */
-(PDF_OBJ_REF)advanceGetRef;
/**
 * @brief   Advanced function to reload document object, called after advanced methods update annotation object data.
 * WARNING: this method require premium license.
 */
-(void)advanceReload;
/**
 * @brief   Advanced function to create a stream using zflate compression(zlib).
 * WARNING: stream byte contents can't modified, once created.
 * WARNING: the byte contents shall auto compress and encrypt by native library.
 * WARNING: this method require premium license, and need Document.SetCache() invoked.
 * @param source Source byte array.
 * @param len Source byte array's length.
 * 
 * @return  PDF cross reference to new object, using Advance_GetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewFlateStream:(const unsigned char *)source :(int)len;
/**
 * @brief   Advanced function to create a stream using raw data.
 * WARNING: if you pass compressed data to this method you shall modify dictionary of this stream, like ”Filter” and other item from dictionary.
 * WARNING: The byte contents shall auto encrypt by native library, if document if encrypted.
 * WARNING: this method require premium license, and need Document.SetCache() invoked.
 * @param source Source byte array.
 * @param len Source byte array's length.
 * 
 * @return  PDF cross reference to new object, using Advance_GetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewRawStream:(const unsigned char *)source :(int)len;
/**
 * @brief   Advanced function to create an empty indirect object to edit.
 * WARNING: this method require premium license, and need Document.SetCache() invoked.
 * 
 * @return  PDF cross reference to new object, using Advance_GetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewIndirectObj;
/**
 * @brief   Advanced function to create an empty indirect object and then copy source object to this indirect object.
 * WARNING: this method require premium license, and need Document.SetCache() invoked.
 * @param obj Source object to be copied.
 * 
 * @return  PDF cross reference to new object, using Advance_GetObj to get Object data.
 */
-(PDF_OBJ_REF)advanceNewIndirectObjAndCopy :(RDPDFObj *)obj;
/**
 * @brief Advanced function to get object from Document to edit.
 * WARNING: this method require premium license.
 * @param ref PDF cross reference ID.
 * 
 * @return PDF object.
 */
-(RDPDFObj *)advanceGetObj:(PDF_OBJ_REF)ref;
/**
 * @brief Set cache file to PDF.
 * WARNING: a professional or premium license is required for this method.
 * @param path Path to save some temporary data, compressed images and so on.
 * 
 * @return true or false.
 */
-(bool)setCache:(NSString *)path;
/**
 * @brief Rotate page.
 * WARNING: this method require premium license.
 * @param pageno 0 based page number to rotate.
 * @param degree Rotate angle in degree. It must be 90 ∗ n.
 * 
 * @return true or false.
 */
-(bool)setPageRotate: (int)pageno : (int)degree;
/**
 * Run javascript
 * NOTICE: considering some complex js, this method is not thread-safe.
 * WARNING: this method require premium license.
 * @param js Javascript string. It can't be null.
 * @param del Delegate for javascript running. It can't be null.
 * 
 * @return true or false.
 */
-(bool)runJS:(NSString *)js :(id<PDFJSDelegate>)del;
/**
 * @brief Verify specified signature.
 * WARNING: this method require premium license.
 * @param sign Signature object to verify.
 * 
 * @return true or false.
 */
-(int)verifySign:(RDPDFSign *)sign;
/**
 * @brief Check if document can be modified or saved.
 * WARNING: this always return false, if no license actived.
 * @return true or false.
 */
-(bool)canSave;
/**
 * @brief Check if document is encryted
 * @return true or false.
 */
-(bool)isEncrypted;
/**
 * @brief Get document's embedded files count.
 * @return Document's embedded files count.
 */
-(int)getEmbedFileCount;
/**
 * @brief Get embedded file's name at index.
 * @param idx Selected index with range in [0, GetEmbedFilesCount()].
 * 
 * @return Embedded file's name.
 */
-(NSString *)getEmbedFileName:(int)idx;
/**
 * @brief Get embedded file's description at index.
 * @param idx Selected index with range in [0, GetEmbedFilesCount()].
 * 
 * @return Embedded file's description.
 */
-(NSString *)getEmbedFileDesc:(int)idx;
/**
 * @brief Get embedded file's data at index and save it in path.
 * @param idx Selected index with range in [0, GetEmbedFilesCount()].
 * @param path Absolute path to save embedded file.
 * 
 * @return true or false.
 */
-(bool)getEmbedFileData:(int)idx :(NSString *)path;
/**
 * @brief Get javascript count.
 * WARNING: this method require premium license.
 * @return Javascript count.
 */
-(int)getJSCount;
/**
 * @brief Get javascript name at index.
 * WARNING: this method require premium license.
 * @param idx Selected index with range in [0, getJSCount()].
 * 
 * @return Javascript name string.
 */
-(NSString *)getJSName:(int)idx;
/**
 * @brief Get javascript at index.
 * WARNING: this method require premium license.
 * @param idx Selected index with range in [0, getJSCount()].
 * 
 * @return Javascript string.
 */
-(NSString *)getJS:(int)idx;
/**
 * @brief Export form data as xml string.
 * WARNING: this method require premium license.
 * @return Form's xml string.
 */
-(NSString *)exportForm;
/**
 * @brief Get documents's XMP string.
 * @return XMP string.
 */
-(NSString *)getXMP;
/**
 * @brief Set documents's XMP string.
 * @param xmp XMP string.
 * 
 * @return true or false.
 */
- (bool)setXMP:(NSString *)xmp;
/**
 * @brief Save the document.
 * WARNING: this always return false, if no license actived or standard license actived.
 * @return true or false.
 */
-(bool)save;
/**
 * @brief Save as the document to another file. it remove any security information.
 * WARNING: this always return false, if no license actived or standard license actived.
 * @param dst Path to save.
 * @param rem_sec Remove security handler flag.
 * 
 * @return true or false.
 */
-(bool)saveAs:(NSString *)dst :(bool)rem_sec;
/**
 *	@brief	Encrypt PDF file as another file.
 *  WARNING: this function require premium license.
 *
 *	@param 	dst 	Full path to save.
 *	@param  upswd	User password.
 *	@param  opswd	Owner password.
 *	@param  perm	Permission to set (see PDF reference or Document_getPermission()).
 *	@param  method	Reserved.
 *	@param	fid		File ID to be set. It must be 32 bytes long.
 *	@return	true or false.
 */
-(bool)encryptAs:(NSString *)dst : (NSString *)upswd : (NSString *)opswd : (int)perm : (int)method : (unsigned char *)fid;
/**
 * @brief Get meta data for document.
 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate". You can also pass any key that self-defined.
 * 
 * @return Meta string value.
 */
-(NSString *)meta:(NSString *)tag;
/**
 * @brief Set meta data for document.
 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate". You can also pass any key that self-defined.
 * @param val Meta data value.
 * 
 * @return true or false.
 */
-(bool)setMeta:(NSString *)tag :(NSString *)val;
/**
 * @brief Get ID of PDF file.
 * @param buf Receive 32 bytes as PDF ID. It must be 32 bytes long.
 * 
 * @return true or false.
*/
-(bool)PDFID:(unsigned char *)buf;
/**
 * @brief Get pages count.
 * @return Pages count.
 */
-(int)pageCount;
/**
 * @brief Get max width and max height of all pages.
 * @return PDF size object. It contains width and height values.
 */
-(PDF_SIZE)getPagesMaxSize;
/**
 * @brief Get a Page object for page number.
 * @param pageno 0 based page number with range in [0, pageCount()-1].
 * 
 * @return Page object.
 */
-(RDPDFPage *)page:(int) pageno;
/**
 * @brief Get page width by page number.
 * @param pageno 0 based page number with range in [0, pageCount()-1].
 * 
 * @return Width value.
 */
-(float)pageWidth:(int) pageno;
/**
 * @brief Get page height by page number.
 * @param pageno 0 based page number with range in [0, pageCount()-1].
 * 
 * @return Height value.
 */
-(float)pageHeight:(int) pageno;
/**
 * @brief Get page label
 * @param pageno 0 based page number with range in [0, pageCount()-1].
 * 
 * @return Page label string value.
 */
-(NSString *)pageLabel:(int)pageno;
/**
 * @brief Get first root outline item.
 * @return First outline's handle value. It returns null if no outlines.
 */
-(RDPDFOutline *)rootOutline;
-(bool)newRootOutline: (NSString *)label :(int) pageno :(float) top;
/**
 * @brief Create a font object, used to write texts.
 * WARNING: a premium license is required for this method.
 * @param name Font name exists in font list. Use Global.getFaceCount(), Global.getFaceName() to enumerate fonts.
 * @param style style value:
 *              (style&1) means bold
 *              (style&2) means Italic
 *              (style&8) means embed
 *              (style&16) means vertical writing, mostly used in Asia fonts.
 *
 * @return DocFont object.
 */
-(RDPDFDocFont *)newFontCID: (NSString *)name :(int) style;
/**
 * @brief Create a ExtGraphicState object used to set alpha values.
 * WARNING: a premium license is required for this method.
 * @return DocGState object.
 */
-(RDPDFDocGState *)newGState;
/**
 * @brief Create a DocFont object.
 * WARNING: a premium license is required for this method.
 * @return DocFont object.
 */
-(RDPDFDocForm *)newForm;
/**
 * @brief Insert a page to Document. If pagheno >= page_count, it do same as append. Otherwise, insert to pageno.
 * WARNING: a premium license is required for this method.
 * @param pageno 0 based page number.
 * @param w Page width in PDF coordinate
 * @param h Page height in PDF coordinate
 *
 * @return Page object.
 */
-(RDPDFPage *)newPage:(int) pageno :(float) w :(float) h;
/**
 * @brief Start import operations, import page from src.
 * WARNING: a premium license is required for this method.
 * WARNING: you shall maintenance the source Document object until all pages are imported and ImportContext.Destroy() invoked. 
 * @param src_doc Source Document object that opened.
 * 
 * @return Context object used in ImportPage. 
 */
-(RDPDFImportCtx *)newImportCtx:(RDPDFDoc *)src_doc;
/**
 * @brief Move the page to other position.
 * WARNING: a premium license is required for this method.
 * @param pageno1 Page number move from.
 * @param pageno2 Page number move to.
 *
 * @return true or false.
 */
-(bool)movePage:(int)pageno1 :(int)pageno2;
/**
 * @brief Remove page by page number.
 * WARNING: a premium license is required for this method.
 * @param pageno 0 based page number.
 *
 * @return true or false.
 */
-(bool)removePage:(int)pageno;
/**
 * @brief Create an image from Bitmap object.
 * @param img Bitmap image reference in ARGB_8888/ARGB_4444/RGB_565 format.
 * @param Generate Alpha channel information flag.
 * @return RDPDFDocImage object.
 */
-(RDPDFDocImage *)newImage:(CGImageRef)img : (bool)has_alpha;
/**
 * @brief create an image from JPEG/JPG file. Supported image color space: GRAY, RGB, CMYK
 * WARNING: a professional or premium license is required for this method.
 * @param path JPEG file's path.
 * @return DocImage object.
 */
-(RDPDFDocImage *)newImageJPEG:(NSString *)path;
/**
 * @brief Create an image from JPX/JPEG 2k file.
 * WARNING: a professional or premium license is required for this method.
 * @param path JPX file's path.
 *
 * @return DocImage object.
 */
-(RDPDFDocImage *)newImageJPX:(NSString *)path;
@end
