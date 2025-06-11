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
import android.os.Looper;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.radaee.annotui.UIAnnotMenu;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.pdf.Page.Annotation;
import com.radaee.util.PDFAssetStream;
import com.radaee.util.PDFHttpStream;
import com.radaee.util.PDFThumbView;
import com.radaee.util.RDRecent;
import com.radaee.util.RadaeePluginCallback;
import com.radaee.view.ILayoutView;
import com.radaee.viewlib.R;

import java.io.File;
import java.io.FileOutputStream;

public class PDFViewAct extends Activity implements ILayoutView.PDFLayoutListener {
    private String mFindQuery = "";
    private boolean mDidShowReader = false;

    static public Document ms_tran_doc;
    static public String ms_tran_path;
    private PDFAssetStream m_asset_stream = null;
    private PDFHttpStream m_http_stream = null;
    private Document m_doc = null;
    private String m_path = null;
    private RelativeLayout m_layout = null;
    private PDFLayoutView m_view = null;
    private PDFViewController m_controller = null;
    private boolean m_save_doc_to_bundle = false;

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
                m_save_doc_to_bundle = false;
                OpenTask task = new OpenTask();
                task.execute();
                break;
            default://unknown error
                onFail(getString(R.string.failed_unknown));
                break;
        }
    }

    private class OpenTask extends AsyncTask<Void, Integer, Integer> {
        private ProgressDialog dlg;
        private Handler handler;
        private Runnable runnable;

        @Override
        protected Integer doInBackground(Void... voids) {
            m_doc.GetPagesMaxSize();//it may spend much time for first invoking this method.
            return null;
        }

        @Override
        protected void onPreExecute() {
            handler = new Handler(Looper.getMainLooper());
            runnable = new Runnable() {
                public void run() {
                    dlg = ProgressDialog.show(PDFViewAct.this, getString(R.string.please_wait), getString(R.string.loading_pdf), true);
                }
            };
            handler.postDelayed(runnable, 1000);//delay 1 second to display progress dialog.
        }

        @Override
        protected void onPostExecute(Integer integer) {
            m_view.PDFOpen(m_doc, PDFViewAct.this);
            m_view.setAnnotMenu(new UIAnnotMenu(m_layout));
            m_view.setReadOnly(getIntent().getBooleanExtra("READ_ONLY", false));
            m_controller = new PDFViewController(m_layout, m_view, m_path,m_asset_stream != null || m_http_stream != null);
            m_controller.SetPagesListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent();
                    intent.setClass(PDFViewAct.this, PDFPagesAct.class);
                    PDFPagesAct.ms_tran_doc = m_doc;
                    startActivityForResult(intent, 10000);
                }
            });
            if (dlg != null) dlg.dismiss();
            else handler.removeCallbacks(runnable);

            int gotoPage = getIntent().getIntExtra("GOTO_PAGE", -1);
            if (gotoPage > 0) m_view.PDFGotoPage(gotoPage);
        }
    }

    private void init_cordova()
    {
        RadaeePluginCallback.getInstance().setActivityListener(new RadaeePluginCallback.PDFActivityListener() {
            @Override
            public void closeReader() {
                onClose(false);
                finish();
            }
        });
        RadaeePluginCallback.getInstance().willShowReader();
    }
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
        show_progress = true;
        init_cordova();

        if (!Global.g_cache_enable)
            m_layout.findViewById(R.id.progress).setVisibility(View.GONE);

        Intent intent = getIntent();
        String bmp_format = intent.getStringExtra("BMPFormat");
        if (bmp_format != null) {
            if (bmp_format.compareTo("RGB_565") == 0)
                m_view.PDFSetBmpFormat(Bitmap.Config.RGB_565);
            else if (bmp_format.compareTo("ARGB_4444") == 0)
                m_view.PDFSetBmpFormat(Bitmap.Config.ARGB_4444);
        }
        if (ms_tran_doc != null)//open from browser UI.
        {
            m_doc = ms_tran_doc;
            m_path = ms_tran_path;
            ms_tran_doc = null;
            ms_tran_path = null;
            m_save_doc_to_bundle = true;
            OpenTask task = new OpenTask();
            task.execute();
        }
        else
        {
            String pdf_asset = intent.getStringExtra("PDFAsset");
            String pdf_path = intent.getStringExtra("PDFPath");
            String pdf_pswd = intent.getStringExtra("PDFPswd");
            String pdf_http = intent.getStringExtra("PDFHttp");
            if (!TextUtils.isEmpty(pdf_http))//open from url
            {
                //PDFHttpStream.open sometimes spend too long time, so, we open url in backing thread.
                new Thread(){
                    @Override
                    public void run() {
                        m_http_stream = new PDFHttpStream();
                        m_http_stream.open(pdf_http);
                        //after http link opened, open PDF in UI thread.
                        m_layout.post(new Runnable() {
                            @Override
                            public void run() {
                                m_doc = new Document();
                                int ret = m_doc.OpenStream(m_http_stream, pdf_pswd);
                                ProcessOpenResult(ret);
                            }
                        });
                    }
                }.start();
            }
            else if (!TextUtils.isEmpty(pdf_asset))//open from assets(readonly)
            {
                m_asset_stream = new PDFAssetStream();
                m_asset_stream.open(getAssets(), pdf_asset);
                m_doc = new Document();
                m_path = pdf_asset;
                int ret = m_doc.OpenStream(m_asset_stream, pdf_pswd);
                ProcessOpenResult(ret);
            }
            else if (!TextUtils.isEmpty(pdf_path))//open from path.
            {
                m_doc = new Document();
                int ret = m_doc.Open(pdf_path, pdf_pswd);
                m_path = pdf_path;
                ProcessOpenResult(ret);
            }
            else//this shall never happen.
            {
                m_asset_stream = new PDFAssetStream();
                m_asset_stream.open(getAssets(), "eula.pdf");
                m_doc = new Document();
                m_path = pdf_asset;
                int ret = m_doc.OpenStream(m_asset_stream, pdf_pswd);
                ProcessOpenResult(ret);
            }
        }
        setContentView(m_layout);
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        m_view.BundleSavePos(savedInstanceState);
        if (m_save_doc_to_bundle && m_doc != null) {
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
            m_controller = new PDFViewController(m_layout, m_view, m_path,m_asset_stream != null || m_http_stream != null);
            m_controller.SetPagesListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent();
                    intent.setClass(PDFViewAct.this, PDFPagesAct.class);
                    PDFPagesAct.ms_tran_doc = m_doc;
                    startActivityForResult(intent, 10000);
                }
            });
            m_save_doc_to_bundle = true;
        }
        m_view.BundleRestorePos(savedInstanceState);
    }

    @Override
    public void onBackPressed() {
        if (m_controller == null || m_controller.OnBackPressed())
            onClose(true);
    }

    private void onClose(final boolean onBackPressed) {
        if (m_path != null && !m_path.isEmpty() && m_asset_stream == null && m_http_stream == null) {
            RDRecent recent = new RDRecent(this);
            recent.insert(m_path, m_view.PDFGetPos(0, 0).pageno, m_view.PDFGetView());
            recent.Close();
        }
        if (m_controller == null) return;
        if (m_controller.getFileState() == PDFViewController.MODIFIED_NOT_SAVED) {
            if (getIntent().getBooleanExtra("AUTOMATIC_SAVE", false) || Global.g_auto_save_doc) {
                if (m_controller != null) m_controller.savePDF();
                if(onBackPressed) super.onBackPressed();
            } else {
                new AlertDialog.Builder(this).setTitle(R.string.exiting)
                        .setMessage(R.string.save_msg).setPositiveButton(R.string.yes, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (m_controller != null) m_controller.savePDF();
                        if(onBackPressed) PDFViewAct.super.onBackPressed();
                    }
                }).setNegativeButton(R.string.no, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if(onBackPressed) PDFViewAct.super.onBackPressed();
                    }
                }).show();
            }
        } else if(onBackPressed) super.onBackPressed();
    }

    @SuppressLint("InlinedApi")
    @Override
    protected void onDestroy() {
        RadaeePluginCallback.getInstance().willCloseReader();

        final PDFViewController vctrl = m_controller;
        final Document doc = m_doc;
        final PDFLayoutView view = m_view;
        final PDFAssetStream astr = m_asset_stream;
        final PDFHttpStream hstr = m_http_stream;
        m_controller = null;
        m_doc = null;
        m_view = null;
        m_asset_stream = null;
        m_http_stream = null;
        view.PDFCloseOnUI();
        new Thread(){
            @Override
            public void run() {
                if (vctrl != null) vctrl.onDestroy();
                if (view != null) view.PDFClose();
                if (doc != null) doc.Close();
                if (astr != null) astr.close();
                if (hstr != null) hstr.close();
                Global.RemoveTmp();
                synchronized (PDFViewAct.this) { PDFViewAct.this.notify(); }
            }
        }.start();
        synchronized (this)
        {
            try { wait(1500); }
            catch(Exception ignored) { }
        }
        super.onDestroy();
        RadaeePluginCallback.getInstance().didCloseReader();
    }

    @Override
    public void OnPDFPageModified(int pageno) {
        if (m_controller != null) m_controller.onPageModified(pageno);
    }

    private int m_cur_page = 0;
    @Override
    public void OnPDFPageChanged(int pageno)
    {
        m_cur_page = pageno;
        if (m_controller != null)
            m_controller.OnPageChanged(pageno);
        RadaeePluginCallback.getInstance().didChangePage(pageno);
    }

    @Override
    public void OnPDFAnnotTapped(int pageno, Annotation annot) {
        if (annot != null) {
            RadaeePluginCallback.getInstance().onAnnotTapped(annot);
            if (!m_view.PDFCanSave() && annot.GetType() != 2)
                return;
        }
        if (m_controller != null)
            m_controller.OnAnnotTapped(pageno, annot);

    }

    @Override
    public void OnPDFBlankTapped(int pageno) {
        if (m_controller != null)
            m_controller.OnBlankTapped();
        RadaeePluginCallback.getInstance().onBlankTapped(pageno);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if(requestCode != 10000) return;
        if(resultCode != 1) return;

        boolean[] removal = data.getBooleanArrayExtra("removal");
        int[] rotate = data.getIntArrayExtra("rotate");
        if (removal == null || rotate == null) return;

        PDFThumbView thumb = m_controller.GetThumbView();
        m_view.PDFSaveView();
        thumb.thumbSave();

        Document doc = m_view.PDFGetDoc();

        int pcur = removal.length;
        while(pcur > 0)
        {
            pcur--;
            if(removal[pcur])
                doc.RemovePage(pcur);
            else if((rotate[pcur] >> 16) !=  (rotate[pcur] & 0xFFFF))
                doc.SetPageRotate(pcur, rotate[pcur] & 0xFFFF);
        }
        thumb.thumbRestore();
        m_view.PDFRestoreView();
        OnPDFPageModified(0);//set modified status.
    }

    @Override
    public void OnPDFSelectEnd(String text) {
        LinearLayout layout = (LinearLayout) LayoutInflater.from(this).inflate(R.layout.dlg_text, null);
        final RadioGroup rad_group = (RadioGroup) layout.findViewById(R.id.rad_group);
        final String sel_text = text;

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
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
    public void OnPDFOpenRendition(String path) {
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
    public boolean OnPDFDoubleTapped(int pageno, float x, float y) {
        float mCurZoomLevel = m_view.PDFGetZoom();
        if (m_view.PDFGetScale() <= m_view.PDFGetMinScale())
            Global.g_zoom_step = 1;
        if ((mCurZoomLevel > Global.g_layout_zoom_level && Global.g_zoom_step > 0) ||
                (mCurZoomLevel == 1 && Global.g_zoom_step < 0)) //reverse zoom step
            Global.g_zoom_step *= -1;

        m_view.PDFSetZoom((int) x, (int) y, m_view.PDFGetPos((int) x, (int) y), mCurZoomLevel + Global.g_zoom_step);
        RadaeePluginCallback.getInstance().onDoubleTapped(pageno, x, y);
        return true;
    }

    @Override
    public void OnPDFLongPressed(int pageno, float x, float y) {
        RadaeePluginCallback.getInstance().onLongPressed(pageno, x, y);
    }

    private boolean show_progress = true;
    @Override
    public void OnPDFPageRendered(ILayoutView.IVPage vpage) {
        if (!mDidShowReader) {
            RadaeePluginCallback.getInstance().didShowReader();
            mDidShowReader = true;
        }
        if (show_progress) {
            findViewById(R.id.progress).setVisibility(View.GONE);
            show_progress = false;
        }
    }

    @Override
    public void OnPDFSearchFinished(boolean found) {
        if (!mFindQuery.equals(m_controller.getFindQuery())) {
            mFindQuery = m_controller.getFindQuery();
            RadaeePluginCallback.getInstance().didSearchTerm(mFindQuery, found);
        }
    }

    @Override
    public void OnPDFPageDisplayed(Canvas canvas, ILayoutView.IVPage vpage) {
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
            return m_cur_page;
        return -1;
    }

    public void imageFromPage(int index, float[] rect, float scale) {
        // Hide the annotations before render method (it's necessary to avoid the annotation render)
        Global.hideAnnots(true);

        // Get the page
        Page page = m_doc.GetPage(index);

        // Set the rect size
        float w = (rect[2] - rect[0]) * scale;
        float h = (rect[3] - rect[1]) * scale;

        // Draw the Bitmap
        Bitmap bmp;
        bmp = Bitmap.createBitmap((int)w, (int)h, Bitmap.Config.ARGB_8888);
        Matrix mat = new Matrix(scale,-scale, -(rect[0] * scale), (rect[1] * scale) + h);
        page.RenderPrepare(bmp);
        page.RenderToBmp(bmp, mat);

        // Clean
        mat.Destroy();
        page.Close();

        // Show annotations
        Global.hideAnnots(false);

        // Write the image file
        try {
            FileOutputStream fo = new FileOutputStream("/sdcard/000_bitmap.jpg");
            bmp.compress(Bitmap.CompressFormat.JPEG, 75, fo);
            fo.close();
            bmp.recycle();
        }
        catch (Exception ignored)
        {
        }
    }
}