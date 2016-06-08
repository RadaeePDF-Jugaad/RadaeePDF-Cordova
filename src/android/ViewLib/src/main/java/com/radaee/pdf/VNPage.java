package com.radaee.pdf;

import android.graphics.Bitmap;
import android.graphics.Canvas;

/*
 * Created by radaee on 2017/11/16.
 */

public class VNPage {
    public interface VNPageListener
    {
        void Render(long vcache);
        void Dealloc(long vcache);
        void BlkRender(long block);
        void BlkDealloc(long block);
        boolean Draw(long block, Canvas canvas, int src_left, int src_top, int src_right, int src_bottom, int dst_left, int dst_top, int dst_right, int dst_bottom);
    }
    protected static native long create(long doc, int pageno, int cw, int ch, Bitmap.Config format);
    protected static native long createFromSuperDoc(long super_doc, int pageno, int cw, int ch, Bitmap.Config format);
    public static native void destroy(long vpage, VNPageListener callback);
    public static native boolean blkRendered(long vpage);
    public static native boolean blkDraw(long vpage, VNPageListener callback, Canvas canvas, float pdfx1, float pdfy1, float pdfx2, float pdfy2, int x, int y);
    public static native void blkStart(long vpage, VNPageListener callback, float pdfx1, float pdfy1, float pdfx2, float pdfy2);
    public static native void blkStart0(long vpage, VNPageListener callback, float pdfx, float pdfy);
    public static native void blkStart1(long vpage, VNPageListener callback);
    public static native void blkStart2(long vpage, VNPageListener callback, float pdfx, float pdfy);
    public static native void blkEnd(long vpage, VNPageListener callback);

    public static native int getPageNo(long vpage);
    public static native int getX(long vpage);
    public static native void setX(long vpage, int x);
    public static native int getY(long vpage);
    public static native int getWidth(long vpage);
    public static native int getHeight(long vpage);
    public static native int getVX(long vpage, float pdfx);
    public static native int getVY(long vpage, float pdfy);
    public static native float getPDFX(long vpage, int vx);
    public static native float getPDFY(long vpage, int vy);
    public static native float toPDFX(long vpage, float x, float scrollx);
    public static native float toPDFY(long vpage, float y, float scrolly);
    public static native float toDIBX(long vpage, float x);
    public static native float toDIBY(long vpage, float y);
    public static native float toPDFSize(long vpage, float val);
    public static native int locVert(long vpage, int y, int gap_half);
    public static native int lovHorz(long vpage, int x, int gap_half);
    public static native void layout(long vpage, int x, int y, float scale, boolean clip);
    public static native void clips(long vpage, VNPageListener callback, boolean clip);
    public static native void endPage(long vpage, VNPageListener callback);
    public static native boolean finished(long vpage);
    public static native void renderAsync(long vpage, VNPageListener callback, int vx, int vy, int vw, int vh);
    public static native void renderSync(long vpage, VNPageListener callback, int vx, int vy, int vw, int vh);
    private static native long draw(long vpage, VNPageListener callback, long bmp, int vx, int vy);
    public static long Draw(long vpage, VNPageListener callback, BMP bmp, int vx, int vy)
    {
        return draw(vpage, callback, bmp.hand, vx, vy);
    }
    public static native boolean drawStep1(long vpage, VNPageListener callback, Canvas canvas, long result);
    private static native void drawStep2(long vpage, long bmp, long result);
    public static void DrawStep2(long vpage, BMP bmp, long result) {drawStep2(vpage, bmp.hand, result);}
    public static native void resultDestroy(long result);
    private static native void zoomStart(long vpage, long bmp, int bits);
    public static void ZoomStart(long vpage, BMP bmp, int bits) {zoomStart(vpage, bmp.hand, bits);}
    public static native void zoomConfirm(long vpage, VNPageListener callback, int vx, int vy, int vw, int vh);
    private static native long invertMatrix(long vpage, float scrollx, float scrolly);
    public static Matrix InvertMatrix(long vpage, float scrollx, float scrolly)
    {
        long hand = invertMatrix(vpage, scrollx, scrolly);
        if(hand == 0) return null;
        return new Matrix(hand);
    }
}
