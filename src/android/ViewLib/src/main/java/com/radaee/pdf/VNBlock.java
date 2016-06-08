package com.radaee.pdf;

import android.graphics.Bitmap;
/**
 * Created by radaee on 2017/11/21.
 */

public class VNBlock {
    public static native void destroy(long block);
    private static native void render(long block, int quality);
    public static void Render(long block)
    {
        render(block, Global.g_render_quality);
    }
    public static native Bitmap bmp(long block);
    public static native int getSta(long block);
    public static native int getPageNO(long block);
}
