package com.radaee.util;

import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Page;
import com.radaee.reader.PDFLayoutView;
import com.radaee.viewlib.R;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;

/**
 * @author Davide created on 15/01/2016.
 *
 * modified on 23/11/2016
 *      Adding new utils methods.
 */
public class CommonUtil {

    private static final String TAG = "RadaeeCommonUtil";
    private static final int CACHE_LIMIT = 1024;

    static String getThumbName(String path)
    {
        try {
            File file = new File(path);
            long lastModifiedDate = file.lastModified();
            return CommonUtil.md5(path + lastModifiedDate);
        }
        catch(Exception e)
        {
            return null;
        }
    }

    static Bitmap loadThumb(File pictureFile) {
        try {
            if(!pictureFile.exists())
                return null;
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            return BitmapFactory.decodeFile(pictureFile.getAbsolutePath(), options);
        } catch (Exception e) {
            return null;
        }
    }

    static void saveThumb(Bitmap image, File pictureFile) {
        if (pictureFile == null) {
            Log.d(TAG,
                    "Error creating media file, check storage permissions: ");// e.getMessage());
            return;
        }
        try {
            FileOutputStream fos = new FileOutputStream(pictureFile);
            image.compress(Bitmap.CompressFormat.PNG, 90, fos);
            fos.close();
        } catch (FileNotFoundException e) {
            Log.d(TAG, "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d(TAG, "Error accessing file: " + e.getMessage());
        }
    }

    static File getOutputMediaFile(Context context, String thumbName) {
        File dir = new File(context.getCacheDir() + "/thumbnails");
        if(dir.exists()) { //too many caches
            File files[] = dir.listFiles();
            if(files.length > CACHE_LIMIT)
                files[0].deleteOnExit();
        }
        File file = new File(context.getCacheDir() + "/thumbnails/" + thumbName + ".png");
        if (!file.exists()) {
            File mediaStorageDir = new File(context.getCacheDir() + "/thumbnails");

            // Create the storage directory if it does not exist
            if (!mediaStorageDir.exists()) {
                if (!mediaStorageDir.mkdirs()) {
                    return null;
                }
            }
            // Create a media file name
            String mImageName = thumbName + ".png";
            return new File(mediaStorageDir.getPath() + File.separator + mImageName);
        } else {
            return file;
        }
    }

    private static String md5(String input) {
        final String MD5 = "MD5";
        try {
            // Create MD5 Hash
            MessageDigest digest = java.security.MessageDigest.getInstance(MD5);
            digest.update(input.getBytes());
            byte messageDigest[] = digest.digest();

            // Create Hex String
            StringBuilder hexString = new StringBuilder();
            for (byte aMessageDigest : messageDigest) {
                String h = Integer.toHexString(0xFF & aMessageDigest);
                while (h.length() < 2) h = "0" + h;
                hexString.append(h);
            }
            return hexString.toString();

        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static JSONObject constructPageJsonFormFields(Page mPage, int index) {
        try {
            if(mPage != null) {
                mPage.ObjsStart();
                JSONArray mPagesAnnot = new JSONArray();
                for(int i = 0 ; i < mPage.GetAnnotCount() ; i++) {
                    Page.Annotation mAnnotation = mPage.GetAnnot(i);
                    if(mAnnotation != null && (mAnnotation.GetType() == 20 || mAnnotation.GetType() == 3)) {
                        JSONObject mAnnotInfoJson = new JSONObject();

                        mAnnotInfoJson.put("Index", mAnnotation.GetIndexInPage());
                        mAnnotInfoJson.put("Name", mAnnotation.GetName());
                        mAnnotInfoJson.put("Type", mAnnotation.GetType());

                        mAnnotInfoJson.put("FieldName", mAnnotation.GetFieldName());
                        mAnnotInfoJson.put("FieldNameWithNO", mAnnotation.GetFieldNameWithNO());
                        mAnnotInfoJson.put("FieldFullName", mAnnotation.GetFieldFullName());
                        mAnnotInfoJson.put("FieldFullName2", mAnnotation.GetFieldFullName2());
                        mAnnotInfoJson.put("FieldFlag", mAnnotation.GetFieldFlag());
                        mAnnotInfoJson.put("FieldFormat", mAnnotation.GetFieldFormat());
                        mAnnotInfoJson.put("FieldType", mAnnotation.GetFieldType());

                        mAnnotInfoJson.put("PopupLabel", mAnnotation.GetPopupLabel());

                        mAnnotInfoJson.put("CheckStatus", mAnnotation.GetCheckStatus());

                        mAnnotInfoJson.put("ComboItemSel", mAnnotation.GetComboItemSel());
                        mAnnotInfoJson.put("ComboItemSelItem", mAnnotation.GetComboItemSel() == -1 ? mAnnotation.GetComboItemSel() :
                            mAnnotation.GetComboItem(mAnnotation.GetComboItemSel()));
                        mAnnotInfoJson.put("ComboItemCount", mAnnotation.GetComboItemCount());

                        if(mAnnotation.GetListSels() != null) {
                            int[] items = mAnnotation.GetListSels();
                            if(items.length == 0)
                                mAnnotInfoJson.put("ListSels", "");
                            else {
                                String selValues = "";
                                for(int item : items)
                                    selValues += mAnnotation.GetListItem(item) + ", ";
                                mAnnotInfoJson.put("ListSels", Arrays.toString(items));
                                mAnnotInfoJson.put("ListSelsItems", selValues.substring(0, selValues.lastIndexOf(",")));
                            }
                        }
                        mAnnotInfoJson.put("ListItemCount", mAnnotation.GetListItemCount());

                        mAnnotInfoJson.put("EditText", mAnnotation.GetEditText());
                        mAnnotInfoJson.put("EditType", mAnnotation.GetEditType());
                        mAnnotInfoJson.put("EditTextFormat", mAnnotation.GetEditTextFormat());

                        mAnnotInfoJson.put("SignStatus", mAnnotation.GetSignStatus());

                        mPagesAnnot.put(mAnnotInfoJson);
                    }
                }

                if(mPagesAnnot.length() > 0) {
                    JSONObject mPageJson = new JSONObject();
                    mPageJson.put("Page", index);
                    mPageJson.put("Annots", mPagesAnnot);
                    return mPageJson;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void parsePageJsonFormFields(JSONObject pageJson, Document document) {
        try {
            int pageIndex = pageJson.optInt("Page");
            if(pageIndex < document.GetPageCount()) {
                Page mPage = document.GetPage(pageIndex);
                if(mPage != null) {
                    mPage.ObjsStart();
                    JSONArray mPageAnnots = pageJson.optJSONArray("Annots");
                    if(mPageAnnots != null) {
                        for(int i = 0 ; i < mPageAnnots.length() ; i++) {
                            JSONObject mAnnotInfo = mPageAnnots.getJSONObject(i);
                            Page.Annotation mAnnotation = mPage.GetAnnot(mAnnotInfo.getInt("Index"));
                            switch (mAnnotation.GetType()) {
                                case 3:
                                    if(!mAnnotInfo.isNull("EditText"))
                                        mAnnotation.SetEditText(mAnnotInfo.getString("EditText"));
                                    break;
                                case 20:
                                    switch (mAnnotation.GetFieldType()) {
                                        case 1: //check box/radio buttons
                                            if(!mAnnotInfo.isNull("CheckStatus")) {
                                                switch(mAnnotInfo.getInt("CheckStatus")) {
                                                    case 0:
                                                        mAnnotation.SetCheckValue(false);
                                                        break;
                                                    case 1:
                                                        mAnnotation.SetCheckValue(true);
                                                        break;
                                                    case 3:
                                                        mAnnotation.SetRadio();
                                                        break;
                                                }
                                            }
                                            break;
                                        case 2: //text field
                                            if(!mAnnotInfo.isNull("EditText"))
                                                mAnnotation.SetEditText(mAnnotInfo.getString("EditText"));
                                            break;
                                        case 3: //combo/list
                                            if(mAnnotation.GetComboItemCount() != -1 && !mAnnotInfo.isNull("ComboItemSel"))
                                                mAnnotation.SetComboItem(mAnnotInfo.getInt("ComboItemSel"));
                                            if(mAnnotation.GetListItemCount() != -1 && !mAnnotInfo.isNull("ListSels")) {
                                                String[] itemsStrs = mAnnotInfo.getString("ListSels").replaceAll("\\[", "").replaceAll("\\]", "").split(",");
                                                int[] items = new int[itemsStrs.length];
                                                for(int j = 0 ; j < itemsStrs.length ; j++)
                                                    items[j] = Integer.parseInt(itemsStrs[j]);
                                                mAnnotation.SetListSels(items);
                                            }
                                            break;
                                    }
                                    break;
                            }
                        }
                    }
                    mPage.Close();
                    document.Save();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void showPDFOutlines(final PDFLayoutView mPdfLayoutView, Context mContext) {
        if(mPdfLayoutView.PDFGetDoc() != null) {
            if(mPdfLayoutView.PDFGetDoc().GetOutlines() == null) {
                Toast.makeText(mContext, R.string.no_pdf_outlines, Toast.LENGTH_SHORT).show();
                return;
            }

            LinearLayout layout = (LinearLayout) LayoutInflater.from(mContext).inflate(R.layout.dlg_outline, null);
            final OutlineList mOutlineList = (OutlineList) layout.findViewById(R.id.lst_outline);
            mOutlineList.SetOutlines(mPdfLayoutView.PDFGetDoc());
            final AlertDialog mAlertDialog = new AlertDialog.Builder(mContext)
                    .setTitle(R.string.pdf_outline)
                    .setView(layout)
                    .show();
            AdapterView.OnItemClickListener item_clk = new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                    OutlineListAdt.outline_ui_item item = mOutlineList.GetItem(i);
                    mPdfLayoutView.PDFGotoPage(item.GetPageNO());
                    mAlertDialog.dismiss();
                }
            };
            mOutlineList.setOnItemClickListener(item_clk);
        }
    }
}
