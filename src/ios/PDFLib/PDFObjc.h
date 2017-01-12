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

@interface PDFDIB : NSObject
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
@end

@interface PDFObj : NSObject
{
	PDF_OBJ m_obj;
}
@property(readonly) PDF_OBJ handle;
-(id)init :(PDF_OBJ)obj;
-(int)getType;
-(int)getIntVal;
-(bool)getBoolVal;
-(float)getRealVal;
-(PDF_OBJ_REF)getReferenceVal;
-(NSString *)getNameVal;
-(NSString *)getAsciiStringVal;
-(NSString *)getTextStringVal;
-(const unsigned char *)getHexStrngVal :(int *)len;
-(void)setIntVal:(int)v;
-(void)setBoolVal:(bool)v;
-(void)setRealVal:(float)v;
-(void)setReferenceVal:(PDF_OBJ_REF)v;
-(void)setNameVal:(NSString *)v;
-(void)setAsciiStringVal:(NSString *)v;
-(void)setTextStringVal:(NSString *)v;
-(void)setHexStringVal:(unsigned char *)v :(int)len;
-(void)setDictionary;
-(int)dictGetItemCount;
-(NSString *)dictGetItemTag:(int)index;
-(PDFObj *)dictGetItemByIndex:(int)index;
-(PDFObj *)dictGetItemByTag:(NSString *)tag;
-(void)dictSetItem:(NSString *)tag;
-(void)dictRemoveItem:(NSString *)tag;
-(void)setArray;
-(int)arrayGetItemCount;
-(PDFObj *)arrayGetItem:(int)index;
-(void)arrayAppendItem;
-(void)arrayInsertItem:(int)index;
-(void)arrayRemoveItem:(int)index;
-(void)arrayClear;
@end

@interface PDFOutline : NSObject
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
-(PDFOutline *)next;
/**
 *	@brief	get first child outline.
 */
-(PDFOutline *)child;
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
 *	@brief	remove this outline from PDF Document.
 */
-(bool)removeFromDoc;
-(bool)addNext:(NSString *)label :(int)pageno :(float)top;
-(bool)addChild:(NSString *)label :(int)pageno :(float)top;
@end

@interface PDFDocFont : NSObject
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
-(float)ascent;
-(float)descent;
@end

@interface PDFDocGState : NSObject
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
-(bool)setStrokeDash:(const float *)dash : (int)dash_cnt : (float)phase;
@end

@interface PDFDocImage : NSObject
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

@interface PDFFinder : NSObject
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
 *	@brief get found location by index.
 *
 *	@param find_index	index value in range [0, PDFFinder.count - 1].
 *
 *	@return	the index value in range [0, PDFPage.objsCount - 1].
 *
 */
-(int)objsIndex:(int)find_index;
@end

@interface PDFPath : NSObject
{
	PDF_PATH m_handle;
}
@property (readonly) PDF_PATH handle;
/**
 *	@brief	create a path object may includes some contours.
 */
-(id)init;
-(void)moveTo:(float)x :(float)y;
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
-(int)nodesCount;
/**
 * @brief	get each node, by index
 *			example:
 *			PDF_POINT pt;
 *			int type = [PDFPath node:index:&pt];
 *
 * @param	index	range [0, PDFPath.nodesCount - 1]
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

@interface PDFInk : NSObject
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
-(int)nodesCount;
/**
 * @brief	get each node, by index
 *			example:
 *			PDF_POINT pt;
 *			int node_type = [PDFInk node:index:&pt];
 *
 * @param	index	range [0, PDFInk.nodesCount - 1]
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

@interface PDFMatrix : NSObject
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
-(void)transformPath:(PDFPath *)path;
-(void)transformInk:(PDFInk *)ink;
-(void)transformRect:(PDF_RECT *)rect;
-(void)transformPoint:(PDF_POINT *)point;
@end    

@interface PDFPageContent : NSObject
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
-(void)gsCatMatrix:(PDFMatrix *) mat;
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
 * @param img image object returned from PDFPage.newImageXXX.
 */
-(void)drawImage:(PDF_PAGE_IMAGE) img;
-(void)drawForm:(PDF_PAGE_FORM)form;
/**
 * @brief draw text
 *
 * @param img text to draw
 */
-(void)drawText:(NSString *)text;
/**
 * @brief stroke the path
 *
 * @param path path to stroke
 */
-(void)strokePath:(PDFPath *) path;
/**
 * @brief fill the path
 *
 * @param path path to fill
 * @param winding true if use winding rule, or even-odd rule.
 */
-(void)fillPath:(PDFPath *)path :(bool) winding;
/**
 * @brief set the path to clip
 *
 * @param path path to clip
 * @param winding true if use winding rule, or even-odd rule.
 */
-(void)clipPath:(PDFPath *)path :(bool) winding;
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
-(bool)setStrokeDash:(float *)dash : (int)cnt;
/**
 * @brief PDF operator: set miter limit.
 * @param miter miter limit.
 */
-(void)setStrokeMiter:(float) miter;
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
 * @param rise
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


@interface PDFDocForm : NSObject
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
-(id)init:(PDF_DOC)doc : (PDF_DOC_FORM *)handle;
-(PDF_PAGE_FONT)addResFont :(PDFDocFont *)font;
-(PDF_PAGE_IMAGE)addResImage :(PDFDocImage *)img;
-(PDF_PAGE_GSTATE)addResGState : (PDFDocGState *)gs;
-(PDF_PAGE_FORM)addResForm : (PDFDocForm *)form;
-(void)setContent : (float)x : (float)y : (float)w : (float)h : (PDFPageContent *)content;
@end


@class PDFPage;
@interface PDFAnnot : NSObject
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
-(PDF_OBJ_REF)advanceGetRef;
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
 *	@brief	get name of this annotation, example: "EditBox1[0]".
 *			this method valid in premium version
 */
-(NSString *)fieldName;
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
-(bool)isReadonly;
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
* @brief get markup annotation's rectangles.
* this method valid in professional or premium version.
* @param rects rects in PDF coordinate system, as out values.
* @param cnt count of rects allocated.
* @return rects count that markup annotation has.
*/
-(int)getMarkupRects:(PDF_RECT *)rects : (int)cnt;
-(int)getIndex;
-(PDFPath *)getInkPath;
-(bool)setInkPath:(PDFPath *)path;
-(PDFPath *)getPolygonPath;
-(bool)setPolygonPath:(PDFPath *)path;
-(PDFPath *)getPolylinePath;
-(bool)setPolylinePath:(PDFPath *)path;

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
-(NSString *)getJS;
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

-(int)getRichMediaItemCount;
-(int)getRichMediaItemActived;
-(int)getRichMediaItemType:(int) idx;
-(NSString *)getRichMediaItemAsset:(int) idx;
-(NSString *)getRichMediaItemPara:(int) idx;
-(NSString *)getRichMediaItemSource:(int) idx;
-(bool)getRichMediaItemSourceData:(int) idx :(NSString *)save_path;
-(bool)getRichMediaData :(NSString *)asset :(NSString *)save_path;



-(bool)getPopupOpen;
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
-(NSString *)getPopupLabel;
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
-(float)getEditTextSize:(PDF_RECT *)rect;
-(NSString *)getEditTextFormat;
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
 * @param text contents to be set.in MultiLine mode: '\r' or '\n' means change line.in password mode the edit box always display "*". 
 * @return true or false.
 */
-(bool)setEditText:(NSString *)val;
-(bool)setEditFont:(PDFDocFont *)font;

-(int)getEditTextColor;
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
 * @param item 0 based item index. range:[0, getComboItemCount()-1]
 * @return null if this is not combo-box, "" if no item selected, otherwise the item selected.
 */
-(NSString *)getComboItem :(int)index;
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
 * @param item 0 based item index to set.
 * @return true or false.
 */
-(bool)setComboSel:(int)index;
/**
 * @brief get item count of list-box.
 * this method valid in premium version
 * @return -1: this is not a list. otherwise: items count.
 */
-(int)getListItemCount;
/**
 * @brief get an item of list-box.
 * this method valid in premium version
 * @param item 0 based item index. range:[0, getListItemCount()-1]
 * @return null if this is not list-box, "" if no item selected, otherwise the item selected.
 */
-(NSString *)getListItem:(int)index;
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
-(bool)setComboSel:(const int *)sels :(int)sels_cnt;
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
-(int)getSignStatus;
-(bool)MoveToPage:(PDFPage *)page :(const PDF_RECT *)rect;
@end

@interface PDFPage : NSObject
{
    PDF_PAGE m_page;
}
@property (readonly) PDF_PAGE handle;
/**
 * @brief create PDFPage object, this method is not supplied for developers, but invoked inner.
 *
 */
-(id)init:(PDF_PAGE) hand;
-(PDF_OBJ_REF)advanceGetRef;
-(void)advanceReload;
-(bool)renderThumb:(PDFDIB *)dib;
/**
 * @brief prepare to render, this method just erase DIB to white.
 */
-(void)renderPrepare:(PDFDIB *)dib;
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
-(bool)render:(PDFDIB *)dib :(PDFMatrix *)mat :(int)quality;
/**
 * @brief set page status to cancelled and cancel render function.
 */
-(void)renderCancel;
/**
 * @brief check if page rendering is finished.
 * @return true or false
 */
-(bool)renderIsFinished;
-(float)reflowPrepare:(float)width :(float)scale;
-(bool)reflow:(PDFDIB *)dib :(float)orgx :(float)orgy;
-(int)getRotate;
-(bool)flatAnnots;
/**
 * @brief get text objects to memory.
 * a standard license is required for this method
 */
-(void)objsStart;
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
 * @param from 0 based unicode index.
 * @param dir if dir < 0,  get start index of the word. otherwise get last index of the word.
 * @return new index value.
 */
-(int)objsAlignWord:(int)index :(int)dir;
/**
 * @brief get char's box in PDF coordinate system, this can be invoked after ObjsStart
 * @param index 0 based unicode index.
 * @param vals return 4 elements for PDF rectangle.
 */
-(void)objsCharRect:(int)index :(PDF_RECT *)rect;
/**
 * @brief get char index nearest to point
 * @param pt point as [x,y] in PDF coordinate.
 * @return char index or -1 failed.
 */
-(int)objsGetCharIndex:(float)x :(float)y;
/**
 * @brief create a find session. this can be invoked after ObjsStart
 * @param str key string to find.
 * @param match_case match case?
 * @param whole_word match whole word?
 * @return handle of find session, or 0 if no found.
 */
-(PDFFinder *)find:(NSString *)key :(bool)match_case :(bool)whole_word;
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
-(PDFAnnot *)annotAtIndex:(int)index;
/**
 * @brief get annotations by PDF point.
 * this can be invoked after ObjsStart or Render or RenderToBmp.
 * this method valid in professional or premium version
 * @param x x value in PDF coordinate system.
 * @param y y value in PDF coordinate system.
 * @return handle of annotation, valid until Close invoked.
 */
-(PDFAnnot *)annotAtPoint:(float)x :(float)y;
-(bool)copyAnnot:(PDFAnnot *)annot :(const PDF_RECT *)rect;
-(bool)addAnnotPopup:(PDFAnnot *)parent :(const PDF_RECT *)rect :(bool)open;
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
-(bool)addAnnotInk:(PDFInk *)ink;
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
 * @param fill_color fill color in rectangle, formated as 0xAARRGGBB, if alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
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
 * @param fill_color fill color in ellipse, formated as 0xAARRGGBB, if alpha channel is 0, means no fill operation, otherwise alpha channel are ignored.
 * @return true or false
 */
-(bool)addAnnotEllipse:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor;
-(bool)addAnnotPolygon:(PDFPath *)path :(int) color :(int) fill_color :(float) width;
-(bool)addAnnotPolyline:(PDFPath *)path :(int) style1 :(int) style2 :(int) color :(int) fill_color :(float) width;
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
-(bool)addAnnotBitmap0:(PDFMatrix *)mat :(PDFDocImage *)dimage :(const PDF_RECT *)rect;
-(bool)addAnnotBitmap:(PDFDocImage *)dimage : (const PDF_RECT *)rect;
-(bool)addAnnotRichMedia:(NSString *)path_player :(NSString *)path_content :(int)type :(PDFDocImage *)dimage :(const PDF_RECT *)rect;
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
 * @param font font object created by PDFDoc.newFontCID
 * @return ResFont or null.
 */
-(PDF_PAGE_FONT)addResFont:(PDFDocFont *)font;
/**
 * @brief add an image as resource of this page.
 * a premium license is required for this method.
 * @param image image object created by PDFDoc.newImageXXX
 * @return null means failed.
 */
-(PDF_PAGE_IMAGE)addResImage:(PDFDocImage *)image;
/**
 * @brief add GraphicState as resource of this page.
 * a premium license is required for this method.
 * @param gstate ExtGraphicState created by PDFDoc.newGState();
 * @return null means failed.
 */
-(PDF_PAGE_GSTATE)addResGState:(PDFDocGState *)gstate;
-(PDF_PAGE_FORM)addResForm:(PDFDocForm *)form;
/**
 * @brief add content stream to this page.
 * a premium license is required for this method.
 * @param content PageContent object called PageContent.create().
 * @return true or false.
 */
-(bool)addContent:(PDFPageContent *)content :(bool)flush;
@end

@interface PDFImportCtx : NSObject
{
    PDF_DOC m_doc;
	PDF_IMPORTCTX m_handle;
}
-(id)init:(PDF_DOC)doc :(PDF_IMPORTCTX)handle;
/**
 * @brief import a page to dest document.
 * a premium license is required for this method.
 * @param srcno 0 based page NO. from source Document that passed to ImportStart.
 * @param dstno 0 based page NO. to insert in dest document object.
 * @return true or false.
 */
-(bool)import:(int)src_no :(int)dst_no;
-(void)importEnd;
@end

@interface PDFDoc : NSObject
{
    PDF_DOC m_doc;
}
@property (readonly) PDF_DOC handle;
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
-(int)open:(NSString *)path : (NSString *)password;
-(int)openMem:(void *)data : (int)data_size : (NSString *)password;
-(int)openStream:(id<PDFStream>)stream : (NSString *)password;
/**
 * @brief create a empty PDF document
 * @param path path to create
 * @return 0 or less than 0 means failed, same as Open.
 */
-(int)create:(NSString *)path;
-(PDF_OBJ_REF)advanceGetRef;
-(void)advanceReload;
-(PDF_OBJ_REF)advanceNewFlateStream:(const unsigned char *)source :(int)len;
-(PDF_OBJ_REF)advanceNewRawStream:(const unsigned char *)source :(int)len;
-(PDF_OBJ_REF)advanceNewIndirectObj;
-(PDF_OBJ_REF)advanceNewIndirectObjAndCopy :(PDFObj *)obj;
-(PDFObj *)advanceGetObj:(PDF_OBJ_REF)ref;

/**
 * @brief set cache file to PDF.
 * a professional or premium license is required for this method.
 * @param path a path to save some temporary data, compressed images and so on
 * @return true or false
 */
-(bool)setCache:(NSString *)path;
-(bool)setPageRotate: (int)pageno : (int)degree;
-(bool)runJS:(NSString *)js :(id<PDFJSDelegate>)del;
/**
 * @brief check if document can be modified or saved.
 * this always return false, if no license actived.
 * @return true or false.
 */
-(bool)canSave;
-(bool)isEncrypted;
-(int)getEmbedFileCount;
-(NSString *)getEmbedFileName:(int)idx;
-(bool)getEmbedFileData:(int)idx :(NSString *)path;
-(NSString *)exportForm;
/**
 * @brief save the document.
 * this always return false, if no license actived or standard license actived.
 * @return true or false
 */
-(bool)save;
/**
 * @brief save as the document to another file. it remove any security information.
 * this always return false, if no license actived or standard license actived.
 * @param path path to save.
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
-(PDF_SIZE)getPagesMaxSize;
/**
 * @brief get a Page object for page NO.
 * @param pageno 0 based page NO. range:[0, pageCount()-1]
 * @return Page object
 */
-(PDFPage *)page:(int) pageno;
/**
 * @brief get page width by page NO.
 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
 * @return width value.
 */
-(float)pageWidth:(int) pageno;
/**
 * @brief get page height by page NO.
 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
 * @return height value.
 */
-(float)pageHeight:(int) pageno;
/**
 * @brief get first root outline item.
 * @return handle value of first root outline item. or null if no outlines.
 */
-(PDFOutline *)rootOutline;
-(bool)newRootOutline: (NSString *)label :(int) pageno :(float) top;
/**
 * @brief create a font object, used to write texts.
 * a premium license is required for this method.
 * @param font_name
 *		font name exists in font list.
 *		using Global.getFaceCount(), Global.getFaceName() to enumerate fonts.
 * @param style
 *   (style&1) means bold
 *   (style&2) means Italic
 *   (style&8) means embed
 *   (style&16) means vertical writing, mostly used in Asia fonts.
 * @return DocFont object or null is failed.
 */
-(PDFDocFont *)newFontCID: (NSString *)name :(int) style;
/**
 * @brief create a ExtGraphicState object, used to set alpha values.
 * a premium license is required for this method.
 * @return DocGState object or null.
 */
-(PDFDocGState *)newGState;
-(PDFDocForm *)newForm;
/**
 * @brief insert a page to Document
 * if pagheno >= page_count, it do same as append.
 * otherwise, insert to pageno.
 * a premium license is required for this method.
 * @param pageno 0 based page NO.
 * @param w page width in PDF coordinate
 * @param h page height in PDF coordinate
 * @return Page object or null means failed.
 */
-(PDFPage *)newPage:(int) pageno :(float) w :(float) h;
/**
 * @brief Start import operations, import page from src
 * a premium license is required for this method.
 * you shall maintenance the source Document object until all pages are imported and ImportContext.Destroy() invoked. 
 * @param src source Document object that opened.
 * @return a context object used in ImportPage. 
 */
-(PDFImportCtx *)newImportCtx:(PDFDoc *)src_doc;
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
-(PDFDocImage *)newImage:(CGImageRef)img : (bool)has_alpha;
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
-(PDFDocImage *)newImageJPEG:(NSString *)path;
/**
 * @brief create an image from JPX/JPEG 2k file.
 * a professional or premium license is required for this method.
 * @param path path to JPX file.
 * @return DocImage object or null.
 */
-(PDFDocImage *)newImageJPX:(NSString *)path;
-(int)checkSignByteRange;
@end
