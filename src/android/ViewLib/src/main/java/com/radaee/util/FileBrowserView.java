package com.radaee.util;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.GridView;

import java.io.File;

public class FileBrowserView extends GridView {

	private FileBrowserAdt m_browse_adt;
	private String m_root;
	private String m_cur;
	private Context mContext;

	public FileBrowserView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
	}

	public void FileInit(String rootPath, String[] filters){
		m_browse_adt = new FileBrowserAdt(mContext, filters);
		this.setAdapter(m_browse_adt);

		m_root = rootPath;
		m_cur = rootPath;
		File root = new File(m_cur);
		int w = getWidth();
		int h = getHeight();
		updateCols(w, h);
		if (root.exists() && root.isDirectory()) {
			m_browse_adt.set_dir(root, false);
		}
	}

	public void FileGotoSubdir(String name) {
		String new_path = m_cur;
		if (name == ".") {
		} else if (name == "..") {
			int index = m_cur.lastIndexOf('/');
			if (index < 0) return;
			new_path = new_path.substring(0, index);
		} else {
			new_path += "/";
			new_path += name;
		}
		File dir = new File(new_path);
		if (dir.exists() && dir.isDirectory()) {
			m_browse_adt.notifyDataSetInvalidated();
			m_cur = new_path;
			m_browse_adt.set_dir(dir, m_cur.compareTo(m_root) != 0);
		}
	}

	public void close() {
		if (m_browse_adt != null) {
			m_browse_adt.destroy();
			m_browse_adt = null;
		}
	}

	public String getPath() {
		return m_cur;
	}

	private void updateCols(int w, int h)
	{
		if( w * 3 > h * 5 )
			this.setNumColumns(5);
		else if( w > h )
			this.setNumColumns(4);
		else
			this.setNumColumns(3);
	}
	@Override
	protected void onSizeChanged(int w, int h, int oldw, int oldh)
	{
		updateCols(w, h);
		this.invalidate();
		super.onSizeChanged(w, h, oldw, oldh);
	}
	@Override
	protected void finalize() throws Throwable {
		close();
		super.finalize();
	}
}
