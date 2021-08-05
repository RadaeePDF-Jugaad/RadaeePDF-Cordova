//
//  ios.h
//  RDPDFLib
//
//  Created by Steve Jobs on 12-6-22.
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
typedef struct _PDF_PAGE *PDF_PAGE;
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
typedef struct _PDF_SIGN *PDF_SIGN;
typedef unsigned long long PDF_OBJ_REF;

/**
 *	@brief	Active Standard license, this type of license can view PDF only.
 *
 *	@param 	name 	Bundle ID of Application in ios.
 *	@param 	company  Company name inputed when pruchase.
 *	@param 	mail 	Email address inputed when pruchase.
 *	@param 	serial 	Serial Number you recieved after paid.
 *
 *	@return	true or false.
 */
bool Global_activeStandard( const char *name, const char *company, const char *mail, const char *serial );

/**
 *	@brief	Active Professional license, this type of license can do some viewing and editing.
 *
 *	@param 	name 	Bundle ID of Application in ios.
 *	@param 	company  Company name inputed when pruchase.
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
 *	@param 	company  Company name inputed when pruchase.
 *	@param 	mail 	Email address inputed when pruchase.
 *	@param 	serial 	Serial Number you recieved after paid.
 *
 *	@return	true or false.
 */
bool Global_activePremium( const char *name, const char *company, const char *mail, const char *serial );
/**
 *  @brief  DEPRECATED: Get version string (timestamp)
 */
void Global_getVerString( char ret[8] );

/**
 *  @brief  Active premium license.
 *  @param company  Customer's company.
 *  @param mail  Customer's mail.
 *  @param serial  Customer's license serial value.
 *
 *  @param company  true or false.
 */
bool Global_activePremiumForVer( const char *company, const char *mail, const char *serial );

/**
 *  @brief  Active professional license.
 *  @param company  Customer's company.
 *  @param mail  Customer's mail.
 *  @param serial  Customer's license serial value.
 *
 *  @param company  true or false.
 */
bool Global_activeProfessionalForVer( const char *company, const char *mail, const char *serial );

/**
 *  @brief  Active standard license.
 *  @param company  Customer's company.
 *  @param mail  Customer's mail.
 *  @param serial  Customer's license serial value.
 *
 *  @param company  true or false.
 */
bool Global_activeStandardForVer( const char *company, const char *mail, const char *serial );
/**

 *	@brief	Load font from specified file.
 
 *	@param 	index 	Font file index.
 *	@param 	path 	Font path in SandBox.
 */
void Global_loadStdFont( int index, const char *path );
/**
 *	@brief	Save system font into a specified file.
 *
 *	@param 	fname 	Font name from ios system (for example Arial).
 *	@param 	save_file 	Full path name that save the font.
 *
 *	@return	true or false.
 */
bool Global_SaveFont( const char *fname, const char *save_file );
/**
 *	@brief	Unload font file.
 *
 *	@param 	index 	Font file index.
 */
void Global_unloadStdFont( int index );
/**

 *	@brief	Load "cmaps" folder datas. This resource defines code mapping struct.
 *
 *	@param 	cmaps 	"cmaps" folder's full path.
 *	@param 	umaps 	"umaps" folder's full path.

 */

/**
 *  @brief  Set "cmaps" specified folder path.
 *  @param  cmaps       "cmaps" folder's full path.
 *  @param  umaps       "umaps" folder's full path.
 
 */
void Global_setCMapsPath( const char *cmaps, const char *umaps );

/**
 *  @brief  Set CMYK profile
 *  @param  path   Path value.
 *
 *  @return  true or false.
 */
bool Global_setCMYKProfile(const char *path);

/**
 *	@brief	Create a font list.
 */
void Global_fontfileListStart(void);
/**
 *	@brief	Add font file to list.
 *
 *	@param 	font_file 	Full path of font file.
 */
void Global_fontfileListAdd( const char *font_file );
/**
 *	@brief	Submit font list to PDF library.
 */
void Global_fontfileListEnd(void);
/**
 *	@brief	Set default font. The default font may be used when PDF has font not embedded. This function is valid only after Global_fontfileListEnd() invoked.
 *
 *	@param 	collection 	May be: null, "GB1", "CNS1", "Japan1", "Korea1".
 *	@param 	font_name 	Font name exist in font list.
 *	@param 	fixed 	Fixed font flag value.
 *
 *	@return	true or false.
 */
bool Global_setDefaultFont( const char *collection, const char *font_name, bool fixed );

/**
 *    @brief    Map a font list.
 */
bool Global_fontfileMapping(const char *map_name, const char *name);

/**
 *	@brief	Set annot font type.
 *
 *	@param 	font_name 	Font file's full path.
 *
 *	@return	true or false.
 */
bool Global_setAnnotFont( const char *font_name );
/**
 *	@brief	Set annot's transparency.
 *
 *	@param 	color 	RGB color in HEX (example: 0x200040FF).
 */
void Global_setAnnotTransparency( int color );
/**
 *	@brief Get faces' count. This function is valid only after Global_fontfileListEnd() invoked.
 *
 *	@return	Faces' count.
 */
int Global_getFaceCount(void);
/**
 *	@brief	Get face name by index. This function is valid only after Global_fontfileListEnd() invoked.
 *
 *	@param 	index 	0 based index, range : [0, Global_getFaceCount()-1].
 *
 *	@return	Face's name.
 */
const char *Global_getFaceName( int index );
/**
 *	@brief	Alloc or realloc DIB object.
 *
 *	@param 	dib 	NULL for alloc, otherwise, realloc object.
 *	@param 	width 	DIB's width.
 *	@param 	height 	DIB's height.
 *
 *	@return	DIB object.
 */
PDF_DIB Global_dibGet( PDF_DIB dib, int width, int height );
/**
 *	@brief	Get dib data and return dib object's pointer.
 *
 *	@param 	dib DIB object.
 *
 *  @return DIB object's pointer.
 */
void *Global_dibGetData( PDF_DIB dib );
/**
 *	@brief	Get dib object's width.
 *
 *	@param 	dib DIB object.
 *
 *	@return	DIB object's width.
 */
int Global_dibGetWidth( PDF_DIB dib );
/**
 *	@brief	Get DIB object's height.
 *
 *	@param 	dib DIB object.
 *
 *	@return	DIB object's height.
 */
int Global_dibGetHeight( PDF_DIB dib );
/**
 *	@brief	delete DIB object.
 *
 *	@param 	dib    DIB object.
 */
void Global_dibFree( PDF_DIB dib );
/**
 *	@brief	Convert a PDF Point to DIB point.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	ppoint 	Point in PDF coordinate system.
 *	@param 	dpoint 	Output value: Point in DIB coordinate system.
 */
void Global_toDIBPoint( PDF_MATRIX matrix, const PDF_POINT *ppoint, PDF_POINT *dpoint );
/**
 *	@brief	Convert a DIB Point to PDF point.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	dpoint 	Point in DIB coordinate system.
 *	@param 	ppoint 	Output value: Point in PDF coordinate system.
 */
void Global_toPDFPoint( PDF_MATRIX matrix, const PDF_POINT *dpoint, PDF_POINT *ppoint );
/**
 *	@brief	Convert a PDF rect to DIB rect.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	prect 	Rect in PDF coordinate system.
 *	@param 	drect 	Output value: Rect in DIB coordinate system.
 */
void Global_toDIBRect( PDF_MATRIX matrix, const PDF_RECT *prect, PDF_RECT *drect );
/**
 *	@brief	Convert a DIB Rect to PDF Rect.
 *
 *	@param 	matrix 	Matrix object that passed to Page_Render.
 *	@param 	drect 	Rect in DIB coordinate system.
 *	@param 	prect 	Output value: Rect in PDF coordinate system.
 */
void Global_toPDFRect( PDF_MATRIX matrix, const PDF_RECT *drect, PDF_RECT *prect );
/**
 *	@brief	Not used for developer
 */
void Global_drawScroll( PDF_DIB dst, PDF_DIB dib1, PDF_DIB dib2, int x, int y, int style, unsigned int back_side_clr );
/**
 *  @brief    Draw annot icon.
 *  @param    annot_type     Annot type value.
 *  @param    icon     Icon type value.
 *  @param    dib     DIB object.
 */
bool Global_drawAnnotIcon(int annot_type, int icon, PDF_DIB dib);
/**
 *	@brief	Create a Matrix object.
 *
 *	@param 	xx 	x scale value.
 *	@param 	yx 	yx scale value.
 *	@param 	xy 	xy scale value.
 *	@param 	yy 	y scale value.
 *	@param 	x0 	x origin.
 *	@param 	y0 	y origin.
 *
 *	@return	Matrix object.
 */
PDF_MATRIX Matrix_create( float xx, float yx, float xy, float yy, float x0, float y0 );
/**
 *	@brief	Create a Matrix object for scale values.
 *
 *	@param 	scalex 	x scale value.
 *	@param 	scaley 	y scale value.
 *	@param 	x0 	x origin.
 *	@param 	y0 	y origin.
 *
 *	@return	Matrix object
 */
PDF_MATRIX Matrix_createScale( float scalex, float scaley, float x0, float y0 );
/**
 *  @brief  Invert matrix object.
 *  @param  matrix   Matrix object. Output value: inverted matrix object.
 */
void Matrix_invert( PDF_MATRIX matrix );
/**
 *  @brief Transform path.
 *  @param path Path object to be transformed.
 */
void Matrix_transformPath( PDF_MATRIX matrix, PDF_PATH path );
/**
 *  @brief Transform ink.
 *  @param ink Ink object to be transformed.
 */
void Matrix_transformInk( PDF_MATRIX matrix, PDF_INK ink );
/**
 *  @brief Transform rect.
 *  @param rect Rect object to be transformed.
 */
void Matrix_transformRect( PDF_MATRIX matrix, PDF_RECT *rect );
/**
 *  @brief Transform point.
 *  @param point Point object to be transformed.
 */
void Matrix_transformPoint( PDF_MATRIX matrix, PDF_POINT *point );
/**
 *	@brief	Destroy Matrix object.
 *
 *	@param 	matrix 	matrix	Matrix object returned from Matrix_create or Matrix_createScale.
 */
void Matrix_destroy( PDF_MATRIX matrix );
/**
 *  @brief  Set doument opening's flag.
 *  @param  flag    Flag value to set.
 */
void Document_setOpenFlag(int flag);
/**
 *	@brief	Open document from specified path.
 *
 *	@param 	path 	 PDF file's full path.
 *	@param 	password    Password used for both user and owner's password.
 *	@param 	err 	 Error code as output if there's any error.
 *
 *	@return	NULL if failed, otherwize return Document object.
 */
PDF_DOC Document_open( const char *path, const char *password, PDF_ERR *err );
/**
 *    @brief    Open document from memory's data.
 *
 *    @param     data      PDF file's data.
 *    @param     data_size     PDF file's data size.
 *    @param     password   Password used for both user and owner's password.
 *    @param     err      Error code as output if there's any error.
 *
 *    @return    NULL if failed, otherwize return Document object.
 */
PDF_DOC Document_openMem( void *data, int data_size, const char *password, PDF_ERR *err );

@protocol PDFStream
/**
 *    @brief    Check if writeable.
 *    @return   true or false.
 */
@required
-(bool)writeable;
/**
 *    @brief    TODO
 */
@required
-(int)read: (void *)buf :(int) len;
/**
 *    @brief    TODO
 */
@required
-(int)write: (const void *)buf :(int) len;
/**
 *    @brief    Get position value.
 *    @return   Position value.
 */
@required
-(unsigned long long)position;
/**
 *    @brief    Get lenght value.
 *    @return   Lenght value.
 */
@required
-(unsigned long long)length;
/**
 *    @brief    TODO
 */
@required
-(bool)seek:(unsigned long long)pos;
@end
/**
 *    @brief    Open document from PDFStream.
 *
 *    @param     stream      PDFStream object.
 *    @param     password   Password used for both user and owner's password.
 *    @param     err      Error code as output if there's any error.
 *
 *    @return    NULL if failed, otherwize return Document object.
 */
PDF_DOC Document_openStream( id<PDFStream> stream, const char *password, PDF_ERR *err );
/**
 *    @brief    Open document from specified path with certificate.
 *
 *    @param     path      PDF file's path.
 *    @param     cert_file     Certificate file's path.
 *    @param     password   Password used for both user and owner's password.
 *    @param     err      Error code as output if there's any error.
 *
 *    @return    NULL if failed, otherwize return Document object.
 */
PDF_DOC Document_openWithCert(const char *path, const char *cert_file, const char *password, PDF_ERR *err);
/**
 *    @brief    Open document from memory's data with certificate.
 *
 *    @param     data      PDF file's data.
 *    @param     data_size     PDF file's data size.
 *    @param     cert_file     Certificate file's path.
 *    @param     password   Password used for both user and owner's password.
 *    @param     err      Error code as output if there's any error.
 *
 *    @return    NULL if failed, otherwize return Document object.
 */
PDF_DOC Document_openMemWithCert(void *data, int data_size, const char *cert_file, const char *password, PDF_ERR *err);
/**
 *    @brief    Open document from PDFStream with certificate.
 *
 *    @param     stream      PDFStream object.
 *    @param     cert_file     Certificate file's path.
 *    @param     password   Password used for both user and owner's password.
 *    @param     err      Error code as output if there's any error.
 *
 *    @return    NULL if failed, otherwize return Document object.
 */
PDF_DOC Document_openStreamWithCert(id<PDFStream> stream, const char *cert_file, const char *password, PDF_ERR *err);

/**
 *	@brief	Create document and return Document object.
 *
 *	@param 	path 	 full path of PDF file.
 *	@param 	err 	 output value: error code.
 *
 *	@return	NULL if failed, and developers should check err code for some reason.
 otherwize return Document object.
 */
PDF_DOC Document_create( const char *path, PDF_ERR *err );
/**
 *    @brief    Set Document object's cache file.
 *
 *    @param     doc          Opened Document object.
 *    @param     cache_file      Cache file's absolute path.
 *
 *    @return    true or false.
 */
bool Document_setCache( PDF_DOC doc, const char *cache_file );
/**
 *    @brief    TODO
 */
@protocol PDFJSDelegate
/**
 *    @brief    TODO
 */
@required
-(int)OnAlert:(int)nbtn :(NSString *)msg :(NSString *)title;
/**
 *    @brief    TODO
 */
@required
-(void)OnConsole:(int)ccmd :(NSString *)para;
/**
 *    @brief    TODO
 */
@required
-(bool)OnDocClose;
/**
 *    @brief    TODO
 */
@required
-(NSString *)OnTmpFile;
/**
 *    @brief    TODO
 */
@required
-(void)OnUncaughtException:(int)code : (NSString *)para;
@end
bool Document_runJS( PDF_DOC doc, const char *js, id<PDFJSDelegate> del );
    
/**
 *	@brief	Get PDF's permission. This value defined in PDF reference 1.7
 *
 *	@param 	doc Opened Document object.
 *
 *	@return	Permission flags:
 *          - Bit 1-2: reserved
 *          - Bit 3(0x4): print
 *          - Bit 4(0x8): modify
 *          - Bit 5(0x10): extract text or image
 *          For others see PDF reference.
 */
int Document_getPermission( PDF_DOC doc );
/**
 *    @brief    Set page rotation.
 *
 *    @param    doc  Opened Document object.
 *    @param    pageno  Specific page to rotate.
 *    @param    doc  Rotation's degree.
 *
 *    @return   true or false.
 */
bool Document_setPageRotate( PDF_DOC doc, int pageno, int degree );
/**
 *    @brief    Change page's rect.
 *
 *    @param    doc Document object returned from Doument_open method
 *    @param    pageno  Specific page to rotate.
 *    @param    dl  Rect's left position.
 *    @param    dt  Rect's top position.
 *    @param    dr  Rect's right position.
 *    @param    db  Rect's bottom position.
 *    @return   true or false.
 */
bool Document_changePageRect( PDF_DOC doc, int pageno, float dl, float dt, float dr, float db );
/**
 *	@brief	Check if Document is editable.
 *
 *	@param 	doc  Opened Document object.
 *
 *	@return	true or false.
 */
bool Document_canSave( PDF_DOC doc );

/**
 *	@brief	Get outline item's title.
 *
 *	@param 	doc 	        Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *	@return	Label string.
 */
NSString *Document_getOutlineLabel(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	Get outline item's destination.
 *
 *	@param 	doc 	        Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *	@return		0 based page number.
 */
int Document_getOutlineDest( PDF_DOC doc, PDF_OUTLINE outlinenode );
/**
 *	@brief	Get outline item's first child.
 *
 *	@param 	doc 	        Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *	@return	Root Outline item if outlinenode == NULL. If there's no child return NULL.
 */
NSString* Document_getOutlineURI(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *    @brief    Get outline item's file link.
 *
 *    @param     doc             Opened Document object.
 *    @param     outlinenode     Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *    @return    File link's string.
 */
NSString* Document_getOutlineFileLink(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *    @brief    Get outline item's child.
 *
 *    @param     doc             Opened Document object.
 *    @param     outlinenode     Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *    @return    Root Outline item if outlinenode == NULL. If there's no child return NULL.
 */
PDF_OUTLINE Document_getOutlineChild(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	Get next outline item.
 *
 *	@param 	doc 	        Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *	@return	Root Outline item if outlinenode == NULL. If there's no next item return NULL.
 */
PDF_OUTLINE Document_getOutlineNext(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	Insert outline as selected Outline's first child. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	        Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *	@param 	label 	        Output value: label text ot outline item.
 *	@param 	pageno 	 0 based page number.
 *	@param 	top 	y in PDF coordinate
 *
 *	@return	true or false
 */
bool Document_addOutlineChild(PDF_DOC doc, PDF_OUTLINE outlinenode, const char *label, int pageno, float top);
/**
 *    @brief Add new a root outline to document, it insert first root outline to Document. The old first root outline, shall be next of this outline.
 *    @param     doc             Opened Document object.
 *    @param     label             Output value: label text ot outline item.
 *    @param     pageno      0 based page number.
 *    @param     top     y in PDF coordinate
 *
 *    @return    true or false
 */
bool Document_newRootOutline( PDF_DOC doc, const char *label, int pageno, float top );
/**
 *	@brief	Insert outline after selected Outline. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *	@param 	label 	Output value: label text ot outline item.
 *	@param 	pageno 	0 based page number.
 *	@param 	top 	y in PDF coordinate
 *
 *	@return	true or false
 */
bool Document_addOutlineNext(PDF_DOC doc, PDF_OUTLINE outlinenode, const char *label, int pageno, float top);
/**
 *	@brief	Remove selected outline.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	outlinenode 	Outline Item returned from Document_getOutlineChild or Document_getOutlineNext methods.
 *
 *	@return	true or false.
 */
bool Document_removeOutline(PDF_DOC doc, PDF_OUTLINE outlinenode);
/**
 *	@brief	Get meta data by tag.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	tag 	Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate","ModDate".
 *	@return	String value.
 */
NSString *Document_getMeta( PDF_DOC doc, const char *tag );
/**
 *    @brief    Get meta data by tag.
 *
 *    @param     doc     Opened Document object.
 *    @param     tag     Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate","ModDate".
 *    @param     meta     Meta data value.
 *    @return    true or false.
 */
bool Document_setMeta( PDF_DOC doc, const char *tag, const char *meta );
/**
 *    @brief    Get unique Document object's ID generated from input string.
 *
 *    @param     doc    Opened Document object.
 *    @param     fid    File ID to be set. It must be 32 bytes long.
 *    @return    true or false.
 */
bool Document_getID(PDF_DOC doc, unsigned char *fid);
/**
 *	@brief	Get selected page's width.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	pageno 	0 based page number.
 *
 *	@return	Selected page's width
 */
float Document_getPageWidth( PDF_DOC doc, int pageno );
/**
 *	@brief	Get page's height.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	pageno 	0 based page number.
 *
 *	@return	Selected page's height.
 */
float Document_getPageHeight( PDF_DOC doc, int pageno );
/**
 *    @brief    Get page's label.
 *
 *    @param     doc     Opened Document object.
 *    @param     pageno     0 based page number.
 *
 *    @return    Selected page's label.
 */
NSString *Document_getPageLabel(PDF_DOC doc, int pageno);
/**
 *	@brief	Get pages' count.
 *
 *	@param 	doc 	Opened Document object.
 *
 *	@return	Pages' count.
 */
int Document_getPageCount( PDF_DOC doc );
/**
 *    @brief    Get max sized reached from selected document's pages.
 *
 *    @param     doc     Opened Document object.
 *    @param     sz     Max sized struct that will be populate.
 */
void Document_getPagesMaxSize(PDF_DOC doc, PDF_SIZE *sz);
/**
 *    @brief    Get Document's XMP.
 *
 *    @param    doc     Opened Document object.
 *
 *    @return   XMP's path.
 */
NSString *Document_getXMP(PDF_DOC doc);
/**
 *    @brief    Set Document's XMP.
 *
 *    @param    doc     Opened Document object.
 *    @param    xmp     XMP's path.
 *
 *    @return   true or false.
 */
bool Document_setXMP(PDF_DOC doc, NSString *xmp);
/**
 *	@brief	Save PDF file.
 *
 *	@param 	doc 	Opened Document object.
 *
 *	@return		true or false.
 */
bool Document_save( PDF_DOC doc );
/**
 *	@brief	Save PDF file as another file. WARNING: In new file's path destination all encrypt's informations will be removed.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	dst 	Full path to save.
 *
 *	@return	true or false.
 */
bool Document_saveAs( PDF_DOC doc, const char *dst, bool rem_sec );
/**
 *   @brief    Encrypt PDF file as another file. WARNING: Premium license is needed for this method.
 *	@param 	doc 	Opened Document object.
 *	@param 	dst 	Full path to save.
 *	@param  upswd	User's password.
 *	@param  opswd	Owner's password.
 *	@param  perm	Permission to set (see PDF reference or Document_getPermission() method).
 *	@param  method	Reserved.
 *	@param	fid		File ID to be set. It must be 32 bytes long.
 *	@return	true or false.
*/
bool Document_encryptAs(PDF_DOC doc, NSString *dst, NSString *upswd, NSString *opswd, int perm, int method, unsigned char *fid);
/**
 *	@brief	Check if document is encrypted
 *
 *	@param 	doc 	Opened Document object.
 *
 *	@return		true or false.
 */
bool Document_isEncrypted( PDF_DOC doc );
/**
 *    @brief    Verify document's specified sign
 *
 *    @param     doc     Opened Document object.
 *
 *    @return    true or false.
 */
int Document_verifySign(PDF_DOC doc, PDF_SIGN sign);
/**
 *    @brief    Get document's EF count.
 *
 *    @param     doc     Opened Document object.
 *
 *    @return    EF count.
 */
int Document_getEFCount(PDF_DOC doc);
/**
 *    @brief    Get document's EF name at index.
 *
 *    @param     doc     Opened Document object.
 *    @param     index     EF's index.
 *
 *    @return    EF name.
 */
NSString *Document_getEFName(PDF_DOC doc, int index);
/**
 *    @brief    Get document's EF description at index.
 *
 *    @param     doc     Opened Document object.
 *    @param     index     EF's index.
 *
 *    @return    EF description.
 */
NSString *Document_getEFDesc(PDF_DOC doc, int index);
/**
 *    @brief    Get document's EF data at index.
 *
 *    @param     doc     Opened Document object.
 *    @param     index     EF's index.
 *
 *    @return    EF data.
 */
bool Document_getEFData(PDF_DOC doc, int index, NSString *path);
/**
 *    @brief    Get document's javascript count.
 *
 *    @param     doc     Opened Document object.
 *
 *    @return    Javascript count.
 */
int Document_getJSCount(PDF_DOC doc);
/**
 *    @brief    Get document's javascript name at index.
 *
 *    @param     doc     Opened Document object.
 *    @param     index     Javascript's index.
 *
 *    @return    Javascript's name.
 */
NSString *Document_getJSName(PDF_DOC doc, int index);
/**
 *    @brief    Get document's javascript at index.
 *
 *    @param     doc     Opened Document object.
 *    @param     index     Javascript's index.
 *
 *    @return    Javascript string value.
 */
NSString *Document_getJS(PDF_DOC doc, int index);
/**
 *    @brief    Export document's form data as XML string.
 *
 *    @param    doc     Opened Document object.
 *
 *    @return   XML string
 */
NSString *Document_exportForm( PDF_DOC doc );
/**
 *	@brief	Close document.
 *
 *	@param 	doc 	Opened Document object.
 */
void Document_close( PDF_DOC doc );
/**
 *    @brief  Get selected document's linearized status.
 *
 *    @param     doc     Opened Document object.
 *    @return   Selected document's linearized status
 */
int Document_getLinearizedStatus(PDF_DOC doc);
/**
 *	@brief	Get page object by page number.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	pageno 	0 based page number.
 *
 *	@return	Page object.
 */
PDF_PAGE Document_getPage( PDF_DOC doc, int pageno );
/**
 *	@brief	Create a font object used to write texts. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	name 	Font name exists in font list. Use Global.getFaceCount() and Global.getFaceName() methods to enumerate fonts.
 *	@param 	style 	(style&1) means bold,
                    (style&2) means Italic,
                    (style&8) means embed,
                    (style&16) means vertical writing, mostly used in Asia fonts.
 *
 *	@return	DocFont object.
 */
PDF_DOC_FONT Document_newFontCID( PDF_DOC doc, const char *name, int style );
/**
 *	@brief	Get font ascent.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	font 	Font object created by Document.NewFontCID() method.
 *
 *	@return	Font ascent.
 */
float Document_getFontAscent( PDF_DOC doc, PDF_DOC_FONT font );
/**
 *	@brief	Get font descent
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	font 	Font object created by Document.NewFontCID() method.
 *
 *	@return	Font descent.
 */
float Document_getFontDescent( PDF_DOC doc, PDF_DOC_FONT font );
/**
 *	@brief	Create a ExtGraphicState object used to set alpha values. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc Opened Document object.
 *
 *	@return	PDF_DOC_GSTATE object.
 */
PDF_DOC_GSTATE Document_newGState( PDF_DOC doc );
/**
 *	@brief	Set GraphicState object stroke alpha.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	state 	PDF Graphicstate create by Document_newGState method.
 *	@param 	alpha  Alpha value
 *
 *	@return	true or false.
 */
bool Document_setGStateStrokeAlpha( PDF_DOC doc, PDF_DOC_GSTATE state, int alpha );
/**
 *	@brief	Set GraphicState object fill alpha.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	state 	PDF Graphicstate create by Document_newGState method.
 *	@param 	alpha 	Alpha value.
 *
 *	@return	true or false.
 */
bool Document_setGStateFillAlpha( PDF_DOC doc, PDF_DOC_GSTATE state, int alpha );
/**
 *    @brief    Set GraphicState object stroke dash.
 *
 *    @param     doc     Opened Document object.
 *    @param     state     PDF Graphicstate create by Document_newGState method.
 *    @param     dash     Dash value.
 *    @param     alpha     Dash count.
 *    @param     alpha     Phase value. Mostly it is 0.
 *
 *    @return    true or false.
 */
bool Document_setGStateStrokeDash(PDF_DOC doc, PDF_DOC_GSTATE state, const float *dash, int dash_cnt, float phase);
/**
 *    @brief    Set GraphicState object blend mode.
 *
 *    @param     doc     Opened Document object.
 *    @param     state     PDF Graphicstate create by Document_newGState method.
 *    @param     bmode     Blend mode.
 *
 *    @return    true or false.
 */
bool Document_setGStateBlendMode(PDF_DOC doc, PDF_DOC_GSTATE state, int bmode);
/**
 *    @brief    Create a document form object.
 *
 *    @param     doc    Opened Document object.
 *
 *    @return    Document form object.
 */
PDF_DOC_FORM Document_newForm(PDF_DOC doc);
/**
 *    @brief    Add a font as form's resource
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Form object.
 *
 *    @return    Font resource object.
 */
PDF_PAGE_FONT Document_addFormResFont(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_FONT font);
/**
 *    @brief    Add an image  as form's resource
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Form object.
 *    @param     image    Image object.
 *
 *    @return    Image resource object.
 */
PDF_PAGE_IMAGE Document_addFormResImage(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_IMAGE image);
/**
 *    @brief    Add graphic state object as form's resource
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Form object.
 *    @param     gstate    Graphic state object.
 *
 *    @return    Graphic state resource object.
 */
PDF_PAGE_GSTATE Document_addFormResGState(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_GSTATE gstate);
/**
 *    @brief    Add subform object as form's resource
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Form object.
 *    @param     sub    Subform object.
 *
 *    @return    Subform resource object.
 */
PDF_PAGE_FORM Document_addFormResForm(PDF_DOC doc, PDF_DOC_FORM form, PDF_DOC_FORM sub);
/**
 *    @brief    Set form's content at position.
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Form object.
 *    @param     x   x position.
 *    @param     y   y position.
 *    @param     w   Content's width.
 *    @param     h   Content's height.
 *    @param     content   Form content object. This will be the output.
 */
void Document_setFormContent(PDF_DOC doc, PDF_DOC_FORM form, float x, float y, float w, float h, PDF_PAGECONTENT content);
/**
 *    @brief    Set form's transparency.
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Form object.
 *    @param     isolate    Isolate flag value.
 *    @param     knockout   Knockout flag value.
 */
void Document_setFormTransparency(PDF_DOC doc, PDF_DOC_FORM form, bool isolate, bool knockout);
/**
 *    @brief    Create free-form object
 *
 *    @param     doc    Opened Document object.
 *    @param     form    Free-form object. This will be the output value.
 */
void Document_freeForm(PDF_DOC doc, PDF_DOC_FORM form);
/**
 *	@brief	Insert a page to Document. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	pageno 	0 based page number. If page number is major than pages' count it will append page at the document's end.
 *	@param 	w 	Page width in PDF coordinate.
 *	@param 	h 	Page height in PDF coordinate.
 *
 *	@return	Page object or null means failed.
 */
PDF_PAGE Document_newPage( PDF_DOC doc, int pageno, float w, float h );

/**
 *	@brief	Create an import context. WARNING: Premium license is needed for this method.
 *	@param 	doc 	Destination Document object returned from Document_openXXX or Document_CreateXXX methods.
 *	@param 	doc_src	Source Document object returned from Document_openXXX or Document_CreateXXX methods.
 *
 *	@return	Context object.
 */
PDF_IMPORTCTX Document_importStart( PDF_DOC doc, PDF_DOC doc_src );

/**
 *	@brief	Import single page from source document. WARNING: Premium license is needed for this method.
 *	@param 	doc 	Destination Document object returned from Document_openXXX or Document_CreateXXX methods.
 *	@param 	ctx		Context object returned from Document_importStart method.
 *	@param 	srcno	0 based page number from source Document object.
 *	@param 	dstno	0 based page number for dest Document object.
 *
 *	@return	true or false.
 */
bool Document_importPage( PDF_DOC doc, PDF_IMPORTCTX ctx, int srcno, int dstno );

/**
 *	@brief	Destroy specified context object. WARNING: Premium license is needed for this method.
 *	@param 	doc 	Destination Document object returned from Document_openXXX or Document_CreateXXX methods.
 *	@param 	ctx		Context object returned from Document_importStart method.
 */
void Document_importEnd( PDF_DOC doc, PDF_IMPORTCTX ctx );

/**
 *	@brief	Move page by page number. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Document object returned from Document_openXXX or Document_CreateXXX methods.
 *	@param 	pageno1	0 based page number for origin page number.
 *	@param 	pageno2	0 based page number for destination page number.
 *
 *	@return	true or false.
 */
bool Document_movePage( PDF_DOC doc, int pageno1, int pageno2 );

/**
 *	@brief	Remove page by page NO. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	pageno 	0 based page number.
 *
 *	@return	true or false.
 */
bool Document_removePage( PDF_DOC doc, int pageno );
/**
 *    @brief    Create a Document Image object from CGImageRef object. WARNING: Premium license is needed for this method.
 *
 *    @param     doc     Opened Document object.
 *    @param     img     CGImageRef object.
 *    @param     has_alpha    Define if image will has alpha or not.
 *
 *    @return    Document Image object.
 */
PDF_DOC_IMAGE Document_newImage(PDF_DOC doc, CGImageRef img, bool has_alpha);
/**
 *	@brief	Create a Document Image object from JPEG/JPG file.
 *          Supported image color space:
 *          - GRAY
 *          - RGB
 *          - CMYK
 *          WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	path    JPEGG/JPG file's path.
 *
 *	@return	Document Image object.
 */
PDF_DOC_IMAGE Document_newImageJPEG( PDF_DOC doc, const char *path );
/**
 *	@brief	Create a Document Image object from JPX/JPEG 2k file. WARNING: Premium license is needed for this method.
 *
 *	@param 	doc 	Opened Document object.
 *	@param 	path 	JPX file's path.
 *
 *	@return	Document Image object.
 */
PDF_DOC_IMAGE Document_newImageJPX( PDF_DOC doc, const char *path );
/**
 *    @brief    Get signatuere's issue.
 *    @return   Signatuere's issue.
 */
NSString *Sign_getIssue(PDF_SIGN sign);
/**
 *    @brief    Get signatuere's subject.
 *    @return   Signatuere's subject.
 */
NSString *Sign_getSubject(PDF_SIGN sign);
/**
 *    @brief    Get signature's version.
 *    @return   Signatuere's version.
 */
long Sign_getVersion(PDF_SIGN sign);
/**
 *    @brief    Get signature's name.
 *    @return   Signatuere's name.
 */
NSString* Sign_getName(PDF_SIGN sign);
/**
 *    @brief    Get signature's location.
 *    @return   Signatuere's location.
 */
NSString *Sign_getLocation(PDF_SIGN sign);
/**
 *    @brief    Get signature's reason.
 *    @return   Signatuere's reason.
 */
NSString *Sign_getReason(PDF_SIGN sign);
/**
 *    @brief    Get signature's contact.
 *    @return   Signatuere's contact.
 */
NSString *Sign_getContact(PDF_SIGN sign);
/**
 *    @brief    Get signatuere's modification date.
 *    @return   Signatuere's modification date.
 */
NSString *Sign_getModDT(PDF_SIGN sign);
/**
 *    @brief    Add signature in specified document's form at specified page.
 *    @param     page     Document's Page object.
 *    @param     appearence     Document's Form object.
 *    @param     box    Position where annotation will be added in pdf coordinate.
 *    @param     cert_file  Certification file's path.
 *    @param     pswd   Document's password.
 *    @param     name   Signature's name.
 *    @param     reason  Signature's reason.
 *    @param     location   Signature's location.
 *    @param     contact    Signature's contact.
 *
 *    @return    Document Image object.
 */
int Page_sign(PDF_PAGE page, PDF_DOC_FORM appearence, const PDF_RECT *box, const char *cert_file, const char *pswd, const char *name, const char *reason, const char *location, const char *contact);
/**
 *    @brief    Get specified page's crop box.
 *
 *    @param     page    Specified page object.
 *    @param     box    Crop box's rect.
 */
bool Page_getCropBox( PDF_PAGE page, PDF_RECT *box );
/**
 *    @brief    Get specified page's media box.
 *
 *    @param     page    Specified page object.
 *    @param     box    Media box's rect.
 */
bool Page_getMediaBox( PDF_PAGE page, PDF_RECT *box );
/**
 *	@brief	Close specified page.
 *
 *	@param 	page    Specified page object.
 */
void Page_close( PDF_PAGE page );
/**
 *    @brief  Render specific page's thumb.
 *
 *    @param     page    Specified page object.
 *    @param     dib    Specified dib object.
 *
 *    @return    true or false.
 */
bool Page_renderThumb(PDF_PAGE page, PDF_DIB dib);
/**
 *	@brief	Reset status and erase wihite for dib.
 *
 *	@param 	page 	Specified page object.
 *	@param 	dib 	Specified dib object.
 */
void Page_renderPrepare( PDF_PAGE page, PDF_DIB dib );
/**
 *	@brief	render page to dib.
 *
 *	@param 	page 	Specified page object.
 *	@param 	dib 	Specified dib object.
 *	@param 	matrix 	Specified Maxtrix object returned from Matrix_create or Matrix_createScale methods.
 *	@param 	show_annots 	Define if showing annotations or not.
 *	@param 	mode 	Render mode.
 *
 *	@return	true or false.
 */
bool Page_render( PDF_PAGE page, PDF_DIB dib, PDF_MATRIX matrix, bool show_annots, PDF_RENDER_MODE mode );

/**
 *	@brief	Cancel render. In mostly, this function called by UI thread, and Page_render method's called by another thread.
 *
 *	@param 	page 	Specified page object.
 */
void Page_renderCancel( PDF_PAGE page );
/**
 *	@brief	check if page render finished.
 *
 *	@param 	page 	Specified page object.
 *
 *	@return	true or false.
 */
bool Page_renderIsFinished( PDF_PAGE page );
/**
 *    @brief    Get page rotation.
 *
 *    @param     page     Specified page object.
 *
 *    @return    Rotation value.
 */
int Page_getRotate(PDF_PAGE page);
/**
 *    @brief    Flate all annots at specific page.
 *
 *    @param     page     Specified page object.
 *
 *    @return    true or false.
 */
bool Page_flate(PDF_PAGE page);
/**
 *    @brief    Flate specific annot at specific page.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annot object.
 *
 *    @return    true or false.
 */
bool Page_flateAnnot(PDF_PAGE page, PDF_ANNOT annot);
/**
 *	@brief	Load all objects in page.
 *
 *	@param 	page 	Specified page object.
 */
void Page_objsStart( PDF_PAGE page );
/**
 *	@brief	Get chars count. WARNING: to invoke this function, call Page_objsStart method before.
 *	@param 	page 	Specified page object.
 *
 *	@return	Chars' count.
 */
int Page_objsGetCharCount( PDF_PAGE page );
/**
 *	@brief	Get string by index range. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	from 	From index, range: [0, Page_objsGetCharCount() - 1]
 *	@param 	to 	    To index, range: [0, Page_objsGetCharCount() - 1]
 *
 *	@return	String value.
 */
NSString *Page_objsGetString( PDF_PAGE page, int from, int to );
/**
 *	@brief	Get char's rect area. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	index 	Range: [0, Page_objsGetCharCount() - 1]
 *	@param 	rect 	Output value: rect in PDF coordinate.
 */
void Page_objsGetCharRect( PDF_PAGE page, int index, PDF_RECT *rect );
/**
 *	@brief	Get char's font name. WARNING: this can be invoked after ObjsStart method.
 *
 *	@param 	page 	Specified page object.
 *	@param 	index 	0 based unicode index.
 *
 *	@return	Font name.
 */
const char *Page_objsGetCharFontName( PDF_PAGE page, int index );
/**
 *	@brief	Get char index nearest to specified point.
 *
 *	@param 	page 	Specified page object.
 *	@param 	x 	x in PDF coordinate.
 *	@param 	y 	y in PDF coordinate.
 *
 *	@return	Char index. If failed return -1.
 */
int Page_objsGetCharIndex( PDF_PAGE page, float x, float y );
/**
 *	@brief	Get index aligned by word. WARNING: this can be invoked after ObjsStart method.
 *
 *	@param 	page 	Specified page object.
 *	@param 	from 	0 based unicode index.
 *	@param 	dir 	If dir < 0, it get start index of the word. Otherwise get last index of the word.
 *
 *	@return	New index value.
 */
int Page_objsAlignWord( PDF_PAGE page, int from, int dir );
/**
 *	@brief	Open a finder object. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *	@param 	page 	    Specified page object.
 *	@param 	str 	    String to find.
 *	@param 	match_case 	Define if searching by match case or not.
 *	@param 	whole_word 	Define if searching by whole word or not.
 *
 *	@return	Finder object.
 */
PDF_FINDER Page_findOpen( PDF_PAGE page, const char *str, bool match_case, bool whole_word );
/**
 *    @brief    Open a finder object. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *    @param     page         Specified page object.
 *    @param     str         String to find.
 *    @param     match_case     Define if searching by match case or not.
 *    @param     whole_word     Define if searching by whole word or not.
 *    @param     skip_blanks     Define if skip blank spaces or not.
 *
 *    @return    Finder object.
 */
PDF_FINDER Page_findOpen2(PDF_PAGE page, const char* str, bool match_case, bool whole_word, bool skip_blanks);
/**
 *	@brief	Get search results' count. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *	@param 	finder 	Specified Finder object.
 *	@return	Search results' count.
 */
int Page_findGetCount( PDF_FINDER finder );
/**
 *	@brief	Get first char index in page by find index. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *	@param 	finder 	Specified Finder object.
 *	@param 	index 	Find index, range: [0, Page_findGetCount() - 1].
 *
 *	@return	Char first index in page, range: [0, Page_objsGetCharCount() - 1].
 */
int Page_findGetFirstChar( PDF_FINDER finder, int index );
/**
 *    @brief    Get last char index in page by find index. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *    @param     finder     Specified Finder object.
 *    @param     index     Find index, range: [0, Page_findGetCount() - 1].
 *
 *    @return    Char last index in page, range: [0, Page_objsGetCharCount() - 1].
 */
int Page_findGetEndChar(PDF_FINDER finder, int index);
/**
 *	@brief	Close specified Finder object. WARNING: to invoke this function, call Page_objsStart method before.
 *
 *	@param 	finder 	Specified Finder object.
 */
void Page_findClose( PDF_FINDER finder );
/**
 *	@brief	Get annotations' count. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page Specified page object.
 *
 *	@return	Annotations' count.
 */
int Page_getAnnotCount( PDF_PAGE page );
/**
 *	@brief	Get annotation by index. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	index 	0 based index, range: [0, Page_getAnnotCount() - 1].
 *
 *	@return	Annotation object.
 */
PDF_ANNOT Page_getAnnot( PDF_PAGE page, int index );
/**
 *	@brief	Get annotation by point. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	x 	x of point, in PDF coordinate
 *	@param 	y 	y of point, in PDF coordinate
 *
 *	@return	Annotation object.
 */
PDF_ANNOT Page_getAnnotFromPoint( PDF_PAGE page, float x, float y );
/**
 *    @brief    Get signature status. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *    @param     page     Specified page object.
 *    @param     annot    Signature's annotation object.
 *
 *    @return    Signature status.
 */
int Page_getAnnotSignStatus(PDF_PAGE page, PDF_ANNOT annot);
/**
 *    @brief    Get specified annotation's signature. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *    @param     page     Specified page object.
 *    @param     annot    Signature's annotation object.
 *
 *    @return    Signature object.
 */
PDF_SIGN Page_getAnnotSign(PDF_PAGE page, PDF_ANNOT annot);
/**
 *	@brief	Chek if is annotation locked. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return		true or false.
 */
bool Page_isAnnotLocked( PDF_PAGE page, PDF_ANNOT annot );
/**
 *    @brief    Set annotation lock status. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     lock     Define if annot is locked or unlocked.
 *
 *    @return        true or false.
 */
void Page_setAnnotLock( PDF_PAGE page, PDF_ANNOT annot, bool lock );
/**
 *    @brief    Chek if is annotation readonly. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return        true or false.
 */
bool Page_isAnnotReadonly(PDF_PAGE page, PDF_ANNOT annot);
/**
 *    @brief    Set annotation readonly status. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     lock     Define if annot is readonly or not.
 *
 *    @return        true or false.
 */
void Page_setAnnotReadonly(PDF_PAGE page, PDF_ANNOT annot, bool lock);

/**
 *	@brief	Chek if annotation has locked content. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return		true or false.
 */
bool Page_isAnnotLockedContent( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Check if is annotation hidden.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	true or false.
 */
bool Page_isAnnotHide( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set annotation hide status.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	hide 	Hide status.
 */
void Page_setAnnotHide( PDF_PAGE page, PDF_ANNOT annot, bool hide );
/**
 *    @brief    Get annotation's name.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    Annotation's name.
 */
NSString *Page_getAnnotName(PDF_PAGE page, PDF_ANNOT annot);
/**
 *    @brief    Set annotation's name.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     name     Annotation's name to add.
 *
 *    @return    true or false.
 */
bool Page_setAnnotName(PDF_PAGE page, PDF_ANNOT annot, const char *name);
/**
 *    @brief    Get annotation by name.
 *
 *    @param     page     Specified page object.
 *    @param     name     Annotation's name to add.
 *
 *    @return    Annotation object.
 */
PDF_ANNOT Page_getAnnotByName(PDF_PAGE page, const char *name);
/**
 *	@brief	Get annotation type.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Annotation's type as these values:
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
 *    @brief    Add signature to annotation's field.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     appearence     Document's Form object.
 *    @param     cert_file  Certification file's path.
 *    @param     pswd   Document's password.
 *    @param     name   Signature's name.
 *    @param     reason  Signature's reason.
 *    @param     location   Signature's location.
 *    @param     contact    Signature's contact.
 *
 *    @return    1 on success, 0 on failure.
 */
int Page_signAnnotField(PDF_PAGE page, PDF_ANNOT annot, PDF_DOC_FORM appearence, const char *cert_file, const char *pswd, const char *name, const char *reason, const char *location, const char *contact);
/**
 *	@brief	Get annotation's field type in acroForm.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Type as these values:
 *          0: unknown
 *          1: button field
 *          2: text field
 *          3: choice field
 *          4: signature field
 */
int Page_getAnnotFieldType( PDF_PAGE page, PDF_ANNOT annot );
/**
 *    @brief    Get annotation's field flag.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in premium version.
 *    @return    Flag value.
 */
int Page_getAnnotFieldFlag(PDF_PAGE page, PDF_ANNOT annot);
/**
 *	@brief Get annotation's name. WARNING: a premium license is needed for this function.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param	buf		Buffer to fill names in UTF-8 coding.
 *	@param	buf_size	Buffer's size that allocated.
 *	@return	Annotation's name (like: "EditBox1[0]").
 */
int Page_getAnnotFieldName( PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size );
/**
 *   @brief Get annotation's name. WARNING: a premium license is needed for this function.
 *
 *   @param     page     Specified page object.
 *   @param     annot     Specified annotation object.
 *   @param    buf        Buffer to fill names in UTF-8 coding.
 *   @param    buf_size    Buffer's size that allocated.
 *   @return    Annotation's name (like: "EditBox1[0]").
 */
int Page_getAnnotFieldNameWithNO(PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size);
/**
 *	@brief Get specified annotation's field full name. WARNING: a premium license is needed for this function.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param	buf		Buffer to fill names in UTF-8 coding.
 *	@param	buf_size	Allocated buffer's size.
 *	@return	Annotation's name (like: "form1.EditBox1").
 */
int Page_getAnnotFieldFullName( PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size );
/**
 *	@brief Get specified annotation's field full name with more details. WARNING: a premium license is needed for this function.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param	buf		Buffer to fill names in UTF-8 coding.
 *	@param	buf_size	Allocated buffer's size.
 *	@return	Annotation's name (like: "form1[0].EditBox1[0]").
 */
int Page_getAnnotFieldFullName2( PDF_PAGE page, PDF_ANNOT annot, char *buf, int buf_size );
/**
 *    @brief Get specified annotation's field javascript value. WARNING: a premium license is needed for this function.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     idx   Index value
 *    @return    Annotation's name (like: "form1[0].EditBox1[0]").
 */
NSString *Page_getAnnotFieldJS(PDF_PAGE page, PDF_ANNOT annot, int idx);
/**
 *    @brief    Render specified annot in specified page and rect WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     dib     Specified dib object
 *
 *    @return   true or false.
 */
bool Page_renderAnnot(PDF_PAGE page, PDF_ANNOT annot, PDF_DIB dib);
/**
 *	@brief	Get annotation's rect. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	rect 	Annotation's rect in PDF coordinate.
 */
void Page_getAnnotRect( PDF_PAGE page, PDF_ANNOT annot, PDF_RECT *rect );
/**
 *	@brief	Set annotation's rect. WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	rect 	Annotation's rect in PDF coordinate.
 */
void Page_setAnnotRect( PDF_PAGE page, PDF_ANNOT annot, const PDF_RECT *rect );
/**
 *    @brief    Get annotation's last modify date.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    Annotation's last modify date.
 */
const char *Page_getAnnotModifyDate(PDF_PAGE page, PDF_ANNOT annot);
/**
 *    @brief    Set annotation's last modify date.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    true or false.
 */
bool Page_setAnnotModifyDate(PDF_PAGE page, PDF_ANNOT annot, const char *val);
/**
 *    @brief    Get annotation's ink path.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    Ink annotation path.
 */
PDF_PATH Page_getAnnotInkPath( PDF_PAGE page, PDF_ANNOT annot );
/**
 *    @brief    Set annotation's ink path.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    true or false.
 */
bool Page_setAnnotInkPath( PDF_PAGE page, PDF_ANNOT annot, PDF_PATH path );
/**
 *    @brief    Get annotation's polygon path.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    Polygon path.
 */
PDF_PATH Page_getAnnotPolygonPath( PDF_PAGE page, PDF_ANNOT annot );
/**
 *    @brief    Get annotation's polygon path.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    true or false.
 */
bool Page_setAnnotPolygonPath( PDF_PAGE page, PDF_ANNOT annot, PDF_PATH path );
/**
 *    @brief    Get annotation's polyline path.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    Polyline path.
 */
PDF_PATH Page_getAnnotPolylinePath( PDF_PAGE page, PDF_ANNOT annot );
/**
 *    @brief    Set annotation's polyline path.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    true or false.
 */
bool Page_setAnnotPolylinePath( PDF_PAGE page, PDF_ANNOT annot, PDF_PATH path );
/**
 *    @brief    Get line annotation's point.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     idx     Specified annotation index.
 *    @param     point     Specified annotation point. This will be the output.
 *
 *    @return    true or false.
 */
bool Page_getAnnotLinePoint(PDF_PAGE page, PDF_ANNOT annot, int idx, PDF_POINT* pt);
/**
 *    @brief    Get  annotation's line style.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *
 *    @return    Annotation's line style..
 */
int Page_getAnnotLineStyle(PDF_PAGE page, PDF_ANNOT annot);
/**
 *    @brief    Set annotation's line style.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     style     Line style.
 *
 *    @return    true or false..
 */
bool Page_setAnnotLineStyle(PDF_PAGE page, PDF_ANNOT annot, int style);

/**
 *	@brief	Get annotation's fill color.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	RGB color.
 */
int Page_getAnnotFillColor( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set annotation's fill color.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	color 	RGB color.
 *
 *	@return	true or false.
 */
bool Page_setAnnotFillColor( PDF_PAGE page, PDF_ANNOT annot, int color );
/**
 *	@brief	Get annotation's stroke color.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	RGB color.
 */
int Page_getAnnotStrokeColor( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set annotation's stroke color.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	color 	RGBA color.
 *
 *	@return	true or false
 */
bool Page_setAnnotStrokeColor( PDF_PAGE page, PDF_ANNOT annot, int color );
/**
 *	@brief	Get annotation's stroke width.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Annotation's stroke width.
 */
float Page_getAnnotStrokeWidth( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set annotation's stroke width.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	width 	Stroke width.
 *
 *	@return	true or false.
 */
bool Page_setAnnotStrokeWidth( PDF_PAGE page, PDF_ANNOT annot, float width );
/**
 *    @brief    Get annotation's stroke dash.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     dash     Stroke dash value.
 *    @param     max     Stroke dashes max value.
 *
 *    @return    Annotation's stroke dash.
 */
int Page_getAnnotStrokeDash(PDF_PAGE page, PDF_ANNOT annot, float* dash, int max);
/**
 *    @brief    Set annotation's stroke dash.
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     dash     Stroke dash value.
 *    @param     cnt     Stroke dashes count.
 *
 *    @return    true or false.
 */
bool Page_setAnnotStrokeDash(PDF_PAGE page, PDF_ANNOT annot, const float *dash, int cnt);
/**
 *	@brief	Set icon for sticky text note/file attachment annotation.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: you need render page again to show modified annotation.
 *          WARNING: this method is valid in professional or premium version
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	icon 	Icon value depends on annotation type.
 *
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
 *
 *                  For file attachment:
 *                  0: PushPin
 *                  1: Graph
 *                  2: Paperclip
 *                  3: Tag
 *
 *                  For Rubber Stamp:
 *                  0: "Draft"(default icon)
 *                  1: "Approved"
 *                  2: "Experimental"
 *                  3: "NotApproved"
 *                  4: "AsIs"
 *                  5: "Expired"
 *                  6: "NotForPublicRelease"
 *                  7: "Confidential"
 *                  8: "Final"
 *                  9: "Sold"
 *                  10: "Departmental"
 *                  11: "ForComment"
 *                  12: "TopSecret"
 *                  13: "ForPublicRelease"
 *                  14: "Accepted"
 *                  15: "Rejected"
 *                  16: "Witness"
 *                  17: "InitialHere"
 *                  18: "SignHere"
 *                  19: "Void"
 *                  20: "Completed"
 *                  21: "PreliminaryResults"
 *                  22: "InformationOnly"
 *                  23: "End"
 *
 *	@return	true or false.
 */
bool Page_setAnnotIcon( PDF_PAGE page, PDF_ANNOT annot, int icon );
/**
 *    @brief    Set icon for sticky text note/file attachment annotation.
 *              WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *              WARNING: you need render page again to show modified annotation.
 *              WARNING: this method is valid in professional or premium version
 *
 *    @param     page     Specified page object.
 *    @param     annot     Specified annotation object.
 *    @param     icon     Icon value depends on annotation type.
 *    @param     form     Annotation's form.
 *
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
 *
 *                  For file attachment:
 *                  0: PushPin
 *                  1: Graph
 *                  2: Paperclip
 *                  3: Tag
 *
 *                  For Rubber Stamp:
 *                  0: "Draft"(default icon)
 *                  1: "Approved"
 *                  2: "Experimental"
 *                  3: "NotApproved"
 *                  4: "AsIs"
 *                  5: "Expired"
 *                  6: "NotForPublicRelease"
 *                  7: "Confidential"
 *                  8: "Final"
 *                  9: "Sold"
 *                  10: "Departmental"
 *                  11: "ForComment"
 *                  12: "TopSecret"
 *                  13: "ForPublicRelease"
 *                  14: "Accepted"
 *                  15: "Rejected"
 *                  16: "Witness"
 *                  17: "InitialHere"
 *                  18: "SignHere"
 *                  19: "Void"
 *                  20: "Completed"
 *                  21: "PreliminaryResults"
 *                  22: "InformationOnly"
 *                  23: "End"
 *
 *    @return    true or false.
 */
bool Page_setAnnotIcon2(PDF_PAGE page, PDF_ANNOT annot, const char *name, PDF_DOC_FORM form);
/**
 *	@brief	Get icon's value for sticky text note/file attachment or Rubber Stamp annotation.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Icon's value depended on annotation type.
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
 
 *          For Rubber Stamp:
 *          0: "Draft"(default icon)
 *          1: "Approved"
 *          2: "Experimental"
 *          3: "NotApproved"
 *          4: "AsIs"
 *          5: "Expired"
 *          6: "NotForPublicRelease"
 *          7: "Confidential"
 *          8: "Final"
 *          9: "Sold"
 *          10: "Departmental"
 *          11: "ForComment"
 *          12: "TopSecret"
 *          13: "ForPublicRelease"
 *          14: "Accepted"
 *          15: "Rejected"
 *          16: "Witness"
 *          17: "InitialHere"
 *          18: "SignHere"
 *          19: "Void"
 *          20: "Completed"
 *          21: "PreliminaryResults"
 *          22: "InformationOnly"
 *          23: "End"
 */
int Page_getAnnotIcon( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get annotation's goto page number.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	0 based page number. If failed returns -1.
 */
int Page_getAnnotDest( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief		Get annotation's goto URI.
 *              WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Uri's string value.
 */
NSString *Page_getAnnotURI( PDF_PAGE page, PDF_ANNOT annot );
/**
 *  @brief     Get JavaScript string from selected annotation.
 *  @param     page     Specified page object.
 *  @param     annot     Specified annotation object.
 *
 *  @return    JavaScript's string value.
 */
NSString *Page_getAnnotJS(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief     Get additional JavaScript string from selected annotation.
 *  @param     page     Specified page object.
 *  @param     annot     Specified annotation object.
 *
 *  @return    Additional JavaScript's string value.
 */
NSString *Page_getAnnotAdditionalJS(PDF_PAGE page, PDF_ANNOT annot, int idx);
/**
 *	@brief	Get annotation's 3D.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	3D name's string value.
 */
NSString *Page_getAnnot3D( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get annotation's movie.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Movie name's string value.
 */
NSString *Page_getAnnotMovie( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get annotation's audio.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Sound name's string value.
 */
NSString *Page_getAnnotSound( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get annotation's attachment.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Attachment name's string value.
 */
NSString *Page_getAnnotAttachment( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief  Get annotation's 3D data.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	path 	Data's destination path.
 *
 *	@return	true or false.
 */
bool Page_getAnnot3DData( PDF_PAGE page, PDF_ANNOT annot, const char *path );
/**
 *	@brief	Get annotation's movie data.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function valid in professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	path 	Data's destination path.
 *
 *	@return	true or false.
 */
bool Page_getAnnotMovieData( PDF_PAGE page, PDF_ANNOT annot, const char *path );
/**
 *	@brief	Get annotation's audio data.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	paras 	4 element parameters, if paras[0] == 0, means the data is formatted audio, for example( *.mp3 )
                    otherwize it is raw sound data.
 *	@param 	path 	Data's destination path.
 *
 *	@return	true or false.
 */
bool Page_getAnnotSoundData( PDF_PAGE page, PDF_ANNOT annot, int *paras, const char *path );
/**
 *	@brief	Get annotation's attachment data.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid for professional or premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	path 	file to save.
 *
 *	@return	true or false.
 */
bool Page_getAnnotAttachmentData( PDF_PAGE page, PDF_ANNOT annot, const char *path );
/**
 *  @brief  Get annotation's rich media count.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return Annotation's rich media count.
 */
int Page_getAnnotRichMediaItemCount(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Get annotation's rich activated status.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return Activated status.
 */
int Page_getAnnotRichMediaItemActived(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Get annotation's rich media type.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  idx     Rich media's index.
 *
 *  @return Annotation's rich media type.
 */
int Page_getAnnotRichMediaItemType(PDF_PAGE page, PDF_ANNOT annot, int idx);
/**
 *  @brief  Get annotation's rich media asset.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  idx     Rich media's index.
 *
 *  @return Annotation's rich media asset.
 */
NSString *Page_getAnnotRichMediaItemAsset(PDF_PAGE page, PDF_ANNOT annot, int idx);
/**
 *  @brief  Get annotation's rich media param.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  idx     Rich media's index.
 *
 *  @return Annotation's rich media param.
 */
NSString *Page_getAnnotRichMediaItemPara(PDF_PAGE page, PDF_ANNOT annot, int idx);
/**
 *  @brief  Get annotation's rich media source.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  idx     Rich media's index.
 *
 *  @return Annotation's rich media source.
 */
NSString *Page_getAnnotRichMediaItemSource(PDF_PAGE page, PDF_ANNOT annot, int idx);
/**
 *  @brief  Get annotation's rich media source data.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  idx     Rich media's index.
 *  @param  save_path    Source data's destination path.
 *
 *  @return true or false.
 */
bool Page_getAnnotRichMediaItemSourceData(PDF_PAGE page, PDF_ANNOT annot, int idx, NSString *save_path);
/**
 *  @brief  Get annotation's rich media data.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  idx     Rich media's index.
 *  @param  asset    Rich media's asset.
 *  @param  save_path   Rich media data's destination path.
 *
 *  @return true or false.
 */
bool Page_getAnnotRichMediaData(PDF_PAGE page, PDF_ANNOT annot, NSString *asset, NSString *save_path);
/**
 *  @brief  Get annotation's file link
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return Annotation's file link.
 */
NSString* Page_getAnnotFileLink(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Get popup text annotatiion.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return Popup text annotation object.
 */
PDF_ANNOT Page_getAnnotPopup(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Get popup text annotation open state.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return true or false.
 */
bool Page_getAnnotPopupOpen(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Set popup text annotation opened or closed.
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  open    Set popup opened or closed.
 *
 *  @return true or false.
 */
bool Page_setAnnotPopupOpen(PDF_PAGE page, PDF_ANNOT annot, bool open);
/**
 *	@brief	Get popup text annotation's subject.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Subject's string value.
 */
NSString *Page_getAnnotPopupSubject( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set popup text annotation's subject.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	subj 	Subject string.
 *
 *	@return	true or false.
 */
bool Page_setAnnotPopupSubject( PDF_PAGE page, PDF_ANNOT annot, const char *subj );
/**
 *	@brief	Get popup text annotation's text.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Text string value.
 */
NSString *Page_getAnnotPopupText( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set popup text annotation's text.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	text 	text string
 *
 *	@return	true or false.
 */
bool Page_setAnnotPopupText( PDF_PAGE page, PDF_ANNOT annot, const char *text );
/**
 *	@brief	Get popup label annotation's text.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Label's string value.
 */
NSString *Page_getAnnotPopupLabel( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set popup label annotation's text.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	text 	Text string
 *
 *	@return	true or false.
 */
bool Page_setAnnotPopupLabel( PDF_PAGE page, PDF_ANNOT annot, const char *text );
/**
 *	@brief	Get edit-box's type, may either in free-text annotation and widget annotation.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return  -1: This annotation is not text-box.
             1:  Normal single line.
             2:  Password.
             3:  Multiline edit area.
 */
int Page_getAnnotEditType( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get edit-box's rect area, may either for free-text annotation and widget annotation.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	rect 	Output value: rect of edit box.
 *
 *	@return	true or false.
 */
bool Page_getAnnotEditTextRect( PDF_PAGE page, PDF_ANNOT annot, PDF_RECT *rect );
/**
 *	@brief	Get edit-box's text size, may either for free-text annotation and widget annotation.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Text size in PDF coordinate.
 */
float Page_getAnnotEditTextSize( PDF_PAGE page, PDF_ANNOT annot );
/**
 *  @brief  Set edit-box's text size.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified edit-box annotation object.
 *  @param  fsize     Text size's float value.
 *
 *  @return true or false.
 */
bool Page_setAnnotEditTextSize(PDF_PAGE page, PDF_ANNOT annot, float fsize);
/**
 *  @brief  Get edit-box's text alignment.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified edit-box annotation object.
 *
 *  @return Alignment int value.
 */
int Page_getAnnotEditTextAlign(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Set edit-box's text alignment.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified edit-box annotation object.
 *  @param  alin     Alignment int value.
 *
 *  @return true or false.
 */
bool Page_setAnnotEditTextAlign(PDF_PAGE page, PDF_ANNOT annot, int align);
/**
 *	@brief	Get edit-box's text, may either for free-text annotation and widget annotation.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Edit-box's string value.
 */
NSString *Page_getAnnotEditText( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set edit-box's text, may either for free-text annotation and widget annotation.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	text 	text string
 *
 *	@return	true or false
 */
bool Page_setAnnotEditText( PDF_PAGE page, PDF_ANNOT annot, const char *text );
/**
 *  @brief  Set edit-box's font.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  font     Font object.
 *
 *  @return true or false.
 */
bool Page_setAnnotEditFont(PDF_PAGE page, PDF_ANNOT annot, PDF_DOC_FONT font);
/**
 *  @brief  Get edit-box's color.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return hex color.
 */
int Page_getAnnotEditTextColor(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Set edit-box's color.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  color     Hex color.
 *
 *  @return true or false.
 */
bool Page_setAnnotEditTextColor(PDF_PAGE page, PDF_ANNOT annot, int color);
/**
 *  @brief  Export annot's datas to store it externally.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  data       Annotation's data blob that will be populated.
 *  @param  data_len     Data's length that will be populated.
 *
 *  @return return 0 (failure) or 1 (success).
 */
int Page_exportAnnot(PDF_PAGE page, PDF_ANNOT annot, unsigned char *data, int data_len);
/**
 *  @brief  Import  annot from data in specified page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  rect     Rect where annotation will be placed.
 *  @param  data       Annotation's data blob that will be populated.
 *  @param  data_len     Data's length that will be populated.
 *
 *  @return return 0 (failure) or 1 (success).
 */
bool Page_importAnnot(PDF_PAGE page, const PDF_RECT *rect, const unsigned char *data, int data_len);
/**
 *  @brief  Get annot's object reference.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return Annot's object reference.
 */
PDF_OBJ_REF Page_getAnnotRef(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Add annot's from specifed object reference.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  ref     Specified annotation's object reference. (TO DO)
 *
 *  @return true or false.
 */
bool Page_addAnnot(PDF_PAGE page, PDF_OBJ_REF ref);
/**
 *  @brief  Add annot's from specifed object reference at specific index.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  ref     Specified annotation's object reference. (TO DO)
 *  @param  index     Specified index position.
 *
 *  @return true or false.
 */
bool Page_addAnnot2(PDF_PAGE page, PDF_OBJ_REF ref, int index);
/**
 *	@brief	Add an edit-box.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object..
 *	@param 	rect 	Edit-box's rect in PDF coordinate.
 *	@param	line_clr    Edit-box's border hex color.
 *	@param	line_w      Edit-box's border width.
 *	@param	fill_clr    Edit-box's background hex color.
 *	@param 	tsize 	Edit-box's text size.
 *	@param 	text_clr    Text hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotEditbox2( PDF_PAGE page, const PDF_RECT *rect, int line_clr, float line_w, int fill_clr, float tsize, int text_clr );
/**
 *	@brief	Add an edit-box.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to render.
 *	@param 	rect 	Edit-box's rect in PDF coordinate.
 *  @param  line_clr    Edit-box's border hex color.
 *  @param  line_w      Edit-box's border width.
 *  @param  fill_clr    Edit-box's background color.
 *  @param  tsize     Edit-box's text size.
 *  @param  text_clr   Text hex color.
 *
 *	@return	true or false.-
 */
bool Page_addAnnotEditbox( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, int line_clr, float line_w, int fill_clr, float tsize, int text_clr );
/**
 *	@brief	Get Combo-box's items count.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Items count. If returns -1 the annotation is not combo-box.
 */
int Page_getAnnotComboItemCount( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get selected combo-box's item visible text by index.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	item 	0 based item index, range: [0, Page_getAnnotComboItemCount() - 1].
 *
 *	@return	String value.
 */
NSString *Page_getAnnotComboItem( PDF_PAGE page, PDF_ANNOT annot, int item );
/**
 *  @brief  Get selected combo-box's item real value by index.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  item     0 based item index, range: [0, Page_getAnnotComboItemCount() - 1].
 *
 *  @return String value.
 */
NSString *Page_getAnnotComboItemVal(PDF_PAGE page, PDF_ANNOT annot, int item);
/**
 *	@brief	Get combo-box item's selected index.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Item's selected index.
 */
int Page_getAnnotComboItemSel( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set combo-box's selected item.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	item 	Item's index.
 *
 *	@return	true or false.
 */
bool Page_setAnnotComboItem( PDF_PAGE page, PDF_ANNOT annot, int item );
/**
 *	@brief	Get selecetd list-box's items count.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	Items count. If returns -1 the annotation is not list-box.
 */
int Page_getAnnotListItemCount( PDF_PAGE page, PDF_ANNOT annot );
/**
 *  @brief  Check if selected list box is multiselection enabled.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *
 *  @return true or false.
 */
bool Page_isAnnotListMultiSel(PDF_PAGE page, PDF_ANNOT annot);
/**
 *	@brief	Get selected list-box's item visible text by index.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	item 	0 based item index, range: [0, Page_getAnnotListItemCount() - 1]
 *
 *	@return	String value.
 */
NSString *Page_getAnnotListItem( PDF_PAGE page, PDF_ANNOT annot, int item );
/**
 *  @brief  Get selected list-box's item real value by index.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *  @param  page     Specified page object.
 *  @param  annot     Specified annotation object.
 *  @param  item     0 based item index, range: [0, Page_getAnnotListItemCount() - 1]
 *
 *  @return String value.
 */
NSString *Page_getAnnotListItemVal(PDF_PAGE page, PDF_ANNOT annot, int item);
/**
 *	@brief	Get list-box's selected items.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page		Specified page object.
 *	@param 	annot		Specified annotation object.
 *	@param  sels		Int array to revieve selected items.
 *  @param  sels_max	Array length.
 *
 *	@return	The count that filled in int array.
 */
int Page_getAnnotListSels( PDF_PAGE page, PDF_ANNOT annot, int *sels, int sels_max );
/**
 *	@brief	Set list-box's selecetd items.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page		Specified page object.
 *	@param 	annot		Specified annotation object.
 *	@param  sels		Int array to set selected items.
 *  @param  sels_cnt	Array length.
 *
 *	@return	The count that filled in int array.
 */
bool Page_setAnnotListSels( PDF_PAGE page, PDF_ANNOT annot, const int *sels, int sels_cnt );
/**
 *	@brief	Get radio's or check-box's check status.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	 -1 if annotation is not valid control.
             0 if check-box is not checked.
             1 if check-box checked.
             2 if radio-box is not checked.
             3 if radio-box checked.
 */
int Page_getAnnotCheckStatus( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Set value to check-box.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	check 	Check status.
 *
 *	@return	true or false.
 */
bool Page_setAnnotCheckValue( PDF_PAGE page, PDF_ANNOT annot, bool check );
/**
 *	@brief	Set value to radio-box and deselect all other radio-boxes in radio-group.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	true or false.
 */
bool Page_setAnnotRadio( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Check if selected annotation is reset button
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	true or false.
 */
bool Page_getAnnotReset( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Do reset action.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	true or false.
 */
bool Page_setAnnotReset( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get submit's target link.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	String value.
 */
NSString *Page_getAnnotSubmitTarget( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Get submit's parameters.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in premium license.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *	@param 	para 	Output value: parameters' string buffer.
                    In mail mode return whole XML string for form data.
                    In http mode return url data (like: "para1=xxx&para2=xxx").
 *	@param 	len 	         Buffer length.
 *
 *	@return	true or false.
 */
bool Page_getAnnotSubmitPara( PDF_PAGE page, PDF_ANNOT annot, char *para, int len );
/**
 *  @brief  Move selected annot to specified page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *  @param  page_src     Annotation's page source.
 *  @param  page_dst     Annotation's page destination.
 *  @param  annot     Specified annotation object.
 *  @param  rect     Moved annotation's rect in PDF coordinates.
 *
 *  @return true or false.
 */
bool Page_moveAnnot( PDF_PAGE page_src, PDF_PAGE page_dst, PDF_ANNOT annot, const PDF_RECT *rect );
/**
 *  @brief  Copy selected annot to specified page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *  @param  page     Annotation's page destination.
 *  @param  annot     Specified annotation object.
 *  @param  rect     Copied annotation's rect in PDF coordinates.
 *
 *  @return true or false.
 */
bool Page_copyAnnot( PDF_PAGE page, PDF_ANNOT annot, const PDF_RECT *rect );
/**
 *	@brief	Remove selected annotation.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	annot 	Specified annotation object.
 *
 *	@return	true or false.
 */
bool Page_removeAnnot( PDF_PAGE page, PDF_ANNOT annot );
/**
 *	@brief	Add ink annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	 Matrix object passed to Page_render
 *	@param 	hand 	Specified ink object..
 *	@param 	orgx 	x or origin in DIB coordinate.
 *	@param 	orgy 	y or origin in DIB coordinate.
 *
 *	@return	true or false.
 */
bool Page_addAnnotInk( PDF_PAGE page, PDF_MATRIX matrix, PDF_INK hand, float orgx, float orgy );
/**
 *	@brief	Add ink annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	hand 	Specified ink object.. It must be in PDF coordinate.
 *
 *	@return	true or false.
 */
bool Page_addAnnotInk2( PDF_PAGE page, PDF_INK hand );
/**
 *	@brief	Add goto-page annot linked to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	rect 	Link area's rect [left, top, right, bottom] in DIB coordinate.
 *	@param 	pageno 	0 based pageno to goto.
 *	@param 	top 	         y coordinate in PDF coordinate. Page.height is page's top and 0 is page's bottom.
 *
 *	@return	true or false.
 */
bool Page_addAnnotGoto( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, int pageno, float top );
/**
 *	@brief	Add goto-page annot linked to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.

 *
 *	@param 	page 	Specified page object.
 *	@param 	rect 	Link's area rect [left, top, right, bottom] in PDF coordinate.
 *	@param 	pageno 	0 based pageno to goto.
 *	@param 	top 	         y coordinate in PDF coordinate. Page.height is page's top and 0 is page's bottom.
 *
 *	@return	true or false.
 */
bool Page_addAnnotGoto2( PDF_PAGE page, const PDF_RECT *rect, int pageno, float top );
/**
 *	@brief	Add URL link to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	rect 	Link's area rect [left, top, right, bottom] in DIB coordinate.
 *	@param 	uri 	         Url address (example: "http://www.radaee.com/en").
 *
 *	@return	true or false.
 */
bool Page_addAnnotUri( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, const char *uri );
/**
 *	@brief	Add URL link to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	rect 	Link's area rect [left, top, right, bottom] in PDF coordinate.
 *	@param 	uri 	         Url address (example: "http://www.radaee.com/en").
 *
 *	@return	true or false.
 */
bool Page_addAnnotURI2( PDF_PAGE page, const PDF_RECT *rect, const char *uri );
/**
 *	@brief	Add line annot to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	pt1 	Start point, 2 elements for x,y, in DIB coordinate.
 *	@param 	pt2 	End point, 2 elements for x,y, in DIB coordinate.
 *	@param 	style1 	Start point's style:
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
 *	@param 	style2 	End point's style, values are same as style1.
 *	@param 	width 	Line width in DIB coordinate.
 *	@param 	color 	Line hex color.
 *	@param 	icolor 	Fill hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotLine( PDF_PAGE page, PDF_MATRIX matrix, const PDF_POINT *pt1, const PDF_POINT *pt2, int style1, int style2, float width, int color, int icolor );
/**
 *	@brief	Add line annot to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	pt1 	Start point, 2 elements for x,y, in PDF coordinate.
 *	@param 	pt2 	End point, 2 elements for x,y, in PDF coordinate.
 *	@param 	style1 	Start point's style:
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
 *	@param 	style2 	End point's style, values are same as style1.
 *	@param 	width 	Line width in PDF coordinate
 *	@param 	color 	Line hex color.
 *	@param 	icolor 	Fill hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotLine2( PDF_PAGE page, const PDF_POINT *pt1, const PDF_POINT *pt2, int style1, int style2, float width, int color, int icolor );
/**
 *	@brief	Add rect annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	rect 	Rect in DIB coordinate.
 *	@param 	width 	Line width in DIB coordinate.
 *	@param 	color 	Line hex color.
 *	@param 	icolor 	Fill hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotRect( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *	@brief	Add rect annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	rect 	Rect in PDF coordinate.
 *	@param 	width 	Line width in PDF coordinate.
 *	@param 	color 	Line hex color.
 *	@param 	icolor 	Fill hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotRect2( PDF_PAGE page, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *	@brief	Add ellipse annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	rect 	Rect in DIB coordinate.
 *	@param 	width 	Line width in DIB coordinate.
 *	@param 	color 	Line hex color.
 *	@param 	icolor 	Fill hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotEllipse( PDF_PAGE page, PDF_MATRIX matrix, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *	@brief	Add ellipse annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	rect 	Rect in PDF coordinate.
 *	@param 	width 	Line width in PDF coordinate.
 *	@param 	color 	Line hex color.
 *	@param 	icolor 	Fill hex color.
 *
 *	@return	true or false.
 */
bool Page_addAnnotEllipse2( PDF_PAGE page, const PDF_RECT *rect, float width, int color, int icolor );
/**
 *   @brief  Add polygon annotation to page.
             WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
             WARNING: this function is valid in professional or premium license.
             WARNING: you should re-render page to display modified data.
 *
 *   @param  page     Specified page object.
 *   @param  hand     Polygon's path object.
 *   @param  color     Line hex color.
 *   @param  fill_color     Fill hex color.
 *   @param  width     Line width in PDF coordinate.
 *
 *   @return true or false.
 */
bool Page_addAnnotPolygon(PDF_PAGE page, PDF_PATH hand, int color, int fill_color, float width);
/**
 *   @brief  Add polyline annotation to page.
             WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
             WARNING: this function is valid in professional or premium license.
             WARNING: you should re-render page to display modified data.
 *
 *   @param  page     Specified page object.
 *   @param  hand     Polyline's path object.
 *   @param  style1  Start point's style:
 *           0: None
 *           1: Arrow
 *           2: Closed Arrow
 *           3: Square
 *           4: Circle
 *           5: Butt
 *           6: Diamond
 *           7: Reverted Arrow
 *           8: Reverted Closed Arrow
 *           9: Slash
 *   @param  style2     End point's style, values are same as style1.
 *   @param  color     Line hex color.
 *   @param  fill_color     Fill hex color.
 *   @param  width     Line width in PDF coordinate.
 *
 *   @return true or false.
 */
bool Page_addAnnotPolyline(PDF_PAGE page, PDF_PATH hand, int style1, int style2, int color, int fill_color, float width);
/**
 *	@brief	Add popup text annotation to page. It's shown as a text note icon.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	x 	x in DIB coordinate.
 *	@param 	y 	y in DIB coordinate.
 *
 *	@return	true or false.
 */
bool Page_addAnnotText( PDF_PAGE page, PDF_MATRIX matrix, float x, float y );
/**
 *	@brief	Add popup text annotation to page. It's shown as a text note icon.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	x 	x in PDF coordinate.
 *	@param 	y 	y in PDF coordinate.
 *
 *	@return	true or false
 */
bool Page_addAnnotText2( PDF_PAGE page, float x, float y );
/**
 *	@brief	Add bitmap annotation to page
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *	@param 	page 	Specified page object.
 *	@param 	matrix 	Matrix object passed to Page_render.
 *	@param 	dimg 	Bitmap data. It must be in RGBA color space.
 *	@param 	rect 	Rect in PDF coordinate.
 *
 *	@return	true or false.
 */
bool Page_addAnnotBitmap( PDF_PAGE page, PDF_MATRIX matrix, PDF_DOC_IMAGE dimg, const PDF_RECT *rect );
/**
 *  @brief  Add bitmap annotation to page
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *  @param  page     Specified page object.
 *  @param  dimg     Bitmap data. It must be in RGBA color space.
 *  @param  rect     Rect in PDF coordinate.
 *
 *  @return true or false.
 */
bool Page_addAnnotBitmap2( PDF_PAGE page, PDF_DOC_IMAGE dimg, const PDF_RECT *rect );
/**
 *  @brief  Add rich media annotation to page.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *  @param  page     Specified page object.
 *  @param  path_player  Embedded player's path
 *  @param  path_content Embedded content's path.
 *  @param  type    Rich media type.
 *  @param  dimage    Bitmap data. It must be in RGBA color space.
 *  @param  rect     Rect in PDF coordinate.
 *
 *  @return true or false.
 */
bool Page_addAnnotRichMedia(PDF_PAGE page, NSString *path_player, NSString *path_content, int type, PDF_DOC_IMAGE dimage, const PDF_RECT *rect);
/**
 *  @brief  Add popup annotation to page for specified parent annot.
            WARNING: to invoke this function, call Page_objsStart or Page_render methods before.
            WARNING: this function is valid in professional or premium license.
            WARNING: you should re-render page to display modified data.
 *
 *  @param  page     Specified page object.
 *  @param  parent     Specifed annot object in page where popup will be attached.
 *  @param  rect     Rect in PDF coordinate.
 *  @param  open     Popup open status.
 *
 *  @return true or false.
 */
bool Page_addAnnotPopup(PDF_PAGE page, PDF_ANNOT parent, const PDF_RECT *rect, bool open);
/**
 *	@brief	Add a text-markup annotation to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	index1 	First char index.
 *	@param 	index2 	Second char index.
 *	@param 	color 	Markup hex color value.
 *	@param 	type 	Type as following:
 *                  0: Highlight
 *                  1: Underline
 *                  2: StrikeOut
 *                  3: Highlight without round corner
 *                  4: Squiggly underline.
 *
 *	@return	true or false.
 */
bool Page_addAnnotMarkup2( PDF_PAGE page, int index1, int index2, int color, int type );
/**
 *  @brief  Get markup annot's rects count.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *  @param  page        Specified page object.
 *  @param  annot      Specified annot object.
 *  @param  rects      Rectangles array, each 4 elements: left, top, right, bottom in DIB coordinate system.
 *  @param  cnt           Markup's count that will be populate.
 *
 *  @return 0 (success) or 1 (failure).
 */
int Page_getAnnotMarkupRects(PDF_PAGE page, PDF_ANNOT annot, PDF_RECT *rects, int cnt);
/**
 * @brief	Add a Rubber Stamp annot to page.
 *		    WARNING: you should re-render page to display modified data.
 *		    WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *		    WARNING: this method valid in professional or premium version.
 *  @param  page        Specified page object.
 *	@param  rect        Icon's area rect [left, top, right, bottom] in PDF coordinate.
 *	@param  icon        Predefined value as below:
 *                  0: "Draft"(default icon)
 *                  1: "Approved"
 *                  2: "Experimental"
 *                  3: "NotApproved"
 *                  4: "AsIs"
 *                  5: "Expired"
 *                  6: "NotForPublicRelease"
 *                  7: "Confidential"
 *                  8: "Final"
 *                  9: "Sold"
 *                  10: "Departmental"
 *                  11: "ForComment"
 *                  12: "TopSecret"
 *                  13: "ForPublicRelease"
 *                  14: "Accepted"
 *                  15: "Rejected"
 *                  16: "Witness"
 *                  17: "InitialHere"
 *                  18: "SignHere"
 *                  19: "Void"
 *                  20: "Completed"
 *                  21: "PreliminaryResults"
 *                  22: "InformationOnly"
 *                  23: "End"
 *  @return true or false.
 *         The added annotation can be obtained by Page.GetAnnot(Page.GetAnnotCount() - 1), if this method return true.
 */
bool Page_addAnnotStamp( PDF_PAGE page, const PDF_RECT *rect, int icon );
/**
 *	@brief	Add a file as attachment annot to page.
 *          WARNING: you should re-render page to display modified data.
 *          WARNING: this can be invoked after ObjsStart or Render or RenderToBmp.
 *          WARNING: this method valid in professional or premium version.
 *
 *	@param 	page 	Specified page object.
 *	@param 	path 	Absolute path name to the file.
 *	@param 	icon 	Icon that will be displayed to the page. values as:
 *                  0: PushPin
 *                  1: Graph
 *                  2: Paperclip
 *                  3: Tag
 *	@param 	rect 	Rect where place annotation in PDF coordinate system.
 *
 *	@return	true or false.
 */
bool Page_addAnnotAttachment( PDF_PAGE page, const char *path, int icon, const PDF_RECT *rect );
/**
 *	@brief	Create ink object for handwriting.
 *
 *	@param 	line_w 	Line width
 *	@param 	color 	Hex color value for ink color.
 *
 *	@return	Ink object.
 */
PDF_INK Ink_create( float line_w, int color );
/**
 *	@brief	Destroy Ink object.
 *
 *	@param 	ink 	Specified ink object.
 */
void Ink_destroy( PDF_INK ink );
/**
 *	@brief	Invoked on handwriting touch-down event.
 *
 *	@param 	ink   Specified ink object.
 *	@param 	x 	 x position.
 *	@param 	y 	 y position.
 */
void Ink_onDown( PDF_INK ink, float x, float y );
/**
 *	@brief	Invoked on handwriting touch-moving event.
 *
 *	@param 	ink 	Specified ink object.
 *	@param 	x 	x positon.
 *	@param 	y 	y position.
 */
void Ink_onMove( PDF_INK ink, float x, float y );
/**
 *	@brief	Invoked on handwriting touch-up event.
 *
 *	@param 	ink 	Specified ink object.
 *	@param 	x 	x position.
 *	@param 	y 	y position.
 */
void Ink_onUp( PDF_INK ink, float x, float y );
/**
 *	@brief	Get ink's node count.
 *
 *	@param 	ink 	Specified ink object.
 *
 *	@return	Nodes count.
 */
int Ink_getNodeCount( PDF_INK ink );
/**
 *	@brief	Get node by index.
 *
 *	@param 	hand 	Specified ink object.
 *	@param 	index 	0 based index, range: [0, Ink_getNodeCount() - 1].
 *	@param 	pt 	Position pointer.
 *
 *	@return	Node's type:
            0: move to
            1: line to
            2: cubic bezier to.
 */
int Ink_getNode( PDF_INK hand, int index, PDF_POINT *pt );
/**
 *	@brief	Create a contour.
 *
 *	@return	PDF_PATH object
 */
PDF_PATH Path_create(void);
/**
 *	@brief	Move-to operation.
 *
 *	@param 	path 	Specified path object.
 *	@param 	x 	x value.
 *	@param 	y 	y value.
 */
void Path_moveTo( PDF_PATH path, float x, float y);
/**
 *	@brief	Line-to operation.
 *
 *	@param 	path 	Specified path object.
 *	@param 	x 	x value.
 *	@param 	y 	y value.
 */
void Path_lineTo( PDF_PATH path, float x, float y);
/**
 *	@brief	Curve-to operation.
 *
 *	@param 	path 	Specified path object.
 *	@param 	x1 	x1 value.
 *	@param 	y1 	y1 value.
 *	@param 	x2 	x2 value.
 *	@param 	y2 	y2 value.
 *	@param 	x3 	x3 value.
 *	@param 	y3 	y3 value.
 */
void Path_curveTo( PDF_PATH path, float x1, float y1, float x2, float y2, float x3, float y3 );
/**
 *	@brief	Close a contour.
 *
 *	@param 	path 	Specified path object.
 */
void Path_closePath( PDF_PATH path );
/**
 *	@brief	Free memory from a contour.
 *
 *	@param 	path 	Specified path object.
 */
void Path_destroy( PDF_PATH path );
/**
 *	@brief	Get nodes count.
 *
 *	@param 	path Specified path object.
 *
 *	@return	Nodes count.
 */
int Path_getNodeCount( PDF_PATH path );
/**
 *	@brief	Get each node.
 *
 *	@param 	path 	Specified path object.
 *	@param 	index 	Range [0, GetNodeCount() - 1].
 *	@param 	pt 	Output value: 2 elements coordinate point.
 *
 *	@return	Node's type:
 *          0: move to
 *          1: line to
 *          3: curve to, index, index + 1, index + 2 are all data
 *          4: close operation
 */
int Path_getNode( PDF_PATH path, int index, PDF_POINT *pt );
/**
 *	@brief	Create PAGECONTENT object.
 *
 *	@return	PDF_PAGECONTENT object.
 */
PDF_PAGECONTENT PageContent_create(void);
/**
 *	@brief	PDF operator: save current GraphicState.
 *
 *	@param 	content PDF_PAGECONTENT object.
 */
void PageContent_gsSave( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: restore GraphicState.
 *
 *	@param 	content PDF_PAGECONTENT object.
 */
void PageContent_gsRestore( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: set ExtGraphicState.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	gs 	ResGState object created by Page.AddResGState().
 */
void PageContent_gsSet( PDF_PAGECONTENT content, PDF_PAGE_GSTATE gs );
/**
 *	@brief	PDF operator: set matrix.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	mat 	Matrix object.
 */
void PageContent_gsSetMatrix( PDF_PAGECONTENT content, PDF_MATRIX mat );
/**
 *	@brief	PDF operator: begin text and set text position to (0,0).
 *
 *	@param 	content PDF_PAGECONTENT object.
 */
void PageContent_textBegin( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: text end.
 *
 *	@param 	content PDF_PAGECONTENT object.
 */
void PageContent_textEnd( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: show image.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	img 	 Image object created by Page.AddResImage()
 */
void PageContent_drawImage( PDF_PAGECONTENT content, PDF_PAGE_IMAGE img );
/**
 *  @brief  PDF operator: show image.
 *
 *  @param  content PDF_PAGECONTENT object.
 *  @param  form      Form object created by Page.AddFormResForm().
 */
void PageContent_drawForm(PDF_PAGECONTENT content, PDF_PAGE_FORM form);
/**
 *	@brief	PDF operator: draw text
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	text 	 Text to show, '\r' or '\n' in string start a new line.
 */
void PageContent_drawText( PDF_PAGECONTENT content, const char *text );
/**
 *  @brief  PDF operator: draw text
 *
 *  @param  content PDF_PAGECONTENT object.
 *  @param  text      Text to show, '\r' or '\n' in string start a new line.
 *  @param  align      Text's alignment.
 *  @param  width      Text's width.
 *
 *  @return  0 (failure) or 1 (success).
 */
int PageContent_drawText2(PDF_PAGECONTENT content, const char* text, int align, float width);
/**
 *  @brief  PDF operator: draw text
 *
 *  @param  content PDF_PAGECONTENT object.
 *  @param  text      Text to show, '\r' or '\n' in string start a new line.
 *  @param  align      Text's alignment.
 *  @param  width      Text's width.
 *  @param  max_lines      Max lines accepted.
 *
 *  @return  0 (failure) or 1 (success).
 */
int PageContent_drawText3(PDF_PAGECONTENT content, const char* text, int align, float width, int max_lines);
/**
 *	@brief	PDF operator: stroke path.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	path 	Path object.
 */
void PageContent_strokePath( PDF_PAGECONTENT content, PDF_PATH path );
/**
 *	@brief	PDF operator: fill path.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	path 	Path object
 *	@param 	winding 	Winding fill rule.
 */
void PageContent_fillPath( PDF_PAGECONTENT content, PDF_PATH path, bool winding );
/**
 *	@brief	PDF operator: set the path as clip path.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	path 	Path object.
 *	@param 	winding 	Winding fill rule.
 */
void PageContent_clipPath( PDF_PAGECONTENT content, PDF_PATH path, bool winding );
/**
 *	@brief	PDF operator: Set fill and other operations color.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	color 	Formatted as hex color without alpha channel (0xRRGGBB). Alpha value shall set by ExtGraphicState(ResGState).
 */
void PageContent_setFillColor( PDF_PAGECONTENT content, int color );
/**
 *	@brief	PDF operator: set stroke color.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	color 	Formatted as hex color without alpha channel (0xRRGGBB). Alpha value shall set by ExtGraphicState(ResGState).
 */
void PageContent_setStrokeColor( PDF_PAGECONTENT content, int color );
/**
 *	@brief	PDF operator: set line cap.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	cap 	Cap's type:
 *              0: butt
 *              1: round
 *              2: square
 */
void PageContent_setStrokeCap( PDF_PAGECONTENT content, int cap );
/**
 *	@brief	PDF operator: set line join.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	join  Join's type:
 *               0: miter.
 *               1: round.
 *               2: bevel.
 */
void PageContent_setStrokeJoin( PDF_PAGECONTENT content, int join );
/**
 *	@brief	PDF operator: set line width.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	w 	Line width in PDF coordinate.
 */
void PageContent_setStrokeWidth( PDF_PAGECONTENT content, float w );
/**
 *	@brief	PDF operator: set miter limit.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	miter     Miter limit.
 */
void PageContent_setStrokeMiter( PDF_PAGECONTENT content, float miter );
/**
 *	@brief	PDF operator: set char space (extra space between chars).
 *
 *	@param 	content  PDF_PAGECONTENT object.
 *	@param 	space 	Char space.
 */
void PageContent_textSetCharSpace( PDF_PAGECONTENT content, float space );
/**
 *	@brief	PDF operator: set word space (extra space between words spit by blank char ' ' ).
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	space     Word space.
 */
void PageContent_textSetWordSpace( PDF_PAGECONTENT content, float space );
/**
 *	@brief	PDF operator: set text leading, height between 2 text lines.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	leading 	leading in PDF coordinate
 */
void PageContent_textSetLeading( PDF_PAGECONTENT content, float leading );
/**
 *	@brief	PDF operator: set text's rise
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	rise 	Text's rise value.
 */
void PageContent_textSetRise( PDF_PAGECONTENT content, float rise );
/**
 *	@brief	PDF operator: set horizontal scale for chars.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	scale 	Scale value (100 means scale value 1.0f).
 */
void PageContent_textSetHScale( PDF_PAGECONTENT content, int scale );
/**
 *	@brief	PDF operator: new text line.
 *
 *	@param 	content PDF_PAGECONTENT object.
 */
void PageContent_textNextLine( PDF_PAGECONTENT content );
/**
 *	@brief	PDF operator: move text position relative to previous line.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	x 	x position in PDF coordinate.
 *	@param 	y 	y positioin in PDF coordinate.
 */
void PageContent_textMove( PDF_PAGECONTENT content, float x, float y );
/**
 *	@brief	Set text font.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	font 	ResFont object created by Page.AddResFont()
 *	@param 	size 	Text size in PDF coordinate.
 */
void PageContent_textSetFont( PDF_PAGECONTENT content, PDF_PAGE_FONT font, float size );
/**
 *	@brief	PDF operator: set text render mode.
 *
 *	@param 	content PDF_PAGECONTENT object.
 *	@param 	mode  Mode value:
 *          0: Filling
 *          1: Stroke
 *          2: Fill and stroke
 *          3: Do nothing
 *          4: Fill and set clip path
 *          5: Stroke and set clip path
 *          6: Fill/stroke/clip
 *          7: Set clip path.
 */
void PageContent_textSetRenderMode( PDF_PAGECONTENT content, int mode );
/**
 *	@brief	Destroy and free memory.
 *
 *	@param 	content PDF_PAGECONTENT object.
 */
void PageContent_destroy( PDF_PAGECONTENT content );
/**
 *	@brief	Add a font as selected page's resource.
 *          WARNING: Premium license is needed for this method.
 *
 *	@param 	page 	Specified page object.
 *	@param 	font 	Specified font object.
 *
 *	@return	PDF_PAGE_FONT object. If returns null meas failed.
 */
PDF_PAGE_FONT Page_addResFont( PDF_PAGE page, PDF_DOC_FONT font );
/**
 *	@brief	Add an image as selected page's resource.
 *          WARNING: Premium license is needed for this method.
 *
 *	@param 	page 	Specified page object.
 *	@param 	image 	Specified image object. It could be created by Document.NewImage() or Document.NewImageJPEG()
 *
 *	@return	PDF_PAGE_IMAGE object. If returns null meas failed.
 */
PDF_PAGE_IMAGE Page_addResImage( PDF_PAGE page, PDF_DOC_IMAGE image );
/**
 *	@brief	Add GraphicState as selected page's resource.
 *          WARNING: Premium license is needed for this method.
 *
 *	@param 	page 	Specified page object.
 *	@param 	gstate 	Specified ExtGraphicState object. It could be created by Document.NewGState()
 *
 *	@return	PDF_PAGE_GSTATE object. If returns null meas failed.
 */
PDF_PAGE_GSTATE Page_addResGState( PDF_PAGE page, PDF_DOC_GSTATE gstate );
/**
 *  @brief  Add a form as selected page's resource.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  form     Specified document's form object. It could be created by Document.NewForm()
 *
 *  @return PDF_PAGE_FORM object. If returns null meas failed.
 */
PDF_PAGE_FORM Page_addResForm(PDF_PAGE page, PDF_DOC_FORM form);
/**
 *	@brief	Add content stream to this page.
 *          WARNING: Premium license is needed for this method.
 *
 *	@param 	page 	Specified page object.
 *	@param 	content 	PageContent object called PageContent.create().
 *  @param  flush   All resources need flush flag. Set true, if you want render page after this method. If it is false, added texts won't displayed till Document.Save() or Document.SaveAs() invoked.
 *
 *	@return	true or false.
 */
bool Page_addContent( PDF_PAGE page, PDF_PAGECONTENT content, bool flush );
/**
 *  @brief  Start reflow to this page.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  width   Width value.
 *  @param  ratio   Ratio value.
 *
 *  @return  Reflow's needed height.
 */
float Page_reflowStart( PDF_PAGE page, float width,  float ratio );
/**
 *  @brief  Reflow to DIB.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  dib   DIB to render.
 *  @param  orgx   x origin coordinate.
 *  @param  orgy   y origin coordnate.
 *
 *  @return  true or false.
 */
bool Page_reflow( PDF_PAGE page, PDF_DIB dib, float orgx, float orgy );
/**
 *  @brief  Get reflow paragraph count.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *
 *  @return  Paragraph's count.
 */
int Page_reflowGetParaCount( PDF_PAGE page );
/**
 *  @brief  Get one paragraph's char count.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph   Paragraph index range[0, ReflowGetParaCount()-1].
 *
 *  @return  Chars count.
 */
int Page_reflowGetCharCount( PDF_PAGE page, int iparagraph );
/**
 *  @brief  Get char's font width.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph   Paragraph index range[0, ReflowGetParaCount()-1].
 *  @param  ichar   Char index range[0, ReflowGetCharCount()].
 *
 *  @return  Char's font width.
 */
float Page_reflowGetCharWidth( PDF_PAGE page, int iparagraph, int ichar );
/**
 *  @brief  Get char's font height.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph   Paragraph index range[0, ReflowGetParaCount()-1].
 *  @param  ichar   Char index range[0, ReflowGetCharCount()].
 *
 *  @return  Char's font height.
 */
float Page_reflowGetCharHeight( PDF_PAGE page, int iparagraph, int ichar );
/**
 *  @brief  Get char's fill color for display.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph   Paragraph index range[0, ReflowGetParaCount()-1].
 *  @param  ichar   Char index range[0, ReflowGetCharCount()].
 *
 *  @return  Color value formatted 0xAARRGGBB, AA: alpha value, RR:red, GG:green, BB:blue.
 */
int Page_reflowGetCharColor( PDF_PAGE page, int iparagraph, int ichar );
/**
 *  @brief  Get char's unicode value.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph   Paragraph index range[0, ReflowGetParaCount()-1].
 *  @param  ichar   Char index range[0, ReflowGetCharCount()].
 *
 *  @return  Char's unicode value.
 */
int Page_reflowGetCharUnicode( PDF_PAGE page, int iparagraph, int ichar );
/**
 *  @brief  Get char's font name.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  ichar   Char index range[0, ReflowGetCharCount()].
 *
 *  @return  Font name.
 */
const char *Page_reflowGetCharFont( PDF_PAGE page, int iparagraph, int ichar );
/**
 *  @brief  Get char's bound box.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph   Paragraph index range[0, ReflowGetParaCount()-1].
 *  @param  ichar   Char index range[0, ReflowGetCharCount()].
 *  @param  rect   Rect objct. It will be the output: 4 element as [left, top, right, bottom].
 *
 *  @return  Color value formatted 0xAARRGGBB, AA: alpha value, RR:red, GG:green, BB:blue.
 */
void Page_reflowGetCharRect( PDF_PAGE page, int iparagraph, int ichar, PDF_RECT *rect );
/**
 *  @brief  Get text from range.
 *          WARNING: Premium license is needed for this method.
 *
 *  @param  page     Specified page object.
 *  @param  iparagraph1   Paragraph first position with index range[0, ReflowGetParaCount()-1].
 *  @param  ichar1   Char first position with index range[0, ReflowGetCharCount()].
 *  @param  iparagraph2   Paragraph second position with index range[0, ReflowGetParaCount()-1].
 *  @param  ichar2  Char first position with index range[0, ReflowGetCharCount()].
 *  @param  buf   Buffer to fill in UTF-8 coding.
 *  @param  buf_size    Buffer's size that allocated.
 *
 *  @return  true or false.
 */
bool Page_reflowGetText( PDF_PAGE page, int iparagraph1, int ichar1, int iparagraph2, int ichar2, char *buf, int buf_len );
/**
 *  @brief  Get array's items count
 *  @param  hand    Specified pdf object.
 *
 *  @return Item's count.
 */
int Obj_dictGetItemCount(PDF_OBJ hand);
/**
 *  @brief  Get pdf object's name from a dictionary by index.
 *  @param  hand    Specified pdf object.
 *  @param  index    Index value.
 *
 *  @return Item's name.
 */
const char *Obj_dictGetItemName(PDF_OBJ hand, int index);
/**
 *  @brief  Get pdf object from a dictionary by index.
 *  @param  hand    Specified pdf object.
 *  @param  index    Index value.
 *
 *  @return Item at specified index.
 */
PDF_OBJ Obj_dictGetItemByIndex(PDF_OBJ hand, int index);
/**
 *  @brief  Get pdf object from a dictionary by name.
 *  @param  hand    Specified pdf object.
 *  @param  name    Pdf object's name.
 *
 *  @return Item at specified index.
 */
PDF_OBJ Obj_dictGetItemByName(PDF_OBJ hand, const char *name);
/**
 *  @brief  Set empty pdf object to item by name.
 *  @param  hand    Specified pdf object.
 *  @param  name    Pdf object's name.
 *
 *  @return Item by name.
 */
void Obj_dictSetItem(PDF_OBJ hand, const char *name);
/**
 *  @brief  Remove item by name.
 *  @param  hand    Specified pdf object.
 *  @param  name    Pdf object's name.
 *
 */
void Obj_dictRemoveItem(PDF_OBJ hand, const char *name);
/**
 *  @brief  Get item's count of specified pdf object.
 *  @param  hand    Specified pdf object.
 *
 *  @return Item's count.
 */
int Obj_arrayGetItemCount(PDF_OBJ hand);
/**
 *  @brief  Get pdf object's item in array at specified index.
 *  @param  hand    Specified pdf object.
 *  @param  index    Index value.
 *
 *  @return Item at index.
 */
PDF_OBJ Obj_arrayGetItem(PDF_OBJ hand, int index);
/**
 *  @brief  Add pdf object's item into specified array's tail.
 *  @param  hand    Specified pdf object.
 *
 */
void Obj_arrayAppendItem(PDF_OBJ hand);
/**
 *  @brief  Add pdf object's item into specified array at index.
 *  @param  hand    Specified pdf object.
 *  @param  index    Index value.
 *
 */
void Obj_arrayInsertItem(PDF_OBJ hand, int index);
/**
 *  @brief  Remove pdf object's item  at index.
 *  @param  hand    Specified pdf object.
 *  @param  index    Index value.
 *
 */
void Obj_arrayRemoveItem(PDF_OBJ hand, int index);
/**
 *  @brief  Clear pdf object's specified array.
 *  @param  hand    Specified pdf object.
 *  @param  index    Index value.
 *
 */
void Obj_arrayClear(PDF_OBJ hand);
/**
 *  @brief  Get boolean from specified pdf object.
 *  @param  hand    Specified pdf object.
 *
 *  @return Bool value.
 */
bool Obj_getBoolean(PDF_OBJ hand);
/**
 *  @brief  Set specified pdf object's boolean.
 *  @param  hand    Specified pdf object.
 *  @param  v   Bool value
 *
 */
void Obj_setBoolean(PDF_OBJ hand, bool v);
/**
 *  @brief  Get int from specified pdf object.
 *  @param  hand    Specified pdf object.
 *
 *  @return Int value.
 */
int Obj_getInt(PDF_OBJ hand);
/**
 *  @brief  Set specified pdf object's int.
 *  @param  hand    Specified pdf object.
 *  @param  v   Int value.
 *
 */
void Obj_setInt(PDF_OBJ hand, int v);
/**
 *  @brief  Get float from specified pdf object.
 *  @param  hand    Specified pdf object.
 *
 *  @return Float value.
 */
float Obj_getReal(PDF_OBJ hand);
/**
 *  @brief  Set specified pdf object's float.
 *  @param  hand    Specified pdf object.
 *  @param  v   Float value.
 *
 */
void Obj_setReal(PDF_OBJ hand, float v);
/**
 *  @brief  Get specified pdf object's name.
 *  @param  hand    Specified pdf object.
 *
 *  @return Name value.
 */
const char *Obj_getName(PDF_OBJ hand);
/**
 *  @brief  Set specified pdf object's name.
 *  @param  hand    Specified pdf object.
 *  @param  v   Name value.
 *
 */
void Obj_setName(PDF_OBJ hand, const char *v);
/**
 *  @brief  Get specified pdf object's string value.
 *  @param  hand    Specified pdf object.
 *
 *  @return String value.
 */
NSString *Obj_getAsciiString(PDF_OBJ hand);
/**
 *  @brief  Get specified pdf object's unicode string.
 *  @param  hand    Specified pdf object.
 *  @param  len     String's length.
 *
 *  @return Unicode string value.
 */
NSString *Obj_getTextString(PDF_OBJ hand);
/**
 *  @brief  Get specified pdf object's binary string.
 *  @param  hand    Specified pdf object.
 *  @param  len     String's length.
 *
 *  @return Binary string value.
 */
unsigned char *Obj_getHexString(PDF_OBJ hand, int *len);
/**
 *  @brief  Set specified pdf object's string.
 *  @param  hand    Specified pdf object.
 *  @param  v   String value.
 *
 */
void Obj_setAsciiString(PDF_OBJ hand, const char *v);
/**
 *  @brief  Set specified pdf object's unicode string.
 *  @param  hand    Specified pdf object.
 *  @param  v   Unicode string value.
 *
 */
void Obj_setTextString(PDF_OBJ hand, const char *v);
/**
 *  @brief  Set specified pdf object's binary string.
 *  @param  hand    Specified pdf object.
 *  @param  v   Binary string value.
 *  @param  len     String's length.
 *
 */
void Obj_setHexString(PDF_OBJ hand, unsigned char *v, int len);
/**
 *  @brief  Get cross reference from pdf object.
 *  @param  hand    Specified pdf object.
 *
 *  @return PDF cross  reference item.
 */
PDF_OBJ_REF Obj_getReference(PDF_OBJ hand);
/**
 *  @brief  Set specified pdf object's cross reference.
 *  @param  hand    Specified pdf object.
 *  @param  v   Cross reference item.
 *
 */
void Obj_setReference(PDF_OBJ hand, PDF_OBJ_REF v);
/**
 *  @brief  Get pdf object's type.
 *  @param  hand    Specified pdf object.
 *
 *  @return Type int value.
 */
int Obj_getType(PDF_OBJ hand);
/**
 *  @brief  Advanced function to get object from document to edit.
            WARNING: this function is valid in premium license.
 *  @param  hand    Specified pdf object.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ Document_advGetObj(PDF_DOC doc, PDF_OBJ_REF ref);
/**
 *  @brief  Advanced function to create an empty indirect object to edit.
            WARNING: this method require premium license.
 *  @param  doc    Specified document object.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Document_advNewIndirectObj(PDF_DOC doc);
/**
 *  @brief  Advanced function to create an empty indirect object to edit.
            WARNING: this method require premium license.
 *  @param  doc    Specified document object.
 *  @param  obj_hand    PDF object handle.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Document_advNewIndirectObjWithData(PDF_DOC doc, PDF_OBJ obj_hand);
/**
 *  @brief  Advanced function to get reference of catalog object(root object of PDF).
            WARNING: this method require premium license.
 *  @param  doc    Specified document object.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Document_advGetRef(PDF_DOC doc);
/**
 *  @brief  Advanced function to reload document objects.
            WARNING: this method require premium license.
            WARNING: all pages object return from Document.GetPage() shall not available, after this method invoked.
 *  @param  doc    Specified document object.
 */
void Document_advReload(PDF_DOC doc);
/**
 *  @brief  Advanced function to create a stream using zflate compression(zlib).
            Stream byte contents can't modified once created.
            The byte contents shall auto compress and encrypt by native library.
            WARNING: This method require premium license, and need Document.SetCache() invoked.
 *  @param  doc    Specified document object.
 *  @param  source   Stream byte source.
 *  @param  len     Byte int lenght value.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Document_advNewFlateStream(PDF_DOC doc, const unsigned char *source, int len);
/**
 *  @brief  Advanced function to create a stream using raw data.
            On passing compressed data to this method, shall modify dictionary of this stream.
            The byte contents shall auto encrypt by native library (if document encrypted).
            WARNING: this method require premium license, and need Document.SetCache() invoked.
 *  @param  doc    Specified document object.
 *  @param  source   Stream byte source.
 *  @param  len     Byte int lenght value.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Document_advNewRawStream(PDF_DOC doc, const unsigned char *source, int len);
/**
 *  @brief  Advanced function to get specified annot object's reference.
            WARNING: this method require premium license.
 *  @param  page    Specified page object.
 *  @param  annot    Specified annot object.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Page_advGetAnnotRef(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Advanced function to get specified page object's reference.
            WARNING: this method require premium license.
 *  @param  page    Specified page object.
 *
 *  @return PDF cross reference object.
 */
PDF_OBJ_REF Page_advGetRef(PDF_PAGE page);
/**
 *  @brief  Advanced function to reload specified annot object's reference.
            WARNING: this method require premium license.
 *  @param  page    Specified page object.
 *  @param  annot    Specified annot object.
 *
 *  @return PDF cross reference object.
 */
void Page_advReloadAnnot(PDF_PAGE page, PDF_ANNOT annot);
/**
 *  @brief  Advanced function to reload specified page object's reference.
            WARNING: this method require premium license.
 *  @param  page    Specified page object.
 *
 *  @return PDF cross reference object.
 */
void Page_advReload(PDF_PAGE page);

#ifdef __cplusplus
}
#endif

#endif
