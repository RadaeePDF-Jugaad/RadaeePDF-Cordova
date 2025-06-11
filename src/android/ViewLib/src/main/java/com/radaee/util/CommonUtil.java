package com.radaee.util;

import android.app.AlertDialog;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Environment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.annotation.ColorRes;
import androidx.annotation.DrawableRes;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.pdf.PageContent;
import com.radaee.pdf.ResImage;
import com.radaee.pdf.adv.Obj;
import com.radaee.pdf.adv.Ref;
import com.radaee.view.ILayoutView;
import com.radaee.viewlib.R;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.Locale;

/**
 * @author Davide created on 15/01/2016.
 *
 *         modified on 23/11/2016
 *         Adding new utils methods.
 */
public class CommonUtil {

    private static final String TAG = "RadaeeCommonUtil";
    private static final int CACHE_LIMIT = 1024;

    public static boolean nigthMode(Context context) {

        boolean bNight;

        int nightModeFlags = context.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;

        switch(nightModeFlags)
        {
            case Configuration.UI_MODE_NIGHT_YES:
                bNight = true;
                break;
            case Configuration.UI_MODE_NIGHT_NO:
                bNight = false;
                break;
            case Configuration.UI_MODE_NIGHT_UNDEFINED:
                bNight = false;
                break;
            default:
                bNight = false;
        }
        return bNight;

    }

    public static void copyFiletoExternalStorage(int resourceId, String resourceName, Context context){
        String pathSDCard = Global.tmp_path + "/" + resourceName;
        try{
            InputStream in = context.getResources().openRawResource(resourceId);
            FileOutputStream out = null;
            out = new FileOutputStream(pathSDCard);
            byte[] buff = new byte[1024];
            int read = 0;
            try {
                while ((read = in.read(buff)) > 0) {
                    out.write(buff, 0, read);
                }
            } finally {
                in.close();
                out.close();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public static String getThumbName(String path) {
        try {
            File file = new File(path);
            long lastModifiedDate = file.lastModified();
            return CommonUtil.md5(path + lastModifiedDate);
        } catch (Exception e) {
            return null;
        }
    }

    public static Bitmap loadThumb(File pictureFile) {
        try {
            if (!pictureFile.exists())
                return null;
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            return BitmapFactory.decodeFile(pictureFile.getAbsolutePath(), options);
        } catch (Exception e) {
            return null;
        }
    }

    public static void saveThumb(Bitmap image, File pictureFile) {
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
        if (dir.exists()) { //too many caches
            File files[] = dir.listFiles();
            if (files.length > CACHE_LIMIT)
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
        return md5(input.getBytes());
    }

    public static String md5(byte[] input) {
        final String MD5 = "MD5";
        try {
            // Create MD5 Hash
            MessageDigest digest = java.security.MessageDigest.getInstance(MD5);
            digest.update(input);
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
            if (mPage != null) {
                mPage.ObjsStart();
                JSONArray mPagesAnnot = new JSONArray();
                for (int i = 0; i < mPage.GetAnnotCount(); i++) {
                    Page.Annotation mAnnotation = mPage.GetAnnot(i);
                    if (mAnnotation != null && (mAnnotation.GetType() == 20 || mAnnotation.GetType() == 3)) {
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

                        if (mAnnotation.GetListSels() != null) {
                            int[] items = mAnnotation.GetListSels();
                            if (items.length == 0)
                                mAnnotInfoJson.put("ListSels", "");
                            else {
                                String selValues = "";
                                for (int item : items)
                                    selValues += mAnnotation.GetListItem(item) + ", ";
                                mAnnotInfoJson.put("ListSels", Arrays.toString(items));
                                mAnnotInfoJson.put("ListSelsItems", selValues.substring(0, selValues.lastIndexOf(",")));
                            }
                        }
                        mAnnotInfoJson.put("ListItemCount", mAnnotation.GetListItemCount());

                        mAnnotInfoJson.put("EditText", mAnnotation.GetEditText());
                        mAnnotInfoJson.put("EditType", mAnnotation.GetEditType());
                        mAnnotInfoJson.put("EditTextFormat", mAnnotation.GetFieldFormat());

                        mAnnotInfoJson.put("SignStatus", mAnnotation.GetSignStatus());

                        mAnnotInfoJson.put("ReadOnly", (mAnnotation.IsReadOnly()) ? 1 : 0);
                        mAnnotInfoJson.put("Locked", (mAnnotation.IsLocked()) ? 1 : 0);

                        mPagesAnnot.put(mAnnotInfoJson);
                    }
                }

                if (mPagesAnnot.length() > 0) {
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
            if (pageIndex < document.GetPageCount()) {
                Page mPage = document.GetPage(pageIndex);
                if (mPage != null) {
                    mPage.ObjsStart();
                    JSONArray mPageAnnots = pageJson.optJSONArray("Annots");
                    if (mPageAnnots != null) {
                        for (int i = 0; i < mPageAnnots.length(); i++) {
                            JSONObject mAnnotInfo = mPageAnnots.getJSONObject(i);
                            Page.Annotation mAnnotation = mPage.GetAnnot(mAnnotInfo.getInt("Index"));
                            switch (mAnnotation.GetType()) {
                                case 3:
                                    if (!mAnnotInfo.isNull("EditText"))
                                        mAnnotation.SetEditText(mAnnotInfo.getString("EditText"));
                                    break;
                                case 20:
                                    switch (mAnnotation.GetFieldType()) {
                                        case 1: //check box/radio buttons
                                            if (!mAnnotInfo.isNull("CheckStatus")) {
                                                switch (mAnnotInfo.getInt("CheckStatus")) {
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
                                            if (!mAnnotInfo.isNull("EditText"))
                                                mAnnotation.SetEditText(mAnnotInfo.getString("EditText"));
                                            break;
                                        case 3: //combo/list
                                            if (mAnnotation.GetComboItemCount() != -1 && !mAnnotInfo.isNull("ComboItemSel"))
                                                mAnnotation.SetComboItem(mAnnotInfo.getInt("ComboItemSel"));
                                            if (mAnnotation.GetListItemCount() != -1 && !mAnnotInfo.isNull("ListSels")) {
                                                String[] itemsStrs = mAnnotInfo.getString("ListSels").replaceAll("\\[", "").replaceAll("\\]", "").split(",");
                                                int[] items = new int[itemsStrs.length];
                                                for (int j = 0; j < itemsStrs.length; j++)
                                                    items[j] = Integer.parseInt(itemsStrs[j]);
                                                mAnnotation.SetListSels(items);
                                            }
                                            break;
                                    }
                                    break;
                            }
                            //readonly
                            if(!mAnnotInfo.isNull("ReadOnly"))
                                mAnnotation.SetReadOnly((mAnnotInfo.getInt("ReadOnly") == 1) ? true : false);
                            //locked
                            if(!mAnnotInfo.isNull("Locked"))
                                mAnnotation.SetLocked((mAnnotInfo.getInt("Locked") == 1) ? true : false);
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

    public static void showPDFOutlines(final ILayoutView mPdfLayoutView, Context mContext) {
        if (mPdfLayoutView.PDFGetDoc() != null) {
            if (mPdfLayoutView.PDFGetDoc().GetOutlines() == null) {
                Toast.makeText(mContext, R.string.no_pdf_outlines, Toast.LENGTH_SHORT).show();
                return;
            }

            LinearLayout layout = (LinearLayout) LayoutInflater.from(mContext).inflate(R.layout.dlg_outline, null, false);
            final OutlineList mOutlineList = (OutlineList) layout.findViewById(R.id.lst_outline);
            mOutlineList.SetOutlines(mPdfLayoutView.PDFGetDoc());
            final AlertDialog mAlertDialog = new AlertDialog.Builder(mContext)
                    .setTitle(R.string.pdf_outline)
                    .setView(layout)
                    .show();
            AdapterView.OnItemClickListener item_clk = new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                    OutlineList.OutlineListAdt.outline_ui_item item = mOutlineList.GetItem(i);
                    mPdfLayoutView.PDFGotoPage(item.GetPageNO());
                    mAlertDialog.dismiss();
                }
            };
            mOutlineList.setOnItemClickListener(item_clk);
        }
    }

    static private String m_types[] = new String[]{"null", "boolean", "int", "real", "string", "name", "array", "dictionary", "reference", "stream"};

    static private String get_type_name(int type) {
        if (type >= 0 && type < m_types.length) return m_types[type];
        else return "unknown";
    }

    public static void checkAnnotAdvancedProp(Document mDocument, Page.Annotation annot) {
        if (mDocument == null || !mDocument.IsOpened() || annot == null) return;

        Ref ref = annot.Advance_GetRef();
        if (ref != null) {
            Obj obj = mDocument.Advance_GetObj(ref);
            handleDictionary(obj);
        }
    }

    private static void handleDictionary(Obj obj) {
        try {
            int count = obj.DictGetItemCount();
            for (int cur = 0; cur < count; cur++) {
                String tag = obj.DictGetItemTag(cur);
                Obj item = obj.DictGetItem(cur);
                int type = item.GetType();
                String type_name = get_type_name(type);

                Log.i("--ADV--", "tag:" + cur + "---" + tag + ":" + type_name + " ->");

                if (type == 1) //boolean
                    Log.i("--ADV--", " value = " + item.GetBoolean());
                else if (type == 2) //int
                    Log.i("--ADV--", " value = " + item.GetInt());
                else if (type == 3) //real
                    Log.i("--ADV--", " value = " + item.GetReal());
                else if (type == 4) //string
                    Log.i("--ADV--", " value = " + item.GetTextString());
                else if (type == 5) //name
                    Log.i("--ADV--", " value = " + item.GetName());
                else if (type == 6) { //array
                    int arraycount = item.ArrayGetItemCount();
                    for (int k = 0; k < arraycount; k++) {
                        Obj array_obj = item.ArrayGetItem(k);
                        Log.i("--ADV--", "array item " + k + ": value = " + array_obj.GetReal());
                    }
                } else if (type == 7) //dictionary
                    handleDictionary(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getPageText(Document mDocument, int pageIndex) {
        String mPageText = null;
        try {
            Page mPage = mDocument.GetPage(pageIndex);
            mPage.ObjsStart();
            mPageText = mPage.ObjsGetString(0, mPage.ObjsGetCharCount() - 1);
            mPage.Close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mPageText;
    }

    /**
     * @return DateTime String object<br/>
     * format as (D:YYYYMMDDHHmmSSOHH'mm') where:<br/>
     * YYYY is the year<br/>
     * MM is the month<br/>
     * DD is the day (01–31)<br/>
     * HH is the hour (00–23)<br/>
     * mm is the minute (00–59)<br/>
     * SS is the second (00–59)<br/>
     * O is the relationship of local time to Universal Time (UT), denoted by one of the characters +, −, or Z (see below)<br/>
     * HH followed by ' is the absolute value of the offset from UT in hours (00–23)<br/>
     * mm followed by ' is the absolute value of the offset from UT in minutes (00–59)<br/>
     * more details see PDF-Reference-1.7 section 3.8.3
     */
    public static String getCurrentDate() {
        String datePattern = "yyyyMMddHHmmssZ''";
        String date = new SimpleDateFormat(datePattern, Locale.getDefault()).format(new Date());
        return "D:" + date.substring(0, date.length() - 3) + "'" + date.substring(date.length() - 3);
    }

    /**
     * it is fake sign method(graphic sign only), if you want a real sign feature, please using Annotation.SignField()
     * @param document document object
     * @param field_name field name of unsigned signature field.
     * @param image Bitmap object.
     * @return true or false.
     */
    public static boolean signField(Document document, String field_name, Bitmap image)
    {
        int pcnt = document.GetPageCount();
        for(int pcur = 0; pcur < pcnt; pcur++)//loop all pages
        {
            Page page = document.GetPage(pcur);
            if (page == null) continue;
            page.ObjsStart();
            int acnt = page.GetAnnotCount();
            for(int acur = 0; acur < acnt; acur++)//loop all annotations
            {
                Page.Annotation annot = page.GetAnnot(acur);
                if (annot == null) continue;
                String fname = annot.GetFieldName();
                if (annot.GetFieldType() == 4 && annot.GetSignStatus() == 0 && field_name.compareTo(fname) == 0)//match field name.
                {
                    boolean ret = signField(document, annot, image);
                    page.Close();
                    return ret;
                }
            }
            page.Close();
        }
        return false;//field name not matched.
    }

    /**
     * it is fake sign method(graphic sign only), if you want a real sign feature, please using Annotation.SignField()
     * @param document document object
     * @param annot annotation object of unsigned signature field.
     * @param image Bitmap object.
     * @return true or false.
     */
    public static boolean signField(Document document, Page.Annotation annot, Bitmap image)
    {
        if (document == null || annot == null || image == null) return false;
        if (annot.GetFieldType() != 4 || annot.GetSignStatus() != 0) return false;
        //it must unsigned signature field.
        float[] rect = annot.GetRect();
        float width = rect[2] - rect[0];
        float height = rect[3] - rect[1];
        Document.DocForm form = createImageForm(document, image, width, height);
        return annot.SetIcon("", form);//make fake sign(graphic sign).
    }
    /**
     * create DocForm object from image, and scale image to (width, height)
     * @param document Document object
     * @param image bitmap object.
     * @param width form width
     * @param height form height
     * @return DocForm object.
     */
    public static Document.DocForm createImageForm(Document document, Bitmap image, float width, float height) {
        Document.DocForm form = document.NewForm();
        if (form != null) {
            PageContent content = new PageContent();
            content.Create();
            content.GSSave();

            content.GSSave();
            float originalWidth = image.getWidth(), originalHeight = image.getHeight();
            float scale = height / originalHeight;
            float scaleW = width / originalWidth;
            if (scaleW < scale) scale = scaleW;

            float xTranslation = (width - originalWidth * scale) * 0.5f;
            float yTranslation = (height - originalHeight * scale) * 0.5f;

            Document.DocImage dimg = document.NewImage(image, 0);//Bitmap object for Android must be support matte, that not loss color.
            ResImage rimg = form.AddResImage(dimg);
            Matrix mat = new Matrix(scale * originalWidth, scale * originalHeight, xTranslation, yTranslation);
            content.GSSetMatrix(mat);
            mat.Destroy();
            content.DrawImage(rimg);
            content.GSRestore();

            content.GSRestore();

            form.SetContent(content, 0, 0, width, height);
            content.Destroy();
        }
        return form;
    }

    public static boolean isFieldGraphicallySigned(Page.Annotation signAnnot) {
        if (signAnnot != null) {
            float[] annotRect = signAnnot.GetRect();
            final float annotWidth = annotRect[2] - annotRect[0];
            final float annotHeight = annotRect[3] - annotRect[1];
            Bitmap bitmap = Bitmap.createBitmap((int) annotWidth, (int) annotHeight, Bitmap.Config.ARGB_8888);
            Global.setAnnotTransparency(0x00000000);
            signAnnot.RenderToBmp(bitmap);
            Global.setAnnotTransparency(Global.g_annot_transparency);
            Bitmap emptyBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), bitmap.getConfig());
            boolean empty = bitmap.sameAs(emptyBitmap);
            bitmap.recycle();
            emptyBitmap.recycle();
            return !empty;
        }
        return false;
    }

    public static String renderAnnotToFile(Document document, int pageno, int annotIndex, String renderPath, int bitmapWidth, int bitmapHeight) {
        String result;
        Page page = document.GetPage(pageno);
        if (page != null) {
            page.ObjsStart();
            Page.Annotation signAnnot = page.GetAnnot(annotIndex);
            if (signAnnot != null) {
                if(bitmapHeight == 0 || bitmapWidth == 0) {
                    float[] annotRect = signAnnot.GetRect();
                    bitmapWidth = (int) (annotRect[2] - annotRect[0]);
                    bitmapHeight = (int) (annotRect[3] - annotRect[1]);
                }

                Bitmap bitmap = Bitmap.createBitmap(bitmapWidth, bitmapHeight, Bitmap.Config.ARGB_8888);
                Global.setAnnotTransparency(0x00000000);
                signAnnot.RenderToBmp(bitmap);
                Global.setAnnotTransparency(Global.g_annot_transparency);
                Bitmap emptyBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), bitmap.getConfig());
                if(bitmap.sameAs(emptyBitmap))
                    result = "Empty Annot";
                else {
                    saveThumb(bitmap, new File(renderPath));
                    result = "Annotation rendered successfully";
                }
                bitmap.recycle();
                emptyBitmap.recycle();
            } else result = "Cannot get annotation with the indicated index";
            page.Close();
        } else result = "Cannot get indicated page";

        return result;
    }
}
