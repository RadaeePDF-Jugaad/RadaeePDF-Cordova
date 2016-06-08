package com.radaee.view;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;

import com.radaee.pdf.BMP;
import com.radaee.pdf.Document;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.VNPage;

public class VPage implements ILayoutView.IVPage
{
	private Bitmap m_zoom_bmp;
    private long m_vpage;
    private final float m_pw;
    private final float m_ph;
    private long m_result;
    private float m_scale;
	protected VPage(Document doc, int pageno, int cw, int ch, Bitmap.Config bmp_format)
	{
		m_zoom_bmp = null;
		m_result = 0;
        m_vpage = doc.CreateVNPage(pageno, cw, ch, bmp_format);
        m_pw = doc.GetPageWidth(pageno);
        m_ph = doc.GetPageHeight(pageno);
		m_scale = 0;
	}
	protected final int GetX() {return VNPage.getX(m_vpage);}
	protected final void SetX(int x){VNPage.setX(m_vpage, x);}
	protected final int GetY() {return VNPage.getY(m_vpage);}
	protected final int GetWidth() {return VNPage.getWidth(m_vpage);}
	protected final int GetHeight() {return VNPage.getHeight(m_vpage);}
	protected final float GetPDFX(int vx){return VNPage.getPDFX(m_vpage, vx);}
	protected final float GetPDFY(int vy){return VNPage.getPDFY(m_vpage, vy);}
    public final int GetPageNo(){return VNPage.getPageNo(m_vpage);}
	public final int GetVX(float pdfx){return VNPage.getVX(m_vpage, pdfx);}
	public final int GetVY(float pdfy){return VNPage.getVY(m_vpage, pdfy);}
    protected int LocVert(int y, int gap_half) {return VNPage.locVert(m_vpage, y, gap_half);}
    protected int LocHorz(int x, int gap_half) {return VNPage.lovHorz(m_vpage, x, gap_half);}
	protected void vDestroy(VNPage.VNPageListener callback)
	{
		VNPage.destroy(m_vpage, callback);
        m_vpage = 0;
	}
	protected void vLayout(int x, int y, float scale, boolean clip)
	{
		VNPage.layout(m_vpage, x, y, scale, clip);
		m_scale = scale;
	}
	public float vGetScale()
	{
		return m_scale;
	}
    protected void vClips(VNPage.VNPageListener callback, boolean clip) {VNPage.clips(m_vpage, callback, clip);}
	protected void vEndPage(VNPage.VNPageListener callback)
	{
	    VNPage.endPage(m_vpage, callback);
		if(m_zoom_bmp != null)
		{
			m_zoom_bmp.recycle();
			m_zoom_bmp = null;
		}
	}
	protected boolean vFinished() {return VNPage.finished(m_vpage);}
	protected void vRenderAsync(VNPage.VNPageListener callback, int vx, int vy, int vw, int vh) {VNPage.renderAsync(m_vpage, callback, vx, vy, vw, vh);}
	protected void vRenderSync(VNPage.VNPageListener callback, int vx, int vy, int vw, int vh) {VNPage.renderSync(m_vpage, callback, vx, vy, vw, vh);}
    protected void vCacheStart(VNPage.VNPageListener callback, float pdfx1, float pdfy1, float pdfx2, float pdfy2)
	{
		VNPage.blkStart(m_vpage, callback, pdfx1, pdfy1, pdfx2, pdfy2);
	}
    protected void vCacheStart0(VNPage.VNPageListener callback, float pdfx, float pdfy)
	{
    	VNPage.blkStart0(m_vpage, callback, pdfx, pdfy);
	}
    protected  void vCacheStart1(VNPage.VNPageListener callback) {VNPage.blkStart1(m_vpage, callback);}
    protected void vCacheStart2(VNPage.VNPageListener callback, float pdfx, float pdfy)
	{
		VNPage.blkStart2(m_vpage, callback, pdfx, pdfy);
	}
    protected  void vCacheEnd(VNPage.VNPageListener callback) {VNPage.blkEnd(m_vpage, callback);}
	protected void vDraw(VNPage.VNPageListener callback, BMP bmp, int vx, int vy) {m_result = VNPage.Draw(m_vpage, callback, bmp, vx, vy);}
    protected boolean vDrawStep1(VNPage.VNPageListener callback, Canvas canvas) {return VNPage.drawStep1(m_vpage, callback, canvas, m_result);}
    protected void vDrawStep2(BMP bmp) {VNPage.DrawStep2(m_vpage, bmp, m_result);}
    protected void vDrawEnd(){VNPage.resultDestroy(m_result);m_result = 0;}
    private final Rect m_rect = new Rect();
	protected void vDraw(VNPage.VNPageListener callback, Canvas canvas, int vx, int vy)
	{
        if(!VNPage.blkDraw(m_vpage, callback, canvas, 0, m_ph, m_pw, 0, GetX() - vx, GetY() - vy))
        {
			m_rect.left = GetX() - vx;
			m_rect.top = GetY() - vy;
			m_rect.right = m_rect.left + GetWidth();
			m_rect.bottom = m_rect.top + GetHeight();
            if (m_zoom_bmp != null) canvas.drawBitmap(m_zoom_bmp, null, m_rect, null);
            else
            {
                Paint paint = new Paint();
                paint.setStyle(Paint.Style.FILL);
                paint.setColor(0xFFFFFFFF);
                canvas.drawRect(m_rect, paint);
            }
        }
	}
	protected void vZoomStart(Bitmap.Config bmp_format)
	{
        if(VNPage.blkRendered(m_vpage)) return;
		int w = GetWidth();
		int h = GetHeight();
		long total = w * h;
		int bits = 0;
		while( total > (1<<20) )
		{
			total >>= 2;
			w >>= 1;
			h >>= 1;
			bits++;
		}
		while( m_zoom_bmp == null )
		{
			try
			{
				m_zoom_bmp = Bitmap.createBitmap(w, h, bmp_format);
			}
			catch(Exception e)
			{
				total >>= 2;
				w >>= 1;
				h >>= 1;
				bits++;
			}
			if( bits > 8 )
                return;
		}
        if(m_vpage == 0) return;
		BMP bmp = new BMP();
		bmp.Create(m_zoom_bmp);
	    VNPage.ZoomStart(m_vpage, bmp, bits);
		bmp.Free(m_zoom_bmp);
	}
	protected void vZoomConfirmed(VNPage.VNPageListener callback, int vx, int vy, int vw, int vh)
	{
	    VNPage.zoomConfirm(m_vpage, callback, vx, vy, vw, vh);
	}
	protected void vZoomEnd()
	{
		if(m_zoom_bmp != null) m_zoom_bmp.recycle();
		m_zoom_bmp = null;
	}
	/**
	 * map x position in view to PDF coordinate
	 * @param x x position in view
	 * @param scrollx x scroll position
	 * @return
	 */
	public final float ToPDFX( float x, float scrollx ) {return VNPage.toPDFX(m_vpage, x, scrollx);}
	/**
	 * map y position in view to PDF coordinate
	 * @param y y position in view
	 * @param scrolly y scroll position
	 * @return
	 */
	public final float ToPDFY( float y, float scrolly ) {return VNPage.toPDFY(m_vpage, y, scrolly);}
	/**
	 * map x to DIB coordinate
	 * @param x x position in PDF coordinate
	 * @return
	 */
	public final float ToDIBX( float x ) {return VNPage.toDIBX(m_vpage, x);}
	/**
	 * map y to DIB coordinate
	 * @param y y position in PDF coordinate
	 * @return
	 */
	public final float ToDIBY( float y ) {return VNPage.toDIBY(m_vpage, y);}
	public final float ToPDFSize( float val )
	{
		return VNPage.toPDFSize(m_vpage, val);
	}
	/**
	 * create an Inverted Matrix maps screen coordinate to PDF coordinate.
	 * @param scrollx current x for PDFView
	 * @param scrolly current y for PDFView
	 * @return
	 */
	public final Matrix CreateInvertMatrix( float scrollx, float scrolly )
	{
		return VNPage.InvertMatrix(m_vpage, scrollx, scrolly);
	}
}