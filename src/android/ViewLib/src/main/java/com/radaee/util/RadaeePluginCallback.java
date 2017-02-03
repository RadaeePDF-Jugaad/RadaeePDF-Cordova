package com.radaee.util;

/**
 * A class to manage callbacks between PDF viewer, and calling class.
 * Your class should implement PDFReaderListener to receive its events.
 *
 * @author Nermeen created on 23/01/2017.
 */
public class RadaeePluginCallback {

    private PDFReaderListener mListener;
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

    public void setControllerListener(PDFControllerListener listener) {
        mControlListener = listener;
    }

    public void willShowReader() {
        if(mListener != null)
            mListener.willShowReader();
    }

    public void didShowReader() {
        if(mListener != null)
            mListener.didShowReader();
    }

    public void willCloseReader() {
        if(mListener != null)
            mListener.willCloseReader();
    }

    public void didCloseReader() {
        if(mListener != null)
            mListener.didCloseReader();
    }

    public void didChangePage(int pageno) {
        if(mListener != null)
            mListener.didChangePage(pageno);
    }

    public void didSearchTerm(String query, boolean found) {
        if(mListener != null)
            mListener.didSearchTerm(query, found);
    }

    public void onSetIconsBGColor(int color) {
        if(mControlListener != null)
            mControlListener.onSetIconsBGColor(color);
    }

    public void onSetToolbarBGColor(int color) {
        if(mControlListener != null)
            mControlListener.onSetToolbarBGColor(color);
    }

    public void onSetImmersive(boolean immersive) {
        if(mControlListener != null)
            mControlListener.onSetImmersive(immersive);
    }

    public String onGetJsonFormFields() {
        if(mControlListener != null)
            return mControlListener.onGetJsonFormFields();
        return "ERROR";
    }

    public String onGetJsonFormFieldsAtPage(int pageno) {
        if(mControlListener != null)
            return mControlListener.onGetJsonFormFieldsAtPage(pageno);
        return "ERROR";
    }

    public String onSetFormFieldsWithJSON(String json) {
        if(mControlListener != null)
            return mControlListener.onSetFormFieldsWithJSON(json);
        return "ERROR";
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
    }

    /**
     * Interface to help pass events to the PDFViewController
     */
    public interface PDFControllerListener {
        void onSetIconsBGColor(int color);
        void onSetToolbarBGColor(int color);
        void onSetImmersive(boolean immersive);
        String onGetJsonFormFields();
        String onGetJsonFormFieldsAtPage(int pageno);
        String onSetFormFieldsWithJSON(String json);
    }
}