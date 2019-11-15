package com.radaee.view;

import com.radaee.pdf.DIB;
import com.radaee.pdf.Document;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;

@Deprecated
public class PDFVCache
{
	protected Document m_doc;
	protected int m_pageno;
	protected Page m_page = null;
	protected float m_scale = 1;
	protected DIB m_dib = null;
	protected int m_dibw = 0;
	protected int m_dibh = 0;
	protected int m_status = 0;
	protected PDFVCache(Document doc, int pageno, float scale, int w, int h)
	{
		m_doc = doc;
		m_pageno = pageno;
		m_scale = scale;
		m_dib = null;
		m_dibw = w;
		m_dibh = h;
		m_status = 0;
	}
	protected final boolean UIIsSame(float scale, int w, int h)
	{
		return (m_scale == scale && m_dibw == w && m_dibh == h);
	}
	protected void Clear()
	{
		if( m_dib != null ) m_dib.Free();
		if( m_page != null ) m_page.Close();
		m_page = null;
		m_dib = null;
		m_status = 0;
	}
	protected final void UIRenderCancel()
	{
		if( m_status == 0 )
		{
			m_status = 2;
			Page page = m_page;
			if( page != null ) page.RenderCancel();
		}
	}
	public void Render()
	{
		if( m_status == 2 ) return;
		if( m_page == null )
			m_page = m_doc.GetPage(m_pageno);
		if( m_dib == null )
		{
			DIB dib = new DIB();
			dib.CreateOrResize( m_dibw, m_dibh );
			m_page.RenderPrepare(dib);
			m_dib = dib;
		}
		else m_page.RenderPrepare(m_dib);
		if( m_status == 2 ) return;
		Matrix mat = new Matrix(m_scale, -m_scale, 0, m_dibh);
		m_page.Render(m_dib, mat);
		mat.Destroy();
		if( m_status != 2 )
			m_status = 1;
	}
	protected void RenderThumb()
	{
		if( m_status == 2 ) return;
		if( m_page == null )
			m_page = m_doc.GetPage(m_pageno);
		if( m_dib == null )
		{
			DIB dib = new DIB();
			dib.CreateOrResize( m_dibw, m_dibh );
			m_page.RenderPrepare(dib);
			m_dib = dib;
		}
		else m_page.RenderPrepare(m_dib);
		if( m_status == 2 ) return;
		if(!m_page.RenderThumbToDIB(m_dib))
		{
			Matrix mat = new Matrix(m_scale, -m_scale, 0, m_dibh);
			m_page.Render(m_dib, mat);
			mat.Destroy();
		}
		if( m_status != 2 )
			m_status = 1;
	}
    @Override
    protected void finalize() throws Throwable
    {
        Clear();
        super.finalize();
    }
}
