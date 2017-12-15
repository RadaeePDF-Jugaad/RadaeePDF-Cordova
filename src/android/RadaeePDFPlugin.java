/*
	RadaeePDF-Cordova for Android
	GEAR.it s.r.l., http://www.gear.it, http://www.radaeepdf.com
	Nermeen Solaiman
	v1.4

	modified on 09/11/16 -->  added getFileState prototype
	
	modified on 18/01/17 -->  added implementation of PDFReaderListener

	modified on 30/01/17 -->  added the usage of RadaeePDFManager

	modified on 26/04/17 -->  added getPageCount, extractTextFromPage and encryptDocAs actions
	
	modified on 20/06/17 -->  added addToBookmarks, removeBookmark and getBookmarks actions
	
	modified on 30/08/17 -->  added support to js callbacks
	
	modified on 05/10/17 -->  added double tap/long press js callbacks
*/
package com.radaee.cordova;

import android.content.Context;
import android.text.TextUtils;
import android.webkit.URLUtil;

import com.radaee.pdf.Global;
import com.radaee.pdf.Page;
import com.radaee.reader.PDFViewAct;
import com.radaee.reader.R; 
import com.radaee.util.BookmarkHandler;
import com.radaee.util.RadaeePDFManager;
import com.radaee.util.RadaeePluginCallback;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

/**
 * define the method exposed by the RadaeePDFPlugin
 */
public class RadaeePDFPlugin extends CordovaPlugin implements RadaeePluginCallback.PDFReaderListener {

    private boolean showPdfInProgress;
    private static RadaeePDFManager mPdfManager;
    private static CallbackContext sWillShowReader;
    private static CallbackContext sDidShowReader;
    private static CallbackContext sWillCloseReader;
    private static CallbackContext sDidCloseReader;
    private static CallbackContext sDidChangePage;
    private static CallbackContext sDidSearchTerm;
    private static CallbackContext sDidTapOnPage;
    private static CallbackContext sDidTapOnAnnot;
	private static CallbackContext sDidDoubleTap;
    private static CallbackContext sDidLongPress;
    private static final String TAG = "RadaeePDFPlugin";

	/**
     * Constructor.
     */
    public RadaeePDFPlugin() {
    }

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        mPdfManager = new RadaeePDFManager(this);
    }
    
    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback id used when calling back into JavaScript.
     * @return                  True if the action was valid, false if not.
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Context mContext = this.cordova.getActivity().getApplicationContext();
        BookmarkHandler.setDbPath(mContext.getFilesDir() + File.separator + "Bookmarks.db");

        JSONObject params;
        switch (action) {
            case "activateLicense":  //activate the license
                params = args.getJSONObject(0);

                if (mPdfManager.activateLicense(cordova.getActivity(), params.optInt("licenseType"), params.optString("company"),
                        params.optString("email"), params.optString("key")))
                    callbackContext.success("License activated successfully.");
                else
                    callbackContext.error("License activation failure.");
                break;
            case "fileState":  //get last opened file's state
                switch (PDFViewAct.getFileState()) {
                    case PDFViewAct.NOT_MODIFIED:
                        callbackContext.success("File has not been modified");
                        break;
                    case PDFViewAct.MODIFIED_NOT_SAVED:
                        callbackContext.success("File has been modified but not saved");
                        break;
                    case PDFViewAct.MODIFIED_AND_SAVED:
                        callbackContext.success("File has been modified and saved");
                        break;
                }
                break;
            case "openFromAssets":  //open file from assets
                params = args.getJSONObject(0);

                String mTarget = params.optString("url");
                if (!TextUtils.isEmpty(mTarget)) {
                    mPdfManager.openFromAssets(mContext, mTarget, params.optString("password"));
                    callbackContext.success("Pdf assets opening success");
                }
                break;
            case "show":  //open file
                params = args.getJSONObject(0);
                String targetPath = params.optString("url");

                if (showPdfInProgress) {
                    callbackContext.error("another Pdf opening in progress");
                    return false;
                }
                showPdfInProgress = true;
                if (!TextUtils.isEmpty(targetPath)) {
                    mPdfManager.show(mContext, targetPath, params.optString("password"), params.optBoolean("readOnlyMode"),
                            params.optBoolean("automaticSave"), params.optInt("gotoPage"), params.optString("bmpFormat"), params.optString("author"));
                    showPdfInProgress = false;
                    callbackContext.success("Pdf local opening success");
                } else {
                    showPdfInProgress = false;
                    callbackContext.error("url is null or white space, this is a mandatory parameter");
                }
                break;
            case "getPageNumber":  //get current page number
                callbackContext.success("Current page Number = " + mPdfManager.getPageNumber());
                break;
            case "JSONFormFields":  //get file's form fields values in json format
                callbackContext.success("JSONFormFields = " + mPdfManager.getJsonFormFields());
                break;
            case "JSONFormFieldsAtPage":  //get file's form fields values for given page in json format
                callbackContext.success("JSONFormFields = " +
                        mPdfManager.getJsonFormFieldsAtPage(args.getJSONObject(0).optInt("page")));
                break;
            case "setFormFieldWithJSON":  //Set form fields' values
                params = args.getJSONObject(0);
                callbackContext.success("Result = " + mPdfManager.setFormFieldsWithJSON(params.optString("json")));
                break;
            case "setReaderBGColor":  //sets reader view background color
                params = args.getJSONObject(0);
                mPdfManager.setReaderBGColor(params.optInt("color"));
                callbackContext.success("Color passed to the reader");
                break;
            case "setThumbnailBGColor":  //sets thumbnail view background color
                params = args.getJSONObject(0);
                mPdfManager.setThumbnailBGColor(params.optInt("color"));
                callbackContext.success("Color passed to the reader");
                break;
            case "setThumbHeight":  //sets thumbnail view height
                params = args.getJSONObject(0);
                mPdfManager.setThumbHeight(params.optInt("height"));
                callbackContext.success("Height passed to the reader");
                break;
			case "setDebugMode":  //Sets the debug mode in Global
                params = args.getJSONObject(0);
                mPdfManager.setDebugMode(params.optBoolean("mode"));
                callbackContext.success("property set successfully");
                break;
            case "setFirstPageCover":  //sets if the first page should be rendered as cover or dual
                params = args.getJSONObject(0);
                mPdfManager.setFirstPageCover(params.optBoolean("cover"));
                callbackContext.success("property set successfully");
                break;
            case "setReaderViewMode":  //sets the reader's view mode
                params = args.getJSONObject(0);
                mPdfManager.setReaderViewMode(params.optInt("mode"));
                callbackContext.success("property set successfully");
                break;
            case "setIconsBGColor":  //Changes the color of the reader toolbar's icons.
                params = args.getJSONObject(0);
                mPdfManager.setIconsBGColor(params.optInt("color"));
                callbackContext.success("property set successfully");
                break;
            case "setTitleBGColor":  //Changes the color of the reader's toolbar.
                params = args.getJSONObject(0);
                mPdfManager.setTitleBGColor(params.optInt("color"));
                callbackContext.success("property set successfully");
                break;
            case "getPageCount": //get total page count
                callbackContext.success("Total page count = " + mPdfManager.getPageCount());
                break;
            case "extractTextFromPage": //get given page's text
                callbackContext.success("Page text = " + mPdfManager.extractTextFromPage(args.getJSONObject(0).optInt("page")));
                break;
            case "encryptDocAs":  //encrypt the opened document
                params = args.getJSONObject(0);
                callbackContext.success("document encrypted = " + mPdfManager.encryptDocAs(params.optString("dst"), params.optString("user_pwd"),
                        params.optString("owner_pwd"), params.optInt("permission"), params.optInt("method"), params.optString("id")));
                break;
            case "addToBookmarks":
            case "removeBookmark":
            case "getBookmarks":
                handleBookmarkActions(action, args.getJSONObject(0), callbackContext);
                break;
            case "willShowReaderCallback":
                sWillShowReader = callbackContext;
                break;
            case "didShowReaderCallback":
                sDidShowReader = callbackContext;
                break;
            case "willCloseReaderCallback":
                sWillCloseReader = callbackContext;
                break;
            case "didCloseReaderCallback":
                sDidCloseReader = callbackContext;
                break;
            case "didChangePageCallback":
                sDidChangePage = callbackContext;
                break;
            case "didSearchTermCallback":
                sDidSearchTerm = callbackContext;
                break;
            case "didTapOnPageCallback":
                sDidTapOnPage = callbackContext;
                break;
            case "didTapOnAnnotationOfTypeCallback":
                sDidTapOnAnnot = callbackContext;
                break;
			case "didDoubleTapOnPageCallback":
                sDidDoubleTap = callbackContext;
                break;
            case "didLongPressOnPageCallback":
                sDidLongPress = callbackContext;
                break;
            default:
                return false;
        }

        return true;
    }

    @Override
    public void willShowReader() {
        if(sWillShowReader != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            sWillShowReader.sendPluginResult(result);
        }
    }

    @Override
    public void didShowReader() {
        if(sDidShowReader != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            sDidShowReader.sendPluginResult(result);
        }
        //Log.d(TAG, mPdfManager.encryptDocAs("/mnt/sdcard/Download/pdf/License_enc.pdf", "12345", "", 4, 4, "123456789abcdefghijklmnopqrstuvw"));
    }

    @Override
    public void willCloseReader() {
        if(sWillCloseReader != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            sWillCloseReader.sendPluginResult(result);
        }
    }

    @Override
    public void didCloseReader() {
        if(sDidCloseReader != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            sDidCloseReader.sendPluginResult(result);
        }
    }

    @Override
    public void didChangePage(int pageno) {
        if(sDidChangePage != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, pageno);
            result.setKeepCallback(true);
            sDidChangePage.sendPluginResult(result);
        }
    }

    @Override
    public void didSearchTerm(String query, boolean found) {
        if(sDidSearchTerm != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, query);
            result.setKeepCallback(true);
            sDidSearchTerm.sendPluginResult(result);
        }
    }

    @Override
    public void onBlankTapped(int pageno) {
        if(sDidTapOnPage != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, pageno);
            result.setKeepCallback(true);
            sDidTapOnPage.sendPluginResult(result);
        }
    }

    @Override
    public void onAnnotTapped(Page.Annotation annot) {
        if(sDidTapOnAnnot != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, annot.GetType());
            result.setKeepCallback(true);
            sDidTapOnAnnot.sendPluginResult(result);
        }
    }

    @Override
    public void onDoubleTapped(int pageno, float x, float y) {
        if(sDidDoubleTap != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, pageno);
            result.setKeepCallback(true);
            sDidDoubleTap.sendPluginResult(result);
        }
    }

    @Override
    public void onLongPressed(int pageno, float x, float y) {
        if(sDidLongPress != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, pageno);
            result.setKeepCallback(true);
            sDidLongPress.sendPluginResult(result);
        }
    }

    private void handleBookmarkActions(String action, JSONObject params, CallbackContext callbackContext) {
        Context mContext = this.cordova.getActivity().getApplicationContext();
        if(!Global.isLicenseActivated())
            Global.Init(mContext);

        String filePath = params.optString("pdfPath");
        if (TextUtils.isEmpty(filePath)) {
            callbackContext.error("pdfPath is null or white space, this is a mandatory parameter");
            return;
        }

        if(URLUtil.isFileUrl(filePath)) {
            String prefix = "file://";
            filePath = filePath.substring(filePath.indexOf(prefix) + prefix.length());
        }

        int page = params.optInt("page");

        switch (action) {
            case "addToBookmarks":
                String bookmarkLabel = TextUtils.isEmpty(params.optString("label")) ? mContext.getString(R.string.bookmark_label, page + 1)
                        : params.optString("label");
                handleAddToBookmarks(filePath, page, bookmarkLabel, callbackContext);
                break;
            case "removeBookmark":
                handleRemoveBookmark(filePath, page, callbackContext);
                break;
            case "getBookmarks":
                handleGetBookmarks(filePath, callbackContext);
                break;
        }
    }

    private void handleAddToBookmarks(String filePath, int page, String bookmarkLabel, CallbackContext callbackContext) {
        Context mContext = this.cordova.getActivity().getApplicationContext();

        callbackContext.success(mPdfManager.addToBookmarks(mContext, filePath, page, bookmarkLabel));
    }

    private void handleRemoveBookmark(String filePath, int page, CallbackContext callbackContext) {
        Context mContext = this.cordova.getActivity().getApplicationContext();

        if(mPdfManager.removeBookmark(page, filePath))
            callbackContext.success("Bookmark deleted successfully for page " + page);
        else
            callbackContext.error(mContext.getString(R.string.bookmark_remove_error));
    }

    private void handleGetBookmarks(String filePath, CallbackContext callbackContext) {
        Context mContext = this.cordova.getActivity().getApplicationContext();

        String bookmarks = mPdfManager.getBookmarksAsJson(filePath);
        if(TextUtils.isEmpty(bookmarks))
            callbackContext.error(mContext.getString(R.string.no_bookmarks));
        else
            callbackContext.success("Bookmarks json: " + bookmarks);
    }
}