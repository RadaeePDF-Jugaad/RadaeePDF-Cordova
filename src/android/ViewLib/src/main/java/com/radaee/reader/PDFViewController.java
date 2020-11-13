package com.radaee.reader;

import android.annotation.TargetApi;
import android.content.Context;
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
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

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

public class PDFViewController implements OnClickListener, SeekBar.OnSeekBarChangeListener {
    static final public int NOT_MODIFIED = 0;
    static final public int MODIFIED_NOT_SAVED = 1;
    static final public int MODIFIED_AND_SAVED = 2;
    static private int sFileState = NOT_MODIFIED;
    static public final int BAR_NONE = 0;
    static public final int BAR_CMD = 1;
    static public final int BAR_ANNOT = 2;
    static public final int BAR_FIND = 3;
    static public final int NAVIGATION_THUMBS = 0;
    static public final int NAVIGATION_SEEK = 1;
    private int m_bar_status = 0;
    private int mNavigationMode = Global.navigationMode;
    private RelativeLayout m_parent;
    private ILayoutView m_view;
    private PDFTopBar m_bar_cmd;
    private PDFTopBar m_bar_find;
    private PDFTopBar m_bar_annot;
    private PDFBotBar m_bar_seek;
    private PDFBotBar m_thumb_view;
    private PDFMenu m_menu_view;
    private PDFMenu m_menu_more;
    private ImageView btn_view;
    private ImageView btn_find;
    private ImageView btn_annot;
    private ImageView btn_select;
    private ImageView btn_outline;
    private ImageView btn_undo;
    private ImageView btn_redo;
    private ImageView btn_more;
    private View btn_pages_list;
    private View btn_add_bookmark;
    private View btn_show_bookmarks;
    private View btn_save;
    private View btn_print;
    private View btn_share;
    private ImageView btn_find_back;
    private ImageView btn_find_prev;
    private ImageView btn_find_next;
    private ImageView btn_annot_back;
    private ImageView btn_annot_ink;
    private ImageView btn_annot_line;
    private ImageView btn_annot_rect;
    private ImageView btn_annot_oval;
    private ImageView btn_annot_stamp;
    private ImageView btn_annot_note;
    private ImageView btn_annot_editbox;
    private ImageView btn_annot_polygon;
    private ImageView btn_annot_polyline;
    private EditText edit_find;
    private SeekBar seek_page;
    private TextView lab_page;
    private View view_vert;
    private View view_horz;
    private View view_single;
    private View view_dual;
    private boolean m_set = false;
    private PDFThumbView mThumbView;
    private boolean m_isAsset;
    private String m_docPath;
    public PDFViewController(RelativeLayout parent, ILayoutView view, String docPath, boolean isAsset) {
        m_parent = parent;
        m_view = view;
        m_docPath = docPath;
        m_isAsset = isAsset;
        sFileState = NOT_MODIFIED;
        m_bar_cmd = new PDFTopBar(m_parent, R.layout.bar_cmd);
        m_bar_find = new PDFTopBar(m_parent, R.layout.bar_find);
        m_bar_annot = new PDFTopBar(m_parent, R.layout.bar_annot);
        m_menu_view = new PDFMenu(m_parent, R.layout.pop_view, 160, 180);
        m_menu_more = new PDFMenu(m_parent, R.layout.pop_more, 180, 220);
        RelativeLayout layout = (RelativeLayout) m_bar_cmd.BarGetView();
        btn_view = (ImageView) layout.findViewById(R.id.btn_view);
        btn_find = (ImageView) layout.findViewById(R.id.btn_find);
        btn_annot = (ImageView) layout.findViewById(R.id.btn_annot);
        btn_select = (ImageView) layout.findViewById(R.id.btn_select);
        btn_outline = (ImageView) layout.findViewById(R.id.btn_outline);
        btn_undo = (ImageView) layout.findViewById(R.id.btn_undo);
        btn_redo = (ImageView) layout.findViewById(R.id.btn_redo);
        btn_more = (ImageView) layout.findViewById(R.id.btn_more);
        layout = (RelativeLayout) m_bar_find.BarGetView();
        btn_find_back = (ImageView) layout.findViewById(R.id.btn_back);
        btn_find_prev = (ImageView) layout.findViewById(R.id.btn_left);
        btn_find_next = (ImageView) layout.findViewById(R.id.btn_right);
        edit_find = (EditText) layout.findViewById(R.id.txt_find);
        layout = (RelativeLayout) m_bar_annot.BarGetView();
        btn_annot_back = (ImageView) layout.findViewById(R.id.btn_back);
        btn_annot_ink = (ImageView) layout.findViewById(R.id.btn_annot_ink);
        btn_annot_polygon = (ImageView) layout.findViewById(R.id.btn_annot_polygon);
        btn_annot_polyline = (ImageView) layout.findViewById(R.id.btn_annot_polyline);
        btn_annot_line = (ImageView) layout.findViewById(R.id.btn_annot_line);
        btn_annot_rect = (ImageView) layout.findViewById(R.id.btn_annot_rect);
        btn_annot_oval = (ImageView) layout.findViewById(R.id.btn_annot_oval);
        btn_annot_stamp = (ImageView) layout.findViewById(R.id.btn_annot_stamp);
        btn_annot_note = (ImageView) layout.findViewById(R.id.btn_annot_note);
        btn_annot_editbox = (ImageView) layout.findViewById(R.id.btn_annot_editbox);
        RelativeLayout layout1 = (RelativeLayout) m_menu_view.MenuGetView();
        view_vert = layout1.findViewById(R.id.view_vert);
        view_horz = layout1.findViewById(R.id.view_horz);
        view_single = layout1.findViewById(R.id.view_single);
        view_dual = layout1.findViewById(R.id.view_dual);
        RelativeLayout moreLayout = (RelativeLayout) m_menu_more.MenuGetView();
        btn_save = moreLayout.findViewById(R.id.save);
        btn_print = moreLayout.findViewById(R.id.print);
        btn_share = moreLayout.findViewById(R.id.share);
        btn_pages_list = moreLayout.findViewById(R.id.edit_pages);
        btn_add_bookmark = moreLayout.findViewById(R.id.add_bookmark);
        btn_show_bookmarks = moreLayout.findViewById(R.id.show_bookmarks);

        btn_view.setOnClickListener(this);
        btn_find.setOnClickListener(this);
        btn_annot.setOnClickListener(this);
        btn_select.setOnClickListener(this);
        btn_outline.setOnClickListener(this);
        btn_undo.setOnClickListener(this);
        btn_redo.setOnClickListener(this);
        btn_more.setOnClickListener(this);
        btn_save.setOnClickListener(this);
        btn_print.setOnClickListener(this);
        btn_share.setOnClickListener(this);
        btn_add_bookmark.setOnClickListener(this);
        btn_show_bookmarks.setOnClickListener(this);
        btn_find_back.setOnClickListener(this);
        btn_find_prev.setOnClickListener(this);
        btn_find_next.setOnClickListener(this);
        btn_annot_back.setOnClickListener(this);
        btn_annot_ink.setOnClickListener(this);
        btn_annot_polygon.setOnClickListener(this);
        btn_annot_polyline.setOnClickListener(this);
        btn_annot_line.setOnClickListener(this);
        btn_annot_rect.setOnClickListener(this);
        btn_annot_oval.setOnClickListener(this);
        btn_annot_stamp.setOnClickListener(this);
        btn_annot_note.setOnClickListener(this);
        btn_annot_editbox.setOnClickListener(this);
        view_vert.setOnClickListener(this);
        view_horz.setOnClickListener(this);
        view_single.setOnClickListener(this);
        view_dual.setOnClickListener(this);
        SetBtnEnabled(btn_annot, m_view.PDFCanSave());
        SetBtnEnabled(btn_save, m_view.PDFCanSave());
        SetBtnEnabled(btn_print, m_view.PDFCanSave() || m_isAsset);
        //SetBtnEnabled(btn_share, m_view.PDFCanSave());

        //Nermeen, show/hide buttons based on license type
        if (Global.isLicenseActivated()) {
            if (Global.mLicenseType == 0) {
                btn_annot.setVisibility(View.GONE);
                btn_select.setVisibility(View.GONE);
                btn_undo.setVisibility(View.GONE);
                btn_redo.setVisibility(View.GONE);
            }
        } else {
            btn_find.setVisibility(View.GONE);
            btn_annot.setVisibility(View.GONE);
            btn_select.setVisibility(View.GONE);
            btn_undo.setVisibility(View.GONE);
            btn_redo.setVisibility(View.GONE);
        }
        RadaeePluginCallback.getInstance().setControllerListener(mControllerListner);
        BookmarkHandler.setDbPath(m_parent.getContext().getFilesDir() + File.separator + "Bookmarks.db");

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT)
            btn_print.setVisibility(View.GONE);

        if (mNavigationMode == NAVIGATION_THUMBS) {
            m_thumb_view = new PDFBotBar(m_parent, R.layout.thumb_view);
            mThumbView = m_thumb_view.BarGetView().findViewById(R.id.thumb_view);

            mThumbView.thumbOpen(m_view.PDFGetDoc(), new PDFViewThumb.PDFThumbListener() {
                @Override
                public void OnPageClicked(int pageno) {
                    m_view.PDFGotoPage(pageno);
                }
            }, Global.rtol);
        } else if (mNavigationMode == NAVIGATION_SEEK) {
            m_bar_seek = new PDFBotBar(m_parent, R.layout.bar_seek);
            layout = (RelativeLayout) m_bar_seek.BarGetView();
            lab_page = (TextView) layout.findViewById(R.id.lab_page);
            lab_page.setTextColor(-1);
            seek_page = (SeekBar) layout.findViewById(R.id.seek_page);
            seek_page.setOnSeekBarChangeListener(this);
            seek_page.setMax(m_view.PDFGetDoc().GetPageCount() - 1);
        }

        if (edit_find != null) {
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
        btn_undo.setVisibility(RadaeePDFManager.sHideUndoButton ? View.GONE : View.VISIBLE);
        btn_redo.setVisibility(RadaeePDFManager.sHideRedoButton ? View.GONE : View.VISIBLE);
        btn_print.setVisibility(RadaeePDFManager.sHidePrintButton ? View.GONE : View.VISIBLE);
        btn_annot.setVisibility(RadaeePDFManager.sHideAnnotButton ? View.GONE : View.VISIBLE);
        btn_find.setVisibility(RadaeePDFManager.sHideSearchButton ? View.GONE : View.VISIBLE);
        btn_share.setVisibility(RadaeePDFManager.sHideShareButton ? View.GONE : View.VISIBLE);
        btn_select.setVisibility(RadaeePDFManager.sHideSelectButton ? View.GONE : View.VISIBLE);
        btn_view.setVisibility(RadaeePDFManager.sHideViewModeButton ? View.GONE : View.VISIBLE);
        btn_outline.setVisibility(RadaeePDFManager.sHideOutlineButton ? View.GONE : View.VISIBLE);
        btn_add_bookmark.setVisibility(RadaeePDFManager.sHideAddBookmarkButton ? View.GONE : View.VISIBLE);
        btn_show_bookmarks.setVisibility(RadaeePDFManager.sHideShowBookmarksButton ? View.GONE : View.VISIBLE);
    }

    public static int getFileState() {
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
        } else {
            btn.setEnabled(false);
            btn.setBackgroundResource(R.color.btn_disabled_color);
        }
    }

    private void SetBtnChecked(ImageView btn, boolean check) {
        if (check)
            btn.setBackgroundResource(R.color.btn_pressed_color);
        else
            btn.setBackgroundColor(0);
        m_set = check;
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

    public void OnAnnotTapped(Annotation annot) {
        switch (m_bar_status) {
            case BAR_NONE:
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
                    m_bar_annot.BarHide();
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
                m_bar_annot.BarHide();
                m_bar_status = BAR_NONE;
                break;
        }
    }

    public void OnSelectEnd() {
        m_view.PDFSetSelect();
        SetBtnChecked(btn_select, false);
        SetBtnEnabled(btn_view, true);
        SetBtnEnabled(btn_find, true);
        SetBtnEnabled(btn_annot, m_view.PDFCanSave());
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

    public void OnPageChanged(int pageno) {
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

    public void onConfigChanged() {
    }

    public boolean OnBackPressed() {
        switch (m_bar_status) {
            case BAR_NONE:
                return true;
            case BAR_CMD:
                if (m_set) OnSelectEnd();
                m_menu_view.MenuDismiss();
                m_menu_more.MenuDismiss();
                m_bar_cmd.BarHide();

                if (mNavigationMode == NAVIGATION_THUMBS)
                    m_thumb_view.BarHide();
                else if (mNavigationMode == NAVIGATION_SEEK)
                    m_bar_seek.BarHide();
                m_bar_status = BAR_NONE;
                return false;
            case BAR_FIND:
                m_bar_find.BarHide();
                m_bar_status = BAR_NONE;
                ((InputMethodManager) m_parent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE))
                        .hideSoftInputFromWindow(edit_find.getWindowToken(), 0);
                m_find_str = null;
                m_view.PDFFindEnd();
                return false;
            case BAR_ANNOT:
                if (m_set) {
                    m_view.PDFCancelAnnot();
                    m_set = false;
                    boolean can_save = m_view.PDFCanSave();
                    SetBtnEnabled(btn_annot_ink, can_save);
                    SetBtnEnabled(btn_annot_polygon, can_save);
                    SetBtnEnabled(btn_annot_polyline, can_save);
                    SetBtnEnabled(btn_annot_line, can_save);
                    SetBtnEnabled(btn_annot_rect, can_save);
                    SetBtnEnabled(btn_annot_oval, can_save);
                    SetBtnEnabled(btn_annot_stamp, can_save);
                    SetBtnEnabled(btn_annot_note, can_save);
                    SetBtnEnabled(btn_annot_editbox, can_save);
                }
                m_bar_annot.BarHide();
                m_bar_status = BAR_NONE;
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

    @Override
    public void onClick(View arg0) {
        if (arg0 == btn_view)//popup view list
        {
            m_menu_view.MenuShow(0, m_bar_cmd.BarGetHeight());
        } else if (arg0 == btn_select) {
            if (m_set) OnSelectEnd();
            else {
                m_view.PDFSetSelect();
                SetBtnChecked(btn_select, true);
                SetBtnEnabled(btn_view, false);
                SetBtnEnabled(btn_find, false);
                SetBtnEnabled(btn_annot, false);
            }
        } else if (arg0 == btn_outline) {
            CommonUtil.showPDFOutlines(m_view, m_parent.getContext());
        } else if (arg0 == btn_find) {
            m_bar_cmd.BarSwitch(m_bar_find);

            if (mNavigationMode == NAVIGATION_THUMBS)
                m_thumb_view.BarHide();
            else if (mNavigationMode == NAVIGATION_SEEK)
                m_bar_seek.BarHide();
            m_bar_status = BAR_FIND;
        } else if (arg0 == btn_undo) {
            m_view.PDFUndo();
        } else if (arg0 == btn_redo) {
            m_view.PDFRedo();
        } else if (arg0 == btn_more) {
            m_menu_more.MenuShow(m_parent.getWidth() - m_menu_more.getWidth(), m_bar_cmd.BarGetHeight());
        } else if (arg0 == btn_save) {
            savePDF();
            m_menu_more.MenuDismiss();
        } else if (arg0 == btn_print) {
            printPDF();
            m_menu_more.MenuDismiss();
        } else if (arg0 == btn_share) {
            sharePDF();
            m_menu_more.MenuDismiss();
        } else if (arg0 == btn_add_bookmark) {
            addToBookmarks();
            m_menu_more.MenuDismiss();
        } else if (arg0 == btn_show_bookmarks) {
            showBookmarks();
            m_menu_more.MenuDismiss();
        } else if (arg0 == btn_find_prev) {
            activateSearch(-1);
        } else if (arg0 == btn_find_next) {
            activateSearch(1);
        } else if (arg0 == btn_annot) {
            m_bar_cmd.BarSwitch(m_bar_annot);

            if (mNavigationMode == NAVIGATION_THUMBS)
                m_thumb_view.BarHide();
            else if (mNavigationMode == NAVIGATION_SEEK)
                m_bar_seek.BarHide();
            m_bar_status = BAR_ANNOT;
        } else if (arg0 == btn_annot_ink) {
            if (m_set) {
                m_view.PDFSetInk(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetInk(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnChecked(btn_annot_ink, true);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_polygon) {
            if (m_set) {
                m_view.PDFSetPolygon(1);
                SetBtnChecked(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetPolygon(0);
                SetBtnChecked(btn_annot_polygon, true);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_polyline) {
            if (m_set) {
                m_view.PDFSetPolyline(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetPolyline(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnChecked(btn_annot_polyline, true);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_line) {
            if (m_set) {
                m_view.PDFSetLine(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetLine(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnChecked(btn_annot_line, true);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_rect) {
            if (m_set) {
                m_view.PDFSetRect(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetRect(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnChecked(btn_annot_rect, true);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_oval) {
            if (m_set) {
                m_view.PDFSetEllipse(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetEllipse(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnChecked(btn_annot_oval, true);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_stamp) {
            if (m_set) {
                m_view.PDFSetStamp(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetStamp(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnChecked(btn_annot_stamp, true);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_note) {
            if (m_set) {
                m_view.PDFSetNote(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_note, false);
                SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            } else {
                m_view.PDFSetNote(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnChecked(btn_annot_note, true);
                SetBtnEnabled(btn_annot_editbox, false);
            }
        } else if (arg0 == btn_annot_editbox) {
            if (m_set) {
                m_view.PDFSetEditbox(1);
                SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
                SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
                SetBtnChecked(btn_annot_editbox, false);
            } else {
                m_view.PDFSetEditbox(0);
                SetBtnEnabled(btn_annot_polygon, false);
                SetBtnEnabled(btn_annot_polyline, false);
                SetBtnEnabled(btn_annot_ink, false);
                SetBtnEnabled(btn_annot_line, false);
                SetBtnEnabled(btn_annot_rect, false);
                SetBtnEnabled(btn_annot_oval, false);
                SetBtnEnabled(btn_annot_stamp, false);
                SetBtnEnabled(btn_annot_note, false);
                SetBtnChecked(btn_annot_editbox, true);
            }
        } else if (arg0 == btn_annot_back) {
            m_view.PDFCancelAnnot();
            m_set = false;
            SetBtnEnabled(btn_annot_polygon, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_polyline, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_ink, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_line, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_rect, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_oval, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_stamp, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_note, m_view.PDFCanSave());
            SetBtnEnabled(btn_annot_editbox, m_view.PDFCanSave());
            m_bar_annot.BarSwitch(m_bar_cmd);

            if (mNavigationMode == NAVIGATION_THUMBS)
                m_thumb_view.BarShow();
            else if (mNavigationMode == NAVIGATION_SEEK)
                m_bar_seek.BarShow();
            m_bar_status = BAR_CMD;
        } else if (arg0 == btn_find_back) {
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
        } else if (arg0 == view_vert) {
            m_view.PDFSetView(0);
            m_menu_view.MenuDismiss();
        } else if (arg0 == view_horz) {
            m_view.PDFSetView(1);
            m_menu_view.MenuDismiss();
        } else if (arg0 == view_single) {
            m_view.PDFSetView(3);
            m_menu_view.MenuDismiss();
        } else if (arg0 == view_dual) {
            m_view.PDFSetView(6);
            m_menu_view.MenuDismiss();
        }
    }

    private void activateSearch(int direction) {
        String val = edit_find.getText().toString();
        if (!TextUtils.isEmpty(val)) {
            ((InputMethodManager) m_parent.getContext().getSystemService(Context.INPUT_METHOD_SERVICE))
                    .hideSoftInputFromWindow(edit_find.getWindowToken(), 0);
            val = bidiFormatCheck(val);
            if (val.equals(m_find_str))
                m_view.PDFFind(direction);
            else {
                m_find_str = val;
                m_view.PDFFindStart(val, Global.g_case_sensitive, Global.g_match_whole_word);
                m_view.PDFFind(direction);
            }
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

        if (!TextUtils.isEmpty(m_docPath)) {
            String docName = m_docPath;
            mJobName += TextUtils.substring(docName, docName.lastIndexOf("/") + 1, docName.length()).replace(".pdf", "_print.pdf");
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
            public void onWrite(PageRange[] pages, ParcelFileDescriptor destination, CancellationSignal cancellationSignal,
                                WriteResultCallback callback) {
                InputStream input;
                OutputStream output;
                try {

                    if (!TextUtils.isEmpty(m_docPath)) {

                        if (m_isAsset) {
                            input = m_parent.getContext().getAssets().open(m_docPath);
                        } else {
                            input = new FileInputStream(m_docPath);
                        }

                        output = new FileOutputStream(destination.getFileDescriptor());
                        byte[] buf = new byte[1024];
                        int bytesRead;

                        // check for cancellation
                        if (cancellationSignal.isCanceled()) {
                            callback.onWriteCancelled();
                            input.close();
                            output.close();
                            return;
                        }

                        while ((bytesRead = input.read(buf)) > 0) {
                            output.write(buf, 0, bytesRead);
                        }
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
        }, null);
    }

    private void sharePDF() {
        if (!TextUtils.isEmpty(m_docPath)) {
            File outputFile = new File(m_docPath);
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
        if (Global.selRTOL) { //selection is right to left, check case of mixed text
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
            if (!TextUtils.isEmpty(m_docPath)) {
                String bookmarkLabel = m_parent.getContext().getString(R.string.bookmark_label, m_view.PDFGetCurrPage() + 1);
                RadaeePDFManager mPDFManager = new RadaeePDFManager();
                Toast.makeText(m_parent.getContext(), mPDFManager.addToBookmarks(m_parent.getContext(), m_docPath,
                        m_view.PDFGetCurrPage(), bookmarkLabel), Toast.LENGTH_SHORT).show();
            } else
                Toast.makeText(m_parent.getContext(), R.string.bookmark_error, Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void showBookmarks() {
        if (!TextUtils.isEmpty(m_docPath))
            BookmarkHandler.showBookmarks(m_parent.getContext(), m_docPath, new BookmarkHandler.BookmarkListener() {
                @Override
                public void onBookmarkClickedListener(int pageno) {
                    m_view.PDFGotoPage(pageno);
                }
            });
        else
            Toast.makeText(m_parent.getContext(), R.string.bookmark_error, Toast.LENGTH_SHORT).show();
    }

    private RadaeePluginCallback.PDFControllerListener mControllerListner = new RadaeePluginCallback.PDFControllerListener() {

        @Override
        public void onSetIconsBGColor(int color) {
            try {
                btn_view.setColorFilter(color);
                btn_find.setColorFilter(color);
                btn_find_back.setColorFilter(color);
                btn_find_next.setColorFilter(color);
                btn_find_prev.setColorFilter(color);
                btn_annot.setColorFilter(color);
                btn_select.setColorFilter(color);
                btn_outline.setColorFilter(color);
                btn_undo.setColorFilter(color);
                btn_redo.setColorFilter(color);
                btn_more.setColorFilter(color);
                btn_annot_back.setColorFilter(color);
                btn_annot_polygon.setColorFilter(color);
                btn_annot_polyline.setColorFilter(color);
                btn_annot_ink.setColorFilter(color);
                btn_annot_line.setColorFilter(color);
                btn_annot_rect.setColorFilter(color);
                btn_annot_oval.setColorFilter(color);
                btn_annot_stamp.setColorFilter(color);
                btn_annot_note.setColorFilter(color);
                btn_annot_editbox.setColorFilter(color);
                ((ImageView) view_vert.findViewById(R.id.imageView1)).setColorFilter(color);
                ((ImageView) view_horz.findViewById(R.id.horz)).setColorFilter(color);
                ((ImageView) view_single.findViewById(R.id.imageView2)).setColorFilter(color);
                ((ImageView) view_dual.findViewById(R.id.imageView3)).setColorFilter(color);
                ((ImageView) btn_add_bookmark.findViewById(R.id.add_bookmark_icon)).setColorFilter(color);
                ((ImageView) btn_show_bookmarks.findViewById(R.id.show_bookmarks_icon)).setColorFilter(color);
                ((ImageView) btn_save.findViewById(R.id.save_icon)).setColorFilter(color);
                ((ImageView) btn_print.findViewById(R.id.print_icon)).setColorFilter(color);
                ((ImageView) btn_share.findViewById(R.id.share_icon)).setColorFilter(color);
            } catch (Exception e) {
                e.getMessage();
            }
        }

        @Override
        public void onSetToolbarBGColor(int color) {
            try {
                m_bar_cmd.BarGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
                m_bar_annot.BarGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
                m_menu_view.MenuGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
                m_menu_more.MenuGetView().getBackground().setColorFilter(color, PorterDuff.Mode.SRC_IN);
            } catch (Exception e) {
                e.getMessage();
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
                    SetBtnChecked(btn_annot_polygon, false);
                    SetBtnChecked(btn_annot_polyline, false);
                    SetBtnChecked(btn_annot_ink, false);
                    SetBtnChecked(btn_annot_line, false);
                    SetBtnChecked(btn_annot_rect, false);
                    SetBtnChecked(btn_annot_oval, false);
                    SetBtnChecked(btn_annot_editbox, false);
                    SetBtnChecked(btn_annot_stamp, false);
                    SetBtnChecked(btn_annot_note, false);
                    if (immersive) {
                        m_bar_annot.BarHide();
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
                    for (int i = 0; i < pagesArray.length(); i++) {
                        CommonUtil.parsePageJsonFormFields(pagesArray.getJSONObject(i), m_view.PDFGetDoc());
                    }
                    m_view.PDFUpdateCurrPage();
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
                if (res && page == m_view.PDFGetCurrPage()) {
                    m_view.PDFUpdateCurrPage();
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
            if (path.indexOf(prefix) != -1) {
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
            m_view.PDFUpdateCurrPage();
        }

        @Override
        public void onAddMarkupAnnotation(int pageno, int type, int index1, int index2) {
            Page page = m_view.PDFGetDoc().GetPage(pageno);
            page.ObjsStart();
            boolean success = page.AddAnnotMarkup(index1, index2, type);
            page.Close();
            m_view.PDFUpdateCurrPage();
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