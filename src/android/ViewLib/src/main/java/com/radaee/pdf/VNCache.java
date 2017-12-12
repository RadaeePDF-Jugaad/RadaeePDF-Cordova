package com.radaee.pdf;
/**
 * Created by radaee on 2017/11/16.
 */

public class VNCache {
    public static native void destroy(long vcache);
    public static native void render(long vcache, boolean unload);
    public static native int getNO(long vcache);
}
