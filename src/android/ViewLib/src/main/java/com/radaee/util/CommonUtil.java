package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.radaee.pdf.Page;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * @author Davide created on 15/01/2016.
 */
public class CommonUtil {

    static final String TAG = "RadaeeCommonUtil";
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

    static Bitmap loadThumb(Context context, String thumbName) {
        if(thumbName == null || thumbName.length() <= 0) return null;
        File pictureFile = getOutputMediaFile(context, thumbName);
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            if(pictureFile != null)
                return BitmapFactory.decodeFile(pictureFile.getAbsolutePath(), options);
        } catch (Exception e) {
            e.getMessage();
        }
        return null;
    }
    static void saveThumb(Context context, String thumbName, Bitmap image)
    {
        if(thumbName == null || thumbName.length() <= 0) return;

        File pictureFile = getOutputMediaFile(context, thumbName);
        File dir = new File(context.getCacheDir() + "/thumbnails");
        if(dir.exists())//too many caches
        {
            File files[] = dir.listFiles();
            if(files.length > CACHE_LIMIT)
                files[0].deleteOnExit();
        }
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

    private static File getOutputMediaFile(Context context, String thumbName) {
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

                        mAnnotInfoJson.put("ComboItemSel", mAnnotation.GetComboItemSel() == -1 ? mAnnotation.GetComboItemSel() :
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
                                mAnnotInfoJson.put("ListSels", selValues.substring(0, selValues.lastIndexOf(",")));
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
}
