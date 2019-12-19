package com.radaee.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.opengl.GLUtils;
import android.util.Log;

import com.radaee.pdf.BMP;
import com.radaee.pdf.Page;

import javax.microedition.khronos.opengles.GL10;

public class GLLayoutReflow extends GLLayout
{
    private int m_cur_page;
    private Bitmap m_bmp;
    private int m_text_cur;
    public GLLayoutReflow(Context context) {
        super(context);
    }

    @Override
    public int vGetPage(int vx, int vy) {
        return m_cur_page;
    }

    protected BMP m_draw_bmp = new BMP();
    @Override
    public void gl_layout(float scale, boolean zoom) {
        if( m_doc == null || m_vw <= m_page_gap || m_vh <= m_page_gap ) return;
        m_scale_min = ((m_vw - m_page_gap) << 1) / m_doc.GetPageWidth(m_cur_page);

        m_scale = scale;
        //to avoid page not rendered completely when zoomed,
        // get the height using the passed scale and check if it exceeds the max size limit
       /* Page page = m_doc.GetPage(m_cur_page);
        int size_limit = GLBlock.m_cell_size * GLBlock.m_cell_size * 4;
        int height = (int)page.ReflowStart(m_vw - m_page_gap, scale, true);
        if((m_vw - m_page_gap) * height <= size_limit)  //acceptable scale
            m_scale = scale;
        else
            Log.d(GLLayoutReflow.class.getSimpleName(), "Max zoom reached");*/
        if( m_scale < m_scale_min ) m_scale = m_scale_min;

        BUTTON_SIZE = m_vw >> 3;
        Bitmap bmp = m_pages[m_cur_page].Reflow(m_vw - m_page_gap, m_scale, true);
        if( bmp != null )
        {
            m_layw = bmp.getWidth() + m_page_gap;
            m_layh = bmp.getHeight() + m_page_gap;
            m_bmp = bmp;
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
        gl_flush_range(gl10);
        int vx = vGetX();
        int vy = vGetY();
        if(m_bmp != null)
        {
            if(m_text_cur != 0) gl10.glDeleteTextures(1, new int[]{m_text_cur}, 0);
            int textures[] = new int[1];
            gl10.glGenTextures(1, textures, 0);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, textures[0]);
            gl10.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MIN_FILTER, GL10.GL_NEAREST);
            gl10.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MAG_FILTER, GL10.GL_LINEAR);
            GLUtils.texImage2D(GL10.GL_TEXTURE_2D, 0, m_bmp, 0);
            m_text_cur = textures[0];
            m_bmp.recycle();
            m_bmp = null;
        }
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, m_text_cur);//bind texture
        int text[] = new int[8];
        int vect[] = new int[8];
        int gap_half = m_page_gap >> 1;
        vect[0] = gap_half << 16;//left
        vect[1] = (gap_half - vy) << 16;//yop
        vect[2] = (m_vw - gap_half) << 16;//right
        vect[3] = (gap_half - vy) << 16;//top
        vect[4] = gap_half << 16;//left
        vect[5] = (m_layh - gap_half - vy) << 16;//bottom
        vect[6] = (m_vw - gap_half) << 16;//right
        vect[7] = (m_layh - gap_half - vy) << 16;//bottom

        text[0] = 0;
        text[1] = 0;
        text[2] = 1 << 16;
        text[3] = 0;
        text[4] = 0;
        text[5] = 1 << 16;
        text[6] = 1 << 16;
        text[7] = 1 << 16;

        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, GLBlock.create_buf(vect));
        gl10.glTexCoordPointer(2, GL10.GL_FIXED, 0, GLBlock.create_buf(text));
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 4);//draw out
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture

        gl10.glColor4f(0.5f, 0.5f, 0.5f, 1);
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
        if(m_text_cur != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_text_cur}, 0);
            m_text_cur = 0;
        }
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
    @Override
    public void gl_surface_create(GL10 gl10)
    {
        super.gl_surface_create(gl10);
        gl_layout(2, false);
    }
    @Override
    public void gl_surface_destroy(GL10 gl10)
    {
        super.gl_surface_destroy(gl10);
        if(m_text_cur != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_text_cur}, 0);
            m_text_cur = 0;
        }
    }
}