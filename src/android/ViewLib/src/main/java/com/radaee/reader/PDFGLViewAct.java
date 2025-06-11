package com.radaee.reader;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Page.Annotation;
import com.radaee.util.PDFAssetStream;
import com.radaee.util.PDFHttpStream;
import com.radaee.util.PDFThumbView;
import com.radaee.util.RDRecent;
import com.radaee.util.RadaeePluginCallback;
import com.radaee.view.ILayoutView;
import com.radaee.viewlib.R;

public class PDFGLViewAct extends Activity implements ILayoutView.PDFLayoutListener
{
	private String mFindQuery = "";
	private boolean mDidShowReader = false;

	static protected Document ms_tran_doc;
	static protected String ms_tran_path;
	private PDFAssetStream m_asset_stream = null;
	private PDFHttpStream m_http_stream = null;
	private Document m_doc = null;
	private String m_path = null;
	private RelativeLayout m_layout = null;
	private PDFGLLayoutView m_view = null;
	private PDFViewController m_controller = null;
	private boolean m_save_doc_to_bundle = false;
	private void onFail(String msg)//treat open failed.
	{
		m_doc.Close();
		m_doc = null;
		Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
		finish();
	}
	private void ProcessOpenResult(int ret)
	{
		switch( ret )
		{
			case -1://need input password
				onFail("Open Failed: Invalid Password");
				break;
			case -2://unknown encryption
				onFail("Open Failed: Unknown Encryption");
				break;
			case -3://damaged or invalid format
				onFail("Open Failed: Damaged or Invalid PDF file");
				break;
			case -10://access denied or invalid file path
				onFail("Open Failed: Access denied or Invalid path");
				break;
			case 0://succeeded, and continue
				m_save_doc_to_bundle = false;
				OpenTask task = new OpenTask();
				task.execute();
				break;
			default://unknown error
				onFail("Open Failed: Unknown Error");
				break;
		}
	}
	class OpenTask extends AsyncTask<Void, Integer, Integer>
	{
		private ProgressDialog dlg;
		private Handler handler;
		private final Runnable runable = new Runnable()
		{
			public void run()
			{
				dlg = ProgressDialog.show(PDFGLViewAct.this, getString(R.string.please_wait), getString(R.string.loading_pdf), true);
			}
		};
		@Override
		protected Integer doInBackground(Void... voids)
		{
			m_doc.GetPagesMaxSize();//it may spend much time for first invoking this method.
			return null;
		}
		@Override
		protected void onPreExecute()
		{
			handler = new Handler(Looper.getMainLooper());
			handler.postDelayed(runable, 1000);//delay 1 second to display progress dialog.
		}
		@Override
		protected void onPostExecute(Integer integer)
		{
			m_view.PDFOpen(m_doc, PDFGLViewAct.this);
			m_view.setReadOnly(getIntent().getBooleanExtra("READ_ONLY", false));
			m_controller = new PDFViewController(m_layout, m_view, m_path,m_asset_stream != null || m_http_stream != null);
			m_controller.SetPagesListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					Intent intent = new Intent();
					intent.setClass(PDFGLViewAct.this, PDFPagesAct.class);
					PDFPagesAct.ms_tran_doc = m_doc;
					startActivityForResult(intent, 10000);
				}
			});
			if(dlg != null) dlg.dismiss();
			else handler.removeCallbacks(runable);
		}
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
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		//plz set this line to Activity in AndroidManifes.xml:
		//    android:configChanges="orientation|keyboardHidden|screenSize"
		//otherwise, APP shall destroy this Activity and re-create a new Activity when rotate.
		Global.Init( this );
		m_layout = (RelativeLayout)LayoutInflater.from(this).inflate(R.layout.pdf_gllayout, null);
		m_view = (PDFGLLayoutView)m_layout.findViewById(R.id.pdf_view);
		show_progress = true;
		init_cordova();//init for cordova.

		Intent intent = getIntent();
		if(ms_tran_doc != null)//open from browser UI.
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
			if(pdf_http != null && !pdf_http.equals(""))//open from http url.
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
			else if( pdf_asset != null && !pdf_asset.equals(""))//open from assets
			{
				m_asset_stream = new PDFAssetStream();
				m_asset_stream.open(getAssets(), pdf_asset);
				m_doc = new Document();
				m_path = pdf_asset;
				int ret = m_doc.OpenStream(m_asset_stream, pdf_pswd);
				ProcessOpenResult(ret);
			}
			else if( pdf_path != null && !pdf_path.equals(""))//open from absolute path
			{
				m_doc = new Document();
				int ret = m_doc.Open(pdf_path, pdf_pswd);
				ProcessOpenResult(ret);
			}
		}
		setContentView(m_layout);
	}

	@Override
	protected void onPause()
	{
		m_view.onPause();
		super.onPause();
	}
	@Override
	public void onResume()
	{
		m_view.onResume();
		super.onResume();
	}
	@Override
	public void onSaveInstanceState(Bundle savedInstanceState)
	{
		super.onSaveInstanceState(savedInstanceState);
		m_view.BundleSavePos(savedInstanceState);
		if(m_save_doc_to_bundle && m_doc != null)
		{
			Document.BundleSave(savedInstanceState, m_doc);//save Document object
			m_doc= null;
		}
	}
	@Override
	public void onRestoreInstanceState(Bundle savedInstanceState)
	{
		super.onRestoreInstanceState(savedInstanceState);
		if( m_doc == null )
		{
			m_doc = Document.BundleRestore(savedInstanceState);//restore Document object
			m_view.PDFOpen(m_doc, this);
			m_controller = new PDFViewController(m_layout, m_view, m_path,m_asset_stream != null || m_http_stream != null);
			m_controller.SetPagesListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					Intent intent = new Intent();
					intent.setClass(PDFGLViewAct.this, PDFPagesAct.class);
					PDFPagesAct.ms_tran_doc = m_doc;
					startActivityForResult(intent, 10000);
				}
			});
			m_save_doc_to_bundle = true;
		}
		m_view.BundleRestorePos(savedInstanceState);
	}

	public void onBackPressed() {
		if (m_controller == null || m_controller.OnBackPressed())
			onClose(true);
	}

	private void onClose(final boolean onBackPressed)
	{
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
						if(onBackPressed) PDFGLViewAct.super.onBackPressed();
					}
				}).setNegativeButton(R.string.no, new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						if(onBackPressed) PDFGLViewAct.super.onBackPressed();
					}
				}).show();
			}
		} else if(onBackPressed) super.onBackPressed();
	}

	@SuppressLint("InlinedApi")
	@Override
	protected void onDestroy()
	{
		RadaeePluginCallback.getInstance().willCloseReader();

		final PDFViewController vctrl = m_controller;
		final Document doc = m_doc;
		final PDFGLLayoutView view = m_view;
		final PDFAssetStream astr = m_asset_stream;
		final PDFHttpStream hstr = m_http_stream;

		m_controller = null;
		m_doc = null;
		m_view = null;
		m_asset_stream = null;
		m_http_stream = null;
		if (view != null) view.PDFCloseOnUI();
		new Thread(){
			@Override
			public void run() {
				if (vctrl != null) vctrl.onDestroy();
				if (view != null) view.PDFClose();
				if (doc != null) doc.Close();
				if (astr != null) astr.close();
				if (hstr != null) hstr.close();
				Global.RemoveTmp();
				synchronized (PDFGLViewAct.this) { PDFGLViewAct.this.notify(); }
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
	public void OnPDFPageModified(int pageno)
	{
		if (m_controller != null) m_controller.onPageModified(pageno);
	}
	@Override
	public void OnPDFPageChanged(int pageno)
	{
		if(m_controller != null)
			m_controller.OnPageChanged(pageno);
		RadaeePluginCallback.getInstance().didChangePage(pageno);
	}
	@Override
	public void OnPDFAnnotTapped(int pageno, Annotation annot)
	{
		if (annot != null) {
			RadaeePluginCallback.getInstance().onAnnotTapped(annot);
			if (!m_view.PDFCanSave() && annot.GetType() != 2)
				return;
		}
		if (m_controller != null)
			m_controller.OnAnnotTapped(pageno, annot);
	}
	@Override
	public void OnPDFBlankTapped(int pageno)
	{
		if(m_controller != null)
			m_controller.OnBlankTapped();
		RadaeePluginCallback.getInstance().onBlankTapped(pageno);
	}
	@Override
	public void OnPDFSelectEnd(String text)
	{
		LinearLayout layout = (LinearLayout)LayoutInflater.from(this).inflate(R.layout.dlg_text, null);
		final RadioGroup rad_group = (RadioGroup)layout.findViewById(R.id.rad_group);
		final String sel_text = text;

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener()
		{
			@SuppressLint("NewApi")
			public void onClick(DialogInterface dialog, int which)
			{
				if (rad_group.getCheckedRadioButtonId() == R.id.rad_copy) {
					android.content.ClipboardManager clipboard = (android.content.ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
					android.content.ClipData clip = android.content.ClipData.newPlainText("Radaee", sel_text);
					clipboard.setPrimaryClip(clip);
					Toast.makeText(PDFGLViewAct.this, getString(R.string.copy_text, sel_text), Toast.LENGTH_SHORT).show();
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
						Toast.makeText(PDFGLViewAct.this, R.string.annotation_failed, Toast.LENGTH_SHORT).show();
				} else
					Toast.makeText(PDFGLViewAct.this, R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
				dialog.dismiss();
				if (m_controller != null)
					m_controller.OnSelectEnd();
			}});
		builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener()
		{
			public void onClick(DialogInterface dialog, int which)
			{
				dialog.dismiss();
			}});
		builder.setTitle(R.string.process_selected_text);
		builder.setCancelable(false);
		builder.setView(layout);
		AlertDialog dlg = builder.create();
		dlg.show();
	}
	@Override
	public void OnPDFOpenURI(String uri)
	{
		try
		{
			Intent intent = new Intent();
			intent.setAction("android.intent.action.VIEW");
			Uri content_url = Uri.parse(uri);
			intent.setData(content_url);
			startActivity(intent);
		}
		catch(Exception e)
		{
			Toast.makeText(PDFGLViewAct.this, "todo: open url:" + uri, Toast.LENGTH_SHORT).show();
		}
	}
	@Override
	public void OnPDFOpenJS(String js)
	{
		Toast.makeText(PDFGLViewAct.this, "todo: execute java script", Toast.LENGTH_SHORT).show();
	}
	@Override
	public void OnPDFOpenMovie(String path)
	{
		Toast.makeText(PDFGLViewAct.this, "todo: play movie", Toast.LENGTH_SHORT).show();
	}
	@Override
	public void OnPDFOpenSound(int[] paras, String path)
	{
		Toast.makeText(PDFGLViewAct.this, "todo: play sound", Toast.LENGTH_SHORT).show();
	}
	@Override
	public void OnPDFOpenAttachment(String path)
	{
		Toast.makeText(PDFGLViewAct.this, "todo: treat attachment", Toast.LENGTH_SHORT).show();
	}

	@Override
	public void OnPDFOpenRendition(String path) {
	}

	@Override
	public void OnPDFOpen3D(String path)
	{
		Toast.makeText(PDFGLViewAct.this, "todo: play 3D module", Toast.LENGTH_SHORT).show();
	}
	@Override
	public void OnPDFZoomStart() { }
	@Override
	public void OnPDFZoomEnd() { }

	@Override
	public boolean OnPDFDoubleTapped(int pageno, float x, float y)
	{
		RadaeePluginCallback.getInstance().onDoubleTapped(pageno, x, y);
		return false;
	}

	@Override
	public void OnPDFLongPressed(int pageno, float x, float y) {
		RadaeePluginCallback.getInstance().onLongPressed(pageno, x, y);
	}

	@Override
	public void OnPDFSearchFinished(boolean found) {
		if (!mFindQuery.equals(m_controller.getFindQuery())) {
			mFindQuery = m_controller.getFindQuery();
			RadaeePluginCallback.getInstance().didSearchTerm(mFindQuery, found);
		}
	}

	@Override
	public void OnPDFPageDisplayed(Canvas canvas, ILayoutView.IVPage vpage) { }

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
}
