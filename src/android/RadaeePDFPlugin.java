/*
	RadaeePDF-Cordova for Android
	GEAR.it s.r.l., http://www.gear.it, http://www.radaeepdf.com
	Nermeen Solaiman
	v1.3

	modified on 09/11/16 -->  added getFileState prototype
	
	modified on 18/01/17 -->  added implementation of PDFReaderListener

	modified on 30/01/17 -->  added the usage of RadaeePDFManager
*/
package com.radaee.cordova;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.radaee.reader.PDFViewAct;
import com.radaee.util.RadaeePDFManager;
import com.radaee.util.RadaeePluginCallback;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * define the method exposed by the RadaeePDFPlugin
 */
public class RadaeePDFPlugin extends CordovaPlugin implements RadaeePluginCallback.PDFReaderListener {

    private boolean showPdfInProgress;
    private static RadaeePDFManager mPdfManager;
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
        Context mContext;
        JSONObject params;
        if(action.equals("activateLicense")) { //activate the license
            params = args.getJSONObject(0);
			
			if(mPdfManager.activateLicense(cordova.getActivity(), params.optInt("licenseType"), params.optString("company"),
                    params.optString("email"), params.optString("key")))
                callbackContext.success("License activated successfully.");
            else
                callbackContext.error("License activation failure.");
        } else if(action.equals("fileState")) { //get last opened file's state
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
        } else if(action.equals("openFromAssets")) { //open file from assets
            params = args.getJSONObject(0);

            String mTarget = params.optString("url");
            if(!TextUtils.isEmpty(mTarget)) {
                mContext = this.cordova.getActivity().getApplicationContext();
                mPdfManager.openFromAssets(mContext, mTarget, params.optString("password"));
                callbackContext.success("Pdf assets opening success");
            }
        } else if (action.equals("show")) { //open file 
        	params = args.getJSONObject(0);
            String targetPath = params.optString("url");

            if(showPdfInProgress){
                callbackContext.error("another Pdf opening in progress");
                return false;
            }
            showPdfInProgress = true;
            if(!TextUtils.isEmpty(targetPath)) {
                mContext = this.cordova.getActivity().getApplicationContext();
                mPdfManager.show(mContext, targetPath, params.optString("password"));
                    showPdfInProgress = false;
                    callbackContext.success("Pdf local opening success");
            } else {
                showPdfInProgress = false;
                callbackContext.error("url is null or white space, this is a mandatory parameter");
            }
        } else if(action.equals("getPageNumber")) { //get current page number
            callbackContext.success("Current page Number = " + mPdfManager.getPageNumber());
        } else if(action.equals("JSONFormFields")) { //get file's form fields values in json format
            callbackContext.success("JSONFormFields = " + mPdfManager.getJsonFormFields());
        } else if(action.equals("JSONFormFieldsAtPage")) { //get file's form fields values for given page in json format
            callbackContext.success("JSONFormFields = " +
                    mPdfManager.getJsonFormFieldsAtPage(args.getJSONObject(0).optInt("page")));
        }else if(action.equals("setReaderBGColor")) { //sets reader view background color
            params = args.getJSONObject(0);
            mPdfManager.setReaderBGColor(params.optInt("color"));
            callbackContext.success("Color passed to the reader");
        } else if(action.equals("setThumbnailBGColor")) { //sets thumbnail view background color
            params = args.getJSONObject(0);
            mPdfManager.setThumbnailBGColor(params.optInt("color"));
            callbackContext.success("Color passed to the reader");
        } else if(action.equals("setThumbHeight")) { //sets thumbnail view height
            params = args.getJSONObject(0);
            mPdfManager.setThumbHeight(params.optInt("height"));
            callbackContext.success("Height passed to the reader");
        } else if(action.equals("setFirstPageCover")) { //sets if the first page should be rendered as cover or dual
            params = args.getJSONObject(0);
            mPdfManager.setFirstPageCover(params.optBoolean("cover"));
            callbackContext.success("property set successfully");
        } else if(action.equals("setReaderViewMode")) { //sets the reader's view mode
            params = args.getJSONObject(0);
            mPdfManager.setReaderViewMode(params.optInt("mode"));
            callbackContext.success("property set successfully");
        } else if(action.equals("setIconsBGColor")) { //Changes the color of the reader toolbar's icons.
            params = args.getJSONObject(0);
            mPdfManager.setIconsBGColor(params.optInt("color"));
            callbackContext.success("property set successfully");
        } else if(action.equals("setTitleBGColor")) { //Changes the color of the reader's toolbar.
            params = args.getJSONObject(0);
            mPdfManager.setTitleBGColor(params.optInt("color"));
            callbackContext.success("property set successfully");
        } else
            return false;

        return true;
    }

    @Override
    public void willShowReader() {
        Log.d(TAG, "will show reader");
    }

    @Override
    public void didShowReader() {
        Log.d(TAG, "did show reader");
    }

    @Override
    public void willCloseReader() {
        Log.d(TAG, "will close reader");
    }

    @Override
    public void didCloseReader() {
        Log.d(TAG, "did close reader");
    }

    @Override
    public void didChangePage(int pageno) {
        Log.d(TAG, "Did change page " + pageno);
    }

    @Override
    public void didSearchTerm(String query, boolean found) {
        Log.d(TAG, "did search term -> " + query + " and result = " + found);
    }
}