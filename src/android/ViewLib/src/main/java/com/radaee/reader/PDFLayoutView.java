package com.radaee.reader;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Ink;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.pdf.Page.Annotation;
import com.radaee.util.CaptureSignature;
import com.radaee.util.ComboList;
import com.radaee.util.CommonUtil;
import com.radaee.util.PopupEditAct;
import com.radaee.view.PDFLayout;
import com.radaee.view.PDFLayout.LayoutListener;
import com.radaee.view.PDFLayout.PDFPos;
import com.radaee.view.PDFLayoutDual;
import com.radaee.view.PDFLayoutHorz;
import com.radaee.view.PDFLayoutVert;
import com.radaee.view.VPage;
import com.radaee.view.VSel;
import com.radaee.viewlib.R;

import java.util.ArrayList;
import java.util.List;

public class PDFLayoutView extends View implements LayoutListener {
    static final protected int STA_NONE = 0;
    static final protected int STA_ZOOM = 1;
    static final protected int STA_SELECT = 2;
    static final protected int STA_INK = 3;
    static final protected int STA_RECT = 4;
    static final protected int STA_ELLIPSE = 5;
    static final protected int STA_NOTE = 6;
    static final protected int STA_LINE = 7;
    static final protected int STA_STAMP = 8;
    static final protected int STA_ANNOT = 100;
    protected Bitmap.Config m_bmp_format = Bitmap.Config.ALPHA_8;
    protected PDFLayout m_layout;
    private Document m_doc;
    protected int m_status = STA_NONE;
    private boolean m_zooming = false;
    private int m_pageno = 0;
    protected PDFPos m_goto_pos = null;

    protected GestureDetector m_gesture = null;
    private Annotation m_annot = null;
    private PDFPos m_annot_pos = null;
    private VPage m_annot_page = null;
    private float m_annot_rect[];
    private float m_annot_rect0[];
    private float m_annot_x0;
    private float m_annot_y0;

    private boolean mReadOnly = false;
    private Ink m_ink = null;
    private Bitmap m_icon = null;
    private Document.DocImage m_dicon = null;
    private float m_rects[];
    private VPage m_note_pages[];
    private int m_note_indecs[];
    private PDFLayoutListener m_listener;
    private VSel m_sel = null;
    private int m_edit_type = 0;
    private int m_combo_item = -1;
    private PopupWindow m_pEdit = null;
    private PopupWindow m_pCombo = null;
    private Bitmap m_sel_icon1 = null;
    private Bitmap m_sel_icon2 = null;
    private PDFLayoutOPStack m_opstack = new PDFLayoutOPStack();

    class PDFGestureListener extends GestureDetector.SimpleOnGestureListener {
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
            if (m_layout == null) return false;
            if (m_status == STA_NONE && m_hold) {
                float dx = e2.getX() - e1.getX();
                float dy = e2.getY() - e1.getY();
                return m_layout.vFling(m_hold_docx, m_hold_docy, dx, dy, velocityX, velocityY);
            } else return false;
        }

        @Override
        public boolean onDoubleTap(MotionEvent e) {
            return false;
        }

        @Override
        public boolean onDoubleTapEvent(MotionEvent e) {
            if (m_layout == null) return false;
            if (m_status == STA_NONE && e.getActionMasked() == MotionEvent.ACTION_UP) {
                if (m_listener == null ||
                        !m_listener.OnPDFDoubleTapped(m_layout, e.getX(), e.getY()))
                    return false;
                return true;
            }
            return false;
        }

        @Override
        public boolean onDown(MotionEvent e) {
            return false;
        }

        @Override
        public void onLongPress(MotionEvent e) {
            if (m_layout == null) return;
            if (m_status == STA_NONE && m_listener != null)
                m_listener.OnPDFLongPressed(m_layout, e.getX(), e.getY());
        }

        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
            return false;
        }

        @Override
        public void onShowPress(MotionEvent e) {
        }

        private void onEditAnnot() {
            try {
                int[] location = new int[2];
                getLocationOnScreen(location);
                Intent intent = new Intent(getContext(), PopupEditAct.class);
                intent.putExtra("txt", m_annot.GetEditText());
                intent.putExtra("x", m_annot_rect[0] + location[0]);
                intent.putExtra("y", m_annot_rect[1] + location[1]);
                intent.putExtra("w", m_annot_rect[2] - m_annot_rect[0]);
                intent.putExtra("h", m_annot_rect[3] - m_annot_rect[1]);
                intent.putExtra("type", m_annot.GetEditType());
                intent.putExtra("max", m_annot.GetEditMaxlen());
                intent.putExtra("size", m_annot.GetEditTextSize() * m_layout.vGetScale());
                m_edit_type = 1;
                PopupEditAct.ms_listener = new PopupEditAct.ActRetListener() {
                    @Override
                    public void OnEditValue(String val) {
                        if (m_annot != null) {
                            m_annot.SetEditText(val);
                            m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                            if (m_annot != null && Global.sExecuteAnnotJS)
                                executeAnnotJS();
                            m_layout.vRenderSync(m_annot_page);
                            if (m_listener != null)
                                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                            PDFEndAnnot();
                            m_edit_type = 0;
                        }
                    }
                };
                getContext().startActivity(intent);
            } catch (Exception e) {
            }
        }

        boolean[] mCheckedItems;

        private void onListAnnot() {
            try {
                AlertDialog.Builder alertBuilder = new AlertDialog.Builder(getContext());
                String items[] = new String[m_annot.GetListItemCount()];
                int cur = 0;
                while (cur < items.length) {
                    items[cur] = m_annot.GetListItem(cur);
                    cur++;
                }
                final int[] selectedItems = m_annot.GetListSels();
                mCheckedItems = new boolean[items.length];
                for (int item : selectedItems)
                    mCheckedItems[item] = true;

                if (m_annot.IsListMultiSel()) {
                    alertBuilder.setMultiChoiceItems(items, mCheckedItems, new DialogInterface.OnMultiChoiceClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int which, boolean isChecked) {
                            mCheckedItems[which] = isChecked;
                        }
                    });
                } else {
                    alertBuilder.setSingleChoiceItems(items, selectedItems[0], new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            mCheckedItems[i] = true;
                            mCheckedItems[selectedItems[0]] = false;
                        }
                    });
                }
                AlertDialog alert = alertBuilder.create();
                alert.setOnDismissListener(new DialogInterface.OnDismissListener() {
                    @Override
                    public void onDismiss(DialogInterface dialogInterface) {
                        List<Integer> listSels = new ArrayList<>();
                        for (int i = 0; i < mCheckedItems.length; i++)
                            if (mCheckedItems[i]) listSels.add(i);
                        int[] sels = new int[listSels.size()];
                        for (int i = 0; i < listSels.size(); i++)
                            sels[i] = listSels.get(i);
                        m_annot.SetListSels(sels);
                        m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                        if (m_annot != null && Global.sExecuteAnnotJS)
                            executeAnnotJS();
                        m_layout.vRenderSync(m_annot_page);
                        if (m_listener != null)
                            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                        PDFEndAnnot();
                    }
                });
                alert.show();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            if (m_layout == null) return false;
            if (m_status == STA_NONE || m_status == STA_ANNOT) {
                m_annot_pos = m_layout.vGetPos((int) e.getX(), (int) e.getY());
                m_annot_page = m_layout.vGetPage(m_annot_pos.pageno);
                Page page = m_doc.GetPage(m_annot_page.GetPageNo());
                if (page == null) m_annot = null;
                else m_annot = page.GetAnnotFromPoint(m_annot_pos.x, m_annot_pos.y);
                if (m_annot == null) {
                    m_annot_page = null;
                    m_annot_pos = null;
                    m_annot_rect = null;
                    if (m_listener != null) {
                        if (m_status == STA_ANNOT)
                            m_listener.OnPDFAnnotTapped(m_annot_page, null);
                        else
                            m_listener.OnPDFBlankTapped();
                    }
                    m_status = STA_NONE;
                } else {
                    page.ObjsStart();
                    m_annot_rect = m_annot.GetRect();
                    float tmp = m_annot_rect[1];
                    m_annot_rect[0] = m_annot_page.GetVX(m_annot_rect[0]) - m_layout.vGetX();
                    m_annot_rect[1] = m_annot_page.GetVY(m_annot_rect[3]) - m_layout.vGetY();
                    m_annot_rect[2] = m_annot_page.GetVX(m_annot_rect[2]) - m_layout.vGetX();
                    m_annot_rect[3] = m_annot_page.GetVY(tmp) - m_layout.vGetY();
                    m_status = STA_ANNOT;
                    int check = m_annot.GetCheckStatus();
                    if(m_annot.IsReadOnly()) {
                        Toast.makeText(getContext(), "Readonly annotation", Toast.LENGTH_SHORT).show();
                        if(m_listener != null) m_listener.OnPDFAnnotTapped(m_annot_page, m_annot);
                    } else if (PDFCanSave() && check >= 0) {
                        switch (check) {
                            case 0:
                                m_annot.SetCheckValue(true);
                                m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                                break;
                            case 1:
                                m_annot.SetCheckValue(false);
                                m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                                break;
                            case 2:
                            case 3:
                                m_annot.SetRadio();
                                m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                                break;
                        }
                        if (m_annot != null && Global.sExecuteAnnotJS)
                            executeAnnotJS();
                        m_layout.vRenderSync(m_annot_page);
                        if (m_listener != null)
                            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                        PDFEndAnnot();
                    } else if (PDFCanSave() && m_annot.GetEditType() > 0)//if form edit-box.
                    {
                        onEditAnnot();
                    } else if (PDFCanSave() && m_annot.GetComboItemCount() >= 0)//if form choice
                    {
                        try {
                            int[] location = new int[2];
                            getLocationOnScreen(location);
                            String opts[] = new String[m_annot.GetComboItemCount()];
                            int cur = 0;
                            while (cur < opts.length) {
                                opts[cur] = m_annot.GetComboItem(cur);
                                cur++;
                            }
                            m_pCombo = new PopupWindow(LayoutInflater.from(getContext()).inflate(R.layout.pop_combo, null));
                            Drawable dw = new ColorDrawable(0);
                            m_pCombo.setFocusable(true);
                            m_pCombo.setTouchable(true);
                            m_pCombo.setBackgroundDrawable(dw);
                            m_pCombo.setWidth((int) (m_annot_rect[2] - m_annot_rect[0]));
                            if ((m_annot_rect[3] - m_annot_rect[1] - 4) * opts.length > 250)
                                m_pCombo.setHeight(250);
                            else
                                m_pCombo.setHeight((int) (m_annot_rect[3] - m_annot_rect[1] - 4) * opts.length);
                            ComboList combo = (ComboList) m_pCombo.getContentView().findViewById(R.id.annot_combo);
                            combo.set_opts(opts);
                            combo.setOnItemClickListener(new OnItemClickListener() {
                                @Override
                                public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                                    m_combo_item = i;
                                    m_pCombo.dismiss();
                                }
                            });
                            m_edit_type = 2;
                            m_combo_item = -1;
                            m_pCombo.setOnDismissListener(new PopupWindow.OnDismissListener() {
                                @Override
                                public void onDismiss() {
                                    if (m_edit_type == 2)//combo
                                    {
                                        if (m_combo_item >= 0) {
                                            m_annot.SetComboItem(m_combo_item);
                                            m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                                            if (m_annot != null && Global.sExecuteAnnotJS)
                                                executeAnnotJS();
                                            m_layout.vRenderSync(m_annot_page);
                                            if (m_listener != null)
                                                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                                        }
                                        m_combo_item = -1;
                                        PDFEndAnnot();
                                    }
                                    m_edit_type = 0;

                                }
                            });
                            m_pCombo.showAtLocation(PDFLayoutView.this, Gravity.NO_GRAVITY, (int) m_annot_rect[0] + location[0], (int) (m_annot_rect[3] + location[1]));
                        } catch (Exception exc) {
                        }
                    } else if (PDFCanSave() && m_annot.GetListItemCount() >= 0)  //if list choice
                        onListAnnot();
                    else if (PDFCanSave() && m_annot.GetFieldType() == 4 && m_annot.GetSignStatus() == 0 && Global.sEnableGraphicalSignature)  //signature field
                        handleSignatureField();
                    else if (PDFCanSave() && m_listener != null)
                        m_listener.OnPDFAnnotTapped(m_annot_page, m_annot);
                    invalidate();
                }
                return true;
            }
            return false;
        }

        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            return false;
        }

        private void handleSignatureField() {
            if (CommonUtil.isFieldGraphicallySigned(m_annot)) {
                new AlertDialog.Builder(getContext()).setTitle(R.string.warning).setMessage(R.string.delete_signature_message)
                        .setPositiveButton(R.string.yes, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                updateSignature(null, true);
                            }
                        })
                        .setNegativeButton(R.string.no, null)
                        .show();
            } else {
                CaptureSignature.CaptureSignatureListener.setListener(new CaptureSignature.CaptureSignatureListener.OnSignatureCapturedListener() {
                    @Override
                    public void OnSignatureCaptured(Bitmap signature) {
                        updateSignature(signature, false);
                    }
                });
                Intent intent = new Intent(getContext(), CaptureSignature.class);
                intent.putExtra(CaptureSignature.SIGNATURE_PAD_DESCR, Global.sSignPadDescr);
                intent.putExtra(CaptureSignature.FIT_SIGNATURE_BITMAP, Global.sFitSignatureToField);
                getContext().startActivity(intent);
            }
        }

        private void updateSignature(Bitmap signature, boolean remove) {
            if (m_annot != null) {
                float[] annotRect = m_annot.GetRect();
                float annotWidth = annotRect[2] - annotRect[0];
                float annotHeight = annotRect[3] - annotRect[1];

                if (remove)
                    signature = Bitmap.createBitmap((int) annotWidth, (int) annotHeight, Bitmap.Config.ARGB_8888);

                if (signature != null) {
                    Document.DocForm form = CommonUtil.createImageForm(m_doc, signature, annotWidth, annotHeight);
                    if (form != null && m_annot.SetIcon("Signature", form)) {
                        m_layout.vRenderSync(m_annot_page);
                        if (m_listener != null)
                            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                        PDFEndAnnot();
                    }
                    signature.recycle();
                }
            }
        }
    }

    public interface PDFLayoutListener {
        void onPDFPageRendered(int pageno);

        void onPDFCacheRendered(int pageno);

        void onPDFSearchFinished(boolean found);

        void onPDFPageDisplayed(Canvas canvas, VPage vpage);

        public void OnPDFPageModified(int pageno);

        public void OnPDFPageChanged(int pageno);

        public void OnPDFAnnotTapped(VPage vpage, Annotation annot);

        public void OnPDFBlankTapped();

        public void OnPDFSelectEnd(String text);

        public void OnPDFOpenURI(String uri);

        public void OnPDFOpenJS(String js);

        public void OnPDFOpenMovie(String path);

        public void OnPDFOpenSound(int[] paras, String path);

        public void OnPDFOpenAttachment(String path);

        public void OnPDFOpen3D(String path);

        public void OnPDFZoomStart();

        public void OnPDFZoomEnd();

        public boolean OnPDFDoubleTapped(PDFLayout layout, float x, float y);

        void OnPDFLongPressed(PDFLayout layout, float x, float y);
    }

    class PDFVPageSet {
        PDFVPageSet(int max_len) {
            pages = new VPage[max_len];
            pages_cnt = 0;
        }

        void Insert(VPage vpage) {
            int cur = 0;
            for (cur = 0; cur < pages_cnt; cur++) {
                if (pages[cur] == vpage) return;
            }
            pages[cur] = vpage;
            pages_cnt++;
        }

        VPage pages[];
        int pages_cnt;
    }

    private ActivityManager m_amgr;
    private ActivityManager.MemoryInfo m_info = new ActivityManager.MemoryInfo();
    private Paint m_info_paint = new Paint();

    public PDFLayoutView(Context context) {
        super(context);
        m_doc = null;
        m_gesture = new GestureDetector(context, new PDFGestureListener());
        setBackgroundColor(Global.readerViewBgColor);
        if (Global.debug_mode) {
            m_amgr = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            m_info_paint.setARGB(255, 255, 0, 0);
            m_info_paint.setTextSize(30);
        }
    }

    public PDFLayoutView(Context context, AttributeSet attrs) {
        super(context, attrs);
        m_doc = null;
        m_gesture = new GestureDetector(context, new PDFGestureListener());
        setBackgroundColor(Global.readerViewBgColor);
        if (Global.debug_mode) {
            m_amgr = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            m_info_paint.setARGB(255, 255, 0, 0);
            m_info_paint.setTextSize(30);
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (m_layout != null && m_status != STA_ANNOT && w > 0 && h > 0) {
            m_layout.vResize(w, h);

            if (m_goto_pos != null) {
                m_pageno = m_goto_pos.pageno;
                m_layout.vSetPos(0, 0, m_goto_pos);
                m_goto_pos = null;
                invalidate();
            }

            m_layout.vZoomSet(m_layout.vGetWidth() / 2, m_layout.vGetHeight() / 2, m_layout.vGetPos(0, 0), 1);
            PDFGotoPage(m_pageno);
        }
    }

    private void onDrawSelect(Canvas canvas) {
        if (m_status == STA_SELECT && m_sel != null && m_annot_page != null) {
            int orgx = m_annot_page.GetVX(0) - m_layout.vGetX();
            int orgy = m_annot_page.GetVY(m_doc.GetPageHeight(m_annot_page.GetPageNo())) - m_layout.vGetY();
            float scale = m_layout.vGetScale();
            float pheight = m_doc.GetPageHeight(m_annot_page.GetPageNo());
            m_sel.DrawSel(canvas, scale, pheight, orgx, orgy);
            int rect1[] = m_sel.GetRect1(scale, pheight, orgx, orgy);
            int rect2[] = m_sel.GetRect2(scale, pheight, orgx, orgy);
            if (rect1 != null && rect2 != null && Global.useSelIcons) {
                canvas.drawBitmap(m_sel_icon1, rect1[0] - m_sel_icon1.getWidth(), rect1[1] - m_sel_icon1.getHeight(), null);
                canvas.drawBitmap(m_sel_icon2, rect2[2], rect2[3], null);
            }
        }
    }

    private void onDrawAnnot(Canvas canvas) {
        if (m_status == STA_ANNOT && Global.highlight_annotation) {
            Paint paint = new Paint();
            paint.setStyle(Style.STROKE);
            paint.setStrokeWidth(2);
            paint.setARGB(0x80, 0, 0, 0);
            canvas.drawRect(m_annot_rect[0],
                    m_annot_rect[1],
                    m_annot_rect[2],
                    m_annot_rect[3], paint);
        }
    }

    private void onDrawRect(Canvas canvas) {
        if (m_status == STA_RECT && m_rects != null) {
            int len = m_rects.length;
            int cur;
            Paint paint1 = new Paint();
            Paint paint2 = new Paint();
            paint1.setStyle(Style.STROKE);
            paint1.setStrokeWidth(Global.rect_annot_width);
            paint1.setARGB((Global.rect_annot_color >> 24) & 0xFF, (Global.rect_annot_color >> 16) & 0xFF, (Global.rect_annot_color >> 8) & 0xFF,
                    Global.rect_annot_color & 0xFF);
            paint2.setStyle(Style.FILL);
            paint2.setARGB((Global.rect_annot_fill_color >> 24) & 0xFF, (Global.rect_annot_fill_color >> 16) & 0xFF, (Global.rect_annot_fill_color >> 8) & 0xFF,
                    Global.rect_annot_fill_color & 0xFF);
            for (cur = 0; cur < len; cur += 4) {
                float rect[] = new float[4];
                if (m_rects[cur] > m_rects[cur + 2]) {
                    rect[0] = m_rects[cur + 2];
                    rect[2] = m_rects[cur];
                } else {
                    rect[0] = m_rects[cur];
                    rect[2] = m_rects[cur + 2];
                }
                if (m_rects[cur + 1] > m_rects[cur + 3]) {
                    rect[1] = m_rects[cur + 3];
                    rect[3] = m_rects[cur + 1];
                } else {
                    rect[1] = m_rects[cur + 1];
                    rect[3] = m_rects[cur + 3];
                }
                canvas.drawRect(rect[0], rect[1], rect[2], rect[3], paint1);
                canvas.drawRect(rect[0] + 1.5f, rect[1] + 1.5f, rect[2] - 1.5f, rect[3] - 1.5f, paint2);
            }
        }
    }

    private void onDrawLine(Canvas canvas) {
        if (m_status == STA_LINE && m_rects != null) {
            int len = m_rects.length;
            int cur;
            Paint paint1 = new Paint();
            paint1.setStyle(Style.STROKE);
            paint1.setStrokeWidth(Global.line_annot_width);
            paint1.setARGB((Global.line_annot_color >> 24) & 0xFF, (Global.line_annot_color >> 16) & 0xFF, (Global.line_annot_color >> 8) & 0xFF,
                    Global.line_annot_color & 0xFF);
            for (cur = 0; cur < len; cur += 4) {
                canvas.drawLine(m_rects[cur], m_rects[cur + 1], m_rects[cur + 2], m_rects[cur + 3], paint1);
            }
        }
    }

    private void onDrawStamp(Canvas canvas) {
        if (m_status == STA_STAMP && m_rects != null) {
            int len = m_rects.length;
            int cur;
            for (cur = 0; cur < len; cur += 4) {
                float rect[] = new float[4];
                if (m_rects[cur] > m_rects[cur + 2]) {
                    rect[0] = m_rects[cur + 2];
                    rect[2] = m_rects[cur];
                } else {
                    rect[0] = m_rects[cur];
                    rect[2] = m_rects[cur + 2];
                }
                if (m_rects[cur + 1] > m_rects[cur + 3]) {
                    rect[1] = m_rects[cur + 3];
                    rect[3] = m_rects[cur + 1];
                } else {
                    rect[1] = m_rects[cur + 1];
                    rect[3] = m_rects[cur + 3];
                }
                if (m_icon != null) {
                    Rect rc = new Rect();
                    rc.left = (int) rect[0];
                    rc.top = (int) rect[1];
                    rc.right = (int) rect[2];
                    rc.bottom = (int) rect[3];
                    canvas.drawBitmap(m_icon, null, rc, null);
                }
            }
        }
    }

    private void onDrawEllipse(Canvas canvas) {
        if (m_status == STA_ELLIPSE && m_rects != null) {
            int len = m_rects.length;
            int cur;
            Paint paint1 = new Paint();
            Paint paint2 = new Paint();
            paint1.setStyle(Style.STROKE);
            paint1.setStrokeWidth(Global.ellipse_annot_width);
            paint1.setARGB((Global.ellipse_annot_color >> 24) & 0xFF, (Global.ellipse_annot_color >> 16) & 0xFF, (Global.ellipse_annot_color >> 8) & 0xFF,
                    Global.ellipse_annot_color & 0xFF);
            paint2.setStyle(Style.FILL);
            paint2.setARGB((Global.ellipse_annot_fill_color >> 24) & 0xFF, (Global.ellipse_annot_fill_color >> 16) & 0xFF, (Global.ellipse_annot_fill_color >> 8) & 0xFF,
                    Global.ellipse_annot_fill_color & 0xFF);
            for (cur = 0; cur < len; cur += 4) {
                float rect[] = new float[4];
                if (m_rects[cur] > m_rects[cur + 2]) {
                    rect[0] = m_rects[cur + 2];
                    rect[2] = m_rects[cur];
                } else {
                    rect[0] = m_rects[cur];
                    rect[2] = m_rects[cur + 2];
                }
                if (m_rects[cur + 1] > m_rects[cur + 3]) {
                    rect[1] = m_rects[cur + 3];
                    rect[3] = m_rects[cur + 1];
                } else {
                    rect[1] = m_rects[cur + 1];
                    rect[3] = m_rects[cur + 3];
                }
                RectF rc = new RectF();
                rc.left = rect[0];
                rc.top = rect[1];
                rc.right = rect[2];
                rc.bottom = rect[3];
                canvas.drawOval(rc, paint1);
                rc.left += 1.5f;
                rc.top += 1.5f;
                rc.right -= 1.5f;
                rc.bottom -= 1.5f;
                canvas.drawOval(rc, paint2);
            }
        }
    }

    /**
     * the draw function invoke onDraw and then call dispatchDraw. so we override only to draw on Canvas to reduce drawing time.
     *
     * @param canvas
     */
    @SuppressLint("MissingSuperCall")
    @Override
    protected void onDraw(Canvas canvas) {
        if (m_layout != null) {
            m_layout.vDraw(canvas, m_zooming || m_status == STA_ZOOM);
            onDrawSelect(canvas);
            onDrawRect(canvas);
            onDrawEllipse(canvas);
            onDrawAnnot(canvas);
            onDrawLine(canvas);
            onDrawStamp(canvas);
            if (m_status == STA_INK && m_ink != null) {
                m_ink.OnDraw(canvas, 0, 0);
            }
        }
        if (Global.debug_mode && m_amgr != null) {
            try {
                m_amgr.getMemoryInfo(m_info);
                canvas.drawText("AvialMem:" + m_info.availMem / (1024 * 1024) + " M", 20, 150, m_info_paint);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private boolean m_hold = false;
    private float m_hold_x;
    private float m_hold_y;
    private int m_hold_docx;
    private int m_hold_docy;
    private PDFPos m_zoom_pos;
    private float m_zoom_dis0;
    private float m_zoom_scale;

    private boolean onTouchNone(MotionEvent event) {
        if (m_status != STA_NONE) return false;
        if (m_gesture.onTouchEvent(event)) return true;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                m_hold_x = event.getX();
                m_hold_y = event.getY();
                m_hold_docx = m_layout.vGetX();
                m_hold_docy = m_layout.vGetY();
                m_layout.vScrollAbort();
                invalidate();
                m_hold = true;
                break;
            case MotionEvent.ACTION_MOVE:
                if (m_hold) {
                    m_layout.vSetX((int) (m_hold_docx + m_hold_x - event.getX()));
                    m_layout.vSetY((int) (m_hold_docy + m_hold_y - event.getY()));
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (m_hold) {
                    m_layout.vSetX((int) (m_hold_docx + m_hold_x - event.getX()));
                    m_layout.vSetY((int) (m_hold_docy + m_hold_y - event.getY()));
                    invalidate();
                    m_layout.vMoveEnd();
                    m_hold = false;
                }
                break;
            case MotionEvent.ACTION_POINTER_DOWN:
                if (event.getPointerCount() >= 2) {
                    m_status = STA_ZOOM;
                    m_hold_x = (event.getX(0) + event.getX(1)) / 2;
                    m_hold_y = (event.getY(0) + event.getY(1)) / 2;
                    m_zoom_pos = m_layout.vGetPos((int) m_hold_x, (int) m_hold_y);
                    float dx = event.getX(0) - event.getX(1);
                    float dy = event.getY(0) - event.getY(1);
                    m_zoom_dis0 = Global.sqrtf(dx * dx + dy * dy);
                    m_zoom_scale = m_layout.vGetZoom();
                    m_status = STA_ZOOM;
                    m_layout.vZoomStart();
                    if (m_listener != null)
                        m_listener.OnPDFZoomStart();
                }
                break;
        }
        return true;
    }

    private boolean onTouchZoom(MotionEvent event) {
        if (m_status != STA_ZOOM) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_MOVE:
                if (m_status == STA_ZOOM && event.getPointerCount() >= 2) {
                    float dx = event.getX(0) - event.getX(1);
                    float dy = event.getY(0) - event.getY(1);
                    float dis1 = Global.sqrtf(dx * dx + dy * dy);
                    m_layout.vZoomSet((int) m_hold_x, (int) m_hold_y, m_zoom_pos, m_zoom_scale * dis1 / m_zoom_dis0);
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_POINTER_UP:
            case MotionEvent.ACTION_CANCEL:
                if (m_status == STA_ZOOM && event.getPointerCount() == 2) {
                    float dx = event.getX(0) - event.getX(1);
                    float dy = event.getY(0) - event.getY(1);
                    float dis1 = Global.sqrtf(dx * dx + dy * dy);
                    m_layout.vZoomSet((int) m_hold_x, (int) m_hold_y, m_zoom_pos, m_zoom_scale * dis1 / m_zoom_dis0);
                    m_hold_x = -10000;
                    m_hold_y = -10000;
                    m_status = STA_NONE;
                    m_zooming = true;
                    m_layout.vZoomConfirmed();
                    invalidate();
                    m_hold = false;
                    if (m_listener != null)
                        m_listener.OnPDFZoomEnd();
                }
                break;
        }
        return true;
    }

    private boolean onTouchSelect(MotionEvent event) {
        if (m_status != STA_SELECT) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                m_hold_x = event.getX();
                m_hold_y = event.getY();
                if (m_sel != null) {
                    m_sel.Clear();
                    m_sel = null;
                }
                m_annot_pos = m_layout.vGetPos((int) m_hold_x, (int) m_hold_y);
                m_annot_page = m_layout.vGetPage(m_annot_pos.pageno);
                m_sel = new VSel(m_doc.GetPage(m_annot_pos.pageno));
                break;
            case MotionEvent.ACTION_MOVE:
                if (m_sel != null) {
                    m_sel.SetSel(m_annot_pos.x, m_annot_pos.y,
                            m_annot_page.ToPDFX(event.getX(), m_layout.vGetX()),
                            m_annot_page.ToPDFY(event.getY(), m_layout.vGetY()));
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (m_sel != null) {
                    m_sel.SetSel(m_annot_pos.x, m_annot_pos.y,
                            m_annot_page.ToPDFX(event.getX(), m_layout.vGetX()),
                            m_annot_page.ToPDFY(event.getY(), m_layout.vGetY()));
                    invalidate();
                    if (m_listener != null) m_listener.OnPDFSelectEnd(m_sel.GetSelString());
                }
                break;
        }
        return true;
    }

    private boolean onTouchInk(MotionEvent event) {
        if (m_status != STA_INK) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                if (m_annot_page == null) {
                    PDFPos pos = m_layout.vGetPos((int) event.getX(), (int) event.getY());
                    m_annot_page = m_layout.vGetPage(pos.pageno);
                }
                m_ink.OnDown(event.getX(), event.getY());
                break;
            case MotionEvent.ACTION_MOVE:
                m_ink.OnMove(event.getX(), event.getY());
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                m_ink.OnUp(event.getX(), event.getY());
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchRect(MotionEvent event) {
        if (m_status != STA_RECT) return false;
        int len = 0;
        if (m_rects != null) len = m_rects.length;
        int cur = 0;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float rects[] = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                len += 4;
                rects[cur + 0] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchEllipse(MotionEvent event) {
        if (m_status != STA_ELLIPSE) return false;
        int len = 0;
        if (m_rects != null) len = m_rects.length;
        int cur = 0;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float rects[] = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                len += 4;
                rects[cur + 0] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchAnnot(MotionEvent event) {
        if (m_status != STA_ANNOT) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                m_annot_x0 = event.getX();
                m_annot_y0 = event.getY();
                if (m_annot_x0 > m_annot_rect[0] && m_annot_y0 > m_annot_rect[1] &&
                        m_annot_x0 < m_annot_rect[2] && m_annot_y0 < m_annot_rect[3]) {
                    m_annot_rect0 = new float[4];
                    m_annot_rect0[0] = m_annot_rect[0];
                    m_annot_rect0[1] = m_annot_rect[1];
                    m_annot_rect0[2] = m_annot_rect[2];
                    m_annot_rect0[3] = m_annot_rect[3];
                } else
                    m_annot_rect0 = null;
                break;
            case MotionEvent.ACTION_MOVE:
                if (m_annot_rect0 != null && !m_annot.IsLocked()) {
                    float x = event.getX();
                    float y = event.getY();
                    m_annot_rect[0] = m_annot_rect0[0] + x - m_annot_x0;
                    m_annot_rect[1] = m_annot_rect0[1] + y - m_annot_y0;
                    m_annot_rect[2] = m_annot_rect0[2] + x - m_annot_x0;
                    m_annot_rect[3] = m_annot_rect0[3] + y - m_annot_y0;
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (m_annot_rect0 != null && !m_annot.IsLocked()) {
                    float x = event.getX();
                    float y = event.getY();
                    PDFPos pos = m_layout.vGetPos((int) x, (int) y);
                    m_annot_rect[0] = m_annot_rect0[0] + x - m_annot_x0;
                    m_annot_rect[1] = m_annot_rect0[1] + y - m_annot_y0;
                    m_annot_rect[2] = m_annot_rect0[2] + x - m_annot_x0;
                    m_annot_rect[3] = m_annot_rect0[3] + y - m_annot_y0;
                    if (m_annot_page.GetPageNo() == pos.pageno) {
                        m_annot_rect0[0] = m_annot_page.ToPDFX(m_annot_rect[0], m_layout.vGetX());
                        m_annot_rect0[1] = m_annot_page.ToPDFY(m_annot_rect[3], m_layout.vGetY());
                        m_annot_rect0[2] = m_annot_page.ToPDFX(m_annot_rect[2], m_layout.vGetX());
                        m_annot_rect0[3] = m_annot_page.ToPDFY(m_annot_rect[1], m_layout.vGetY());
                        //add to redo/undo stack.
                        float rect[] = m_annot.GetRect();
                        m_opstack.push(new OPMove(pos.pageno, rect, pos.pageno, m_annot.GetIndexInPage(), m_annot_rect0));
                        m_annot.SetRect(m_annot_rect0[0], m_annot_rect0[1], m_annot_rect0[2], m_annot_rect0[3]);
                        m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                        m_layout.vRenderSync(m_annot_page);
                        if (m_listener != null)
                            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                    } else {
                        VPage vpage = m_layout.vGetPage(pos.pageno);
                        Page page = m_doc.GetPage(vpage.GetPageNo());
                        if (page != null) {
                            page.ObjsStart();
                            m_annot_rect0[0] = vpage.ToPDFX(m_annot_rect[0], m_layout.vGetX());
                            m_annot_rect0[1] = vpage.ToPDFY(m_annot_rect[3], m_layout.vGetY());
                            m_annot_rect0[2] = vpage.ToPDFX(m_annot_rect[2], m_layout.vGetX());
                            m_annot_rect0[3] = vpage.ToPDFY(m_annot_rect[1], m_layout.vGetY());
                            //add to redo/undo stack.
                            float rect[] = m_annot.GetRect();
                            m_opstack.push(new OPMove(m_annot_page.GetPageNo(), rect, pos.pageno, page.GetAnnotCount(), m_annot_rect0));
                            m_annot.MoveToPage(page, m_annot_rect0);
                            m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                            //page.CopyAnnot(m_annot, m_annot_rect0);
                            page.Close();
                        }
                        m_layout.vRenderSync(m_annot_page);
                        m_layout.vRenderSync(vpage);
                        if (m_listener != null) {
                            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                            m_listener.OnPDFPageModified(vpage.GetPageNo());
                        }
                    }
                }
                PDFEndAnnot();
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchLine(MotionEvent event) {
        if (m_status != STA_LINE) return false;
        int len = 0;
        if (m_rects != null) len = m_rects.length;
        int cur = 0;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float rects[] = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                len += 4;
                rects[cur + 0] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchStamp(MotionEvent event) {
        if (m_status != STA_STAMP) return false;
        int len = 0;
        if (m_rects != null) len = m_rects.length;
        int cur = 0;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float rects[] = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                len += 4;
                rects[cur + 0] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchNote(MotionEvent event) {
        if (m_status != STA_NOTE) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_UP:
                PDFPos pos = m_layout.vGetPos((int) event.getX(), (int) event.getY());
                VPage vpage = m_layout.vGetPage(pos.pageno);
                Page page = m_doc.GetPage(vpage.GetPageNo());
                if (page != null) {
                    page.ObjsStart();
                    if (m_note_pages == null) {
                        m_note_pages = new VPage[1];
                        m_note_indecs = new int[1];
                        m_note_pages[0] = vpage;
                        m_note_indecs[0] = page.GetAnnotCount();
                    } else {
                        int cur = 0;
                        int cnt = m_note_pages.length;
                        while (cur < cnt) {
                            if (m_note_pages[cur] == vpage) break;
                            cur++;
                        }
                        if (cur >= cnt)//append 1 page
                        {
                            VPage pages[] = new VPage[cnt + 1];
                            int indecs[] = new int[cnt + 1];
                            for (cur = 0; cur < cnt; cur++) {
                                pages[cur] = m_note_pages[cur];
                                indecs[cur] = m_note_indecs[cur];
                            }
                            pages[cnt] = vpage;
                            indecs[cnt] = page.GetAnnotCount();
                            m_note_pages = pages;
                            m_note_indecs = indecs;
                        }
                    }
                    float pt[] = new float[2];
                    pt[0] = pos.x;
                    pt[1] = pos.y;
                    page.AddAnnotText(pt);
                    onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                    //add to redo/undo stack.
                    m_opstack.push(new OPAdd(pos.pageno, page, page.GetAnnotCount() - 1));
                    m_layout.vRenderSync(vpage);
                    invalidate();
                    page.Close();

                    if (m_listener != null)
                        m_listener.OnPDFPageModified(vpage.GetPageNo());
                }
                break;
        }
        return true;
    }

    private void onAnnotCreated(Annotation annot) {
        if (annot != null) {
            annot.SetModifyDate(CommonUtil.getCurrentDate());
            if (!TextUtils.isEmpty(Global.sAnnotAuthor))
                annot.SetPopupLabel(Global.sAnnotAuthor);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (m_layout == null) return false;
        if (onTouchNone(event)) return true;
        if (onTouchZoom(event)) return true;
        if (onTouchSelect(event)) return true;
        if (onTouchInk(event)) return true;
        if (onTouchRect(event)) return true;
        if (onTouchEllipse(event)) return true;
        if (onTouchNote(event)) return true;
        if (onTouchLine(event)) return true;
        if (onTouchStamp(event)) return true;
        if (onTouchAnnot(event)) return true;
        return true;
    }

    @Override
    public void computeScroll() {
        if (m_layout != null && m_layout.vScrollCompute())
            invalidate();
    }

    public void PDFSetView(int style) {
        PDFPos pos = null;
        if (m_layout != null)
            pos = m_layout.vGetPos(0, 0);
        PDFClose();
        switch (style) {
            case 1:
                m_layout = new PDFLayoutHorz(getContext());
                break;
            case 3: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean paras[] = new boolean[m_doc.GetPageCount()];
                int cur = 0;
                while (cur < paras.length) {
                    paras[cur] = false;
                    cur++;
                }
                layout.vSetLayoutPara(null, paras, Global.rtol, false);
                m_layout = layout;
            }
            break;
            case 4: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean paras[] = new boolean[m_doc.GetPageCount()];
                int cur = 0;
                while (cur < paras.length) {
                    paras[cur] = true;
                    cur++;
                }
                layout.vSetLayoutPara(null, paras, Global.rtol, false);
                m_layout = layout;
            }
            break;
            case 6: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                layout.vSetLayoutPara(null, null, Global.rtol, false);
                m_layout = layout;
            }
            break;
            default: {
                PDFLayoutVert layout = new PDFLayoutVert(getContext());
                m_layout = layout;
            }
            break;
        }
        Global.def_view = style;
        m_layout.vOpen(m_doc, this);
        if (m_bmp_format != Bitmap.Config.ALPHA_8) {
            m_layout.vSetBmpFormat(m_bmp_format);
            m_bmp_format = Bitmap.Config.ALPHA_8;
        }
        if (getWidth() > 0 && getHeight() > 0) {
            m_layout.vResize(getWidth(), getHeight());
            if (m_goto_pos != null) {
                m_layout.vSetPos(0, 0, m_goto_pos);
                m_goto_pos = null;
                invalidate();
            } else if (pos != null) {
                if(style == 3 || style == 4 || style == 6)
					m_layout.vGotoPage(pos.pageno);
				else
				    m_layout.vSetPos(0, 0, pos);
                m_layout.vMoveEnd();
            }
        }
        invalidate();
    }

    public void PDFOpen(Document doc, PDFLayoutListener listener) {
        m_doc = doc;
        m_listener = listener;
        PDFSetView(Global.def_view);
    }

    public void PDFSetBmpFormat(Bitmap.Config format) {
        if (format == Bitmap.Config.ALPHA_8) return;
        if (m_layout != null) {
            m_layout.vSetBmpFormat(format);
            m_bmp_format = Bitmap.Config.ALPHA_8;
            invalidate();
        } else if (m_bmp_format != format)
            m_bmp_format = format;
    }

    public void PDFGotoPage(int pageno) {
        if (m_layout == null) return;
        if (m_layout.vGetHeight() <= 0 || m_layout.vGetWidth() <= 0) {
            m_goto_pos = m_layout.new PDFPos();
            m_goto_pos.pageno = pageno;
            m_goto_pos.x = 0;
            m_goto_pos.y = m_doc.GetPageHeight(pageno) + 1;
        } else {
            m_layout.vGotoPage(pageno);
            invalidate();
        }
    }

    public void PDFClose() {
        if (m_layout != null) {
            PDFCancelAnnot();
            PDFEndAnnot();
            m_layout.vClose();
            m_layout = null;
            m_status = STA_NONE;
            m_zooming = false;
            m_pageno = -1;
        }
    }

    public boolean PDFIsOpen() {
        return m_layout != null;
    }

    public void OnPageChanged(int pageno) {
        m_pageno = pageno;
        if (m_listener != null)
            m_listener.OnPDFPageChanged(pageno);
    }

    public void OnPageRendered(int pageno) {
        invalidate();
        if (m_listener != null)
            m_listener.onPDFPageRendered(pageno);
    }

    @Override
    public void OnCacheRendered(int pageno) {
        if (m_listener != null)
            m_listener.onPDFCacheRendered(pageno);
    }

    public void OnFound(boolean found) {
        if (found) invalidate();
        else Toast.makeText(getContext(), R.string.no_more_found, Toast.LENGTH_SHORT).show();
        if (m_listener != null)
            m_listener.onPDFSearchFinished(found);
    }

    public void OnPageDisplayed(Canvas canvas, VPage vpage) {
        if (m_listener != null) m_listener.onPDFPageDisplayed(canvas, vpage);
    }

    public void OnTimer() {
        if (m_layout != null) {
            if (m_zooming && m_layout.vZoomEnd()) {
                m_zooming = false;
                invalidate();
            }
            //else if(!m_layout.vRenderFinished())
            //invalidate();
        }
    }

    public boolean PDFSetAttachment(String attachmentPath) {
        boolean result = false;
        Page page = m_doc.GetPage(0);
        if (page != null) {
            result = page.AddAnnotAttachment(attachmentPath, 0, new float[]{0, 0, 0, 0});
            if (result && m_listener != null) m_listener.OnPDFPageModified(0);
            page.Close();
        }
        return result;
    }

    public void PDFSetInk(int code) {
        if (code == 0)//start
        {
            m_status = STA_INK;
            m_ink = new Ink(Global.inkWidth);
        } else if (code == 1)//end
        {
            m_status = STA_NONE;
            if (m_annot_page != null) {
                Page page = m_doc.GetPage(m_annot_page.GetPageNo());
                if (page != null) {
                    page.ObjsStart();
                    Matrix mat = m_annot_page.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                    mat.TransformInk(m_ink);
                    page.AddAnnotInk(m_ink);
                    mat.Destroy();
                    onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                    //add to redo/undo stack.
                    m_opstack.push(new OPAdd(m_annot_page.GetPageNo(), page, page.GetAnnotCount() - 1));
                    m_layout.vRenderSync(m_annot_page);
                    page.Close();
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                }
            }
            if (m_ink != null) m_ink.Destroy();
            m_ink = null;
            m_annot_page = null;
            invalidate();
        } else//cancel
        {
            m_status = STA_NONE;
            m_ink.Destroy();
            m_ink = null;
            m_annot_page = null;
            invalidate();
        }
    }

    public void PDFSetRect(int code) {
        if (code == 0)//start
        {
            m_status = STA_RECT;
        } else if (code == 1)//end
        {
            if (m_rects != null) {
                int len = m_rects.length;
                int cur;
                PDFVPageSet pset = new PDFVPageSet(len);
                for (cur = 0; cur < len; cur += 4) {
                    PDFPos pos = m_layout.vGetPos((int) m_rects[cur], (int) m_rects[cur + 1]);
                    VPage vpage = m_layout.vGetPage(pos.pageno);
                    Page page = m_doc.GetPage(vpage.GetPageNo());
                    if (page != null) {
                        page.ObjsStart();
                        Matrix mat = vpage.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                        float rect[] = new float[4];
                        if (m_rects[cur] > m_rects[cur + 2]) {
                            rect[0] = m_rects[cur + 2];
                            rect[2] = m_rects[cur];
                        } else {
                            rect[0] = m_rects[cur];
                            rect[2] = m_rects[cur + 2];
                        }
                        if (m_rects[cur + 1] > m_rects[cur + 3]) {
                            rect[1] = m_rects[cur + 3];
                            rect[3] = m_rects[cur + 1];
                        } else {
                            rect[1] = m_rects[cur + 1];
                            rect[3] = m_rects[cur + 3];
                        }
                        mat.TransformRect(rect);
                        page.AddAnnotRect(rect, vpage.ToPDFSize(Global.rect_annot_width), Global.rect_annot_color, Global.rect_annot_fill_color);
                        mat.Destroy();
                        onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                        //add to redo/undo stack.
                        m_opstack.push(new OPAdd(pos.pageno, page, page.GetAnnotCount() - 1));
                        pset.Insert(vpage);
                        page.Close();
                    }
                }
                for (cur = 0; cur < pset.pages_cnt; cur++) {
                    VPage vpage = pset.pages[cur];
                    m_layout.vRenderSync(vpage);
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(vpage.GetPageNo());
                }
            }
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
        } else//cancel
        {
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
        }
    }

    public void PDFSetEllipse(int code) {
        if (code == 0)//start
        {
            m_status = STA_ELLIPSE;
        } else if (code == 1)//end
        {
            if (m_rects != null) {
                int len = m_rects.length;
                int cur;
                PDFVPageSet pset = new PDFVPageSet(len);
                for (cur = 0; cur < len; cur += 4) {
                    PDFPos pos = m_layout.vGetPos((int) m_rects[cur], (int) m_rects[cur + 1]);
                    VPage vpage = m_layout.vGetPage(pos.pageno);
                    Page page = m_doc.GetPage(vpage.GetPageNo());
                    if (page != null) {
                        page.ObjsStart();
                        Matrix mat = vpage.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                        float rect[] = new float[4];
                        if (m_rects[cur] > m_rects[cur + 2]) {
                            rect[0] = m_rects[cur + 2];
                            rect[2] = m_rects[cur];
                        } else {
                            rect[0] = m_rects[cur];
                            rect[2] = m_rects[cur + 2];
                        }
                        if (m_rects[cur + 1] > m_rects[cur + 3]) {
                            rect[1] = m_rects[cur + 3];
                            rect[3] = m_rects[cur + 1];
                        } else {
                            rect[1] = m_rects[cur + 1];
                            rect[3] = m_rects[cur + 3];
                        }
                        mat.TransformRect(rect);
                        page.AddAnnotEllipse(rect, vpage.ToPDFSize(Global.ellipse_annot_width), Global.ellipse_annot_color, Global.ellipse_annot_fill_color);
                        mat.Destroy();
                        onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                        //add to redo/undo stack.
                        m_opstack.push(new OPAdd(pos.pageno, page, page.GetAnnotCount() - 1));
                        page.Close();
                        pset.Insert(vpage);
                    }
                }
                for (cur = 0; cur < pset.pages_cnt; cur++) {
                    VPage vpage = pset.pages[cur];
                    m_layout.vRenderSync(vpage);
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(vpage.GetPageNo());
                }
            }
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
        } else//cancel
        {
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
        }
    }

    public void PDFSetSelect() {
        if (m_status == STA_SELECT) {
            if (Global.useSelIcons) {
                m_sel_icon1.recycle();
                m_sel_icon2.recycle();
                m_sel_icon1 = null;
                m_sel_icon2 = null;
            }
            m_annot_page = null;
            m_status = STA_NONE;
        } else {
            if (Global.useSelIcons) {
                m_sel_icon1 = BitmapFactory.decodeResource(this.getResources(), R.drawable.pt_start);
                m_sel_icon2 = BitmapFactory.decodeResource(this.getResources(), R.drawable.pt_end);
            }
            m_annot_page = null;
            m_status = STA_SELECT;
        }
    }

    public void PDFSetNote(int code) {
        if (code == 0) {
            m_note_pages = null;
            m_note_indecs = null;
            m_status = STA_NOTE;
        } else if (code == 1)//end
        {
            if (m_listener != null && m_note_pages != null) {
                int cur = 0;
                int cnt = m_note_pages.length;
                while (cur < cnt) {
                    m_listener.OnPDFPageModified(m_note_pages[cur].GetPageNo());
                    cur++;
                }
            }
            m_note_pages = null;
            m_note_indecs = null;
            m_status = STA_NONE;
        } else//cancel
        {
            if (m_note_pages != null)//remove added note.
            {
                int cur = 0;
                int cnt = m_note_pages.length;
                while (cur < cnt) {
                    VPage vpage = m_note_pages[cur];
                    Page page = m_doc.GetPage(vpage.GetPageNo());
                    page.ObjsStart();
                    int index = m_note_indecs[cur];
                    Annotation annot;
                    while ((annot = page.GetAnnot(index)) != null) {
                        annot.RemoveFromPage();
                        m_opstack.undo();
                    }
                    page.Close();
                    m_layout.vRenderSync(vpage);
                    cur++;
                }
                m_note_pages = null;
                m_note_indecs = null;
                invalidate();
            }
            m_status = STA_NONE;
        }
    }

    public void PDFSetLine(int code) {
        if (code == 0)//start
        {
            m_status = STA_LINE;
        } else if (code == 1)//end
        {
            if (m_rects != null) {
                int len = m_rects.length;
                int cur;
                float[] pt1 = new float[2];
                float[] pt2 = new float[2];
                PDFVPageSet pset = new PDFVPageSet(len);
                for (cur = 0; cur < len; cur += 4) {
                    PDFPos pos = m_layout.vGetPos((int) m_rects[cur], (int) m_rects[cur + 1]);
                    VPage vpage = m_layout.vGetPage(pos.pageno);
                    pt1[0] = m_rects[cur];
                    pt1[1] = m_rects[cur + 1];
                    pt2[0] = m_rects[cur + 2];
                    pt2[1] = m_rects[cur + 3];
                    Page page = m_doc.GetPage(vpage.GetPageNo());
                    if (page != null) {
                        page.ObjsStart();
                        Matrix mat = vpage.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                        mat.TransformPoint(pt1);
                        mat.TransformPoint(pt2);
                        page.AddAnnotLine(pt1, pt2, Global.line_annot_style1, Global.line_annot_style2, vpage.ToPDFSize(Global.line_annot_width), Global.line_annot_color, Global.line_annot_fill_color);
                        mat.Destroy();
                        onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                        //add to redo/undo stack.
                        m_opstack.push(new OPAdd(pos.pageno, page, page.GetAnnotCount() - 1));
                        page.Close();
                        pset.Insert(vpage);
                    }
                }
                for (cur = 0; cur < pset.pages_cnt; cur++) {
                    VPage vpage = pset.pages[cur];
                    m_layout.vRenderSync(vpage);
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(vpage.GetPageNo());
                }
            }
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
        } else//cancel
        {
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
        }
    }

    public void PDFSetStamp(int code) {
        if (code == 0)//start
        {
            m_status = STA_STAMP;
            //if(m_dicon == null) {
            m_icon = BitmapFactory.decodeResource(this.getResources(), R.drawable.pdf_custom_stamp);
            if (m_icon != null) {
                m_dicon = m_doc.NewImage(m_icon, true);
            }
            //}
        } else if (code == 1)//end
        {
            if (m_rects != null) {
                int len = m_rects.length;
                int cur;
                PDFVPageSet pset = new PDFVPageSet(len);
                for (cur = 0; cur < len; cur += 4) {
                    PDFPos pos = m_layout.vGetPos((int) m_rects[cur], (int) m_rects[cur + 1]);
                    VPage vpage = m_layout.vGetPage(pos.pageno);
                    Page page = m_doc.GetPage(vpage.GetPageNo());
                    if (page != null) {
                        Matrix mat = vpage.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                        float rect[] = new float[4];
                        if (m_rects[cur] > m_rects[cur + 2]) {
                            rect[0] = m_rects[cur + 2];
                            rect[2] = m_rects[cur];
                        } else {
                            rect[0] = m_rects[cur];
                            rect[2] = m_rects[cur + 2];
                        }
                        if (m_rects[cur + 1] > m_rects[cur + 3]) {
                            rect[1] = m_rects[cur + 3];
                            rect[3] = m_rects[cur + 1];
                        } else {
                            rect[1] = m_rects[cur + 1];
                            rect[3] = m_rects[cur + 3];
                        }
                        mat.TransformRect(rect);
                        page.ObjsStart();
                        page.AddAnnotBitmap(m_dicon, rect);
                        mat.Destroy();
                        onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                        //add to redo/undo stack.
                        m_opstack.push(new OPAdd(pos.pageno, page, page.GetAnnotCount() - 1));
                        page.Close();
                        pset.Insert(vpage);
                    }
                }
                for (cur = 0; cur < pset.pages_cnt; cur++) {
                    VPage vpage = pset.pages[cur];
                    m_layout.vRenderSync(vpage);
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(vpage.GetPageNo());
                }
            }
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
            if (m_icon != null)
                m_icon.recycle();
            m_icon = null;
        } else//cancel
        {
            m_status = STA_NONE;
            m_rects = null;
            invalidate();
            if (m_icon != null)
                m_icon.recycle();
            m_icon = null;
        }
    }

    public void PDFCancelAnnot() {
        if (m_status == STA_NOTE) PDFSetNote(2);
        if (m_status == STA_RECT) PDFSetRect(2);
        if (m_status == STA_INK) PDFSetInk(2);
        if (m_status == STA_LINE) PDFSetLine(2);
        if (m_status == STA_STAMP) PDFSetStamp(2);
        if (m_status == STA_ELLIPSE) PDFSetEllipse(2);
        if (m_status == STA_ANNOT) PDFEndAnnot();
        invalidate();
    }

    public void PDFRemoveAnnot() {
        if (m_status != STA_ANNOT || !PDFCanSave()) return;
        //add to redo/undo stack.
        Page page = m_doc.GetPage(m_annot_page.GetPageNo());
        page.ObjsStart();
        m_opstack.push(new OPDel(m_annot_page.GetPageNo(), page, m_annot.GetIndexInPage()));
        page.Close();

        m_annot.RemoveFromPage();
        m_annot = null;
        m_layout.vRenderSync(m_annot_page);
        if (m_listener != null)
            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
        PDFEndAnnot();
    }

    public void PDFEndAnnot() {
        if (m_status != STA_ANNOT) return;
        m_annot_page = null;
        m_annot_pos = null;
        m_annot = null;
        invalidate();
        m_status = STA_NONE;
        try {
            if (m_pEdit != null && m_pEdit.isShowing()) m_pEdit.dismiss();
            if (m_pCombo != null && m_pCombo.isShowing()) m_pCombo.dismiss();
        } catch (Exception e) {

        }
        if (m_listener != null)
            m_listener.OnPDFAnnotTapped(null, null);
    }

    public void PDFEditAnnot() {
        if (m_status != STA_ANNOT) return;
        RelativeLayout layout = (RelativeLayout) LayoutInflater.from(getContext()).inflate(R.layout.dlg_note, null);
        final EditText subj = (EditText) layout.findViewById(R.id.txt_subj);
        final EditText content = (EditText) layout.findViewById(R.id.txt_content);
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
        builder.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                String str_subj = subj.getText().toString();
                String str_content = content.getText().toString();
                m_annot.SetPopupSubject(str_subj);
                m_annot.SetPopupText(str_content);
                m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                dialog.dismiss();
                if (m_listener != null)
                    m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                PDFEndAnnot();
            }
        });
        builder.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                PDFEndAnnot();
            }
        });
        builder.setTitle(R.string.note_content);
        builder.setCancelable(false);
        builder.setView(layout);

        subj.setText(m_annot.GetPopupSubject());
        content.setText(m_annot.GetPopupText());
        AlertDialog dlg = builder.create();
        dlg.show();
    }

    public void PDFPerformAnnot() {
        if (m_status != STA_ANNOT) return;
        Page page = m_doc.GetPage(m_annot_page.GetPageNo());
        if (page == null || m_annot == null) return;
        page.ObjsStart();
        int dest = m_annot.GetDest();
        if (dest >= 0) {
            m_layout.vGotoPage(dest);
            invalidate();
        }
        String js = m_annot.GetJS();
        if (Global.sExecuteAnnotJS)
            executeAnnotJS();
        if (m_listener != null && js != null)
            m_listener.OnPDFOpenJS(js);
        String uri = m_annot.GetURI();
        if (m_listener != null && uri != null)
            m_listener.OnPDFOpenURI(uri);
        int index;
        String mov = m_annot.GetMovie();
        if (mov != null) {
            index = -1;
            if (index < 0) index = mov.lastIndexOf('\\');
            if (index < 0) index = mov.lastIndexOf('/');
            if (index < 0) index = mov.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + mov.substring(index + 1);
            m_annot.GetMovieData(save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenMovie(save_file);
        }
        String snd = m_annot.GetSound();
        if (snd != null) {
            int paras[] = new int[4];
            index = -1;
            if (index < 0) index = snd.lastIndexOf('\\');
            if (index < 0) index = snd.lastIndexOf('/');
            if (index < 0) index = snd.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + snd.substring(index + 1);
            m_annot.GetSoundData(paras, save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenSound(paras, save_file);
        }
        String att = m_annot.GetAttachment();
        if (att != null) {
            index = -1;
            if (index < 0) index = att.lastIndexOf('\\');
            if (index < 0) index = att.lastIndexOf('/');
            if (index < 0) index = att.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + att.substring(index + 1);
            m_annot.GetAttachmentData(save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenAttachment(save_file);
        }
        String f3d = m_annot.Get3D();
        if (f3d != null) {
            index = -1;
            if (index < 0) index = f3d.lastIndexOf('\\');
            if (index < 0) index = f3d.lastIndexOf('/');
            if (index < 0) index = f3d.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + f3d.substring(index + 1);
            m_annot.Get3DData(save_file);
            if (m_listener != null)
                m_listener.OnPDFOpen3D(save_file);
        }

        boolean reset = m_annot.GetReset();
        if (reset && PDFCanSave()) {
            m_annot.SetReset();
            m_layout.vRenderSync(m_annot_page);
            if (m_listener != null)
                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
        }
        String tar = m_annot.GetSubmitTarget();
        if (tar != null) {
            if (m_listener != null)
                m_listener.OnPDFOpenURI(tar + "?" + m_annot.GetSubmitTarget());
        }
        page.Close();
        PDFEndAnnot();
    }

    public final void PDFFindStart(String key, boolean match_case, boolean whole_word) {
        m_layout.vFindStart(key, match_case, whole_word);
    }

    public final void PDFFindStart(String key, boolean match_case, boolean whole_word, boolean skipBlank) {
        m_layout.vFindStart(key, match_case, whole_word, skipBlank);
    }

    public final void PDFFind(int dir) {
        m_layout.vFind(dir);
    }

    public final void PDFFindEnd() {
        m_layout.vFindEnd();
        invalidate();
    }

    public boolean PDFSetSelMarkup(int type) {
        if (m_status == STA_SELECT && m_sel != null && m_sel.SetSelMarkup(type)) {
            //add to redo/undo stack.
            Page page = m_sel.GetPage();
            onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
            m_opstack.push(new OPAdd(m_annot_page.GetPageNo(), page, page.GetAnnotCount() - 1));
            m_layout.vRenderSync(m_annot_page);
            invalidate();
            if (m_listener != null)
                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
            return true;
        } else {
            return false;
        }
    }

    public final int PDFGetCurrPage() {
        return m_pageno;
    }

    public final PDFPos PDFGetPos(int x, int y) {
        if (m_layout != null)
            return m_layout.vGetPos(x, y);
        else return null;
    }

    public final void PDFSetPos(PDFPos pos, int x, int y) {
        if (m_layout != null) {
            m_layout.vSetPos(x, y, pos);
            invalidate();
        }
    }

    public void BundleSavePos(Bundle bundle) {
        if (m_layout != null) {
            PDFPos pos = m_layout.vGetPos(0, 0);
            bundle.putInt("view_page", pos.pageno);
            bundle.putFloat("view_x", pos.x);
            bundle.putFloat("view_y", pos.y);
        }
    }

    public void BundleRestorePos(Bundle bundle) {
        if (m_layout != null) {
            PDFPos pos = m_layout.new PDFPos();
            pos.pageno = bundle.getInt("view_page");
            pos.x = bundle.getFloat("view_x");
            pos.y = bundle.getFloat("view_y");
            if (m_layout.vGetHeight() <= 0 || m_layout.vGetWidth() <= 0) {
                m_goto_pos = pos;
            } else {
                m_layout.vSetPos(0, 0, pos);
                invalidate();
            }
        }
    }

    public final Document PDFGetDoc() {
        return m_doc;
    }

    public final boolean PDFCanSave() {
        return !mReadOnly && m_doc.CanSave();
    }

    public void PDFUndo() {
        //if(m_opstack.can_undo()) return;
        OPItem item = m_opstack.undo();
        if (item != null) {
            item.op_undo(m_doc);
            PDFGotoPage(item.m_pageno);
            m_layout.vRenderSync(m_layout.vGetPage(item.m_pageno));
            invalidate();
        } else
            Toast.makeText(getContext(), R.string.no_more_undo, Toast.LENGTH_SHORT).show();
    }

    public void PDFRedo() {
        //if(m_opstack.can_redo()) return;
        OPItem item = m_opstack.redo();
        if (item != null) {
            item.op_redo(m_doc);
            PDFGotoPage(item.m_pageno);
            m_layout.vRenderSync(m_layout.vGetPage(item.m_pageno));
            invalidate();
        } else
            Toast.makeText(getContext(), R.string.no_more_redo, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void finalize() throws Throwable {
        PDFClose();
        super.finalize();
    }

    public float PDFGetScale() {
        if (m_layout != null)
            return m_layout.vGetScale();
        return 1;
    }

    public float PDFGetMinScale() {
        if (m_layout != null)
            return m_layout.vGetMinScale();
        return 1;
    }

    public float PDFGetX() {
        return m_layout != null ? m_layout.vGetX() : 0;
    }

    public float PDFGetY() {
        return m_layout != null ? m_layout.vGetY() : 0;
    }

    public void refreshCurrentPage() {
        if (m_layout != null)
            m_layout.vRenderSync(m_layout.vGetPage(m_pageno));
    }

    public void refreshPageAsync(int page) {
        if (m_layout != null && page < m_doc.GetPageCount())
            m_layout.vRenderAsync(m_layout.vGetPage(page));
    }

    public void setReadOnly(boolean readonly) {
        mReadOnly = readonly;
    }

    public void PDFSetZoom(int vx, int vy, PDFPos pos, float zoom) {
        if(m_layout != null) m_layout.vZoomSet(vx, vy, pos, zoom);
    }

    private static int tmp_idx = 0;

    private void executeAnnotJS() {
        if (!TextUtils.isEmpty(m_annot.GetJS()))
            runJS(m_annot.GetJS());
        if (!TextUtils.isEmpty(m_annot.GetAdditionalJS(1)))
            runJS(m_annot.GetAdditionalJS(1));
    }

    private void runJS(String js) {
        try {
            m_doc.RunJS(js, new Document.PDFJSDelegate() {
                @Override
                public void OnConsole(int cmd, String para) {
                    //cmd-> 0:clear, 1:hide, 2:println, 3:show
                }

                @Override
                public int OnAlert(int btn, String msg, String title) {
                    Log.d(PDFLayoutView.class.getSimpleName(), "Alert {title:\"" + title + "\",message:\"" + msg + "\",button:" + btn + ",return:1}\r\n");
                    return 1;
                }

                @Override
                public boolean OnDocClose() {
                    return false;
                }

                @Override
                public String OnTmpFile() {
                    tmp_idx++;
                    return Global.tmp_path + "/" + tmp_idx + ".tmp";
                }

                @Override
                public void OnUncaughtException(int code, String msg) {
                    Log.d(PDFLayoutView.class.getSimpleName(), "code = " + code + ", msg = " + msg);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}