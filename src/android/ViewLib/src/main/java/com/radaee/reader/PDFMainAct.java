package com.radaee.reader;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.util.RDBGView;
import com.radaee.util.RDFilesItem;
import com.radaee.util.RDFilesView;
import com.radaee.util.RDGridItem;
import com.radaee.util.RDGridView;
import com.radaee.util.RDLockerSet;
import com.radaee.util.RDRecentItem;
import com.radaee.util.RDRecentView;
import com.radaee.viewlib.R;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

public class PDFMainAct extends Activity {
    private boolean m_pending = false;
    private RDGridItem m_item_grid;
    private RDRecentItem m_item_rec;
    private RDFilesItem m_item_file;
    private int m_item_idx;
    private RDLockerSet m_locker_set;
    class OpenTaskGrid extends AsyncTask<Void, Integer, Integer> {
        private ProgressDialog m_dlg;
        private Handler m_handler;
        private Runnable m_runable;
        private final String m_pswd;
        private String m_path;
        private int m_ret;
        private Document m_doc;
        OpenTaskGrid(RDGridItem item, String pswd) {
            m_item_grid = item;
            m_pswd = pswd;
        }
        @Override
        protected Integer doInBackground(Void... voids) {
            m_doc = new Document();
            m_ret = m_item_grid.RDOpen(m_doc, m_pswd);
            m_path = m_item_grid.RDGetPath();
            return null;
        }
        @Override
        protected void onPreExecute() {
            m_pending = true;
            m_handler = new Handler();
            m_runable = new Runnable() {
                public void run() {
                    m_dlg = ProgressDialog.show(PDFMainAct.this, getString(R.string.please_wait), getString(R.string.thumbnail_creation_running), true);
                }
            };
            m_handler.postDelayed(m_runable, 1000);//delay 1 second to display progress dialog.

        }
        private void InputPswd()//treat password
        {
            LinearLayout layout = (LinearLayout) LayoutInflater.from(PDFMainAct.this).inflate(R.layout.dlg_pswd, null);
            final EditText tpassword = (EditText) layout.findViewById(R.id.txt_password);

            AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
            builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    String password = tpassword.getText().toString();
                    OpenTaskGrid task = new OpenTaskGrid(m_item_grid, password);
                    task.execute();
                }
            });
            builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
            builder.setTitle(R.string.input_password);
            builder.setCancelable(false);
            builder.setView(layout);

            AlertDialog dlg = builder.create();
            dlg.show();
        }
        @Override
        protected void onPostExecute(Integer integer) {
            m_pending = false;
            switch (m_ret) {
                case -1://need input password
                    m_doc.Close();
                    InputPswd();
                    break;
                case -2://unknown encryption
                    onFail(m_doc, getString(R.string.failed_encryption));
                    break;
                case -3://damaged or invalid format
                    onFail(m_doc, getString(R.string.failed_invalid_format));
                    break;
                case -10://access denied or invalid file path
                    onFail(m_doc, getString(R.string.failed_invalid_path));
                    break;
                case 0://succeeded, and continue
                    InitView(m_doc, m_path);
                    break;
                default://unknown error
                    onFail(m_doc, getString(R.string.failed_unknown));
                    break;
            }
            if (m_dlg != null)
                m_dlg.dismiss();
            else
                m_handler.removeCallbacks(m_runable);
        }
    }
    class OpenTaskRecent extends AsyncTask<Void, Integer, Integer> {
        private ProgressDialog m_dlg;
        private Handler m_handler;
        private Runnable m_runable;
        private final String m_pswd;
        private String m_path;
        private int m_ret;
        private Document m_doc;
        OpenTaskRecent(RDRecentItem item, String pswd) {
            m_item_rec = item;
            m_pswd = pswd;
        }
        @Override
        protected Integer doInBackground(Void... voids) {
            m_doc = new Document();
            m_ret = m_item_rec.RDOpen(m_doc, m_pswd);
            m_path = m_item_rec.RDGetFile().getAbsolutePath();
            return null;
        }
        @Override
        protected void onPreExecute() {
            m_pending = true;
            m_handler = new Handler();
            m_runable = new Runnable() {
                public void run() {
                    m_dlg = ProgressDialog.show(PDFMainAct.this, getString(R.string.please_wait), getString(R.string.thumbnail_creation_running), true);
                }
            };
            m_handler.postDelayed(m_runable, 1000);//delay 1 second to display progress dialog.

        }
        private void InputPswd()//treat password
        {
            LinearLayout layout = (LinearLayout) LayoutInflater.from(PDFMainAct.this).inflate(R.layout.dlg_pswd, null);
            final EditText tpassword = (EditText) layout.findViewById(R.id.txt_password);

            AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
            builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    String password = tpassword.getText().toString();
                    OpenTaskRecent task = new OpenTaskRecent(m_item_rec, password);
                    task.execute();
                }
            });
            builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
            builder.setTitle(R.string.input_password);
            builder.setCancelable(false);
            builder.setView(layout);

            AlertDialog dlg = builder.create();
            dlg.show();
        }
        @Override
        protected void onPostExecute(Integer integer) {
            m_pending = false;
            switch (m_ret) {
                case -1://need input password
                    m_doc.Close();
                    InputPswd();
                    break;
                case -2://unknown encryption
                    onFail(m_doc, getString(R.string.failed_encryption));
                    break;
                case -3://damaged or invalid format
                    onFail(m_doc, getString(R.string.failed_invalid_format));
                    break;
                case -10://access denied or invalid file path
                    onFail(m_doc, getString(R.string.failed_invalid_path));
                    break;
                case 0://succeeded, and continue
                    InitView(m_doc, m_path);
                    break;
                default://unknown error
                    onFail(m_doc, getString(R.string.failed_unknown));
                    break;
            }
            if (m_dlg != null)
                m_dlg.dismiss();
            else
                m_handler.removeCallbacks(m_runable);
        }
    }
    class OpenTaskFile extends AsyncTask<Void, Integer, Integer> {
        private ProgressDialog m_dlg;
        private Handler m_handler;
        private Runnable m_runable;
        private String m_path;
        private final String m_pswd;
        private int m_ret;
        private Document m_doc;
        OpenTaskFile(RDFilesItem item, int idx, String pswd) {
            m_item_file = item;
            m_item_idx = idx;
            m_pswd = pswd;
        }
        @Override
        protected Integer doInBackground(Void... voids) {
            m_doc = new Document();
            m_ret = m_item_file.RDOpen(m_item_idx, m_doc, m_pswd);
            m_path = m_item_file.RDGetFile(m_item_idx).getAbsolutePath();
            return null;
        }
        @Override
        protected void onPreExecute() {
            m_pending = true;
            m_handler = new Handler();
            m_runable = new Runnable() {
                public void run() {
                    m_dlg = ProgressDialog.show(PDFMainAct.this, getString(R.string.please_wait), getString(R.string.thumbnail_creation_running), true);
                }
            };
            m_handler.postDelayed(m_runable, 1000);//delay 1 second to display progress dialog.

        }
        private void InputPswd()//treat password
        {
            LinearLayout layout = (LinearLayout) LayoutInflater.from(PDFMainAct.this).inflate(R.layout.dlg_pswd, null);
            final EditText tpassword = (EditText) layout.findViewById(R.id.txt_password);

            AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
            builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    String password = tpassword.getText().toString();
                    OpenTaskFile task = new OpenTaskFile(m_item_file, m_item_idx, password);
                    task.execute();
                }
            });
            builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
            builder.setTitle(R.string.input_password);
            builder.setCancelable(false);
            builder.setView(layout);

            AlertDialog dlg = builder.create();
            dlg.show();
        }
        @Override
        protected void onPostExecute(Integer integer) {
            m_pending = false;
            switch (m_ret) {
                case -1://need input password
                    m_doc.Close();
                    InputPswd();
                    break;
                case -2://unknown encryption
                    onFail(m_doc, getString(R.string.failed_encryption));
                    break;
                case -3://damaged or invalid format
                    onFail(m_doc, getString(R.string.failed_invalid_format));
                    break;
                case -10://access denied or invalid file path
                    onFail(m_doc, getString(R.string.failed_invalid_path));
                    break;
                case 0://succeeded, and continue
                    InitView(m_doc, m_path);
                    break;
                default://unknown error
                    onFail(m_doc, getString(R.string.failed_unknown));
                    break;
            }
            if (m_dlg != null)
                m_dlg.dismiss();
            else
                m_handler.removeCallbacks(m_runable);
        }
    }
    private LinearLayout m_lay_panel;
    private LinearLayout m_btn_recent;
    private LinearLayout m_btn_files;
    private LinearLayout m_btn_nav;
    private RDBGView m_bg_view;
    private RelativeLayout m_lay_recent;
    private RelativeLayout m_lay_files;
    private RelativeLayout m_lay_navigate;
    private PDFBotBar m_bar_recent;
    private PDFBotBar m_bar_grid;
    private PDFBotBar m_bar_file;

    private RDGridView m_vGrid;
    private TextView m_tPath;
    private void initNavigate()
    {
        m_vGrid = m_lay_navigate.findViewById(R.id.vw_grid);
        m_tPath = m_lay_navigate.findViewById(R.id.txt_path);
        m_vGrid.RDSetListener(m_locker_set, new RDGridView.RDGridAdt.OnGridListener() {
            @Override
            public void OnItemClick(RDGridItem item) {
                if (m_pending) return;
                OpenTaskGrid task = new OpenTaskGrid(item, null);
                task.execute();
            }
            @Override
            public void OnItemMore(RDGridItem item) {
                m_item_grid = item;
                File file = m_item_grid.RDGetFile();
                View bar_view = m_bar_grid.BarGetView();
                TextView tname = bar_view.findViewById(R.id.txt_name);
                tname.setText(file.getName());
                TextView tinfo = bar_view.findViewById(R.id.txt_info);
                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
                tinfo.setText(format.format(new Date(file.lastModified())) + " " + (file.length() >> 10) + "kb");
                if (!m_bg_view.RDIsShowing()) {
                    m_bar_grid.BarShow();
                    m_bg_view.RDShow();
                }
            }
            @Override
            public void OnPathChanged(String root, String path)
            {
                m_tPath.setText("/sdcard" + path.substring(root.length()));
            }
        });
        m_vGrid.RDSetRoot(Environment.getExternalStorageDirectory().getPath());
        ImageView imgv = m_lay_navigate.findViewById(R.id.btn_up);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) { m_vGrid.RDGoUp(); }
        });
        imgv = m_lay_navigate.findViewById(R.id.btn_refresh);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) { m_vGrid.RDFresh(); }
        });

        View bar_view = m_bar_grid.BarGetView();
        bar_view.setOnTouchListener(new View.OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View v, MotionEvent event) { return true; }
        });
        //delete button in menu
        bar_view.findViewById(R.id.btn_remove).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
                builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        m_vGrid.RDRemove(m_item_grid.getAdapterPosition());
                        m_item_grid.RDCancel();
                        m_item_grid.RDDelete();
                        m_item_grid = null;
                        if (!m_bg_view.RDIsHidding()) {
                            m_bar_grid.BarHide();
                            m_bg_view.RDHide();
                        }
                    }
                });
                builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                });
                builder.setTitle(getString(R.string.confirm));
                builder.setCancelable(false);
                TextView tview = new TextView(PDFMainAct.this);
                tview.setText(getString(R.string.browser_file_delete_confirm) + "\n" + m_item_grid.RDGetPath() + "\n?");
                builder.setView(tview);

                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
        //share button in menu
        bar_view.findViewById(R.id.btn_share).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                File outputFile = new File(m_item_grid.RDGetPath());
                Uri uri = Uri.fromFile(outputFile);

                Intent share = new Intent();
                share.setAction(Intent.ACTION_SEND);
                share.setType("application/pdf");
                share.putExtra(Intent.EXTRA_STREAM, uri);

                try {
                    startActivity(share);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
            }
        });
        imgv = bar_view.findViewById(R.id.img_00);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_01);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_10);
        imgv.setColorFilter(Global.toolbar_icon_color);
    }
    private RDRecentView m_vRecent;
    private void initRecent()
    {
        m_vRecent = m_lay_recent.findViewById(R.id.vw_recent);
        m_vRecent.OpenRecent(m_locker_set, new RDRecentView.OnRecentListener() {
            @Override
            public void OnItemClick(RDRecentItem item, int idx) {
                if (m_pending) return;
                OpenTaskRecent task = new OpenTaskRecent(item, null);
                task.execute();
            }
            @Override
            public void OnItemMore(RDRecentItem item, int idx) {
                m_item_rec = item;
                File file = m_item_rec.RDGetFile();
                View bar_view = m_bar_recent.BarGetView();
                TextView tname = bar_view.findViewById(R.id.txt_name);
                tname.setText(file.getName());
                TextView tinfo = bar_view.findViewById(R.id.txt_info);
                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
                tinfo.setText(format.format(new Date(file.lastModified())) + " " + (file.length() >> 10) + "kb");
                if (!m_bg_view.RDIsShowing()) {
                    m_bar_recent.BarShow();
                    m_bg_view.RDShow();
                }
            }
        });
        ImageView imgv = m_lay_recent.findViewById(R.id.btn_clear);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
                builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        m_vRecent.Clear();
                        UpdateRecentUI(m_vRecent);
                    }
                });
                builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                });
                builder.setTitle(getString(R.string.confirm));
                builder.setCancelable(false);
                TextView tview = new TextView(PDFMainAct.this);
                tview.setText(getString(R.string.browser_file_delete_recent_list_confirm));
                builder.setView(tview);

                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });

        View bar_view = m_bar_recent.BarGetView();
        bar_view.setOnTouchListener(new View.OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View v, MotionEvent event) { return true; }
        });
        //delete button in menu
        bar_view.findViewById(R.id.btn_remove).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
                builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        m_vRecent.Remove(m_item_rec);
                        m_item_rec.RDCancel();
                        m_item_rec.RDDelete();
                        m_item_rec = null;
                        if (!m_bg_view.RDIsHidding()) {
                            m_bar_recent.BarHide();
                            m_bg_view.RDHide();
                        }
                        UpdateRecentUI(m_vRecent);
                    }
                });
                builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                });
                builder.setTitle(getString(R.string.confirm));
                builder.setCancelable(false);
                TextView tview = new TextView(PDFMainAct.this);
                tview.setText(getString(R.string.browser_file_delete_confirm) + "\n" + m_item_rec.RDGetFile().getAbsoluteFile() + "\n?");
                builder.setView(tview);

                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
        //remove from recent button in menu
        bar_view.findViewById(R.id.btn_remove_rec).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                m_vRecent.Remove(m_item_rec);
                m_item_rec = null;
                if (!m_bg_view.RDIsHidding()) {
                    m_bar_recent.BarHide();
                    m_bg_view.RDHide();
                }
                UpdateRecentUI(m_vRecent);
            }
        });
        //share button in menu
        bar_view.findViewById(R.id.btn_share).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                File outputFile = new File(m_item_rec.RDGetFile().getAbsolutePath());
                Uri uri = Uri.fromFile(outputFile);

                Intent share = new Intent();
                share.setAction(Intent.ACTION_SEND);
                share.setType("application/pdf");
                share.putExtra(Intent.EXTRA_STREAM, uri);
                try {
                    startActivity(share);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
            }
        });
        imgv = bar_view.findViewById(R.id.img_00);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_01);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_02);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_10);
        imgv.setColorFilter(Global.toolbar_icon_color);
        UpdateRecentUI(m_vRecent);
    }
    private RDFilesView m_vFiles;
    private void initFiles()
    {
        m_vFiles = m_lay_files.findViewById(R.id.vw_files);
        m_vFiles.SetListener(m_locker_set, "/sdcard", new RDFilesView.OnFilesListener() {
            @Override
            public void OnItemClick(RDFilesItem item, int idx) {
                if (m_pending) return;
                OpenTaskFile task = new OpenTaskFile(item, idx, null);
                task.execute();
            }
            @Override
            public void OnItemMore(RDFilesItem item, int idx) {
                m_item_file = item;
                m_item_idx = idx;
                File file = item.RDGetFile(idx);
                View bar_view = m_bar_file.BarGetView();
                TextView tname = bar_view.findViewById(R.id.txt_name);
                tname.setText(file.getName());
                TextView tinfo = bar_view.findViewById(R.id.txt_info);
                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
                tinfo.setText(format.format(new Date(file.lastModified())) + " " + (file.length() >> 10) + "kb");
                if (!m_bg_view.RDIsShowing()) {
                    m_bar_file.BarShow();
                    m_bg_view.RDShow();
                }
            }
            @Override
            public void OnItemAdded() {
                UpdateFilesUI(m_vFiles);
            }
        });
        m_vFiles.Update();
        UpdateFilesUI(m_vFiles);

        View bar_view = m_bar_file.BarGetView();
        bar_view.setOnTouchListener(new View.OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View v, MotionEvent event) { return true; }
        });
        //delete button in menu
        bar_view.findViewById(R.id.btn_remove).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder builder = new AlertDialog.Builder(PDFMainAct.this);
                builder.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        if (m_item_file.RDDelete(m_item_idx) <= 0)
                            m_vFiles.Remove(m_item_file);
                        m_item_file = null;
                        if (!m_bg_view.RDIsHidding()) {
                            m_bar_file.BarHide();
                            m_bg_view.RDHide();
                        }
                        UpdateFilesUI(m_vFiles);
                    }
                });
                builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                });
                builder.setTitle(getString(R.string.confirm));
                builder.setCancelable(false);
                TextView tview = new TextView(PDFMainAct.this);
                tview.setText(getString(R.string.browser_file_delete_confirm) + m_item_file.RDGetFile(m_item_idx).getAbsolutePath() + "\n?");
                builder.setView(tview);

                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
        //share button in menu
        bar_view.findViewById(R.id.btn_share).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                File outputFile = new File(m_item_file.RDGetFile(m_item_idx).getAbsolutePath());
                Uri uri = Uri.fromFile(outputFile);

                Intent share = new Intent();
                share.setAction(Intent.ACTION_SEND);
                share.setType("application/pdf");
                share.putExtra(Intent.EXTRA_STREAM, uri);

                try {
                    startActivity(share);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
            }
        });
        ImageView imgv = bar_view.findViewById(R.id.img_00);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_01);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = bar_view.findViewById(R.id.img_10);
        imgv.setColorFilter(Global.toolbar_icon_color);

        imgv = m_lay_files.findViewById(R.id.btn_refresh);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                m_vFiles.Update();
                UpdateFilesUI(m_vFiles);
            }
        });
    }
    private String m_engine;
    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Global.Init(this);
        m_locker_set = new RDLockerSet();
        m_engine = getIntent().getStringExtra("ENGINE");

        RelativeLayout layout = (RelativeLayout) LayoutInflater.from(this).inflate(R.layout.pdf_main, null);
        m_bar_recent = new PDFBotBar(layout, R.layout.bar_menu_recent);
        m_bar_grid = new PDFBotBar(layout, R.layout.bar_menu_file);
        m_bar_file = new PDFBotBar(layout, R.layout.bar_menu_file);
        m_lay_recent = (RelativeLayout) LayoutInflater.from(this).inflate(R.layout.pdf_recent, null);
        m_lay_files = (RelativeLayout) LayoutInflater.from(this).inflate(R.layout.pdf_files, null);
        m_lay_navigate = (RelativeLayout) LayoutInflater.from(this).inflate(R.layout.pdf_navigate, null);

        ImageView imgv = layout.findViewById(R.id.img_00);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = layout.findViewById(R.id.img_01);
        imgv.setColorFilter(Global.toolbar_icon_color);
        imgv = layout.findViewById(R.id.img_02);
        imgv.setColorFilter(Global.toolbar_icon_color);

        m_lay_panel = layout.findViewById(R.id.lay_panel);
        m_lay_panel.addView(m_lay_recent);

        m_btn_recent = layout.findViewById(R.id.btn_recent);
        m_btn_files = layout.findViewById(R.id.btn_files);
        m_btn_nav = layout.findViewById(R.id.btn_nav);
        m_bg_view = layout.findViewById(R.id.vw_menu_back);
        m_bg_view.setOnTouchListener(new View.OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                int act = event.getActionMasked();
                if(!m_bg_view.RDIsHidding() && (act == MotionEvent.ACTION_UP || act == MotionEvent.ACTION_CANCEL)) {
                    m_bg_view.RDHide();
                    if (!m_bar_recent.BarIsHide())
                        m_bar_recent.BarHide();
                    if (!m_bar_grid.BarIsHide())
                        m_bar_grid.BarHide();
                    if (!m_bar_file.BarIsHide())
                        m_bar_file.BarHide();
                }
                return true;
            }
        });
        setContentView(layout);

        m_btn_recent.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                m_lay_panel.removeAllViews();
                m_lay_panel.addView(m_lay_recent);
                //RDRecentView vRecent = m_lay_recent.findViewById(R.id.vw_recent);
                //vRecent.Update();
            }
        });
        m_btn_files.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                m_lay_panel.removeAllViews();
                m_lay_panel.addView(m_lay_files);
            }
        });
        m_btn_nav.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                m_lay_panel.removeAllViews();
                m_lay_panel.addView(m_lay_navigate);
            }
        });

        initRecent();
        initFiles();
        initNavigate();
    }
    @Override
    protected void onDestroy() {
        RDGridView vGrid = m_lay_navigate.findViewById(R.id.vw_grid);
        vGrid.RDClose();
        RDRecentView vRecent = m_lay_recent.findViewById(R.id.vw_recent);
        vRecent.Close();
        super.onDestroy();
    }
    private void onFail(Document doc, String msg)//treat open failed.
    {
        doc.Close();
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }
    private void InitView(Document doc, String path)//process to view PDF file
    {
        if (m_engine != null && m_engine.compareTo("OPENGL") == 0) {
            PDFGLViewAct.ms_tran_doc = doc;
            PDFGLViewAct.ms_tran_path = path;
            Intent intent = new Intent(this, PDFGLViewAct.class);
            startActivityForResult(intent, 1000);
        } else {
            PDFViewAct.ms_tran_doc = doc;
            PDFViewAct.ms_tran_path = path;
            Intent intent = new Intent(this, PDFViewAct.class);
            startActivityForResult(intent, 1000);
        }
    }

    private void UpdateRecentUI(RDRecentView vRecent)
    {
        TextView tNoRecent = m_lay_recent.findViewById(R.id.txt_no_recent);
        if (vRecent.IsEmpty())
        {
            vRecent.setVisibility(View.GONE);
            tNoRecent.setVisibility(View.VISIBLE);
        }
        else
        {
            vRecent.setVisibility(View.VISIBLE);
            tNoRecent.setVisibility(View.GONE);
        }
    }
    private void UpdateFilesUI(RDFilesView vFiles)
    {
        TextView tNoFiles = m_lay_files.findViewById(R.id.txt_no_files);
        if (vFiles.IsEmpty())
        {
            vFiles.setVisibility(View.GONE);
            tNoFiles.setVisibility(View.VISIBLE);
        }
        else
        {
            vFiles.setVisibility(View.VISIBLE);
            tNoFiles.setVisibility(View.GONE);
        }
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1000) {
            RDRecentView vRecent = m_lay_recent.findViewById(R.id.vw_recent);
            vRecent.Update();
            vRecent.invalidate();
            UpdateRecentUI(vRecent);
        }
    }
    @Override
    public void onBackPressed() {
        if (m_bg_view.RDIsShowing())
        {
            if(!m_bg_view.RDIsHidding()) {
                m_bg_view.RDHide();
                if (!m_bar_recent.BarIsHide())  m_bar_recent.BarHide();
                if (!m_bar_grid.BarIsHide()) m_bar_grid.BarHide();
                if (!m_bar_file.BarIsHide()) m_bar_file.BarHide();
            }
        }
        else super.onBackPressed();
    }
}
