package com.radaee.util;

import com.radaee.pdf.Page;

/**
 * A class to manage callbacks between PDF viewer, and calling class.
 * Your class should implement PDFReaderListener to receive its events.
 *
 * @author Nermeen created on 23/01/2017.
 */
public class RadaeePluginCallback {

    private PDFReaderListener mListener;
    private PDFThumbListener mThumbListener;
    private PDFControllerListener mControlListener;
    private static RadaeePluginCallback mInstance;

    private RadaeePluginCallback() {}

    public static RadaeePluginCallback getInstance() {
        if(mInstance == null) {
            mInstance = new RadaeePluginCallback();
        }
        return mInstance;
    }

    public void setListener(PDFReaderListener listener) {
        mListener = listener;
    }

    public void setThumbListener(PDFThumbListener listener) {
        mThumbListener = listener;
    }

    public void setControllerListener(PDFControllerListener listener) {
        mControlListener = listener;
    }

    public void willShowReader() {
        if(mListener != null) mListener.willShowReader();
    }

    public void didShowReader() {
        if(mListener != null) mListener.didShowReader();
    }

    public void willCloseReader() {
        if(mListener != null) mListener.willCloseReader();
    }

    public void didCloseReader() {
        if(mListener != null) mListener.didCloseReader();
    }

    public void didChangePage(int pageno) {
        if(mListener != null) mListener.didChangePage(pageno);
    }

    public void didSearchTerm(String query, boolean found) {
        if(mListener != null) mListener.didSearchTerm(query, found);
    }

    public void onBlankTapped(int pageno) {
        if(mListener != null) mListener.onBlankTapped(pageno);
    }

    public void onAnnotTapped(Page.Annotation annot) {
        if(mListener != null) mListener.onAnnotTapped(annot);
    }

    public void onThumbPageClick(int pageno) {
        if(mThumbListener != null)
            mThumbListener.onPageClicked(pageno);
    }

    public void onDoubleTapped(int pageno, float x, float y) {
        if(mListener != null) mListener.onDoubleTapped(pageno, x, y);
    }

    public void onLongPressed(int pageno, float x, float y) {
        if(mListener != null) mListener.onLongPressed(pageno, x, y);
    }

    public void onSetIconsBGColor(int color) {
        if(mControlListener != null) mControlListener.onSetIconsBGColor(color);
    }

    public void onSetToolbarBGColor(int color) {
        if(mControlListener != null) mControlListener.onSetToolbarBGColor(color);
    }

    public void onSetImmersive(boolean immersive) {
        if(mControlListener != null) mControlListener.onSetImmersive(immersive);
    }

    public String onGetJsonFormFields() {
        return mControlListener != null ? mControlListener.onGetJsonFormFields() : "ERROR";
    }

    public String onGetJsonFormFieldsAtPage(int pageno) {
        return mControlListener != null ? mControlListener.onGetJsonFormFieldsAtPage(pageno) : "ERROR";
    }

    public String onSetFormFieldsWithJSON(String json) {
        return mControlListener != null ? mControlListener.onSetFormFieldsWithJSON(json) : "ERROR";
    }

    public int onGetPageCount() {
        return mControlListener != null ? mControlListener.onGetPageCount() : -1;
    }

    public String onGetPageText(int pageno) {
        return mControlListener != null ? mControlListener.onGetPageText(pageno) : "ERROR";
    }

    public boolean onEncryptDocAs(String dst, String upswd, String opswd, int perm, int method, byte[] id) {
        return mControlListener != null && mControlListener.onEncryptDocAs(dst, upswd, opswd, perm, method, id);
    }

    public boolean onAddAnnotAttachment(String attachmentPath) {
        return mControlListener != null && mControlListener.onAddAnnotAttachment(attachmentPath);
    }

    public String renderAnnotToFile(int page, int annotIndex, String renderPath, int bitmapWidth, int bitmapHeight) {
        return mControlListener != null ? mControlListener.renderAnnotToFile(page, annotIndex,
                renderPath, bitmapWidth, bitmapHeight) : "ERROR";
    }

    /**
     * An interface that can help in recognizing some events.
     */
    public interface PDFReaderListener {
        void willShowReader();
        void didShowReader();
        void willCloseReader();
        void didCloseReader();
        void didChangePage(int pageno);
        void didSearchTerm(String query, boolean found);
        void onBlankTapped(int pageno);
        void onAnnotTapped(Page.Annotation annot);
        void onDoubleTapped(int pageno, float x, float y);
        void onLongPressed(int pageno, float x, float y);
    }

    /**
     * An interface that recognizes the thumbnail grid page click event
     */
    public interface PDFThumbListener {
        void onPageClicked( int pageno );
    }

    /**
     * Interface to help pass events to the PDFViewController
     */
    public interface PDFControllerListener {
        int onGetPageCount();
        void onSetIconsBGColor(int color);
        void onSetToolbarBGColor(int color);
        void onSetImmersive(boolean immersive);
        String onGetPageText(int pageno);
        String onGetJsonFormFields();
        String onGetJsonFormFieldsAtPage(int pageno);
        String onSetFormFieldsWithJSON(String json);
        boolean onAddAnnotAttachment(String attachmentPath);
        boolean onEncryptDocAs(String dst, String upswd, String opswd, int perm, int method, byte[] id);
        String renderAnnotToFile(int page, int annotIndex, String renderPath, int bitmapWidth, int bitmapHeight);
    }
}