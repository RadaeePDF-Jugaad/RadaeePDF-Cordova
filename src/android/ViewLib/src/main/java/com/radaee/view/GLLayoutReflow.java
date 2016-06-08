package com.radaee.view;

import android.content.Context;
import android.widget.Toast;

import com.radaee.pdf.Global;
import com.radaee.viewlib.R;

import javax.microedition.khronos.opengles.GL10;

public class GLLayoutReflow extends GLLayout
{
    private int m_cur_page;
    private GLReflowCanvas m_cur_layout;
    private int m_goto_page;
    private GLReflowCanvas m_goto_layout;
    public GLLayoutReflow(Context context) {
        super(context);
        m_goto_page = -1;
    }

    @Override
    public int vGetPage(int vx, int vy) {
        return m_cur_page;
    }

    @Override
    public void gl_layout(float scale, boolean zoom) {
        if( m_doc == null || m_vw <= m_page_gap || m_vh <= m_page_gap ) return;
        m_scale_min = (m_vw - m_page_gap) / m_doc.GetPageWidth(m_cur_page);
        if(scale < m_scale_min) scale = m_scale_min;
        if(scale > m_scale_min * Global.g_view_zoom_level) scale = m_scale_min * Global.g_view_zoom_level;
        if(!vSupportZoom()) scale = m_scale_min * 2;
        m_scale = scale;

        if(zoom) return;

        if(m_goto_page >= 0)
        {
            m_goto_layout.gl_destroy();
            m_goto_layout = null;
            m_goto_page = -1;
        }

        BUTTON_SIZE = m_vw >> 3;
        GLReflowCanvas layout = m_pages[m_cur_page].Reflow(m_vw - m_page_gap, m_scale, m_page_gap);
        if( layout != null )
        {
            m_layw = layout.getWidth() + m_page_gap;
            m_layh = layout.getHeight() + m_page_gap;
            m_goto_page = m_cur_page;
            m_goto_layout = layout;
        }
        else
        {
            m_layw = 0;
            m_layh = 0;
        }
        m_scroller.forceFinished(true);
        m_scroller.setFinalX(0);
        m_scroller.setFinalY(0);
    }
    @Override
    public PDFPos vGetPos( int vx, int vy )
    {
        if( m_doc == null || m_vw <= 0 || m_vh <= 0 ) return null;
        PDFPos m_pos = new PDFPos();
        m_pos.pageno = m_cur_page;
        m_pos.x = 0;
        m_pos.y = m_doc.GetPageHeight(m_cur_page);
        return m_pos;
    }
    @Override
    public void vSetPos(int vx, int vy, PDFPos pos)
    {
        if(pos == null) return;
        vGotoPage(pos.pageno);
    }
    @Override
    public void vGotoPage( int pageno )
    {
        if( m_doc == null || pageno < 0 || pageno >= m_doc.GetPageCount() ) return;
        if( m_cur_page == pageno ) return;
        m_cur_page = pageno;
        gl_layout(m_scale, false);
    }
    @Override
    public void vScrolltoPage( int pageno )
    {
        if( m_doc == null || pageno < 0 || pageno >= m_doc.GetPageCount() ) return;
        if( m_cur_page == pageno ) return;
        m_cur_page = pageno;
        gl_layout(m_scale, false);
    }
    @Override
    public boolean vSupportZoom()
    {
        return true;
    }
    static private int BUTTON_SIZE = 60;
    public void gl_draw(GL10 gl10)
    {
        if(m_goto_page >= 0)
        {
            if(m_cur_layout != null)
                m_cur_layout.gl_close(gl10, m_thread);
            m_cur_page = m_goto_page;
            m_cur_layout = m_goto_layout;
            m_goto_page = -1;
            m_goto_layout = null;
        }
        if(m_cur_layout == null) return;
        m_scroller.computeScrollOffset();
        //int vx = vGetX();
        int vy = vGetY();
        m_cur_layout.gl_draw(gl10, m_thread, m_def_text, vy, m_vh);

        int[] vect = new int[8];
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
        gl10.glColor4f(0.5f, 0.5f, 0.5f, 0.5f);
        vect[0] = 4 << 16;
        vect[1] = m_vh << 15;
        vect[2] = (BUTTON_SIZE + 4) << 16;
        vect[3] = (m_vh - (BUTTON_SIZE << 1)) << 15;
        vect[4] = (BUTTON_SIZE + 4) << 16;
        vect[5] = (m_vh + (BUTTON_SIZE << 1)) << 15;
        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, GLBlock.create_buf(vect));
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 3);//draw out

        vect[0] = (m_vw- 4) << 16;
        vect[1] = m_vh << 15;
        vect[2] = (m_vw - BUTTON_SIZE - 4) << 16;
        vect[3] = (m_vh - (BUTTON_SIZE << 1)) << 15;
        vect[4] = (m_vw - BUTTON_SIZE - 4) << 16;
        vect[5] = (m_vh + (BUTTON_SIZE << 1)) << 15;
        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, GLBlock.create_buf(vect));
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 3);//draw out
        gl10.glColor4f(1, 1, 1, 1);
    }
    @Override
    public void gl_close(GL10 gl10)
    {
        if(m_goto_layout != null) {
            m_goto_layout.gl_close(gl10, m_thread);
            m_goto_layout = null;
        }
        if(m_cur_layout != null) {
            m_cur_layout.gl_close(gl10, m_thread);
            m_cur_layout = null;
        }
        super.gl_close(gl10);
    }
    @Override
    public int gl_click(int x, int y)
    {
        if(y > ((m_vh - BUTTON_SIZE) >> 1) && y < ((m_vh + BUTTON_SIZE) >> 1))
        {
            if(x > 4 && x < BUTTON_SIZE + 4)//prev
            {
                vGotoPage(m_cur_page - 1);
                return 2;
            }
            if(x > m_vw - BUTTON_SIZE - 4 && x < m_vw - 4)
            {
                vGotoPage(m_cur_page + 1);
                return 2;
            }
        }
        return 1;
    }
    @Override
    public boolean vCanSave()
    {
        return false;
    }
    public void vFindStart( String key, boolean match_case, boolean whole_word )
    {
        Toast.makeText(m_ctx, R.string.no_search_reflow, Toast.LENGTH_LONG).show();
        m_finder.find_end();
    }
    public void gl_zoom_start(GL10 gl10)
    {
        if( m_pageno1 < 0 || m_pageno2 < 0 ) return;
        gl_abort_scroll();
    }
    public void gl_zoom_confirm(GL10 gl10)
    {
        gl_layout(m_scale, false);
    }
    @Override
    public void gl_surface_create(GL10 gl10)
    {
        super.gl_surface_create(gl10);
        gl_layout(2, false);
    }
    @Override
    public void gl_surface_destroy(GL10 gl10)
    {
        if(m_goto_layout != null) {
            m_goto_layout.gl_close(gl10, m_thread);
            m_goto_layout = null;
        }
        if(m_cur_layout != null) {
            m_cur_layout.gl_close(gl10, m_thread);
            m_cur_layout = null;
        }
        super.gl_surface_destroy(gl10);
    }
}
