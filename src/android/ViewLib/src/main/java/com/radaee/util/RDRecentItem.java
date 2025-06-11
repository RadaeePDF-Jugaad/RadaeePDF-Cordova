package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

import java.io.File;

public class RDRecentItem
{
    protected RelativeLayout m_view;
    protected File m_file;
    protected Bitmap m_thumb;
    protected int m_pageno;
    protected int m_view_type;
    private int m_iw;
    private int m_ih;
    private Page m_page;
    private final RDLockerSet m_lset;
    public File RDGetFile() { return m_file; }
    private static int dp2px(Context context, float dpValue) {
        return (int)(dpValue * context.getResources().getDisplayMetrics().density);
    }
    public RDRecentItem(Context ctx, RDLockerSet lset)
    {
        m_lset = lset;
        m_view = (RelativeLayout) LayoutInflater.from(ctx).inflate(R.layout.item_file_list, null);
        ImageView imgv = m_view.findViewById(R.id.img_thumb);
        imgv.setImageBitmap(RDGridView.m_def_pdf_icon);
        imgv.setColorFilter(Global.gridview_icon_color);
    }
    private synchronized void set_page(Page page)
    {
        m_page = page;
    }
    protected void start_render()
    {
        m_iw = m_ih = dp2px(m_view.getContext(), 60);
    }
    protected boolean render()
    {
        String key = m_file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        Bitmap bmp = null;
        Document doc = new Document();
        Document.SetOpenFlag(3);
        int iret = doc.Open(m_file.getAbsolutePath(), null);
        Document.SetOpenFlag(1);
        if( iret == 0 )
        {
            Page page = doc.GetPage0();
            set_page(page);

            float w = doc.GetPageWidth(0);
            float h = doc.GetPageHeight(0);
            float ratiox = m_iw / w;
            float ratioy = m_ih / h;
            int iw = (int)(w * ratiox);
            int ih = (int)(h * ratiox);

            bmp = Bitmap.createBitmap( iw, ih, Bitmap.Config.ARGB_8888 );
            bmp.eraseColor(-1);
            if( !page.RenderThumb(bmp) )
            {
                if( ratiox > ratioy ) ratiox = ratioy;
                Matrix mat = new Matrix( ratiox, -ratiox, 0, ih );
                page.RenderPrepare((Bitmap)null);
                page.RenderToBmp(bmp, mat);
                mat.Destroy();
                if( !page.RenderIsFinished() )
                {
                    bmp.recycle();
                    bmp = null;
                }
            }
            set_page(null);
            page.Close();
            doc.Close();
            if (bmp != null) m_thumb = bmp;
        }
        m_lset.Unlock(key, locker);
        return bmp != null;
    }
    public int RDOpen(Document doc, String password )
    {
        String key = m_file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        int ret = doc.Open(key, password);
        m_lset.Unlock(key, locker);
        return ret;
    }
    public void RDDelete()
    {
        String key = m_file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        m_file.delete();
        m_lset.Unlock(key, locker);
    }
    public synchronized void RDCancel()
    {
        if (m_page != null) m_page.RenderCancel();
    }
    public void UpdateThumb()
    {
        ImageView imgv = m_view.findViewById(R.id.img_thumb);
        if (m_thumb != RDGridView.m_def_dir_icon && m_thumb != RDGridView.m_def_pdf_icon)
            imgv.setColorFilter(0);
        else imgv.setColorFilter(Global.gridview_icon_color);
        imgv.setImageBitmap(m_thumb);
    }
}
