package com.radaee.pdf;

import android.graphics.Bitmap;
import android.os.Bundle;

import com.radaee.pdf.adv.Obj;
import com.radaee.pdf.adv.Ref;

/**
 class for PDF Document.
 @author Radaee
 @version 1.1
 */
public class Document
{
	public interface PDFFontDelegate
	{
		/**
		 * font delegate, invoked when the Font not found in FontList.g
		 * @param collection like: "", "GB1", "CNS1", and so on.
		 * @param fname font name that not found in native library.
		 * @param flag flag&1 means fixed width font, flag&2 means vertical writing.
		 * @param ret_flags 1 element int array for output values:<br/>
		 * (ret_flag[0]>>8) is the index of face in Font File(TTC file may has many faces, TTF file just pass 0).<br/>
		 * (ret_flag[0]&1) tell native library to apply bold effect by program.<br/>
		 * (ret_flag[0]&2) tell native library to apply italic effect by program.<br/>
		 * @return full path name to font file, or null if using native default font.
		 */
		String GetExtFont(String collection, String fname, int flag, int[] ret_flags);
	}
	public interface PDFJSDelegate
	{
		/**
		 * console command
		 * @param cmd 0: clear console.<br/>
		 *            1: hide console.<br/>
		 *            2: print line on sonsole.<br/>
		 *            3: show console.
		 * @param para only valid when cmd == 2;
		 */
		void OnConsole(int cmd, String para);

		/**
		 * show a alert dialog on screen.
		 * @param btn buttons show on dialog.<br/>
		 *            0: OK<br/>
		 *            1: OK, Cancel<br/>
		 *            2: Yes, No<br/>
		 *            3: Yes, No, Cancel<br/>
		 * @param msg message to be show..
		 * @param title title to be show.
		 * @return which button user clicked? values as below:<br/>
		 * 1:OK<br/>
		 * 2:Cancel<br/>
		 * 3:No<br/>
		 * 4:Yes<br/>
		 */
		int OnAlert(int btn, String msg, String title);

		/**
		 * callback when document closed.
		 * @return true is the Document object need save, otherwise false.
		 */
		boolean OnDocClose();

		/**
		 * generate a tmp file name that JS needed in background.
		 * @return absolute path to temp path generated.
		 */
		String OnTmpFile();

		/**
		 * callback when an Uncaught exception appears.
		 * @param code error code.
		 * @param msg error message.
		 */
		void OnUncaughtException(int code, String msg);
	}
	public interface PDFStream
	{
		/**
		 * check whether the stream is writable 
		 * @return true or false
		 */
		boolean writeable();
		/**
		 * get stream length.
		 * @return
		 */
		int get_size();
		/**
		 * read data from stream
		 * @param data output values.
		 * @return bytes read
		 */
		int read( byte[] data );
		/**
		 * write data to stream
		 * @param data data to write
		 * @return bytes written
		 */
		int write( byte[] data );
		/**
		 * seek to position
		 * @param pos position from begin of the stream
		 */
		void seek( int pos );
		/**
		 * tell current position
		 * @return position from begin of the stream
		 */
		public int tell();
	}
	static public class ImportContext
	{
		protected ImportContext(Document doc, long value)
		{
			hand = value;
			m_doc = doc;
		}
		/**
		 * import a page to the document.<br/>
		 * a premium license is required for this method.<br/>
		 * do not forget to invoke ImportContext.Destroy() after all pages are imported.
		 * @param srcno 0 based page NO. from source Document that passed to ImportStart.
		 * @param dstno 0 based page NO. to insert in this document object.
		 * @return true or false.
		 */
		public boolean ImportPage( int srcno, int dstno )
		{
			if (hand == 0) return false;
			return Document.importPage(m_doc.hand_val, hand, srcno, dstno);
		}
		/**
		 * Destroy context object and free memory used.
		 */
		public void Destroy()
		{
			Document.importEnd( m_doc.hand_val, hand );
			hand = 0;
		}
		protected long hand;
		protected Document m_doc;
	}
	public class Outline
	{
		protected long hand;
		/**
		 * get label of Outline
		 * @return title string
		 */
		public String GetTitle()
		{
			return Document.getOutlineTitle(hand_val, hand);
		}
		/**
		 * set label of Outline.<br/>
		 * a premium license is required for this method.
		 * @param title title to set
		 * @return true or false.
		 */
		public boolean SetTitle(String title)
		{
			return Document.setOutlineTitle(hand_val, hand, title);
		}
		/**
		 * get next
		 * @return
		 */
		public Outline GetNext()
		{
			long ret =  Document.getOutlineNext(hand_val, hand);
			if( ret == 0 ) return null;
			Outline ol = new Outline();
			ol.hand = ret;
			return ol;
		}
		/**
		 * get first child
		 * @return
		 */
		public Outline GetChild()
		{
			long ret =  Document.getOutlineChild(hand_val, hand);
			if( ret == 0 ) return null;
			Outline ol = new Outline();
			ol.hand = ret;
			return ol;
		}
		/**
		 * get jumping page NO.
		 * @return 0 based page NO.
		 */
		public int GetDest()
		{
			return Document.getOutlineDest(hand_val, hand);
		}
		/**
		 * get url string of Outline
		 * @return url string or null.
		 */
		public String GetURI()
		{
			return Document.getOutlineURI(hand_val, hand);
		}
		/**
		 * get file link path of Outline
		 * @return file link path string or null.
		 */
		public String GetFileLink()
		{
			return Document.getOutlineFileLink(hand_val, hand);
		}
		/**
		 * insert outline after of this Outline.<br/>
		 * a premium license is required for this method.
		 * @param label label of new outline.
		 * @param pageno 0 based page NO.
		 * @param top y in PDF coordinate.
		 * @return true of false.
		 */
		public boolean AddNext( String label, int pageno, float top )
		{
			return Document.addOutlineNext(hand_val, hand, label, pageno, top);
		}
		/**
		 * insert outline as first child of this Outline.<br/>
		 * a premium license is required for this method.
		 * @param label label of new outline.
		 * @param pageno 0 based page NO.
		 * @param top y in PDF coordinate.
		 * @return true or false.
		 */
		public boolean AddChild( String label, int pageno, float top )
		{
			return Document.addOutlineChild(hand_val, hand, label, pageno, top);
		}
		/**
		 * remove this Outline, and all children of this Outline.<br/>
		 * this method connect previous Outline and next Outline.<br/>
		 * a premium license is required for this method.
		 * @return true or false.
		 */
		public boolean RemoveFromDoc()
		{
			boolean ret = Document.removeOutline(hand_val, hand);
			hand = 0;
			return ret;
		}
	}
	protected long hand_val = 0;
	private static native void setOpenFlag(int flag);
	private static native long create( String path );
	private static native long createForStream( PDFStream stream );
	private static native long open( String path, String password );
	private static native long openMem( byte[] data, String password );
	private static native long openStream( PDFStream stream, String password );
	private static native long openWithCert( String path, String cert_file, String password );
	private static native long openMemWithCert( byte[] data, String cert_file, String password );
	private static native long openStreamWithCert( PDFStream stream, String cert_file, String password );
	private static native int getLinearizedStatus(long hand);
	private static native boolean setCache( long hand, String path );
	private static native boolean runJS(long hand, String js, PDFJSDelegate del);
	private static native void setFontDel( long hand, PDFFontDelegate del );
	private static native int getEFCount( long hand );
	private static native String getEFName( long hand, int index );
	private static native String getEFDesc( long hand, int index );
	private static native boolean getEFData( long hand, int index, String save_path );
	private static native int getJSCount( long hand );
	private static native String getJSName( long hand, int index );
	private static native String getJS( long hand, int index );
	private static native int getPermission( long hand );
	private static native int getPerm( long hand );
	private static native String exportForm( long hand );
	private static native void close( long hand );
	private static native long getPage( long hand, int pageno );
	static private native long getPage0(long hand);
	private static native int getPageCount( long hand );
	private static native float getPageWidth( long hand, int pageno );
	private static native float getPageHeight( long hand, int pageno );
	private static native String getPageLabel(long hand, int pageno);
	private static native float[] getPagesMaxSize(long hand);
	private static native boolean changePageRect( long hand, int pageno, float dl, float dt, float dr, float db );
	private static native boolean setPageRotate( long hand, int pageno, int degree );
	private static native String getOutlineTitle( long hand, long outline );
	private static native boolean setOutlineTitle( long hand, long outline, String title );
	private static native int getOutlineDest( long hand, long outline );
	private static native String getOutlineURI( long hand, long outline );
	private static native String getOutlineFileLink( long hand, long outline );
	private static native long getOutlineNext( long hand, long outline );
	private static native long getOutlineChild( long hand, long outline );
	private static native boolean addOutlineNext( long hand, long outline, String label, int pageno, float top );
	private static native boolean addOutlineChild( long hand, long outline, String label, int pageno, float top );
	private static native boolean removeOutline( long hand, long outline );
	private static native String getMeta( long hand, String tag );
	private static native byte[] getID( long hand, int index);
	private static native boolean setMeta( long hand, String tag, String value );
	private static native String getXMP(long hand);
	private static native boolean setXMP(long hand, String xmp);
	private static native boolean canSave( long hand );
	private static native boolean save( long hand );
	private static native boolean saveAs( long hand, String dst, boolean rem_sec );//remove security info and save to another file.
	private static native boolean encryptAs( long hand, String dst, String upswd, String opswd, int perm, int method, byte[] id);
	private static native boolean isEncrypted( long hand );

	private static native long importStart( long hand, long hand_src );
	private static native boolean importPage( long hand, long ctx, int srcno, int dstno );
	private static native void importEnd( long hand, long ctx );
	private static native long newPage( long hand, int pageno, float w, float h );
	private static native boolean removePage( long hand, int pageno );
	private static native boolean movePage( long hand, int pageno1, int pageno2 );
	private static native long newFontCID( long hand, String name, int style );
	private static native long newForm(long doc);
	private static native float getFontAscent( long hand, long font );
	private static native float getFontDescent( long hand, long font );
	private static native long newGState(long hand);
	private static native boolean setGStateStrokeAlpha(long hand, long gstate, int alpha);
	private static native boolean setGStateFillAlpha(long hand, long gstate, int alpha);
	private static native boolean setGStateStrokeDash(long hand, long gstate, float[] dash, float phase);
	private static native boolean setGStateBlendMode(long hand, long state, int bmode);
	private static native long newImage( long hand, Bitmap bmp, boolean has_alpha );
	private static native long newImage2( long hand, Bitmap bmp, int matte );
	private static native long newImageJPEG( long hand, String path );
	private static native long newImageJPEGByArray( long hand, byte[] data, int length );
	private static native long newImageJPX( long hand, String path );
	private static native long addFormResFont(long doc, long form, long font);
	private static native long addFormResImage(long doc, long form, long image);
	private static native long addFormResGState(long doc, long form, long gstate);
	private static native long addFormResForm(long doc, long form, long sub);
	private static native void setFormContent(long doc, long form, float x, float y, float w, float h, long content);
	private static native void setFormTransparency(long hand, long form, boolean isolate, boolean knockout);
	private static native void freeForm(long doc, long form);

	private static native int verifySign(long doc, long sign);


	private static native long advGetObj(long doc, long ref);
	private static native long advNewIndirectObj(long doc);
	private static native long advNewIndirectObjWithData(long doc, long obj_hand);
	private static native long advGetRef(long doc);
	private static native long advNewFlateStream(long doc, byte[] source);
	private static native long advNewRawStream(long doc, byte[] source);
	private static native void advReload(long doc);
	static private Ref adv_create_ref(long ret)
	{
		if(ret == 0) return null;
		return new Ref(ret);
	}
	static private Obj adv_create_obj(long ret)
	{
		if(ret == 0) return null;
		return new Obj(ret);
	}

	/**
	 * advanced function to get object from Document to edit.<br/>
	 * this method require premium license.<br/>
	 * @param ref PDF cross reference ID, which got from:<br/>
	 *            Advance_NewIndirectObj()<br/>
	 *            Advance_GetCatalog()<br/>
	 *            Advance_GetPage()<br/>
	 *            Advance_NewFlateStream()<br/>
	 *            Advance_NewRawStream()<br/>
	 * @return PDF Object or null.
	 */
	public Obj Advance_GetObj(Ref ref)
	{
		return adv_create_obj(advGetObj(hand_val, ref.get_hand()));
	}

	/**
	 * advanced function to create an empty indirect object to edit.<br/>
	 * this method require premium license.<br/>
	 * @return PDF cross reference to new object, using Advance_GetObj to get Object data.
	 */
	public Ref Advance_NewIndirectObj()
	{
		return adv_create_ref(advNewIndirectObj(hand_val));
	}

	/**
	 * advanced function to create an indirect object, and then copy source object to this indirect object.<br/>
	 * this method require premium license.<br/>
	 * @param obj source object to be copied.
	 * @return PDF cross reference to new object, using Advance_GetObj to get Object data.
	 */
	public Ref Advance_NewIndirectAndCopyObj(Obj obj)
	{
		return adv_create_ref(advNewIndirectObjWithData(hand_val, obj.get_hand()));
	}
	/**
	 * advanced function to create a stream using zflate compression(zlib).<br/>
	 * stream byte contents can't modified, once created.<br/>
	 * the byte contents shall auto compress and encrypt by native library.<br/>
	 * this method require premium license, and need Document.SetCache() invoked.<br/>
	 * @param source
	 * @return PDF cross reference to new object, using Advance_GetObj to get Object data.
	 */
	public Ref Advance_NewFlateStream(byte[] source)
	{
		return adv_create_ref(advNewFlateStream(hand_val, source));
	}
	/**
	 * advanced function to create a stream using raw data.<br/>
	 * if u pass compressed data to this method, u shall modify dictionary of this stream.<br/>
	 * like "Filter" and other item from dictionary.<br/>
	 * the byte contents shall auto encrypt by native library, if document if encrypted.<br/>
	 * this method require premium license, and need Document.SetCache() invoked.<br/>
	 * @param source
	 * @return PDF cross reference to new object, using Advance_GetObj to get Object data.
	 */
	public Ref Advance_NewRawStream(byte[] source)
	{
		return adv_create_ref(advNewRawStream(hand_val, source));
	}
	/**
	 * advanced function to get reference of catalog object(root object of PDF).<br/>
	 * this method require premium license.<br/>
	 * @return PDF cross reference to new object, using Advance_GetObj to get Object data.
	 */
	public Ref Advance_GetRef()
	{
		return adv_create_ref(advGetRef(hand_val));
	}
	/**
	 * advanced function to reload document objects.<br/>
	 * this method require premium license.<br/>
	 * all pages object return from Document.GetPage() shall not available, after this method invoked.
	 */
	public void Advance_Reload()
	{
		advReload(hand_val);
	}

	public class DocFont
	{
		protected long hand;
		Document doc;
		/**
		 * get ascent
		 * @return ascent based in 1, for example: 0.88f
		 */
		public float GetAscent()
		{
			return getFontAscent(doc.hand_val, hand);
		}
		/**
		 * get descent
		 * @return ascent based in 1, for example: -0.12f
		 */
		public float GetDescent()
		{
			return getFontDescent(doc.hand_val, hand);
		}
	}
	public class DocGState
	{
		protected long hand;
		Document doc;
		/**
		 * set alpha value for fill and other non-stroke operation
		 * @param alpha range: [0, 255]
		 * @return true or false
		 */
		public boolean SetFillAlpha(int alpha)
		{
			return Document.setGStateFillAlpha(doc.hand_val, hand, alpha);
		}
		/**
		 * set alpha value for stroke operation
		 * @param alpha range: [0, 255]
		 * @return true or false
		 */
		public boolean SetStrokeAlpha(int alpha)
		{
			return Document.setGStateStrokeAlpha(doc.hand_val, hand, alpha);
		}

		/**
		 * set dash for stroke operation.
		 * @param dash dash arra, if null, means set to solid.
		 * @param phase phase value, mostly, it is 0.
		 * @return true or false.
		 * eaxmple:<br/>
		 * [2, 1], 0  means 2 on, 1 off, 2 on, 1 off, …<br/>
		 * [2, 1], 0.5 means 1.5 on, 1 off, 2 on 1 off, …<br/>
		 * for more details, plz see PDF-Reference 1.7 (4.3.2) Line Dash Pattern.<br/>
		 */
		public boolean SetStrokeDash(float[] dash, float phase)
		{
			return setGStateStrokeDash(doc.hand_val, hand, dash, phase);
		}

		/**
		 * set blend mode to graphic state.
		 * @param bmode 2:Multipy<br/>
		 *              3:Screen<br/>
		 *              4:Overlay<br/>
		 *              5:Darken<br/>
		 *              6:Lighten<br/>
		 *              7:ColorDodge<br/>
		 *              8:ColorBurn<br/>
		 *              9:Difference<br/>
		 *              10:Exclusion<br/>
		 *              11:Hue<br/>
		 *              12:Saturation<br/>
		 *              13:Color<br/>
		 *              14:Luminosity<br/>
		 *              others:Normal
		 * @return true or false.
		 */
		public boolean SetBlendMode(int bmode)
		{
			return setGStateBlendMode(doc.hand_val, hand, bmode);
		}
	}
	public class DocImage
	{
		protected long hand;
	}
	public class DocForm
	{
		protected Document m_doc;
		protected long hand;

		/**
		 * add font as resource of form.
		 * @param dfont returned by Document.NewFontCID()
		 * @return resource handle
		 */
		public ResFont AddResFont(Document.DocFont dfont)
		{
			if(dfont == null) return null;
			long ret = addFormResFont(m_doc.hand_val, hand, dfont.hand);
			if(ret == 0) return null;
			ResFont res_font = new ResFont();
			res_font.hand = ret;
			return res_font;
		}

		/**
		 * add image as resource of form.
		 * @param dimg returned by Document.NewImageXXX()
		 * @return resource handle
		 */
		public ResImage AddResImage(Document.DocImage dimg)
		{
			if(dimg == null) return null;
			long ret = addFormResImage(m_doc.hand_val, hand, dimg.hand);
			if(ret == 0) return null;
			ResImage res_img = new ResImage();
			res_img.hand = ret;
			return res_img;
		}

		/**
		 * add Graphic State as resource of form.
		 * @param dgs returned by Document.NewGState()
		 * @return resource handle
		 */
		public ResGState AddResGState(Document.DocGState dgs)
		{
			if(dgs == null) return null;
			long ret = addFormResGState(m_doc.hand_val, hand, dgs.hand);
			if(ret == 0) return null;
			ResGState res_gs = new ResGState();
			res_gs.hand = ret;
			return res_gs;
		}

		/**
		 * add sub-form as resource of form.<br/>
		 * @param dform returned by Document.NewForm()
		 * @return resource handle
		 */
		public ResForm AddResForm(DocForm dform)
		{
			if(dform == null) return null;
			long ret = addFormResForm(m_doc.hand_val, hand, dform.hand);
			if(ret == 0) return null;
			ResForm res_form = new ResForm();
			res_form.hand = ret;
			return res_form;
		}

		/**
		 * set content of form, need a box defined in form.<br/>
		 * the box define edge of form area, which PageContent object includes.
		 * @param content PageContent object.
		 * @param x x of form's box
		 * @param y y of form's box
		 * @param w width of form's box
		 * @param h height of form's box
		 */
		public void SetContent(PageContent content, float x, float y, float w, float h)
		{
			if(content == null) return;
			setFormContent(m_doc.hand_val, hand, x, y, w, h, content.hand);
		}

		/**
		 * set this form as transparency.
		 * @param isolate set to isolate, mostly are false.
		 * @param knockout set to knockout, mostly are false.
		 */
		public void SetTransparency(boolean isolate, boolean knockout)
		{
			setFormTransparency(m_doc.hand_val, hand, isolate, knockout);
		}
		@Override
		protected void finalize() throws Throwable
		{
			if(m_doc != null)
			{
				freeForm(m_doc.hand_val, hand);
				m_doc = null;
			}
			hand = 0;
			super.finalize();
		}
	}
	public Document()
	{
	}
	/**
	 * inner function.
	 * @param hand
	 */
	public Document(long hand)
	{
		//modified by radaee.
		//in fact, the handle value is pointer, which is 64 bits on 64 bits system.
		//int vals is 32 bits values.
		hand_val = hand;
	}
	private long getOutlineRoot()
	{
		return getOutlineNext( hand_val, 0 );
	}
	/**
	 * check if opened.
	 * @return true or false.
	 */
	public boolean IsOpened()
	{
		return (hand_val != 0);
	}
	/**
	 * create a empty PDF document
	 * @param path path to create
	 * @return 0 or less than 0 means failed, same as Open.
	 */
	public int Create( String path )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			hand_val = create( path );
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}
	/**
	 * create a empty PDF document
	 * @param stream stream to create
	 * @return 0 or less than 0 means failed, same as Open.
	 */
	public int CreateForStream( PDFStream stream ) throws Exception
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			hand_val = createForStream( stream );
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}
	/**
	 * set cache file to PDF.<br/>
	 * a professional or premium license is required for this method.
	 * @param path a path to save some temporary data, compressed images and so on
	 * @return true or false
	 */
	public boolean SetCache( String path )
	{
		return setCache( hand_val, path );
	}
	/**
	 * set font delegate to PDF.<br/>
	 * a professional or premium license is required for this method.
	 * @param del delegate for font mapping, or null to remove delegate.
	 */
	public void SetFontDel( PDFFontDelegate del )
	{
		setFontDel(hand_val, del);
	}

	/**
	 * a static method set open flag.<br/>
	 * the flag is a global setting, which effect all Document.OpenXXX() methods.
	 * @param flag (flag&1) : load linearzied hint table.<br/>
	 *             (flag&2) : if bit set, mean all pages considered as same size, and SDK will only read first page object in open time, and set all pages size same to first page.<br/>
	 *             (flag&2) only works when (flag&1) is set.
	 */
	static public void SetOpenFlag(int flag)
	{
		setOpenFlag(flag);
	}

	/**
	 * open document.<br/>
	 * first time, SDK try password as user password, and then try password as owner password.
	 * @param path PDF file to be open.
	 * @param password password or null.
	 * @return error code:<br/>
	 * 0:succeeded, and continue<br/>
	 * -1:need input password<br/>
	 * -2:unknown encryption<br/>
	 * -3:damaged or invalid format<br/>
	 * -10:access denied or invalid file path<br/>
	 * others:unknown error
	 */
	public int Open( String path, String password )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			try {
				hand_val = open(path, password);
			}
			catch (Exception e)
			{
				e.printStackTrace();
				hand_val = -10;
			}
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}

	/**
	 * open PDF, and decrypt PDF using public-key.<br/>
	 * this feature only enabled on signed feature version. which native libs has bigger size.
	 * @param path PDF file path
	 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
	 * @param password password to open cert file.
	 * @return same as password version.
	 */
	public int Open( String path, String cert_file, String password )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			try {
				hand_val = openWithCert(path, cert_file, password);
			}
			catch (Exception e)
			{
				e.printStackTrace();
				hand_val = -10;
			}
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}
	/**
	 * open document in memory.
	 * first time, SDK try password as user password, and then try password as owner password.
	 * @param data data for whole PDF file in byte array. developers should retain array data, till document closed.
	 * @param password password or null.
	 * @return error code:<br/>
	 * 0:succeeded, and continue<br/>
	 * -1:need input password<br/>
	 * -2:unknown encryption<br/>
	 * -3:damaged or invalid format<br/>
	 * -10:access denied or invalid file path<br/>
	 * others:unknown error
	 */
	public int OpenMem( byte[] data, String password )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			try {
				hand_val = openMem(data, password);
			}
			catch (Exception e)
			{
				e.printStackTrace();
				hand_val = -10;
			}
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}
	/**
	 * open PDF, and decrypt PDF using public-key.<br/>
	 * this feature only enabled on signed feature version. which native libs has bigger size.
	 * @param data data for whole PDF file in byte array. developers should retain array data, till document closed.
	 * @param cert_file a cert file like .p12 or .pfx file, DER encoded cert file.
	 * @param password password to open cert file.
	 * @return same as password version.
	 */
	public int OpenMem( byte[] data, String cert_file, String password )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			try {
				hand_val = openMemWithCert(data, cert_file, password);
			}
			catch (Exception e)
			{
				e.printStackTrace();
				hand_val = -10;
			}
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}
	/**
	 * open document from stream.
	 * first time, SDK try password as user password, and then try password as owner password.
	 * @param stream PDFStream object.
	 * @param password password or null.
	 * @return error code:<br/>
	 * 0:succeeded, and continue<br/>
	 * -1:need input password<br/>
	 * -2:unknown encryption<br/>
	 * -3:damaged or invalid format<br/>
	 * -10:access denied or invalid file path<br/>
	 * others:unknown error
	 */
	public int OpenStream( PDFStream stream, String password )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			try {
				hand_val = openStream(stream, password);
			}catch (Exception e)
			{
				e.printStackTrace();
			}
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}

	public int OpenStream( PDFStream stream, String cert_file, String password )
	{
		if( hand_val == 0 )
		{
			int ret = 0;
			try {
				hand_val = openStreamWithCert(stream, cert_file, password);
			}catch (Exception e)
			{
				e.printStackTrace();
			}
			if( hand_val <= 0 && hand_val >= -10 )//error
			{
				ret = (int)hand_val;
				hand_val = 0;
			}
			return ret;
		}
		return 0;
	}
	/**
	 * run javascript, NOTICE:considering some complex js, this method is not thread-safe.<br/>
	 * this method require premium license, it always return false if using other license type.
	 * @param js javascript string, can't be null.
	 * @param del delegate for javascript running, can't be null.
	 * @return if js or del is null, or no premium license actived, return false.<br/>
	 * if success running, return true.<br/>
	 * otherwise, an exception shall throw to java.
	 */
	public boolean RunJS(String js, PDFJSDelegate del) throws Exception
	{
		return runJS(hand_val, js, del);
	}

	/**
	 * get embed files count, for document level.<br/>
	 * this method require premium license, it always return 0 if using other license type.
	 * @return count
	 */
	public int GetEmbedFilesCount()
	{
		return getEFCount(hand_val);
	}

	/**
	 * get name of embed file.
	 * @param index range in [0, GetEmbedFilesCount())
	 * @return name of embed file
	 */
	public String GetEmbedFileName( int index )
	{
		return getEFName(hand_val, index);
	}

	/**
	 * get Description of embed file.
	 * @param index range in [0, GetEmbedFilesCount())
	 * @return Description of embed file
	 */
	public String GetEmbedFileDesc( int index )
	{
		return getEFDesc(hand_val, index);
	}

	/**
	 * get embed file data, and save to save_path
	 * @param index range in [0, GetEmbedFilesCount())
	 * @param save_path absolute path to save embed file.
	 * @return true or false.
	 */
	public boolean GetEmbedFileData( int index, String save_path )
	{
		return getEFData(hand_val, index, save_path);
	}
	/**
	 * get java script count, for document level.<br/>
	 * this method require premium license, it always return 0 if using other license type.
	 * @return count
	 */
	public int GetJSCount()
	{
		return getJSCount(hand_val);
	}

	/**
	 * get name of javascript.
	 * @param index range in [0, GetJSCount())g
	 * @return name of javascript
	 */
	public String GetJSName( int index )
	{
		return getJSName(hand_val, index);
	}

	/**
	 * get javascript.
	 * @param index range in [0, GetJSCount())
	 * @return javascript string
	 */
	public String GetJS( int index )
	{
		return getJS(hand_val, index);
	}

	/**
	 * get permission of PDF, this value defined in PDF reference 1.7<br/>
	 * mostly, it means the permission from encryption.<br/>
	 * this method require a professional or premium license.
	 * bit 1-2 reserved<br/>
	 * bit 3(0x4) print<br/>
	 * bit 4(0x8) modify<br/>
	 * bit 5(0x10) extract text or image<br/>
	 * others: see PDF reference
	 * @return permission flags
	 */
	public int GetPermission()
	{
		return getPermission( hand_val );
	}
	/**
	 * get permission of PDF, this value defined in "Perm" entry in Catalog object.<br/>
	 * mostly, it means the permission from signature.<br/>
	 * this method require a professional or premium license.
	 * @return 0 means not defined<br/>
	 * 1 means can't modify<br/>
	 * 2 means can modify some form fields<br/>
	 * 3 means can do any modify<br/>
	 */
	public int GetPerm()
	{
		return getPerm( hand_val );
	}
	/**
	 * export form data as xml string.<br/>
	 * this method require premium license.
	 * @return xml string or null.
	 */
	public String ExportForm()
	{
		return exportForm( hand_val );
	}
	/**
	 * close the document.
	 */
	public void Close()
	{
		if( hand_val != 0 )
			close( hand_val );
		hand_val = 0;
	}

	/**
	 * get linearizied status.
	 * @return 0: linearized header not loaded or no linearized header.(if setOpenFlag(0); cause always return 0)<br/>
	 * 1: there is linearized header, but linearized entry checked as failed.<br/>
	 * 2: there is linearized header, linearized entry checked succeeded, but hint table is damaged.<br/>
	 * 3. linearized header loaded succeeded.
	 */
	public int GetLinearizedStatus() {
		return getLinearizedStatus (hand_val);
	}
	/**
	 * fast get first page, used in first page thumbnail generating.<br/>
	 * do not use this method for other purpose.
	 * @return Page object or null.
	 */
	public Page GetPage0()
	{
		if( hand_val == 0 ) return null;
		long hand = getPage0( hand_val );
		if( hand == 0 ) return null;
		Page page = new Page();
		if( page != null )
		{
			page.hand = hand;
			page.m_doc = this;
		}
		return page;
	}
	/**
	 * get a Page object for page NO.
	 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
	 * @return Page object or null.
	 */
	public Page GetPage( int pageno )
	{
		if( hand_val == 0 ) return null;
		long hand = getPage( hand_val, pageno );
		if( hand == 0 ) return null;
		Page page = new Page();
		if( page != null )
		{
			page.hand = hand;
			page.m_doc = this;
		}
		return page;
	}
	/**
	 * get pages count.
	 * @return pages count.
	 */
	public int GetPageCount()
	{
		//it loads all pages. sometimes the function is very slow.
		//modified by radaee.
		//only first time to invoke getPageCount() maybe very slow.
		//since second time, it return from native int value directly.
		return getPageCount(hand_val);
	}
	/**
	 * get page width by page NO.
	 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
	 * @return width value.
	 */
	public float GetPageWidth( int pageno )
	{
		float w = getPageWidth( hand_val, pageno );
		if( w <= 0 ) return 1;
		else return w;
	}
	/**
	 * get page height by page NO.
	 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
	 * @return height value.
	 */
	public float GetPageHeight( int pageno )
	{
		if(pageno < 0 || pageno >= getPageCount(hand_val)) return 1;
		float h = getPageHeight( hand_val, pageno );
		if( h <= 0 ) return 1;
		else return h;
	}

	/**
	 * get label of page
	 * @param pageno 0 based page index number
	 * @return json string or pure text. for json: name is style name of number.<br/>
	 * for example:<br/>
	 * {"D":2} is "2"<br/>
	 * {"R":3} is "III"<br/>
	 * {"r":4} is "iv"<br/>
	 * {"A":5} is "E"<br/>
	 * {"a":6} is "f"<br/>
	 * for pure text: the text is the label.
	 */
	public String GetPageLabel(int pageno)
	{
		return getPageLabel(hand_val, pageno);
	}

	/**
	 * get max width and max height of all pages.
	 * @return 2 elements container width and height values, or null if failed.
	 */
	public float[] GetPagesMaxSize()
	{
		return getPagesMaxSize(hand_val);
	}
	/**
	 * get meta data of document.
	 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate".<br/>or you can pass any key that self-defined.
	 * @return Meta string value, or null.
	 */
	public String GetMeta( String tag )
	{
		return getMeta( hand_val, tag );
	}

	/**
	 * get XMP string from document.
	 * @return null or XML string.
	 */
	public String GetXMP()
	{
		return getXMP( hand_val );
	}

	/**
	 * set XMP string from document.<br/>
	 * this method require premium license.
	 * @param xmp xmp string to set.
	 * @return true or false.
	 */
	public boolean SetXMP(String xmp)
	{
		return setXMP(hand_val, xmp);
	}
	/**
	 * get id of document.
	 * @param index must 0 or 1, 0 means first 16 bytes, 1 means last 16 bytes.
	 * @return bytes or null if no id for this document.
	 */
	public byte[] GetID(int index)
	{
		return getID( hand_val, index);
	}
	/**
	 * set meta data for document.<br/>
	 * this method valid only in premium version.
	 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate".<br/>or you can pass any key that self-defined.
	 * @param val string value.
	 * @return true or false.
	 */
	public boolean SetMeta( String tag, String val )
	{
		return setMeta( hand_val, tag, val );
	}
	/**
	 * get first root outline item.
	 * @return handle value of first root outline item. or null if no outlines.<br/>
	 */
	public Outline GetOutlines()
	{
		long ret = getOutlineRoot();
		if( ret == 0 ) return null;
		Outline ol = new Outline();
		ol.hand = ret;
		return ol;
	}
	/**
	 * check if document can be modified or saved.<br/>
	 * this always return false, if no license actived.
	 * @return true or false.
	 */
	public boolean CanSave()
	{
		return canSave( hand_val );
	}
	/**
	 * save the document.<br/>
	 * this always return false, if no license actived.
	 * @return true or false
	 */
	public boolean Save()
	{
		try {
			return save(hand_val);
		}
		catch (Exception e)
		{
			e.printStackTrace();;
			return false;
		}
	}
	/**
	 * save as the document to another file.<br/>
	 * this method require a professional or premium license.
	 * @param path path to save.
	 * @param rem_sec remove security info?
	 * @return true or false.
	 */
	public boolean SaveAs( String path, boolean rem_sec )
	{
		try {
			return saveAs(hand_val, path, rem_sec);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return false;
		}
	}
	/**
	 * encrypt document and save as the document to another file.<br/>
	 * this method require premium license.
	 * @param dst path to save， same as path parameter of SaveAs.
	 * @param upswd user password, can be null.
	 * @param opswd owner password, can be null.
	 * @param perm permission to set, same as GetPermission() method.<br/>
	 * bit 1-2 reserved<br/>
	 * bit 3(0x4) print<br/>
	 * bit 4(0x8) modify<br/>
	 * bit 5(0x10) extract text or image<br/>
	 * others: see PDF reference
	 * @param method set 3 means using AES 256bits encrypt(Acrobat X), V=5 and R = 6 mode, others AES with V=4 and R=4 mode.
	 * @param id must be 32 bytes for file ID. it is divided to 2 array in native library, as each 16 bytes.
	 * @return true or false.
	 */
	public boolean EncryptAs( String dst, String upswd, String opswd, int perm, int method, byte[] id)
	{
		try {
			return encryptAs(hand_val, dst, upswd, opswd, perm, method, id);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return false;
		}
	}
	/**
	 * check if document is encrypted.
	 * @return true or false.
	 */
	public boolean IsEncrypted()
	{
		return isEncrypted( hand_val );
	}
	/**
	 * new a root outline to document, it insert first root outline to Document.<br/>
	 * the old first root outline, shall be next of this outline.
	 * @param label label to display
	 * @param pageno pageno to jump
	 * @param top y position in PDF coordinate
	 * @return true or false
	 */
	public boolean NewRootOutline( String label, int pageno, float top )
	{
		return addOutlineChild(hand_val, 0, label, pageno, top);
	}
	/**
	 * Start import operations, import page from src<br/>
	 * a premium license is required for this method.<br/>
	 * you shall maintenance the source Document object until all pages are imported and ImportContext.Destroy() invoked.
	 * @param src source Document object that opened.
	 * @return a context object used in ImportPage.
	 */
	public ImportContext ImportStart( Document src )
	{
		if( src == null ) return null;
		long hand = importStart( hand_val, src.hand_val );
		if( hand != 0 ) return new ImportContext(this, hand);
		else return null;
	}
	/**
	 * insert a page to Document<br/>
	 * if pagheno >= page_count, it do same as append.<br/>
	 * otherwise, insert to pageno.<br/>
	 * a premium license is required for this method.
	 * @param pageno 0 based page NO.
	 * @param w page width in PDF coordinate
	 * @param h page height in PDF coordinate
	 * @return Page object or null means failed.
	 */
	public Page NewPage( int pageno, float w, float h )
	{
		long ret = newPage( hand_val, pageno, w, h );
		if( ret != 0 )
		{
			//modified by radaee.
			Page page = new Page();
			page.hand = ret;
			return page;
		}
		else return null;
	}
	/**
	 * remove page by page NO.<br/>
	 * a premium license is required for this method.
	 * @param pageno 0 based page NO.
	 * @return true or false
	 */
	public boolean RemovePage( int pageno )
	{
		//modified by radaee.
		return removePage(hand_val, pageno);
	}
	/**
	 * move the page to other position.<br/>
	 * a premium license is required for this method.
	 * @param pageno1 page NO, move from
	 * @param pageno2 page NO, move to
	 * @return true or false
	 */
	public boolean MovePage( int pageno1, int pageno2 )
	{
		return movePage(hand_val, pageno1, pageno2 );
	}
	/**
	 * create a font object, used to write texts.<br/>
	 * a premium license is required for this method.
	 * @param font_name <br/>
	 * font name exists in font list.<br/>
	 * using Global.getFaceCount(), Global.getFaceName() to enumerate fonts.
	 * @param style <br/>
	 *   (style&1) means bold,<br/>
	 *   (style&2) means Italic,<br/>
	 *   (style&8) means embed,<br/>
	 *   (style&16) means vertical writing, mostly used in Asia fonts.
	 * @return DocFont object or null is failed.
	 */
	public DocFont NewFontCID( String font_name, int style )
	{
		long ret = newFontCID(hand_val, font_name, style);
		if( ret != 0 )
		{
			DocFont font = new DocFont();
			font.hand = ret;
			font.doc = this;
			return font;
		}
		else return null;
	}
	/**
	 * create a ExtGraphicState object, used to set alpha values.<br/>
	 * a premium license is required for this method.
	 * @return DocGState object or null.
	 */
	public DocGState NewGState()
	{
		long ret = newGState(hand_val);
		if( ret != 0 )
		{
			DocGState gs = new DocGState();
			gs.hand = ret;
			gs.doc = this;
			return gs;
		}
		else return null;
	}
	/**
	 * create an image from Bitmap object.<br/>
	 * @param bmp Bitmap object in ARGB_8888/ARGB_4444/RGB_565 format.
	 * @param has_alpha generate alpha channel information?
	 * @return DocImage object or null.
	 */
	public DocImage NewImage( Bitmap bmp, boolean has_alpha )
	{
		long ret = newImage(hand_val, bmp, has_alpha);
		if( ret != 0 )
		{
			DocImage img = new DocImage();
			img.hand = ret;
			return img;
		}
		else return null;
	}

	/**
	 * create an image from Bitmap object.<br/>
	 * this method will generate an image with alpha channel.
	 * @param bmp Bitmap object in ARGB_8888/ARGB_4444 format
	 * @param matte matte value.
	 * @return DocImage object or null.
	 */
	public DocImage NewImage( Bitmap bmp, int matte )
	{
		long ret = newImage2(hand_val, bmp, matte);
		if( ret != 0 )
		{
			DocImage img = new DocImage();
			img.hand = ret;
			return img;
		}
		else return null;
	}
	/**
	 * create an image from JPEG/JPG file.<br/>
	 * supported image color space:<br/>
	 * --GRAY<br/>
	 * --RGB<br/>
	 * --CMYK<br/>
	 * @param path path to JPEG file.
	 * @return DocImage object or null.
	 */
	public DocImage NewImageJPEG( String path )
	{
		long ret = newImageJPEG(hand_val, path);
		if( ret != 0 )
		{
			DocImage img = new DocImage();
			img.hand = ret;
			return img;
		}
		else return null;
	}

	/**
	 * create an image from JPEG/JPG byte array.<br/>
	 * supported image color space:<br/>
	 * --GRAY<br/>
	 * --RGB<br/>
	 * --CMYK<br/>
	 * @param data byte array include whole jpg file.
	 * @param len byte length of data.
	 * @return DocImage object or null.
	 */
	public DocImage NewImageByMem( byte[] data, int len )
	{
		long ret = newImageJPEGByArray(hand_val, data, len);
		if( ret != 0 )
		{
			DocImage img = new DocImage();
			img.hand = ret;
			return img;
		}
		else return null;
	}
	/**
	 * create an image from JPX/JPEG 2k file.<br/>
	 * @param path path to JPX file.
	 * @return DocImage object or null.
	 */
	public DocImage NewImageJPX( String path )
	{
		long ret = newImageJPX(hand_val, path);
		if( ret != 0 )
		{
			DocImage img = new DocImage();
			img.hand = ret;
			return img;
		}
		else return null;
	}

	/**
	 * new a form from Document level.
	 * this method require SetCache() invoked.
	 * @return DocForm object or null.
	 */
	public DocForm NewForm()
	{
		long ret = newForm(hand_val);
		if(ret == 0) return null;
		DocForm form = new DocForm();
		form.hand = ret;
		form.m_doc = this;
		return form;
	}
	/**
	 * change page rect.<br/>
	 * a premium license is required for this method.
	 * @param pageno 0 based page NO.
	 * @param dl delta to left, page_left += dl;
	 * @param dt delta to top, page_top += dt;
	 * @param dr delta to right, page_right += dr;
	 * @param db delta to bottom, page_bottom += db;
	 * @return true or false.
	 */
	public boolean ChangePageRect( int pageno, float dl, float dt, float dr, float db )
	{
		return changePageRect( hand_val, pageno, dl, dt, dr, db );
	}
	/**
	 * set page rotate.<br/>
	 * a premium license is required for this method.
	 * @param pageno 0 based page NO.
	 * @param degree rotate angle in degree, must be 90 * n.
	 * @return true or false
	 */
	public boolean SetPageRotate( int pageno, int degree )
	{
		return setPageRotate( hand_val, pageno, degree );
	}

	/**
	 * verify the signature<br/>
	 * a premium license is required for this method.
	 * @param sign signature object from Annotation.GetSign()
	 * @return 0 if verify OK, others are error.
	 */
	public int VerifySign(Sign sign)
	{
		return verifySign( hand_val, sign.m_hand );
	}
	public static void BundleSave(Bundle bundle, Document doc)
	{
		bundle.putLong("pdf_doc_handle", doc.hand_val);
	}
	public static Document BundleRestore(Bundle bundle)
	{
		try
		{
			long hand = bundle.getLong("pdf_doc_handle");
			if( hand != 0 )
			{
				Document doc = new Document();
				doc.hand_val = hand;
				return doc;
			}
			else return null;
		}
		catch(Exception e)
		{
			return null;
		}
	}
	@Override
	protected void finalize() throws Throwable
	{
		Close();
		super.finalize();
	}

	public long CreateVNPage(int pageno, int cw, int ch, Bitmap.Config format)
	{
		return VNPage.create(hand_val, pageno, cw, ch, format);
	}
}
