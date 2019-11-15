package com.radaee.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

public class PDFViewThumb extends PDFView {


    public interface PDFThumbListener {
        void OnPageClicked(int pageno);
    }

    public PDFViewThumb(Context context) {
        super(context);
        vSetLock(5);
    }

    private int m_orientation = 0;
    private int m_sel = 0;
    private int mThumbHeight = 0;
    private Paint m_sel_paint = new Paint();//to avoid allocation.
    private PDFThumbListener m_tlistener;

    @Override
    public void vOpen(Document doc, int page_gap, int back_color, PDFViewListener listener) {
        super.vOpen(doc, page_gap, back_color, listener);
        m_sel_paint.setStyle(Style.FILL);
        if (m_orientation == 2) {
            m_scroller.setFinalX(m_docw);
            m_scroller.computeScrollOffset();
        }
    }

    @Override
    public void vClose() {
        super.vClose();
        m_tlistener = null;
        m_sel = 0;
    }

    @Override
    public void vResize(int w, int h) {
        boolean set = (m_orientation == 2 && (m_w <= 0 || m_h <= 0));
        super.vResize(w, h);
        if (set) {
            m_scroller.setFinalX(m_docw);
            m_scroller.computeScrollOffset();
        }
    }

    public void vSetThumbListener(PDFThumbListener listener) {
        m_tlistener = listener;
    }

    /**
     * set layout mode
     *
     * @param dir 0: horizontal<br/>
     *            1: vertical<br/>
     *            2: RTOL horizontal<br/>
     *            3: Grid <br/>
     */
    public void vSetOrientation(int dir) {
        if (m_orientation == dir) return;
        m_orientation = dir;
        if (m_pages == null) return;
        vLayout();
        if (m_listener != null)
            m_listener.OnPDFInvalidate(false);
    }

    /**
     * get layout mode
     *
     * @return 0: horizontal<br/>
     * 1: vertical<br/>
     * 2: RTOL horizontal<br/>
     */
    public int vGetOrientation() {
        return m_orientation;
    }

    @Override
    protected void vLayout() {
        if (m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap) return;
        int cur = 0;
        int cnt = m_doc.GetPageCount();
        float[] size = m_doc.GetPagesMaxSize();
        if (m_orientation == 0)//horz
        {
            float maxh = size[1];
            m_scale_min = ((float) (m_h - m_page_gap)) / maxh;
            m_scale_max = m_scale_min * Global.zoomLevel;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];
            int left = m_w / 2;
            int top = m_page_gap / 2;
            cur = 0;
            m_docw = 0;
            m_doch = 0;
            while (cur < cnt) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                m_pages[cur].SetRect(left, top, m_scale);
                left += m_pages[cur].GetWidth() + m_page_gap;
                if (m_doch < m_pages[cur].GetHeight()) m_doch = m_pages[cur].GetHeight();
                cur++;
            }
            m_docw = left + m_w / 2;
        } else if (m_orientation == 2) {
            float maxh = size[1];
            m_scale_min = ((float) (m_h - m_page_gap)) / maxh;
            m_scale_max = m_scale_min * Global.zoomLevel;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];
            int left = m_w / 2;
            int top = m_page_gap / 2;
            cur = cnt - 1;
            m_docw = 0;
            m_doch = 0;
            while (cur >= 0) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                m_pages[cur].SetRect(left, top, m_scale);
                left += m_pages[cur].GetWidth() + m_page_gap;
                if (m_doch < m_pages[cur].GetHeight()) m_doch = m_pages[cur].GetHeight();
                cur--;
            }
            m_docw = left + m_w / 2;
        } else if (m_orientation == 1) //vertical
        {
            float maxw = size[0];
            m_scale_min = ((float) (m_w - m_page_gap)) / maxw;
            m_scale_max = m_scale_min * Global.zoomLevel;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];
            int left = m_page_gap / 2;
            int top = m_h / 2;
            cur = 0;
            m_docw = 0;
            m_doch = 0;
            while (cur < cnt) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                m_pages[cur].SetRect(left, top, m_scale);
                top += m_pages[cur].GetHeight() + m_page_gap;
                if (m_docw < m_pages[cur].GetWidth()) m_docw = m_pages[cur].GetWidth();
                cur++;
            }
            m_doch = top + m_h / 2;
        } else if (m_orientation == 3) { //Grid
            float maxh = size[1];
            m_scale_min = mThumbHeight / maxh;
            m_scale_max = m_scale_min * Global.zoomLevel;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];

            int columnWidth = (int) (size[0] * m_scale);
            int columns = Global.thumbGridViewMode == 0 ? m_w / (columnWidth + m_page_gap) :
                    m_w / ((columnWidth + m_page_gap) * 2);
            int x = ((m_w - (columnWidth * columns + (m_page_gap * (columns - 1)))) / 2);

            int left = x;
            int top = m_page_gap / 2;
            cur = 0;
            m_docw = 0;
            m_doch = 0;
            while (cur < cnt) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                m_pages[cur].SetRect(left, top, m_scale);
                if (left + m_pages[cur].GetWidth() + m_page_gap > columnWidth * columns + x) {
                    top += m_pages[cur].GetHeight() + m_page_gap;
                    left = x;
                } else
                    left += m_pages[cur].GetWidth() + m_page_gap;

                if (m_docw < m_pages[cur].GetWidth()) m_docw = m_pages[cur].GetWidth();
                cur++;
            }
            m_doch = top;
        }
    }

    @Override
    protected int vGetPage(int vx, int vy) {
        if (m_pages == null || m_pages.length <= 0) return -1;
        if (m_orientation == 0)//ltor
        {
            int left = 0;
            int right = m_pages.length - 1;
            int x = m_scroller.getCurrX() + vx;
            int gap = m_page_gap >> 1;
            while (left <= right) {
                int mid = (left + right) >> 1;
                PDFVPage pg1 = m_pages[mid];
                if (x < pg1.GetX() - gap) {
                    right = mid - 1;
                } else if (x > pg1.GetX() + pg1.GetWidth() + gap) {
                    left = mid + 1;
                } else {
                    return mid;
                }
            }
            if (right < 0) return 0;
            else return m_pages.length - 1;
        } else if (m_orientation == 2)//rtol
        {
            int left = 0;
            int right = m_pages.length - 1;
            int x = m_scroller.getCurrX() + vx;
            int gap = m_page_gap >> 1;
            while (left <= right) {
                int mid = (left + right) >> 1;
                PDFVPage pg1 = m_pages[mid];
                if (x < pg1.GetX() - gap) {
                    left = mid + 1;
                } else if (x > pg1.GetX() + pg1.GetWidth() + gap) {
                    right = mid - 1;
                } else {
                    return mid;
                }
            }
            if (right < 0) return 0;
            else return m_pages.length - 1;
        } else if (m_orientation == 3) { //grid
            int columnWidth = (int) (m_doc.GetPagesMaxSize()[0] * m_scale);
            int columns = Global.thumbGridViewMode == 0 ? m_w / (columnWidth + m_page_gap) :
                    m_w / ((columnWidth + m_page_gap) * 2);
            int startX = ((m_w - (columnWidth * columns + (m_page_gap * (columns - 1)))) / 2);

            int left = 0;
            int right = m_pages.length - 1;
            int x = m_scroller.getCurrX() + vx;
            if (x == 0) x = startX;
            int y = m_scroller.getCurrY() + vy;
            int gap = m_page_gap >> 1;
            while (left <= right) {
                int mid = (left + right) >> 1;
                PDFVPage pg1 = m_pages[mid];
                if (y < pg1.GetY() - gap)
                    right = mid - 1;
                else if (y > pg1.GetY() + pg1.GetHeight() + gap)
                    left = mid + 1;
                else { //row found, get the correct column
                    if (x < pg1.GetX() - gap)
                        right = mid - 1;
                    else if (x > pg1.GetX() + pg1.GetWidth() + gap)
                        left = mid + 1;
                    else
                        return mid;
                }
            }
            if (right < 0) return 0;
            else return m_pages.length - 1;
        } else {
            int left = 0;
            int right = m_pages.length - 1;
            int y = m_scroller.getCurrY() + vy;
            int gap = m_page_gap >> 1;
            while (left <= right) {
                int mid = (left + right) >> 1;
                PDFVPage pg1 = m_pages[mid];
                if (y < pg1.GetY() - gap) {
                    right = mid - 1;
                } else if (y > pg1.GetY() + pg1.GetHeight() + gap) {
                    left = mid + 1;
                } else {
                    return mid;
                }
            }
            if (right < 0) return 0;
            else return m_pages.length - 1;
        }
    }

    @Override
    protected boolean vOnFling(float dx, float dy, float velocityX, float velocityY) {
        if (m_pages == null) return false;
        int x = m_scroller.getCurrX();
        int y = m_scroller.getCurrY();
        x -= velocityX * Global.fling_dis / 2;
        y -= velocityY * Global.fling_dis / 2;
        int pcur = 0;
        if (m_orientation == 0) {
            while (pcur < m_pages.length) {
                if (x < m_pages[pcur].m_x + m_pages[pcur].m_w) {
                    x = m_pages[pcur].m_x + m_pages[pcur].m_w / 2 - m_w / 2;
                    x -= m_scroller.getCurrX();
                    m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, 3000);
                    break;
                }
                pcur++;
            }
            if (pcur == m_pages.length) {
                pcur--;
                x = m_pages[pcur].m_x + m_pages[pcur].m_w / 2 - m_w / 2;
                x -= m_scroller.getCurrX();
                m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, 3000);
            }
            y = 0;
        } else if (m_orientation == 2) {
            while (pcur < m_pages.length) {
                if (x > m_pages[pcur].m_x) {
                    x = m_pages[pcur].m_x + m_pages[pcur].m_w / 2 - m_w / 2;
                    x -= m_scroller.getCurrX();
                    m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, 3000);
                    break;
                }
                pcur++;
            }
            if (pcur == m_pages.length) {
                pcur--;
                x = m_pages[pcur].m_x + m_pages[pcur].m_w / 2 - m_w / 2;
                x -= m_scroller.getCurrX();
                m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, 3000);
            }
            y = 0;
        } else {
            while (pcur < m_pages.length) {
                if (y < m_pages[pcur].m_y + m_pages[pcur].m_h) {
                    y = m_pages[pcur].m_y + m_pages[pcur].m_h / 2 - m_h / 2;
                    y -= m_scroller.getCurrY();
                    m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, y, 3000);
                    break;
                }
                pcur++;
            }
            if (pcur == m_pages.length) {
                pcur--;
                y = m_pages[pcur].m_y + m_pages[pcur].m_h / 2 - m_h / 2;
                y -= m_scroller.getCurrY();
                m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, y, 3000);
            }
            x = 0;
        }
        return true;
    }

    @Override
    protected void vOnMoveEnd(int x, int y) {
        int pageno = vGetPage(m_w / 2, m_h / 2);
        if (m_pages == null) return;
        if (m_orientation == 0 || m_orientation == 2) {
            int nx = m_pages[pageno].m_x + m_pages[pageno].m_w / 2 - m_w / 2;
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), nx - x, 0, 1000);

        } else if (m_orientation == 1) {
            int ny = m_pages[pageno].m_y + m_pages[pageno].m_h / 2 - m_h / 2;
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - y, 1000);
        }
    }

    @Override
    protected void vSingleTap(float x, float y) {
        if (m_doc == null || m_pages == null) return;
        int pageno = vGetPage((int) x, (int) y);
        if ((x < m_pages[pageno].m_x || x > m_pages[pageno].m_x + m_pages[pageno].m_w) && m_orientation == 3)
            return;
        m_sel = pageno;
        if (m_tlistener != null)
            m_tlistener.OnPageClicked(m_sel);
        if (m_orientation == 0 || m_orientation == 2) {
            int nx = m_pages[pageno].m_x + m_pages[pageno].m_w / 2 - m_w / 2;
            int oldx = m_scroller.getCurrX();
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), nx - oldx, 0, 1000);
        } else if (m_orientation == 3) {
            int ny = m_pages[pageno].m_y + m_pages[pageno].m_h / 2 - m_h / 2;
            int oldy = m_scroller.getCurrY();
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - oldy, 1000);
        } else if (m_orientation == 1) {
            int ny = m_pages[pageno].m_y + m_pages[pageno].m_h / 2 - m_h / 2;
            int oldy = m_scroller.getCurrY();
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - oldy, 1000);
        }
        if (m_listener != null)
            m_listener.OnPDFInvalidate(false);
    }

    /**
     * set selected page, and then scroll to this page.
     *
     * @param pageno
     */
    public void vSetSel(int pageno) {
        if (m_pages == null) return;
        if (pageno < 0) pageno = 0;
        if (pageno >= m_pages.length) pageno = m_pages.length - 1;
        m_sel = pageno;
        if (m_orientation == 0 || m_orientation == 2) {
            int nx = m_pages[pageno].m_x + m_pages[pageno].m_w / 2 - m_w / 2;
            int oldx = m_scroller.getCurrX();
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), nx - oldx, 0, 1000);

        } else if (m_orientation == 3) {
            int ny = m_pages[pageno].m_y + m_pages[pageno].m_h / 2 - m_h / 2;
            int oldy = m_scroller.getCurrY();
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - oldy, 1000);
        } else if (m_orientation == 1) {
            int ny = m_pages[pageno].m_y + m_pages[pageno].m_h / 2 - m_h / 2;
            int oldy = m_scroller.getCurrY();
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - oldy, 1000);
        }
        if (m_listener != null)
            m_listener.OnPDFInvalidate(false);
    }

    @Override
    protected void vFlushRange() {
        int pageno1 = vGetPage(0, 0);
        int pageno2 = vGetPage(m_w, m_h);
        if (pageno1 >= 0 && pageno2 >= 0) {
            if (pageno1 > pageno2) {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if (m_prange_start < pageno1) {
                int start = m_prange_start;
                int end = pageno1;
                if (end > m_prange_end) end = m_prange_end;
                while (start < end) {
                    m_thread.end_render(m_pages[start]);
                    start++;
                }
            }
            if (m_prange_end > pageno2) {
                int start = pageno2;
                int end = m_prange_end;
                if (start < m_prange_start) start = m_prange_start;
                while (start < end) {
                    m_thread.end_render(m_pages[start]);
                    start++;
                }
            }
        } else {
            int start = m_prange_start;
            int end = m_prange_end;
            while (start < end) {
                m_thread.end_render(m_pages[start]);
                start++;
            }
        }
        m_prange_start = pageno1;
        m_prange_end = pageno2;
        pageno1 = vGetPage(m_w / 4, m_h / 4);
        if (m_listener != null && pageno1 != m_pageno) {
            m_listener.OnPDFPageChanged(m_pageno = pageno1);
        }
    }

    @Override
    public void vDraw(Canvas canvas) {
        if (m_pages == null) return;
        m_sel_paint.setColor(Global.selColor);
        int left = m_scroller.getCurrX();
        int top = m_scroller.getCurrY();
        int left1 = left;
        int top1 = top;
        if (left1 > m_docw - m_w) left1 = m_docw - m_w;
        if (left1 < 0) left1 = 0;
        if (top1 > m_doch - m_h) top1 = m_doch - m_h;
        if (top1 < 0) top1 = 0;
        if (left1 != left) {
            m_scroller.setFinalX(left1);
            left = left1;
        }
        if (top1 != top) {
            m_scroller.setFinalY(top1);
            top = top1;
        }
        int right = left + m_w;
        int bottom = top + m_h;
        vFlushRange();
        int cur = m_prange_start;
        int end = m_prange_end;

        m_bmp.eraseColor(m_back);
        m_draw_bmp.Create(m_bmp);
        while (cur < end) {
            PDFVPage vpage = m_pages[cur];
            m_thread.start_render_thumb(vpage);
            vpage.Draw(m_draw_bmp, left, top);
            cur++;
        }
        if (Global.dark_mode) {
            m_draw_bmp.Invert();
        }
        m_draw_bmp.Free(m_bmp);
        canvas.drawBitmap(m_bmp, 0, 0, null);

        if (m_pages == null || m_sel < 0 || m_sel >= m_pages.length) return;
        left = m_pages[m_sel].GetVX(m_scroller.getCurrX());
        top = m_pages[m_sel].GetVY(m_scroller.getCurrY());
        right = left + m_pages[m_sel].GetWidth();
        bottom = top + m_pages[m_sel].GetHeight();
        canvas.drawRect(left, top, right, bottom, m_sel_paint);
        if (m_listener != null) {
            cur = m_prange_start;
            end = m_prange_end;
            while (cur < end) {
                m_listener.OnPDFPageDisplayed(canvas, m_pages[cur]);
                cur++;
            }
        }
    }

    public void setThumbHeight(int height) {
        mThumbHeight = height;
    }

    public int getThumbHeight() {
        return mThumbHeight;
    }
}