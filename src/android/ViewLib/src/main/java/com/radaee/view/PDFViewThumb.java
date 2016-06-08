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
    private final Paint m_sel_paint = new Paint();//to avoid allocation.
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
        int cur;
        int cnt = m_doc.GetPageCount();
        float[] size = m_doc.GetPagesMaxSize();
        if (m_orientation == 0)//horz
        {
            float maxh = size[1];
            m_scale_min = ((float) (m_h - m_page_gap)) / maxh;
            m_scale_max = m_scale_min * Global.g_view_zoom_level;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];
            int left = m_w / 2;
            int top = m_page_gap / 2;
            m_docw = 0;
            m_doch = 0;
            for (cur = 0; cur < cnt; cur++) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                PDFVPage vp = m_pages[cur];
                vp.SetRect(left, top, m_scale);
                left += vp.GetWidth() + m_page_gap;
                if (m_doch < vp.GetHeight()) m_doch = vp.GetHeight();
            }
            m_docw = left + m_w / 2;
        } else if (m_orientation == 2) { //RTOL horizontal
            float maxh = size[1];
            m_scale_min = ((float) (m_h - m_page_gap)) / maxh;
            m_scale_max = m_scale_min * Global.g_view_zoom_level;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];
            int left = m_w / 2;
            int top = m_page_gap / 2;
            cur = cnt - 1;
            m_docw = 0;
            m_doch = 0;
            while (cur >= 0) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                PDFVPage vp = m_pages[cur];
                vp.SetRect(left, top, m_scale);
                left += vp.GetWidth() + m_page_gap;
                if (m_doch < vp.GetHeight()) m_doch = vp.GetHeight();
                cur--;
            }
            m_docw = left + m_w / 2;
        } else if (m_orientation == 1) //vertical
        {
            float maxw = size[0];
            m_scale_min = ((float) (m_w - m_page_gap)) / maxw;
            m_scale_max = m_scale_min * Global.g_view_zoom_level;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];
            int left = m_page_gap / 2;
            int top = m_h / 2;
            m_docw = 0;
            m_doch = 0;
            for (cur = 0; cur < cnt; cur++) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                PDFVPage vp = m_pages[cur];
                vp.SetRect(left, top, m_scale);
                top += vp.GetHeight() + m_page_gap;
                if (m_docw < vp.GetWidth()) m_docw = vp.GetWidth();
            }
            m_doch = top + m_h / 2;
        } else if (m_orientation == 3) { //Grid
            float maxh = size[1];
            m_scale_min = mThumbHeight / maxh;
            m_scale_max = m_scale_min * Global.g_view_zoom_level;
            m_scale = m_scale_min;

            if (m_pages == null) m_pages = new PDFVPage[cnt];

            int columnWidth = (int) (size[0] * m_scale);
            int columns = Global.thumbGridViewMode == 0 ? m_w / (columnWidth + m_page_gap) :
                    m_w / ((columnWidth + m_page_gap) * 2);
            int x = ((m_w - (columnWidth * columns + (m_page_gap * (columns - 1)))) / 2);

            int left = x;
            int top = m_page_gap / 2;
            m_docw = 0;
            m_doch = 0;
            for (cur = 0; cur < cnt; cur++) {
                if (m_pages[cur] == null) m_pages[cur] = new PDFVPage(m_doc, cur);
                PDFVPage vp = m_pages[cur];
                vp.SetRect(left, top, m_scale);
                if (left + vp.GetWidth() + m_page_gap > columnWidth * columns + x) {
                    top += vp.GetHeight() + m_page_gap;
                    left = x;
                } else
                    left += vp.GetWidth() + m_page_gap;

                if (m_docw < vp.GetWidth()) m_docw = vp.GetWidth();
            }
            if (cnt % columns != 0 && columns < cnt)
                top += maxh + m_page_gap;

            m_doch = top;
        }
    }

    @Override
    protected int vGetPage(int vx, int vy) {
        if (m_pages == null || m_pages.length <= 0) return -1;
        int curx = m_scroller.getCurrX();
        if (m_orientation == 0)//ltor
        {
            int left = 0;
            int right = m_pages.length - 1;
            int x = curx + vx;
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
            int x = curx + vx;
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
            int x = curx + vx;
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
            int y = curx + vy;
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

    private int getDuration2(int dis)
    {
        int dur = (dis > 0) ? dis : (-dis);
        if (dur < 100) return 100;
        if (dur > 3000) return 3000;
        return dur;
    }
    @Override
    protected boolean vOnFling(float dx, float dy, float velocityX, float velocityY) {
        if (m_pages == null) return false;
        int x = m_scroller.getCurrX();
        int y = m_scroller.getCurrY();
        x -= velocityX * Global.fling_dis * 0.5f;//to avoid divide
        y -= velocityY * Global.fling_dis * 0.5f;//to avoid divide
        int pcur = 0;
        if (m_orientation == 0) {
            while (pcur < m_pages.length) {
                PDFVPage vp = m_pages[pcur];
                if (x < vp.m_x + vp.m_w) {
                    x = vp.m_x + vp.m_w / 2 - m_w / 2;
                    x -= m_scroller.getCurrX();
                    m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, getDuration2(x));
                    break;
                }
                pcur++;
            }
            if (pcur == m_pages.length) {
                pcur--;
                PDFVPage vp = m_pages[pcur];
                x = vp.m_x + vp.m_w / 2 - m_w / 2;
                x -= m_scroller.getCurrX();
                m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, getDuration2(x));
            }
        } else if (m_orientation == 2) {
            while (pcur < m_pages.length) {
                PDFVPage vp = m_pages[pcur];
                if (x > vp.m_x) {
                    x = vp.m_x + vp.m_w / 2 - m_w / 2;
                    x -= m_scroller.getCurrX();
                    m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, getDuration2(x));
                    break;
                }
                pcur++;
            }
            if (pcur == m_pages.length) {
                pcur--;
                PDFVPage vp = m_pages[pcur];
                x = vp.m_x + vp.m_w / 2 - m_w / 2;
                x -= m_scroller.getCurrX();
                m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), x, 0, getDuration2(x));
            }
        } else {
            while (pcur < m_pages.length) {
                PDFVPage vp = m_pages[pcur];
                if (y < vp.m_y + vp.m_h) {
                    y = vp.m_y + vp.m_h / 2 - m_h / 2;
                    y -= m_scroller.getCurrY();
                    m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, y, getDuration2(y));
                    break;
                }
                pcur++;
            }
            if (pcur == m_pages.length) {
                pcur--;
                PDFVPage vp = m_pages[pcur];
                y = vp.m_y + vp.m_h / 2 - m_h / 2;
                y -= m_scroller.getCurrY();
                m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, y, getDuration2(y));
            }
        }
        return true;
    }
    private int getDuration(int dis)
    {
        int dur = (dis > 0) ? dis >> 1 : (-dis) >> 1;
        if (dur < 100) return 100;
        if (dur > 1000) return 1000;
        return dur;
    }
    @Override
    protected void vOnMoveEnd(int x, int y) {
        int pageno = vGetPage(m_w >> 1, m_h >> 1);
        if (m_pages == null) return;
        PDFVPage vp = m_pages[pageno];
        if (m_orientation == 0 || m_orientation == 2) {
            int nx = vp.m_x + ((vp.m_w - m_w) >> 1);
            int dx = nx - x;
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), nx - x, 0, getDuration(dx));

        } else if (m_orientation == 1) {
            int ny = vp.m_y + ((vp.m_h - m_h) >> 1);
            int dy = ny - y;
            m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - y, getDuration(dy));
        }
    }
    @Override
    protected boolean vSingleTap(float x, float y) {
        if (m_doc == null || m_pages == null) return false;
        int pageno = vGetPage((int) x, (int) y);
        PDFVPage vp = m_pages[pageno];
        if (m_orientation == 3 && (x < vp.m_x || x > vp.m_x + vp.m_w)) return false;
        m_sel = pageno;
        if (m_tlistener != null) m_tlistener.OnPageClicked(m_sel);
        if (m_orientation == 0 || m_orientation == 2) {
            int nx = vp.m_x + ((vp.m_w - m_w) >> 1);
            int oldx = m_scroller.getCurrX();
            int dx = nx - oldx;
            m_scroller.startScroll(oldx, m_scroller.getCurrY(), dx, 0, getDuration(dx));
        } else if (m_orientation == 3) {
            int ny = vp.m_y + ((vp.m_h - m_h) >> 1);
            int oldy = m_scroller.getCurrY();
            int dy = ny - oldy;
            m_scroller.startScroll(m_scroller.getCurrX(), oldy, 0, dy, getDuration(dy));
        } else if (m_orientation == 1) {
            int ny = vp.m_y + ((vp.m_h - m_h) >> 1);
            int oldy = m_scroller.getCurrY();
            int dy = ny - oldy;
            m_scroller.startScroll(m_scroller.getCurrX(), oldy, 0, dy, getDuration(dy));
        }
        if (m_listener != null)
            m_listener.OnPDFInvalidate(false);
        return true;
    }

    /**
     * set selected page, and then scroll to this page.
     *
     * @param pageno 0 baed page NO.
     */
    public void vSetSel(int pageno, boolean is_shown) {
        if (m_pages == null) return;
        if (pageno < 0) pageno = 0;
        if (pageno >= m_pages.length) pageno = m_pages.length - 1;
        m_sel = pageno;
        PDFVPage vp = m_pages[pageno];
        if (m_orientation == 0 || m_orientation == 2) {
            int nx = vp.m_x + ((vp.m_w - m_w) >> 1);
            int oldx = m_scroller.getCurrX();
            if (!is_shown)
            {
                m_scroller.startScroll(0,0,0,0, 0);
                m_scroller.computeScrollOffset();
                m_scroller.setFinalX(nx);
            }
            else m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), nx - oldx, 0, 1000);
        } else if (m_orientation == 3) {
            int ny = vp.m_y + ((vp.m_h - m_h) >> 1);
            int oldy = m_scroller.getCurrY();
            if (!is_shown)
            {
                m_scroller.startScroll(0,0,0,0, 0);
                m_scroller.computeScrollOffset();
                m_scroller.setFinalY(ny);
            }
            else m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - oldy, 1000);
        } else if (m_orientation == 1) {
            int ny = vp.m_y + ((vp.m_h - m_h) >> 1);
            int oldy = m_scroller.getCurrY();
            if (!is_shown)
            {
                m_scroller.startScroll(0,0,0,0, 0);
                m_scroller.computeScrollOffset();
                m_scroller.setFinalY(ny);
            }
            else m_scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, ny - oldy, 1000);
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
        m_sel_paint.setColor(Global.g_sel_color);
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
        if (Global.g_dark_mode) {
            m_draw_bmp.Invert();
        }
        m_draw_bmp.Free(m_bmp);
        canvas.drawBitmap(m_bmp, 0, 0, null);

        if (m_pages == null || m_sel < 0 || m_sel >= m_pages.length) return;
        PDFVPage vp = m_pages[m_sel];
        left = vp.GetVX(m_scroller.getCurrX());
        top = vp.GetVY(m_scroller.getCurrY());
        int right = left + vp.GetWidth();
        int bottom = top + vp.GetHeight();
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
