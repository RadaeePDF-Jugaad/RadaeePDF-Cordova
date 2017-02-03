package com.radaee.util;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.webkit.URLUtil;
import android.widget.Toast;

import com.radaee.pdf.Global;
import com.radaee.reader.PDFViewAct;
import com.radaee.reader.R;

/**
 * A class that can be used by depending modules, to facilitate the PDF Viewer usage.
 *
 * @author Nermeen created on 30/01/2017.
 */
public class RadaeePDFManager implements RadaeePluginCallback.PDFReaderListener {

    private int mViewMode = 0;
    private int mCurrentPage = -1;
    private int mIconsBgColor = -1;
    private int mTitleBgColor = -1;
    private RadaeePluginCallback.PDFReaderListener mListener;

    public RadaeePDFManager() {
        Global.navigationMode = 0; //thumbnail navigation mode
        RadaeePluginCallback.getInstance().setListener(this);
    }

    public RadaeePDFManager(RadaeePluginCallback.PDFReaderListener listener) {
        Global.navigationMode = 0; //thumbnail navigation mode
        mListener = listener;
        RadaeePluginCallback.getInstance().setListener(this);
    }

    /**
     * Activates the SDK license.
     * Should be called before show, open methods
     *
     * @param context Context object must be derived from CoontextWrapper
     * @param licenseType 0: standard license, 1: professional license, 2: premium license.
     * @param companyName company name (not package name)
     * @param mail mail
     * @param key the license activation key
     * @return true if the license was activated correctly, false otherwise
     */
    public boolean activateLicense(Context context, int licenseType, String companyName, String mail, String key) {
        Global.mKey = key;
        Global.mEmail = mail;
        Global.mCompany = companyName;
        Global.mLicenseType = licenseType;
        return Global.Init(context);
    }

    /**
     * Opens the passed file and shows the PDF reader.
     *
     * @param context the current context.
     * @param url the url can be remote (starts with http/https), or local
     * @param password the pdf's password, if no apssword, pass empty string
     */
    public void show(Context context, String url, String password) {
        if(!TextUtils.isEmpty(url)) {
            String name = "";
            if(URLUtil.isHttpUrl(url) || URLUtil.isHttpsUrl(url))
                name = "PDFHttp";
            else if(URLUtil.isFileUrl(url)) {
                String prefix = "file://";
                url = url.substring(url.indexOf(prefix) + prefix.length());
                name = "PDFPath";
            } else
                name = "PDFPath";
            Intent intent = new Intent(context, PDFViewAct.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra( name, url);
            intent.putExtra( "PDFPswd", password);
            context.startActivity(intent);
        } else
            Toast.makeText(context, context.getString(R.string.failed_invalid_path), Toast.LENGTH_SHORT).show();
    }

    /**
     * Opens the passed assets file and shows the PDF reader.
     *
     * @param context the current context.
     * @param path the asset name/path
     * @param password the pdf's password, if no apssword, pass empty string
     */
    public void openFromAssets(Context context, String path, String password) {
        Intent intent = new Intent(context, PDFViewAct.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra( "PDFAsset", path);
        intent.putExtra( "PDFPswd", password);
        context.startActivity(intent);
    }

    /**
     * Opens the passed file and shows the PDF reader.
     *
     * @param context the current context.
     * @param path the pdf file path
     * @param password the pdf's password, if no apssword, pass empty string
     */
    public void openFromPath(Context context, String path, String password) {
        Intent intent = new Intent(context, PDFViewAct.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra( "PDFPath", path);
        intent.putExtra( "PDFPswd", password);
        context.startActivity(intent);
    }

    /**
     * Changes the Reader's view mode
     * Should be called before show, open methods
     *
     * @param viewMode 0:vertical 3:single 4:dual 6:Dual with cover(1st page single)
     */
    public void setReaderViewMode(int viewMode) {
        mViewMode = viewMode;
    }

    /**
     * Changes the reader's view background color.
     * Should be called before show, open methods
     *
     * @param color format as 0xAARRGGBB
     */
    public void setReaderBGColor(int color) {
        Global.readerViewBgColor = color;
    }

    /**
     * Changes the thumbnail's view background color.
     * Should be called before show, open methods
     *
     * @param color format as 0xAARRGGBB
     */
    public void setThumbnailBGColor(int color) {
        Global.thumbViewBgColor = color;
    }

    /**
     * Changes the height of the thumbnail view.
     * Should be called before show, open methods
     *
     * @param height height in dp, i.e. 100 = 100dp
     */
    public void setThumbHeight(int height) {
        if(height > 0) Global.thumbViewHeight = height;
    }

    /**
     * Sets if the first page should be rendered as cover or dual
     * Should be called before show, open methods
     *
     * @param firstPageCover if true the first page will be single, if false it will be dual (same as view_mode = 4)
     */
    public void setFirstPageCover(boolean firstPageCover) {
        if(!firstPageCover)
            mViewMode = 4;
    }

    /**
     * Gets the current page index, in case of dual it will return the page on the left
     *
     * @return the current page index (0-based), -1 otherwise
     */
    public int getPageNumber() {
        return mCurrentPage;
    }

    /**
     * Changes the color of the reader toolbar's icons.
     *
     * @param color format as 0xAARRGGBB
     */
    public void setIconsBGColor(int color) {
        mIconsBgColor = color;
        RadaeePluginCallback.getInstance().onSetIconsBGColor(color);
    }

    /**
     * Changes the color of the reader's toolbar.
     *
     * @param color format as 0xAARRGGBB
     */
    public void setTitleBGColor(int color) {
        mTitleBgColor = color;
        RadaeePluginCallback.getInstance().onSetToolbarBGColor(color);
    }

    /**
     * show/hide toolbar and thumbnails slider
     *
     * @param immersive if true the toolbar and thumbnail will be hidden (if visible),
     *                  if false and hidden they will be shown
     */
    public void setImmersive(boolean immersive) {
        RadaeePluginCallback.getInstance().onSetImmersive(immersive);
    }

    /**
     * Returns a json object that contains all the document form fields dictionary
     *
     * @return json object of all the document form fields dictionary (if-any), or ERROR otherwise
     */
    public String getJsonFormFields() {
        return RadaeePluginCallback.getInstance().onGetJsonFormFields();
    }

    /**
     * Returns a json object that contains a specific page's form fields dictionary
     *
     * @param pageno the page number, 0-index (from 0 to Document.GetPageCount - 1)
     * @return json object of the page's form fields dictionary (if-any), or ERROR otherwise
     */
    public String getJsonFormFieldsAtPage(int pageno) {
        return RadaeePluginCallback.getInstance().onGetJsonFormFieldsAtPage(pageno);
    }

    /**
     * Using the passed json, you can set the value of form fields like: Text fields, checkbox,
     * combo, radio buttons.
     *
     * @param json object of the document form fields dictionary
     */
    public String setFormFieldsWithJSON(String json) {
        return RadaeePluginCallback.getInstance().onSetFormFieldsWithJSON(json);
    }

    @Override
    public void willShowReader() {
        Global.def_view = mViewMode;
        if(mListener != null)
            mListener.willShowReader();
    }

    @Override
    public void didShowReader() {
        if(mListener != null)
            mListener.didShowReader();
        if(mIconsBgColor != -1) RadaeePluginCallback.getInstance().onSetIconsBGColor(mIconsBgColor);
        if(mTitleBgColor != -1) RadaeePluginCallback.getInstance().onSetToolbarBGColor(mTitleBgColor);
        mIconsBgColor = mTitleBgColor = -1;
    }

    @Override
    public void willCloseReader() {
        if(mListener != null)
            mListener.willCloseReader();
    }

    @Override
    public void didCloseReader() {
        if(mListener != null)
            mListener.didCloseReader();
    }

    @Override
    public void didChangePage(int pageno) {
        mCurrentPage = pageno;
        if(mListener != null)
            mListener.didChangePage(pageno);
    }

    @Override
    public void didSearchTerm(String query, boolean found) {
        if(mListener != null)
            mListener.didSearchTerm(query, found);
    }
}