package com.radaee.view;

import com.radaee.pdf.DIB;
import com.radaee.pdf.Page;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;

import javax.microedition.khronos.opengles.GL10;

public class GLReflowBlock {
    private DIB m_dib;
    private Page m_page;
    private int m_y;
    private int m_w;
    private int m_h;
    private int m_gap;
    private int m_status;

    public GLReflowBlock(Page page, int y, int w, int h, int gap) {
        m_page = page;
        m_y = y;
        m_w = w;
        m_h = h;
        m_gap = gap;
        m_status = 0;
    }

    public boolean render_cancel() {
        if (m_status == 1) {
			m_page.RenderCancel();
            m_status = -1;
            return true;
        } else return false;
    }

    public boolean render_start() {
        if(m_status == 0)
        {
            m_status = 1;
            return true;
        }
        return false;
    }

    public boolean render() {
        if (m_status < 0) return false;
        DIB dib = new DIB();
        dib.CreateOrResize(m_w, m_h);
        dib.DrawRect(-1, 0, 0, m_w, m_h, 0);
        m_page.Reflow(dib, (m_gap >> 1), (m_gap >> 1) - m_y);
        if(m_status < 0)
        {
            dib.Free();
            return false;
        }
        m_dib = dib;
        m_status = 2;
        return true;
    }

    public void destroy() {

        if (m_dib != null) {
            DIB dib = m_dib;
            m_dib = null;
            dib.Free();
        }
		m_status = 0;
    }

    public boolean gl_in_range(int y, int h) {
        return (y < m_y + m_h && y + h > m_y);
    }

    static protected IntBuffer create_buf(int[] val) {
        if (val == null) return null;
        ByteBuffer buffer = ByteBuffer.allocateDirect(val.length << 2);
        buffer.order(ByteOrder.nativeOrder());
        IntBuffer ibuf = buffer.asIntBuffer();
        ibuf.put(val);
        ibuf.position(0);
        return ibuf;
    }

    static protected ByteBuffer create_buf(byte[] val) {
        if (val == null) return null;
        ByteBuffer buffer = ByteBuffer.allocateDirect(val.length);
        buffer.put(val);
        buffer.position(0);
        return buffer;
    }

    static private IntBuffer m_text = create_buf(new int[]{0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16});
    private IntBuffer m_vect = create_buf(new int[]{0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16});
    ;
    private int m_texture = 0;

    public void gl_draw(GL10 gl10, int def_text, int vy, int vh) {
        int texture = m_texture;
        if (texture == 0 && m_dib != null) {
            DIB dib = m_dib;
            m_texture = dib.GLGenTexture();
        }
        if (texture <= 0) texture = def_text;
        int left = 0;
        int right = m_w;
        int top = m_y - vy;
        int bottom = top + m_h;

        m_vect.position(0);
        m_vect.put(left << 16);
        m_vect.put(top << 16);
        m_vect.put(right << 16);
        m_vect.put(top << 16);
        m_vect.put(left << 16);
        m_vect.put(bottom << 16);
        m_vect.put(right << 16);
        m_vect.put(bottom << 16);
        m_vect.position(0);
        gl10.glTexCoordPointer(2, GL10.GL_FIXED, 0, m_text);
        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, m_vect);

        gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 4);//draw out
        //Log.e("GLBlock", "gl_draw with glDrawElements 0");
        //gl10.glDrawElements(GL10.GL_TRIANGLE_STRIP, 4, GL10.GL_UNSIGNED_BYTE, create_buf(new byte[]{0, 1, 2, 3}));
        //Log.e("GLBlock", "gl_draw with glDrawElements 1");
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);
    }

    public void gl_close(GL10 gl10) {
        if (m_texture != 0) gl10.glDeleteTextures(1, new int[]{m_texture}, 0);
        m_texture = 0;
    }
}
