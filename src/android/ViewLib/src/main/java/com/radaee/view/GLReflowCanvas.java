package com.radaee.view;

import com.radaee.pdf.Document;
import com.radaee.pdf.Page;

import javax.microedition.khronos.opengles.GL10;

public class GLReflowCanvas
{
    private int m_w;
    private int m_h;
    private int m_gap;
    private int m_cell_h;
    private GLReflowBlock[] m_blks;
    private Page m_page;
    public GLReflowCanvas(Document doc, int pageno, float scale, int w, int cell_h, int gap)
    {
        m_page = doc.GetPage(pageno);
        int h = (int)m_page.ReflowStart(w, scale, true);
        m_gap = gap;
        m_w = w + gap;
        m_h = h + gap;
        m_cell_h = cell_h;
        int blk_cnt = (m_h + m_cell_h - 1) / m_cell_h;
        if(blk_cnt > 1 && (m_h % m_cell_h) > (m_cell_h >> 1))  blk_cnt--;
        m_blks = new GLReflowBlock[blk_cnt];
        int blk_cur = 0;
        int y = 0;
        for(blk_cur = 0; blk_cur < blk_cnt - 1; blk_cur++)
        {
            m_blks[blk_cur] = new GLReflowBlock(m_page, y, m_w, m_cell_h, m_gap);
            y += m_cell_h;
        }
        m_blks[blk_cur] = new GLReflowBlock(m_page, y, m_w, m_h - y, m_gap);//last block
    }
    public void gl_draw(GL10 gl10, GLThread thread, int def_text, int vy, int vh)
    {
        if(m_blks == null) return;
        int blk_cur = 0;
        for(blk_cur = 0; blk_cur < m_blks.length; blk_cur++)
        {
            GLReflowBlock blk = m_blks[blk_cur];
            if(blk.gl_in_range(vy, vh)) {
                thread.reflow_start(blk);
                blk.gl_draw(gl10, def_text, vy, vh);
            }
            else thread.reflow_end(blk);
        }
    }
    public void gl_close(GL10 gl10, GLThread thread)
    {
        int blk_cur = 0;
        for(blk_cur = 0; blk_cur < m_blks.length; blk_cur++) {
            GLReflowBlock blk = m_blks[blk_cur];
            blk.gl_close(gl10);
            thread.reflow_end(blk);
            m_blks[blk_cur] = null;
        }
        m_blks = null;
        Page page = m_page;
        m_page = null;
        thread.reflow_destroy_page(page);//destroy page object in backing thread.
    }
    public void gl_destroy()
    {
        int blk_cur = 0;
        for(blk_cur = 0; blk_cur < m_blks.length; blk_cur++) {
            GLReflowBlock blk = m_blks[blk_cur];
            blk.destroy();
            m_blks[blk_cur] = null;
        }
        m_blks = null;
        if(m_page != null) {
            m_page.Close();
        m_page = null;
        }
    }
    public int getWidth() {return m_w;}
    public int getHeight() {return m_h;}
}
