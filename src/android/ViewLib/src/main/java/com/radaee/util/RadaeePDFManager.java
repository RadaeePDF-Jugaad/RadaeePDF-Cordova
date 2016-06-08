package com.radaee.util;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.text.TextUtils;
import android.webkit.URLUtil;
import android.widget.Toast;

import com.radaee.pdf.Global;
import com.radaee.pdf.Page;
import com.radaee.reader.PDFGLViewAct;
import com.radaee.reader.PDFViewAct;
import com.radaee.viewlib.R;

import java.io.File;

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

    private int mLayoutType = CPU_BASED_LAYOUT;
    public static final int GPU_BASED_LAYOUT = 0;
    public static final int CPU_BASED_LAYOUT = 1;

    public static boolean sHideSaveButton = false;
    public static boolean sHideMoreButton = false;
    public static boolean sHideUndoButton = false;
    public static boolean sHideRedoButton = false;
    public static boolean sHideShareButton = false;
    public static boolean sHidePrintButton = false;
    public static boolean sHideAnnotButton = false;
    public static boolean sHideSelectButton = false;
    public static boolean sHideSearchButton = false;
    public static boolean sHideOutlineButton = false;
    public static boolean sHideViewModeButton = false;
    public static boolean sHideAddBookmarkButton = false;
    public static boolean sHideShowBookmarksButton = false;
    private RadaeePluginCallback.PDFReaderListener mListener;

    public RadaeePDFManager() {
        this(null);
    }

    public RadaeePDFManager(RadaeePluginCallback.PDFReaderListener listener) {
        Global.g_navigation_mode = 0; //thumbnail navigation mode
        if(listener != null)
            mListener = listener;
        RadaeePluginCallback.getInstance().setListener(this);
    }

    /**
     * Activates the SDK license.
     * Should be called before show, open methods
     *
     * @param context Context object must be derived from CoontextWrapper
     * @param key the license activation key
     * @return true if the license was activated correctly, false otherwise
     */
    public boolean activateLicense(Context context, String company, String email, String key) {
        //Global.mSerial = key;
        Global.mCompany = company;
        Global.mEmail = email;
        Global.mKey = key;
        return Global.Init((ContextWrapper)context);
    }

    /**
     * Opens the passed file and shows the PDF reader.
     *
     * @param context the current context.
     * @param url the url can be remote (starts with http/https), or local
     * @param password the pdf's password, if no password, pass empty string
     */
    public void show(Context context, String url, String password) {
        show(context, url, password, false, false, 0, null,
                null, mLayoutType);
    }

    /**
     * Opens the passed file and shows the PDF reader.
     *
     * @param context the current context.
     * @param url the url can be remote (starts with http/https), or local
     * @param password the pdf's password, if no password, pass empty string
     * @param readOnlyMode if true, the document will be opened in read-only mode
     * @param automaticSave if true, the modifications will be saved automatically, else a requester to save will be shown
     * @param gotoPage if greater than 0, the reader will render directly the passed page (0-index: from 0 to Document.GetPageCount - 1)
     * @param bmpFormat bmp format, can be RGB_565 or ARGB_4444, default is ALPHA_8
     * @param author if not empty, it will be used to set annotations' author during creation.
     * @param layoutType determine the type of the layout to be used for rendering, (GPU or CPU) based layout, GPU_BASED_LAYOUT:0 (OpenGL), CPU_BASED_LAYOUT:1
     */
    public void show(Context context, String url, String password, boolean readOnlyMode, boolean automaticSave,
                     int gotoPage, String bmpFormat, String author, int layoutType) {
        mLayoutType = layoutType;
        if(!TextUtils.isEmpty(url)) {
            String name;
            if(URLUtil.isHttpUrl(url) || URLUtil.isHttpsUrl(url))
                name = "PDFHttp";
            else if(URLUtil.isFileUrl(url)) {
                String prefix = "file://";
                url = url.substring(url.indexOf(prefix) + prefix.length());
                name = "PDFPath";
            } else
                name = "PDFPath";
            Global.g_annot_def_author = author;
            Intent intent = new Intent(context, mLayoutType == GPU_BASED_LAYOUT ? PDFGLViewAct.class : PDFViewAct.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra( name, url);
            intent.putExtra( "PDFPswd", password);
            intent.putExtra("READ_ONLY", readOnlyMode);
            intent.putExtra("AUTOMATIC_SAVE", automaticSave);
            intent.putExtra("GOTO_PAGE", gotoPage);
            intent.putExtra( "BMPFormat", bmpFormat);
            context.startActivity(intent);
        } else
            Toast.makeText(context, context.getString(R.string.failed_invalid_path), Toast.LENGTH_SHORT).show();
    }

    /**
     * Opens the passed assets file and shows the PDF reader.
     *
     * @param context the current context.
     * @param path the asset name/path
     * @param password the pdf's password, if no password, pass empty string
     */
    public void openFromAssets(Context context, String path, String password) {
        openFromAssets(context, path, password, null);
    }

    /**
     * Opens the passed assets file and shows the PDF reader.
     *
     * @param context the current context.
     * @param path the asset name/path
     * @param password the pdf's password, if no password, pass empty string
     * @param bmpFormat bmp format, can be RGB_565 or ARGB_4444, default is ALPHA_8
     */
    public void openFromAssets(Context context, String path, String password, String bmpFormat) {
        Intent intent = new Intent(context, mLayoutType == GPU_BASED_LAYOUT ? PDFGLViewAct.class : PDFViewAct.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra( "PDFAsset", path);
        intent.putExtra( "PDFPswd", password);
        intent.putExtra( "BMPFormat", bmpFormat);

        context.startActivity(intent);
    }

    /**
     * Opens the passed file and shows the PDF reader.
     *
     * @param context the current context.
     * @param path the pdf file path
     * @param password the pdf's password, if no password, pass empty string
     * @param layoutType determine the type of the layout to be used for rendering, (GPU or CPU) based layout, GPU_BASED_LAYOUT:0 (OpenGL), CPU_BASED_LAYOUT:1
     */
    public void openFromPath(Context context, String path, String password, int layoutType) {
        mLayoutType = layoutType;
        Intent intent = new Intent(context, mLayoutType == GPU_BASED_LAYOUT ? PDFGLViewAct.class : PDFViewAct.class);
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
        Global.g_readerview_bg_color = color;
    }

    /**
     * Changes the thumbnail's view background color.
     * Should be called before show, open methods
     *
     * @param color format as 0xAARRGGBB
     */
    public void setThumbnailBGColor(int color) {
        Global.g_thumbview_bg_color = color;
    }

    /**
     * Changes the height of the thumbnail view.
     * Should be called before show, open methods
     *
     * @param height height in dp, i.e. 100 = 100dp
     */
    public void setThumbHeight(int height) {
        if(height > 0) Global.g_thumbview_height = height;
    }

    /**
     * Sets the debug mode in Global
     * Should be called before show, open methods
     *
     * @param debugMode if true you will see (available memory debug message)
     */
    public void setDebugMode(boolean debugMode) {
        Global.debug_mode = debugMode;
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
     * determine the type of the layout to be used for rendering, (GPU or CPU) based layout
     * @param layoutType GPU_BASED_LAYOUT:0 (OpenGL), CPU_BASED_LAYOUT:1
     */
    public void setLayoutType(int layoutType) {
        mLayoutType = layoutType;
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

    /**
     * Returns document's pages count
     *
     * @return document's pages count, -1 in case of error
     */
    public int getPageCount() {
        return RadaeePluginCallback.getInstance().onGetPageCount();
    }

    /**
     * extract the text content of the given page
     *
     * @param page the page number, 0-index (from 0 to Document.GetPageCount - 1)
     * @return the given page's text
     */
    public String extractTextFromPage(int page) {
        return RadaeePluginCallback.getInstance().onGetPageText(page);
    }

    /**
     * encrypt document and save into another file.<br/>
     * this method require premium license.
     * @param dst path to save， same as path parameter of SaveAs.
     * @param upswd user password, can be null (is the public password (shared with authorized users). It's sufficient to open the file with applied permission mask set).
     * @param opswd owner password, can be null (is the password that allow opening the file without any restriction from the permission mask).
     * @param perm permission to set, same as GetPermission() method.<br/>
     * bit 1-2 reserved<br/>
     * bit 3(0x4) print<br/>
     * bit 4(0x8) modify<br/>
     * bit 5(0x10) extract text or image<br/>
     * others: see PDF reference
     * @param method set 3 means using AES 256bits encrypt(Acrobat X), V=5 and R = 6 mode, others AES with V=4 and R=4 mode.
     * @param id must be 32 bytes for file ID. it is divided to 2 array in native library, as each 16 bytes (something like the encryption seed or salt in some
     *           other encryption scheme. That id is a reserved code that make password stronger).
     * @return Success of error.
     */
    public String encryptDocAs(String dst, String upswd, String opswd, int perm, int method, String id) {
        if(!TextUtils.isEmpty(dst)) {
            if(URLUtil.isFileUrl(dst)) {
                String prefix = "file://";
                dst = dst.substring(dst.indexOf(prefix) + prefix.length());
            }
            if(RadaeePluginCallback.getInstance().onEncryptDocAs(dst, upswd, opswd, perm, method, id.getBytes()))
                return "Success";
            else return "Error";
        }
        return "Invalid destination path";
    }

    /**
     * Adds the given page to the bookmarks.
     *
     * @param mContext context object
     * @param filePath the original pdf file
     * @param page 0 based page no.
     * @param bookmarkLabel label of Bookmark (can be empty string)
     * @return a string that indicates the result
     */
    public String addToBookmarks(Context mContext, String filePath, int page, String bookmarkLabel) {
        Global.Init((ContextWrapper)mContext);

        if(URLUtil.isFileUrl(filePath)) {
            String prefix = "file://";
            filePath = filePath.substring(filePath.indexOf(prefix) + prefix.length());
        }

        if(TextUtils.isEmpty(BookmarkHandler.getDbPath()))
            BookmarkHandler.setDbPath(mContext.getFilesDir() + File.separator + "Bookmarks.db");
        BookmarkHandler.BookmarkStatus status = BookmarkHandler.addToBookmarks(filePath, page, bookmarkLabel);
        if(status == BookmarkHandler.BookmarkStatus.SUCCESS)
            return mContext.getString(R.string.bookmark_success, bookmarkLabel);
        else if(status == BookmarkHandler.BookmarkStatus.ALREADY_ADDED)
            return mContext.getString(R.string.bookmark_already_added);
        else
            return mContext.getString(R.string.bookmark_error);
    }

    /**
     * Removes the given page from bookmarks.
     *
     * @param page 0 based page no.
     * @param filePath the orignal pdf file
     * @return true or false.
     */
    public boolean removeBookmark(int page, String filePath) {
        if(URLUtil.isFileUrl(filePath)) {
            String prefix = "file://";
            filePath = filePath.substring(filePath.indexOf(prefix) + prefix.length());
        }
        return BookmarkHandler.removeBookmark(page, filePath);
    }

    /**
     * returns a list of bookmarked pages in json format
     * @param filePath the orignal pdf file
     * @return json string or null ex: [{"Page": 4,"Label": "Page: 5"}, {"Page": 1,"Label": "Page: 2"}]
     */
    public String getBookmarksAsJson(String filePath) {
        if(URLUtil.isFileUrl(filePath)) {
            String prefix = "file://";
            filePath = filePath.substring(filePath.indexOf(prefix) + prefix.length());
        }
        return BookmarkHandler.getBookmarksAsJson(filePath);
    }

    /**
     * add a file as an attachment.<br/>
     * this can be invoked after ObjsStart or Render or RenderToBmp.<br/>
     * this method require professional or premium license.
     * @param attachmentPath absolute path name to the file.
     * @return true or false.<br/>
     */
    public boolean addAnnotAttachment(String attachmentPath) {
        return RadaeePluginCallback.getInstance().onAddAnnotAttachment(attachmentPath);
    }


    public String getTextAnnotationDetails(int page) {
        return RadaeePluginCallback.getInstance().onGetTextAnnotationDetails(page);
    }

    public String getMarkupAnnotationDetails(int page) {
        return RadaeePluginCallback.getInstance().onGetMarkupAnnotationDetails(page);
    }

    public int getCharIndex(int page, float x,float y) {
        return RadaeePluginCallback.getInstance().onGetCharIndex(page, x,y);
    }

    public void addTextAnnotation(int page, float x,float y, String text, String subject) {
        RadaeePluginCallback.getInstance().onAddTextAnnotation(page,x,y,text,subject);
    }

    public void addMarkupAnnotation(int page, int type, int index1, int index2) {
        RadaeePluginCallback.getInstance().onAddMarkupAnnotation(page,type,index1,index2);
    }

    public String getPDFCoordinates(int x, int y) {
        return RadaeePluginCallback.getInstance().onGetPDFCoordinates(x,y);
    }

    public String getScreenCoordinates(int pageno, float x, float y) {
        return RadaeePluginCallback.getInstance().onGetScreenCoordinates(pageno, x,y);
    }

    public String getPDFRect(int left, int top, int right, int bottom) {
        return RadaeePluginCallback.getInstance().onGetPDFRect(left,top,right,bottom);
    }

    public String getScreenRect(int pageno, float left, float top, float right, float bottom) {
        return RadaeePluginCallback.getInstance().onGetScreenRect(pageno,left,top,right,bottom);
    }


    /**
     * Render annot to a bitmap, and save it to the given path
     * @param page the page number, 0-index (from 0 to Document.GetPageCount - 1)
     * @param annotIndex annotation index
     * @param renderPath the directory path in which the annotation will be saved (ex:/mnt/sdcard/bitmap.png)
     *                      (in case of sdcard make sure the WRITE_EXTERNAL_STORAGE permission is granted)
     * @param bitmapWidth the desired width of the result bitmap, 0 in case of using original width
     * @param bitmapHeight the desired height of the result bitmap, 0 in case of using original height
     */
    public String renderAnnotToFile(int page, int annotIndex, String renderPath, int bitmapWidth, int bitmapHeight) {
        return RadaeePluginCallback.getInstance().renderAnnotToFile(page, annotIndex, renderPath, bitmapWidth, bitmapHeight);
    }

    public boolean flatAnnotAtPage(int page) {
        return RadaeePluginCallback.getInstance().flatAnnotAtPage(page);
    }

    public boolean flatAnnots() {
        return RadaeePluginCallback.getInstance().flatAnnots();
    }

    public boolean saveDocumentToPath(String path, String pswd) {
        return RadaeePluginCallback.getInstance().saveDocumentToPath(path, pswd);
    }

    public boolean saveDocumentToPath(String path) {
        return RadaeePluginCallback.getInstance().saveDocumentToPath(path, "");
    }

    public void closeReader() {
        RadaeePluginCallback.getInstance().closeReader();
    }

    @Override
    public void willShowReader() {
        Global.g_view_mode = mViewMode;
        if(mListener != null) mListener.willShowReader();
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
        if(mListener != null) mListener.willCloseReader();
    }

    @Override
    public void didCloseReader() {
        if(mListener != null) mListener.didCloseReader();
    }

    @Override
    public void didChangePage(int pageno) {
        mCurrentPage = pageno;
        if(mListener != null) mListener.didChangePage(pageno);
    }

    @Override
    public void didSearchTerm(String query, boolean found) {
        if(mListener != null) mListener.didSearchTerm(query, found);
    }

    @Override
    public void onBlankTapped(int pageno) {
        if(mListener != null) mListener.onBlankTapped(pageno);
    }

    @Override
    public void onAnnotTapped(Page.Annotation annot) {
        if(mListener != null) mListener.onAnnotTapped(annot);
    }

    @Override
    public void onDoubleTapped(int pageno, float x, float y) {
        if(mListener != null) mListener.onDoubleTapped(pageno, x, y);
    }

    @Override
    public void onLongPressed(int pageno, float x, float y) {
        if(mListener != null) mListener.onLongPressed(pageno, x, y);
    }
}