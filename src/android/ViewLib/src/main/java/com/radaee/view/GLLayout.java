package com.radaee.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.opengl.GLUtils;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import android.widget.Scroller;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

import javax.microedition.khronos.opengles.GL10;

abstract public class GLLayout {
    protected static float m_max_zoom = Global.g_layout_zoom_level;
    /**
     * call-back listener classv
     * @author radaee
     */
    public interface GLListener
    {
        void OnBlockRendered(int pageno);
        void OnFound(boolean found);
        void OnRedraw();
    }

    protected Context m_ctx;
    protected Scroller m_scroller;
    protected GLPage[] m_pages;
    protected int m_page_gap;
    protected int m_page_cnt;
    protected Document m_doc;
    protected VFinder m_finder;
    protected GLListener m_listener;
    private final Handler m_hand_gl = new Handler(Looper.getMainLooper())
    {
        @Override
        public void handleMessage(Message msg)
        {
            if(m_thread == null) return;
            switch( msg.what )
            {
                case 0:
                    m_listener.OnBlockRendered(((GLBlock)msg.obj).GetPageNo());
                    msg.obj = null;
                    break;
                case 2://find operation returned.
                    if( msg.arg1 == 1 )//succeeded
                    {
                        vFindGoto();
                        if( m_listener != null )
                            m_listener.OnFound( true );
                    }
                    else
                    {
                        if( m_listener != null )
                            m_listener.OnFound( false );
                    }
                    break;
            }
            super.handleMessage(msg);
        }
    };
    protected GLThread m_thread;
    protected int m_pageno1;
    protected int m_pageno2;
    protected float m_scale;
    protected float m_scale_min;
    protected int m_layw;
    protected int m_layh;
    protected int m_vw;
    protected int m_vh;
    protected int m_def_text;
    protected GLLayout(Context context)
    {
        m_ctx = context;
        m_scroller = new Scroller(context);
        m_scroller.startScroll(0, 0, 0, 0);
        m_scroller.computeScrollOffset();
        m_scale = -1;
        m_layw = 0;
        m_layh = 0;
        m_vw = 0;
        m_vh = 0;
        m_def_text = 0;

        if(GLBlock.m_cell_size <= 0) {
            WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            DisplayMetrics dm = new DisplayMetrics();
            wm.getDefaultDisplay().getMetrics(dm);
            GLBlock.m_cell_size = dm.widthPixels;
            if(GLBlock.m_cell_size > dm.heightPixels) GLBlock.m_cell_size = dm.heightPixels;
            //if(GLBlock.m_cell_size > 1024) GLBlock.m_cell_size = 1024;
            //else GLBlock.m_cell_size = 512;
        }
    }
    public void vOpen(Document doc, GLListener listener, int page_gap)
    {
        m_doc = doc;
        m_page_gap = page_gap;
        m_finder = new VFinder();
        m_listener = listener;
        m_thread = new GLThread();
        m_thread.set_handler(m_hand_gl);
        m_thread.start();
        m_page_cnt = m_doc.GetPageCount();
        m_pages = new GLPage[m_page_cnt];
        for(int pcur = 0; pcur < m_page_cnt; pcur++)
        {
            m_pages[pcur] = new GLPage(m_doc, pcur);
        }
    }
    public void gl_surface_create(GL10 gl10)
    {
        if(m_def_text != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_def_text}, 0);
            m_def_text = 0;
        }
        int[] textures = new int[1];
        Bitmap bmp = Bitmap.createBitmap(8, 8, Bitmap.Config.ARGB_8888);
        bmp.eraseColor(-1);
        gl10.glGenTextures(1, textures, 0);
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, textures[0]);
        gl10.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MIN_FILTER, GL10.GL_NEAREST);
        gl10.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MAG_FILTER, GL10.GL_LINEAR);
        GLUtils.texImage2D(GL10.GL_TEXTURE_2D, 0, bmp, 0);
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);
        m_def_text = textures[0];

        bmp.recycle();
    }
    public void gl_surface_destroy(GL10 gl10)
    {
        if(m_def_text != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_def_text}, 0);
            m_def_text = 0;
        }
        if(m_thread != null)
        {
            for( int cur = 0; cur < m_page_cnt; cur++ )
            {
                m_pages[cur].gl_end_zoom(gl10, m_thread);
                m_pages[cur].gl_end(gl10, m_thread);
            }
        }
    }
    public void gl_close(GL10 gl10)
    {
        if(m_def_text != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_def_text}, 0);
            m_def_text = 0;
        }
        if(m_thread != null)
        {
            for( int cur = 0; cur < m_page_cnt; cur++ )
            {
                m_pages[cur].gl_end_zoom(gl10, m_thread);
                m_pages[cur].gl_end(gl10, m_thread);
            }
            GLThread thread = m_thread;
            m_thread = null;
            thread.destroy();
        }
        m_doc = null;
        m_pages = null;
        m_scale = -1;
        m_layw = 0;
        m_layh = 0;
        m_vw = 0;
        m_vh = 0;
    }
    public final boolean gl_is_scroll_finished()
    {
        return m_scroller.isFinished();
    }
    protected void gl_flush_range(GL10 gl10)
    {
        if(!m_scroller.computeScrollOffset() && m_pageno2 > m_pageno1) return;
        int pageno1 = vGetPage(-GLBlock.m_cell_size, -GLBlock.m_cell_size);
        int pageno2 = vGetPage(m_vw + GLBlock.m_cell_size, m_vh + GLBlock.m_cell_size);
        if( pageno1 >= 0 && pageno2 >= 0 )
        {
            if( pageno1 > pageno2 )
            {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if( m_pageno1 < pageno1 )
            {
                int start = m_pageno1;
                int end = pageno1;
                if( end > m_pageno2 ) end = m_pageno2;
                while( start < end )
                {
                    GLPage vpage = m_pages[start];
                    vpage.gl_end_zoom(gl10, m_thread);
                    vpage.gl_end(gl10, m_thread);
                    start++;
                }
            }
            if( m_pageno2 > pageno2 )
            {
                int start = pageno2;
                int end = m_pageno2;
                if( start < m_pageno1 ) start = m_pageno1;
                while( start < end )
                {
                    GLPage vpage = m_pages[start];
                    vpage.gl_end_zoom(gl10, m_thread);
                    vpage.gl_end(gl10, m_thread);
                    start++;
                }
            }
        }
        else
        {
            int start = m_pageno1;
            int end = m_pageno2;
            while( start < end )
            {
                GLPage vpage = m_pages[start];
                vpage.gl_end_zoom(gl10, m_thread);
                vpage.gl_end(gl10, m_thread);
                start++;
            }
        }
        m_pageno1 = pageno1;
        m_pageno2 = pageno2;
    }
    public void gl_fill_color(GL10 gl10, int left, int top, int right, int bottom, float r, float g, float b)
    {
        GLBlock.drawQuadColor(gl10, m_def_text, left << 16, top << 16, right << 16, top << 16, left << 16, bottom << 16, right << 16, bottom << 16, r, g, b);
    }
    public void gl_draw(GL10 gl10)
    {
        if(m_doc == null) return;
        gl_flush_range(gl10);
        int vx = vGetX();
        int vy = vGetY();
        for(int pcur = m_pageno1; pcur < m_pageno2; pcur++)
            m_pages[pcur].gl_draw(gl10, m_thread, m_def_text, vx, vy, m_vw, m_vh);
    }
    public void gl_sync() {
        if (m_doc == null) return;
        m_scroller.computeScrollOffset();
        int pageno1 = vGetPage(-GLBlock.m_cell_size, -GLBlock.m_cell_size);
        int pageno2 = vGetPage(m_vw + GLBlock.m_cell_size, m_vh + GLBlock.m_cell_size);
        if (pageno1 >= 0 && pageno2 >= 0) {
            if (pageno1 > pageno2) {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;            }
            pageno2++;
        }
        int vx = vGetX();
        int vy = vGetY();
        for (int pcur = pageno1; pcur < pageno2; pcur++)
            m_pages[pcur].gl_sync(vx, vy, m_vw, m_vh);
        m_scroller.forceFinished(false);
    }
    public static class PDFPos
    {
        public float x = 0;
        public float y = 0;
        public int pageno = 0;
    }
    public final GLPage vGetPage(int pageno)
    {
        return m_pages[pageno];
    }
    abstract public int vGetPage(int vx, int vy);
    abstract public void gl_layout(float scale, boolean zoom);
    public void vSetPos(int vx, int vy, PDFPos pos)
    {
        if(pos == null) return;
        GLPage gpage = m_pages[pos.pageno];
        vSetX(gpage.GetVX(pos.x) - vx);
        vSetY(gpage.GetVY(pos.y) - vy);
        m_scroller.computeScrollOffset();//update scroller value immediately.
        if(m_scroller.isFinished())//let next computeScrollOffset return true. and ensure that flush range will run normally.
            m_scroller.setFinalY(m_scroller.getCurrY());//make isFinished false.
    }
    public PDFPos vGetPos(int vx, int vy)
    {
        int pgno = vGetPage(vx, vy);
        if(pgno < 0 || pgno >= m_page_cnt) return null;
        GLPage gpage = m_pages[pgno];
        PDFPos pos = new PDFPos();
        pos.pageno = pgno;
        pos.x = gpage.GetPDFX(vGetX() + vx);
        pos.y = gpage.GetPDFY(vGetY() + vy);
        return pos;
    }
    public void gl_reset(GL10 gl10)
    {
        if(m_thread != null && m_pages != null)
        {
            for( int cur = 0; cur < m_page_cnt; cur++ )
                m_pages[cur].gl_end(gl10, m_thread);
        }
    }
    /**
     * invoke when resize.
     * @param cx new width
     * @param cy new height
     */
    public void gl_resize(int cx, int cy)
    {
        if( cx <= 0 || cy <= 0 ) return;
        if( cx == m_vw && cy == m_vh ) return;
        gl_abort_scroll();
        PDFPos pos = vGetPos(m_vw >> 1, m_vh >> 1);
        m_vw = cx;
        m_vh = cy;
        gl_layout(m_scale, false);
        vSetPos(m_vw >> 1, m_vh >> 1, pos);
        gl_move_end();
    }
    public final void gl_abort_scroll()
    {
        if(m_doc == null) return;
        if(m_scroller.isFinished()) return;
        Scroller scroller = new Scroller(m_ctx);
        m_scroller.computeScrollOffset();
        scroller.startScroll(m_scroller.getCurrX(), m_scroller.getCurrY(), 0, 0, 0);
        m_scroller = scroller;
        m_scroller.computeScrollOffset();
    }
    public boolean gl_fling(int holdx, int holdy, float dx, float dy, float vx, float vy)
    {
        m_scroller.computeScrollOffset();
        m_scroller.forceFinished(true);
        m_scroller.fling(vGetX(), vGetY(), (int)-vx, (int)-vy, -m_vw, m_layw, -m_vh, m_layh);
        return true;
    }
    public void gl_down(int x, int y)
    {
    }
    public void gl_move(int x, int y)
    {
    }
    public void gl_move_end()
    {
    }
    public int gl_click(int x, int y) { return 0; }
    public boolean vSupportZoom()
    {
        return true;
    }
    public final int vGetX()
    {
        m_scroller.computeScrollOffset();
        int x = m_scroller.getCurrX();
        if(x > m_layw - m_vw) x = m_layw - m_vw;
        if(x < 0) x = 0;
        return x;
    }
    public void vSetX(int x)
    {
        if( x > m_layw - m_vw ) x = m_layw - m_vw;
        if( x < 0 ) x = 0;
        m_scroller.setFinalX(x);
    }
    public final int vGetY()
    {
        m_scroller.computeScrollOffset();
        int y = m_scroller.getCurrY();
        if(y > m_layh - m_vh) y = m_layh - m_vh;
        if(y < 0) y = 0;
        return y;
    }
    public void vSetY(int y)
    {
        if( y > m_layh - m_vh ) y = m_layh - m_vh;
        if( y < 0 ) y = 0;
        m_scroller.setFinalY(y);
    }
    public final float vGetZoom() {return m_scale/m_scale_min;}
    public final void gl_zoom_set(float zoom)
    {
        gl_layout(zoom * m_scale_min, true);
    }
    public void gl_zoom_set_pos(int vx, int vy, PDFPos pos)
    {
        vSetPos(vx, vy, pos);
    }
    public void gl_zoom_start(GL10 gl10)
    {
        if( m_pageno1 < 0 || m_pageno2 < 0 ) return;
        gl_abort_scroll();
        for(int cur = 0; cur < m_page_cnt; cur++)
        {
            m_pages[cur].gl_zoom_start(gl10, m_thread);
        }
    }
    public void gl_zoom_confirm(GL10 gl10)
    {
        for(int cur = 0; cur < m_page_cnt; cur++)
        {
            if(cur < m_pageno1 || cur >= m_pageno2)
                m_pages[cur].gl_end_zoom(gl10, m_thread);
            m_pages[cur].gl_end(gl10, m_thread);
            m_pages[cur].gl_alloc();
        }
    }
    /**
     * render page again, after page modified.
     * @param page page object obtained by vGetPage()
     */
    public void gl_render(GLPage page)
    {
        if( m_pages == null || page == null ) return;
        page.gl_set_dirty();
    }

    /**
     * render page again for a dirty bounding box, after page modified.
     * @param page page object obtained by vGetPage()
     * @param pdf_rect dirty bounding box, must 4 elements as [left, top, right, bottom]
     */
    public void gl_render(GLPage page, float[] pdf_rect)
    {
        if( m_pages == null || page == null ) return;
        page.gl_set_dirty(pdf_rect[0], pdf_rect[1], pdf_rect[2], pdf_rect[3]);
    }
    public void vGotoPage( int pageno )
    {
        if( m_pages == null || pageno < 0 || pageno >= m_pages.length ) return;
        float x = m_pages[pageno].GetLeft() - (m_page_gap >> 1);
        float y = m_pages[pageno].GetTop() - (m_page_gap >> 1);
        if( x > m_layw - m_vw ) x = m_layw - m_vw;
        if( x < 0 ) x = 0;
        if( y > m_layh - m_vh ) y = m_layh - m_vh;
        if( y < 0 ) y = 0;
        m_scroller.setFinalX((int)x);
        m_scroller.setFinalY((int)y);
        m_scroller.computeScrollOffset();
        if (m_scroller.isFinished())//let next computeScrollOffset return true. and ensure that flush range will run normally.
            m_scroller.setFinalY(m_scroller.getCurrY());//make isFinished false.
    }
    public void vScrolltoPage( int pageno )
    {
        if( m_pages == null || pageno < 0 || pageno >= m_pages.length ) return;
        int x = m_pages[pageno].GetLeft() - (m_page_gap >> 1);
        int y = m_pages[pageno].GetTop() - (m_page_gap >> 1);
        if( x > m_layw - m_vw ) x = m_layw - m_vw;
        if( x < 0 ) x = 0;
        if( y > m_layh - m_vh ) y = m_layh - m_vh;
        if( y < 0 ) y = 0;
        m_scroller.computeScrollOffset();
        int oldx = m_scroller.getCurrX();
        int oldy = m_scroller.getCurrY();
        m_scroller.startScroll(oldx, oldy, x - oldx, y - oldy);
    }
    public void vFindStart( String key, boolean match_case, boolean whole_word )
    {
        if( m_pages == null ) return;
        int pageno = vGetPage(0,0);
        m_finder.find_end();
        m_finder.find_start(m_doc, pageno, key, match_case, whole_word);
    }
    protected void vFindGoto()
    {
        if( m_pages == null ) return;
        int pg = m_finder.find_get_page();
        if( pg < 0 || pg >= m_doc.GetPageCount() ) return;
        int x = vGetX();
        int y = vGetY();
        float[] pos = m_finder.find_get_pos();
        if( pos == null ) return;
        pos[0] = m_pages[pg].GetVX(pos[0]);
        pos[1] = m_pages[pg].GetVY(pos[1]);
        pos[2] = m_pages[pg].GetVX(pos[2]);
        pos[3] = m_pages[pg].GetVY(pos[3]);
        if( x > pos[0] - m_vw/8 ) x = (int)pos[0] - m_vw/8;
        if( x < pos[2] - m_vw*7/8 ) x = (int)pos[2] - m_vw*7/8;
        if( y > pos[1] - m_vh/8 ) y = (int)pos[1] - m_vh/8;
        if( y < pos[3] - m_vh*7/8 ) y = (int)pos[3] - m_vh*7/8;
        if( x > m_layw - m_vw ) x = m_layw - m_vw;
        if( x < 0 ) x = 0;
        if( y > m_layh - m_vh ) y = m_layh - m_vh;
        if( y < 0 ) y = 0;
        gl_abort_scroll();
        m_scroller.setFinalX(x);
        m_scroller.setFinalY(y);
    }
    public int vFind(int dir)
    {
        if( m_pages == null ) return -1;
        int ret = m_finder.find_prepare(dir);
        if( ret == 1 )
        {
            if( m_listener != null )
                m_listener.OnFound( true );
            vFindGoto();
            return 0;//succeeded
        }
        if( ret == 0 )
        {
            if( m_listener != null )
                m_listener.OnFound( false );
            return -1;//failed
        }
        m_thread.find_start( m_finder );//need thread operation.
        return 1;
    }
    public void vFindEnd() {
        if (m_pages == null) return;
        m_finder.find_end();
    }

    public boolean vCanSave()
    {
        if(m_doc != null) return m_doc.CanSave();
        return false;
    }
    public void vFindDraw(Canvas canvas)
    {
        int pageno0 = m_finder.find_get_page();
        if(pageno0 >= m_pageno1 && pageno0 < m_pageno2)
            m_finder.find_draw(canvas, m_pages[pageno0], vGetX(), vGetY());
    }
    public final boolean vHasFind()
    {
        if(m_finder == null) return false;
        int pageno0 = m_finder.find_get_page();
        return (pageno0 >= m_pageno1 && pageno0 < m_pageno2);
    }
    public final void vClear(GL10 gl10, int color)
    {
        //gl10.glClear(GL10.GL_COLOR_BUFFER_BIT);
        //gl10.glClearColor(((m_back_color >> 16) & 0xff) / 255.0f, ((m_back_color >> 8) & 0xff) / 255.0f, (m_back_color & 0xff) / 255.0f, ((m_back_color >> 24) & 0xff) / 255.0f);
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, m_def_text);
        GLBlock.drawQuadColor(gl10, 0, 0, 0, m_vw << 16, 0, 0, m_vh << 16, m_vw << 16, m_vh << 16,
                ((color >> 16) & 0xff) / 255.0f, ((color >> 8) & 0xff) / 255.0f, (color & 0xff) / 255.0f);
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);
    }
    public final boolean vRenderFinished() {
        int pageno0 = m_pageno1;
        int pageno1 = m_pageno2;
        if (pageno0 < 0 || pageno1 < 0) return true;
        while (pageno0 < pageno1) {
            if (!m_pages[pageno0].vFinished()) return false;
            pageno0++;
        }
        return true;
    }
}
