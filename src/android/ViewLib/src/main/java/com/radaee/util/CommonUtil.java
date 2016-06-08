package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Created by EMANUELE on 15/01/2016.
 */
public class CommonUtil {

    public static final String TAG = "Save";
    private static final int CACHE_LIMIT = 1024;

    public static String getThumbName(String path)
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

    public static Bitmap loadThumb(Context context, String thumbName) {
        if(thumbName == null || thumbName.length() <= 0) return null;
        File pictureFile = getOutputMediaFile(context, thumbName);
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            Bitmap bitmap = BitmapFactory.decodeFile(pictureFile.getAbsolutePath(), options);
            return bitmap;
        } catch (Exception e) {
            return null;
        }
    }
    public static void saveThumb(Context context, String thumbName, Bitmap image)
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
            File mediaFile = new File(mediaStorageDir.getPath() + File.separator + mImageName);
            return mediaFile;
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
}
