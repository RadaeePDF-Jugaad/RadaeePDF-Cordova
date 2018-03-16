package com.radaee.reader;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Page.Annotation;
import com.radaee.reader.PDFLayoutView.PDFLayoutListener;
import com.radaee.util.PDFAssetStream;
import com.radaee.util.PDFHttpStream;
import com.radaee.util.RadaeePluginCallback;
import com.radaee.view.PDFLayout;
import com.radaee.view.VPage;
import com.radaee.viewlib.R;

public class PDFViewAct extends Activity implements PDFLayoutListener {
    private String mFindQuery = "";
    private boolean mDidShowReader = false;

    static public Document ms_tran_doc;
    private PDFAssetStream m_asset_stream = null;
    private PDFHttpStream m_http_stream = null;
    private Document m_doc = null;
    private RelativeLayout m_layout = null;
    private PDFLayoutView m_view = null;
    private PDFViewController m_controller = null;
    private boolean need_save_doc = false;

    private void onFail(String msg)//treat open failed.
    {
        m_doc.Close();
        m_doc = null;
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
        finish();
    }

    private void ProcessOpenResult(int ret) {
        switch (ret) {
            case -1://need input password
                onFail(getString(R.string.failed_invalid_password));
                break;
            case -2://unknown encryption
                onFail(getString(R.string.failed_encryption));
                break;
            case -3://damaged or invalid format
                onFail(getString(R.string.failed_invalid_format));
                break;
            case -10://access denied or invalid file path
                onFail(getString(R.string.failed_invalid_path));
                break;
            case 0://succeeded, and continue
                OpenTask task = new OpenTask(false);
                task.execute();
                break;
            default://unknown error
                onFail(getString(R.string.failed_unknown));
                break;
        }
    }

    private class MyPDFFontDel implements Document.PDFFontDelegate {
        @Override
        public String GetExtFont(String collection, String fname, int flag, int[] ret_flags) {
            Log.i("ExtFont", fname);
            return null;
        }
    }

    private class OpenTask extends AsyncTask<Void, Integer, Integer> {
        private boolean need_save;
        private ProgressDialog dlg;
        private Handler handler;
        private Runnable runable;

        OpenTask(boolean need_save) {
            this.need_save = need_save;
        }

        @Override
        protected Integer doInBackground(Void... voids) {
            m_doc.GetPagesMaxSize();//it may spend much time for first invoking this method.
            return null;
        }

        @Override
        protected void onPreExecute() {
            handler = new Handler();
            runable = new Runnable() {
                public void run() {
                    dlg = ProgressDialog.show(PDFViewAct.this, getString(R.string.please_wait), getString(R.string.loading_pdf), true);
                }
            };
            handler.postDelayed(runable, 1000);//delay 1 second to display progress dialog.
        }

        @Override
        protected void onPostExecute(Integer integer) {
            m_view.PDFOpen(m_doc, PDFViewAct.this);
            m_view.setReadOnly(getIntent().getBooleanExtra("READ_ONLY", false));
            m_controller = new PDFViewController(m_layout, m_view);
            need_save_doc = need_save;
            if (dlg != null)
                dlg.dismiss();
            else
                handler.removeCallbacks(runable);

            int gotoPage = getIntent().getIntExtra("GOTO_PAGE", -1);
            if (gotoPage > 0)
                m_view.PDFGotoPage(gotoPage);
        }
    }

    private MyPDFFontDel m_font_del = new MyPDFFontDel();

    @SuppressLint("InlinedApi")
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //plz set this line to Activity in AndroidManifes.xml:
        //    android:configChanges="orientation|keyboardHidden|screenSize"
        //otherwise, APP shall destroy this Activity and re-create a new Activity when rotate.
        Global.Init(this);
        m_layout = (RelativeLayout) LayoutInflater.from(this).inflate(R.layout.pdf_layout, null);
        m_view = (PDFLayoutView) m_layout.findViewById(R.id.pdf_view);

        RadaeePluginCallback.getInstance().willShowReader();
        if (!Global.cacheEnabled)
            m_layout.findViewById(R.id.progress).setVisibility(View.GONE);

        Intent intent = getIntent();
        String bmp_format = intent.getStringExtra("BMPFormat");
        if (bmp_format != null) {
            if (bmp_format.compareTo("RGB_565") == 0)
                m_view.PDFSetBmpFormat(Bitmap.Config.RGB_565);
            else if (bmp_format.compareTo("ARGB_4444") == 0)
                m_view.PDFSetBmpFormat(Bitmap.Config.ARGB_4444);
        }
        if (ms_tran_doc != null) {
            m_doc = ms_tran_doc;
            ms_tran_doc = null;
            //m_doc.SetCache(String.format("%s/temp%08x.dat", Global.tmp_path, m_tmp_index));//set temporary cache for editing.
            //m_tmp_index++;
            OpenTask task = new OpenTask(true);
            task.execute();
            /*
            m_view.PDFOpen(m_doc, this);
    		m_controller = new PDFViewController(m_layout, m_view);
    		need_save_doc = true;
    		*/
        } else {
            String pdf_asset = intent.getStringExtra("PDFAsset");
            String pdf_path = intent.getStringExtra("PDFPath");
            String pdf_pswd = intent.getStringExtra("PDFPswd");
            String pdf_http = intent.getStringExtra("PDFHttp");
            if (!TextUtils.isEmpty(pdf_http)) {
                m_http_stream = new PDFHttpStream();
                m_http_stream.open(pdf_http);
                m_doc = new Document();
                int ret = m_doc.OpenStream(m_http_stream, pdf_pswd);
                /*
                Page page = m_doc.GetPage(0);
                Bitmap bmp;
                bmp = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888);
                Matrix mat = new Matrix(0.5f, 0.5f, 0, 0);
                page.RenderToBmp(bmp, mat);
                try {
                    FileOutputStream fo = new FileOutputStream("/sdcard/111.jpg");
                    bmp.compress(Bitmap.CompressFormat.JPEG, 75, fo);
                    fo.close();
                    bmp.recycle();
                }
                catch (Exception e)
                {
                }
                */
                ProcessOpenResult(ret);
            } else if (!TextUtils.isEmpty(pdf_asset)) {
                m_asset_stream = new PDFAssetStream();
                m_asset_stream.open(getAssets(), pdf_asset);
                m_doc = new Document();
                int ret = m_doc.OpenStream(m_asset_stream, pdf_pswd);

                ProcessOpenResult(ret);
            } else if (!TextUtils.isEmpty(pdf_path)) {
                m_doc = new Document();
                int ret = m_doc.Open(pdf_path, pdf_pswd);
                //m_doc.SetCache(String.format("%s/temp%08x.dat", Global.tmp_path, m_tmp_index));//set temporary cache for editing.
                //m_tmp_index++;
                //m_doc.SetFontDel(m_font_del);
                ProcessOpenResult(ret);
            }
        }
        setContentView(m_layout);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        m_controller.onConfigChanged();
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (m_doc == null)
            m_doc = m_view.PDFGetDoc();
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        m_view.BundleSavePos(savedInstanceState);
        if (need_save_doc && m_doc != null) {
            Document.BundleSave(savedInstanceState, m_doc);//save Document object
            m_doc = null;
        }
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        if (m_doc == null) {
            m_doc = Document.BundleRestore(savedInstanceState);//restore Document object
            m_view.PDFOpen(m_doc, this);
            m_controller = new PDFViewController(m_layout, m_view);
            need_save_doc = true;
        }
        m_view.BundleRestorePos(savedInstanceState);
    }

    @Override
    public void onBackPressed() {
        if (m_controller == null || m_controller.OnBackPressed()) {
            if (getFileState() == PDFViewController.MODIFIED_NOT_SAVED) {
                if (getIntent().getBooleanExtra("AUTOMATIC_SAVE", false)) {
                    m_controller.savePDF();
                    super.onBackPressed();
                } else {
                    TextView txtView = new TextView(this);
                    txtView.setText(R.string.save_msg);
                    new AlertDialog.Builder(this).setTitle(R.string.exiting).setView(
                            txtView).setPositiveButton(R.string.yes, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            m_controller.savePDF();
                            PDFViewAct.super.onBackPressed();
                        }
                    }).setNegativeButton(R.string.no, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            PDFViewAct.super.onBackPressed();
                        }
                    }).show();
                }
            } else super.onBackPressed();
        }
    }

    @SuppressLint("InlinedApi")
    @Override
    protected void onDestroy() {
        RadaeePluginCallback.getInstance().willCloseReader();

        if (m_controller != null)
            m_controller.onDestroy();
        if (m_doc != null) {
            m_view.PDFClose();
            m_doc.Close();
            m_doc = null;
        }
        if (m_asset_stream != null) {
            m_asset_stream.close();
            m_asset_stream = null;
        }
        if (m_http_stream != null) {
            m_http_stream.close();
            m_http_stream = null;
        }
        Global.RemoveTmp();
        super.onDestroy();

        RadaeePluginCallback.getInstance().didCloseReader();
    }

    @Override
    public void OnPDFPageModified(int pageno) {
        if (m_controller != null) m_controller.onPageModified(pageno);
    }

    @Override
    public void OnPDFPageChanged(int pageno) {
        if (m_controller != null)
            m_controller.OnPageChanged(pageno);
        RadaeePluginCallback.getInstance().didChangePage(pageno);
    }

    @Override
    public void OnPDFAnnotTapped(VPage vpage, Annotation annot) {
        if (m_controller != null)
            m_controller.OnAnnotTapped(annot);
        if (annot != null)
            RadaeePluginCallback.getInstance().onAnnotTapped(annot);
    }

    @Override
    public void OnPDFBlankTapped() {
        if (m_controller != null)
            m_controller.OnBlankTapped();
        RadaeePluginCallback.getInstance().onBlankTapped(m_view.PDFGetCurrPage());
    }

    @Override
    public void OnPDFSelectEnd(String text) {
        LinearLayout layout = (LinearLayout) LayoutInflater.from(this).inflate(R.layout.dlg_text, null);
        final RadioGroup rad_group = (RadioGroup) layout.findViewById(R.id.rad_group);
        final String sel_text = text;

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @SuppressLint("NewApi")
            public void onClick(DialogInterface dialog, int which) {
                if (rad_group.getCheckedRadioButtonId() == R.id.rad_copy) {
                    android.content.ClipboardManager clipboard = (android.content.ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
                    android.content.ClipData clip = android.content.ClipData.newPlainText("Radaee", sel_text);
                    clipboard.setPrimaryClip(clip);
                    Toast.makeText(PDFViewAct.this, getString(R.string.copy_text, sel_text), Toast.LENGTH_SHORT).show();
                } else if (m_view.PDFCanSave()) {
                    boolean ret = false;
                    if (rad_group.getCheckedRadioButtonId() == R.id.rad_highlight)
                        ret = m_view.PDFSetSelMarkup(0);
                    else if (rad_group.getCheckedRadioButtonId() == R.id.rad_underline)
                        ret = m_view.PDFSetSelMarkup(1);
                    else if (rad_group.getCheckedRadioButtonId() == R.id.rad_strikeout)
                        ret = m_view.PDFSetSelMarkup(2);
                    else if (rad_group.getCheckedRadioButtonId() == R.id.rad_squiggly)
                        ret = m_view.PDFSetSelMarkup(4);
                    if (!ret)
                        Toast.makeText(PDFViewAct.this, R.string.annotation_failed, Toast.LENGTH_SHORT).show();
                } else
                    Toast.makeText(PDFViewAct.this, R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
                dialog.dismiss();
                if (m_controller != null)
                    m_controller.OnSelectEnd();
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        builder.setTitle(R.string.process_selected_text);
        builder.setCancelable(false);
        builder.setView(layout);
        AlertDialog dlg = builder.create();
        dlg.show();
    }

    @Override
    public void OnPDFOpenURI(String uri) {
        try {
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            Uri content_url = Uri.parse(uri);
            intent.setData(content_url);
            startActivity(intent);
        } catch (Exception e) {
            Toast.makeText(PDFViewAct.this, getString(R.string.todo_open_url) + uri, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void OnPDFOpenJS(String js) {
        Toast.makeText(PDFViewAct.this, R.string.todo_java_script, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void OnPDFOpenMovie(String path) {
        Toast.makeText(PDFViewAct.this, R.string.todo_play_movie, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void OnPDFOpenSound(int[] paras, String path) {
        Toast.makeText(PDFViewAct.this, R.string.todo_play_sound, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void OnPDFOpenAttachment(String path) {
        Toast.makeText(PDFViewAct.this, R.string.todo_attachment, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void OnPDFOpen3D(String path) {
        Toast.makeText(PDFViewAct.this, R.string.todo_3d, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void OnPDFZoomStart() {
    }

    @Override
    public void OnPDFZoomEnd() {
    }

    @Override
    public boolean OnPDFDoubleTapped(PDFLayout layout, float x, float y) {
        float mCurZoomLevel = layout.vGetZoom();
        if (m_view.PDFGetScale() <= m_view.PDFGetMinScale())
            Global.zoomStep = 1;
        if ((mCurZoomLevel > Global.zoomLevel && Global.zoomStep > 0) ||
                (mCurZoomLevel == 1 && Global.zoomStep < 0)) //reverse zoom step
            Global.zoomStep *= -1;

        layout.vZoomSet((int) x, (int) y, layout.vGetPos((int) x, (int) y), mCurZoomLevel + Global.zoomStep);
        RadaeePluginCallback.getInstance().onDoubleTapped(m_view.PDFGetCurrPage(), x, y);
        return true;
    }

    @Override
    public void OnPDFLongPressed(PDFLayout layout, float x, float y) {
        RadaeePluginCallback.getInstance().onLongPressed(m_view.PDFGetCurrPage(), x, y);
    }

    @Override
    public void onPDFPageRendered(int pageno) {
        if (!mDidShowReader) {
            RadaeePluginCallback.getInstance().didShowReader();
            mDidShowReader = true;
        }
    }

    @Override
    public void onPDFCacheRendered(int pageno) {
        findViewById(R.id.progress).setVisibility(View.GONE);
    }

    @Override
    public void onPDFSearchFinished(boolean found) {
        if (!mFindQuery.equals(m_controller.getFindQuery())) {
            mFindQuery = m_controller.getFindQuery();
            RadaeePluginCallback.getInstance().didSearchTerm(mFindQuery, found);
        }
    }

    @Override
    public void onPDFPageDisplayed(Canvas canvas, VPage vpage) {
    }

    /**
     * To get the current file state.
     *
     * @return a string that contains one of the following values:
     * Not modified
     * Modified but not saved
     * Modified and saved
     */
    public static int getFileState() {
        return PDFViewController.getFileState();
    }

    /**
     * returns current rendered page.
     *
     * @return current rendered page, -1 otherwise
     */
    public int getCurrentPage() {
        if (m_view != null)
            return m_view.PDFGetCurrPage();
        return -1;
    }
}