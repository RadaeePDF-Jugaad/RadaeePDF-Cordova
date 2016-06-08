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
    private PDFActivityListener mActivityListener;
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

    public void setActivityListener(PDFActivityListener listener) {
        mActivityListener = listener;
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

    public boolean flatAnnotAtPage(int page) {
        return mControlListener != null && mControlListener.flatAnnotAtPage(page);
    }

    public boolean flatAnnots() {
        return mControlListener != null && mControlListener.flatAnnots();
    }

    public boolean saveDocumentToPath(String path, String pswd) {
        return mControlListener != null && mControlListener.saveDocumentToPath(path, pswd);
    }

    public void closeReader() {
        if(mActivityListener != null)
            mActivityListener.closeReader();
    }

    public String onGetTextAnnotationDetails(int page) {
        return mControlListener != null ? mControlListener.onGetTextAnnotationDetails(page) : "ERROR";
    }

    public String onGetMarkupAnnotationDetails(int page) {
        return mControlListener != null ? mControlListener.onGetMarkupAnnotationDetails(page) : "ERROR";
    }

    public int onGetCharIndex(int page, float x, float y) {
        return mControlListener != null ? mControlListener.onGetCharIndex(page,x,y) : -1;
    }

    public void onAddTextAnnotation(int page, float x, float y, String text, String subject) {
        if (mControlListener != null)  mControlListener.onAddTextAnnotation(page,x,y,text,subject);
    }

    public void onAddMarkupAnnotation(int page, int type, int index1, int index2) {
        if (mControlListener != null)  mControlListener.onAddMarkupAnnotation(page,type,index1,index2);
    }

    public String onGetPDFCoordinates(int x, int y) {
        return mControlListener != null ? mControlListener.onGetPDFCoordinates(x,y) : "ERROR";
    }

    public String onGetScreenCoordinates(int pageno, float x, float y) {
        return mControlListener != null ? mControlListener.onGetScreenCoordinates(pageno, x,y) : "ERROR";
    }

    public String onGetScreenRect(int pageno, float left, float top, float right, float bottom) {
        return mControlListener != null ? mControlListener.onGetScreenRect(pageno,left,top,right,bottom) : "ERROR";
    }

    public String onGetPDFRect(int left, int top, int right, int bottom) {
        return mControlListener != null ? mControlListener.onGetPDFRect(left,top,right,bottom) : "ERROR";
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
     * this interface is only used in cordova plugin.
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
        boolean flatAnnotAtPage(int page);
        boolean flatAnnots();
        boolean saveDocumentToPath(String path, String pswd);
        String onGetTextAnnotationDetails(int page);
        String onGetMarkupAnnotationDetails(int page);
        int onGetCharIndex(int page, float x, float y);
        void onAddTextAnnotation(int page, float x, float y, String text, String subject);
        void onAddMarkupAnnotation(int page, int type, int index1, int index2);
        String onGetPDFCoordinates(int x, int y);
        String onGetScreenCoordinates(int pageno, float x, float y);
        String onGetScreenRect(int pageno, float left, float top, float right, float bottom);
        String onGetPDFRect(int left, int top, int right, int bottom);
    }

    /**
     * Interface to help pass events to the Activity
     */
    public interface PDFActivityListener {
        void closeReader();
    }
}