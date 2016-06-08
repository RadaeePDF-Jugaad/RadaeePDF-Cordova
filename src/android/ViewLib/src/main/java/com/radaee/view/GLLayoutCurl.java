package com.radaee.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.opengl.GLUtils;
import android.util.Log;

import java.util.Timer;
import java.util.TimerTask;

import javax.microedition.khronos.opengles.GL10;

public class GLLayoutCurl extends GLLayout {
    private int m_cur_page;
    private int m_goto_page;
    private int m_type;
    private int m_touch_x;
    private int m_touch_y;
    private int m_text_shadow;
    public GLLayoutCurl(Context context) {
        super(context);
        m_type = 0;
        m_goto_page = -1;
        m_text_shadow = 0;
    }
    @Override
    public int vGetPage(int vx, int vy)
    {
        if(m_vw <= 0 || m_vh <= 0) return -1;
        return m_cur_page;
    }

    @Override
    public void gl_layout(float scale, boolean zoom) {
        if(m_vw <= 0 || m_vh <= 0 || zoom) return;
        float[] size = m_doc.GetPagesMaxSize();
        m_scale_min = m_vw / size[0];
        scale = m_vh / size[1];
        if(m_scale_min > scale) m_scale_min = scale;
        m_scale = m_scale_min;
        m_layw = m_vw;
        m_layh = m_vh;
        for(int pcur = 0; pcur < m_page_cnt; pcur++)
        {
            m_pages[pcur].gl_layout(m_vw, m_vh);
            m_pages[pcur].gl_alloc();
        }
    }
    private void set_page(int pageno)
    {
        if(pageno < 0) pageno = 0;
        if(pageno >= m_page_cnt) pageno = m_page_cnt - 1;
        if(m_cur_page == pageno) return;
        m_goto_page = pageno;
    }
    private boolean m_pressed = false;
    @Override
    public void gl_down(int x, int y)
    {
        if(y < (m_vh >> 1)) m_type = 1;
        else m_type = 2;
        if(x < (m_vw >> 1))
        {
            if(m_cur_page == 0) m_type = 0;
            else set_page(m_cur_page - 1);
        }
        m_touch_x = x;
        m_touch_y = y;
        m_pressed = true;
    }
    @Override
    public void gl_move(int x, int y)
    {
        if(m_pressed)
        {
            m_touch_x = x;
            m_touch_y = y;
        }
    }
    private Timer m_timer;
    @Override
    public void gl_move_end()
    {
        if(m_pressed)
        {
            m_pressed = false;
            if(m_timer != null) m_timer.cancel();
            int last_x = (m_touch_x < (m_vw >> 1)) ? 0 : m_vw;
            int last_y = (m_type == 1) ? 0 : m_vh;
            int stepx = (last_x - m_touch_x) >> 4;
            int stepy = (last_y - m_touch_y) >> 4;
            if(stepx == 0) stepx = (m_touch_x < (m_vw >> 1)) ? -1 : 1;
            if(stepy == 0) stepy = (m_type == 1) ? -1 : 1;
            final int tstepx = stepx;
            final int tstepy = stepy;
            m_timer = new Timer();
            m_timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    m_touch_x += tstepx;
                    m_touch_y += tstepy;
                    if(tstepx < 0 && m_touch_x <= 0)
                    {
                        m_touch_x = 0;
                        set_page(m_cur_page + 1);
                        m_type = 0;
                        Timer ttmp = m_timer;
                        m_timer = null;
                        ttmp.cancel();
                    }
                    else if(tstepx > 0 && m_touch_x >= m_vw)
                    {
                        m_touch_x = m_vw;
                        m_type = 0;
                        Timer ttmp = m_timer;
                        m_timer = null;
                        ttmp.cancel();
                    }
                    else if(tstepy < 0 && m_touch_y <= 0)
                    {
                        m_touch_y = 0;
                        if (m_touch_x < (m_vw >> 1)) set_page(m_cur_page + 1);
                        m_type = 0;
                        Timer ttmp = m_timer;
                        m_timer = null;
                        ttmp.cancel();
                    }
                    else if(tstepy > 0 && m_touch_y >= m_vh)
                    {
                        m_touch_y = m_vh;
                        if (m_touch_x < (m_vw >> 1)) set_page(m_cur_page + 1);
                        m_type = 0;
                        Timer ttmp = m_timer;
                        m_timer = null;
                        ttmp.cancel();
                    }
                    if (m_listener != null)
                        m_listener.OnRedraw();
                }
            }, 20, 20);
        }
    }
    @Override
    public boolean gl_fling(int holdx, int holdy, float dx, float dy, float vx, float vy)
    {
        gl_move_end();
        return true;
    }
    @Override
    public int gl_click(int x, int y) { return 1; }
    @Override
    public boolean vSupportZoom()
    {
        return false;
    }
    @Override
    public void gl_draw(GL10 gl10)
    {
        if(m_vw <= 0 || m_vh <= 0) return;
        if(m_text_shadow == 0)
        {
            Bitmap shadow = Bitmap.createBitmap(64, 512, Bitmap.Config.ARGB_8888);
            shadow.eraseColor(0x80808080);
            int pixels[] = new int[256 * 256];
            for(int y = 0; y < 256; y++)
            {
                for(int x = 0; x < 64; x++)
                {
                    int val = 0x60 * (255 - y) / 255;
                    pixels[(y << 6) + x] = (val << 24) | (val << 16) | (val << 8) | val;
                }
            }
            shadow.setPixels(pixels, 0, 64, 0, 256, 64, 256);

            int textures[] = new int[1];
            gl10.glGenTextures(1, textures, 0);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, textures[0]);
            gl10.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MIN_FILTER, GL10.GL_NEAREST);
            gl10.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MAG_FILTER, GL10.GL_LINEAR);
            GLUtils.texImage2D(GL10.GL_TEXTURE_2D, 0, shadow, 0);
            m_text_shadow = textures[0];
            shadow.recycle();
        }
        int prev = m_cur_page - 1;
        int next = m_cur_page + 1;
        if(m_goto_page >= 0)
        {
            int gprev = m_goto_page - 1;
            int gnext = m_goto_page + 1;
            while(prev <= next)
            {
                if(prev >= 0 && prev < m_page_cnt && (prev < gprev || prev > gnext))
                    m_pages[prev].gl_end(gl10, m_thread);
                prev++;
            }
            m_cur_page = m_goto_page;
            prev = m_cur_page - 1;
            next = m_cur_page + 1;
            if(m_listener != null)
            m_goto_page = -1;
        }
        while(prev <= next)
        {
            if(prev >= 0 && prev < m_cur_page)
                m_pages[prev].gl_render(gl10, m_thread);
            prev++;
        }
        if(m_type > 0 && m_cur_page < m_page_cnt - 1)
        {
            m_pages[m_cur_page + 1].gl_draw_curl(gl10, m_thread, m_def_text, m_text_shadow, 0, m_touch_x, m_touch_y);
            m_pages[m_cur_page].gl_draw_curl(gl10, m_thread, m_def_text, m_text_shadow, m_type, m_touch_x, m_touch_y);
        }
        else m_pages[m_cur_page].gl_draw_curl(gl10, m_thread, m_def_text, m_text_shadow, 0, m_touch_x, m_touch_y);
    }
    @Override
    public PDFPos vGetPos(int vx, int vy)
    {
        int pgno = vGetPage(vx, vy);
        if(pgno < 0 || pgno >= m_page_cnt) return null;
        GLPage gpage = m_pages[pgno];
        PDFPos pos = new PDFPos();
        pos.pageno = pgno;
        pos.x = gpage.GetPDFX(vx);
        pos.y = gpage.GetPDFY(vy);
        return pos;
    }
    @Override
    public void vSetPos(int vx, int vy, PDFPos pos)
    {
        if(pos == null) return;
        set_page(pos.pageno);
    }
    @Override
    public void vGotoPage( int pageno )
    {
        if( m_pages == null || pageno < 0 || pageno >= m_pages.length ) return;
        set_page(pageno);
    }
    @Override
    public void vScrolltoPage( int pageno )
    {
        if( m_pages == null || pageno < 0 || pageno >= m_pages.length ) return;
        set_page(pageno);
    }
    @Override
    public void gl_close(GL10 gl10)
    {
        super.gl_close(gl10);
        if(m_text_shadow != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_text_shadow}, 0);
            m_text_shadow = 0;
        }
    }
    @Override
    public void gl_surface_destroy(GL10 gl10)
    {
        super.gl_surface_destroy(gl10);
        if(m_text_shadow != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_text_shadow}, 0);
            m_text_shadow = 0;
        }
    }
}