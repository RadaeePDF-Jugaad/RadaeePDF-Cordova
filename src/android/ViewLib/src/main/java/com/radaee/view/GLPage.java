package com.radaee.view;

import android.graphics.Bitmap;

import com.radaee.pdf.Document;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;

import javax.microedition.khronos.opengles.GL10;

public class GLPage implements ILayoutView.IVPage{
    private final Document m_doc;
    private final int m_pageno;
    private int m_left;
    private int m_top;
    private int m_right;
    private int m_bottom;
    private int m_pw;
    private int m_ph;
    private float m_scale;
    private boolean m_dirty;
    private boolean m_curl;
    private GLBlock[] m_blks;
    private GLBlock[] m_blks_zoom;
    public GLPage(Document doc, int pageno)
    {
        m_doc = doc;
        m_pageno = pageno;
        m_blks = null;
        m_blks_zoom = null;
        m_dirty = false;
    }
    protected final void gl_layout(int x, int y, float scale)
    {
        m_left = x;
        m_top = y;
        m_pw = (int)(m_doc.GetPageWidth(m_pageno) * scale);
        m_ph = (int)(m_doc.GetPageHeight(m_pageno) * scale);
        m_right = m_left + m_pw;
        m_bottom = m_top + m_ph;
        m_scale = scale;
        m_curl = false;
    }
    protected final void gl_layout(int w, int h)
    {
        m_left = 0;
        m_top = 0;
        m_right = m_left + w;
        m_bottom = m_top + h;
        float pw = m_doc.GetPageWidth(m_pageno);
        float ph = m_doc.GetPageHeight(m_pageno);
        float scale = w / pw;
        m_scale = h / ph;
        if(m_scale > scale) m_scale = scale;
        m_curl = true;
        m_pw = (int)(pw * m_scale);
        m_ph = (int)(ph * m_scale);
    }
    protected final void gl_alloc()
    {
        int width = m_right - m_left;
        int height = m_bottom - m_top;
        int csize2 = GLBlock.m_cell_size << 1;
        if(!m_curl && GLBlock.m_cell_size > 0 && (width >= csize2 || height >= csize2))
        {
            int xcnt = (width + GLBlock.m_cell_size - 1) / GLBlock.m_cell_size;
            int ycnt = (height + GLBlock.m_cell_size - 1) / GLBlock.m_cell_size;
            m_blks = new GLBlock[xcnt * ycnt];
            int cury = 0;
            for(int yb = 0; yb < ycnt; yb++)
            {
                int curx = 0;
                int bheight = (yb < ycnt - 1) ? GLBlock.m_cell_size : height - cury;
                for(int xb = 0; xb < xcnt; xb++)
                {
                    int bwidth = (xb < xcnt - 1) ? GLBlock.m_cell_size : width - curx;
                    m_blks[yb * xcnt + xb] = new GLBlock(m_doc, m_pageno, m_scale, curx, cury, bwidth, bheight, height);
                    curx += bwidth;
                }
                cury += bheight;
            }
        }
        else
        {
            m_blks = new GLBlock[1];
            m_blks[0] = new GLBlock(m_doc, m_pageno, m_scale, 0, 0, m_right - m_left, m_bottom - m_top, height);
        }
    }
    /**
     * set whole page as dirty
     */
    protected void gl_set_dirty()
    {
        m_dirty = true;
    }
    /**
     * set dirty for a area
     * @param pdfl left of dirty bounding box
     * @param pdft top of dirty bounding box
     * @param pdfr right of dirty bounding box
     * @param pdfb bottom of dirty bounding box
     */
    protected void gl_set_dirty(float pdfl, float pdft, float pdfr, float pdfb)
    {
        int dibl = (int)(pdfl * m_scale);
        int dibt = m_ph - (int)(pdfb * m_scale);
        int dibr = (int)(pdfr * m_scale);
        int dibb = m_ph - (int)(pdft * m_scale);
        if (m_blks_zoom != null)
        {
            GLBlock glb = m_blks_zoom[m_blks_zoom.length - 1];
            int srcw = glb.GetRight();
            int srch = glb.GetBottom();
            if (srcw != m_pw || srch != m_ph) return;
        }
        if (m_blks_zoom == null) m_blks_zoom = new GLBlock[m_blks.length];
        for (int idx = 0; idx < m_blks.length; idx++)
        {
            GLBlock glb = m_blks[idx];
            if (glb.isCross(dibl, dibt, dibr, dibb))
            {
                if (m_blks_zoom[idx] == null || !m_blks_zoom[idx].has_render()) {
                    m_blks_zoom[idx] = glb;
                    m_blks[idx] = new GLBlock(m_doc, m_pageno, m_scale, glb.GetX(), glb.GetY(), glb.GetW(), glb.GetH(), m_ph);
                }
            }
            else
            {
                if (m_blks_zoom[idx] == null)
                    m_blks_zoom[idx] = new GLBlock(m_doc, m_pageno, m_scale, glb.GetX(), glb.GetY(), glb.GetW(), glb.GetH(), m_ph);
            }
        }
    }
    public final void gl_render(GL10 gl10, GLThread thread)
    {
        thread.render_start(m_blks[0]);
    }
    public final void gl_draw_curl(GL10 gl10, GLThread thread, int def_text, int shadow_text, int type, int x, int y)
    {
        if(!m_blks[0].gl_make_text()) thread.render_start(m_blks[0]);
        m_blks[0].gl_draw_curl(gl10, def_text, type, x, y, shadow_text);
    }
    public final void gl_draw(GL10 gl10, GLThread thread, int def_text, int orgx, int orgy, int w, int h)
    {
        if(m_dirty)
        {
            m_dirty = false;
            gl_zoom_start(gl10, thread);
            gl_alloc();
        }
        int bl = m_left - orgx;
        int bt = m_top - orgy;
        int br = m_right - orgx;
        int bb = m_bottom - orgy;
        if(bl < 0) bl = 0;
        if(bt < 0) bt = 0;
        if(br > w) br = w;
        if(bb > h) bb = h;
        if(br > bl && bb > bt)
            GLBlock.drawQuadColor(gl10, def_text, bl << 16, bt << 16, br << 16, bt << 16, bl << 16, bb << 16, br << 16, bb << 16, 1, 1, 1);
        int left = m_left - orgx;
        int top = m_top - orgy;
        if(m_blks_zoom != null)//draw zoom cache first.
        {
            GLBlock glb = m_blks_zoom[m_blks_zoom.length - 1];
            int srcw = glb.GetRight();
            int srch = glb.GetBottom();
            int dstw = m_right - m_left;
            int dsth = m_bottom - m_top;
            for (GLBlock glBlock : m_blks_zoom) {
                glb = glBlock;
                bl = left + glb.GetX() * dstw / srcw;
                bt = top + glb.GetY() * dsth / srch;
                br = left + glb.GetRight() * dstw / srcw;
                bb = top + glb.GetBottom() * dsth / srch;
                if (br <= 0 || bl >= w || bb <= 0 || bt >= h) continue;
                if (glb.gl_make_text()) glb.gl_draw(gl10, -1, bl, bt, br, bb);
            }
        }
        if(m_blks == null) return;//then draw the blocks.
        boolean all_ok = true;
        bl = -left - GLBlock.m_cell_size;
        bt = -top - GLBlock.m_cell_size;
        br = w - left + GLBlock.m_cell_size;
        bb = h - top + GLBlock.m_cell_size;
        for (GLBlock glb : m_blks) {
            if (glb.isCross(bl, bt, br, bb)) {
                if (!glb.gl_make_text()) {
                    all_ok = false;
                    thread.render_start(glb);
                    if (m_blks_zoom == null)//not in zooming status.
                        glb.gl_draw(gl10, def_text, left + glb.GetX(), top + glb.GetY(), left + glb.GetRight(), top + glb.GetBottom());
                } else//texture is ready
                    glb.gl_draw(gl10, def_text, left + glb.GetX(), top + glb.GetY(), left + glb.GetRight(), top + glb.GetBottom());
            } else thread.render_end(gl10, glb);
        }
        if(all_ok) gl_end_zoom(gl10, thread);//destroy zoom cache and draw blk.
    }
    /**
     * draw page with more cache.
     * @param gl10
     * @param thread
     * @param def_text
     * @param orgx
     * @param orgy
     * @param w
     * @param h
     */
    public final void gl_draw2(GL10 gl10, GLThread thread, int def_text, int orgx, int orgy, int w, int h) {
        if (m_dirty) {
            m_dirty = false;
            gl_zoom_start(gl10, thread);
            gl_alloc();
        }
        int bl = m_left - orgx;
        int bt = m_top - orgy;
        int br = m_right - orgx;
        int bb = m_bottom - orgy;
        if (bl < 0) bl = 0;
        if (bt < 0) bt = 0;
        if (br > w) br = w;
        if (bb > h) bb = h;
        if (br > bl && bb > bt)
            GLBlock.drawQuadColor(gl10, def_text, bl << 16, bt << 16, br << 16, bt << 16, bl << 16, bb << 16, br << 16, bb << 16, 1, 1, 1);
        int left = m_left - orgx;
        int top = m_top - orgy;
        if (m_blks_zoom != null)//draw zoom cache first.
        {
            GLBlock glb = m_blks_zoom[m_blks_zoom.length - 1];
            int srcw = glb.GetRight();
            int srch = glb.GetBottom();
            int dstw = m_right - m_left;
            int dsth = m_bottom - m_top;
            for (GLBlock glBlock : m_blks_zoom) {
                glb = glBlock;
                bl = left + glb.GetX() * dstw / srcw;
                bt = top + glb.GetY() * dsth / srch;
                br = left + glb.GetRight() * dstw / srcw;
                bb = top + glb.GetBottom() * dsth / srch;
                if (br <= 0 || bl >= w || bb <= 0 || bt >= h) continue;
                if (glb.gl_make_text()) glb.gl_draw(gl10, -1, bl, bt, br, bb);
            }
        }
        if (m_blks == null) return;//then draw the blocks.
        boolean all_ok = true;
        bl = -left;
        bt = -top;
        br = w - left;
        bb = h - top;
        int bl1 = -left - w - GLBlock.m_cell_size;
        int bt1 = -top - GLBlock.m_cell_size;
        int br1 = w - left + w + GLBlock.m_cell_size;
        int bb1 = h - top + GLBlock.m_cell_size;
        for (GLBlock glb : m_blks) {
            if (glb.isCross(bl1, bt1, br1, bb1))//in cache area?
            {
                if (glb.isCross(bl, bt, br, bb))//in display area?
                {
                    if (!glb.gl_make_text()) {
                        all_ok = false;
                        thread.render_start(glb);
                        if (m_blks_zoom == null)//not in zooming status.
                            glb.gl_draw(gl10, def_text, left + glb.GetX(), top + glb.GetY(), left + glb.GetRight(), top + glb.GetBottom());
                    } else//texture is ready
                        glb.gl_draw(gl10, def_text, left + glb.GetX(), top + glb.GetY(), left + glb.GetRight(), top + glb.GetBottom());
                } else
                    thread.render_start(glb);
            } else thread.render_end(gl10, glb);
        }
        if (all_ok) gl_end_zoom(gl10, thread);//destroy zoom cache and draw blk.
    }
    public final void gl_sync(int orgx, int orgy, int w, int h) {
        if (m_blks == null) {
            gl_alloc();
        }
        int left = m_left - orgx;
        int top = m_top - orgy;
        if (m_blks == null) return;//then draw the blocks.
        int bl = -left - GLBlock.m_cell_size;
        int bt = -top - GLBlock.m_cell_size;
        int br = w - left + GLBlock.m_cell_size;
        int bb = h - top + GLBlock.m_cell_size;
        for (GLBlock glb : m_blks) {
            if (glb.isCross(bl, bt, br, bb)) {
                if (!glb.gl_make_text() && !glb.has_render()) {
                    glb.gl_start();
                    glb.bk_render();
                }
            }
        }
    }
    public final void gl_end(GL10 gl10, GLThread thread)
    {
        if(m_blks == null) return;
        for(int cur = 0; cur < m_blks.length; cur++)
        {
            GLBlock glb = m_blks[cur];
            if (thread.render_end(gl10, glb)) m_blks[cur] = new GLBlock(glb, m_doc);
        }
    }
    public final void gl_end_zoom(GL10 gl10, GLThread thread)
    {
        if(m_blks_zoom == null) return;
        for (GLBlock glBlock : m_blks_zoom) thread.render_end(gl10, glBlock);
        m_blks_zoom = null;
    }
    protected final void gl_zoom_start(GL10 gl10, GLThread thread)
    {
        if(m_blks_zoom != null)
        {
            if(m_blks != null)
            {
                for (GLBlock glb : m_blks) {
                    thread.render_end(gl10, glb);
                }
                m_blks = null;
            }
            return;
        }
        m_blks_zoom = m_blks;
        m_blks = null;
    }
    public final int GetPageNo(){return m_pageno;}
    protected final int GetLeft(){return m_left;}
    protected final int GetTop(){return m_top;}
    protected final int GetRight(){return m_right;}
    protected final int GetBottom(){return m_bottom;}
    protected final int GetWidth(){return m_right - m_left;}
    protected final int GetHeight() {return m_bottom - m_top;}
    protected final float GetPDFX(int vx)
    {
        return (vx - ((m_right + m_left - m_pw) >> 1)) / m_scale;
    }
    protected final float GetPDFY(int vy)
    {
        return (((m_bottom + m_top + m_ph) >> 1) - vy) / m_scale;
    }
    /**
     * map x position in view to PDF coordinate
     * @param x x position in view
     * @param scrollx x scroll position
     * @return
     */
    public final float ToPDFX( float x, float scrollx )
    {
        if(m_curl) return GetPDFY((int)x);
        return (x + scrollx - m_left) / m_scale;
    }
    /**
     * map y position in view to PDF coordinate
     * @param y y position in view
     * @param scrolly y scroll position
     * @return
     */
    public final float ToPDFY( float y, float scrolly )
    {
        if(m_curl) return GetPDFY((int)y);
        return (m_bottom - y - scrolly) / m_scale;
    }
    /**
     * map x to DIB coordinate
     * @param x x position in PDF coordinate
     * @return
     */
    public final float ToDIBX( float x ) {return x * m_scale;}
    /**
     * map y to DIB coordinate
     * @param y y position in PDF coordinate
     * @return
     */
    public final float ToDIBY( float y ) {return m_ph - y * m_scale;}
    public final int GetVX(float pdfx)
    {
        return ((m_right + m_left - m_pw) >> 1)  + (int)(pdfx * m_scale);
    }
    public final int GetVY(float pdfy)
    {
        return ((m_bottom + m_top + m_ph) >> 1)  - (int)(pdfy * m_scale);
    }
    public final float GetScale() {return m_scale;}
    public final float ToPDFSize( float val ) { return val / m_scale; }
    public final Matrix CreateInvertMatrix(float scrollx, float scrolly )
    {
        if(m_curl)
        {
            Matrix mat = new Matrix(m_scale, -m_scale, (m_right + m_left - m_pw) >> 1, (m_bottom + m_top + m_ph) >> 1);
            mat.Invert();
            return mat;
        }
        Matrix mat = new Matrix(m_scale, -m_scale, m_left - scrollx, m_bottom - scrolly);
        mat.Invert();
        return mat;
    }
    public GLReflowCanvas Reflow(int w, float scale, int gap)
    {
        return new GLReflowCanvas(m_doc, m_pageno, scale, w, GLBlock.m_cell_size, gap);
    }
    static private int size_limit = 0;
    public Bitmap Reflow(int w, float scale, boolean render_images)
    {
        if(size_limit <= 0) size_limit = GLBlock.m_cell_size * GLBlock.m_cell_size * 4;
        Page page = m_doc.GetPage(m_pageno);
        int height = (int)page.ReflowStart(w, scale, render_images);
        if( w * height > size_limit )
            height = size_limit / w;
        if( w * height <= 0 ) return null;
        Bitmap bmp = Bitmap.createBitmap( w, height, Bitmap.Config.ARGB_8888 );
        bmp.eraseColor(0xFFFFFFFF);
        page.ReflowToBmp(bmp, 0, 0);
        page.Close();
        return bmp;
    }
    public boolean vFinished()
    {
        if (m_blks == null) return true;
        for (GLBlock blk : m_blks) {
            if (blk != null && blk.is_rendering()) return false;
        }
        return true;
    }
}
