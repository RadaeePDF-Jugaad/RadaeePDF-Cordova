package com.radaee.reader;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.print.PageRange;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintDocumentInfo;
import android.print.PrintManager;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Page;
import com.radaee.pdf.Page.Annotation;
import com.radaee.util.BookmarkHandler;
import com.radaee.util.CommonUtil;
import com.radaee.util.PDFThumbView;
import com.radaee.util.RadaeePDFManager;
import com.radaee.util.RadaeePluginCallback;
import com.radaee.view.GLLayout;
import com.radaee.view.ILayoutView;
import com.radaee.view.PDFLayout;
import com.radaee.view.PDFViewThumb;
import com.radaee.viewlib.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.Bidi;
import java.util.Locale;
import java.util.UUID;

public class PDFViewController implements SeekBar.OnSeekBarChangeListener
{
    public interface PDFViewControllerCallback
    {
        Document.PDFStream getStream();
        String getPath();
        void onClose();
    }
    static final public int NOT_MODIFIED = 0;
    static final public int MODIFIED_NOT_SAVED = 1;
    static final public int MODIFIED_AND_SAVED = 2;
    static public final int BAR_NONE = 0;
    static public final int BAR_CMD = 1;
    static public final int BAR_ANNOT = 2;
    static public final int BAR_FIND = 3;
    static public final int NAVIGATION_THUMBS = 0;
    static public final int NAVIGATION_SEEK = 1;
    private int sFileState = NOT_MODIFIED;
    private int m_bar_status = 0;
    private int mNavigationMode = Global.g_navigation_mode;
    private final RelativeLayout m_parent;
    private final ILayoutView m_view;
    private final PDFTopBar m_bar_cmd;
    private final PDFTopBar m_bar_confirm;
    private final PDFTopBar m_bar_find;
    private PDFBotBar m_bar_seek;
    private PDFBotBar m_thumb_view;
    private final PDFMenu m_menu_view;
    private final PDFMenu m_menu_tools;
    private final PDFMenu m_menu_annots;
    private final PDFMenu m_menu_more;
    private final ImageView btn_back;
    private final ImageView btn_view;
    private final ImageView btn_tools;
    private final ImageView btn_annot;
    private final ImageView btn_more;
    private final View btn_pages_list;
    private final View btn_add_bookmark;
    private final View btn_show_bookmarks;
    private final View btn_save;
    private final View btn_print;
    private final View btn_share;
    private final ImageView btn_find_back;
    private final ImageView btn_find_prev;
    private final ImageView btn_find_next;
    private final EditText edit_find;
    private SeekBar seek_page;
    private TextView lab_page;
    private final View view_vert;
    private final View view_horz;
    private final View view_single;
    private final View view_dual;
    private final View view_dualv;

    private final View view_tool_meta;
    private final View view_tool_outline;
    private final View view_tool_find;
    private final View view_tool_select;
    private final View view_tool_undo;
    private final View view_tool_redo;

    private final View view_annot_ink;
    private final View view_annot_line;
    private final View view_annot_rect;
    private final View view_annot_oval;
    private final View view_annot_note;
    private final View view_annot_edit;
    private final View view_annot_stamp;
    private final View view_annot_polygon;
    private final View view_annot_polyline;

    private final ImageView btn_done;
    private final ImageView btn_cancel;
    private int m_sta;

    private PDFThumbView mThumbView;
    private void setIconsColor(int color)
    {
        btn_back.setColorFilter(color);
        btn_view.setColorFilter(color);
        btn_tools.setColorFilter(color);
        btn_annot.setColorFilter(color);
        btn_more.setColorFilter(color);

        ((ImageView)view_tool_meta.findViewById(R.id.img_meta)).setColorFilter(color);
        ((ImageView)view_tool_outline.findViewById(R.id.img_outline)).setColorFilter(color);
        ((ImageView)view_tool_find.findViewById(R.id.img_search)).setColorFilter(color);
        ((ImageView)view_tool_select.findViewById(R.id.img_select)).setColorFilter(color);
        ((ImageView)view_tool_undo.findViewById(R.id.img_undo)).setColorFilter(color);
        ((ImageView)view_tool_redo.findViewById(R.id.img_redo)).setColorFilter(color);

        ((ImageView)view_annot_ink.findViewById(R.id.img_ink)).setColorFilter(color);
        ((ImageView)view_annot_line.findViewById(R.id.img_line)).setColorFilter(color);
        ((ImageView)view_annot_rect.findViewById(R.id.img_rect)).setColorFilter(color);
        ((ImageView)view_annot_oval.findViewById(R.id.img_oval)).setColorFilter(color);
        ((ImageView)view_annot_note.findViewById(R.id.img_note)).setColorFilter(color);
        ((ImageView)view_annot_edit.findViewById(R.id.img_edit)).setColorFilter(color);
        ((ImageView)view_annot_stamp.findViewById(R.id.img_stamp)).setColorFilter(color);
        ((ImageView)view_annot_polygon.findViewById(R.id.img_polygon)).setColorFilter(color);
        ((ImageView)view_annot_polyline.findViewById(R.id.img_polyline)).setColorFilter(color);

        btn_done.setColorFilter(color);
        btn_cancel.setColorFilter(color);

        btn_find_back.setColorFilter(color);
        btn_find_prev.setColorFilter(color);
        btn_find_next.setColorFilter(color);
        ((ImageView)view_vert.findViewById(R.id.view_vert_icon)).setColorFilter(color);
        ((ImageView)view_horz.findViewById(R.id.view_horz_icon)).setColorFilter(color);
        ((ImageView)view_single.findViewById(R.id.view_single_icon)).setColorFilter(color);
        ((ImageView)view_dual.findViewById(R.id.view_dual_icon)).setColorFilter(color);
        ((ImageView)view_dualv.findViewById(R.id.view_dualv_icon)).setColorFilter(color);
        ((ImageView)btn_pages_list.findViewById(R.id.edit_pages_icon)).setColorFilter(color);
        ((ImageView)btn_add_bookmark.findViewById(R.id.add_bookmark_icon)).setColorFilter(color);
        ((ImageView)btn_show_bookmarks.findViewById(R.id.show_bookmarks_icon)).setColorFilter(color);
        ((ImageView)btn_save.findViewById(R.id.save_icon)).setColorFilter(color);
        ((ImageView)btn_print.findViewById(R.id.print_icon)).setColorFilter(color);
        ((ImageView)btn_share.findViewById(R.id.share_icon)).setColorFilter(color);
    }
    private final PDFViewControllerCallback m_callback;
    private void onBackButtonPressed()
    {
        if (m_sta == 2) {
            m_view.PDFSetSelect();
            m_sta = 0;
        }
        m_menu_view.MenuDismiss();
        m_menu_more.MenuDismiss();
        m_bar_cmd.BarHide();

        if (mNavigationMode == NAVIGATION_THUMBS) m_thumb_view.BarHide();
        else if (mNavigationMode == NAVIGATION_SEEK) m_bar_seek.BarHide();
        m_bar_status = BAR_NONE;
    }
    public PDFViewController(RelativeLayout parent, ILayoutView view, PDFViewControllerCallback callback)
    {
        m_parent = parent;
        m_view = view;
        m_callback = callback;
        sFileState = NOT_MODIFIED;
        m_bar_cmd = new PDFTopBar(m_parent, R.layout.bar_cmd);
        m_bar_confirm = new PDFTopBar(m_parent, R.layout.bar_confirm);
        m_bar_find = new PDFTopBar(m_parent, R.layout.bar_find);
        m_menu_view = new PDFMenu(m_parent, R.layout.pop_view, 220);
        m_menu_tools = new PDFMenu(m_parent, R.layout.pop_tools, 160);
        m_menu_annots = new PDFMenu(m_parent, R.layout.pop_annots, 160);
        m_menu_more = new PDFMenu(m_parent, R.layout.pop_more, 180);
        RelativeLayout layout = (RelativeLayout) m_bar_cmd.BarGetView();
        btn_back = (ImageView) layout.findViewById(R.id.btn_back);
        btn_view = (ImageView) layout.findViewById(R.id.btn_view);
        btn_tools = (ImageView) layout.findViewById(R.id.btn_tools);
        btn_annot = (ImageView) layout.findViewById(R.id.btn_annot);
        btn_more = (ImageView) layout.findViewById(R.id.btn_more);
        layout = (RelativeLayout) m_bar_find.BarGetView();
        btn_find_back = (ImageView) layout.findViewById(R.id.btn_back);
        btn_find_prev = (ImageView) layout.findViewById(R.id.btn_left);
        btn_find_next = (ImageView) layout.findViewById(R.id.btn_right);
        edit_find = (EditText) layout.findViewById(R.id.txt_find);

        RelativeLayout layout1 = (RelativeLayout) m_menu_view.MenuGetView();
        view_vert = layout1.findViewById(R.id.view_vert);
        view_horz = layout1.findViewById(R.id.view_horz);
        view_single = layout1.findViewById(R.id.view_single);
        view_dual = layout1.findViewById(R.id.view_dual);
        view_dualv = layout1.findViewById(R.id.view_dualv);

        layout1 = (RelativeLayout) m_menu_tools.MenuGetView();
        view_tool_meta = layout1.findViewById(R.id.view_meta);
        view_tool_find = layout1.findViewById(R.id.view_search);
        view_tool_select = layout1.findViewById(R.id.view_select);
        view_tool_outline = layout1.findViewById(R.id.view_outlines);
        view_tool_undo = layout1.findViewById(R.id.view_undo);
        view_tool_redo = layout1.findViewById(R.id.view_redo);

        layout1 = (RelativeLayout)m_menu_annots.MenuGetView();
        view_annot_ink = layout1.findViewById(R.id.view_ink);
        view_annot_line = layout1.findViewById(R.id.view_line);
        view_annot_rect = layout1.findViewById(R.id.view_rect);
        view_annot_oval = layout1.findViewById(R.id.view_oval);
        view_annot_note = layout1.findViewById(R.id.view_note);
        view_annot_edit = layout1.findViewById(R.id.view_editbox);
        view_annot_stamp = layout1.findViewById(R.id.view_stamp);
        view_annot_polygon = layout1.findViewById(R.id.view_polygon);
        view_annot_polyline = layout1.findViewById(R.id.view_polyline);

        layout1 = (RelativeLayout)m_menu_more.MenuGetView();
        btn_save = layout1.findViewById(R.id.save);
        btn_print = layout1.findViewById(R.id.print);
        btn_share = layout1.findViewById(R.id.share);
        btn_pages_list = layout1.findViewById(R.id.edit_pages);
        btn_add_bookmark = layout1.findViewById(R.id.add_bookmark);
        btn_show_bookmarks = layout1.findViewById(R.id.show_bookmarks);

        layout1 = (RelativeLayout)m_bar_confirm.BarGetView();
        btn_done = layout1.findViewById(R.id.btn_done);
        btn_cancel = layout1.findViewById(R.id.btn_cancel);

        /*
        set Icon colors from Global.toolbar_icon_color
         */
        setIconsColor(Global.toolbar_icon_color);
        btn_back.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { onBackButtonPressed(); if (m_callback != null) m_callback.onClose(); }
        });
        btn_view.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_menu_view.MenuShow(btn_view.getLeft(), m_bar_cmd.BarGetHeight()); }
        });
        btn_tools.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_menu_tools.MenuShow(btn_tools.getLeft(), m_bar_cmd.BarGetHeight()); }
        });
        btn_annot.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_menu_annots.MenuShow(btn_annot.getLeft(), m_bar_cmd.BarGetHeight()); }
        });
        btn_more.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_menu_more.MenuShow(m_parent.getWidth() - m_menu_more.getWidth(), m_bar_cmd.BarGetHeight()); }
        });

        view_tool_select.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_view.PDFSetSelect(); m_sta = 2; m_menu_tools.MenuDismiss(); }
        });
        view_tool_meta.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                CommonUtil.showPDFMeta(m_view, m_parent.getContext(), new CommonUtil.PDFMetaCallback() {
                    @Override
                    public void onModified() {
                        sFileState = MODIFIED_NOT_SAVED;
                    }
                });
                m_menu_tools.MenuDismiss();
            }
        });
        view_tool_outline.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { CommonUtil.showPDFOutlines(m_view, m_parent.getContext()); m_menu_tools.MenuDismiss(); }
        });
        view_tool_find.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_bar_cmd.BarSwitch(m_bar_find);
                if (mNavigationMode == NAVIGATION_THUMBS) m_thumb_view.BarHide();
                else if (mNavigationMode == NAVIGATION_SEEK) m_bar_seek.BarHide();
                m_bar_status = BAR_FIND;
                m_menu_tools.MenuDismiss();
            }
        });
        view_tool_undo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_view.PDFUndo(); m_menu_tools.MenuDismiss(); }
        });
        view_tool_redo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { m_view.PDFRedo(); m_menu_tools.MenuDismiss(); }
        });

        view_annot_ink.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 3;
                m_view.PDFSetInk(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_line.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 7;
                m_view.PDFSetLine(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_rect.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 4;
                m_view.PDFSetRect(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_oval.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 5;
                m_view.PDFSetEllipse(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_note.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 6;
                m_view.PDFSetNote(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_edit.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 9;
                m_view.PDFSetEditbox(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_stamp.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 8;
                m_view.PDFSetStamp(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_polygon.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 10;
                m_view.PDFSetPolygon(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });
        view_annot_polyline.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_sta = 11;
                m_view.PDFSetPolyline(0);
                m_menu_annots.MenuDismiss();
                m_bar_cmd.BarSwitch(m_bar_confirm);
                m_bar_status = BAR_ANNOT;
            }
        });

        btn_save.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { savePDF(); m_menu_more.MenuDismiss(); }
        });
        btn_print.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { printPDF(); m_menu_more.MenuDismiss(); }
        });
        btn_share.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { sharePDF(); m_menu_more.MenuDismiss(); }
        });
        btn_add_bookmark.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { addToBookmarks(); m_menu_more.MenuDismiss(); }
        });
        btn_show_bookmarks.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { showBookmarks(); m_menu_more.MenuDismiss(); }
        });
        btn_find_back.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_bar_find.BarSwitch(m_bar_cmd);
                if (mNavigationMode == NAVIGATION_THUMBS)
                    m_thumb_view.BarShow();
                else if (mNavigationMode == NAVIGATION_SEEK)
                    m_bar_seek.BarShow();
                m_bar_status = BAR_CMD;
                ((InputMethodManager) m_parent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE))
                        .hideSoftInputFromWindow(edit_find.getWindowToken(), 0);
                m_find_str = null;
                m_view.PDFFindEnd();
            }
        });
        btn_find_prev.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { activateSearch(-1); }
        });
        btn_find_next.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) { activateSearch(1); }
        });
        view_vert.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Global.g_view_mode = 0;
                m_view.PDFSetView(0);
                m_menu_view.MenuDismiss();
            }
        });
        view_horz.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Global.g_view_mode = 1;
                m_view.PDFSetView(1);
                m_menu_view.MenuDismiss();
            }
        });
        view_single.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Global.g_view_mode = 3;
                m_view.PDFSetView(3);
                m_menu_view.MenuDismiss();
            }
        });
        view_dual.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Global.g_view_mode = 6;
                m_view.PDFSetView(6);
                m_menu_view.MenuDismiss();
            }
        });
        view_dualv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Global.g_view_mode = 7;
                m_view.PDFSetView(7);
                m_menu_view.MenuDismiss();
            }
        });

        btn_done.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                switch(m_sta) {
                    case 3:
                        m_view.PDFSetInk(1);
                        break;
                    case 4:
                        m_view.PDFSetRect(1);
                        break;
                    case 5:
                        m_view.PDFSetEllipse(1);
                        break;
                    case 6:
                        m_view.PDFSetNote(1);
                        break;
                    case 7:
                        m_view.PDFSetLine(1);
                        break;
                    case 8:
                        m_view.PDFSetStamp(1);
                        break;
                    case 9:
                        m_view.PDFSetEditbox(1);
                        break;
                    case 10:
                        m_view.PDFSetPolygon(1);
                        break;
                    case 11:
                        m_view.PDFSetPolyline(1);
                        break;
                }
                m_bar_confirm.BarSwitch(m_bar_cmd);
                m_bar_status = BAR_CMD;
                m_sta = 0;
            }
        });
        btn_cancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_view.PDFCancelAnnot();
                m_bar_confirm.BarSwitch(m_bar_cmd);
                m_bar_status = BAR_CMD;
                m_sta = 0;
            }
        });

        SetBtnEnabled(btn_annot, m_view.PDFCanSave());
        SetBtnEnabled(btn_save, m_view.PDFCanSave());
        SetBtnEnabled(btn_print, m_view.PDFCanSave());
        SetBtnEnabled(btn_pages_list, m_view.PDFCanSave());

        //show/hide buttons based on writable
        if (!m_view.PDFCanSave()) {
            btn_annot.setVisibility(View.GONE);
            view_tool_redo.setVisibility(View.GONE);
            view_tool_undo.setVisibility(View.GONE);
        }
        RadaeePluginCallback.getInstance().setControllerListener(mControllerListner);
        BookmarkHandler.setDbPath(m_parent.getContext().getFilesDir() + File.separator + "Bookmarks.db");

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) btn_print.setVisibility(View.GONE);
        if (mNavigationMode == NAVIGATION_THUMBS) {
            m_thumb_view = new PDFBotBar(m_parent, R.layout.bar_thumb_view);
            mThumbView = m_thumb_view.BarGetView().findViewById(R.id.thumb_view);
            mThumbView.thumbOpen(m_view.PDFGetDoc(), new PDFViewThumb.PDFThumbListener() {
                @Override
                public void OnPageClicked(int pageno) {
                    m_view.PDFGotoPage(pageno);
                }
            }, Global.g_layout_rtol);
        } else if (mNavigationMode == NAVIGATION_SEEK) {
            m_bar_seek = new PDFBotBar(m_parent, R.layout.bar_seek);
            layout = (RelativeLayout) m_bar_seek.BarGetView();
            lab_page = (TextView) layout.findViewById(R.id.lab_page);
            lab_page.setTextColor(-1);
            seek_page = (SeekBar) layout.findViewById(R.id.seek_page);
            seek_page.setOnSeekBarChangeListener(this);
            seek_page.setMax(m_view.PDFGetDoc().GetPageCount() - 1);
        }

        if (edit_find != null)
        {
            edit_find.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                @Override
                public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                    if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                        activateSearch(1);
                        return true;
                    }
                    return false;
                }
            });
            edit_find.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (hasFocus) {
                        InputMethodManager imm = (InputMethodManager) v.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.showSoftInput(v, InputMethodManager.SHOW_IMPLICIT);
                    }
                }
            });
        }

        btn_save.setVisibility(RadaeePDFManager.sHideSaveButton ? View.GONE : View.VISIBLE);
        btn_more.setVisibility(RadaeePDFManager.sHideMoreButton ? View.GONE : View.VISIBLE);
        btn_print.setVisibility(RadaeePDFManager.sHidePrintButton ? View.GONE : View.VISIBLE);
        btn_annot.setVisibility(RadaeePDFManager.sHideAnnotButton ? View.GONE : View.VISIBLE);
        btn_share.setVisibility(RadaeePDFManager.sHideShareButton ? View.GONE : View.VISIBLE);
        btn_view.setVisibility(RadaeePDFManager.sHideViewModeButton ? View.GONE : View.VISIBLE);
        btn_add_bookmark.setVisibility(RadaeePDFManager.sHideAddBookmarkButton ? View.GONE : View.VISIBLE);
        btn_show_bookmarks.setVisibility(RadaeePDFManager.sHideShowBookmarksButton ? View.GONE : View.VISIBLE);
    }

    public int getFileState() {
        return sFileState;
    }
    public PDFThumbView GetThumbView()
    {
        return mThumbView;
    }
    public void SetPagesListener(OnClickListener listener)
    {
        btn_pages_list.setOnClickListener(listener);
    }
    private void SetBtnEnabled(View btn, boolean enable) {
        if (enable) {
            btn.setEnabled(true);
            btn.setBackgroundColor(0);
            btn.setAlpha(1.0f);
        } else {
            btn.setEnabled(false);
            btn.setBackgroundResource(R.color.btn_disabled_color);
            btn.setAlpha(0.3f);
        }
    }

    /**
     * Set the navigation mode between (thumb view or seekbar)
     *
     * @param navigationMode, the navigation mode must be one of the following values:
     *                        0 (NAVIGATION_THUMBS) for Thumb view mode
     *                        1 (NAVIGATION_SEEK) for seekbar mode
     */
    public void setNavigationMode(int navigationMode) {
        mNavigationMode = navigationMode;
    }

    public void OnAnnotTapped(int pageno, Annotation annot) {
        switch (m_bar_status) {
            case BAR_NONE:
                //if (pageno < 0 && annot == null)
                //{
                //}
                break;
            case BAR_CMD:
                if (annot != null) {
                    m_bar_cmd.BarHide();
                    if (mNavigationMode == NAVIGATION_THUMBS)
                        m_thumb_view.BarHide();
                    else if (mNavigationMode == NAVIGATION_SEEK)
                        m_bar_seek.BarHide();
                    m_bar_status = BAR_NONE;
                }
                break;
            case BAR_FIND:
                if (annot != null) {
                    m_bar_find.BarHide();
                    m_bar_status = BAR_NONE;
                }
                break;
            case BAR_ANNOT:
                if (annot != null) {
                    m_bar_confirm.BarHide();
                    m_bar_status = BAR_NONE;
                }
                break;
        }
    }

    public void OnBlankTapped() {
        switch (m_bar_status) {
            case BAR_NONE:
                m_bar_cmd.BarShow();
                if (mNavigationMode == NAVIGATION_THUMBS)
                    m_thumb_view.BarShow();
                else if (mNavigationMode == NAVIGATION_SEEK)
                    m_bar_seek.BarShow();
                m_bar_status = BAR_CMD;
                break;
            case BAR_CMD:
                m_menu_view.MenuDismiss();
                m_menu_more.MenuDismiss();
                m_bar_cmd.BarHide();

                if (mNavigationMode == NAVIGATION_THUMBS)
                    m_thumb_view.BarHide();
                else if (mNavigationMode == NAVIGATION_SEEK)
                    m_bar_seek.BarHide();
                m_bar_status = BAR_NONE;
                break;
            case BAR_FIND:
                m_bar_find.BarHide();
                m_bar_status = BAR_NONE;
                ((InputMethodManager) m_parent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE))
                        .hideSoftInputFromWindow(edit_find.getWindowToken(), 0);
                break;
            case BAR_ANNOT:
                m_bar_confirm.BarHide();
                m_bar_status = BAR_NONE;
                break;
        }
    }


    public void OnSelectEnd(String text)
    {
        Context context = m_parent.getContext();
        LinearLayout layout = (LinearLayout) LayoutInflater.from(context).inflate(R.layout.dlg_text, null);
        final RadioGroup rad_group = (RadioGroup) layout.findViewById(R.id.rad_group);
        final String sel_text = text;

        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                if (rad_group.getCheckedRadioButtonId() == R.id.rad_copy) {
                    android.content.ClipboardManager clipboard = (android.content.ClipboardManager)context.getSystemService(Context.CLIPBOARD_SERVICE);
                    android.content.ClipData clip = android.content.ClipData.newPlainText("Radaee", sel_text);
                    clipboard.setPrimaryClip(clip);
                    Toast.makeText(context, context.getString(R.string.copy_text, sel_text), Toast.LENGTH_SHORT).show();
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
                        Toast.makeText(context, R.string.annotation_failed, Toast.LENGTH_SHORT).show();
                } else
                    Toast.makeText(context, R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
                dialog.dismiss();
                if (m_sta == 2) {
                    m_view.PDFSetSelect();
                    m_sta = 0;
                }
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                if (m_sta == 2) {
                    m_view.PDFSetSelect();
                    m_sta = 0;
                }
            }
        });
        builder.setTitle(R.string.process_selected_text);
        builder.setCancelable(false);
        builder.setView(layout);
        AlertDialog dlg = builder.create();
        dlg.show();
    }

    @Override
    public void onProgressChanged(SeekBar arg0, int arg1, boolean arg2) {
        lab_page.setText(String.format(Locale.ENGLISH, "%d", arg0.getProgress() + 1));
    }

    @Override
    public void onStartTrackingTouch(SeekBar arg0) {
    }

    @Override
    public void onStopTrackingTouch(SeekBar arg0) {
        m_view.PDFGotoPage(arg0.getProgress());
    }
    private int m_cur_page = 0;
    public void OnPageChanged(int pageno)
    {
        m_cur_page = pageno;
        if (mNavigationMode == NAVIGATION_SEEK) {
            lab_page.setText(String.format(Locale.ENGLISH, "%d", pageno + 1));
            seek_page.setProgress(pageno);
        } else if (mNavigationMode == NAVIGATION_THUMBS)
            mThumbView.thumbGotoPage(pageno);
    }

    public void onPageModified(int pageno) {
        sFileState = MODIFIED_NOT_SAVED;
        if (mNavigationMode == NAVIGATION_THUMBS)
            mThumbView.thumbUpdatePage(pageno);
    }

    public boolean OnBackPressed()
    {
        m_menu_view.MenuDismiss();
        m_menu_tools.MenuDismiss();
        m_menu_annots.MenuDismiss();
        m_menu_more.MenuDismiss();
        switch (m_bar_status) {
            case BAR_NONE:
                return true;
            case BAR_CMD:
                onBackButtonPressed();
                return false;
            case BAR_FIND:
                m_bar_find.BarHide();
                m_bar_status = BAR_NONE;
                ((InputMethodManager) m_parent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(edit_find.getWindowToken(), 0);
                m_find_str = null;
                m_view.PDFFindEnd();
                return false;
            case BAR_ANNOT:
                m_view.PDFCancelAnnot();
                m_bar_confirm.BarHide();
                m_bar_status = BAR_NONE;
                m_sta = 0;
                return false;
            default:
                return false;
        }
    }

    public void onDestroy() {
        if (mThumbView != null) {
            mThumbView.thumbClose();
            mThumbView = null;
        }
    }

    private String m_find_str = null;

    private void activateSearch(int direction) {
        String val = edit_find.getText().toString();
        if (!TextUtils.isEmpty(val)) {
            ((InputMethodManager) m_parent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE))
                    .hideSoftInputFromWindow(edit_find.getWindowToken(), 0);
            val = bidiFormatCheck(val);
            if (!val.equals(m_find_str))
            {
                m_find_str = val;
                m_view.PDFFindStart(val, Global.g_case_sensitive, Global.g_match_whole_word);
            }
            m_view.PDFFind(direction);
        }
    }

    void savePDF() {
        if (m_view.PDFSave()) {
            sFileState = MODIFIED_AND_SAVED;
            Toast.makeText(m_parent.getContext(), R.string.saved_message, Toast.LENGTH_SHORT).show();
        }
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private void printPDF() {
        PrintManager mPrintManager = (PrintManager) m_parent.getContext().getSystemService(Context.PRINT_SERVICE);
        String mJobName = "";
        String path = (m_callback != null) ? m_callback.getPath() : null;
        if (!TextUtils.isEmpty(path)) {
            mJobName += TextUtils.substring(path, path.lastIndexOf("/") + 1, path.length()).replace(".pdf", "_print.pdf");
        } else {
            String docName = UUID.randomUUID().toString() + ".pdf";
            mJobName += TextUtils.substring(docName, docName.lastIndexOf("/") + 1, docName.length()).replace(".pdf", "_print.pdf");
        }

        final String finalJobName = mJobName;
        mPrintManager.print(mJobName, new PrintDocumentAdapter() {
            int mTotalPages = 0;

            @Override
            public void onLayout(PrintAttributes oldAttributes, PrintAttributes newAttributes, CancellationSignal cancellationSignal,
                                 LayoutResultCallback callback, Bundle extras) {
                mTotalPages = m_view.PDFGetDoc().GetPageCount();

                if (cancellationSignal.isCanceled()) { // Respond to cancellation request
                    callback.onLayoutCancelled();
                    return;
                }

                if (mTotalPages > 0) { // Return print information to print framework
                    PrintDocumentInfo info = new PrintDocumentInfo
                            .Builder(finalJobName)
                            .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
                            .setPageCount(mTotalPages)
                            .build();
                    // Content layout reflow is complete
                    callback.onLayoutFinished(info, true);
                } else { // Otherwise report an error to the print framework
                    callback.onLayoutFailed(m_parent.getContext().getString(R.string.pdf_print_calculation_failed));
                }
            }

            @Override
            public void onWrite(PageRange[] pages, ParcelFileDescriptor destination, CancellationSignal cancellationSignal, WriteResultCallback callback)
            {
                OutputStream output = new FileOutputStream(destination.getFileDescriptor());
                Document.PDFStream stream = (m_callback != null) ? m_callback.getStream() : null;
                if (stream != null)
                {
                    try {
                        if (cancellationSignal.isCanceled())
                        {
                            callback.onWriteCancelled();
                            output.close();
                            return;
                        }
                        if (stream.save(output))//save in thread safe mode.
                            callback.onWriteFinished(new PageRange[]{PageRange.ALL_PAGES});
                        else
                            callback.onWriteFailed(m_parent.getContext().getString(R.string.pdf_print_not_available));
                        output.close();
                    } catch (Exception ex) {
                        callback.onWriteFailed(ex.toString());
                    }
                }
                else
                {
                    String path = (m_callback != null) ? m_callback.getPath() : null;
                    InputStream input;
                    byte[] buf = new byte[1024];
                    int bytesRead;
                    try
                    {
                        if (!TextUtils.isEmpty(path))
                        {
                            input = new FileInputStream(path);
                            // check for cancellation
                            if (cancellationSignal.isCanceled())
                            {
                                callback.onWriteCancelled();
                                input.close();
                                output.close();
                                return;
                            }
                            while ((bytesRead = input.read(buf)) > 0)
                                output.write(buf, 0, bytesRead);
                            callback.onWriteFinished(new PageRange[]{PageRange.ALL_PAGES});
                            input.close();
                            output.close();
                        } else
                            callback.onWriteFailed(m_parent.getContext().getString(R.string.pdf_print_not_available));
                    } catch (Exception e) {
                        e.printStackTrace();
                        callback.onWriteFailed(e.toString());
                    }
                }
            }
        }, null);
    }

    private void sharePDF() {
        String path = (m_callback != null) ? m_callback.getPath() : null;
        if (!TextUtils.isEmpty(path)) {
            File outputFile = new File(path);
            Uri uri = Uri.fromFile(outputFile);

            Intent share = new Intent();
            share.setAction(Intent.ACTION_SEND);
            share.setType("application/pdf");
            share.putExtra(Intent.EXTRA_STREAM, uri);

            m_parent.getContext().startActivity(share);
        } else {
            Toast.makeText(m_parent.getContext(), R.string.pdf_share_not_available, Toast.LENGTH_SHORT).show();
        }
    }

    private String bidiFormatCheck(String input) {
        if (Global.g_sel_rtol) { //selection is right to left, check case of mixed text
            Bidi bidi = new Bidi(input, Bidi.DIRECTION_DEFAULT_RIGHT_TO_LEFT);
            if (bidi.isMixed() || bidi.isLeftToRight()) { //we need to reverse mixed text
                String reversedVal = "", toBeReversed = "";
                int baseLevel = bidi.getBaseLevel();
                for (int i = 0; i < bidi.getLength(); i++) {
                    if (bidi.getLevelAt(i) != baseLevel || bidi.isLeftToRight()) { //mixed char, save it
                        toBeReversed += input.charAt(i);
                        if (i + 1 == bidi.getLength() ||
                                (i + 1 < bidi.getLength() && bidi.getLevelAt(i + 1) == baseLevel && !bidi.isLeftToRight())) { //reverse and append to reversed text
                            reversedVal += new StringBuilder(toBeReversed).reverse().toString();
                            toBeReversed = "";
                        }
                    } else
                        reversedVal += input.charAt(i);

                }
                input = reversedVal;
            }
        }
        return input;
    }

    public String getFindQuery() {
        return m_find_str;
    }

    private void addToBookmarks() {
        try {
            String path = (m_callback != null) ? m_callback.getPath() : null;
            if (!TextUtils.isEmpty(path)) {
                String bookmarkLabel = m_parent.getContext().getString(R.string.bookmark_label, m_cur_page + 1);
                RadaeePDFManager mPDFManager = new RadaeePDFManager();
                Toast.makeText(m_parent.getContext(), mPDFManager.addToBookmarks(m_parent.getContext(), path,
                        m_cur_page, bookmarkLabel), Toast.LENGTH_SHORT).show();
            } else
                Toast.makeText(m_parent.getContext(), R.string.bookmark_error, Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void showBookmarks() {
        String path = (m_callback != null) ? m_callback.getPath() : null;
        if (!TextUtils.isEmpty(path))
            BookmarkHandler.showBookmarks(m_parent.getContext(), path, new BookmarkHandler.BookmarkListener() {
                @Override
                public void onBookmarkClickedListener(int pageno) {
                    m_view.PDFGotoPage(pageno);
                }
            });
        else
            Toast.makeText(m_parent.getContext(), R.string.bookmark_error, Toast.LENGTH_SHORT).show();
    }
    private final RadaeePluginCallback.PDFControllerListener mControllerListner = new RadaeePluginCallback.PDFControllerListener() {
        @Override
        public void onSetIconsBGColor(int color) {
            try {
                Global.toolbar_icon_color = color;
                setIconsColor(color);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        @Override
        public void onSetToolbarBGColor(int color) {
            try {
                m_bar_cmd.BarGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
                m_bar_confirm.BarGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
                m_menu_view.MenuGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
                m_menu_more.MenuGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        @Override
        public void onSetImmersive(boolean immersive) {
            switch (m_bar_status) {
                case BAR_NONE:
                    if (!immersive) {
                        m_bar_cmd.BarShow();
                        if (mNavigationMode == NAVIGATION_THUMBS)
                            m_thumb_view.BarShow();
                        else if (mNavigationMode == NAVIGATION_SEEK)
                            m_bar_seek.BarShow();
                        m_bar_status = BAR_CMD;
                    }
                    break;
                case BAR_CMD:
                    if (immersive) {
                        m_menu_view.MenuDismiss();
                        m_menu_more.MenuDismiss();
                        m_bar_cmd.BarHide();
                        if (mNavigationMode == NAVIGATION_THUMBS)
                            m_thumb_view.BarHide();
                        else if (mNavigationMode == NAVIGATION_SEEK)
                            m_bar_seek.BarHide();
                        m_bar_status = BAR_NONE;
                    }
                    break;
                case BAR_FIND:
                    if (immersive) {
                        m_bar_find.BarHide();
                        m_bar_status = BAR_NONE;
                    }
                    break;
                case BAR_ANNOT:
                    if (immersive) {
                        m_bar_confirm.BarHide();
                        m_bar_status = BAR_NONE;
                    }
                    break;
            }
        }
        @Override
        public String onGetJsonFormFields() {
            try {
                if (m_view.PDFGetDoc() != null && m_view.PDFGetDoc().IsOpened()) {
                    JSONArray mPages = new JSONArray();
                    for (int i = 0; i < m_view.PDFGetDoc().GetPageCount(); i++) {
                        Page mPage = m_view.PDFGetDoc().GetPage(i);
                        mPage.ObjsStart();
                        JSONObject mResult = CommonUtil.constructPageJsonFormFields(mPage, i);
                        if (mResult != null)
                            mPages.put(mResult);
                    }

                    if (mPages.length() > 0) {
                        JSONObject mPageJson = new JSONObject();
                        mPageJson.put("Pages", mPages);
                        return mPageJson.toString();
                    }
                    return "";
                } else
                    return "Document not set";
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return "ERROR";
        }
        @Override
        public String onGetJsonFormFieldsAtPage(int pageno) {
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened())
                return "Document not set";
            if (pageno >= m_view.PDFGetDoc().GetPageCount()) return "Page index error";

            Page mPage = m_view.PDFGetDoc().GetPage(pageno);
            JSONObject mResult = CommonUtil.constructPageJsonFormFields(mPage, pageno);
            mPage.Close();
            if (mResult != null)
                return mResult.toString();
            else
                return "";
        }
        @Override
        public String onSetFormFieldsWithJSON(String json) {
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened())
                return "Document not set";
            if (!m_view.PDFCanSave()) return "Document instance is readonly";
            try {
                JSONObject pages = new JSONObject(json);
                if (pages.optJSONArray("Pages") != null) {
                    JSONArray pagesArray = pages.optJSONArray("Pages");
                    int cnt = (pagesArray != null) ? pagesArray.length() : 0;
                    for (int i = 0; i < cnt; i++) {
                        CommonUtil.parsePageJsonFormFields(pagesArray.getJSONObject(i), m_view.PDFGetDoc());
                    }
                    m_view.PDFUpdatePage(m_cur_page);
                    return "property set successfully";
                } else return "\"Pages\" attribute is missing";
            } catch (Exception e) {
                e.printStackTrace();
            }
            return "ERROR";
        }
        @Override
        public int onGetPageCount() {
            if (m_view.PDFGetDoc() != null && m_view.PDFGetDoc().IsOpened())
                return m_view.PDFGetDoc().GetPageCount();
            return -1;
        }
        @Override
        public String onGetPageText(int pageno) {
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened())
                return "Document not set";
            if (pageno >= m_view.PDFGetDoc().GetPageCount()) return "Page index error";
            return CommonUtil.getPageText(m_view.PDFGetDoc(), pageno);
        }
        @Override
        public boolean onEncryptDocAs(String dst, String upswd, String opswd, int perm, int method, byte[] id) {
            return !(m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened())
                    && m_view.PDFGetDoc().EncryptAs(dst, upswd, opswd, perm, method, id);
        }
        @Override
        public boolean onAddAnnotAttachment(String attachmentPath) {
            return !(m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened() || !m_view.PDFCanSave())
                    && m_view.PDFSetAttachment(attachmentPath);
        }
        @Override
        public String renderAnnotToFile(int page, int annotIndex, String renderPath, int bitmapWidth, int bitmapHeight) {
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened())
                return "Document not set";
            if (page >= m_view.PDFGetDoc().GetPageCount()) return "Page index error";
            return CommonUtil.renderAnnotToFile(m_view.PDFGetDoc(), page, annotIndex, renderPath, bitmapWidth, bitmapHeight);
        }
        @Override
        public boolean flatAnnotAtPage(int page) {
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened()) return false;
            if (page >= m_view.PDFGetDoc().GetPageCount()) return false;
            Page ppage = m_view.PDFGetDoc().GetPage(page);
            if (ppage != null) {
                boolean res = ppage.FlatAnnots();
                if (res && page == m_cur_page) {
                    m_view.PDFUpdatePage(m_cur_page);
                    return true;
                }
            }
            return false;
        }
        @Override
        public boolean flatAnnots() {
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened()) return false;
            for (int i = 0; i < m_view.PDFGetDoc().GetPageCount(); i++) {
                if (!this.flatAnnotAtPage(i))
                    return false;
            }
            return true;
        }
        @Override
        public boolean saveDocumentToPath(String path, String pswd) {
            String prefix = "file://";
            if (path.contains(prefix)) {
                path = path.substring(path.indexOf(prefix) + prefix.length());
            }
            if (m_view.PDFGetDoc() == null || !m_view.PDFGetDoc().IsOpened()) return false;
            if (m_view.PDFGetDoc().IsEncrypted()) {
                byte[] id = "123456789abcdefghijklmnopqrstuvw".getBytes();
                return m_view.PDFGetDoc().EncryptAs(path, pswd, pswd, 0x4, 4, id);
            } else {
                return m_view.PDFGetDoc().SaveAs(path, false);
            }
        }
        @Override
        public String onGetTextAnnotationDetails(int pageno) {
            Page page = m_view.PDFGetDoc().GetPage(pageno);
            JSONArray jsonArray = new JSONArray();
            try {
                for (int i = 0; i < page.GetAnnotCount(); i++) {
                    Annotation annotation = page.GetAnnot(i);
                    if (annotation.GetType()==1) {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("left",annotation.GetRect()[0]);
                        jsonObject.put("bottom",annotation.GetRect()[1]);
                        jsonObject.put("right",annotation.GetRect()[2]);
                        jsonObject.put("top",annotation.GetRect()[3]);
                        jsonObject.put("subject",annotation.GetPopupSubject());
                        jsonObject.put("text",annotation.GetPopupText());
                        jsonArray.put(jsonObject);
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            page.Close();
            return jsonArray.toString();
        }
        @Override
        public String onGetMarkupAnnotationDetails(int pageno) {
            Page page = m_view.PDFGetDoc().GetPage(pageno);
            JSONArray jsonArray = new JSONArray();
            for (int i = 0; i < page.GetAnnotCount(); i++) {
                Annotation annotation = page.GetAnnot(i);
                if (annotation.GetType()>= 9 && annotation.GetType() <= 12) {
                    try {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("left",annotation.GetRect()[0]);
                        jsonObject.put("bottom",annotation.GetRect()[1]);
                        jsonObject.put("right",annotation.GetRect()[2]);
                        jsonObject.put("top",annotation.GetRect()[3]);
                        jsonObject.put("type",annotation.GetType());
                        jsonArray.put(jsonObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
            page.Close();
            return jsonArray.toString();
        }
        @Override
        public int onGetCharIndex(int pageno, float x, float y) {
            Page page = m_view.PDFGetDoc().GetPage(pageno);
            page.ObjsStart();
            float[] pt = new float[] {x,y};
            int result = page.ObjsGetCharIndex(pt);
            page.Close();
            return result;
        }
        @Override
        public void onAddTextAnnotation(int pageno, float x, float y, String text, String subject) {
            Page page = m_view.PDFGetDoc().GetPage(pageno);
            float[] pt = new float[] {x,y};
            page.AddAnnotText(pt);
            Annotation annotation = page.GetAnnot(page.GetAnnotCount()-1);
            annotation.SetPopupText(text);
            annotation.SetPopupSubject(subject);
            page.Close();
            m_view.PDFUpdatePage(pageno);
        }
        @Override
        public void onAddMarkupAnnotation(int pageno, int type, int index1, int index2) {
            Page page = m_view.PDFGetDoc().GetPage(pageno);
            page.ObjsStart();
            boolean success = page.AddAnnotMarkup(index1, index2, type);
            page.Close();
            if(success) m_view.PDFUpdatePage(pageno);
        }
        @Override
        public String onGetPDFCoordinates(int x, int y) {
            JSONObject jsonObject = new JSONObject();
            float pdfX;
            float pdfY;
            int pageno;
            if (m_view instanceof PDFLayoutView) {
                PDFLayoutView pdfLayoutView = (PDFLayoutView) m_view;
                PDFLayout.PDFPos pdfPos = pdfLayoutView.PDFGetPos(x, y);
                if (pdfPos == null) return "ERROR";
                pdfX = pdfPos.x;
                pdfY = pdfPos.y;
                pageno = pdfPos.pageno;
            }
            else if (m_view instanceof PDFGLLayoutView) {
                PDFGLLayoutView pdfLayoutView = (PDFGLLayoutView) m_view;
                GLLayout.PDFPos pdfPos = pdfLayoutView.PDFGetPos(x, y);
                if (pdfPos == null) return "ERROR";
                pdfX = pdfPos.x;
                pdfY = pdfPos.y;
                pageno = pdfPos.pageno;
            }
            else return "ERROR";
            try {
                jsonObject.put("x", pdfX);
                jsonObject.put("y", pdfY);
                jsonObject.put("pageno", pageno);
            } catch (JSONException e) {
                return "ERROR";
            }
            return jsonObject.toString();
        }
        @Override
        public String onGetScreenCoordinates(int pageno, float x, float y) {
            int screenX = m_view.GetScreenX(x,pageno) ;
            int screenY = m_view.GetScreenY(y,pageno);

            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("x", screenX);
                jsonObject.put("y", screenY);

            } catch (JSONException e) {
                return "ERROR";
            }
            return jsonObject.toString();

        }
        @Override
        public String onGetScreenRect(int pageno, float left, float top, float right, float bottom) {
            int screenLeft = m_view.GetScreenX(left,pageno) ;
            int screenRight = m_view.GetScreenX(right,pageno);
            int screenTop = m_view.GetScreenY(top,pageno);
            int screenBottom = m_view.GetScreenY(bottom,pageno);

            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("left", screenLeft);
                jsonObject.put("top", screenTop);
                jsonObject.put("right", screenRight);
                jsonObject.put("bottom", screenBottom);
                jsonObject.put("pageno", pageno);
            } catch (JSONException e) {
                return "ERROR";
            }
            return jsonObject.toString();
        }
        @Override
        public String onGetPDFRect(int left, int top, int right, int bottom) {
            JSONObject jsonObject = new JSONObject();
            float pdfLeft;
            float pdfTop;
            float pdfRight;
            float pdfBottom;
            int pageno;
            if (m_view instanceof PDFLayoutView) {
                PDFLayoutView pdfLayoutView = (PDFLayoutView) m_view;
                PDFLayout.PDFPos pdfPos1 = pdfLayoutView.PDFGetPos(left, top);
                if (pdfPos1 == null) return "ERROR";
                pdfLeft = pdfPos1.x;
                pdfTop = pdfPos1.y;

                PDFLayout.PDFPos pdfPos2 = pdfLayoutView.PDFGetPos(right, bottom);
                if (pdfPos2 == null) return "ERROR";
                pdfRight = pdfPos2.x;
                pdfBottom = pdfPos2.y;

                pageno = pdfPos1.pageno;
            }
            else if (m_view instanceof PDFGLLayoutView) {
                PDFGLLayoutView pdfLayoutView = (PDFGLLayoutView) m_view;
                GLLayout.PDFPos pdfPos1 = pdfLayoutView.PDFGetPos(left, top);
                if (pdfPos1 == null) return "ERROR";
                pdfLeft = pdfPos1.x;
                pdfTop = pdfPos1.y;

                GLLayout.PDFPos pdfPos2 = pdfLayoutView.PDFGetPos(right, bottom);
                if (pdfPos2 == null) return "ERROR";
                pdfRight = pdfPos2.x;
                pdfBottom = pdfPos2.y;

                pageno = pdfPos1.pageno;
            }
            else return "ERROR";
            try {
                jsonObject.put("left", pdfLeft);
                jsonObject.put("top", pdfTop);
                jsonObject.put("right", pdfRight);
                jsonObject.put("bottom", pdfBottom);
                jsonObject.put("pageno", pageno);
            } catch (JSONException e) {
                return "ERROR";
            }
            return jsonObject.toString();
        }

    };
}