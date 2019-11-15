package com.radaee.view;

import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Rect;

import com.radaee.pdf.BMP;
import com.radaee.pdf.DIB;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;

@Deprecated
public class PDFVPage
{
	protected Document m_doc;
	public PDFVCache m_cache;
	protected PDFVSel m_sel;
	protected int m_pageno;
	protected float m_scale;
	protected int m_w = 0;
	protected int m_h = 0;
	protected int m_x;
	protected int m_y;
	protected Bitmap m_bmp = null;
	static private Paint m_thumb_paint = null;
	protected PDFVPage( Document doc, int pageno )
	{
		m_pageno = pageno;
		m_doc = doc;
		if( m_thumb_paint == null )
		{
			m_thumb_paint = new Paint();//to avoid allocation.
			m_thumb_paint.setStyle(Style.FILL);
			m_thumb_paint.setColor(0xFFFFFFFF);
		}
	}
	protected boolean SetRect( int x, int y, float scale )
	{
		if( m_x == x && m_y == y && m_scale == scale ) return false;
		m_x = x;
		m_y = y;
		m_scale = scale;
		m_w = (int)(m_scale * m_doc.GetPageWidth(m_pageno));
		m_h = (int)(m_scale * m_doc.GetPageHeight(m_pageno));
		return true;
	}
	public final boolean IsFinished()
	{
		if( m_cache != null ) return m_cache.m_status == 1;
		return true;
	}
	public int RenderPrepare()
	{
		if( m_cache == null )
		{
			m_cache = new PDFVCache( m_doc, m_pageno, m_scale, m_w, m_h );
			return 0;
		}
		if( m_cache.UIIsSame(m_scale, m_w, m_h) ) return 1;
		return 2;
	}
	/**
	 * cancel render session, mostly it invoked by UI thread.
	 * @return
	 */
	protected PDFVCache CancelRender()
	{
		if( m_cache == null ) return null;
		if( m_sel != null )
		{
			m_sel.Clear();
			m_sel = null;
		}
		PDFVCache cache = m_cache;
		m_cache = null;
		cache.UIRenderCancel();
		return cache;
	}
	protected final void SetSel( float x1, float y1, float x2, float y2, int scrollx, int scrolly )
	{
		if( m_sel == null ) m_sel = new PDFVSel(m_doc.GetPage(m_pageno));
		m_sel.SetSel( ToPDFX(x1, scrollx), ToPDFY(y1, scrolly), ToPDFX(x2, scrollx), ToPDFY(y2, scrolly) );
	}
	protected final boolean SetSelMarkup(int type)
	{
		if( m_sel != null )
			return m_sel.SetSelMarkup(type);
		return false;
	}
	protected final String GetSel()
	{
		if( m_sel == null ) return null;
		return m_sel.GetSelString();
	}
	protected final void ClearSel()
	{
		if( m_sel != null )
		{
			m_sel.m_index1 = -1;
			m_sel.m_index2 = -1;
		}
	}
	protected void DrawDIB( DIB dib, int scrollx, int scrolly )
	{
		PDFVCache cache = m_cache;
		if( cache != null && cache.m_dib != null )
		{
			cache.m_dib.DrawToDIB(dib, m_x - scrollx, m_y - scrolly);
		}
		else
			dib.DrawRect(0xFFFFFFFF, m_x - scrollx, m_y - scrolly, m_w, m_h, 1);
		if( m_sel != null )
			m_sel.DrawSelToDIB(dib, m_scale, m_doc.GetPageHeight(m_pageno), m_x - scrollx, m_y - scrolly);
	}
	/**
	 * draw to Bitmap, mostly it invoked by UI thread.
	 * @param bmp
	 * @param scrollx
	 * @param scrolly
	 */
	public void Draw( BMP bmp, int scrollx, int scrolly )
	{
		PDFVCache cache = m_cache;
		if( cache != null && cache.m_dib != null )
		{
			if( cache.UIIsSame(m_scale, m_w, m_h) )
			{
				//long rec_time = System.currentTimeMillis();
				cache.m_dib.DrawToBmp(bmp, m_x - scrollx, m_y - scrolly);
				//Log.i(String.format("bmp:%04d", m_pageno), String.valueOf(System.currentTimeMillis() - rec_time));
			}
			else
				cache.m_dib.DrawToBmp2(bmp, m_x - scrollx, m_y - scrolly, m_w, m_h);
		}
		else
			bmp.DrawRect(0xFFFFFFFF, m_x - scrollx, m_y - scrolly, m_w, m_h, 1);
		if( m_sel != null )
			m_sel.DrawSel(bmp, m_scale, m_doc.GetPageHeight(m_pageno), m_x - scrollx, m_y - scrolly);
	}
	protected final int[] GetSelRect1( int scrollx, int scrolly )
	{
		if( m_sel == null ) return null;
		return m_sel.GetRect1( m_scale, m_doc.GetPageHeight(m_pageno), m_x - scrollx, m_y - scrolly);
	}
	protected final int[] GetSelRect2( int scrollx, int scrolly )
	{
		if( m_sel == null ) return null;
		return m_sel.GetRect2( m_scale, m_doc.GetPageHeight(m_pageno), m_x - scrollx, m_y - scrolly);
	}
	/**
	 * draw to Canvas, mostly it invoked by UI thread.
	 * @param canvas
	 */
	protected void Draw( Canvas canvas, int scrollx, int scrolly )
	{
		Rect rect = new Rect();
		rect.left = m_x - scrollx;
		rect.top = m_y - scrolly;
		rect.right = rect.left + m_w;
		rect.bottom = rect.top + m_h;
		if( m_bmp != null )
		{
			canvas.drawBitmap(m_bmp, null, rect, null);
			return;
		}
		Paint paint = new Paint();
		paint.setStyle(Style.FILL);
		paint.setColor(0xFFFFFFFF);
		canvas.drawRect(rect, paint);
		if( m_sel != null )
			m_sel.DrawSel(canvas, m_scale, m_doc.GetPageHeight(m_pageno), m_x - scrollx, m_y - scrolly);
	}
	protected final void DeleteBmp()
	{
		if( m_bmp != null )
		{
			m_bmp.recycle();
			m_bmp = null;
		}
	}
	protected void CreateBmp(Config bmp_format)
	{
		if( m_cache == null || m_cache.m_status != 1 || m_bmp != null ) return;
		if( m_cache.m_dibw > 0 && m_cache.m_dibh > 0 )
		{
			float scale = 1;
			if( m_cache.m_dibw * m_cache.m_dibh > (1000000) )
				scale = Global.sqrtf((float) (1000000) / (m_cache.m_dibw * m_cache.m_dibh));
			int w = (int)(m_cache.m_dibw * scale);
			int h = (int)(m_cache.m_dibh * scale);
			if( w <= 0 ) w = 1;
			if( h <= 0 ) h = 1;
			try
			{
				m_bmp = Bitmap.createBitmap(w, h, bmp_format);
				BMP bmp = new BMP();
				bmp.Create(m_bmp);
				m_cache.m_dib.DrawToBmp2(bmp, 0, 0, w, h);
				bmp.Free(m_bmp);
			}
			catch(Exception e)
			{
			}
		}
		m_cache.Clear();
		m_cache = null;
		if( m_sel != null )
		{
			m_sel.Clear();
			m_sel = null;
		}
	}
	protected boolean NeedBmp()
	{
		if( m_bmp == null ) return false;
		if( m_cache != null )
			return ( m_cache.m_status != 1 || !m_cache.UIIsSame(m_scale, m_w, m_h) );
		else
			return true;
	}
	/**
	 * map x position in view to PDF coordinate
	 * @param x x position in view
	 * @param scrollx x scroll position
	 * @return
	 */
	public final float ToPDFX( float x, float scrollx )
	{
		float dibx = scrollx + x - m_x;
		return dibx / m_scale;
	}
	/**
	 * map y position in view to PDF coordinate
	 * @param y y position in view
	 * @param scrolly y scroll position
	 * @return
	 */
	public final float ToPDFY( float y, float scrolly )
	{
		float diby = scrolly + y - m_y;
		return (m_h - diby) / m_scale;
	}
	/**
	 * map x to DIB coordinate
	 * @param x x position in PDF coordinate
	 * @return
	 */
	public final float ToDIBX( float x )
	{
		return x * m_scale;
	}
	/**
	 * map y to DIB coordinate
	 * @param y y position in PDF coordinate
	 * @return
	 */
	public final float ToDIBY( float y )
	{
		return (m_doc.GetPageHeight(m_pageno) - y) * m_scale;
	}
	/**
	 * get Page object
	 * @return
	 */
	public final Page GetPage()
	{
		if( m_cache == null ) return null;
		return m_cache.m_page;
	}
	/**
	 * get 0 based page NO.
	 * @return
	 */
	public final int GetPageNo()
	{
		return m_pageno;
	}
	/**
	 * get x position in whole View
	 * @return
	 */
	public final int GetX()
	{
		return m_x;
	}
	/**
	 * get y position in whole View
	 * @return
	 */
	public final int GetY()
	{
		return m_y;
	}
	public final float GetScale()
	{
		return m_scale;
	}
	/**
	 * get x position in View
	 * @param scrollx x scroll position
	 * @return
	 */
	public final int GetVX( float scrollx )
	{
		return m_x - (int)scrollx;
	}
	/**
	 * get y position in View
	 * @param scrolly y scroll position
	 * @return
	 */
	public final int GetVY( float scrolly )
	{
		return m_y - (int)scrolly;
	}
	/**
	 * get page width in view
	 * @return
	 */
	public final int GetWidth()
	{
		return m_w;
	}
	/**
	 * get page width in view
	 * @return
	 */
	public final int GetHeight()
	{
		return m_h;
	}
	/**
	 * create a Matrix object maps PDF coordinate to DIB coordinate.
	 * @return
	 */
	public final Matrix CreateMatrix()
	{
		return new Matrix( m_scale, -m_scale, 0, m_h );
	}
	/**
	 * create an Inverted Matrix maps screen coordinate to PDF coordinate.
	 * @param scrollx current x for PDFView
	 * @param scrolly current y for PDFView
	 * @return
	 */
	public final Matrix CreateInvertMatrix( float scrollx, float scrolly )
	{
		return new Matrix( 1/m_scale, -1/m_scale, (scrollx - m_x)/m_scale, (m_y + m_h - scrolly)/m_scale );
	}
	/**
	 * convert size to PDF size
	 * @param val size value, mostly are line width.
	 * @return size value in PDF coordinate
	 */
	public final float ToPDFSize( float val )
	{
		return val / m_scale;
	}
	static private int size_limit = 3<<20;
	public Bitmap Reflow(int w, float scale, boolean render_images)
	{
		Page page = m_doc.GetPage(m_pageno);
		int height = (int)page.ReflowStart(w, scale, render_images);
		if( w * height > size_limit )
			height = size_limit / w;
		if( w * height <= 0 ) return null;
		Bitmap bmp = Bitmap.createBitmap( w, height, Config.ARGB_8888 );
		bmp.eraseColor(0xFFFFFFFF);
		page.ReflowToBmp(bmp, 0, 0);
		page.Close();
		return bmp;
	}
}
