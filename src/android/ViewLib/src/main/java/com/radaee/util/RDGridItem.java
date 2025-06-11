package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

import java.io.File;

public class RDGridItem extends RecyclerView.ViewHolder
{
    static public class RDFileItem {
        protected File m_file;
        protected Bitmap m_thumb;
    }
    protected View m_parent;
    protected RDFileItem m_file;
    protected RDFileItem m_render;
    protected ImageView m_vThumb;
    protected TextView m_vName;
    protected ImageView m_vMore;
    private int m_iw;
    private int m_ih;
    private Page m_page;
    private final RDLockerSet m_lset;
    private static int dp2px(Context context, float dpValue) {
        return (int)(dpValue * context.getResources().getDisplayMetrics().density);
    }
    public RDGridItem(@NonNull View itemView, RDLockerSet lset)
    {
        super(itemView);
        m_lset = lset;
        m_parent = itemView;
        m_vThumb = itemView.findViewById(R.id.img_thumb);
        m_vName = itemView.findViewById(R.id.txt_name);
        m_vMore = itemView.findViewById(R.id.img_more);
        m_iw = m_ih = dp2px(m_vThumb.getContext(), 100);
        m_vMore.setColorFilter(Global.gridview_icon_color);
    }
    protected void start_render()
    {
        m_render = m_file;
    }
    protected boolean render()
    {
        String key = m_file.m_file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        Bitmap bmp = null;
        Document doc = new Document();
        Document.SetOpenFlag(3);
        int iret = doc.Open(m_render.m_file.getAbsolutePath(), null);
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
            if (bmp != null) m_render.m_thumb = bmp;
        }
        m_lset.Unlock(key, locker);
        return bmp != null;
    }
    public int RDOpen( Document doc, String password )
    {
        String key = m_file.m_file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        int ret = doc.Open(key, password);
        m_lset.Unlock(key, locker);
        return ret;
    }
    public String RDGetPath()
    {
        return m_file.m_file.getAbsolutePath();
    }
    public File RDGetFile()
    {
        return m_file.m_file;
    }
    public void HideMore(boolean hide)
    {
        if (hide) m_vMore.setVisibility(View.GONE);
        else m_vMore.setVisibility(View.VISIBLE);
    }
    public void UpdateNameAndSize()
    {
        m_vName.setText(m_file.m_file.getName());
        m_iw = m_vThumb.getWidth();
        m_ih = m_vThumb.getHeight();
    }
    public void UpdateThumb()
    {
        if (m_file.m_thumb != RDGridView.m_def_dir_icon &&
            m_file.m_thumb != RDGridView.m_def_pdf_icon)
            m_vThumb.setColorFilter(0);
        else m_vThumb.setColorFilter(Global.gridview_icon_color);
        m_vThumb.setImageBitmap(m_file.m_thumb);
    }
    private synchronized void set_page(Page page)
    {
        m_page = page;
    }
    public synchronized void RDCancel()
    {
        if (m_page != null) m_page.RenderCancel();
    }
    public void RDDelete()
    {
        String key = m_file.m_file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        m_file.m_file.delete();
        m_lset.Unlock(key, locker);
    }
    public boolean IsDir()
    {
        return m_file.m_file.isDirectory();
    }
    public void Close()
    {
        m_vThumb.setImageBitmap(null);
        m_file = null;
    }
}
