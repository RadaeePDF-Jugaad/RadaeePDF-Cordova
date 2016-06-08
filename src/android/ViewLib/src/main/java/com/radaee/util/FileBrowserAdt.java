package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.radaee.reader.R;

import java.io.File;
import java.util.Vector;

public class FileBrowserAdt extends BaseAdapter {
	static Bitmap m_def_file_icon = null;
	static Bitmap m_def_dir_icon = null;
	static Bitmap m_def_up_icon = null;
	static Bitmap m_def_refresh_icon = null;
	static int TEXT_COLOR = 0xFF888888;
	public class FileGridItem extends LinearLayout {
		private ImageView m_image;
		private TextView m_name;
		private String m_path;
		private Bitmap m_bmp;

		public FileGridItem(Context context, AttributeSet attrs) {
			super(context, attrs);
			if (m_def_file_icon == null)
				m_def_file_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_file);
			if (m_def_dir_icon == null)
				m_def_dir_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_folder0);
			if (m_def_up_icon == null)
				m_def_up_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_folder1);
			if (m_def_refresh_icon == null)
				m_def_refresh_icon = BitmapFactory.decodeResource(context.getResources(), R.drawable.ic_grid_folder2);
			this.setBackgroundColor(0);
			this.setOrientation(VERTICAL);
		}

		public boolean is_dir() {
			return (m_bmp == m_def_dir_icon || m_bmp == m_def_up_icon || m_bmp == m_def_refresh_icon);
		}

		public String get_name() {
			return (String) m_name.getText();
		}

		public String get_path() {
			return m_path;
		}

		protected void set_dir(String name, String path) {
			m_path = path;
			m_name = new TextView(getContext());
			m_name.setText(name);
			m_name.setSingleLine(true);
			m_name.setGravity(Gravity.CENTER_HORIZONTAL);
			m_name.setTextColor(TEXT_COLOR);
			m_image = new ImageView(getContext());
			if (name == ".")  m_bmp = m_def_refresh_icon;
			else if (name == "..")  m_bmp = m_def_up_icon;
			else  m_bmp = m_def_dir_icon;
			m_image.setImageBitmap(m_bmp);
			m_image.setPadding(2, 2, 2, 2);
			m_name.setWidth(m_image.getWidth());
			this.addView(m_image);
			this.addView(m_name);
			this.setGravity(Gravity.CENTER_VERTICAL);
		}

		protected void set_file(String name, String path) {
			m_path = path;
			m_name = new TextView(getContext());
			m_name.setText(name);
			m_name.setSingleLine(true);
			m_name.setGravity(Gravity.CENTER_HORIZONTAL);
			m_name.setTextColor(TEXT_COLOR);
			m_image = new ImageView(getContext());
			m_bmp = m_def_file_icon;
			m_image.setImageBitmap(m_bmp);
			m_image.setPadding(2, 2, 2, 2);
			m_name.setWidth(m_image.getWidth());
			this.addView(m_image);
			this.addView(m_name);
		}
	}


	private Context m_context;
	private String[] m_filters;
	static protected int clr_back = 0xFFCCCCCC;
	static protected int clr_text = 0xFF000044;

	public static class SnatchItem {
		public String m_path;
		public String m_name;
		public FileGridItem m_item;
	}

	private Vector<SnatchItem> m_items = new Vector<SnatchItem>();

	private void insert_item(SnatchItem item) {
		int left = 0;
		int right = m_items.size() - 1;
		if (item.m_item.is_dir()) {
			while (left <= right) {
				int mid = (left + right) >> 1;
				SnatchItem tmp = m_items.get(mid);
				if (!tmp.m_item.is_dir())
					right = mid - 1;
				else {
					int ret = item.m_name.compareToIgnoreCase(tmp.m_name);
					if (ret == 0) {
						left = mid;
						break;
					}
					if (ret > 0) left = mid + 1;
					else right = mid - 1;
				}
			}
		} else {
			while (left <= right) {
				int mid = (left + right) >> 1;
				SnatchItem tmp = m_items.get(mid);
				if (tmp.m_item.is_dir())
					left = mid + 1;
				else {
					int ret = item.m_name.compareToIgnoreCase(tmp.m_name);
					if (ret == 0) {
						left = mid;
						break;
					}
					if (ret > 0) left = mid + 1;
					else right = mid - 1;
				}
			}
		}
		m_items.insertElementAt(item, left);
	}

	public void destroy() {
		m_items.clear();
	}

	public void set_dir(File file, boolean need_up) {
		m_items.clear();
		{
			SnatchItem item = new SnatchItem();
			item.m_name = ".";
			item.m_path = null;
			item.m_item = new FileGridItem(m_context, null);
			item.m_item.set_dir(item.m_name, item.m_path);
			insert_item(item);
		}
		if (need_up) {
			SnatchItem item = new SnatchItem();
			item.m_name = "..";
			item.m_path = null;
			item.m_item = new FileGridItem(m_context, null);
			item.m_item.set_dir(item.m_name, item.m_path);
			insert_item(item);
		}

		File files[] = file.listFiles();
		if (files == null) {
			notifyDataSetChanged();
			return;
		}
		int cur = 0;
		int cnt = files.length;
		while (cur < cnt)
		{
			if (files[cur].isHidden()) {
				cur++;
				continue;
			}
			if (files[cur].isFile() && match_filter(files[cur].getName()))
			{
				SnatchItem item = new SnatchItem();
				item.m_name = files[cur].getName();
				item.m_path = files[cur].getPath();
				item.m_item = new FileGridItem(m_context, null);
				item.m_item.set_file(item.m_name, item.m_path);
				insert_item(item);
			}
			if (files[cur].isDirectory()) {
				SnatchItem item = new SnatchItem();
				item.m_name = files[cur].getName();
				item.m_path = files[cur].getPath();
				item.m_item = new FileGridItem(m_context, null);
				item.m_item.set_dir(item.m_name, item.m_path);
				insert_item(item);
			}
			cur++;
		}
		notifyDataSetChanged();
	}
	private boolean match_filter(String fname)
	{
		if(m_filters == null) return true;
		int ext_pos = fname.lastIndexOf(".");
		if(ext_pos < 0) return false;
		String ext = fname.substring(ext_pos);
		int icnt = m_filters.length;
		for(int iext = 0; iext < icnt; iext++)
		{
			if(ext.compareToIgnoreCase(m_filters[iext]) == 0) return true;
		}
		return false;
	}
	public FileBrowserAdt(Context ctx, String[]  filters) {
		m_context = ctx;
		m_filters = filters;
	}

	public int getCount() {
		return m_items.size();
	}

	public Object getItem(int arg0) {
		return m_items.get(arg0);
	}

	public long getItemId(int position) {
		return 0;
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		return m_items.get(position).m_item;
	}
}
