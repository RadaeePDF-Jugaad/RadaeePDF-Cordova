package com.radaee.util;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.BMDatabase;
import com.radaee.pdf.Global;
import com.radaee.viewlib.R;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/*
 * Created by Nermeen on 20/06/2017.
 */
@SuppressWarnings({"WeakerAccess", "unused"})
public class BookmarkHandler {

    private static String mDbPath;

    public static String getDbPath() {
        return mDbPath;
    }

    public static void setDbPath(String path) {
        mDbPath = path;
    }

    public static class Bookmark {
        public int page;
        public String bmLabel;

        public Bookmark(int pageno, String label) {
            page = pageno;
            bmLabel = label;
        }
    }

    public enum BookmarkStatus {
        SUCCESS, ALREADY_ADDED, ERROR_UNKNOWN
    }

    private static BMDatabase openOrCreateDB() {
        BMDatabase mBMDatabase = new BMDatabase();
        if(mBMDatabase.OpenOrCreate(TextUtils.isEmpty(mDbPath) ? Global.tmp_path + "/Bookmarks.db" : mDbPath))
            return mBMDatabase;
        return null;
    }

    public static BookmarkStatus addToBookmarks(String pdfPath, int page, String label) {
        return addToBookmarks(pdfPath, new Bookmark(page, label));
    }

    public static BookmarkStatus addToBookmarks(String pdfPath, Bookmark bookmark) {
        try {
            BMDatabase mBMDatabase = openOrCreateDB();
            if(mBMDatabase != null) {
                long recHandle = mBMDatabase.RecOpen(pdfPath);
                if(isBookmarkAlreadyAdded(mBMDatabase, recHandle, bookmark.page))
                    return BookmarkStatus.ALREADY_ADDED;
                boolean result = mBMDatabase.RecItemInsert(recHandle, bookmark.bmLabel, bookmark.page);
                mBMDatabase.RecClose(recHandle);
                mBMDatabase.Close();
                return result ? BookmarkStatus.SUCCESS : BookmarkStatus.ERROR_UNKNOWN;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return BookmarkStatus.ERROR_UNKNOWN;
    }

    public static boolean removeBookmark(int page, String pdfPath) {
        return removeBookmark(new Bookmark(page, ""), pdfPath);
    }

    public static boolean removeBookmark(Bookmark bookmark, String pdfPath) {
        try {
            BMDatabase mBMDatabase = openOrCreateDB();
            if(mBMDatabase != null) {
                long recHandle = mBMDatabase.RecOpen(pdfPath);
                int recCount = mBMDatabase.RecGetCount(recHandle);
                boolean success = false;
                for (int i = 0; i < recCount; i++) {
                    if(mBMDatabase.RecItemGetPage(recHandle, i) == bookmark.page) {
                        success = mBMDatabase.RecItemRemove(recHandle, i);
                        break;
                    }
                }

                mBMDatabase.RecClose(recHandle);
                mBMDatabase.Close();

                return success;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static void showBookmarks(final Context mContext, final String pdfPath, final BookmarkListener bookmarkListener) {
        ProgressDialog progressDialog = ProgressDialog.show(mContext, mContext.getString(R.string.bookmarks),
                mContext.getString(R.string.loading), true, false);
        List<Bookmark> mBookmarks = getBookmarks(pdfPath);
        if(mBookmarks != null && mBookmarks.size() > 0) {
            ListView mBookmarksList = new ListView(mContext);

            final BookmarkAdapter mAdapter = new BookmarkAdapter(mContext, mBookmarks);
            mBookmarksList.setAdapter(mAdapter);

            final AlertDialog mAlertDialog = new AlertDialog.Builder(mContext)
                    .setTitle(R.string.bookmarks)
                    .setView(mBookmarksList)
                    .show();

            mBookmarksList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                    Bookmark bookmark = (Bookmark) adapterView.getItemAtPosition(i);
                    if(bookmark != null && bookmarkListener != null)
                        bookmarkListener.onBookmarkClickedListener(bookmark.page);
                    mAlertDialog.dismiss();
                }
            });
            mBookmarksList.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
                @Override
                public boolean onItemLongClick(AdapterView<?> adapterView, View view, int i, long l) {
                    showPopupMenu(mContext, mAlertDialog, mAdapter, view, i, pdfPath);
                    return true;
                }
            });
        }
        else
            Toast.makeText(mContext, R.string.no_bookmarks, Toast.LENGTH_SHORT).show();
        progressDialog.dismiss();
    }

    public static List<Bookmark> getBookmarks(String pdfPath) {
        BMDatabase mBMDatabase = openOrCreateDB();
        if(mBMDatabase != null) {
            long recHandle = mBMDatabase.RecOpen(pdfPath);
            int recCount = mBMDatabase.RecGetCount(recHandle);
            List<Bookmark> mBookmarks = null;
            if(recCount > 0) {
                mBookmarks = new ArrayList<>();
                for (int i = 0; i < recCount; i++)
                    mBookmarks.add(new Bookmark(mBMDatabase.RecItemGetPage(recHandle, i), mBMDatabase.RecItemGetName(recHandle, i)));
            }

            mBMDatabase.RecClose(recHandle);
            mBMDatabase.Close();

            return mBookmarks;
        }
        return null;
    }

    public static String getBookmarksAsJson(String pdfPath) {
        List<Bookmark> mBookmarks = getBookmarks(pdfPath);
        try {
            if(mBookmarks != null && mBookmarks.size() > 0) {
                JSONArray bookmarksArray = new JSONArray();
                for (Bookmark bookmark : mBookmarks) {
                    JSONObject bookmarkObject = new JSONObject();
                    bookmarkObject.put("Page", bookmark.page);
                    bookmarkObject.put("Label", bookmark.bmLabel);
                    bookmarksArray.put(bookmarkObject);
                }
                return bookmarksArray.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static boolean isBookmarkAlreadyAdded(BMDatabase mBMDatabase, long recHandler, int pageno) {
        int recCount = mBMDatabase.RecGetCount(recHandler);
        for (int i = 0; i < recCount; i++) {
            if(mBMDatabase.RecItemGetPage(recHandler, i) == pageno)
                return true;
        }
        return false;
    }

    private static void showPopupMenu(final Context mContext, final AlertDialog mAlertDialog, final BookmarkAdapter adapterView, final View parent,
                                      final int position, final String pdfPath) {
        View mPopupView = LayoutInflater.from(mContext).inflate(R.layout.bookmark_popup_menu, null);
        final PopupWindow mPopup = new PopupWindow(mPopupView);
        mPopup.setOutsideTouchable(true);
        final float scale = mContext.getResources().getDisplayMetrics().density;
        mPopup.setWidth((int)(100 * scale));
        mPopup.setHeight((int)(50 * scale));
        mPopup.showAsDropDown(parent, (parent.getWidth() - mPopup.getWidth()) / 2, - mPopup.getHeight() / 2);

        mPopupView.findViewById(R.id.delete).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(removeBookmark((Bookmark) adapterView.getItem(position), pdfPath)) {
                    adapterView.removeItem(position);
                    adapterView.notifyDataSetChanged();
                    if(adapterView.getCount() == 0 && mAlertDialog != null)
                        mAlertDialog.dismiss();
                } else
                    Toast.makeText(mContext, R.string.bookmark_remove_error, Toast.LENGTH_SHORT).show();
                mPopup.dismiss();
            }
        });
    }

    public interface BookmarkListener {
        void onBookmarkClickedListener(int pageno);
    }

    public static class BookmarkAdapter extends BaseAdapter {

        Context mContext;
        List<Bookmark> mBookmarks;

        BookmarkAdapter(Context context, List<Bookmark> bookmarks) {
            mContext = context;
            mBookmarks = bookmarks;
        }

        @Override
        public int getCount() {
            return mBookmarks != null ? mBookmarks.size() : 0;
        }

        @Override
        public Object getItem(int i) {
            return mBookmarks != null ? mBookmarks.get(i) : null;
        }

        @SuppressWarnings("SuspiciousMethodCalls")
        @Override
        public long getItemId(int i) {
            return mBookmarks != null && getItem(i) != null ? mBookmarks.indexOf(getItem(i)) : 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup viewGroup) {
            ViewHolder holder;

            if (convertView == null) {
                convertView = ((LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.bookmark_row,
                        viewGroup, false);
                holder = new ViewHolder();
                holder.label = (TextView) convertView.findViewById(R.id.label);
                convertView.setTag(holder);
            } else
                holder = (ViewHolder) convertView.getTag();

            Bookmark bookmark = (Bookmark) getItem(position);

            holder.label.setText(bookmark.bmLabel);

            return convertView;
        }

        void removeItem(int position) {
            mBookmarks.remove(position);
        }

        private class ViewHolder {
            TextView label;
        }
    }
}