package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class PDFGridItem extends LinearLayout
{
	private ImageView m_image;
	private TextView m_name;
	private String m_path;
	private Bitmap m_bmp;
	private Page m_page;
	private boolean m_cancel = false;
	static Bitmap m_def_pdf_icon = null;
	static Bitmap m_def_dir_icon = null;
	static Bitmap m_def_up_icon = null;
	static Bitmap m_def_refresh_icon = null;
	static int TEXT_COLOR = 0xFFCCCCCC;
	public PDFGridItem(Context context, AttributeSet attrs)
	{
		super(context, attrs);
		if( m_def_pdf_icon == null )
			m_def_pdf_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_file);
		if( m_def_dir_icon == null )
			m_def_dir_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_folder0);
		if( m_def_up_icon == null )
			m_def_up_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_folder1);
		if( m_def_refresh_icon == null )
			m_def_refresh_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_folder2);
		this.setBackgroundColor(0);
		this.setOrientation(VERTICAL);
		unlock_file();
	}
	public int open_doc( Document doc, String password )
	{
		lock_file();
		int ret = doc.Open(m_path, password);
		unlock_file();
		return ret;
	}
	public boolean is_dir()
	{
		return (m_bmp == m_def_dir_icon || m_bmp == m_def_up_icon || m_bmp == m_def_refresh_icon);
	}
	public String get_name()
	{
		return (String) m_name.getText();
	}
	public String get_path()
	{
		return m_path;
	}
	protected synchronized void page_set()
	{
		this.removeAllViews();
		m_image = new ImageView(getContext());
		m_image.setImageBitmap(m_bmp);
		m_image.setPadding(2, 2, 2, 2);
		this.addView(m_image);
		this.addView(m_name);
	}
	protected synchronized void page_destroy()
	{
		m_cancel = true;
		if( m_page != null )
			m_page.RenderCancel();
		if( m_bmp != m_def_pdf_icon && m_bmp != m_def_dir_icon && m_bmp != m_def_up_icon && m_bmp != m_def_refresh_icon && m_bmp != null )
		{
			m_bmp.recycle();
			m_bmp = null;
		}
	}
	protected void set_dir( String name, String path )
	{
		m_path = path;
		m_name = new TextView(getContext());
		m_name.setText(name);
		m_name.setSingleLine(true);
		m_name.setGravity(Gravity.CENTER_HORIZONTAL);
		m_name.setTextColor(TEXT_COLOR);
		m_image = new ImageView(getContext());
		if(name.equals("."))
			m_bmp = m_def_refresh_icon;
		else if(name.equals(".."))
			m_bmp = m_def_up_icon;
		else
			m_bmp = m_def_dir_icon;
		m_image.setImageBitmap(m_bmp);
		m_image.setPadding(2, 2, 2, 2);
		m_image.setColorFilter(Global.gridview_icon_color);
		m_name.setWidth(m_image.getWidth());
		this.addView(m_image);
		this.addView(m_name);
	}
	protected void set_file(PDFGridView.PDFGridThread thread, String name, String path )
	{
		m_path = path;
		m_name = new TextView(getContext());
		m_name.setText(name);
		m_name.setSingleLine(true);
		m_name.setGravity(Gravity.CENTER_HORIZONTAL);
		m_name.setTextColor(TEXT_COLOR);
		m_image = new ImageView(getContext());
		m_bmp = m_def_pdf_icon;
		m_image.setImageBitmap(m_bmp);
		m_image.setPadding(2, 2, 2, 2);
		m_image.setColorFilter(Global.gridview_icon_color);
		m_name.setWidth(m_image.getWidth());
		this.addView(m_image);
		this.addView(m_name);
		thread.start_render( this );
	}
	private synchronized void set_page(Page page, Bitmap bmp)
	{
		m_page = page;
		if( bmp != null ) m_bmp = bmp;
	}
	protected boolean render()
	{
		if( m_cancel ) return false;
		String thumbName = null;
		Bitmap bmp = null;
		if(Global.g_save_thumb_in_cache)
		{
			thumbName = CommonUtil.getThumbName(m_path);
			if(thumbName != null)
			{
				bmp = CommonUtil.loadThumb(CommonUtil.getOutputMediaFile(getContext(), thumbName));
				if (bmp != null)//if found cache, return immediately.
				{
					set_page(null, bmp);
					return true;
				}
			}
		}

		lock_file();
		Document doc = new Document();
		Document.SetOpenFlag(3);
		int iret = doc.Open(m_path, null);
		Document.SetOpenFlag(1);
		if( iret == 0 )
		{
			int iw = m_bmp.getWidth();
			int ih = m_bmp.getHeight();
			Page page = doc.GetPage0();
			set_page( page, null );
			try
			{
				bmp = Bitmap.createBitmap( iw, ih, Bitmap.Config.ARGB_8888 );
				bmp.eraseColor(0);
				if( !page.RenderThumb(bmp) )
				{
					float w = doc.GetPageWidth(0);
					float h = doc.GetPageHeight(0);
					float ratiox = iw/w;
					float ratioy = ih/h;
					if( ratiox > ratioy ) ratiox = ratioy;
					Canvas canvas = new Canvas(bmp);
					Paint paint = new Paint();
					paint.setARGB(255, 255, 255, 255);
					canvas.drawRect((iw - w * ratiox)/2, (ih - h * ratiox)/2,
							(iw + w * ratiox)/2, (ih + h * ratiox)/2, paint);
					Matrix mat = new Matrix( ratiox, -ratiox, (iw - w * ratiox)/2, (ih + h * ratiox)/2 );
					page.RenderPrepare((Bitmap)null);
					page.RenderToBmp(bmp, mat);
					mat.Destroy();
					if( !m_page.RenderIsFinished() )
					{
						bmp.recycle();
						bmp = null;
					}
					else if(Global.g_save_thumb_in_cache) {
						CommonUtil.saveThumb(bmp, CommonUtil.getOutputMediaFile(getContext(), thumbName));
					}
				}
			}
			catch(Exception e)
			{
				Log.e("RERR:", e.getMessage());
			}
			set_page( null, bmp );
			page.Close();
			doc.Close();
		}
		unlock_file();
		return bmp != null;
	}
	private boolean is_notified = false;
	private boolean is_waitting = false;
	//public boolean is_locked = false;
	private synchronized void lock_file()
	{
		try
		{
			if( is_notified ) {
				is_notified = false;
				//is_locked = true;
			}
			else
			{
				is_waitting = true;
				wait();
				is_waitting = false;
			}
		}
		catch(Exception e)
		{
			//is_locked = false;
		}
	}
	private synchronized void unlock_file()
	{
		if( is_waitting )
			notify();
		else {
			is_notified = true;
			//is_locked = false;
		}
	}
}