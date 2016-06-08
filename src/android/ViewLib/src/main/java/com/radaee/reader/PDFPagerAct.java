package com.radaee.reader;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.util.PDFAssetStream;
import com.radaee.util.PDFHttpStream;
import com.radaee.view.PDFViewPager;
import com.radaee.viewlib.R;

import java.util.Locale;

/*
 * Created by radaee on 2015/5/14.
 */
public class PDFPagerAct extends Activity
{
    private Document m_doc;
    private PDFAssetStream m_asset_stream;
    private PDFHttpStream m_http_stream;
    private PDFViewPager m_pager;
    static private int m_tmp_index = 0;
    RelativeLayout m_layout;
    private void onFail(String msg)//treat open failed.
    {
        m_doc.Close();
        m_doc = null;
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
        finish();
    }
    private final void ProcessOpenResult(int ret)
    {
        switch( ret )
        {
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
                m_pager.PDFOpen(m_doc, 1);
                break;
            default://unknown error
                onFail(getString(R.string.failed_unknown));
                break;
        }
    }
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        Global.Init(this);
        m_layout = (RelativeLayout) LayoutInflater.from(this).inflate(com.radaee.viewlib.R.layout.pdf_fragment, null);
        m_pager = (PDFViewPager)m_layout.findViewById(R.id.pdf_pager);
        m_doc = new Document();
        Intent intent = getIntent();
        String pdf_asset = intent.getStringExtra("PDFAsset");
        String pdf_path = intent.getStringExtra("PDFPath");
        String pdf_pswd = intent.getStringExtra("PDFPswd");
        String pdf_http = intent.getStringExtra("PDFHttp");
        if(!TextUtils.isEmpty(pdf_http))
        {
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
        }
        else if(!TextUtils.isEmpty(pdf_asset) )
        {
            m_asset_stream = new PDFAssetStream();
            m_asset_stream.open(getAssets(), pdf_asset);
            m_doc = new Document();
            int ret = m_doc.OpenStream(m_asset_stream, pdf_pswd);
            ProcessOpenResult(ret);
        }
        else if(!TextUtils.isEmpty(pdf_path))
        {
            m_doc = new Document();
            int ret = m_doc.Open(pdf_path, pdf_pswd);
            m_doc.SetCache(String.format(Locale.ENGLISH, "%s/temp%08x.dat", Global.tmp_path, m_tmp_index));//set temporary cache for editing.
            m_tmp_index++;
            //m_doc.SetFontDel(m_font_del);
            ProcessOpenResult(ret);
        }
        setContentView(m_layout);
    }
    @Override
    protected void onDestroy()
    {
        m_pager.PDFClose();
        if(m_doc != null) {
            m_doc.Close();
            m_doc = null;
        }
        if( m_asset_stream != null )
        {
            m_asset_stream.close();
            m_asset_stream = null;
        }
        if( m_http_stream != null )
        {
            m_http_stream.close();
            m_http_stream = null;
        }
        Global.RemoveTmp();
        super.onDestroy();
    }
}
