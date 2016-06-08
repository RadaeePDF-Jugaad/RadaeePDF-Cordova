package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

@Deprecated
public class PDFViewDual extends PDFView
{
	private boolean[] m_vert_dual;
	private boolean[] m_horz_dual;
	private boolean m_rtol = false;
    private boolean m_page_align_top = true;
	protected static class PDFCell
	{
		public int left;
		public int right;
		public int page_left;
		public int page_right;
	}
	protected PDFCell[] m_cells;
	public PDFViewDual(Context context)
	{
		super(context);
	}
    /**
     * set layout parameters.
     * @param verts applied duals flag for vertical screen
     * @param horzs applied duals flag for landscape screen<br/>
     * Element which set to true mean this cell treat as dual page, otherwise treat as single page.<br/>
     * For example, book has a cover(first page treat as single) just codes:<br/>
     * &nbsp;&nbsp;verts = null;<br/>
     * &nbsp;&nbsp;horzs = new boolean[1];<br/>
     * &nbsp;&nbsp;horzs[0] = false;<br/>
     * Pages, those out of array bound:<br/>
     * in vertical screen: treat as single page(false).<br/>
     * in landscape screen: treat as dual page(true).<br/>
     * @param rtol right scroll to left page mode?.<br/>
     * @param page_align_top pages align to top? if false, pages were vertically centered.
     */
	public void vSetLayoutPara(boolean[] verts, boolean[] horzs, boolean rtol, boolean page_align_top )
	{
		m_vert_dual = verts;
		m_horz_dual = horzs;
		m_rtol = rtol;
        m_page_align_top = page_align_top;
		vLayout();
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	@Override
	public void vOpen(Document doc, int page_gap, int back_color, PDFViewListener listener)
	{
		super.vOpen(doc, page_gap, back_color, listener);
		if( m_rtol )
		{
			m_scroller.setFinalX(m_docw);
			m_scroller.computeScrollOffset();
		}
	}
	@Override
	public void vResize(int w, int h)
	{
		boolean set = (m_rtol && (m_w <=0 || m_h <= 0));
		super.vResize(w, h);
		if( set )
		{
			m_scroller.setFinalX(m_docw);
			m_scroller.computeScrollOffset();
		}
	}
	@Override
	public void vGotoPage( int pageno )
	{
		vCenterPage( pageno );
	}
	@Override
	protected void vLayout()
	{
		if( m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap ) return;
		int pcur = 0;
		int pcnt = m_doc.GetPageCount();
		int ccur = 0;
		int ccnt = 0;
		float max_w = 0;
		float max_h = 0;
        m_doc.GetPagesMaxSize();
		if( m_pages == null ) m_pages = new PDFVPage[pcnt];
		if( m_h > m_w )//vertical
		{
			while( pcur < pcnt )
			{
				if( m_vert_dual != null && ccnt < m_vert_dual.length && m_vert_dual[ccnt] && pcur < pcnt - 1 )
				{
					float w = m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1);
					if( max_w < w ) max_w = w;
					float h = m_doc.GetPageHeight(pcur);
					if( max_h < h ) max_h = h;
					h = m_doc.GetPageHeight(pcur + 1);
					if( max_h < h ) max_h = h;
					pcur += 2;
				}
				else
				{
					float w = m_doc.GetPageWidth(pcur);
					if( max_w < w ) max_w = w;
					float h = m_doc.GetPageHeight(pcur);
					if( max_h < h ) max_h = h;
					pcur++;
				}
				ccnt++;
			}
            m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
            float scale = ((float)(m_h - m_page_gap)) / max_h;
            if( m_scale_min > scale ) m_scale_min = scale;
            m_scale_max = m_scale_min * Global.g_view_zoom_level;
			if( m_scale < m_scale_min ) m_scale = m_scale_min;
			if( m_scale > m_scale_max ) m_scale = m_scale_max;
			m_doch = (int)(max_h * m_scale) + m_page_gap;
			if( m_doch < m_h ) m_doch = m_h;
			m_cells = new PDFCell[ccnt];
			pcur = 0;
			ccur = 0;
			int left = 0;
			while( ccur < ccnt )
			{
				PDFCell cell = new PDFCell();
				int w = 0;
				int cw = 0;
				if( m_vert_dual != null && ccur < m_vert_dual.length && m_vert_dual[ccur] && pcur < pcnt - 1 )
				{
					w = (int)( (m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1)) * m_scale );
					if( w + m_page_gap < m_w ) cw = m_w;
					else cw = w + m_page_gap;
					cell.page_left = pcur;
					cell.page_right = pcur + 1;
					cell.left = left;
					cell.right = left + cw;
					if( m_pages[pcur] == null ) m_pages[pcur] = new PDFVPage(m_doc, pcur);
					if( m_pages[pcur+1] == null ) m_pages[pcur+1] = new PDFVPage(m_doc, pcur+1);
                    if(m_page_align_top)
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2, m_page_gap / 2, m_scale);
                        m_pages[pcur + 1].SetRect(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(), m_page_gap / 2, m_scale);
                    }
                    else
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2,
                                (int) (m_doch - m_doc.GetPageHeight(pcur) * m_scale) / 2, m_scale);
                        m_pages[pcur + 1].SetRect(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(),
                                (int) (m_doch - m_doc.GetPageHeight(pcur + 1) * m_scale) / 2, m_scale);
                    }
					pcur += 2;
				}
				else
				{
					w = (int)( m_doc.GetPageWidth(pcur) * m_scale );
					if( w + m_page_gap < m_w ) cw = m_w;
					else cw = w + m_page_gap;
					cell.page_left = pcur;
					cell.page_right = -1;
					cell.left = left;
					cell.right = left + cw;
					if( m_pages[pcur] == null ) m_pages[pcur] = new PDFVPage(m_doc, pcur);
                    if(m_page_align_top)
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2,
                                m_page_gap / 2, m_scale);
                    }
                    else
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2,
                                (int) (m_doch - m_doc.GetPageHeight(pcur) * m_scale) / 2, m_scale);
                    }
					pcur++;
				}
				left += cw;
				m_cells[ccur] = cell;
				ccur++;
			}
			m_docw = left;
		}
		else
		{
			while( pcur < pcnt )
			{
				if( (m_horz_dual == null || ccnt >= m_horz_dual.length || m_horz_dual[ccnt]) && pcur < pcnt - 1 )
				{
					float w = m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1);
					if( max_w < w ) max_w = w;
					float h = m_doc.GetPageHeight(pcur);
					if( max_h < h ) max_h = h;
					h = m_doc.GetPageHeight(pcur + 1);
					if( max_h < h ) max_h = h;
					pcur += 2;
				}
				else
				{
					float w = m_doc.GetPageWidth(pcur);
					if( max_w < w ) max_w = w;
					float h = m_doc.GetPageHeight(pcur);
					if( max_h < h ) max_h = h;
					pcur++;
				}
				ccnt++;
			}
			m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
			float scale = ((float)(m_h - m_page_gap)) / max_h;
			if( m_scale_min > scale ) m_scale_min = scale;
			m_scale_max = m_scale_min * Global.g_view_zoom_level;
			if( m_scale < m_scale_min ) m_scale = m_scale_min;
			if( m_scale > m_scale_max ) m_scale = m_scale_max;
			m_doch = (int)(max_h * m_scale) + m_page_gap;
			if( m_doch < m_h ) m_doch = m_h;
			m_cells = new PDFCell[ccnt];
			pcur = 0;
			ccur = 0;
			int left = 0;
			while( ccur < ccnt )
			{
				PDFCell cell = new PDFCell();
				int w = 0;
				int cw = 0;
				if( (m_horz_dual == null || ccur >= m_horz_dual.length || m_horz_dual[ccur]) && pcur < pcnt - 1 )
				{
					w = (int)( (m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1)) * m_scale );
					if( w + m_page_gap < m_w ) cw = m_w;
					else cw = w + m_page_gap;
					cell.page_left = pcur;
					cell.page_right = pcur + 1;
					cell.left = left;
					cell.right = left + cw;
					if( m_pages[pcur] == null ) m_pages[pcur] = new PDFVPage(m_doc, pcur);
					if( m_pages[pcur+1] == null ) m_pages[pcur+1] = new PDFVPage(m_doc, pcur+1);
                    if(m_page_align_top)
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2, m_page_gap / 2, m_scale);
                        m_pages[pcur + 1].SetRect(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(), m_page_gap / 2, m_scale);
                    }
                    else
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2,
                                (int) (m_doch - m_doc.GetPageHeight(pcur) * m_scale) / 2, m_scale);
                        m_pages[pcur + 1].SetRect(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(),
                                (int) (m_doch - m_doc.GetPageHeight(pcur + 1) * m_scale) / 2, m_scale);
                    }
					pcur += 2;
				}
				else
				{
					w = (int)( m_doc.GetPageWidth(pcur) * m_scale );
					if( w + m_page_gap < m_w ) cw = m_w;
					else cw = w + m_page_gap;
					cell.page_left = pcur;
					cell.page_right = -1;
					cell.left = left;
					cell.right = left + cw;
					if( m_pages[pcur] == null ) m_pages[pcur] = new PDFVPage(m_doc, pcur);
                    if(m_page_align_top)
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2, m_page_gap / 2, m_scale);
                    }
                    else
                    {
                        m_pages[pcur].SetRect(left + (cw - w) / 2,
                                (int) (m_doch - m_doc.GetPageHeight(pcur) * m_scale) / 2, m_scale);
                    }
					pcur++;
				}
				left += cw;
				m_cells[ccur] = cell;
				ccur++;
			}
			m_docw = left;
		}
		if( m_rtol )
		{
			ccur = 0;
			pcur = 0;
			while( ccur < ccnt )
			{
				PDFCell cell = m_cells[ccur];
				int tmp = cell.left;
				cell.left = m_docw - cell.right;
				cell.right = m_docw - tmp;
				if( cell.page_right >= 0 )
				{
					tmp = cell.page_left;
					cell.page_left = cell.page_right;
					cell.page_right = tmp;
				}
				ccur++;
			}
			while( pcur < pcnt )
			{
				PDFVPage vpage = m_pages[pcur];
				vpage.m_x = m_docw - (vpage.m_x + vpage.m_w);
				pcur++;
			}
		}
	}
	@Override
	protected int vGetPage( int vx, int vy )
	{
		if( m_pages == null || m_pages.length <= 0 ) return -1;
		int left = 0;
		int right = m_cells.length - 1;
		int x = m_scroller.getCurrX() + vx;
		if( !m_rtol )//ltor
		{
			while( left <= right )
			{
				int mid = (left + right)>>1;
				PDFCell pg1 = m_cells[mid];
				if( x < pg1.left )
				{
					right = mid - 1;
				}
				else if( x > pg1.right )
				{
					left = mid + 1;
				}
				else
				{
					PDFVPage vpage = m_pages[pg1.page_left];
					if(pg1.page_right >= 0 && x > vpage.GetX() + vpage.GetWidth() )
						return pg1.page_right;
					else
						return pg1.page_left;
				}
			}
		}
		else//rtol
		{
			while( left <= right )
			{
				int mid = (left + right)>>1;
				PDFCell pg1 = m_cells[mid];
				if( x < pg1.left )
				{
					left = mid + 1;
				}
				else if( x > pg1.right )
				{
					right = mid - 1;
				}
				else
				{
					PDFVPage vpage = m_pages[pg1.page_left];
					if(pg1.page_right >= 0 && x > vpage.GetX() + vpage.GetWidth() )
						return pg1.page_right;
					else
						return pg1.page_left;
				}
			}
		}
		if( right < 0 )
		{
			return 0;
		}
		else
		{
			return m_pages.length - 1;
		}
	}
	@Override
	public void vCenterPage( int pageno )
	{
		if( m_pages == null || m_doc == null || m_w <= 0 || m_h <= 0 ) return;
		int ccur = 0;
		while( ccur < m_cells.length )
		{
			PDFCell cell = m_cells[ccur];
			if( pageno == cell.page_left || pageno == cell.page_right )
			{
				int left = m_cells[ccur].left;
				int w = m_cells[ccur].right - left;
				int x = left + (w - m_w)/2;
				int oldx = m_scroller.getCurrX();
				int oldy = m_scroller.getCurrY();
				m_scroller.startScroll(oldx, oldy, x - oldx, 0);
				break;
			}
			ccur++;
		}
	}
	@Override
	protected void vOnMoveEnd( int x, int y )
	{
		int ccur = 0;
		if( m_rtol )
		{
			while( ccur < m_cells.length )
			{
				PDFCell cell = m_cells[ccur];
				if( x >= cell.left )
				{
					if( x <= cell.right - m_w )
					{
					}
					else if( cell.right - x > m_w/2 )
					{
						m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
					}
					else if( ccur < m_cells.length - 1 )
					{
						m_scroller.startScroll(x, y, cell.right - x, 0);
					}
					else
					{
						m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
					}
					break;
				}
				ccur++;
			}
		}
		else
		{
			while( ccur < m_cells.length )
			{
				PDFCell cell = m_cells[ccur];
				if( x < cell.right )
				{
					if( x <= cell.right - m_w )
					{
					}
					else if( cell.right - x > m_w/2 )
					{
						m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
					}
					else if( ccur < m_cells.length - 1 )
					{
						m_scroller.startScroll(x, y, cell.right - x, 0);
					}
					else
					{
						m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
					}
					break;
				}
				ccur++;
			}
		}
	}
	@Override
	protected void vOnZoomEnd()
	{
		vOnMoveEnd( m_scroller.getFinalX(), m_scroller.getFinalY() );
	}
	@Override
	protected boolean vOnFling( float dx, float dy, float velocityX, float velocityY )
	{
        if(vGetScale() > vGetMinScale()) {
            if (m_pages == null || m_lock == 3) return false;
            int ivx = (int) (-velocityX * Global.fling_dis / 2);
            int ivy = (int) (-velocityY * Global.fling_dis / 2);
            int minX = 0, maxX = m_docw - m_w, minY = 0, maxY = m_doch - m_h;

            int index = m_pageno;
            if (Global.g_view_mode == 6 && m_w > m_h && (m_horz_dual != null && m_horz_dual[m_pageno]))
                index = (m_pageno + 1) / 2;
            if (index < m_cells.length) {
                minX = m_cells[index].left;
                maxX = m_cells[index].right - m_w;
            }
            m_scroller.fling(m_scroller.getCurrX(), m_scroller.getCurrY(), ivx, ivy, minX, maxX, minY, maxY);
            return true;
        }
		float ddx = (velocityX<0)?-velocityX:velocityX;
		float ddy = (velocityY<0)?-velocityY:velocityY;
		if( ddx < ddy ) return false;
		if( dx < (m_w>>2) && dx > -(m_w>>2) ) return false;
		if( ddx < (m_w>>1) && ddx > -(m_w>>1) ) return false;
		int x = m_scroller.getCurrX();
		int y = m_scroller.getCurrY();
		if( x + m_w > m_docw ) x = m_docw - m_w;
		if( x < 0 ) x = 0;
		if( y + m_h > m_doch ) y = m_doch - m_h;
		if( y < 0 ) y = 0;
		int ccur = 0;
		while( ccur < m_cells.length )
		{
			PDFCell cell = m_cells[ccur];
			if( m_holdsx >= cell.left && m_holdsx < cell.right )
			{
				if( m_rtol )
				{
					if( dx > 0 )
					{
						if( ccur < m_cells.length - 1 )
						{
							int endx = m_cells[ccur+1].right - m_w;
							m_scroller.startScroll(x, y, endx - x, 0);
						}
						else
							m_scroller.startScroll(x, y, -x, 0);
					}
					else
					{
						if( ccur > 0 )
						{
							int endx = cell.right;
							m_scroller.startScroll(x, y, endx - x, 0);
						}
						else
							m_scroller.startScroll(x, y, m_cells[ccur].right - m_w, 0);
					}
				}
				else
				{
					if( dx > 0 )
					{
						if( ccur > 0 )
						{
							int endx = m_cells[ccur-1].right - m_w;
							m_scroller.startScroll(x, y, endx - x, 0);
						}
						else
							m_scroller.startScroll(x, y, -x, 0);
					}
					else
					{
						if( ccur < m_cells.length - 1 )
						{
							int endx = cell.right;
							m_scroller.startScroll(x, y, endx - x, 0);
						}
						else
							m_scroller.startScroll(x, y, m_cells[ccur].right - m_w, 0);
					}
				}
				return true;
			}
			ccur++;
		}
		return false;
	}
}
