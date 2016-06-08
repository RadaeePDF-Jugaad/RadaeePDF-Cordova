package com.radaee.reader;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.util.PDFGridItem;
import com.radaee.util.PDFGridView;
import com.radaee.viewlib.R;

public class PDFNavAct extends Activity implements OnItemClickListener
{
	private LinearLayout m_layout;
	private PDFGridView m_grid;
	private EditText m_path;
    private boolean m_pending = false;
    class OpenTask extends AsyncTask<Void, Integer, Integer>
    {
        private ProgressDialog dlg;
        private Handler handler;
        private Runnable runable;
        private PDFGridItem item;
        private String pswd;
        private int ret;
        Document doc;
        OpenTask(PDFGridItem item, String pswd)
        {
            this.item = item;
            this.pswd = pswd;
        }
        @Override
        protected Integer doInBackground(Void... voids)
        {
            doc = new Document();
            ret = item.open_doc(doc, pswd);
            return null;
        }
        @Override
        protected void onPreExecute()
        {
            m_pending = true;
            handler = new Handler();
            runable = new Runnable()
            {
                public void run()
                {
                    dlg = ProgressDialog.show(PDFNavAct.this, "Please wait", "Thumbnail creation is running...", true);
                }
            };
            handler.postDelayed(runable, 1000);//delay 1 second to display progress dialog.

        }
        @Override
        protected void onPostExecute(Integer integer)
        {
            m_pending = false;
            switch( ret )
            {
                case -1://need input password
                    doc.Close();
                    InputPswd(item);
                    break;
                case -2://unknown encryption
                    onFail(doc, "Open Failed: Unknown Encryption");
                    break;
                case -3://damaged or invalid format
                    onFail(doc, "Open Failed: Damaged or Invalid PDF file");
                    break;
                case -10://access denied or invalid file path
                    onFail(doc, "Open Failed: Access denied or Invalid path");
                    break;
                case 0://succeeded, and continue
                    InitView(doc);
                    break;
                default://unknown error
                    onFail(doc, "Open Failed: Unknown Error");
                    break;
            }
            if(dlg != null)
                dlg.dismiss();
            else
                handler.removeCallbacks(runable);
        }
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
		m_layout = (LinearLayout)LayoutInflater.from(this).inflate(R.layout.pdf_nav, null);
		m_grid = (PDFGridView)m_layout.findViewById(R.id.pdf_nav);
		m_path = (EditText)m_layout.findViewById(R.id.txt_path);
		m_grid.PDFSetRootPath("/mnt");
		m_path.setText(m_grid.getPath());
		m_path.setEnabled(false);
		m_grid.setOnItemClickListener(this);
		setContentView(m_layout);
    }
    @Override
    public void onConfigurationChanged(Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
    }
    @SuppressLint("InlinedApi")
	@Override
    protected void onDestroy()
    {
        Global.RemoveTmp();
        super.onDestroy();
    }
    private void onFail(Document doc, String msg)//treat open failed.
    {
    	doc.Close();
		Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }
    private void InputPswd(PDFGridItem item)//treat password
    {
		LinearLayout layout = (LinearLayout)LayoutInflater.from(this).inflate(R.layout.dlg_pswd, null);
		final EditText tpassword = (EditText)layout.findViewById(R.id.txt_password);
		final PDFGridItem gitem = item;

		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setPositiveButton("OK", new DialogInterface.OnClickListener(){
			public void onClick(DialogInterface dialog, int which)
			{
				String password = tpassword.getText().toString();
                OpenTask task = new OpenTask(gitem, password);
                task.execute();
			}});
		builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener(){
			public void onClick(DialogInterface dialog, int which)
			{
				dialog.dismiss();
			}});
		builder.setTitle("Input Password");
		builder.setCancelable(false);
		builder.setView(layout);
		
		AlertDialog dlg = builder.create();
		dlg.show();
    }
	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3)//listener for icon clicked.
	{
        if(m_pending) return;
		PDFGridItem item = (PDFGridItem)arg1;
		if( item.is_dir() )
		{
			m_grid.PDFGotoSubdir(item.get_name());
			m_path.setText(m_grid.getPath());
		}
		else
		{
            OpenTask task = new OpenTask(item, null);
            task.execute();
		}
	}
    private void InitView(Document doc)//process to view PDF file
    {
		PDFViewAct.ms_tran_doc = doc;
		Intent intent = new Intent(this, PDFViewAct.class);  
		startActivity(intent);
    }
}
