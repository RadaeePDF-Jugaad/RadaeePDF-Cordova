//
//  ios.h
//  RDPDFLib
//
//  Created by Radaee on 12-6-22.
//  Copyright 2012 Radaee inc. All rights reserved.
//
#ifndef _PDF_IOS_H_
#define _PDF_IOS_H_
#import <CoreGraphics/CGImage.h>
#import <CoreGraphics/CGBitmapContext.h>
#import <UIKit/UIKit.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef enum
{
    err_ok = 0,
    err_open = 1,
    err_password = 2,
    err_encrypt = 3,
    err_bad_file = 4,
}PDF_ERR;
typedef enum
{
    mode_poor = 0,
    mode_normal = 1,
    mode_best = 2,
}PDF_RENDER_MODE;
typedef struct
{
	float cx;
	float cy;
}PDF_SIZE;
typedef struct
{
    float x;
    float y;
}PDF_POINT;
typedef struct
{
    float left;
    float top;
    float right;
    float bottom;
}PDF_RECT;
typedef struct _PDF_DIB * PDF_DIB;
typedef struct _PDF_MATRIX * PDF_MATRIX;
typedef struct _PDF_DOC * PDF_DOC;
typedef struct _PDF_OUTLINE * PDF_OUTLINE;
typedef void * PDF_PAGE;
typedef struct _PDF_FINDER * PDF_FINDER;
typedef struct _PDF_ANNOT * PDF_ANNOT;
typedef struct _PDF_INK * PDF_INK;
typedef struct _PDF_IMPORTCTX * PDF_IMPORTCTX;

typedef struct _PDF_PATH * PDF_PATH;
typedef struct _PDF_PAGECONTENT * PDF_PAGECONTENT;
typedef struct _PDF_DOC_FONT * PDF_DOC_FONT;
typedef struct _PDF_PAGE_FONT * PDF_PAGE_FONT;
typedef struct _PDF_DOC_GSTATE * PDF_DOC_GSTATE;
typedef struct _PDF_PAGE_GSTATE * PDF_PAGE_GSTATE;
typedef struct _PDF_DOC_IMAGE * PDF_DOC_IMAGE;
typedef struct _PDF_PAGE_IMAGE * PDF_PAGE_IMAGE;
typedef struct _PDF_DOC_FORM * PDF_DOC_FORM;
typedef struct _PDF_PAGE_FORM * PDF_PAGE_FORM;
typedef struct _PDF_OBJ * PDF_OBJ;
typedef unsigned long long PDF_OBJ_REF;

/**
 *	@brief	Active Standard license, this type of license can view PDF only.
 *
 *	@param 	name 	Bundle ID of Application in ios
 *	@param 	company Company name inputed when pruchase.
 *	@param 	mail 	Email address inputed when pruchase.
 *	@param 	serial 	Serial Number you recieved after paid.
 *
 *	@return	true or false.
 */
bool Global_activeStandard( const char *name, const char *company, const char *mail, const char *serial );

/**
 *	@brief	Active Professional license, this type of license can do some viewing and editing.
 *
 *	@param 	name 	Bundle ID of Application in ios
 *	@param 	company Company name inputed when pruchase.
 *	@param 	mail 	Email address inputed when pruchase.
 *	@param 	serial 	Serial Number you recieved after paid.
 *
 *	@return	true or false.
 */
bool Global_activeProfession( const char *name, const char *company, const char *mail, const char *serial );

/**
 *	@brief	Active Premium license, this type of license can do some viewing and editing and form editing.
 *
 *	@param 	name 	Bundle ID of Application in ios.
 *	@param 	company Company name inputed when pruchase.
 *	@param 	mail 	Email address inputed when pruchase.
 *	@param 	serial 	Serial Number you recieved after paid.
 *
 *	@return	true or false.
 */
bool Global_activePremium( const char *name, const char *company, const char *mail, const char *serial );

void Global_getVerString( char ret[8] );
bool Global_activePremiumForVer( const char *company, const char *mail, const char *serial );
bool Global_activeProfessionalForVer( const char *company, const char *mail, const char *serial );
bool Global_activeStandardForVer( const char *company, const char *mail, const char *serial );


/**

 *	@brief	Load font file.
 
 *	@param 	index 	Font file index.
 *	@param 	path 	Font path in SandBox.
 */
void Global_loadStdFont( int index, const char *path );
/**
 *	@brief	Save system font to a file.
 *
 *	@param 	fname 	font name from ios system, for example: Arial
 *	@param 	save_file 	full path name that save the font.
 *
 *	@return	true or false
 */
bool Global_SaveFont( const char *fname, const char *save_file );
/**
 *	@brief	Unload font file.
 *
 *	@param 	index 	font file index.
 */
void Global_unloadStdFont( int index );
/**

 *	@brief	load cmaps data. cmaps is code mapping struct.
 *
 *	@param 	cmaps 	full path of cmaps
 *	@param 	umaps 	full path of umaps

 */
void Global_setCMapsPath( const char *cmaps, const char *umaps );
bool Global_setCMYKProfile(const char *path);

/**
 *	@brief	create font list
 */
void Global_fontfileListStart();
/**
 *	@brief	add font file to list.
 *
 *	@param 	font_file 	full path of font file.
 */
void Global_fontfileListAdd( const char *font_file );
/**
 *	@brief		submit font list to PDF library.
 */
void Global_fontfileListEnd();
/**
 *	@brief	Set default font. the default font may be used when PDF has font not embed.
 this function valid after Global_fontfileListEnd() invoked.
 *
 *	@param 	collection 	may be: null, "GB1", "CNS1", "Japan1", "Korea1"
 *	@param 	font_name 	font name exist in font list.
 *	@param 	fixed 	set for fixed font?
 *
 *	@return	true or false
 */
bool Global_setDefaultFont( const char *collection, const char *font_name, bool fixed );

bool Global_fontfileMapping(const char *map_name, const char *name);

/**
 *	@brief	Set annot font type
 *
 *	@param 	font_name 	full path of font file.
 *
 *	@return	true or false
 */
bool Global_setAnnotFont( const char *font_name );
/**
 *	@brief	set annot transparency
 *
 *	@param 	color 	RGB color.e.g.0x200040FF
 */
void Global_setAnnotTransparency( int color );
/**
 *	@brief Get face count.
           this function valid after Global_fontfileListEnd() invoked.
 *
 *	@return	face count
 */
int Global_getFaceCount();
/**
 *	@brief	get face name by index.
            this function valid after Global_fontfileListEnd() invoked.
 *
 *	@param 	index 	0 based index, range : [0, Global_getFaceCount()-1].
 *
 *	@return	face name.
 */
const char *Global_getFaceName( int index );
/**
 *	@brief	alloc or realloc DIB object.
 *
 *	@param 	dib 	NULL for alloc, otherwise, realloc object.
 *	@param 	width 	width of DIB
 *	@param 	height 	height of DIB
 *
 *	@return	DIB object.
 */
PDF_DIB Global_dibGet( PDF_DIB dib, int width, int height );
/**
 *	@brief	Get dib data,return pointer of dib object 
 *
 *	@param 	dib Dib object 
 */
void *Global_dibGetData( PDF_DIB dib );
/**
 *	@brief	Get dib object's width
 *
 *	@param 	dib DIB object
 *
 *	@return	DIB object's width
 */
int Global_dibGetWidth( PDF_DIB dib );
/**
 *	@brief	Get dib object's height
 *
 *	@param 	dib DIB object
 *
 *	@return	DIB object's height
 */
int Global_dibGetHeight( PDF_DIB dib );
/**
 *	@brief	delete DIB object
 *
 *	@param 	dib    DIB object 
 */
void Global_dibFree( PDF_DIB dib );
/**
 *	@brief	map PDF Point to DIB point.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	ppoint 	Point in PDF coordinate system.
 *	@param 	dpoint 	output value: Point in DIB coordinate system.
 */
void Global_toDIBPoint( PDF_MATRIX matrix, const PDF_POINT *ppoint, PDF_POINT *dpoint );
/**
 *	@brief	map DIB Point to PDF point.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	dpoint 	Point in DIB coordinate system.
 *	@param 	ppoint 	output value: Point in PDF coordinate system.
 */
void Global_toPDFPoint( PDF_MATRIX matrix, const PDF_POINT *dpoint, PDF_POINT *ppoint );
/**
 *	@brief	map PDF rect to DIB rect.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	prect 	Rect in PDF coordinate system.
 *	@param 	drect 	output value: Rect in DIB coordinate system.
 */
void Global_toDIBRect( PDF_MATRIX matrix, const PDF_RECT *prect, PDF_RECT *drect );
/**
 *	@brief	map DIB Rect to PDF Rect.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	drect 	Rect in DIB coordinate system.
 *	@param 	prect 	output value: Rect in PDF coordinate system.
 */
void Global_toPDFRect( PDF_MATRIX matrix, const PDF_RECT *drect, PDF_RECT *prect );
/**
 *	@brief	not used for developer
 */
void Global_drawScroll( PDF_DIB dst, PDF_DIB dib1, PDF_DIB dib2, int x, int y, int style );
/**
 *	@brief	create a Matrix object
 *
 *	@param 	xx 	x scale value
 *	@param 	yx 	yx-
 *	@param 	xy 	xy-
 *	@param 	yy 	y scale value
 *	@param 	x0 	x origin
 *	@param 	y0 	y origin
 *
 *	@return	Matrix object
 */
PDF_MATRIX Matrix_create( float xx, float yx, float xy, float yy, float x0, float y0 );
/**
 *	@brief	create a Matrix object for scale values.
 *
 *	@param 	scalex 	x scale value
 *	@param 	scaley 	y scale value
 *	@param 	x0 	x origin
 *	@param 	y0 	y origin
 *
 *	@return	Matrix object
 */
PDF_MATRIX Matrix_createScale( float scalex, float scaley, float x0, float y0 );
void Matrix_invert( PDF_MATRIX matrix );
void Matrix_transformPath( PDF_MATRIX matrix, PDF_PATH path );
void Matrix_transformInk( PDF_MATRIX matrix, PDF_INK ink );
void Matrix_transformRect( PDF_MATRIX matrix, PDF_RECT *rect );
void Matrix_transformPoint( PDF_MATRIX matrix, PDF_POINT *point );
/**
 *	@brief	free Matrix object
 *
 *	@param 	matrix 	matrix	Matrix object returned from Matrix_create or Matrix_createScale
 */
void Matrix_destroy( PDF_MATRIX matrix );
/**
 *	@brief	open document and return Document object.
 *
 *	@param 	path 	 full path of PDF file.
 *	@param 	password password try both user password and owner password
 *	@param 	err 	 output value: error code.
 *
 *	@return	NULL if failed, and developers should check err code for some reason.
            otherwize return Document object.
 */
PDF_DOC Document_open( const char *path, const char *password, PDF_ERR *err );
PDF_DOC Document_openMem( void *data, int data_size, const char *password, PDF_ERR *err );

@protocol PDFStream
@required
-(bool)writeable;
@required
-(int)read: (void *)buf :(int) len;
@required
-(int)write: (const void *)buf :(int) len;
@required
-(unsigned long long)position;
@required
-(unsigned long long)length;
@required
-(bool)seek:(unsigned long long)pos;
@end
PDF_DOC Document_openStream( id<PDFStream> stream, const char *password, PDF_ERR *err );

/**
 *	@brief	create document and return Document object.
 *
 *	@param 	path 	 full path of PDF file.
 *	@param 	err 	 output value: error code.
 *
 *	@return	NULL if failed, and developers should check err code for some reason.
 otherwize return Document object.
 */
PDF_DOC Document_create( const char *path, PDF_ERR *err );

/**
  *	@brief	set cache file for the document object.
  *
  *	@param 	doc 	     document object from open or create.
  *	@param 	cache_file 	 absolute path-name for cache file.
  *
  *	@return	true or false.
  */
bool Document_setCache( PDF_DOC doc, const char *cache_file );
    
@protocol PDFJSDelegate
@required
-(int)OnAlert:(int)nbtn :(NSString *)msg :(NSString *)title;
@required
-(void)OnConsole:(int)ccmd :(NSString *)para;
@required
-(bool)OnDocClose;
@required
-(NSString *)OnTmpFile;
@required
-(void)OnUncaughtException:(int)code : (NSString *)para;
@end
bool Document_runJS( PDF_DOC doc, const char *js, id<PDFJSDelegate> del );
    
/**
 *	@brief	get permission of PDF, this value defined in PDF reference 1.7
 *
 *	@param 	doc Document object returned from Doument_open
 *
 *	@return	permission flags
 *          bit 1-2 reserved
 *          bit 3(0x4) print
 *          bit 4(0x8) modify
 *          bit 5(0x10) extract text or image
 *          others: see PDF reference
 */
int Document_getPermission( PDF_DOC doc );
bool Document_setPageRotate( PDF_DOC doc, int pageno, int degree );
bool Document_changePageRect( PDF_DOC doc, int pageno, float dl, float dt, float dr, float db );
/**
 *	@brief	is Document editable?
 *
 *	@param 	doc  Document object returned from Document_open
 *
 *	@return	true or false
 */
bool Document_canSave( PDF_DOC doc );

/**
 *	@brief	Get title of outline item.
 *
 *	@param 	doc 	        Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *	@param 	label 	        output value: label text ot outline item.
 *	@param 	len 	        buffer length.
 *
 *	@return	length of label.
 */
int Document_getOutlineLabel(PDF_DOC doc, PDF_OUTLINE outlinenode, char *label, int len);
/**
 *	@brief	Get destination of Outline item.
 *
 *	@param 	doc 	        Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *
 *	@return		0 based page NO.
 */
int Document_getOutlineDest( PDF_DOC doc, PDF_OUTLINE outlinenode );
/**
 *	@brief	get first child Outline item.
 *
 *	@param 	doc 	        Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *
 *	@return	Root Outline item if outlinenode == NULL.
            return NULL if no children.
 */
PDF_OUTLINE Document_getOutlineChild(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	get next Outline item.
 *
 *	@param 	doc 	        Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *
 *	@return	Root Outline item if outlinenode == NULL.
            return NULL if no next item.
 */
PDF_OUTLINE Document_getOutlineNext(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	insert outline as first child of this Outline.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	        Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *	@param 	label 	        output value: label text ot outline item.
 *	@param 	pageno 	 0 based page NO.
 *	@param 	top 	y in PDF coordinate
 *
 *	@return	true or false
 */
bool Document_addOutlineChild(PDF_DOC doc, PDF_OUTLINE outlinenode, const char *label, int pageno, float top);
bool Document_newRootOutline( PDF_DOC doc, const char *label, int pageno, float top );
/**
 *	@brief	insert outline after of this Outline.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *	@param 	label 	output value: label text ot outline item.
 *	@param 	pageno 	0 based page NO.
 *	@param 	top 	y in PDF coordinate
 *
 *	@return	true or false
 */
bool Document_addOutlineNext(PDF_DOC doc, PDF_OUTLINE outlinenode, const char *label, int pageno, float top);
/**
 *	@brief	remove Outline
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext
 *
 *	@return	true or false
 */
bool Document_removeOutline(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	get meta data by tag.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	tag 	Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate","ModDate".
 *	@param 	meta 	output value: meta data.
 *	@param 	len 	buffer length.
 *
 *	@return	length of meta data.
 */
int Document_getMeta( PDF_DOC doc, const char *tag, char *meta, int len );
bool Document_getID(PDF_DOC doc, unsigned char *fid);
/**
 *	@brief	get page width.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	pageno 	0 based page number.
 *
 *	@return	width of page
 */
float Document_getPageWidth( PDF_DOC doc, int pageno );
/**
 *	@brief	get page height.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	pageno 	0 based page number.
 *
 *	@return	height of page.
 */
float Document_getPageHeight( PDF_DOC doc, int pageno );
/**
 *	@brief	get page count.
 *
 *	@param 	doc 	Document object returned from Document_open
 *
 *	@return	count of pages.
 */
int Document_getPageCount( PDF_DOC doc );
void Document_getPagesMaxSize(PDF_DOC doc, PDF_SIZE *sz);
/**
 *	@brief	save PDF file.
 *
 *	@param 	doc 	Document object returned from Document_open
 *
 *	@return		true or false.
 */
bool Document_save( PDF_DOC doc );
/**
 *	@brief	save PDF file as another file.
            this function remove all encrypt information and save to dst.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	dst 	full path to save.
 *
 *	@return	true or false.
 */
bool Document_saveAs( PDF_DOC doc, const char *dst, bool rem_sec );
/**
*	@brief	encrypt PDF file as another file. this function need premium license.
*
*	@param 	doc 	Document object returned from Document_open
*	@param 	dst 	full path to save.
*	@param  upswd	user password.
*	@param  opswd	owner password.
*	@param  perm	permission to set, see PDF reference or Document_getPermission().
*	@param  method	reserved.
*	@param	fid		file ID to be set. must be 32 bytes long.
*	@return	true or false.
*/
bool Document_encryptAs(PDF_DOC doc, NSString *dst, NSString *upswd, NSString *opswd, int perm, int method, unsigned char *fid);
/**
 *	@brief	is document encrypted?
 *
 *	@param 	doc 	Document object returned from Document_open
 *
 *	@return		true or false.
 */
bool Document_isEncrypted( PDF_DOC doc );
unsigned char* Document_getSignContents( PDF_DOC doc );
int Document_getSignContentsLen( PDF_DOC doc );
const char *Document_getSignFilter( PDF_DOC doc );
const char *Document_getSignSubFilter( PDF_DOC doc );
const int *Document_getSignByteRange( PDF_DOC doc );
int Document_getSignByteRangeCount( PDF_DOC doc );
int Document_checkSignByteRange( PDF_DOC doc );
int Document_getEFCount(PDF_DOC doc);
NSString *Document_getEFName(PDF_DOC doc, int index);
bool Document_getEFData(PDF_DOC doc, int index, NSString *path);
NSString *Document_exportForm( PDF_DOC doc );

/**
 *	@brief	close document.
 *
 *	@param 	doc 	Document object returned from Document_open
 */
void Document_close( PDF_DOC doc );
/**
 *	@brief	get page object by page NO.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	pageno 	0 based page NO.
 *
 *	@return	page object.
 */
PDF_PAGE Document_getPage( PDF_DOC doc, int pageno );
/**
 *	@brief	create a font object, used to write texts.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	name 	font name exists in font list.
 *                  using Global.getFaceCount(), Global.getFaceName() to enumerate fonts.
 *	@param 	style 	(style&1) means bold,
                    (style&2) means Italic,
                    (style&8) means embed,
                    (style&16) means vertical writing, mostly used in Asia fonts.
 *
 *	@return	DocFont object or null is failed.
 */
PDF_DOC_FONT Document_newFontCID( PDF_DOC doc, const char *name, int style );
/**
 *	@brief	get font ascent
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	font 	font object created by Document.NewFontCID()
 *
 *	@return	<#return value description#>
 */
float Document_getFontAscent( PDF_DOC doc, PDF_DOC_FONT font );
/**
 *	@brief	get font descent
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	font 	font object created by Document.NewFontCID()
 *
 *	@return	<#return value description#>
 */
float Document_getFontDescent( PDF_DOC doc, PDF_DOC_FONT font );
/**
 *	@brief	create a ExtGraphicState object, used to set alpha values.
 *          a premium license is needed for this method.
 *
 *	@param 	doc Document object returned from Document_open
 *
 *	@return	PDF_DOC_GSTATE objecet or NULL is failed.
 */
PDF_DOC_GSTATE Document_newGState( PDF_DOC doc );
/**
 *	@brief	set GraphicState object stroke alpha
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	state 	PDF Graphicstate create by Document_newGState
 *	@param 	alpha 	alpha value
 *
 *	@return	true or false
 */
bool Document_setGStateStrokeAlpha( PDF_DOC doc, PDF_DOC_GSTATE state, int alpha );
/**
 *	@brief	set GraphicState object fill alpha
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	state 	PDF Graphicstate create by Document_newGState
 *	@param 	alpha 	alpha value
 *
 *	@return	true or false
 */
bool Document_setGStateFillAlpha( PDF_DOC doc, PDF_DOC_GSTATE state, int alpha );
PDF_DOC_FORM Document_newForm(PDF_DOC doc);
PDF_PAGE_FONT Document_addFormResFont(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_FONT font);
PDF_PAGE_IMAGE Document_addFormResImage(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_IMAGE image);
PDF_PAGE_GSTATE Document_addFormResGState(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_GSTATE gstate);
PDF_PAGE_FORM Document_addFormResForm(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_FORM sub);
void Document_setFormContent(PDF_DOC doc, PDF_DOC_FORM form, float x, float y, float w, float h, PDF_PAGECONTENT content);
void Document_freeForm(PDF_DOC doc, PDF_DOC_FORM form);
/**
 *	@brief	insert a page to Document
 *          if pagheno >= page_count, it do same as append.
 *          otherwise, insert to pageno.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	pageno 	0 based page NO.
 *	@param 	w 	page width in PDF coordinate
 *	@param 	h 	page height in PDF coordinate
 *
 *	@return	Page object or null means failed.
 */
PDF_PAGE Document_newPage( PDF_DOC doc, int pageno, float w, float h );

/**
 *	@brief	create an import context.
 *          a premium license is needed for this method.
 *	@param 	doc 	dest Document object returned from Document_openXXX or Document_CreateXXX
 *	@param 	doc_src	source Document object returned from Document_openXXX or Document_CreateXXX
 *
 *	@return	context object or NULL.
 */
PDF_IMPORTCTX Document_importStart( PDF_DOC doc, PDF_DOC doc_src );

/**
 *	@brief	import 1 page from source document
 *          a premium license is needed for this method.
 *	@param 	doc 	dest Document object returned from Document_openXXX or Document_CreateXXX
 *	@param 	ctx		context object returned from Document_importStart
 *	@param 	srcno	0 based page NO. from source Document object
 *	@param 	dstno	0 based page NO. for dest Document object
 *
 *	@return	true or false.
 */
bool Document_importPage( PDF_DOC doc, PDF_IMPORTCTX ctx, int srcno, int dstno );

/**
 *	@brief	destroy context object
 *          a premium license is needed for this method.
 *	@param 	doc 	dest Document object returned from Document_openXXX or Document_CreateXXX
 *	@param 	ctx		context object returned from Document_importStart
 */
void Document_importEnd( PDF_DOC doc, PDF_IMPORTCTX ctx );

/**
 *	@brief	move page by page NO.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_openXXX or Document_CreateXXX
 *	@param 	pageno1	0 based page NO for origin page NO.
 *	@param 	pageno2	0 based page NO for dest page NO.
 *
 *	@return	true or false
 */
bool Document_movePage( PDF_DOC doc, int pageno1, int pageno2 );

/**
 *	@brief	remove page by page NO.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	pageno 	0 based page NO.
 *
 *	@return	true or false
 */
bool Document_removePage( PDF_DOC doc, int pageno );
/**
 *	@brief	create an image from JPEG/JPG file.
 *          supported image color space:
 *          --GRAY
 *          --RGB
 *          --CMYK
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	path 	path to JPEG file
 *
 *	@return	DocImage object or null.
 */
PDF_DOC_IMAGE Document_newImageJPEG( PDF_DOC doc, const char *path );
/**
 *	@brief	create an image from JPX/JPEG 2k file.
 *          a premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_open
 *	@param 	path 	path to JPX file.
 *
 *	@return	DocImage object or null.
 */
PDF_DOC_IMAGE Document_newImageJPX( PDF_DOC doc, const char *path );

bool Page_getCropBox( PDF_PAGE page, PDF_RECT *box );
bool Page_getMediaBox( PDF_PAGE page, PDF_RECT *box );
/**
 *	@brief	close page.
 *
 *	@param 	page 	returned from Document_getPage
 */
void Page_close( PDF_PAGE page );
bool Page_renderThumb(PDF_PAGE page, PDF_DIB dib);
/**
 *	@brief	reset status and erase wihite for dib.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	dib 	returned from Global_dibGet
 */
void Page_renderPrepare( PDF_PAGE page, PDF_DIB dib );
/**
 *	@brief	render page to dib.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	dib 	returned from Global_dibGet
 *	@param 	matrix 	returned from Matrix_create or Matrix_createScale
 *	@param 	show_annots 	show annotations?
 *	@param 	mode 	render mode.
 *
 *	@return	true or false.
 */
bool Page_render( PDF_PAGE page, PDF_DIB dib, PDF_MATRIX matrix, bool show_annots, PDF_RENDER_MODE mode );

/**
 *	@brief	cancel render, in mostly, this function called by UI thread, and Page_render called by another thread.
 *
 *	@param 	page 	returned from Document_getPage
 */
void Page_renderCancel( PDF_PAGE page );
/**
 *	@brief	check if page render finished.
 *
 *	@param 	page 	returned from Document_getPage
 *
 *	@return	true or false.
 */
bool Page_renderIsFinished( PDF_PAGE page );
int Page_getRotate(PDF_PAGE page);
bool Page_flate(PDF_PAGE page);
/**
 *	@brief	load all objects in page.
 *
 *	@param 	page 	returned from Document_getPage
 */
void Page_objsStart( PDF_PAGE page );
/**
 *	@brief	get chars count.
            to invoke this function, developers should call Page_objsStart before.
 *	@param 	page 	returned from Document_getPage
 *
 *	@return	count of chars.
 */
int Page_objsGetCharCount( PDF_PAGE page );
/**
 *	@brief	get string by index range.
            to invoke this function, developers should call Page_objsStart before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	from 	from index, range: [0, Page_objsGetCharCount() - 1]
 *	@param 	to 	    to index, range: [0, Page_objsGetCharCount() - 1]
 *	@param 	buf 	output value: string value
 *	@param 	len 	buffer length.
 *
 *	@return	count of chars.
 */
int Page_objsGetString( PDF_PAGE page, int from, int to, char *buf, int len );
/**
 *	@brief	get area rect of char.
            to invoke this function, developers should call Page_objsStart before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	index 	range: [0, Page_objsGetCharCount() - 1]
 *	@param 	rect 	output value: rect in PDF coordinate
 */
void Page_objsGetCharRect( PDF_PAGE page, int index, PDF_RECT *rect );
/**
 *	@brief	get char's font name. this can be invoked after ObjsStart
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	index 	0 based unicode index.
 *
 *	@return	font name, may be null.
 */
const char *Page_objsGetCharFontName( PDF_PAGE page, int index );
/**
 *	@brief	get char index nearest to point
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	x 	x in PDF coordinate.
 *	@param 	y 	y in PDF coordinate.
 *
 *	@return	char index or -1 failed.
 */
int Page_objsGetCharIndex( PDF_PAGE page, float x, float y );
/**
 *	@brief	get index aligned by word. this can be invoked after ObjsStart
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	from 	0 based unicode index.
 *	@param 	dir 	if dir < 0, get start index of the word. otherwise get last index of the word.
 *
 *	@return	new index value.
 */
int Page_objsAlignWord( PDF_PAGE page, int from, int dir );
/**
 *	@brief	open a finder object.
            to invoke this function, developers should call Page_objsStart before.
 *
 *	@param 	page 	    returned from Document_getPage
 *	@param 	str 	    string to find.
 *	@param 	match_case 	match case?
 *	@param 	whole_word 	whole word?
 *
 *	@return	finder object ot NULL if not found.
 */
PDF_FINDER Page_findOpen( PDF_PAGE page, const char *str, bool match_case, bool whole_word );
/**
 *	@brief	how many found?
            to invoke this function, developers should call Page_objsStart before.
 *
 *	@param 	finder 	finder	returned from Page_findOpen
 *	@return	0 if no found, otherwise, count of founds.
 */
int Page_findGetCount( PDF_FINDER finder );
/**
 *	@brief	get char index in page, by find index.
            to invoke this function, developers should call Page_objsStart before.
 *
 *	@param 	finder 	returned from Page_findOpen
 *	@param 	index 	find index, range: [0, Page_findGetCount() - 1].
 *
 *	@return	char index in page, range: [0, Page_objsGetCharCount() - 1].
 */
int Page_findGetFirstChar( PDF_FINDER finder, int index );
/**
 *	@brief	close finder
            to invoke this function, developers should call Page_objsStart before.
 *
 *	@param 	finder 	finder	returned from Page_findOpen
 */
void Page_findClose( PDF_FINDER finder );
/**
 *	@brief	get count of annotations.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page returned from Document_getPage
 *
 *	@return	count of annotations.
 */
int Page_getAnnotCount( PDF_PAGE page );
/**
 *	@brief	get annotation by index.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	index 	0 based index, range: [0, Page_getAnnotCount() - 1].
 *
 *	@return	annotation object or NULL.
 */
PDF_ANNOT Page_getAnnot( PDF_PAGE page, int index );
/**
 *	@brief	get annotation by point.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	x 	x of point, in PDF coordinate
 *	@param 	y 	y of point, in PDF coordinate
 *
 *	@return	annotation object or NULL.
 */
PDF_ANNOT Page_getAnnotFromPoint( PDF_PAGE page, float x, float y );
int Page_getAnnotSignStatus(PDF_PAGE page, PDF_ANNOT annot);
/**
 *	@brief	is annotation locked?
 *          to invoke this function, developers should call Page_objsStart or Page_render before.
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return		true or false.
 */
bool Page_isAnnotLocked( PDF_PAGE page, PDF_ANNOT annot );
void Page_setAnnotLock( PDF_PAGE page, PDF_ANNOT annot, bool lock );
bool Page_isAnnotReadonly(PDF_PAGE page, PDF_ANNOT annot);
void Page_setAnnotReadonly(PDF_PAGE page, PDF_ANNOT annot, bool lock);

/**
 *	@brief	is annotation locked?
 *          to invoke this function, developers should call Page_objsStart or Page_render before.
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return		true or false.
 */
bool Page_isAnnotLockedContent( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	is annotation hided?
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	true or false
 */
bool Page_isAnnotHide( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	set annotation hided
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	hide 	true or false
 */
void Page_setAnnotHide( PDF_PAGE page, PDF_ANNOT annot, bool hide );
/**
 *	@brief	get annotation type.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	type as these values:
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
 *          26: rich media
 */
int Page_getAnnotType( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	get annotation field type in acroForm.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	type as these values:
 *          0: unknown
 *          1: button field
 *          2: text field
 *          3: choice field
 *          4: signature field
 */
int Page_getAnnotFieldType( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief get field name of this annotation.
 *			a premium license is needed for this function.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param	buf		buffer to fill names in UTF-8 coding.
 *	@param	buf_size	size of buffer that allocated.
 *	@return	name of this annotation, like: "EditBox1[0]"
 */
int Page_getAnnotFieldName( PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size );
int Page_getAnnotFieldNameWithNO(PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size);
/**
 *	@brief get field full name of this annotation.
 *			a premium license is needed for this function.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param	buf		buffer to fill names in UTF-8 coding.
 *	@param	buf_size	size of buffer that allocated.
 *	@return	name of this annotation, like: "form1.EditBox1"
 */
int Page_getAnnotFieldFullName( PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size );
/**
 *	@brief get field full name of this annotation with more details.
 *			a premium license is needed for this function.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param	buf		buffer to fill names in UTF-8 coding.
 *	@param	buf_size	size of buffer that allocated.
 *	@return	name of this annotation, like: "form1[0].EditBox1[0]"
 */
int Page_getAnnotFieldFullName2( PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size );
/**
 *	@brief	get annotation rect.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	rect 	rect of annotation area, in PDF coordinate.
 */
void Page_getAnnotRect( PDF_PAGE page, PDF_ANNOT annot, PDF_RECT *rect );
/**
 *	@brief	set annotation rect.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	rect 	rect of annotation area, in PDF coordinate.
 */
void Page_setAnnotRect( PDF_PAGE page, PDF_ANNOT annot, const PDF_RECT *rect );
PDF_PATH Page_getAnnotInkPath( PDF_PAGE page, PDF_ANNOT annot );
bool Page_setAnnotInkPath( PDF_PAGE page, PDF_ANNOT annot, PDF_PATH path );
PDF_PATH Page_getAnnotPolygonPath( PDF_PAGE page, PDF_ANNOT annot );
bool Page_setAnnotPolygonPath( PDF_PAGE page, PDF_ANNOT annot, PDF_PATH path );
PDF_PATH Page_getAnnotPolylinePath( PDF_PAGE page, PDF_ANNOT annot );
bool Page_setAnnotPolylinePath( PDF_PAGE page, PDF_ANNOT annot, PDF_PATH path );

/**
 *	@brief	get annotation fill color
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	RGB color
 */
int Page_getAnnotFillColor( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	set annotation fill color
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	color 	RGB color
 *
 *	@return	true or false
 */
bool Page_setAnnotFillColor( PDF_PAGE page, PDF_ANNOT annot, int color );
/**
 *	@brief	get annotation stroke color
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	RGB color
 */
int Page_getAnnotStrokeColor( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	set annotation stroke color
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	color 	RGBA color
 *
 *	@return	true or false
 */
bool Page_setAnnotStrokeColor( PDF_PAGE page, PDF_ANNOT annot, int color );
/**
 *	@brief	get annot stroke width
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	stroke width
 */
float Page_getAnnotStrokeWidth( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	set annot stroke width
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	width 	stroke width
 *
 *	@return	true or false
 */
bool Page_setAnnotStrokeWidth( PDF_PAGE page, PDF_ANNOT annot, float width );
/**
 *	@brief	set icon for sticky text note/file attachment annotation.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          you need render page again to show modified annotation.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	icon 	icon value depends on annotation type.
 *                  For sticky text note:
 *                  0: Note
 *                  1: Comment
 *                  2: Key
 *                  3: Help
 *                  4: NewParagraph
 *                  5: Paragraph
 *                  6: Insert
 *                  7: Check
 *                  8: Circle
 *                  9: Cross
 *                  For file attachment:
 *                  0: PushPin
 *                  1: Graph
 *                  2: Paperclip
 *                  3: Tag
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
 *	@return	true or false
 */
bool Page_setAnnotIcon( PDF_PAGE page, PDF_ANNOT annot, int icon );
/**
 *	@brief	get icon value for sticky text note/file attachment/Rubber Stamp annotation.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	icon value depends on annotation type.
 *          For sticky text note:
 *          0: Note
 *          1: Comment
 *          2: Key
 *          3: Help
 *          4: NewParagraph
 *          5: Paragraph
 *          6: Insert
 *          7: Check
 *          8: Circle
 *          9: Cross
 *          For file attachment:
 *          0: PushPin
 *          1: Graph
 *          2: Paperclip
 *          3: Tag
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
int Page_getAnnotIcon( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	get annotation's goto page action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	-1 if failed or 0 based page NO.
 */
int Page_getAnnotDest( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief		get annotation's goto URI action.
 to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	uri 	output value: uri buffer to recieve uri address
 *	@param 	len 	buffer length.
 *
 *	@return	length of uri, or 0.
 */
int Page_getAnnotURI( PDF_PAGE page, PDF_ANNOT annot, char *uri, int len );
NSString *Page_getAnnotJS(PDF_PAGE page, PDF_ANNOT annot);
/**
 *	@brief	get annotation's 3D play action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	f3d 	file name of 3d data, must in ".u3d" format.
 *	@param 	len 	buffer length.
 *
 *	@return	length of f3d, or 0.
 */
int Page_getAnnot3D( PDF_PAGE page, PDF_ANNOT annot, char *f3d, int len );
/**
 *	@brief	get annotation's movie play action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	mov 	file name of movie data.
 *	@param 	len 	buffer length.
 *
 *	@return	length of mov, or 0.
 */
int Page_getAnnotMovie( PDF_PAGE page, PDF_ANNOT annot, char *mov, int len );
/**
 *	@brief	get annotation's audio play action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	snd 	file name of audio data.
 *	@param 	len 	buffer length.
 *
 *	@return	length of snd, or 0.
 */
int Page_getAnnotSound( PDF_PAGE page, PDF_ANNOT annot, char *snd, int len );
/**
 *	@brief	get annotation's attachment open action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	att 	file name of attachment data.
 *	@param 	len 	buffer length.
 *
 *	@return	length of att, or 0.
 */
int Page_getAnnotAttachment( PDF_PAGE page, PDF_ANNOT annot, char *att, int len );
/**
 *	@brief	get data of annotation's 3D open action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	path 	file to save.
 *
 *	@return	true or false.
 */
bool Page_getAnnot3DData( PDF_PAGE page, PDF_ANNOT annot, const char *path );
/**
 *	@brief	get data of annotation's movie open action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	path 	file to save.
 *
 *	@return	true or false.
 */
bool Page_getAnnotMovieData( PDF_PAGE page, PDF_ANNOT annot, const char *path );
/**
 *	@brief	get data of annotation's Audio open action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	paras 	4 element parameters, if paras[0] == 0, means the data is formatted audio, for example( *.mp3 )
                    otherwize it is raw sound data.
 *	@param 	path 	file to save.
 *
 *	@return	true or false.
 */
bool Page_getAnnotSoundData( PDF_PAGE page, PDF_ANNOT annot, int *paras, const char *path );
/**
 *	@brief	get data of annotation's attachment open action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	path 	file to save.
 *
 *	@return	true or false.
 */
bool Page_getAnnotAttachmentData( PDF_PAGE page, PDF_ANNOT annot, const char *path );
PDF_ANNOT Page_getAnnotPopup(PDF_PAGE page, PDF_ANNOT annot);
bool Page_getAnnotPopupOpen(PDF_PAGE page, PDF_ANNOT annot);
bool Page_setAnnotPopupOpen(PDF_PAGE page, PDF_ANNOT annot, bool open);
/**
 *	@brief	get subject of popup text annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	subj 	output value: subject string buffer.
 *	@param 	len 	buffer length.
 *
 *	@return	true or false.
 */
bool Page_getAnnotPopupSubject( PDF_PAGE page, PDF_ANNOT annot, char *subj, int len );
/**
 *	@brief	set subject of popup text annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	subj 	subject string.
 *
 *	@return	true or false
 */
bool Page_setAnnotPopupSubject( PDF_PAGE page, PDF_ANNOT annot, const char *subj );
/**
 *	@brief	get text of popup text annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	text 	output value: text string buffer.
 *	@param 	len 	buffer length.
 *
 *	@return	true or false.
 */
bool Page_getAnnotPopupText( PDF_PAGE page, PDF_ANNOT annot, char *text, int len );
/**
 *	@brief	set text of popup text annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	text 	text string
 *
 *	@return	true or false
 */
bool Page_setAnnotPopupText( PDF_PAGE page, PDF_ANNOT annot, const char *text );
/**
 *	@brief	get text of popup label annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	text 	output value: text string buffer.
 *	@param 	len 	buffer length.
 *
 *	@return	true or false.
 */
bool Page_getAnnotPopupLabel( PDF_PAGE page, PDF_ANNOT annot, char *text, int len );
/**
 *	@brief	set text of popup label annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	text 	text string
 *
 *	@return	true or false
 */
bool Page_setAnnotPopupLabel( PDF_PAGE page, PDF_ANNOT annot, const char *text );
/**
 *	@brief	get type of edit-box, may either in free-text annotation and widget annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return -1: this annotation is not text-box.
             1:  normal single line.
             2:  password.
             3:  MultiLine edit area.
 */
int Page_getAnnotEditType( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	get rect area of edit-box, may either for free-text annotation and widget annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	rect 	output value: rect of edit box.
 *
 *	@return	true or false.
 */
bool Page_getAnnotEditTextRect( PDF_PAGE page, PDF_ANNOT annot, PDF_RECT *rect );
/**
 *	@brief	get text size of edit-box, may either for free-text annotation and widget annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	text size in PDF coordinate.
 */
float Page_getAnnotEditTextSize( PDF_PAGE page, PDF_ANNOT annot );
bool Page_getAnnotEditTextFormat( PDF_PAGE page, PDF_ANNOT annot, char *text, int len );

/**
 *	@brief	get text of edit-box, may either for free-text annotation and widget annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	text 	output value: text string buffer
 *	@param 	len 	buffer length
 *
 *	@return	true or false
 */
bool Page_getAnnotEditText( PDF_PAGE page, PDF_ANNOT annot, char *text, int len );
/**
 *	@brief	set text of edit-box, may either for free-text annotation and widget annotation.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	text 	text string
 *
 *	@return	true or false
 */
bool Page_setAnnotEditText( PDF_PAGE page, PDF_ANNOT annot, const char *text );
bool Page_setAnnotEditFont(PDF_PAGE page, PDF_ANNOT annot, PDF_DOC_FONT font);
int Page_getAnnotEditTextColor(PDF_PAGE page, PDF_ANNOT annot);
bool Page_setAnnotEditTextColor(PDF_PAGE page, PDF_ANNOT annot, int color);

/**
 *	@brief	add an edit-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage.
 *	@param 	rect 	rect in PDF coordinate.
 *	@param	line_clr border color of editbox.
 *	@param	line_w border width of editbox.
 *	@param	fill_clr background of editbox.
 *	@param 	tsize 	text size of the editbox.
 *	@param 	color_clr text color.
 *
 *	@return	true or false
 */
bool Page_addAnnotEditbox2( PDF_PAGE page, const PDF_RECT *rect, int line_clr, float line_w, int fill_clr, float tsize, int text_clr );

/**
 *	@brief	add an edit-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage.
 *	@param 	matrix 	matrix object that passed to render.
 *	@param 	rect 	rect in PDF coordinate.
 *	@param	line_clr border color of editbox.
 *	@param	line_w border width of editbox.
 *	@param	fill_clr background of editbox.
 *	@param 	tsize 	text size of the editbox.
 *	@param 	color_clr text color.
 *
 *	@return	true or false
 */
bool Page_addAnnotEditbox( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, int line_clr, float line_w, int fill_clr, float tsize, int text_clr );
/**
 *	@brief	get items count in combo-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	-1: this is not combo. otherwise: items count.
 */
int Page_getAnnotComboItemCount( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	get item text by index.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	item 	0 based item index, range: [0, Page_getAnnotComboItemCount() - 1]
 *	@param 	val 	output buffer: text string buffer
 *	@param 	len 	buffer length
 *
 *	@return	true or false
 */
bool Page_getAnnotComboItem( PDF_PAGE page, PDF_ANNOT annot, int item, char *val, int len );
/**
 *	@brief	get index of selected item.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	item index selected.
 */
int Page_getAnnotComboItemSel( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	set selected item.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	item 	index of item.
 *
 *	@return	true or false.
 */
bool Page_setAnnotComboItem( PDF_PAGE page, PDF_ANNOT annot, int item );

/**
 *	@brief	get items count in list-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	-1: this is not list-box. otherwise: items count.
 */
int Page_getAnnotListItemCount( PDF_PAGE page, PDF_ANNOT annot );

/**
 *	@brief	get item text by index.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	item 	0 based item index, range: [0, Page_getAnnotListItemCount() - 1]
 *	@param 	buf 	output buffer: text string buffer
 *	@param 	buf_len	buffer length
 *
 *	@return	true or false
 */
bool Page_getAnnotListItem( PDF_PAGE page, PDF_ANNOT annot, int item, char *buf, int buf_len );
/**
 *	@brief	get selected items of list-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page		page object returned from Document_getPage
 *	@param 	annot		annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param  sels		int array to revieve selected items.
 *  @param  sels_max	array length.
 *
 *	@return	the count that filled in int array.
 */
int Page_getAnnotListSels( PDF_PAGE page, PDF_ANNOT annot, int *sels, int sels_max );
/**
 *	@brief	set selected items of list-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page		page object returned from Document_getPage
 *	@param 	annot		annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param  sels		int array to set selected items.
 *  @param  sels_cnt	array length.
 *
 *	@return	the count that filled in int array.
 */
bool Page_setAnnotListSels( PDF_PAGE page, PDF_ANNOT annot, const int *sels, int sels_cnt );

/**
 *	@brief	get radio or check-box check status.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	-1 if annotation is not valid control.
             0 if check-box is not checked.
             1 if check-box checked.
             2 if radio-box is not checked.
             3 if radio-box checked.
 */
int Page_getAnnotCheckStatus( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	set value to check-box.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	check 	check status.
 *
 *	@return	true or false.
 */
bool Page_setAnnotCheckValue( PDF_PAGE page, PDF_ANNOT annot, bool check );
/**
 *	@brief	set value to radio-box, and deselect all other radio-box in radio-group.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	true or false.
 */
bool Page_setAnnotRadio( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	is this annotation reset button?
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	true or false.
 */
bool Page_getAnnotReset( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	do reset action.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	true or false.
 */
bool Page_setAnnotReset( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	get submit target link.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	tar 	output value: target string buffer.
                    may either formatted in: "mailto:..." or "http://...".
 *	@param 	len 	buffer length.
 *
 *	@return	true or false.
 */
bool Page_getAnnotSubmitTarget( PDF_PAGE page, PDF_ANNOT annot, char *tar, int len );
/**
 *	@brief	get submit parameters.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in premium license.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *	@param 	para 	output value: parameters string buffer.
                    in mail mode: return whole XML string for form data.
                    in http mode: url data likes: "para1=xxx&para2=xxx".
 *	@param 	len 	buffer length.
 *
 *	@return	true or false.
 */
bool Page_getAnnotSubmitPara( PDF_PAGE page, PDF_ANNOT annot, char *para, int len );

bool Page_moveAnnot( PDF_PAGE page_src, PDF_PAGE page_dst, PDF_ANNOT annot, const PDF_RECT *rect );
bool Page_copyAnnot( PDF_PAGE page, PDF_ANNOT annot, const PDF_RECT *rect );

/**
 *	@brief	remove annotation
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	annot 	annotation object returned from Page_getAnnot or Page_getAnnotFromPoint
 *
 *	@return	true or false.
 */
bool Page_removeAnnot( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	add ink annotation to page.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	 Matrix object passed to Page_render
 *	@param 	hand 	Ink object returned from Ink_create.
 *	@param 	orgx 	x or origin, in DIB coordinate
 *	@param 	orgy 	y or origin, in DIB coordinate
 *
 *	@return	true or false.
 */
bool Page_addAnnotInk( PDF_PAGE page, PDF_MATRIX matrix, PDF_INK hand, float orgx, float orgy );

/**
 *	@brief	add ink annotation to page.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	hand 	Ink object returned from Ink_create, must in PDF coordinate.
 *
 *	@return	true or false.
 */
bool Page_addAnnotInk2( PDF_PAGE page, PDF_INK hand );
/**
 *	@brief	add goto-page link to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version

 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	rect 	link area rect [left, top, right, bottom] in DIB coordinate.
 *	@param 	pageno 	 0 based pageno to goto.
 *	@param 	top 	y coordinate in PDF coordinate, page.height is top of page. and 0 is bottom of page.
 *
 *	@return	true or false
 */
bool Page_addAnnotGoto( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, int pageno, float top );
/**
 *	@brief	add goto-page link to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version

 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	rect 	link area rect [left, top, right, bottom] in PDF coordinate.
 *	@param 	pageno 	 0 based pageno to goto.
 *	@param 	top 	y coordinate in PDF coordinate, page.height is top of page. and 0 is bottom of page.
 *
 *	@return	true or false
 */
bool Page_addAnnotGoto2( PDF_PAGE page, const PDF_RECT *rect, int pageno, float top );
/**
 *	@brief	add URL link to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	rect 	link area rect [left, top, right, bottom] in DIB coordinate.
 *	@param 	uri 	url address, example: "http://www.radaee.com/en"
 *
 *	@return	true or false
 */
bool Page_addAnnotUri( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, const char *uri );
/**
 *	@brief	add URL link to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	rect 	link area rect [left, top, right, bottom] in PDF coordinate.
 *	@param 	uri 	url address, example: "http://www.radaee.com/en"
 *
 *	@return	true or false
 */
bool Page_addAnnotURI2( PDF_PAGE page, const PDF_RECT *rect, const char *uri );

/**
 *	@brief	add line to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	pt1 	start point, 2 elements for x,y, in DIB coordinate
 *	@param 	pt2 	end point, 2 elements for x,y, in DIB coordinate
 *	@param 	style1 	tyle for start point:
 *          0: None
 *          1: Arrow
 *          2: Closed Arrow
 *          3: Square
 *          4: Circle
 *          5: Butt
 *          6: Diamond
 *          7: Reverted Arrow
 *          8: Reverted Closed Arrow
 *          9: Slash
 *	@param 	style2 	style for end point, values are same as style1.
 *	@param 	width 	line width in DIB coordinate
 *	@param 	color 	line color. same as addAnnotRect.
 *	@param 	icolor 	fill color. same as addAnnotRect.
 *
 *	@return	true or false
 */
bool Page_addAnnotLine( PDF_PAGE page, PDF_MATRIX matrix, const PDF_POINT *pt1, const PDF_POINT *pt2, int style1, int style2, float width, int color, int icolor );
/**
 *	@brief	add line to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	pt1 	start point, 2 elements for x,y, in PDF coordinate
 *	@param 	pt2 	end point, 2 elements for x,y, in PDF coordinate
 *	@param 	style1 	tyle for start point:
 *          0: None
 *          1: Arrow
 *          2: Closed Arrow
 *          3: Square
 *          4: Circle
 *          5: Butt
 *          6: Diamond
 *          7: Reverted Arrow
 *          8: Reverted Closed Arrow
 *          9: Slash
 *	@param 	style2 	style for end point, values are same as style1.
 *	@param 	width 	line width in PDF coordinate
 *	@param 	color 	line color. same as addAnnotRect.
 *	@param 	icolor 	fill color. same as addAnnotRect.
 *
 *	@return	true or false
 */
bool Page_addAnnotLine2( PDF_PAGE page, const PDF_POINT *pt1, const PDF_POINT *pt2, int style1, int style2, float width, int color, int icolor );
/**
 *	@brief	add rect annotation to page.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	rect 	rect in DIB coordinate
 *	@param 	width 	line width in DIB coordinate
 *	@param 	color 	RGB value for rect color
 *	@param 	icolor 	fill color. same as addAnnotRect.
 *
 *	@return	true or false
 */
bool Page_addAnnotRect( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *	@brief	add rect annotation to page.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	rect 	rect in PDF coordinate
 *	@param 	width 	line width in PDF coordinate
 *	@param 	color 	RGB value for rect color
 *	@param 	icolor 	fill color. same as addAnnotRect.
 *
 *	@return	true or false
 */
bool Page_addAnnotRect2( PDF_PAGE page, const PDF_RECT *rect, float width, int color, int icolor );

/**
 *	@brief	add ellipse annotation to page.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	rect 	rect in DIB coordinate
 *	@param 	width 	line width in DIB coordinate
 *	@param 	color 	RGB value for rect color
 *	@param 	icolor 	fill color. same as addAnnotRect.
 *
 *	@return	true or false
 */
bool Page_addAnnotEllipse( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *	@brief	add ellipse annotation to page.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	rect 	rect in PDF coordinate
 *	@param 	width 	line width in PDF coordinate
 *	@param 	color 	RGB value for rect color
 *	@param 	icolor 	fill color. same as addAnnotRect.
 *
 *	@return	true or false
 */
bool Page_addAnnotEllipse2( PDF_PAGE page, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *	@brief	add popup text annotation to page. shows as an text note icon.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	x 	x in DIB coordinate.
 *	@param 	y 	y in DIB coordinate.
 *
 *	@return	true or false
 */
bool Page_addAnnotText( PDF_PAGE page, PDF_MATRIX matrix, float x, float y );
/**
 *	@brief	add popup text annotation to page. shows as an text note icon.
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	x 	x in PDF coordinate.
 *	@param 	y 	y in PDF coordinate.
 *
 *	@return	true or false
 */
bool Page_addAnnotText2( PDF_PAGE page, float x, float y );
/**
 *	@brief	add bitmap annotation to page
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	bitmap 	bitmap data, must be in RGBA color space.
 *	@param 	has_alpha 	need generate alpha values for bitmap?
 *	@param 	rect 	rect in PDF coordinate.
 *
 *	@return	true or false
 */
bool Page_addAnnotBitmap( PDF_PAGE page, PDF_MATRIX matrix, CGImageRef bitmap, bool has_alpha, const PDF_RECT *rect );
bool Page_addAnnotBitmap2( PDF_PAGE page, CGImageRef bitmap, bool has_alpha, const PDF_RECT *rect );
bool Page_addAnnotPopup(PDF_PAGE page, PDF_ANNOT parent, const PDF_RECT *rect, bool open);
/**
 *	@brief	add a text-markup annotation to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	index1 	first char index
 *	@param 	index2 	second char index
 *	@param 	color 	RGB value
 *	@param 	type 	type as following:
 *                  0: Highlight
 *                  1: Underline
 *                  2: StrikeOut
 *                  3: Highlight without round corner
 *                  4: Squiggly underline.
 *
 *	@return	true or false
 */
bool Page_addAnnotMarkup2( PDF_PAGE page, int index1, int index2, int color, int type );
int Page_getAnnotMarkupRects(PDF_PAGE page, PDF_ANNOT annot, PDF_RECT *rects, int cnt);

/**
 *	@brief	add bitmap annotation to page
            to invoke this function, developers should call Page_objsStart or Page_render before.
            this function valid in professional or premium license.
            you should re-render page to display modified data
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	matrix 	Matrix object passed to Page_render
 *	@param 	bitmap 	bitmap data, must be in RGBA color space
 *	@param 	has_alpha 	need generate alpha values for bitmap?
 *	@param 	rect 	rect in PDF coordinate.
 *
 *	@return	true or false
 */
bool Page_addBitmap( PDF_PAGE page, PDF_MATRIX matrix, CGImageRef bitmap, bool has_alpha, const PDF_RECT *rect );
	/**
	 * @brief	add an Rubber Stamp to page.
	 *		you should re-render page to display modified data.
	 *		this can be invoked after ObjsStart or Render or RenderToBmp.
	 *		this method valid in professional or premium version
	 *	@param rect icon area rect [left, top, right, bottom] in PDF coordinate.
	 *	@param icon predefined value as below:
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
bool Page_addAnnotStamp( PDF_PAGE page, const PDF_RECT *rect, int icon );

/**
 *	@brief	add a file as an attachment to page.
 *          you should re-render page to display modified data.
 *          this can be invoked after ObjsStart or Render or RenderToBmp.
 *          this method valid in professional or premium version
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	path 	absolute path name to the file.
 *	@param 	icon 	icon display to the page. values as:
 *                  0: PushPin
 *                  1: Graph
 *                  2: Paperclip
 *                  3: Tag
 *	@param 	rect 	4 elements: left, top, right, bottom in PDF coordinate system.
 *
 *	@return	true or false
 */
bool Page_addAnnotAttachment( PDF_PAGE page, const char *path, int icon, const PDF_RECT *rect );

/**
 *	@brief	create ink object for hand-writing
 *
 *	@param 	line_w 	line width
 *	@param 	color 	RGB value for ink color
 *
 *	@return	Ink object
 */
PDF_INK Ink_create( float line_w, int color );
/**
 *	@brief	destroy Ink object
 *
 *	@param 	ink 	Ink object returned from Ink_create
 */
void Ink_destroy( PDF_INK ink );
/**
 *	@brief	invoked when touch-down.
 *
 *	@param 	ink Ink object returned from Ink_create
 *	@param 	x 	x position
 *	@param 	y 	y position
 */
void Ink_onDown( PDF_INK ink, float x, float y );
/**
 *	@brief	invoked when touch-moving.
 *
 *	@param 	ink 	Ink object returned from Ink_create
 *	@param 	x 	x positon
 *	@param 	y 	y position
 */
void Ink_onMove( PDF_INK ink, float x, float y );
/**
 *	@brief	invoked when touch-up.
 *
 *	@param 	ink 	Ink object returned from Ink_create
 *	@param 	x 	x position
 *	@param 	y 	y position
 */
void Ink_onUp( PDF_INK ink, float x, float y );
/**
 *	@brief	get node count for ink.
 *
 *	@param 	ink 	Ink object returned from Ink_create
 *
 *	@return	nodes count
 */
int Ink_getNodeCount( PDF_INK ink );
/**
 *	@brief	get node by index
 *
 *	@param 	hand 	Ink object returned from Ink_create
 *	@param 	index 	0 based index, range: [0, Ink_getNodeCount() - 1]
 *	@param 	pt 	position pointer
 *
 *	@return	type of node:
            0: move to
            1: line to
            2: cubic bezier to.
 */
int Ink_getNode( PDF_INK hand, int index, PDF_POINT *pt );

/**
 *	@brief	create a contour
 *
 *	@return	PDF_PATH object
 */
PDF_PATH Path_create();
/**
 *	@brief	move to operation
 *
 *	@param 	path 	path create by Path_create()
 *	@param 	x 	x value
 *	@param 	y 	y value
 */
void Path_moveTo( PDF_PATH path, float x, float y);
/**
 *	@brief	move to operation
 *
 *	@param 	path 	path create by Path_create()
 *	@param 	x 	x value
 *	@param 	y 	y value
 *
 */
void Path_lineTo( PDF_PATH path, float x, float y);
/**
 *	@brief	curve to operation
 *
 *	@param 	path 	path create by Path_create()
 *	@param 	x1 	x1 value
 *	@param 	y1 	y1 value
 *	@param 	x2 	x2 value
 *	@param 	y2 	y2 value
 *	@param 	x3 	x3 value
 *	@param 	y3 	y3 value
 */
void Path_curveTo( PDF_PATH path, float x1, float y1, float x2, float y2, float x3, float y3 );
/**
 *	@brief	close a contour.
 *
 *	@param 	path 	path create by Path_create()
 */
void Path_closePath( PDF_PATH path );
/**
 *	@brief	free memory
 *
 *	@param 	path 	path create by Path_create()
 */
void Path_destroy( PDF_PATH path );
/**
 *	@brief	get node count
 *
 *	@param 	path path create by Path_create()
 *
 *	@return	node count
 */
int Path_getNodeCount( PDF_PATH path );
/**
 *	@brief	get each node
 *
 *	@param 	path 	path create by Path_create()
 *	@param 	index 	range [0, GetNodeCount() - 1]
 *	@param 	pt 	output value: 2 elements coordinate point
 *
 *	@return	node type:
 *          0: move to
 *          1: line to
 *          3: curve to, index, index + 1, index + 2 are all data
 *          4: close operation
 */
int Path_getNode( PDF_PATH path, int index, PDF_POINT *pt );

/**
 *	@brief	create PAGECONTENT
 *
 *	@return	PDF_PAGECONTENT object
 */
PDF_PAGECONTENT PageContent_create();
/**
 *	@brief	PDF operator: gs_save, save current GraphicState
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 */
void PageContent_gsSave( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: gs_restore, restore GraphicState
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 */
void PageContent_gsRestore( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: set ExtGraphicState
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	gs 	ResGState object created by Page.AddResGState()
 */
void PageContent_gsSet( PDF_PAGECONTENT content, PDF_PAGE_GSTATE gs );
/**
 *	@brief	PDF operator: set matrix.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	mat 	Matrix object
 */
void PageContent_gsSetMatrix( PDF_PAGECONTENT content, PDF_MATRIX mat );
/**
 *	@brief	PDF operator: begin text and set text position to (0,0).
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 */
void PageContent_textBegin( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: text end.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 */
void PageContent_textEnd( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: show image.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	img 	 image object created by Page.AddResImage()
 */
void PageContent_drawImage( PDF_PAGECONTENT content, PDF_PAGE_IMAGE img );
void PageContent_drawForm(PDF_PAGECONTENT content, PDF_PAGE_FORM form);
/**
 *	@brief	show text
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	text 	 text to show, '\r' or '\n' in string start a new line.
 */
void PageContent_drawText( PDF_PAGECONTENT content, const char *text );
/**
 *	@brief	stroke path.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	path 	Path object
 */
void PageContent_strokePath( PDF_PAGECONTENT content, PDF_PATH path );
/**
 *	@brief	fill path.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	path 	Path object
 *	@param 	winding 	winding fill rule
 */
void PageContent_fillPath( PDF_PAGECONTENT content, PDF_PATH path, bool winding );
/**
 *	@brief	set the path as clip path.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	path 	Path object
 *	@param 	winding 	winding fill rule?
 */
void PageContent_clipPath( PDF_PAGECONTENT content, PDF_PATH path, bool winding );
/**
 *	@brief	PDF operator: set fill and other operations color.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	color 	formatted as 0xRRGGBB, no alpha channel. alpha value shall set by ExtGraphicState(ResGState).
 */
void PageContent_setFillColor( PDF_PAGECONTENT content, int color );
/**
 *	@brief	PDF operator: set stroke color.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	color 	formatted as 0xRRGGBB, no alpha channel. alpha value shall set by ExtGraphicState(ResGState).
 */
void PageContent_setStrokeColor( PDF_PAGECONTENT content, int color );
/**
 *	@brief	PDF operator: set line cap
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	cap 	0:butt, 1:round: 2:square
 */
void PageContent_setStrokeCap( PDF_PAGECONTENT content, int cap );
/**
 *	@brief	PDF operator: set line join
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	join 	0:miter, 1:round, 2:bevel
 */
void PageContent_setStrokeJoin( PDF_PAGECONTENT content, int join );
/**
 *	@brief	PDF operator: set line width
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	w 	line width in PDF coordinate
 */
void PageContent_setStrokeWidth( PDF_PAGECONTENT content, float w );
/**
 *	@brief	PDF operator: set miter limit.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	miter 	 miter limit.
 */
void PageContent_setStrokeMiter( PDF_PAGECONTENT content, float miter );
/**
 *	@brief	PDF operator: set char space(extra space between chars)
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	space 	char space
 */
void PageContent_textSetCharSpace( PDF_PAGECONTENT content, float space );
/**
 *	@brief	PDF operator: set word space(extra space between words spit by blank char ' ' ).
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	space 	word space.
 */
void PageContent_textSetWordSpace( PDF_PAGECONTENT content, float space );
/**
 *	@brief	PDF operator: set text leading, height between 2 text lines.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	leading 	leading in PDF coordinate
 */
void PageContent_textSetLeading( PDF_PAGECONTENT content, float leading );
/**
 *	@brief	PDF operator: set text rise
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	rise 	<#rise description#>
 */
void PageContent_textSetRise( PDF_PAGECONTENT content, float rise );
/**
 *	@brief	PDF operator: set horizon scale for chars.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	scale 	100 means scale value 1.0f
 */
void PageContent_textSetHScale( PDF_PAGECONTENT content, int scale );
/**
 *	@brief	PDF operator: new a text line
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 */
void PageContent_textNextLine( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: move text position relative to previous line
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	x 	in PDF coordinate add to previous line position
 *	@param 	y 	in PDF coordinate add to previous line position
 */
void PageContent_textMove( PDF_PAGECONTENT content, float x, float y );
/**
 *	@brief	set text font
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	font 	ResFont object created by Page.AddResFont()
 *	@param 	size 	text size in PDF coordinate.
 */
void PageContent_textSetFont( PDF_PAGECONTENT content, PDF_PAGE_FONT font, float size );
/**
 *	@brief	PDF operator: set text render mode.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 *	@param 	mode -
 *          0: filling
 *          1: stroke
 *          2: fill and stroke
 *          3: do nothing
 *          4: fill and set clip path
 *          5: stroke and set clip path
 *          6: fill/stroke/clip
 *          7: set clip path.
 */
void PageContent_textSetRenderMode( PDF_PAGECONTENT content, int mode );
/**
 *	@brief	destroy and free memory.
 *
 *	@param 	content PDF_PAGECONTENT create by PageContent_create()
 */
void PageContent_destroy( PDF_PAGECONTENT content );
/**
 *	@brief	add a font as resource of this page.
 *          a premium license is needed for this method.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	font 	font object created by Document.NewFontCID()
 *
 *	@return	PDF_PAGE_FONT object or null means failed
 */
PDF_PAGE_FONT Page_addResFont( PDF_PAGE page, PDF_DOC_FONT font );
/**
 *	@brief	add an image as resource of this page.
 *          a premium license is needed for this method.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	image 	image - image object created by Document.NewImage() or Document.NewImageJPEG()
 *
 *	@return	null means failed.
 */
PDF_PAGE_IMAGE Page_addResImage( PDF_PAGE page, PDF_DOC_IMAGE image );
/**
 *	@brief	add GraphicState as resource of this page.
 *          a premium license is needed for this method.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	gstate 	ExtGraphicState created by Document.NewGState()
 *
 *	@return	null means failed.
 */
PDF_PAGE_GSTATE Page_addResGState( PDF_PAGE page, PDF_DOC_GSTATE gstate );
PDF_PAGE_FORM Page_addResForm(PDF_PAGE page, PDF_DOC_FORM form);
/**
 *	@brief	add content stream to this page.
 *          a premium license is needed for this method.
 *
 *	@param 	page 	returned from Document_getPage
 *	@param 	content 	PageContent object called PageContent.create().
 *
 *	@return	true or false
 */
bool Page_addContent( PDF_PAGE page, PDF_PAGECONTENT content, bool flush );

float Page_reflowStart( PDF_PAGE page, float width,  float ratio );
bool Page_reflow( PDF_PAGE page, PDF_DIB dib, float orgx, float orgy );
int Page_reflowGetParaCount( PDF_PAGE page );
int Page_reflowGetCharCount( PDF_PAGE page, int iparagraph );
float Page_reflowGetCharWidth( PDF_PAGE page, int iparagraph, int ichar );
float Page_reflowGetCharHeight( PDF_PAGE page, int iparagraph, int ichar );
int Page_reflowGetCharColor( PDF_PAGE page, int iparagraph, int ichar );
int Page_reflowGetCharUnicode( PDF_PAGE page, int iparagraph, int ichar );
const char *Page_reflowGetCharFont( PDF_PAGE page, int iparagraph, int ichar );
void Page_reflowGetCharRect( PDF_PAGE page, int iparagraph, int ichar, PDF_RECT *rect );
bool Page_reflowGetText( PDF_PAGE page, int iparagraph1, int ichar1, int iparagraph2, int ichar2, char *buf, int buf_len );


int Obj_dictGetItemCount(PDF_OBJ hand);
const char *Obj_dictGetItemName(PDF_OBJ hand, int index);
PDF_OBJ Obj_dictGetItemByIndex(PDF_OBJ hand, int index);
PDF_OBJ Obj_dictGetItemByName(PDF_OBJ hand, const char *name);
void Obj_dictSetItem(PDF_OBJ hand, const char *name);
void Obj_dictRemoveItem(PDF_OBJ hand, const char *name);
int Obj_arrayGetItemCount(PDF_OBJ hand);
PDF_OBJ Obj_arrayGetItem(PDF_OBJ hand, int index);
void Obj_arrayAppendItem(PDF_OBJ hand);
void Obj_arrayInsertItem(PDF_OBJ hand, int index);
void Obj_arrayRemoveItem(PDF_OBJ hand, int index);
void Obj_arrayClear(PDF_OBJ hand);
bool Obj_getBoolean(PDF_OBJ hand);
void Obj_setBoolean(PDF_OBJ hand, bool v);
int Obj_getInt(PDF_OBJ hand);
void Obj_setInt(PDF_OBJ hand, int v);
float Obj_getReal(PDF_OBJ hand);
void Obj_setReal(PDF_OBJ hand, float v);
const char *Obj_getName(PDF_OBJ hand);
void Obj_setName(PDF_OBJ hand, const char *v);
const char *Obj_getAsciiString(PDF_OBJ hand);
void Obj_getTextString(PDF_OBJ hand, char *buf, int len);
unsigned char *Obj_getHexString(PDF_OBJ hand, int *len);
void Obj_setAsciiString(PDF_OBJ hand, const char *v);
void Obj_setTextString(PDF_OBJ hand, const char *v);
void Obj_setHexString(PDF_OBJ hand, unsigned char *v, int len);
PDF_OBJ_REF Obj_getReference(PDF_OBJ hand);
void Obj_setReference(PDF_OBJ hand, PDF_OBJ_REF v);
int Obj_getType(PDF_OBJ hand);
PDF_OBJ Document_advGetObj(PDF_DOC doc, PDF_OBJ_REF ref);
PDF_OBJ_REF Document_advNewIndirectObj(PDF_DOC doc);
PDF_OBJ_REF Document_advNewIndirectObjWithData(PDF_DOC doc, PDF_OBJ obj_hand);
PDF_OBJ_REF Document_advGetRef(PDF_DOC doc);
void Document_advReload(PDF_DOC doc);
PDF_OBJ_REF Document_advNewFlateStream(PDF_DOC doc, const unsigned char *source, int len);
PDF_OBJ_REF Document_advNewRawStream(PDF_DOC doc, const unsigned char *source, int len);
PDF_OBJ_REF Page_advGetAnnotRef(PDF_PAGE page, PDF_ANNOT annot);
PDF_OBJ_REF Page_advGetRef(PDF_PAGE page);
void Page_advReloadAnnot(PDF_PAGE page, PDF_ANNOT annot);
void Page_advReload(PDF_PAGE page);

#ifdef __cplusplus
}
#endif

#endif