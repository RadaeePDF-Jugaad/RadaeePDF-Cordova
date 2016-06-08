package com.radaee.pdf;

import android.graphics.Bitmap;

/**
 * managed many Documents as 1 Document object.
 * @author radaee
 */
public class SuperDoc extends Document
{
	static public class PageInfo
	{
		public float width;
		public float height;
	}
	static public class DocInfo
	{
		public DocInfo()
		{
			m_path = null;
			m_pswd = null;
			m_pages = null;
			m_doc = null;
			m_ref = 0;
			m_pstart = 0;
		}
		public String m_path;//path to PDF file, it can reference to PDF file not exists, but will created later outer.
		public String m_pswd;//password to PDF file.
		public PageInfo[] m_pages;//all page information.
		protected void DecRef()
		{
			m_ref--;
			if(m_ref == 0)
			{
				m_doc.Close();
				m_doc = null;
			}
		}
		private int cmp_no(int pageno)
		{
			if (pageno < m_pstart) return pageno - m_pstart;
			int plast = m_pstart + m_pages.length - 1;
			if(pageno > plast) return pageno - plast;
			return 0;
		}
		private void GetMaxPageSize(PageInfo size)
		{
			int pcnt = m_pages.length;
			for(int pcur = 0; pcur < pcnt; pcur++)
			{
				PageInfo pi = m_pages[pcur];
				if(size.width < pi.width) size.width = pi.width;
				if(size.height < pi.height) size.height = pi.height;
			}
		}
		private int m_pstart;
		private Document m_doc;//Document object, it is null if the path not loaded yet.
		private int m_ref;//reference count of Document object.
	}

	private DocInfo[] m_pdfs;
	/**
	 * Initialize SuperDoc object
	 * @param pdfs all information of PDF files.
	 * @param legacy is legacy mode? in legacy mode, all documents will open in constructor, and keep document objects till close().<br/>
	 *               if not in legacy mode, document objects will load in dynamic way, that mean less memory cost, but may slower that legacy mode.
	 */
	public SuperDoc(DocInfo[] pdfs, boolean legacy)
	{
		m_pdfs = pdfs;
		int dcnt = m_pdfs.length;
		DocInfo diprev = m_pdfs[0];
		if (legacy)
		{
			diprev.m_doc = new Document();
			diprev.m_doc.Open(diprev.m_path, diprev.m_pswd);
			diprev.m_ref = 1;
			for(int dcur = 1; dcur < dcnt; dcur++)
			{
				DocInfo dicur = m_pdfs[dcur];
				dicur.m_pstart = diprev.m_pstart + diprev.m_pages.length;
				dicur.m_doc = new Document();
				dicur.m_doc.Open(dicur.m_path, dicur.m_pswd);
				dicur.m_ref = 1;
				diprev = dicur;
			}
		}
		else
		{
			for (int dcur = 1; dcur < dcnt; dcur++) {
				DocInfo dicur = m_pdfs[dcur];
				dicur.m_pstart = diprev.m_pstart + diprev.m_pages.length;
				diprev = dicur;
			}
		}
	}
	/**
	 * check if opened.
	 * @return true or false.
	 */
	public boolean IsOpened()
	{
		return (m_pdfs != null);
	}
	/**
	 * create a empty PDF document
	 * @param path path to create
	 * @return 0 or less than 0 means failed, same as Open.
	 */
	public int Create( String path )
	{
		return -3;
	}
	public int CreateForStream( PDFStream stream )
	{
		return -3;
	}
	/**
	 * set cache file to PDF.<br/>
	 * a premium license is needed for this method.
	 * @param path a path to save some temporary data, compressed images and so on
	 * @return true or false
	 */
	public boolean SetCache( String path )
	{
		return false;
	}
	/**
	 * set font delegate to PDF.<br/>
	 * a professional or premium license is needed for this method.
	 * @param del delegate for font mapping, or null to remove delegate.
	 */
	public void SetFontDel( PDFFontDelegate del )
	{
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
		return -3;
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
		return -3;
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
		return -3;
	}
	/**
	 * get permission of PDF, this value defined in PDF reference 1.7<br/>
	 * mostly, it means the permission from encryption.<br/>
	 * this method need a professional or premium license.
	 * bit 1-2 reserved<br/>
	 * bit 3(0x4) print<br/>
	 * bit 4(0x8) modify<br/>
	 * bit 5(0x10) extract text or image<br/>
	 * others: see PDF reference
	 * @return permission flags
	 */
	public int GetPermission()
	{
		return 0;
	}
	/**
	 * get permission of PDF, this value defined in "Perm" entry in Catalog object.<br/>
	 * mostly, it means the permission from signature.<br/>
	 * this method need a professional or premium license.
	 * @return 0 means not defined<br/>
	 * 1 means can't modify<br/>
	 * 2 means can modify some form fields<br/>
	 * 3 means can do any modify<br/>
	 */
	public int GetPerm()
	{
		return 0;
	}
	/**
	 * export form data as xml string.<br/>
	 * this method need premium license.
	 * @return xml string or null.
	 */
	public String ExportForm()
	{
		return null;
	}
	/**
	 * close the document.
	 */
	public void Close()
	{
		if(m_pdfs == null) return;
		int dcnt = m_pdfs.length;
		for(int dcur = 0; dcur < dcnt; dcur++)
		{
			DocInfo di = m_pdfs[dcur];
			if(di.m_doc != null)
			{
				di.m_doc.Close();
				di.m_ref = 0;
				di.m_doc = null;
			}
		}
		hand_val = 0;
	}
	private int locate_page(int pageno)
	{
		int left = 0;
		int right = m_pdfs.length - 1;
		while(left <= right)
		{
			int mid = (left + right) >> 1;
			DocInfo dimid = m_pdfs[mid];
			int iret = dimid.cmp_no(pageno);
			if (iret > 0) left = mid + 1;
			else if(iret < 0) right = mid - 1;
			else return mid;
		}
		return -1;
	}
	/**
	 * get a Page object for page NO.
	 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
	 * @return Page object
	 */
	public Page GetPage( int pageno )
	{
		int idx = locate_page(pageno);
		if(idx < 0) return null;
		DocInfo dinfo = m_pdfs[idx];
		int pno = pageno - dinfo.m_pstart;
		if (dinfo.m_doc == null)
		{
			Document doc = new Document();
			if(doc.Open(dinfo.m_path, dinfo.m_pswd) != 0) return null;
			dinfo.m_doc = doc;
		}
		dinfo.m_ref++;
		return new SuperPage(dinfo.m_doc.GetPage(pno), dinfo);
	}
	/**
	 * get pages count.
	 * @return pages count.
	 */
	public int GetPageCount()
	{
		if(m_pdfs == null) return 0;
		int last = m_pdfs.length - 1;
		DocInfo dinfo = m_pdfs[last];
		return dinfo.m_pstart + dinfo.m_pages.length;
	}
	/**
	 * get page width by page NO.
	 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
	 * @return width value.
	 */
	public float GetPageWidth( int pageno )
	{
		int idx = locate_page(pageno);
		if(idx < 0) return 0;
		DocInfo dinfo = m_pdfs[idx];
		int pno = pageno - dinfo.m_pstart;
		return dinfo.m_pages[pno].width;
	}
	/**
	 * get page height by page NO.
	 * @param pageno 0 based page NO. range:[0, GetPageCount()-1]
	 * @return height value.
	 */
	public float GetPageHeight( int pageno )
	{
		int idx = locate_page(pageno);
		if(idx < 0) return 0;
		DocInfo dinfo = m_pdfs[idx];
		int pno = pageno - dinfo.m_pstart;
		return dinfo.m_pages[pno].height;
	}
	/**
	 * get meta data of document.
	 * @param tag Predefined values:"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate", "ModDate".<br/>or you can pass any key that self-defined.
	 * @return Meta string value, or null.
	 */
	public String GetMeta( String tag )
	{
		return null;
	}
	/**
	 * get id of document.
	 * @param index must 0 or 1, 0 means first 16 bytes, 1 means last 16 bytes.
	 * @return bytes or null if no id for this document.
	 */
	public byte[] GetID(int index)
	{
		return null;
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
		return false;
	}
	/**
	 * get first root outline item.
	 * @return handle value of first root outline item. or null if no outlines.<br/>
	 */
	public Outline GetOutlines()
	{
		return null;
	}
	/**
	 * check if document can be modified or saved.<br/>
	 * this always return false, if no license actived.
	 * @return true or false.
	 */
	public boolean CanSave()
	{
		return false;
	}
	/**
	 * save the document.<br/>
	 * this always return false, if no license actived.
	 * @return true or false
	 */
	public boolean Save()
	{
		return false;
	}
	/**
	 * save as the document to another file.<br/>
	 * this method need professional or premium license.
	 * @param path path to save.
	 * @param rem_sec remove security info?
	 * @return true or false.
	 */
	public boolean SaveAs( String path, boolean rem_sec )
	{
		return false;
	}
	/**
	 * encrypt document and save as the document to another file.<br/>
	 * this method need premium license.
	 * @param dst path to save， same as path parameter of SaveAs.
	 * @param upswd user password, can be null.
	 * @param opswd owner password, can be null.
	 * @param perm permission to set, same as GetPermission() method.<br/>
	 * bit 1-2 reserved<br/>
	 * bit 3(0x4) print<br/>
	 * bit 4(0x8) modify<br/>
	 * bit 5(0x10) extract text or image<br/>
	 * others: see PDF reference
	 * @param method reserved, currently only AES with V=4 and R=4 mode can be working.
	 * @param id must be 32 bytes for file ID. it is divided to 2 array in native library, as each 16 bytes.
	 * @return true or false.
	 */
	public boolean EncryptAs( String dst, String upswd, String opswd, int perm, int method, byte[] id)
	{
		return false;
	}
	/**
	 * check if document is encrypted.
	 * @return true or false.
	 */
	public boolean IsEncrypted()
	{
		return false;
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
		return false;
	}
	/**
	 * Start import operations, import page from src<br/>
	 * a premium license is needed for this method.<br/>
	 * you shall maintenance the source Document object until all pages are imported and ImportContext.Destroy() invoked.
	 * @param src source Document object that opened.
	 * @return a context object used in ImportPage.
	 */
	public ImportContext ImportStart( Document src )
	{
		return null;
	}
	/**
	 * import a page to the document.<br/>
	 * a premium license is needed for this method.<br/>
	 * do not forget to invoke ImportContext.Destroy() after all pages are imported.
	 * @param ctx context object created from ImportStart
	 * @param srcno 0 based page NO. from source Document that passed to ImportStart.
	 * @param dstno 0 based page NO. to insert in this document object.
	 * @return true or false.
	 */
	public boolean ImportPage( ImportContext ctx, int srcno, int dstno )
	{
		return false;
	}
	/**
	 * insert a page to Document<br/>
	 * if pagheno >= page_count, it do same as append.<br/>
	 * otherwise, insert to pageno.<br/>
	 * a premium license is needed for this method.
	 * @param pageno 0 based page NO.
	 * @param w page width in PDF coordinate
	 * @param h page height in PDF coordinate
	 * @return Page object or null means failed.
	 */
	public Page NewPage( int pageno, float w, float h )
	{
		return null;
	}
	/**
	 * remove page by page NO.<br/>
	 * a premium license is needed for this method.
	 * @param pageno 0 based page NO.
	 * @return true or false
	 */
	public boolean RemovePage( int pageno )
	{
		return false;
	}
	/**
	 * move the page to other position.<br/>
	 * a premium license is needed for this method.
	 * @param pageno1 page NO, move from
	 * @param pageno2 page NO, move to
	 * @return true or false
	 */
	public boolean MovePage( int pageno1, int pageno2 )
	{
		return false;
	}
	/**
	 * create a font object, used to write texts.<br/>
	 * a premium license is needed for this method.
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
		return null;
	}
	/**
	 * create a ExtGraphicState object, used to set alpha values.<br/>
	 * a premium license is needed for this method.
	 * @return DocGState object or null.
	 */
	public DocGState NewGState()
	{
		return null;
	}
	/**
	 * create an image from Bitmap object.<br/>
	 * a premium license is needed for this method.
	 * @param bmp Bitmap object in ARGB_8888 format.
	 * @param has_alpha generate alpha channel information?
	 * @return DocImage object or null.
	 */
	public DocImage NewImage( Bitmap bmp, boolean has_alpha )
	{
		return null;
	}
	/**
	 * create an image from JPEG/JPG file.<br/>
	 * supported image color space:<br/>
	 * --GRAY<br/>
	 * --RGB<br/>
	 * --CMYK<br/>
	 * a premium license is needed for this method.
	 * @param path path to JPEG file.
	 * @return DocImage object or null.
	 */
	public DocImage NewImageJPEG( String path )
	{
		return null;
	}
	/**
	 * create an image from JPX/JPEG 2k file.<br/>
	 * a premium license is needed for this method.
	 * @param path path to JPX file.
	 * @return DocImage object or null.
	 */
	public DocImage NewImageJPX( String path )
	{
		return null;
	}
	/**
	 * change page rect.<br/>
	 * a premium license is needed for this method.
	 * @param pageno 0 based page NO.
	 * @param dl delta to left, page_left += dl;
	 * @param dt delta to top, page_top += dt;
	 * @param dr delta to right, page_right += dr;
	 * @param db delta to bottom, page_bottom += db;
	 * @return true or false.
	 */
	public boolean ChangePageRect( int pageno, float dl, float dt, float dr, float db )
	{
		return false;
	}
	/**
	 * set page rotate.<br/>
	 * a premium license is needed for this method.
	 * @param pageno 0 based page NO.
	 * @param degree rotate angle in degree, must be 90 * n.
	 * @return true or false
	 */
	public boolean SetPageRotate( int pageno, int degree )
	{
		return false;
	}

	/**
	 * get signature contents. mostly an encrypted digest.<br/>
	 * this method valid in professional or premium version.<br/>
	 * @return byte array which format depends on Filter and SubFilter.<br/>
	 * or null, if not signed for document.
	 */
	public byte[] GetSignContents()
	{
		return null;
	}
	/**
	 * get signature filter name.<br/>
	 * this method valid in professional or premium version.<br/>
	 * @return The name of the preferred signature handler to use.<br/>
	 * Example signature handlers are "Adobe.PPKLite", "Entrust.PPKEF", "CICI.SignIt", and "VeriSign.PPKVS".<br/>
	 * others maybe user defined.
	 */
	public String GetSignFilter()
	{
		return null;
	}
	/**
	 * get sub filter name of signature.<br/>
	 * this method valid in professional or premium version.<br/>
	 * @return name that describes the encoding of the signature value and key information in the signature dictionary.<br/>
	 * like "adbe.x509.rsa_sha1", "adbe.pkcs7.detached", and "adbe.pkcs7.sha1"<br/>
	 * others maybe user defined.
	 */
	public String GetSignSubFilter()
	{
		return null;
	}
	/**
	 * get byte ranges from PDF file, to get digest.<br/>
	 * this method valid in professional or premium version.<br/>
	 * @return an integer pair array, to record byte ranges.<br/>
	 * each pair describing a range to digest.<br/>
	 * 1st element of pair is offset.<br/>
	 * 2nd element of pair is length.
	 */
	public int[] GetSignByteRange()
	{
		return null;
	}
	/**
	 * check object defined in signature("Data" entry), is in byte ranges defined in signature.
	 * this method valid in professional or premium version.<br/>
	 * to ensure PDF file modified, mostly you shall(Adobe Standard):<br/>
	 * 1. invoke this method first.<br/>
	 * 2. if succeeded, then get signature contents(see GetSignContents).<br/>
	 * 3. decode public key from contents(see GetSignContents).<br/>
	 * 4. decode encrypted digest from contents.<br/>
	 * 5. decrypt digest.1 using public key, for step 4.<br/>
	 * 6. calculate digest.2 by yourself, using byte ranges(GetSignByteRange).<br/>
	 * 7. check digest.1 == digest.2
	 * @return <br/>
	 * -1: unknown or not defined in signature.<br/>
	 *  0: check failed, means modified.<br/>
	 *  1: check succeeded, means no new objects after signature.
	 */
	public int CheckSignByteRange()
	{
		return -1;
	}

	public float[] GetPagesMaxSize()
	{
		int dcnt = m_pdfs.length;
		PageInfo psize = new PageInfo();
		float[] msize = new float[2];
		for(int dcur = 0; dcur < dcnt; dcur++)
		{
			DocInfo di = m_pdfs[dcur];
			di.GetMaxPageSize(psize);
			if(msize[0] < psize.width) msize[0] = psize.width;
			if(msize[1] < psize.height) msize[1] = psize.height;
		}
		return msize;
	}
	public Page GetPage0()
	{
		return GetPage(0);
	}
	@Override
	public long CreateVNPage(int pageno, int cw, int ch, Bitmap.Config format)
	{
		int idx = locate_page(pageno);
		if(idx < 0) return 0;
		DocInfo dinfo = m_pdfs[idx];
		int pno = pageno - dinfo.m_pstart;
		Document doc;
		if (dinfo.m_doc == null)
		{
			doc = new Document();
			if(doc.Open(dinfo.m_path, dinfo.m_pswd) != 0) return 0;
			dinfo.m_doc = doc;
		}
		doc = dinfo.m_doc;
		return VNPage.create(doc.hand_val, pno, cw, ch, format);
	}
	@Override
	protected void finalize() throws Throwable
	{
		Close();
		super.finalize();
	}
}
