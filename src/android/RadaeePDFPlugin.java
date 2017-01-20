/*
	RadaeePDF-Cordova for Android
	GEAR.it s.r.l., http://www.gear.it, http://www.radaeepdf.com
	Nermeen Solaiman
	v1.2

	modified on 09/11/16 -->  added getFileState prototype
	
	modified on 18/01/17 -->  added implementation of PDFReaderListener
*/
package com.radaee.cordova;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.URLUtil;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.reader.PDFViewAct;
import com.radaee.util.PDFHttpStream;

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
public class RadaeePDFPlugin extends CordovaPlugin implements PDFViewAct.PDFReaderListener {

    private Document mDocument;
    private boolean showPdfInProgress;
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
            Global.mLicenseType = params.optInt("licenseType");
            Global.mCompany = params.optString("company");
            Global.mEmail = params.optString("email");
            Global.mKey = params.optString("key");
			
			if(Global.Init(cordova.getActivity(), Global.mLicenseType, Global.mCompany, Global.mEmail, Global.mKey))
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
                Intent intent = new Intent(mContext, PDFViewAct.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra("PDFAsset", mTarget);
                intent.putExtra("PDFPswd", params.optString("password"));
                mContext.startActivity(intent);
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
                if(URLUtil.isFileUrl(targetPath)) { //open from file system
                    PDFViewAct.setPDFReaderListener(this);
                    String suffix = "file://";
                    Intent intent = new Intent(mContext, PDFViewAct.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra("PDFPath", targetPath.substring(targetPath.indexOf(suffix) + suffix.length()));
                    intent.putExtra("PDFPswd", params.optString("password"));
                    mContext.startActivity(intent);
                    showPdfInProgress = false;
                    callbackContext.success("Pdf local opening success");
                } else if(URLUtil.isHttpUrl(targetPath) || URLUtil.isHttpsUrl(targetPath)) { //open from remote url
                    PDFViewAct.setPDFReaderListener(this);
					Global.Init(cordova.getActivity());
                    PDFHttpStream m_http_stream = new PDFHttpStream();
                    m_http_stream.open(targetPath);
                    mDocument = new Document();
                    int ret = mDocument.OpenStreamWithoutLoadingPages(m_http_stream, params.optString("password"));
                    switch (ret)
                    {
                        case -1://need input password
                            onFail(callbackContext, "Open Failed: Invalid Password");
                            break;
                        case -2://unknown encryption
                            onFail(callbackContext, "Open Failed: Unknown Encryption");
                            break;
                        case -3://damaged or invalid format
                            onFail(callbackContext, "Open Failed: Damaged or Invalid PDF file");
                            break;
                        case -10://access denied or invalid file path
                            onFail(callbackContext, "Open Failed: Access denied or Invalid path");
                            break;
                        case 0://succeeded, and continue
                            PDFViewAct.ms_tran_doc = mDocument;
                            break;
                        default://unknown error
                            onFail(callbackContext, "Open Failed: Unknown Error");
                            break;
                    }

                    Intent intent = new Intent(mContext, PDFViewAct.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra( "PDFHttp", targetPath );
                    intent.putExtra( "PDFPswd", params.optString("password") );
                    mContext.startActivity(intent);
                }
            } else {
                showPdfInProgress = false;
                callbackContext.error("url is null or white space, this is a mandatory parameter");
            }
        } else if(action.equals("getPageNumber")) { //get current page number
            if(PDFViewAct.getInstance() != null) {
                callbackContext.success("Current page Number = " + PDFViewAct.getInstance().getCurrentPage());
            } else
                callbackContext.error("Reader Not ready");
        } else if(action.equals("JSONFormFields")) { //get file's form fields values in json format
            if(PDFViewAct.getInstance() != null) {
                callbackContext.success("Result = " + PDFViewAct.getInstance().getJsonFormFields());
            } else
                callbackContext.error("Reader Not ready");
        } else if(action.equals("JSONFormFieldsAtPage")) { //get file's form fields values for given page in json format
            if(PDFViewAct.getInstance() != null) {
                callbackContext.success("Current page Number = " +
                        PDFViewAct.getInstance().getJsonFormFieldsAtPage(args.getJSONObject(0).optInt("page")));
            } else
                callbackContext.error("Reader Not ready");
        } else
            return false;

        return true;
    }

    private void onFail(CallbackContext callbackContext, String msg) { //treat open failed.
        mDocument.Close();
        mDocument = null;
        callbackContext.error(msg);
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
    public void didSearchTerm(String query, boolean found) {
        Log.d(TAG, "did search term -> " + query + " and result = " + found);
    }
}