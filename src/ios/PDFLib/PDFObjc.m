//
//  PDFDoc.m
//  PDFViewer
//
//  Created by Radaee on 12-9-18.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import "PDFObjc.h"
extern uint annotHighlightColor;
extern uint annotUnderlineColor;
extern uint annotStrikeoutColor;

@implementation PDFSign
@synthesize handle = m_sign;
-(id)init:(PDF_SIGN)sign
{
    if( self = [super init] )
    {
        m_sign = sign;
    }
    return self;
}

-(NSString *)issue
{
	return Sign_getIssue(m_sign);
}
-(NSString *)subject
{
	return Sign_getSubject(m_sign);
}
-(long)version
{
	return Sign_getVersion(m_sign);
}
@end

@implementation PDFDIB
@synthesize handle = m_dib;
-(id)init
{
    if( self = [super init] )
    {
        _cached = false;
	    m_dib = NULL;
    }
    return self;
}

-(id)init:(int)width :(int)height
{
    if( self = [super init] )
    {
	    m_dib = Global_dibGet(NULL, width, height);
        memset([self data],255,width * height *4);
    }
    return self;
}
-(void)resize:(int)newWidth :(int)newHeight
{
    m_dib = Global_dibGet(m_dib, newWidth, newHeight);
}

-(void *)data
{
    return Global_dibGetData(m_dib);
}

-(int)width
{
    return Global_dibGetWidth(m_dib);
}

-(int)height
{
    return Global_dibGetHeight(m_dib);
}
/*
-(void)clear
{
    Global_dibFree(m_dib);
    m_dib = NULL;
}*/

-(void)dealloc
{
    PDF_DIB tmp_dib = m_dib;
    m_dib = NULL;
    Global_dibFree(tmp_dib);
}

-(void)erase:(int)color
{
	int *pix = (int *)Global_dibGetData(m_dib);
	int *pix_end = pix + Global_dibGetWidth(m_dib) * Global_dibGetHeight(m_dib) * 4;
	while(pix < pix_end) *pix++ = color;
}

-(CGImageRef)image
{
    if(!m_dib) return nil;
    void *pdata = Global_dibGetData(m_dib);
    int w = Global_dibGetWidth(m_dib);
    int h = Global_dibGetHeight(m_dib);
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, pdata, w * h * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( w, h, 8, 32, w<<2, cs,
                                   kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst,
                                   provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    return img;
}
@end

@implementation PDFMatrix
@synthesize handle = m_mat;
-(id)init
{
    if( self = [super init] )
    {
	    m_mat = Matrix_createScale(1, 1, 0, 0);
    }
    return self;
}
-(id)init:(float)scalex :(float)scaley :(float)orgx :(float)orgy
{
    if( self = [super init] )
    {
	    m_mat = Matrix_createScale(scalex, scaley, orgx, orgy);
    }
    return self;
}
-(id)init:(float)xx :(float)yx :(float)xy :(float)yy :(float)x0 :(float)y0
{
    if( self = [super init] )
    {
	    m_mat = Matrix_create(xx, yx, xy, yy, x0, y0);
    }
    return self;
}
-(void)invert
{
	Matrix_invert( m_mat );
}
-(void)transformPath:(PDFPath *)path
{
	Matrix_transformPath( m_mat, path.handle );
}
-(void)transformInk:(PDFInk *)ink
{
	Matrix_transformInk( m_mat, ink.handle );
}
-(void)transformRect:(PDF_RECT *)rect
{
	Matrix_transformRect( m_mat, rect );
}
-(void)transformPoint:(PDF_POINT *)point
{
	Matrix_transformPoint( m_mat, point );
}
-(void)dealloc
{
    PDF_MATRIX tmp_mat = m_mat;
    m_mat = NULL;
    Matrix_destroy(tmp_mat);
}
@end

@implementation PDFObj
@synthesize handle = m_obj;
-(id)init:(PDF_OBJ)obj
{
    if( self = [super init] )
    {
	    m_obj = obj;
    }
    return self;
}
-(int)getType
{
	return Obj_getType(m_obj);
}
-(int)getIntVal
{
	return Obj_getInt(m_obj);
}
-(bool)getBoolVal
{
	return Obj_getBoolean(m_obj);
}
-(float)getRealVal
{
	return Obj_getReal(m_obj);
}
-(PDF_OBJ_REF)getReferenceVal
{
	return Obj_getReference(m_obj);
}
-(NSString *)getNameVal
{
	const char *name = Obj_getName(m_obj);
	if(!name) return NULL;
	return [NSString stringWithUTF8String:name];
}
-(NSString *)getAsciiStringVal
{
	const char *name = Obj_getAsciiString(m_obj);
	if(!name) return NULL;
	return [NSString stringWithUTF8String:name];
}
-(NSString *)getTextStringVal
{
	char *buf = (char *)malloc(65536);
	Obj_getTextString(m_obj, buf, 65536);
	NSString *ret = [NSString stringWithUTF8String:buf];
	free(buf);
    return ret;
}
-(const unsigned char *)getHexStrngVal :(int *)len;
{
	if(!len) return NULL;
	return Obj_getHexString(m_obj, len);
}
-(void)setIntVal:(int)v
{
	Obj_setInt(m_obj, v);
}
-(void)setBoolVal:(bool)v
{
	Obj_setBoolean(m_obj, v);
}
-(void)setRealVal:(float)v
{
	Obj_setReal(m_obj, v);
}
-(void)setReferenceVal:(PDF_OBJ_REF)v
{
	Obj_setReference(m_obj, v);
}
-(void)setNameVal:(NSString *)v
{
	if(!v) return;
	Obj_setName(m_obj, [v UTF8String]);
}
-(void)setAsciiStringVal:(NSString *)v
{
	if(!v) return;
	Obj_setAsciiString(m_obj, [v UTF8String]);
}
-(void)setTextStringVal:(NSString *)v
{
	if(!v) return;
	Obj_setTextString(m_obj, [v UTF8String]);
}
-(void)setHexStringVal:(unsigned char *)v :(int)len
{
	if(!v) return;
	Obj_setHexString(m_obj, v,len);
}
-(void)setDictionary
{
	Obj_dictGetItemCount(m_obj);
}
-(int)dictGetItemCount
{
	return Obj_dictGetItemCount(m_obj);
}
-(NSString *)dictGetItemTag:(int)index
{
	const char *tag = Obj_dictGetItemName(m_obj, index);
	if(!tag) return NULL;
	return [NSString stringWithUTF8String:tag];
}
-(PDFObj *)dictGetItemByIndex:(int)index
{
	PDF_OBJ obj = Obj_dictGetItemByIndex(m_obj, index);
	if(!obj) return NULL;
	return [[PDFObj alloc] init:obj];
}
-(PDFObj *)dictGetItemByTag:(NSString *)tag
{
	if(!tag) return NULL;
	PDF_OBJ obj = Obj_dictGetItemByName(m_obj, [tag UTF8String]);
	if(!obj) return NULL;
	return [[PDFObj alloc] init:obj];
}
-(void)dictSetItem:(NSString *)tag
{
	if(!tag) return;
	Obj_dictSetItem(m_obj, [tag UTF8String]);
}
-(void)dictRemoveItem:(NSString *)tag
{
	if(!tag) return;
	Obj_dictRemoveItem(m_obj, [tag UTF8String]);
}
-(void)setArray
{
	Obj_arrayGetItemCount(m_obj);
}
-(int)arrayGetItemCount
{
	return Obj_arrayGetItemCount(m_obj);
}
-(PDFObj *)arrayGetItem:(int)index
{
	PDF_OBJ obj = Obj_arrayGetItem(m_obj, index);
	if(!obj) return NULL;
	return [[PDFObj alloc] init:obj];
}
-(void)arrayAppendItem
{
	Obj_arrayAppendItem(m_obj);
}
-(void)arrayInsertItem:(int)index
{
	Obj_arrayInsertItem(m_obj, index);
}
-(void)arrayRemoveItem:(int)index
{
	Obj_arrayRemoveItem(m_obj, index);
}
-(void)arrayClear
{
	Obj_arrayClear(m_obj);
}
@end

@implementation PDFOutline
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
	    m_doc = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_DOC)doc :(PDF_OUTLINE)handle
{
    if( self = [super init] )
    {
	    m_doc = doc;
		m_handle = handle;
    }
    return self;
}
-(PDFOutline *)next
{
    PDF_OUTLINE outline = Document_getOutlineNext(m_doc, m_handle);
    if( !outline ) return NULL;
    return [[PDFOutline alloc] init:m_doc:outline];
}
-(PDFOutline *)child
{
    PDF_OUTLINE outline = Document_getOutlineChild(m_doc, m_handle);
    if( !outline ) return NULL;
    return [[PDFOutline alloc] init:m_doc:outline];
}
-(int)dest
{
    return Document_getOutlineDest(m_doc, m_handle);
}
-(NSString *)label
{
    char label[512];
    Document_getOutlineLabel(m_doc, m_handle, label, 511);
    return [NSString stringWithUTF8String:label];
}
-(bool)removeFromDoc
{
	return Document_removeOutline( m_doc, m_handle );
}
-(bool)addNext:(NSString *)label :(int)pageno :(float)top
{
    return Document_addOutlineNext(m_doc, m_handle, [label UTF8String], pageno, top);
}
-(bool)addChild:(NSString *)label :(int)pageno :(float)top
{
    return Document_addOutlineChild(m_doc, m_handle, [label UTF8String], pageno, top);
}
@end

@implementation PDFDocFont
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
	    m_doc = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_DOC)doc :(PDF_DOC_FONT)handle
{
    if( self = [super init] )
    {
	    m_doc = doc;
		m_handle = handle;
    }
    return self;
}
-(float)ascent
{
	return Document_getFontAscent(m_doc, m_handle );
}
-(float)descent
{
	return Document_getFontDescent(m_doc, m_handle );
}
@end

@implementation PDFDocGState
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
	    m_doc = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_DOC)doc :(PDF_DOC_GSTATE)handle
{
    if( self = [super init] )
    {
	    m_doc = doc;
		m_handle = handle;
    }
    return self;
}
-(bool)setStrokeAlpha:(int)alpha
{
	return Document_setGStateStrokeAlpha( m_doc, m_handle, alpha );
}
-(bool)setFillAlpha:(int)alpha
{
	return Document_setGStateFillAlpha( m_doc, m_handle, alpha );
}
-(bool)setStrokeDash:(const float *)dash :(int)dash_cnt :(float)phase
{
	return Document_setGStateStrokeDash( m_doc, m_handle, dash, dash_cnt, phase );
}

-(bool)setBlendMode :(int)bmode
{
	return Document_setGStateBlendMode( m_doc, m_handle, bmode );
}

@end

@implementation PDFDocImage
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
	    m_doc = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_DOC)doc :(PDF_DOC_IMAGE)handle
{
    if( self = [super init] )
    {
	    m_doc = doc;
		m_handle = handle;
    }
    return self;
}
@end

@implementation PDFDocForm
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
	    m_doc = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_DOC)doc :(PDF_DOC_FORM)handle
{
    if( self = [super init] )
    {
	    m_doc = doc;
		m_handle = handle;
    }
    return self;
}
-(void)dealloc
{
	if(m_handle && m_doc)
	{
		Document_freeForm(m_doc, m_handle);
		m_handle = NULL;
		m_doc = NULL;
	}
}
-(PDF_PAGE_FONT)addResFont :(PDFDocFont *)font
{
	return Document_addFormResFont(m_doc, m_handle, font.handle);
}
-(PDF_PAGE_IMAGE)addResImage :(PDFDocImage *)img
{
	return Document_addFormResImage(m_doc, m_handle, img.handle);
}
-(PDF_PAGE_GSTATE)addResGState : (PDFDocGState *)gs
{
	return Document_addFormResGState(m_doc, m_handle, gs.handle);
}
-(PDF_PAGE_FORM)addResForm : (PDFDocForm *)form
{
	return Document_addFormResForm(m_doc, m_handle, form.handle);
}
-(void)setContent : (float)x : (float)y : (float)w : (float)h : (PDFPageContent *)content
{
	Document_setFormContent(m_doc, m_handle, x, y, w, h, content.handle);
}
-(void)setTransparency :(bool)isolate :(bool)knockout
{
	Document_setFormTransparency(m_doc, m_handle, isolate, knockout);
}
@end

@implementation PDFFinder
-(id)init
{
    if( self = [super init] )
    {
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_FINDER)handle
{
    if( self = [super init] )
    {
		m_handle = handle;
    }
    return self;
}
-(int)count
{
	return Page_findGetCount(m_handle);
}

-(int)objsIndex:(int)find_index
{
	return Page_findGetFirstChar( m_handle, find_index );
}
-(void)dealloc
{
    Page_findClose(m_handle);
    m_handle = NULL;
}
@end

@implementation PDFPath
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
		m_handle = Path_create();
    }
    return self;
}

-(id)init:(PDF_PATH)path
{
    if( self = [super init] )
    {
		m_handle = path;
    }
    return self;
}

-(void)moveTo:(float)x :(float)y
{
	Path_moveTo( m_handle, x, y );
}
-(void)lineTo:(float)x :(float)y
{
	Path_lineTo( m_handle, x, y );
}
-(void)CurveTo:(float)x1 :(float)y1 :(float)x2 :(float)y2 :(float)x3 :(float)y3
{
	Path_curveTo( m_handle, x1, y1, x2, y2, x3, y3 );
}
-(void)closePath
{
	Path_closePath(m_handle);
}
-(int)nodesCount
{
	return Path_getNodeCount(m_handle);
}
-(int)node:(int)index :(PDF_POINT *)pt
{
	return Path_getNode(m_handle, index, pt);
}
-(void)dealloc
{
    Path_destroy(m_handle);
    m_handle = NULL;
}
@end

@implementation PDFInk
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
		m_handle = NULL;
    }
    return self;
}
-(id)init:(float)line_width :(int)color
{
    if( self = [super init] )
    {
		m_handle = Ink_create(line_width, color);
    }
    return self;
}
-(void)onDown:(float)x :(float)y
{
	Ink_onDown(m_handle, x, y);
}
-(void)onMove:(float)x :(float)y
{
	Ink_onMove(m_handle, x, y);
}
-(void)onUp:(float)x :(float)y
{
	Ink_onUp(m_handle, x, y);
}
-(int)nodesCount
{
	return Ink_getNodeCount(m_handle);
}
-(int)node:(int)index :(PDF_POINT *)pt
{
	return Ink_getNode(m_handle, index, pt);
}
-(void)dealloc
{
    Ink_destroy(m_handle);
    m_handle = NULL;
}
@end

@implementation PDFPageContent
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
		m_handle = PageContent_create();
    }
    return self;
}
-(void)gsSave
{
	PageContent_gsSave( m_handle );
}
-(void)gsRestore
{
	PageContent_gsRestore( m_handle );
}
-(void)gsSet:(PDF_PAGE_GSTATE) gs
{
	PageContent_gsSet( m_handle, gs );
}
-(void)gsCatMatrix:(PDFMatrix *) mat
{
	PageContent_gsSetMatrix( m_handle, mat.handle );
}
-(void)textBegin
{
	PageContent_textBegin( m_handle );
}
-(void)textEnd
{
	PageContent_textEnd( m_handle );
}
-(void)drawImage:(PDF_PAGE_IMAGE) img
{
	PageContent_drawImage( m_handle, img );
}
-(void)drawForm:(PDF_PAGE_FORM) form
{
	PageContent_drawForm( m_handle, form );
}
-(void)drawText:(NSString *)text
{
	PageContent_drawText( m_handle, [text UTF8String] );
}
-(void)strokePath:(PDFPath *) path
{
	PageContent_strokePath( m_handle, path.handle );
}
-(void)fillPath:(PDFPath *)path :(bool) winding
{
	PageContent_fillPath( m_handle, path.handle, winding );
}
-(void)clipPath:(PDFPath *)path :(bool) winding
{
	PageContent_clipPath( m_handle, path.handle, winding );
}
-(void)setFillColor:(int) color
{
	PageContent_setFillColor( m_handle, color );
}
-(void)setStrokeColor:(int) color
{
	PageContent_setStrokeColor( m_handle, color );
}
-(void)setStrokeCap:(int) cap
{
	PageContent_setStrokeCap( m_handle, cap );
}
-(void)setStrokeJoin:(int) join
{
	PageContent_setStrokeJoin( m_handle, join );
}
-(void)setStrokeWidth:(float) w
{
	PageContent_setStrokeWidth( m_handle, w );
}
-(void)setStrokeMiter:(float) miter
{
	PageContent_setStrokeMiter( m_handle, miter );
}
-(void)textSetCharSpace:(float) space
{
	PageContent_textSetCharSpace( m_handle, space );
}
-(void)textSetWordSpace:(float) space
{
	PageContent_textSetWordSpace( m_handle, space );
}
-(void)textSetLeading:(float) leading
{
	PageContent_textSetLeading( m_handle, leading );
}
-(void)textSetRise:(float) rise
{
	PageContent_textSetRise( m_handle, rise );
}
-(void)textSetHScale:(int) scale
{
	PageContent_textSetHScale( m_handle, scale );
}
-(void)textNextLine
{
	PageContent_textNextLine( m_handle );
}
-(void)textMove:(float) x :(float) y
{
	PageContent_textMove( m_handle, x, y );
}
-(void)textSetFont:(PDF_PAGE_FONT) font :(float) size
{
	PageContent_textSetFont( m_handle, font, size );
}
-(void)textSetRenderMode:(int) mode
{
	PageContent_textSetRenderMode( m_handle, mode );
}
-(void)dealloc
{
    PageContent_destroy(m_handle);
    m_handle = NULL;
}
@end

@implementation PDFAnnot
@synthesize handle = m_handle;
-(id)init
{
    if( self = [super init] )
    {
        m_page = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_PAGE)page :(PDF_ANNOT)handle
{
    if( self = [super init] )
    {
	    m_page = page;
		m_handle = handle;
    }
    return self;
}
-(PDF_OBJ_REF)advanceGetRef
{
	return Page_advGetAnnotRef(m_page, m_handle);
}
-(void)advanceReload
{
	Page_advReloadAnnot(m_page, m_handle);
}
-(int)type
{
	return Page_getAnnotType( m_page, m_handle );
}
-(int)export :(unsigned char *)buf :(int)len
{
	return Page_exportAnnot(m_page, m_handle, buf, len);
}
-(int)signField :(PDFDocForm *)appearence :(NSString *)cert_file :(NSString *)pswd :(NSString *)reason :(NSString *)location :(NSString *)contact;
{
	return Page_signAnnotField(m_page, m_handle, [appearence handle], [cert_file UTF8String], [pswd UTF8String], [reason UTF8String], [location UTF8String], [contact UTF8String]);
}

-(int)fieldType
{
	return Page_getAnnotFieldType( m_page, m_handle );
}
-(int)fieldFlag
{
	return Page_getAnnotFieldFlag( m_page, m_handle );
}
-(NSString *)fieldName
{
	char buf[512];
	int len = Page_getAnnotFieldName( m_page, m_handle, buf, 511 );
	if( len <= 0 ) return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)fieldNameWithNO
{
	char buf[512];
	int len = Page_getAnnotFieldNameWithNO( m_page, m_handle, buf, 511 );
	if( len <= 0 ) return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)fieldFullName
{
	char buf[512];
	int len = Page_getAnnotFieldFullName( m_page, m_handle, buf, 511 );
	if( len <= 0 ) return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)fieldFullName2
{
	char buf[512];
	int len = Page_getAnnotFieldFullName2( m_page, m_handle, buf, 511 );
	if( len <= 0 ) return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(bool)isLocked
{
	return Page_isAnnotLocked( m_page, m_handle );
}
-(void)setLocked:(bool)lock
{
	Page_setAnnotLock( m_page, m_handle, lock );
}
-(NSString *)getName
{
    char *stmp = (char *)malloc(1024);
    if(!Page_getAnnotName(m_page, m_handle, stmp, 1023))
    {
        free(stmp);
        return nil;
    }
    NSString *ret = [NSString stringWithUTF8String:stmp];
    free(stmp);
    return ret;
}
-(bool)setName:(NSString *)name
{
	if(!name) return false;
	return Page_setAnnotName(m_page, m_handle, [name UTF8String]);
}
-(bool)isReadonly
{
	return Page_isAnnotReadonly( m_page, m_handle );
}
-(void)setReadonly:(bool)readonly
{
	Page_setAnnotReadonly( m_page, m_handle, readonly );
}
-(bool)isHidden
{
	return Page_isAnnotHide( m_page, m_handle );
}
-(bool)setHidden:(bool)hide
{
	Page_setAnnotHide( m_page, m_handle, hide );
	return true;
}
-(bool)render:(PDFDIB *)dib :(int)back_color
{
	[dib erase:back_color];
	return Page_renderAnnot(m_page, m_handle, [dib handle]);
}
-(void)getRect:(PDF_RECT *)rect
{
	Page_getAnnotRect( m_page, m_handle, rect );
}
-(void)setRect:(const PDF_RECT *)rect
{
	Page_setAnnotRect( m_page, m_handle, rect );
}

-(NSString *)getModDate
{
	const char *sval = Page_getAnnotModifyDate(m_page, m_handle);
	if(!sval) return nil;
	return [NSString stringWithUTF8String:sval];
}

-(bool)setModDate:(NSString *)mdate
{
	return Page_setAnnotModifyDate(m_page, m_handle, [mdate UTF8String]);
}

-(int)getMarkupRects:(PDF_RECT *)rects :(int)cnt
{
	return Page_getAnnotMarkupRects(m_page, m_handle, rects, cnt);
}
-(int)getIndex
{
	int cnt = Page_getAnnotCount(m_page);
	int cur = 0;
	while( cur < cnt )
	{
		if( m_handle == Page_getAnnot(m_page, cur) )
			return cur;
		cur++;
	}
	return -1;
}
-(PDFPath *)getInkPath
{
	PDF_PATH path = Page_getAnnotInkPath( m_page, m_handle );
	if( !path ) return NULL;
	return [[PDFPath alloc] init: path];
}
-(bool)setInkPath:(PDFPath *)path
{
	return Page_setAnnotInkPath( m_page, m_handle, [path handle] );
}

-(PDFPath *)getPolygonPath
{
	PDF_PATH path = Page_getAnnotPolygonPath( m_page, m_handle );
	if( !path ) return NULL;
	return [[PDFPath alloc] init: path];
}
-(bool)setPolygonPath:(PDFPath *)path
{
	return Page_setAnnotPolygonPath( m_page, m_handle, [path handle] );
}

-(PDFPath *)getPolylinePath
{
	PDF_PATH path = Page_getAnnotPolylinePath( m_page, m_handle );
	if( !path ) return NULL;
	return [[PDFPath alloc] init: path];
}
-(bool)setPolylinePath:(PDFPath *)path
{
	return Page_setAnnotPolylinePath( m_page, m_handle, [path handle] );
}


-(int)getFillColor
{
	return Page_getAnnotFillColor( m_page, m_handle );
}
-(bool)setFillColor:(int)color
{
	return Page_setAnnotFillColor( m_page, m_handle, color );
}
-(int)getStrokeColor
{
	return Page_getAnnotStrokeColor( m_page, m_handle );
}
-(bool)setStrokeColor:(int)color
{
	return Page_setAnnotStrokeColor( m_page, m_handle, color );
}
-(float)getStrokeWidth
{
	return Page_getAnnotStrokeWidth( m_page, m_handle );
}
-(bool)setStrokeWidth:(float)width
{
	return Page_setAnnotStrokeWidth( m_page, m_handle, width );
}
-(bool)setStrokeDash:(float *)dash : (int)cnt
{
	return Page_setAnnotStrokeDash( m_page, m_handle, dash, cnt );
}
-(int)getIcon
{
	return Page_getAnnotIcon( m_page, m_handle );
}
-(bool)setIcon:(int)icon
{
	return Page_setAnnotIcon(m_page, m_handle, icon);
}
-(bool)setIcon2:(NSString *)icon_name :(PDFDocForm *)icon
{
	return Page_setAnnotIcon2(m_page, m_handle, [icon_name UTF8String], [icon handle]);
}

-(int)getDest
{
	return Page_getAnnotDest( m_page, m_handle );
}
-(NSString *)getURI
{
	char buf[1024];
	int len = Page_getAnnotURI( m_page, m_handle, buf, 1023 );
	if( len <= 0 ) return NULL;
    buf[len] = 0;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getJS
{
	return Page_getAnnotJS( m_page, m_handle );
}

-(NSString *)getAdditionalJS :(int)idx
{
	return Page_getAnnotAdditionalJS(m_page, m_handle, idx);
}

-(NSString *)get3D
{
	char buf[1024];
	int len = Page_getAnnot3D( m_page, m_handle, buf, 1023 );
	if( len <= 0 ) return NULL;
    buf[len] = 0;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getMovie
{
	char buf[1024];
	int len = Page_getAnnotMovie( m_page, m_handle, buf, 1023 );
	if( len <= 0 ) return NULL;
    buf[len] = 0;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getSound
{
	char buf[1024];
	int len = Page_getAnnotSound( m_page, m_handle, buf, 1023 );
	if( len <= 0 ) return NULL;
    buf[len] = 0;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getAttachment
{
	char buf[1024];
	int len = Page_getAnnotAttachment( m_page, m_handle, buf, 1023 );
	if( len <= 0 ) return NULL;
    buf[len] = 0;
	return [NSString stringWithUTF8String:buf];
}
-(bool)get3DData:(NSString *)save_file
{
	return Page_getAnnot3DData( m_page, m_handle, [save_file UTF8String] );
}
-(bool)getMovieData:(NSString *)save_file
{
	return Page_getAnnotMovieData( m_page, m_handle, [save_file UTF8String] );
}
-(bool)getSoundData:(int *)paras :(NSString *)save_file
{
	return Page_getAnnotSoundData( m_page, m_handle, paras, [save_file UTF8String] );
}
-(bool)getAttachmentData:(NSString *)save_file
{
	return Page_getAnnotAttachmentData( m_page, m_handle, [save_file UTF8String] );
}


-(int)getRichMediaItemCount
{
	return Page_getAnnotRichMediaItemCount(m_page, m_handle);
}

-(int)getRichMediaItemActived
{
	return Page_getAnnotRichMediaItemActived(m_page, m_handle);
}

-(int)getRichMediaItemType:(int) idx
{
	return Page_getAnnotRichMediaItemType(m_page, m_handle, idx);
}

-(NSString *)getRichMediaItemAsset:(int) idx
{
	return Page_getAnnotRichMediaItemAsset(m_page, m_handle, idx);
}

-(NSString *)getRichMediaItemPara:(int) idx
{
	return Page_getAnnotRichMediaItemPara(m_page, m_handle, idx);
}

-(NSString *)getRichMediaItemSource:(int) idx
{
	return Page_getAnnotRichMediaItemSource(m_page, m_handle, idx);
}

-(bool)getRichMediaItemSourceData:(int) idx :(NSString *)save_path
{
	return Page_getAnnotRichMediaItemSourceData(m_page, m_handle, idx, save_path);
}

-(bool)getRichMediaData :(NSString *)asset :(NSString *)save_path
{
	return Page_getAnnotRichMediaData(m_page, m_handle, asset, save_path);
}


-(bool)getPopupOpen
{
	return Page_getAnnotPopupOpen(m_page, m_handle);
}
-(NSString *)getPopupSubject
{
	char buf[1024];
	if( !Page_getAnnotPopupSubject( m_page, m_handle, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getPopupText
{
	char buf[1024];
	if( !Page_getAnnotPopupText( m_page, m_handle, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getPopupLabel
{
	char buf[1024];
	if( !Page_getAnnotPopupLabel( m_page, m_handle, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(bool)setPopupOpen :(bool)open
{
	return Page_setAnnotPopupOpen( m_page, m_handle, open );
}
-(bool)setPopupSubject:(NSString *)val
{
	return Page_setAnnotPopupSubject( m_page, m_handle, [val UTF8String] );
}
-(bool)setPopupText:(NSString *)val
{
	return Page_setAnnotPopupText( m_page, m_handle, [val UTF8String] );
}
-(bool)setPopupLabel:(NSString *)val
{
	return Page_setAnnotPopupLabel( m_page, m_handle, [val UTF8String] );
}
-(int)getEditType
{
	return Page_getAnnotEditType( m_page, m_handle );
}
-(bool)getEditRect:(PDF_RECT *)rect
{
	return Page_getAnnotEditTextRect( m_page, m_handle, rect );
}
-(float)getEditTextSize
{
	return Page_getAnnotEditTextSize( m_page, m_handle );
}
-(bool)setEditTextSize:(float)fsize
{
	return Page_setAnnotEditTextSize( m_page, m_handle, fsize );
}
-(NSString *)getEditText
{
	char buf[1024];
	if( !Page_getAnnotEditText( m_page, m_handle, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}

-(NSString *)getFieldJS:(int)idx
{
	char buf[1024];
	if( !Page_getAnnotFieldJS( m_page, m_handle, idx, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}

-(bool)setEditText:(NSString *)val
{
	return Page_setAnnotEditText( m_page, m_handle, [val UTF8String] );
}
-(bool)setEditFont:(PDFDocFont *)font
{
	if(!font) return false;
	return Page_setAnnotEditFont( m_page, m_handle, font.handle );
}

-(int)getEditTextColor
{
	return Page_getAnnotEditTextColor( m_page, m_handle );
}
-(bool)setEditTextColor:(int)color
{
	return Page_setAnnotEditTextColor( m_page, m_handle, color );
}

-(int)getComboItemCount
{
	return Page_getAnnotComboItemCount( m_page, m_handle );
}
-(NSString *)getComboItem:(int)index
{
	char buf[1024];
	if( !Page_getAnnotComboItem( m_page, m_handle, index, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(int)getComboSel
{
	return Page_getAnnotComboItemSel( m_page, m_handle );
}
-(bool)setComboSel:(int)index
{
	return Page_setAnnotComboItem( m_page, m_handle, index );
}
-(bool)isMultiSel
{
	return Page_isAnnotListMultiSel(m_page, m_handle);
}
-(int)getListItemCount
{
	return Page_getAnnotListItemCount( m_page, m_handle );
}
-(NSString *)getListItem:(int)index
{
	char buf[1024];
	if( !Page_getAnnotListItem( m_page, m_handle, index, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(int)getListSels:(int *)sels :(int)sels_max
{
	return Page_getAnnotListSels( m_page, m_handle, sels, sels_max );
}
-(bool)setListSels:(const int *)sels :(int)sels_cnt
{
	return Page_setAnnotListSels( m_page, m_handle, sels, sels_cnt );
}
-(int)getCheckStatus
{
	return Page_getAnnotCheckStatus( m_page, m_handle );
}
-(bool)setCheckValue:(bool)check
{
	return Page_setAnnotCheckValue( m_page, m_handle, check );
}
-(bool)setRadio
{
	return Page_setAnnotRadio( m_page, m_handle );
}
-(bool)getReset
{
	return Page_getAnnotReset( m_page, m_handle );
}
-(bool)setReset
{
	return Page_setAnnotReset( m_page, m_handle );
}
-(NSString *)getSubmitTarget
{
	char buf[1024];
	if( !Page_getAnnotSubmitTarget( m_page, m_handle, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(NSString *)getSubmitPara
{
	char buf[1024];
	if( !Page_getAnnotSubmitPara( m_page, m_handle, buf, 1023 ) )
		return NULL;
	return [NSString stringWithUTF8String:buf];
}
-(bool)removeFromPage
{
	bool ret = Page_removeAnnot( m_page, m_handle );
	m_handle = NULL;
	m_page = NULL;
	return ret;
}
-(int)getSignStatus
{
	return Page_getAnnotSignStatus( m_page, m_handle );
}
-(PDFSign *)getSign
{
	PDF_SIGN sign = Page_getAnnotSign(m_page, m_handle);
	if(!sign) return NULL;
	return [[PDFSign alloc] init:sign];
}

-(bool)MoveToPage:(PDFPage *)page :(const PDF_RECT *)rect
{
	return Page_moveAnnot(m_page, [page handle], m_handle, rect);
}

- (BOOL)canMoveAnnot
{
    return (self.type == 4 || self.type == 5 || self.type == 6 || self.type == 13 || self.type == 15 || self.type == 1);
}

-(PDF_OBJ_REF)getRef
{
	return Page_getAnnotRef(m_page, m_handle);
}
@end

@implementation PDFPage
@synthesize handle = m_page;
-(id)init;
{
    if( self = [super init] )
    {
	    m_page = NULL;
    }
    return self;
}
-(id)init:(PDF_PAGE) hand
{
    if( self = [super init] )
    {
	    m_page = hand;
    }
    return self;
}
-(PDF_OBJ_REF)advanceGetRef
{
	return Page_advGetRef(m_page);
}
-(void)advanceReload
{
	Page_advReload(m_page);
}
-(bool)importAnnot:(const PDF_RECT *)rect :(const unsigned char *)dat :(int)dat_len
{
	return Page_importAnnot(m_page, rect, dat, dat_len);
}

-(bool)renderThumb:(PDFDIB *)dib
{
	return Page_renderThumb(m_page, [dib handle]);
}

-(void)renderPrepare:(PDFDIB *)dib
{
    Page_renderPrepare(m_page, [dib handle]);
}
-(bool)render:(PDFDIB *)dib :(PDFMatrix *)mat :(int)quality
{
    return Page_render(m_page, [dib handle], [mat handle], true, quality);
}
-(void)renderCancel
{
    return Page_renderCancel(m_page);
}
-(bool)renderIsFinished
{
    return Page_renderIsFinished(m_page);
}
-(float)reflowPrepare:(float)width :(float)scale
{
    return Page_reflowStart( m_page, width,  scale );
}
-(bool)reflow:(PDFDIB *)dib :(float)orgx :(float)orgy
{
    return Page_reflow( m_page, [dib handle], orgx, orgy );
}
-(int)getRotate
{
	return Page_getRotate(m_page);
}
-(bool)flatAnnots
{
	return Page_flate(m_page);
}

-(int)sign:(PDFDocForm *)appearence :(const PDF_RECT *)box :(NSString *)cert_file :(NSString *)pswd :(NSString *)reason :(NSString *)location :(NSString *)contact
{
	return Page_sign(m_page, [appearence handle], box, [cert_file UTF8String], [pswd UTF8String], [reason UTF8String], [location UTF8String], [contact UTF8String]);
}

-(void)objsStart
{
    Page_objsStart(m_page);
}
-(int)objsCount
{
    return Page_objsGetCharCount(m_page);
}
-(NSString *)objsString:(int)from :(int)to
{
    if( to <= from ) return NULL;
    char *buf = (char *)malloc(4 * (to - from) + 8);
    Page_objsGetString(m_page, from, to, buf, 4 * (to - from) + 4);
    NSString *str = [NSString stringWithUTF8String:buf];
    free(buf);
    return str;
}
-(int)objsAlignWord:(int)index :(int)dir
{
    return Page_objsAlignWord(m_page, index, dir);
}
-(void)objsCharRect:(int)index :(PDF_RECT *)rect
{
    Page_objsGetCharRect(m_page, index, rect);
}
-(int)objsGetCharIndex:(float)x :(float)y
{
    return Page_objsGetCharIndex(m_page, x, y);
}
-(PDFFinder *)find:(NSString *)key :(bool)match_case :(bool)whole_word
{
	PDF_FINDER hand = Page_findOpen( m_page, [key UTF8String], match_case, whole_word );
	if( !hand ) return NULL;
	return [[PDFFinder alloc] init:hand];
}
-(int)annotCount
{
	return Page_getAnnotCount( m_page );
}
-(PDFAnnot *)annotAtIndex:(int)index
{
	PDF_ANNOT hand = Page_getAnnot( m_page, index );
	if( !hand ) return NULL;
	return [[PDFAnnot alloc] init:m_page:hand];
}
-(PDFAnnot *)annotAtPoint : (float)x : (float)y
{
	PDF_ANNOT hand = Page_getAnnotFromPoint( m_page, x, y );
	if( !hand ) return NULL;
	return [[PDFAnnot alloc] init:m_page:hand];
}
-(PDFAnnot *)annotByName:(NSString *)name
{
	if(!name) return NULL;
	PDF_ANNOT hand = Page_getAnnotByName(m_page, [name UTF8String]);
	if( !hand ) return NULL;
	return [[PDFAnnot alloc] init:m_page:hand];
}
-(bool)copyAnnot:(PDFAnnot *)annot :(const PDF_RECT *)rect
{
	return Page_copyAnnot( m_page, [annot handle], rect );
}
-(bool)addAnnot:(PDF_OBJ_REF)ref
{
	return Page_addAnnot(m_page, ref);
}

-(bool)addAnnotPopup:(PDFAnnot *)parent :(const PDF_RECT *)rect :(bool)open
{
	return Page_addAnnotPopup( m_page, [parent handle], rect, open);
}

-(bool)addAnnotMarkup : (int)index1 : (int)index2 : (int)type :(int) color
{
    return Page_addAnnotMarkup2(m_page, index1, index2, color, type);
}
-(bool)addAnnotInk:(PDFInk *)ink
{
	return Page_addAnnotInk2( m_page, ink.handle );
}
-(bool)addAnnotGoto :(const PDF_RECT *)rect :(int)dest :(float)top
{
	return Page_addAnnotGoto2( m_page, rect, dest, top );
}
-(bool)addAnnotURI :(NSString *)uri :(const PDF_RECT *)rect
{
	return Page_addAnnotURI2( m_page, rect, [uri UTF8String] );
}
-(bool)addAnnotLine :(const PDF_POINT *)pt1 :(const PDF_POINT *)pt2 :(int) style1 : (int) style2 : (float) width : (int) color : (int) icolor
{
	return Page_addAnnotLine2( m_page, pt1, pt2, style1, style2, width, color, icolor );
}
-(bool)addAnnotRect:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor
{
	return Page_addAnnotRect2( m_page, rect, width, color, icolor );
}
-(bool)addAnnotEllipse:(const PDF_RECT *)rect :(float) width :(int) color :(int) icolor
{
	return Page_addAnnotEllipse2( m_page, rect, width, color, icolor );
}
-(bool)addAnnotPolygon:(PDFPath *)path :(int) color :(int) fill_color :(float) width
{
	return Page_addAnnotPolygon(m_page, [path handle], color, fill_color, width);
}
-(bool)addAnnotPolyline:(PDFPath *)path :(int) style1 :(int) style2 :(int) color :(int) fill_color :(float) width
{
	return Page_addAnnotPolyline(m_page, [path handle], style1, style2, color, fill_color, width);
}
-(bool)addAnnotNote:(const PDF_POINT *)pt
{
	return Page_addAnnotText2( m_page, pt->x, pt->y );
}
-(bool)addAnnotAttachment:(NSString *)att :(int)icon :(const PDF_RECT *)rect
{
	return Page_addAnnotAttachment( m_page, [att UTF8String], icon, rect );
}
-(bool)addAnnotBitmap0:(PDFMatrix *)mat :(PDFDocImage *) dimage :(const PDF_RECT *) rect
{
	return Page_addAnnotBitmap( m_page, [mat handle], [dimage handle], rect );
}
-(bool)addAnnotBitmap:(PDFDocImage *) dimage :(const PDF_RECT *) rect
{
	return Page_addAnnotBitmap2( m_page, [dimage handle], rect );
}

-(bool)addAnnotRichMedia:(NSString *) path_player :(NSString *) path_content :(int) type :(PDFDocImage *) dimage :(const PDF_RECT *) rect
{
	return Page_addAnnotRichMedia( m_page, path_player, path_content, type, [dimage handle], rect );
}

-(bool)addAnnotStamp:(int)icon :(const PDF_RECT *)rect
{
	return Page_addAnnotStamp( m_page, rect, icon );
}
-(PDF_PAGE_FONT)addResFont:(PDFDocFont *)font
{
	return Page_addResFont( m_page, font.handle );
}
-(PDF_PAGE_IMAGE)addResImage:(PDFDocImage *)image
{
	return Page_addResImage( m_page, image.handle );
}
-(PDF_PAGE_GSTATE)addResGState:(PDFDocGState *)gstate
{
	return Page_addResGState( m_page, gstate.handle );
}
-(PDF_PAGE_FORM)addResForm:(PDFDocForm *)form
{
	return Page_addResForm( m_page, form.handle );
}
-(bool)addContent:(PDFPageContent *)content :(bool)flush
{
	return Page_addContent( m_page, content.handle, flush );
}
- (bool)addAnnotEditText:(const PDF_RECT *)rect
{
    return Page_addAnnotEditbox2(m_page, rect, 0xFF000000, 1, 0xFFFFFFFF, 10, 0xFF000000);
}
-(void)dealloc
{
    PDF_PAGE tmp_page = m_page;
    m_page = NULL;
    Page_close(tmp_page);
}
@end

@implementation PDFImportCtx
-(id)init
{
    if( self = [super init] )
    {
	    m_doc = NULL;
		m_handle = NULL;
    }
    return self;
}
-(id)init:(PDF_DOC)doc :(PDF_IMPORTCTX)handle
{
    if( self = [super init] )
    {
	    m_doc = doc;
		m_handle = handle;
    }
    return self;
}
-(bool)import:(int)src_no :(int)dst_no;
{
	return Document_importPage(m_doc, m_handle, src_no, dst_no );
}
-(void)importEnd
{
    Document_importEnd(m_doc, m_handle);
    m_doc = NULL;
	m_handle = NULL;
}
-(void)dealloc
{
    Document_importEnd(m_doc, m_handle);
    m_doc = NULL;
	m_handle = NULL;
}
@end

@implementation PDFDoc
@synthesize handle = m_doc;
-(id)init
{
    if( self = [super init] )
    {
        m_doc = NULL;
    }
    return self;
}
-(int)open:(NSString *)path : (NSString *)password
{
    PDF_ERR err;
    const char *cpath = [path UTF8String];
    if( !password )
        m_doc = Document_open(cpath, NULL, &err);
    else
    {
        const char *pwd = [password UTF8String];
        m_doc = Document_open(cpath, pwd, &err);
    }
    return err;
}
-(int)openMem:(void *)data : (int)data_size : (NSString *)password
{
    PDF_ERR err;
    if( !password )
        m_doc = Document_openMem(data, data_size, NULL, &err);
    else
    {
        const char *pwd = [password UTF8String];
        m_doc = Document_openMem(data, data_size, pwd, &err);
    }
    return err;
}

-(int)openStream:(id<PDFStream>)stream : (NSString *)password
{
    PDF_ERR err;
    if( !password )
        m_doc = Document_openStream(stream, NULL, &err);
    else
    {
        const char *pwd = [password UTF8String];
        m_doc = Document_openStream(stream, pwd, &err);
    }
    return err;
}

-(int)openWithCert:(NSString *)path :(NSString *)cert_file :(NSString *)password
{
    PDF_ERR err;
    m_doc = Document_openWithCert([path UTF8String], [cert_file UTF8String], [password UTF8String], &err);
    return err;
}

-(int)openMemWithCert:(void *)data :(int)data_size :(NSString *)cert_file :(NSString *)password
{
    PDF_ERR err;
    m_doc = Document_openMemWithCert(data, data_size, [cert_file UTF8String], [password UTF8String], &err);
    return err;
}

-(int)openStreamWithCert:(id<PDFStream>)stream :(NSString *)cert_file :(NSString *)password
{
    PDF_ERR err;
    m_doc = Document_openStreamWithCert(stream, [cert_file UTF8String], [password UTF8String], &err);
    return err;
}

-(int)create:(NSString *)path
{
    PDF_ERR err;
    const char *cpath = [path UTF8String];
    m_doc = Document_create(cpath, &err);
    return err;
}
-(PDF_OBJ_REF)advanceGetRef
{
	return Document_advGetRef(m_doc);
}
-(void)advanceReload
{
	Document_advReload(m_doc);
}
-(PDF_OBJ_REF)advanceNewFlateStream:(const unsigned char *)source :(int)len
{
	return Document_advNewFlateStream(m_doc, source, len);
}
-(PDF_OBJ_REF)advanceNewRawStream:(const unsigned char *)source :(int)len
{
	return Document_advNewRawStream(m_doc, source, len);
}
-(PDF_OBJ_REF)advanceNewIndirectObj
{
	return Document_advNewIndirectObj(m_doc);
}
-(PDF_OBJ_REF)advanceNewIndirectObjAndCopy :(PDFObj *)obj
{
	if(!obj) return 0;
	return Document_advNewIndirectObjWithData(m_doc, [obj handle]);
}
-(PDFObj *)advanceGetObj:(PDF_OBJ_REF)ref
{
	PDF_OBJ obj = Document_advGetObj(m_doc, ref);
	if(!obj) return NULL;
	return [[PDFObj alloc] init:obj];
}

-(bool)setCache:(NSString *)path
{
	return Document_setCache( m_doc, [path UTF8String] );
}

-(bool)setPageRotate: (int)pageno : (int)degree
{
	return Document_setPageRotate( m_doc, pageno, degree);
}

-(bool)runJS:(NSString *)js :(id<PDFJSDelegate>)del
{
    return Document_runJS(m_doc, [js UTF8String], del);
}

-(int)verifySign:(PDFSign *)sign
{
	return Document_verifySign(m_doc, [sign handle]);
}

-(bool)canSave
{
    return Document_canSave(m_doc);
}
-(bool)isEncrypted
{
    return Document_isEncrypted(m_doc);
}
-(int)getEmbedFileCount
{
	return Document_getEFCount(m_doc);
}
-(NSString *)getEmbedFileName:(int)idx
{
	return Document_getEFName(m_doc, idx);
}
-(NSString *)getEmbedFileDesc:(int)idx
{
	return Document_getEFDesc(m_doc, idx);
}
-(bool)getEmbedFileData:(int)idx :(NSString *)path
{
	return Document_getEFData(m_doc, idx, path);
}
-(NSString *)exportForm
{
	return Document_exportForm(m_doc);
}
-(bool)save
{
    return Document_save(m_doc);
}
-(bool)saveAs:(NSString *)dst :(bool)rem_sec
{
    const char *fdst = [dst UTF8String];
    return Document_saveAs(m_doc, fdst, rem_sec);
}

-(bool)encryptAs:(NSString *)dst :(NSString *)upswd :(NSString *)opswd :(int)perm :(int)method :(unsigned char *)fid
{
    return Document_encryptAs(m_doc, dst, upswd, opswd, perm, method, fid);
}

-(NSString *)meta:(NSString *)tag
{
    const char *stag = [tag UTF8String];
    char smeta[512];
    Document_getMeta(m_doc, stag, smeta, 511);
    return [NSString stringWithUTF8String: smeta];
}

-(bool)setMeta:(NSString *)tag :(NSString *)val
{
    const char *stag = [tag UTF8String];
    return Document_setMeta(m_doc, stag, [val UTF8String]);
}

-(bool)PDFID:(unsigned char *)buf
{
	return Document_getID(m_doc, buf);
}

-(int)pageCount
{
    return Document_getPageCount(m_doc);
}
-(PDF_SIZE)getPagesMaxSize
{
	PDF_SIZE sz;
	Document_getPagesMaxSize(m_doc, &sz);
	return sz;
}

-(PDFPage *)page:(int) pageno
{
    PDF_PAGE hand = Document_getPage(m_doc, pageno);
    if( !hand ) return NULL;
    return [[PDFPage alloc] init:hand];
}
-(float)pageWidth:(int) pageno
{
    return Document_getPageWidth(m_doc, pageno);
}
-(float)pageHeight:(int) pageno
{
    return Document_getPageHeight(m_doc, pageno);
}
-(NSString *)pageLabel:(int) pageno
{
    return Document_getPageLabel(m_doc, pageno);
}

-(PDFOutline *)rootOutline
{
    PDF_OUTLINE hand = Document_getOutlineNext(m_doc, NULL);
	if( !hand ) return NULL;
	return [[PDFOutline alloc] init:m_doc:hand];
}

-(bool)newRootOutline: (NSString *)label :(int) pageno :(float) top
{
    return Document_newRootOutline(m_doc, [label UTF8String], pageno, top);
}

-(PDFDocFont *)newFontCID: (NSString *)name :(int) style
{
	PDF_DOC_FONT hand = Document_newFontCID( m_doc, [name UTF8String], style );
	if( !hand ) return NULL;
	return [[PDFDocFont alloc] init:m_doc:hand];
}

-(PDFDocGState *)newGState
{
	PDF_DOC_GSTATE hand = Document_newGState( m_doc );
	if( !hand ) return NULL;
	return [[PDFDocGState alloc] init:m_doc:hand];
}
-(PDFDocForm *)newForm
{
	PDF_DOC_FORM hand = Document_newForm( m_doc );
	if( !hand ) return NULL;
	return [[PDFDocForm alloc] init:m_doc:hand];
}

-(PDFPage *)newPage:(int) pageno :(float) w :(float) h
{
    PDF_PAGE hand = Document_newPage(m_doc, pageno, w, h);
    if( !hand ) return NULL;
    return [[PDFPage alloc] init:hand];
}

-(PDFImportCtx *)newImportCtx:(PDFDoc *)src_doc
{
	PDF_IMPORTCTX hand = Document_importStart( m_doc, [src_doc handle] );
	if( !hand ) return NULL;
    return [[PDFImportCtx alloc] init:m_doc:hand];
}

-(bool)movePage:(int)pageno1 :(int)pageno2
{
	return Document_movePage( m_doc, pageno1, pageno2 );
}

-(bool)removePage:(int)pageno
{
	return Document_removePage( m_doc, pageno );
}
-(PDFDocImage *)newImage:(CGImageRef)img : (bool)has_alpha
{
	if(!img) return nil;
	PDF_DOC_IMAGE hand = Document_newImage( m_doc, img, has_alpha );
	if( !hand ) return NULL;
    return [[PDFDocImage alloc] init:m_doc:hand];
}

-(PDFDocImage *)newImageJPEG:(NSString *)path
{
	PDF_DOC_IMAGE hand = Document_newImageJPEG( m_doc, [path UTF8String] );
	if( !hand ) return NULL;
    return [[PDFDocImage alloc] init:m_doc:hand];
}

-(PDFDocImage *)newImageJPX:(NSString *)path
{
	PDF_DOC_IMAGE hand = Document_newImageJPX( m_doc, [path UTF8String] );
	if( !hand ) return NULL;
    return [[PDFDocImage alloc] init:m_doc:hand];
}
-(void)dealloc
{
    Document_close(m_doc);
    m_doc = NULL;
}

@end
