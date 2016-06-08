package com.radaee.view;

import android.util.Log;

import com.radaee.pdf.DIB;
import com.radaee.pdf.Document;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;

import javax.microedition.khronos.opengles.GL10;

public class GLBlock {
    private static final int m_shadow_factor = 4;
    private static final int m_shadow_base = 100;
    private final int m_x;
    private final int m_y;
    private final int m_w;
    private final int m_h;
    private final int m_ph;
    private final float m_scale;
    private DIB m_dib;
    private DIB m_dib_tmp;
    private final Document m_doc;
    private final int m_pageno;
    private Page m_page;
    private int m_texture;
    private int m_status;
    public static int m_cell_size = 0;
    static protected IntBuffer create_buf(int[] val)
    {
        if(val == null) return null;
        ByteBuffer buffer = ByteBuffer.allocateDirect(val.length << 2);
        buffer.order(ByteOrder.nativeOrder());
        IntBuffer ibuf = buffer.asIntBuffer();
        ibuf.put(val);
        ibuf.position(0);
        return ibuf;
    }
    static protected ByteBuffer create_buf(byte[] val)
    {
        if(val == null) return null;
        ByteBuffer buffer = ByteBuffer.allocateDirect(val.length);
        buffer.put(val);
        buffer.position(0);
        return buffer;
    }
    static private final IntBuffer m_text = create_buf(new int[]{0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16});
    private final IntBuffer m_vect;
    protected GLBlock(GLBlock src, Document doc)
    {
        m_doc = doc;
        m_pageno = src.m_pageno;
        m_scale = src.m_scale;
        m_x = src.m_x;
        m_y = src.m_y;
        m_w = src.m_w;
        m_h = src.m_h;
        m_ph = src.m_ph;
        m_vect = create_buf(new int[]{0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16});
        m_page = null;
        m_dib = null;
        m_texture = 0;
        m_status = 0;
    }
    protected GLBlock(Document doc, int pageno, float scale, int x, int y, int w, int h, int ph)
    {
        m_doc = doc;
        m_pageno = pageno;
        m_scale = scale;
        m_x = x;
        m_y = y;
        m_w = w;
        m_h = h;
        m_ph = ph;
        m_vect = create_buf(new int[]{0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16});
        m_page = null;
        m_dib = null;
        m_texture = 0;
        m_status = 0;
    }
    protected final boolean has_render()
    {
        return (m_status > 0);
    }
    protected final boolean is_rendering()
    {
        return (m_status == 1);
    }
    protected final void bk_render()
    {
        if(m_status != 1) return;

        m_page = m_doc.GetPage(m_pageno);
        DIB dib = new DIB();
        dib.CreateOrResize(m_w, m_h);
        m_page.RenderPrepare(dib);
        m_dib_tmp = dib;
        if(m_status != 1) return;

        int sw = (int)(m_doc.GetPageWidth(m_pageno) * m_scale);
        int sh = (int)(m_doc.GetPageHeight(m_pageno) * m_scale);
        if(sw <= m_w && sh <= m_h)
        {
            Matrix mat = new Matrix(m_scale, -m_scale, (m_w - sw) >> 1, (m_h + sh) >> 1);
            m_page.Render(dib, mat);
            mat.Destroy();
        }
        else
        {
            Matrix mat = new Matrix(m_scale, -m_scale, -m_x, m_ph - m_y);
            m_page.Render(dib, mat);
            mat.Destroy();
        }
        m_dib_tmp = null;
        if(m_status == 1)
        {
            m_dib = dib;
            m_status = 2;
        }
        else
            dib.Free();
    }
    protected final void bk_destroy()
    {
        if(m_page != null) { m_page.Close(); m_page = null; }
        DIB dib = m_dib;
        if(dib != null)
        {
            m_dib = null;
            dib.Free();
        }
        m_status = 0;
    }
    protected final boolean gl_start()
    {
        if(m_status != 0) return false;
        m_status = 1;
        return true;
    }
    protected final boolean gl_end(GL10 gl10)
    {
        if(m_status == 0 || m_status == -1) return false;
        if(m_status == 1 && m_page != null) m_page.RenderCancel();
        m_status = -1;
        if(m_texture != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_texture}, 0);
            m_texture = 0;
        }
        if(m_texture_tmp != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_texture_tmp}, 0);
            m_texture_tmp = 0;
        }
        return true;
    }
    private int m_draw_cnt;
    private int m_texture_tmp;
    protected final void gl_draw(GL10 gl10, int def_text, int left, int top, int right, int bottom)
    {
        int texture = m_texture;
        m_draw_cnt++;
        if(texture == 0)
        {
            DIB dib = m_dib_tmp;
            if(dib != null && (m_draw_cnt&7) == 0)
            {
                if(m_texture_tmp != 0)
                    gl10.glDeleteTextures(1, new int[]{m_texture_tmp}, 0);
                m_texture_tmp = dib.GLGenTexture();
            }
            texture = m_texture_tmp;
            if(texture == 0 && def_text >= 0) texture = def_text;
        }
        else if(m_texture_tmp != 0)
        {
            gl10.glDeleteTextures(1, new int[]{m_texture_tmp}, 0);
            m_texture_tmp = 0;
        }
        if(texture < 0) return;
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
    public static void drawQuadColor(GL10 gl10, int text_white, int vx00, int vy00, int vx10, int vy10, int vx01, int vy01, int vx11, int vy11, float r, float g, float b)
    {
        int[] vect = new int[8];
        vect[0] = vx00;
        vect[1] = vy00;
        vect[2] = vx10;
        vect[3] = vy10;
        vect[4] = vx01;
        vect[5] = vy01;
        vect[6] = vx11;
        vect[7] = vy11;
        gl10.glTexCoordPointer(2, GL10.GL_FIXED, 0, m_text);
        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, create_buf(vect));

        gl10.glColor4f(r, g, b, 1);
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_white);
        //Log.e("GLBlock", "drawQuadColor with glDrawElements 0");
        //gl10.glDrawElements(GL10.GL_TRIANGLE_STRIP, 4, GL10.GL_UNSIGNED_BYTE, create_buf(new byte[]{0, 1, 2, 3}));
        //Log.e("GLBlock", "drawQuadColor with glDrawElements 1");
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 4);//draw out
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);
    }
    public static void drawQuadFixed(GL10 gl10, int vx00, int vy00, int vx10, int vy10, int vx01, int vy01, int vx11, int vy11, int tx00, int ty00, int tx10, int ty10, int tx01, int ty01, int tx11, int ty11)
    {
        int[] text = new int[8];
        int[] vect = new int[8];
        vect[0] = vx00;
        vect[1] = vy00;
        vect[2] = vx10;
        vect[3] = vy10;
        vect[4] = vx01;
        vect[5] = vy01;
        vect[6] = vx11;
        vect[7] = vy11;

        text[0] = tx00;
        text[1] = ty00;
        text[2] = tx10;
        text[3] = ty10;
        text[4] = tx01;
        text[5] = ty01;
        text[6] = tx11;
        text[7] = ty11;

        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, create_buf(vect));
        gl10.glTexCoordPointer(2, GL10.GL_FIXED, 0, create_buf(text));
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 4);//draw out
    }
    private void drawQuad(GL10 gl10, int x00, int y00, int x10, int y10, int x01, int y01, int x11, int y11)
    {
        int[] text = new int[8];
        int[] vect = new int[8];
        vect[0] = x00 << 16;
        vect[1] = y00 << 16;
        vect[2] = x10 << 16;
        vect[3] = y10 << 16;
        vect[4] = x01 << 16;
        vect[5] = y01 << 16;
        vect[6] = x11 << 16;
        vect[7] = y11 << 16;

        text[0] = vect[0] / m_w;
        text[1] = vect[1] / m_h;
        text[2] = vect[2] / m_w;
        text[3] = vect[3] / m_h;
        text[4] = vect[4] / m_w;
        text[5] = vect[5] / m_h;
        text[6] = vect[6] / m_w;
        text[7] = vect[7] / m_h;

        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, create_buf(vect));
        gl10.glTexCoordPointer(2, GL10.GL_FIXED, 0, create_buf(text));
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 4);//draw out
    }
    private void drawTrangle(GL10 gl10, int x00, int y00, int x10, int y10, int x01, int y01)
    {
        int[] text = new int[6];
        int[] vect = new int[6];
        vect[0] = x00 << 16;
        vect[1] = y00 << 16;
        vect[2] = x10 << 16;
        vect[3] = y10 << 16;
        vect[4] = x01 << 16;
        vect[5] = y01 << 16;

        text[0] = vect[0] / m_w;
        text[1] = vect[1] / m_h;
        text[2] = vect[2] / m_w;
        text[3] = vect[3] / m_h;
        text[4] = vect[4] / m_w;
        text[5] = vect[5] / m_h;

        gl10.glVertexPointer(2, GL10.GL_FIXED, 0, create_buf(vect));
        gl10.glTexCoordPointer(2, GL10.GL_FIXED, 0, create_buf(text));
        gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 3);//draw out
    }
    static private int flate_bezier2(int x1, int y1, int x2, int y2, int x3, int y3, int dep, int[] out, int out_pos)
    {
        if(dep < 1)
        {
            out[out_pos] = x3;
            out[out_pos + 1] = y3;
            return out_pos + 2;
        }
        int midx = (x1 + (x2 << 1) + x3) >> 2;
        int midy = (y1 + (y2 << 1) + y3) >> 2;
        if(dep < 2)
        {
            out[out_pos] = midx;
            out[out_pos + 1] = midy;
            out[out_pos + 2] = x3;
            out[out_pos + 3] = y3;
            return out_pos + 4;
        }
        else
        {
            out_pos = flate_bezier2(x1, y1, (x1 + x2) >> 1, (y1 + y2) >> 1, midx, midy, dep - 1, out, out_pos);
            return flate_bezier2(midx, midy, (x2 + x3) >> 1, (y2 + y3) >> 1, x3, y3, dep - 1, out, out_pos);
        }
    }
    private void drawLT(GL10 gl10, int texture, int x, int y, int text_shadow, int text_white)
    {
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture
        float sr = 0.5f;
        float sg = 0.5f;
        float sb = 0.4f;
        float er = sg * 2;
        float eg = sr * 2;
        float eb = sb * 2;

        int midx = (m_w + x)>>1;
        int midy = (0 + y)>>1;
        int c2x = (midx + x)>>1;
        int c2y = (midy + y)>>1;
        //int c1x = (midx + c2x)>>1;
        //int c1y = (midy + c2y)>>1;

        double a = (y <= 0) ? -100000 : (double)(m_w - x)/(0 - y);
        double b = (midy - 0) - a * (m_w - midx);
        double b2 = (c2y - 0) - a * (m_w - c2x);

        int ctrl1x = m_w;
        int ctrl1y = (int)(0 + b);
        int ctrl2x = (int)(b/a) + m_w;
        int ctrl2y = 0;
        int p11x = m_w;
        int p11y = (int)(0 + b2);
        int p22x = (int)(b2/a) + m_w;
        int p22y = 0;

        int p12x = (ctrl1x + x)>>1;
        int p12y = (ctrl1y + y)>>1;
        int p21x = (ctrl2x + x)>>1;
        int p21y = (ctrl2y + y)>>1;

        int corner1x = (p11x + p12x + (ctrl1x << 1))>>2;
        int corner1y = (p11y + p12y + (ctrl1y << 1))>>2;
        int corner2x = (p21x + p22x + (ctrl2x << 1))>>2;
        int corner2y = (p21y + p22y + (ctrl2y << 1))>>2;

        if(a < -99999 || p11y > 30000 + m_w)//vertical
        {
            drawQuad(gl10, 0, 0, x, 0, 0, m_h, x, m_h);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int remain = (m_w - x) * 3 / 8;
            int right = x + (remain * 2 / 3);
            drawQuadFixed(gl10, right << 16, 0, right << 16, m_h << 16,
                    (x + remain * 4 / 3) << 16, 0, (x + remain * 4 / 3) << 16, m_h << 16,
                    0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
            drawQuadColor(gl10, text_white,x << 16, 0, right << 16, 0,
                    x << 16, m_h << 16, right << 16, m_h << 16, er, eg, eb);
            int shadow = remain / 3;
            for(int pos = 0; pos < 32; pos++)
            {
                drawQuadColor(gl10, text_white, (right + shadow * pos / 32) << 16, 0, (right + shadow * (pos + 1) / 32) << 16, 0,
                        (right + shadow * pos / 32) << 16, m_h << 16, (right + shadow * (pos + 1) / 32) << 16, m_h << 16,
                        (sr * pos + er * (32 - pos)) / 32, (sg * pos + eg * (32 - pos)) / 32, (sb * pos + eb * (32 - pos)) / 32);
            }
            gl10.glColor4f(1, 1, 1, 1);

            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int left = m_w - (m_w - x) * (m_shadow_factor + m_shadow_base) / m_shadow_base;
            drawQuadFixed(gl10, x << 16, 0, x << 16, m_h << 16,
                    left << 16, 0, left << 16, m_h << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
        }
        else if(x == m_w || p22x < -30000)//horizon
        {
            drawQuad(gl10, 0, y, m_w, y, 0, m_h, m_w, m_h);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int remain = y * 3 / 8;
            int bot = y - remain;
            drawQuadFixed(gl10, 0, (bot + (y >> 3)) << 16, m_w << 16, (bot + (y >> 3)) << 16,
                    0, (bot - (y >> 3)) << 16, m_w << 16, (bot - (y >> 3)) << 16,
                    0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
            drawQuadColor(gl10, text_white,0, y << 16, m_w << 16, y << 16,
                    0, bot << 16, m_w << 16, bot << 16, er, eg, eb);
            int shadow = remain / 3;
            for(int pos = 0; pos < 32; pos++)
            {
                drawQuadColor(gl10, text_white,0, (bot + shadow * pos / 32) << 16, m_w << 16, (bot + shadow * pos / 32) << 16,
                        0, (bot + shadow * (pos + 1) / 32) << 16, m_w << 16, (bot + shadow * (pos + 1) / 32) << 16,
                        (sr * (32 - pos) + er * pos) / 32, (sg * (32 - pos) + eg * pos) / 32, (sb * (32 - pos) + eb * pos) / 32);
            }
            gl10.glColor4f(1, 1, 1, 1);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int sbot = y * (m_shadow_factor + m_shadow_base) / m_shadow_base;
            drawQuadFixed(gl10, 0 << 16, y << 16, m_w << 16, y << 16,
                    0 << 16, sbot << 16, m_w << 16, sbot << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
        }
        else
        {
            int dy = ( m_w - x );
            int dx = ( y - 0 );
            if( dx > dy )
            {
                dx = (dx * 3) / (dy * 2);
                dy = (int)1.5f;
            }
            else
            {
                dy = (dy * 3) / (dx * 2);
                dx = (int)1.5f;
            }

            int p3x = (p11x + ctrl1x)>>1;
            int p3y = (p11y + ctrl1y)>>1;
            int p4x = (p22x + ctrl2x)>>1;
            int p4y = (p22y + ctrl2y)>>1;
            if (p11y > m_h && p22x < 0)
            {
            }
            else if (p11y > m_h)//左侧梯形
            {
                drawQuad(gl10, 0, 0, p22x, p22y, 0, m_h, (int) (m_w - ((m_h - p11y) / a)), m_h);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
                drawQuadFixed(gl10, p22x << 16, p22y << 16, p11x << 16, p11y << 16,
                        ctrl2x << 16, ctrl2y << 16, ctrl1x << 16, ctrl1y << 16,
                        0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture
                //再开始画折角圆筒下半层
                double cur11 = m_w + ((p11y - m_h) / a);
                double cur22 = p22x;
                double step = (m_w - p22x) / 80;
                int ddx = (int) cur11 - p22x;
                int ddy = m_h;

                //path.lineTo((corner2x - dx), corner2y);
                //path.quadTo(p4x, p4y, p22x, p22y);//left top
                int[] b22 = new int[64 + 2];
                b22[0] = p22x;
                b22[1] = p22y;
                flate_bezier2(b22[0], b22[1], p4x, p4y, (corner2x - dx), corner2y, 5, b22, 2);

                int[] b11 = new int[64 + 2];
                b11[0] = (int) cur11;
                b11[1] = m_h;
                flate_bezier2(b11[0], b11[1], (p4x + ddx), (p4y + ddy), ((corner2x - dx) + ddx), (corner2y + ddy), 5, b11, 2);

                //path.lineTo(p11x, p11y);
                //path.quadTo(p3x, p3y, corner1x, (corner1y + dy));//right-bottom
                int[] b110 = new int[64 + 2];
                b110[0] = p11x;
                b110[1] = p11y;
                flate_bezier2(b110[0], b110[1], p3x, p3y, corner1x, (corner1y - dy), 5, b110, 2);

                for (int pos = 0; pos < 64; pos += 2)//画四边形条目
                {
                    if (b110[pos + 1] > m_h) {
                        drawQuadFixed(gl10,
                                b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                                b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                                (int) (cur11 * 65536) / m_w, 1 << 16, (int) ((cur11 + step) * 65536) / m_w, 1 << 16,
                                (int) (cur22 * 65536) / m_w, 0, (int) ((cur22 + step) * 65536) / m_w, 0);
                    } else {
                        drawQuadFixed(gl10,
                                b110[pos] << 16, b110[pos + 1] << 16, b110[pos + 2] << 16, b110[pos + 3] << 16,
                                b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                                1 << 16,
                                (int) ((b110[pos + 1] - b22[pos + 1]) << 16) / ddy,
                                1 << 16,
                                (int) ((b110[pos + 3] - b22[pos + 3]) << 16) / ddy,
                                (int) ((cur22 * 65536) / m_w), 0,
                                (int) (((cur22 + step) * 65536) / m_w), 0);
                    }
                    cur11 += step;
                    cur22 += step;
                }
            }
            else if (p22x < 0)//下侧梯形
            {
                drawQuad(gl10, 0, (int) (p22x * a), p11x, p11y, 0, m_h, m_w, m_h);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
                drawQuadFixed(gl10, p22x << 16, p22y << 16, p11x << 16, p11y << 16,
                        ctrl2x << 16, ctrl2y << 16, ctrl1x << 16, ctrl1y << 16,
                        0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture

                double cur11 = p11y;
                double cur22 = (p22x * a);
                double step = p11y / 80;
                int ddx = -p11x;
                int ddy = (int) (cur22 - cur11);

                int[] b220 = new int[64 + 2];
                b220[0] = 0;
                b220[1] = (int) cur22;
                flate_bezier2(b220[0], b220[1], p3x + ddx, p3y + ddy, corner1x + ddx, (corner1y - dy) + ddy, 5, b220, 2);

                int[] b22 = new int[64 + 2];
                b22[0] = p22x;
                b22[1] = p22y;
                flate_bezier2(b22[0], b22[1], p4x, p4y, (corner2x - dx), corner2y, 5, b22, 2);

                int[] b11 = new int[64 + 2];
                b11[0] = p11x;
                b11[1] = p11y;
                flate_bezier2(b11[0], b11[1], p3x, p3y, corner1x, (corner1y - dy), 5, b11, 2);

                for (int pos = 0; pos < 64; pos += 2)//画四边形条目
                {
                    if (b22[pos] < b220[pos]) {
                        drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                                b220[pos] << 16, b220[pos + 1] << 16, b220[pos + 2] << 16, b220[pos + 3] << 16,
                                1 << 16, (int) (cur11 * 65536) / m_h,
                                1 << 16, (int) ((cur11 - step) * 65536) / m_h,
                                0, (int) (cur22 * 65536) / m_h,
                                0, (int) ((cur22 - step) * 65536) / m_h);
                    } else {
                        drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                                b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                                1 << 16, (int) (cur11 * 65536) / m_h,
                                1 << 16, (int) ((cur11 - step) * 65536) / m_h,
                                ((b220[pos] - b22[pos]) << 16) / ddx, (int) (cur22 * 65536) / m_h,
                                ((b220[pos + 2] - b22[pos + 2]) << 16) / ddx, (int) ((cur22 - step) * 65536) / m_h);
                    }
                    cur11 -= step;
                    cur22 -= step;
                }
            }
            else//去除尖角部分
            {
                drawTrangle(gl10, 0, 0, 0, m_h, m_w, m_h);
                drawQuad(gl10, 0, 0, p22x, p22y, m_w, m_h, p11x, p11y);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
                drawQuadFixed(gl10, p22x << 16, p22y << 16, p11x << 16, p11y << 16,
                        ctrl2x << 16, ctrl2y << 16, ctrl1x << 16, ctrl1y << 16,
                        0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture

                //再开始画折角圆筒下半层
                double cur11 = m_w + ((p11y - m_h) / a);
                double cur22 = p22x;
                double step = (m_w - p22x) / 80;
                int ddx = (int) cur11 - p22x;
                int ddy = m_h;

                //path.lineTo((corner2x - dx), corner2y);
                //path.quadTo(p4x, p4y, p22x, p22y);//left top
                int[] b22 = new int[64 + 2];
                b22[0] = p22x;
                b22[1] = p22y;
                flate_bezier2(b22[0], b22[1], p4x, p4y, (corner2x - dx), corner2y, 5, b22, 2);

                int[] b11 = new int[64 + 2];
                b11[0] = (int) cur11;
                b11[1] = m_h;
                flate_bezier2(b11[0], b11[1], (p4x + ddx), (p4y + ddy), ((corner2x - dx) + ddx), (corner2y + ddy), 5, b11, 2);

                //path.lineTo(p11x, p11y);
                //path.quadTo(p3x, p3y, corner1x, (corner1y + dy));//right-bottom
                int[] b110 = new int[64 + 2];
                b110[0] = p11x;
                b110[1] = p11y;
                flate_bezier2(b110[0], b110[1], p3x, p3y, corner1x, (corner1y - dy), 5, b110, 2);

                for (int pos = 0; pos < 64; pos += 2)//画四边形条目
                {
                    drawQuadFixed(gl10,
                            b110[pos] << 16, b110[pos + 1] << 16, b110[pos + 2] << 16, b110[pos + 3] << 16,
                            b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                            1 << 16,
                            (int) ((b110[pos + 1] - b22[pos + 1]) << 16) / ddy,
                            1 << 16,
                            (int) ((b110[pos + 3] - b22[pos + 3]) << 16) / ddy,
                            (int) ((cur22 * 65536) / m_w), 0,
                            (int) (((cur22 + step) * 65536) / m_w), 0);
                    cur11 += step;
                    cur22 += step;
                }
            }
            int p5x = (p12x + ctrl1x) >> 1;//右上
            int p5y = (p12y + ctrl1y) >> 1;
            int p6x = (p21x + ctrl2x) >> 1;//左下
            int p6y = (p21y + ctrl2y) >> 1;

            int[] b22 = new int[64 + 2];
            b22[0] = corner2x;
            b22[1] = corner2y;
            flate_bezier2(b22[0], b22[1], p6x, p6y, p21x, p21y, 5, b22, 2);
            int[] b11 = new int[64 + 2];
            b11[0] = corner1x;
            b11[1] = corner1y;
            flate_bezier2(b11[0], b11[1], p5x, p5y, p12x, p12y, 5, b11, 2);
            for (int pos = 0; pos < 64; pos += 2)//画四边形条目
            {
                float cr = (sr * (64 - pos) + er * pos) / 64;
                float cg = (sg * (64 - pos) + eg * pos) / 64;
                float cb = (sb * (64 - pos) + eb * pos) / 64;
                drawQuadColor(gl10, text_white,b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                        b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16, cr, cg, cb);
            }
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_white);//bind texture
            gl10.glColor4f(er, eg, eb, 1);
            int vect[] = new int[6];
            vect[0] = (p12x << 16);
            vect[1] = (p12y << 16);
            vect[2] = x << 16;
            vect[3] = y << 16;
            vect[4] = (p21x << 16);
            vect[5] = (p21y << 16);
            gl10.glVertexPointer(2, GL10.GL_FIXED, 0, create_buf(vect));
            gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 3);//draw  out
            gl10.glColor4f(1, 1, 1, 1);

            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int shx = m_w - (m_w - x) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int shy = y * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b12x = m_w - (m_w - p12x) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b12y = p12y * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b21x = m_w - (m_w - p21x) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b21y = p21y * (m_shadow_base + m_shadow_factor) / m_shadow_base;

            int b5x = m_w - (m_w - p5x) * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;
            int b5y = p5y * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;
            int b6x = m_w - (m_w - p6x) * (100 + (m_shadow_factor >> 1)) / m_shadow_base;
            int b6y = p6y * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;

            int[] bb22 = new int[64 + 2];
            bb22[0] = corner2x;
            bb22[1] = corner2y;
            flate_bezier2(bb22[0], bb22[1], b6x, b6y, b21x, b21y, 5, bb22, 2);
            int[] bb11 = new int[64 + 2];
            bb11[0] = corner1x;
            bb11[1] = corner1y;
            flate_bezier2(bb11[0], bb11[1], b5x, b5y, b12x, b12y, 5, bb11, 2);
            drawQuadFixed(gl10, x << 16, y << 16, p21x << 16, p21y << 16,
                    shx << 16, shy << 16, b21x << 16, b21y << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            drawQuadFixed(gl10, x << 16, y << 16, p12x << 16, p12y << 16,
                    shx << 16, shy << 16, b12x << 16, b12y << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            for (int pos = 0; pos < 64; pos += 2)//画四边形条目
            {
                drawQuadFixed(gl10, b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                        bb22[pos] << 16, bb22[pos + 1] << 16, bb22[pos + 2] << 16, bb22[pos + 3] << 16,
                        0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
                drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                        bb11[pos] << 16, bb11[pos + 1] << 16, bb11[pos + 2] << 16, bb11[pos + 3] << 16,
                        0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            }
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
            gl10.glColor4f(1, 1, 1, 1);
        }
    }
    private void drawRB(GL10 gl10, int texture, int x, int y, int text_shadow, int text_white)
    {
        gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture
        float sr = 0.5f;
        float sg = 0.5f;
        float sb = 0.4f;
        float er = sg * 2;
        float eg = sr * 2;
        float eb = sb * 2;

        int midx = (m_w + x)>>1;
        int midy = (m_h + y)>>1;
        int c2x = (midx + x)>>1;//折角边缘点
        int c2y = (midy + y)>>1;//折角边缘点
        //int c1x = (midx + c2x)>>1;
        //int c1y = (midy + c2y)>>1;
        double a = (y >= m_h) ? 100000 : ((float)(m_w - x))/(m_h - y);
        double b = (m_h - midy) - a * midx;
        double b2 = (m_h - c2y) - a * c2x;

        int ctrl1x = m_w;//右上角控制点
        int ctrl1y = m_h - (int)(a * m_w + b);//右上角控制点
        int ctrl2x = (int)(-b/a);//左下角控制点
        int ctrl2y = m_h;//左下角控制点
        int p11x = m_w;//右上角
        int p11y = m_h - (int)(a * m_w + b2);//右上角
        int p22x = (int)(-b2/a);//左下角
        int p22y = m_h;//左下角

        if(a > 99999 || p11y < -30000)//vertical
        {
            drawQuad(gl10, 0, 0, x, 0, 0, m_h, x, y);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int remain = (m_w - x) * 3 / 8;
            int right = x + (remain * 2 / 3);
            drawQuadFixed(gl10, right << 16, 0, right << 16, m_h << 16,
                    (x + remain * 4 / 3) << 16, 0, (x + remain * 4 / 3) << 16, m_h << 16,
                    0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
            drawQuadColor(gl10, text_white,x << 16, 0, right << 16, 0,
                    x << 16, m_h << 16, right << 16, m_h << 16, er, eg, eb);
            int shadow = remain / 3;
            for(int pos = 0; pos < 32; pos++)
            {
                drawQuadColor(gl10, text_white,(right + shadow * pos / 32) << 16, 0, (right + shadow * (pos + 1) / 32) << 16, 0,
                        (right + shadow * pos / 32) << 16, m_h << 16, (right + shadow * (pos + 1) / 32) << 16, m_h << 16,
                        (sr * pos + er * (32 - pos)) / 32, (sg * pos + eg * (32 - pos)) / 32, (sb * pos + eb * (32 - pos)) / 32);
            }
            gl10.glColor4f(1, 1, 1, 1);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int left = m_w - (m_w - x) * (m_shadow_factor + m_shadow_base) / m_shadow_base;
            drawQuadFixed(gl10, x << 16, 0, x << 16, m_h << 16,
                    left << 16, 0, left << 16, m_h << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
        }
        else if(x == m_w || p22x < -30000)//horizon
        {
            drawQuad(gl10, 0, 0, m_w, 0, 0, y, m_w, y);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int remain = (m_h - y) * 3 / 8;
            int bot = y + (remain * 2 / 3);
            int bot1 = y + remain;
            int gap = (m_h - y) >> 3;
            drawQuadFixed(gl10, 0, (bot1 - gap) << 16, m_w << 16, (bot1 - gap) << 16,
                    0, (bot1 + gap) << 16, m_w << 16, (bot1 + gap) << 16,
                    0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
            drawQuadColor(gl10, text_white, 0, y << 16, m_w << 16, y << 16,
                    0, bot << 16, m_w << 16, bot << 16, er, eg, eb);
            int shadow = remain / 3;
            for(int pos = 0; pos < 32; pos++)
            {
                drawQuadColor(gl10, text_white,0, (bot + shadow * pos / 32) << 16, m_w << 16, (bot + shadow * pos / 32) << 16,
                        0, (bot + shadow * (pos + 1) / 32) << 16, m_w << 16, (bot + shadow * (pos + 1) / 32) << 16,
                        (sr * pos + er * (32 - pos)) / 32, (sg * pos + eg * (32 - pos)) / 32, (sb * pos + eb * (32 - pos)) / 32);
            }
            gl10.glColor4f(1, 1, 1, 1);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int top = m_h - (m_h - y) * (m_shadow_factor + m_shadow_base) / m_shadow_base;
            drawQuadFixed(gl10, 0 << 16, y << 16, m_w << 16, y << 16,
                    0 << 16, top << 16, m_w << 16, top << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
        }
        else
        {
            int p12x = (ctrl1x + x)>>1;
            int p12y = (ctrl1y + y)>>1;
            int p21x = (ctrl2x + x)>>1;
            int p21y = (ctrl2y + y)>>1;
            int corner1x = (p11x + p12x + (ctrl1x << 1))>>2;
            int corner1y = (p11y + p12y + (ctrl1y << 1))>>2;
            int corner2x = (p21x + p22x + (ctrl2x << 1))>>2;
            int corner2y = (p21y + p22y + (ctrl2y << 1))>>2;
            int p3x = (p11x + ctrl1x)>>1;
            int p3y = (p11y + ctrl1y)>>1;
            int p4x = (p22x + ctrl2x)>>1;
            int p4y = (p22y + ctrl2y)>>1;

            int dy = (m_w - x);
            int dx = (m_h - y);
            if( dx > dy )
            {
                dx = (dx * 3) / (dy * 2);
                dy = 1;//1.5f
            }
            else
            {
                dy = (dx * 3) / (dy * 2);
                dx = 1;//1.5f
            }
            if (p22x < 0 && p11y < 0)//只显示一个尖角
            {
                drawTrangle(gl10, 0, 0, m_w - (int) (p11x / a), 0, 0, m_h + (int) (a * p22x));
            }
            else if (p11y < 0)//左侧梯形
            {
                //先画梯形
                drawQuad(gl10, 0, 0, m_w + (int) (p11y / a), 0, 0, m_h, p22x, m_h);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
                drawQuadFixed(gl10, p22x << 16, p22y << 16, p11x << 16, p11y << 16,
                        ctrl2x << 16, ctrl2y << 16, ctrl1x << 16, ctrl1y << 16,
                        0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture

                //再开始画折角圆筒下半层
                double cur11 = m_w + (p11y / a);
                double cur22 = p22x;
                double step = (m_w - p22x) / 80;
                int ddx = (int) cur11 - p22x;
                int ddy = -p22y;

                int[] b22 = new int[64 + 2];
                b22[0] = p22x;
                b22[1] = p22y;
                flate_bezier2(b22[0], b22[1], p4x, p4y, (corner2x - dx), corner2y, 5, b22, 2);

                int[] b11 = new int[64 + 2];
                b11[0] = (int) cur11;
                b11[1] = 0;
                flate_bezier2(b11[0], b11[1], (p4x + ddx), (p4y + ddy), ((corner2x - dx) + ddx), (corner2y + ddy), 5, b11, 2);

                int[] b110 = new int[64 + 2];
                b110[0] = p11x;
                b110[1] = p11y;
                flate_bezier2(b110[0], b110[1], p3x, p3y, corner1x, (corner1y - dy), 5, b110, 2);

                for (int pos = 0; pos < 64; pos += 2)//画四边形条目
                {
                    if (b110[pos + 1] < 0) {
                        drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                                b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                                (int) (cur11 * 65536) / m_w, 0, (int) ((cur11 + step) * 65536) / m_w, 0,
                                (int) (cur22 * 65536) / m_w, 1 << 16, (int) ((cur22 + step) * 65536) / m_w, 1 << 16);
                    } else {
                        drawQuadFixed(gl10, b110[pos] << 16, b110[pos + 1] << 16, b110[pos + 2] << 16, b110[pos + 3] << 16,
                                b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                                (int) (((b110[pos] - b22[pos]) << 16) / ddx * cur11 + ((b11[pos] - b110[pos]) << 16) / ddx * cur22) / m_w,
                                (int) ((long) (b11[pos + 1] - b110[pos + 1]) << 16) / ddy,
                                (int) (((b110[pos + 2] - b22[pos + 2]) << 16) / ddx * (cur11 + step) + ((b11[pos + 2] - b110[pos + 2]) << 16) / ddx * (cur22 + step)) / m_w,
                                (int) ((long) (b11[pos + 3] - b110[pos + 3]) << 16) / ddy,
                                (int) ((cur22 * 65536) / m_w), 1 << 16,
                                (int) (((cur22 + step) * 65536) / m_w), 1 << 16);
                    }
                    cur11 += step;
                    cur22 += step;
                }
            }
            else if (p22x < 0)//上侧梯形
            {
                drawQuad(gl10, 0, 0, m_w, 0, p22x, p22y, p11x, p11y);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
                drawQuadFixed(gl10, p22x << 16, p22y << 16, p11x << 16, p11y << 16,
                        ctrl2x << 16, ctrl2y << 16, ctrl1x << 16, ctrl1y << 16,
                        0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture

                double cur11 = p11y;
                double cur22 = m_h + (p22x * a);
                double step = (m_h - p11y) / 80;
                int ddx = -p11x;
                int ddy = (int) (cur22 - cur11);

                int[] b220 = new int[64 + 2];
                b220[0] = 0;
                b220[1] = (int) cur22;
                flate_bezier2(b220[0], b220[1], p3x + ddx, p3y + ddy, corner1x + ddx, (corner1y - dy) + ddy, 5, b220, 2);

                int[] b22 = new int[64 + 2];
                b22[0] = p22x;
                b22[1] = p22y;
                flate_bezier2(b22[0], b22[1], p4x, p4y, (corner2x - dx), corner2y, 5, b22, 2);

                int[] b11 = new int[64 + 2];
                b11[0] = p11x;
                b11[1] = p11y;
                flate_bezier2(b11[0], b11[1], p3x, p3y, corner1x, (corner1y - dy), 5, b11, 2);

                for (int pos = 0; pos < 64; pos += 2)//画四边形条目
                {
                    if (b22[pos] < b220[pos]) {
                        drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                                b220[pos] << 16, b220[pos + 1] << 16, b220[pos + 2] << 16, b220[pos + 3] << 16,
                                1 << 16, (int) (cur11 * 65536) / m_h, 1 << 16, (int) ((cur11 + step) * 65536) / m_h,
                                0, (int) (cur22 * 65536) / m_h, 0, (int) ((cur22 + step) * 65536) / m_h);
                    } else {
                        drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                                b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                                1 << 16, (int) (cur11 * 65536) / m_h, 1 << 16, (int) ((cur11 + step) * 65536) / m_h,
                                ((b220[pos] - b22[pos]) << 16) / ddx, (int) (cur22 * 65536) / m_h,
                                ((b220[pos + 2] - b22[pos + 2]) << 16) / ddx, (int) ((cur22 + step) * 65536) / m_h);
                    }
                    cur11 += step;
                    cur22 += step;
                }
            }
            else//去除右下角的梯形
            {
                drawTrangle(gl10, 0, 0, m_w, 0, 0, m_h);
                drawQuad(gl10, m_w, 0, p11x, p11y, 0, m_h, p22x, p22y);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
                drawQuadFixed(gl10, p22x << 16, p22y << 16, p11x << 16, p11y << 16,
                        ctrl2x << 16, ctrl2y << 16, ctrl1x << 16, ctrl1y << 16,
                        0, 0, 1 << 16, 0, 0, 1 << 16, 1 << 16, 1 << 16);
                gl10.glBindTexture(GL10.GL_TEXTURE_2D, texture);//bind texture

                //再开始画折角圆筒下半层
                double cur11 = m_w + (p11y / a);
                double cur22 = p22x;
                double step = (m_w - p22x) / 80;
                int ddx = (int) cur11 - p22x;
                int ddy = -p22y;

                int[] b22 = new int[64 + 2];
                b22[0] = p22x;
                b22[1] = p22y;
                flate_bezier2(p22x, p22y, p4x, p4y, (corner2x - dx), corner2y, 5, b22, 2);

                int[] b11 = new int[64 + 2];
                b11[0] = (int) cur11;
                b11[1] = 0;
                flate_bezier2((int) cur11, 0, (p4x + ddx), (p4y + ddy), ((corner2x - dx) + ddx), (corner2y + ddy), 5, b11, 2);

                int[] b110 = new int[64 + 2];
                b110[0] = p11x;
                b110[1] = p11y;
                flate_bezier2(p11x, p11y, p3x, p3y, corner1x, (corner1y - dy), 5, b110, 2);

                for (int pos = 0; pos < 64; pos += 2)//画四边形条目
                {
                    drawQuadFixed(gl10, b110[pos] << 16, b110[pos + 1] << 16, b110[pos + 2] << 16, b110[pos + 3] << 16,
                            b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                            (int) (((b110[pos] - b22[pos]) << 16) / ddx * cur11 + ((b11[pos] - b110[pos]) << 16) / ddx * cur22) / m_w,
                            (int) ((long) (b11[pos + 1] - b110[pos + 1]) << 16) / ddy,
                            (int) (((b110[pos + 2] - b22[pos + 2]) << 16) / ddx * (cur11 + step) + ((b11[pos + 2] - b110[pos + 2]) << 16) / ddx * (cur22 + step)) / m_w,
                            (int) ((long) (b11[pos + 3] - b110[pos + 3]) << 16) / ddy,
                            (int) ((cur22 * 65536) / m_w), 1 << 16,
                            (int) (((cur22 + step) * 65536) / m_w), 1 << 16);
                    cur11 += step;
                    cur22 += step;
                }
            }

            int p5x = (p12x + ctrl1x) >> 1;//右上
            int p5y = (p12y + ctrl1y) >> 1;
            int p6x = (p21x + ctrl2x) >> 1;//左下
            int p6y = (p21y + ctrl2y) >> 1;

            int[] b22 = new int[64 + 2];
            b22[0] = corner2x;
            b22[1] = corner2y;
            flate_bezier2(b22[0], b22[1], p6x, p6y, p21x, p21y, 5, b22, 2);
            int[] b11 = new int[64 + 2];
            b11[0] = corner1x;
            b11[1] = corner1y;
            flate_bezier2(b11[0], b11[1], p5x, p5y, p12x, p12y, 5, b11, 2);
            for (int pos = 0; pos < 64; pos += 2)//画四边形条目
            {
                float cr = (sr * (64 - pos) + er * pos) / 64;
                float cg = (sg * (64 - pos) + eg * pos) / 64;
                float cb = (sb * (64 - pos) + eb * pos) / 64;
                drawQuadColor(gl10, text_white,b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                        b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16, cr, cg, cb);
            }
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_white);//bind texture
            gl10.glColor4f(er, eg, eb, 1);
            int[] vect = new int[6];
            vect[0] = (p12x << 16);
            vect[1] = (p12y << 16);
            vect[2] = x << 16;
            vect[3] = y << 16;
            vect[4] = (p21x << 16);
            vect[5] = (p21y << 16);
            gl10.glVertexPointer(2, GL10.GL_FIXED, 0, create_buf(vect));
            gl10.glDrawArrays(GL10.GL_TRIANGLE_STRIP, 0, 3);//draw  out
            gl10.glColor4f(1, 1, 1, 1);

            gl10.glBindTexture(GL10.GL_TEXTURE_2D, text_shadow);//bind texture
            int shx = m_w - (m_w - x) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int shy = m_h - (m_h - y) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b12x = m_w - (m_w - p12x) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b12y = m_h - (m_h - p12y) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b21x = m_w - (m_w - p21x) * (m_shadow_base + m_shadow_factor) / m_shadow_base;
            int b21y = m_h - (m_h - p21y) * (m_shadow_base + m_shadow_factor) / m_shadow_base;

            int b5x = m_w - (m_w - p5x) * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;
            int b5y = m_h - (m_h - p5y) * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;
            int b6x = m_w - (m_w - p6x) * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;
            int b6y = m_h - (m_h - p6y) * (m_shadow_base + (m_shadow_factor >> 1)) / m_shadow_base;

            int[] bb22 = new int[64 + 2];
            bb22[0] = corner2x;
            bb22[1] = corner2y;
            flate_bezier2(bb22[0], bb22[1], b6x, b6y, b21x, b21y, 5, bb22, 2);
            int[] bb11 = new int[64 + 2];
            bb11[0] = corner1x;
            bb11[1] = corner1y;
            flate_bezier2(bb11[0], bb11[1], b5x, b5y, b12x, b12y, 5, bb11, 2);
            drawQuadFixed(gl10, x << 16, y << 16, p21x << 16, p21y << 16,
                    shx << 16, shy << 16, b21x << 16, b21y << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            drawQuadFixed(gl10, x << 16, y << 16, p12x << 16, p12y << 16,
                    shx << 16, shy << 16, b12x << 16, b12y << 16,
                    0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            for (int pos = 0; pos < 64; pos += 2)//画四边形条目
            {
                drawQuadFixed(gl10, b22[pos] << 16, b22[pos + 1] << 16, b22[pos + 2] << 16, b22[pos + 3] << 16,
                        bb22[pos] << 16, bb22[pos + 1] << 16, bb22[pos + 2] << 16, bb22[pos + 3] << 16,
                        0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
                drawQuadFixed(gl10, b11[pos] << 16, b11[pos + 1] << 16, b11[pos + 2] << 16, b11[pos + 3] << 16,
                        bb11[pos] << 16, bb11[pos + 1] << 16, bb11[pos + 2] << 16, bb11[pos + 3] << 16,
                        0, 1 << 15, 1 << 16, 1 << 15, 0, 1 << 16, 1 << 16, 1 << 16);
            }
            gl10.glBindTexture(GL10.GL_TEXTURE_2D, 0);//bind texture
            gl10.glColor4f(1, 1, 1, 1);
        }
    }
    protected final void gl_draw_curl(GL10 gl10, int def_text, int type, int x, int y, int text_shadow)
    {
        switch(type)
        {
            case 1:
                if(m_texture == 0) drawLT(gl10, def_text, x, y, text_shadow, def_text);
                else drawLT(gl10, m_texture, x, y, text_shadow, def_text);
                break;
            case 2:
                if(m_texture == 0) drawRB(gl10, def_text, x, y, text_shadow, def_text);
                else drawRB(gl10, m_texture, x, y, text_shadow, def_text);
                break;
            default:
                gl_draw(gl10, def_text, 0, 0, m_w, m_h);
                break;
        }
    }

    protected final boolean gl_make_text()
    {
        if(m_texture != 0) return true;
        DIB dib = m_dib;
        if(dib == null) return false;
        m_dib = null;
        m_texture = dib.GLGenTexture();
        dib.Free();
        return true;
    }
    protected final boolean isCross(int left, int top, int right, int bottom)
    {
        return !(left >= m_x + m_w || right < m_x || top >= m_y + m_h || bottom < m_y);
    }
    protected final int GetX()
    {
        return m_x;
    }
    protected final int GetY()
    {
        return m_y;
    }
    protected final int GetRight()
    {
        return m_x + m_w;
    }
    protected final int GetBottom()
    {
        return m_y + m_h;
    }
    protected final int GetW()
    {
        return m_w;
    }
    protected final int GetH()
    {
        return m_h;
    }
    protected final int GetPageNo() {return m_pageno;}
    @Override
    protected void finalize() throws Throwable
    {
        bk_destroy();
        if(m_texture != 0) Log.e("LEAK", "BLOCK NOT FREED." + m_status);
        super.finalize();
    }
}
