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

import com.radaee.annotui.UIAnnotDlgPopup;
import com.radaee.annotui.UIAnnotDlgSign;
import com.radaee.annotui.UIAnnotDlgSignProp;
import com.radaee.annotui.UIAnnotMenu;
import com.radaee.annotui.UIAnnotPopEdit;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Ink;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.pdf.Page.Annotation;
import com.radaee.pdf.Path;
import com.radaee.util.ComboList;
import com.radaee.util.CommonUtil;
import com.radaee.util.PopupEditAct;
import com.radaee.view.GLLayout;
import com.radaee.view.GLLayoutDual;
import com.radaee.view.GLLayoutDualV;
import com.radaee.view.ILayoutView;
import com.radaee.view.PDFLayout;
import com.radaee.view.PDFLayout.LayoutListener;
import com.radaee.view.PDFLayout.PDFPos;
import com.radaee.view.PDFLayoutDual;
import com.radaee.view.PDFLayoutDualV;
import com.radaee.view.PDFLayoutHorz;
import com.radaee.view.PDFLayoutVert;
import com.radaee.view.VPage;
import com.radaee.view.VSel;
import com.radaee.viewlib.R;

import java.util.ArrayList;
import java.util.List;

public class PDFLayoutView extends View implements ILayoutView, LayoutListener {
    static final protected int STA_NONE = 0;
    static final protected int STA_ZOOM = 1;
    static final protected int STA_SELECT = 2;
    static final protected int STA_INK = 3;
    static final protected int STA_RECT = 4;
    static final protected int STA_ELLIPSE = 5;
    static final protected int STA_NOTE = 6;
    static final protected int STA_LINE = 7;
    static final protected int STA_STAMP = 8;
    static final protected int STA_EDITBOX = 9;
    static final protected int STA_POLYGON = 10;
    static final protected int STA_POLYLINE = 11;
    static final protected int STA_ANNOT = 100;
    protected Bitmap.Config m_bmp_format = Bitmap.Config.ALPHA_8;
    protected PDFLayout m_layout;
    private Document m_doc;
    protected int m_status = STA_NONE;
    private boolean m_zooming = false;
    private int m_pageno = 0;
    protected PDFPos m_goto_pos = null;

    protected GestureDetector m_gesture;
    private Annotation m_annot = null;
    private PDFPos m_annot_pos = null;
    private Page m_annot_pg = null;
    private VPage m_annot_page = null;
    private float[] m_annot_rect;
    private float[] m_annot_rect0;
    private float m_annot_x0;
    private float m_annot_y0;

    private boolean mReadOnly = false;
    private Ink m_ink = null;
    private Path m_polygon;
    private Bitmap m_icon = null;
    private Document.DocImage m_dicon = null;
    private float[] m_rects;
    private VPage[] m_note_pages;
    private int[] m_note_indecs;
    private ILayoutView.PDFLayoutListener m_listener;
    private VSel m_sel = null;
    private int m_edit_type = 0;
    private int m_combo_item = -1;
    private UIAnnotPopEdit m_pEdit = null;
    private PopupWindow m_pCombo = null;
    private UIAnnotMenu m_aMenu = null;
    private Bitmap m_sel_icon1 = null;
    private Bitmap m_sel_icon2 = null;
    private PDFLayoutOPStack m_opstack = new PDFLayoutOPStack();

    private interface IAnnotOP
    {
        void onDraw(Canvas canvas);
        void onTouch(MotionEvent event);
    }
    static private Paint NewPaintBorder()
    {
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(2);
        paint.setColor(0x80000000);
        return paint;
    }
    static private Paint NewPaintLine()
    {
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(2);
        paint.setColor(0x400000FF);
        return paint;
    }
    static private Paint NewPaintFill()
    {
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(0x80FFFFFF);
        return paint;
    }
    private void MovRect(float dx, float dy)
    {
        m_annot_rect[0] = m_annot_rect0[0] + dx;
        m_annot_rect[1] = m_annot_rect0[1] + dy;
        m_annot_rect[2] = m_annot_rect0[2] + dx;
        m_annot_rect[3] = m_annot_rect0[3] + dy;
    }
    private final IAnnotOP m_annot_op_normal = new IAnnotOP() {
        private final Paint m_paint = NewPaintBorder();
        @Override
        public void onDraw(Canvas canvas) {
            canvas.drawRect(m_annot_rect[0], m_annot_rect[1],
                    m_annot_rect[2], m_annot_rect[3], m_paint);
        }

        @Override
        public void onTouch(MotionEvent event) {
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
                    if (m_annot_rect0 != null) {
                        float x = event.getX();
                        float y = event.getY();
                        MovRect(x - m_annot_x0, y - m_annot_y0);
                    }
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    if (m_annot_rect0 != null) {
                        float x = event.getX();
                        float y = event.getY();
                        PDFPos pos = m_layout.vGetPos((int) x, (int) y);
                        MovRect(x - m_annot_x0, y - m_annot_y0);
                        if (m_annot_page.GetPageNo() == pos.pageno) {
                            m_annot_rect0[0] = m_annot_page.ToPDFX(m_annot_rect[0], m_layout.vGetX());
                            m_annot_rect0[1] = m_annot_page.ToPDFY(m_annot_rect[3], m_layout.vGetY());
                            m_annot_rect0[2] = m_annot_page.ToPDFX(m_annot_rect[2], m_layout.vGetX());
                            m_annot_rect0[3] = m_annot_page.ToPDFY(m_annot_rect[1], m_layout.vGetY());
                            //add to redo/undo stack.
                            float[] rect = m_annot.GetRect();
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
                                float[] rect = m_annot.GetRect();
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
        }
    };
    private final IAnnotOP m_annot_op_resize = new IAnnotOP() {
        private final Paint m_paint_s = NewPaintBorder();
        private final Paint m_paint_f = NewPaintFill();
        private int m_gap = 0;
        private int m_node = 0;
        @Override
        public void onDraw(Canvas canvas) {
            if (m_gap == 0) m_gap = dp2px(getContext(), 4);
            float left = m_annot_rect[0];
            float top = m_annot_rect[1];
            float right = m_annot_rect[2];
            float bot = m_annot_rect[3];
            float xmid = (left + right) * 0.5f;
            float ymid = (top + bot) * 0.5f;

            canvas.drawRect(left, top, right, bot, m_paint_s);

            canvas.drawRect(left - m_gap, top - m_gap, left + m_gap, top + m_gap, m_paint_f);
            canvas.drawRect(left - m_gap, top - m_gap, left + m_gap, top + m_gap, m_paint_s);

            canvas.drawRect(xmid - m_gap, top - m_gap, xmid + m_gap, top + m_gap, m_paint_f);
            canvas.drawRect(xmid - m_gap, top - m_gap, xmid + m_gap, top + m_gap, m_paint_s);

            canvas.drawRect(right - m_gap, top - m_gap, right + m_gap, top + m_gap, m_paint_f);
            canvas.drawRect(right - m_gap, top - m_gap, right + m_gap, top + m_gap, m_paint_s);

            canvas.drawRect(right - m_gap, ymid - m_gap, right + m_gap, ymid + m_gap, m_paint_f);
            canvas.drawRect(right - m_gap, ymid - m_gap, right + m_gap, ymid + m_gap, m_paint_s);

            canvas.drawRect(right - m_gap, bot - m_gap, right + m_gap, bot + m_gap, m_paint_f);
            canvas.drawRect(right - m_gap, bot - m_gap, right + m_gap, bot + m_gap, m_paint_s);

            canvas.drawRect(xmid - m_gap, bot - m_gap, xmid + m_gap, bot + m_gap, m_paint_f);
            canvas.drawRect(xmid - m_gap, bot - m_gap, xmid + m_gap, bot + m_gap, m_paint_s);

            canvas.drawRect(left - m_gap, bot - m_gap, left + m_gap, bot + m_gap, m_paint_f);
            canvas.drawRect(left - m_gap, bot - m_gap, left + m_gap, bot + m_gap, m_paint_s);

            canvas.drawRect(left - m_gap, ymid - m_gap, left + m_gap, ymid + m_gap, m_paint_f);
            canvas.drawRect(left - m_gap, ymid - m_gap, left + m_gap, ymid + m_gap, m_paint_s);
        }

        @Override
        public void onTouch(MotionEvent event) {
            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN: {
                    if (m_gap == 0) m_gap = dp2px(getContext(), 4);
                    float left = m_annot_rect[0];
                    float top = m_annot_rect[1];
                    float right = m_annot_rect[2];
                    float bot = m_annot_rect[3];
                    float xmid = (left + right) * 0.5f;
                    float ymid = (top + bot) * 0.5f;

                    m_annot_x0 = event.getX();
                    m_annot_y0 = event.getY();
                    m_annot_rect0 = new float[4];
                    m_annot_rect0[0] = m_annot_rect[0];
                    m_annot_rect0[1] = m_annot_rect[1];
                    m_annot_rect0[2] = m_annot_rect[2];
                    m_annot_rect0[3] = m_annot_rect[3];
                    if (m_annot_y0 >= top - m_gap && m_annot_y0 <= top + m_gap) {
                        if (m_annot_x0 >= left - m_gap && m_annot_x0 <= left + m_gap) m_node = 1;
                        else if (m_annot_x0 >= xmid - m_gap && m_annot_x0 <= xmid + m_gap) m_node = 2;
                        else if (m_annot_x0 >= right - m_gap && m_annot_x0 <= right + m_gap) m_node = 3;
                        else m_node = 0;
                    }
                    else if (m_annot_y0 >= ymid - m_gap && m_annot_y0 <= ymid + m_gap)
                    {
                        if (m_annot_x0 >= left - m_gap && m_annot_x0 <= left + m_gap) m_node = 8;
                        else if (m_annot_x0 >= right - m_gap && m_annot_x0 <= right + m_gap) m_node = 4;
                        else m_node = 0;
                    }
                    else if (m_annot_y0 >= bot - m_gap && m_annot_y0 <= bot + m_gap)
                    {
                        if (m_annot_x0 >= left - m_gap && m_annot_x0 <= left + m_gap) m_node = 7;
                        else if (m_annot_x0 >= xmid - m_gap && m_annot_x0 <= xmid + m_gap) m_node = 6;
                        else if (m_annot_x0 >= right - m_gap && m_annot_x0 <= right + m_gap) m_node = 5;
                        else m_node = 0;
                    }
                    else if (m_annot_x0 > m_annot_rect[0] && m_annot_y0 > m_annot_rect[1] &&
                            m_annot_x0 < m_annot_rect[2] && m_annot_y0 < m_annot_rect[3]) {
                        m_node = 9;
                    } else
                    {
                        m_node = 0;
                        m_annot_rect0 = null;
                    }
                }
                break;
                case MotionEvent.ACTION_MOVE:
                    if (m_node > 0) {
                        float x = event.getX();
                        float y = event.getY();

                        switch(m_node)
                        {
                            case 1://left,top
                                m_annot_rect[0] = m_annot_rect0[0] + x - m_annot_x0;
                                m_annot_rect[1] = m_annot_rect0[1] + y - m_annot_y0;
                                break;
                            case 2://xmid,top
                                m_annot_rect[1] = m_annot_rect0[1] + y - m_annot_y0;
                                break;
                            case 3://right,top
                                m_annot_rect[1] = m_annot_rect0[1] + y - m_annot_y0;
                                m_annot_rect[2] = m_annot_rect0[2] + x - m_annot_x0;
                                break;
                            case 4://right,ymid
                                m_annot_rect[2] = m_annot_rect0[2] + x - m_annot_x0;
                                break;
                            case 5://right,bottom
                                m_annot_rect[2] = m_annot_rect0[2] + x - m_annot_x0;
                                m_annot_rect[3] = m_annot_rect0[3] + y - m_annot_y0;
                                break;
                            case 6://xmid,bottom
                                m_annot_rect[3] = m_annot_rect0[3] + y - m_annot_y0;
                                break;
                            case 7://left,bottom
                                m_annot_rect[0] = m_annot_rect0[0] + x - m_annot_x0;
                                m_annot_rect[3] = m_annot_rect0[3] + y - m_annot_y0;
                                break;
                            case 8://left,ymid
                                m_annot_rect[0] = m_annot_rect0[0] + x - m_annot_x0;
                                break;
                            default:
                                MovRect(x - m_annot_x0, y - m_annot_y0);
                                break;
                        }
                    }
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    if (m_node > 0) {
                        float x = event.getX();
                        float y = event.getY();
                        PDFPos pos = m_layout.vGetPos((int) x, (int) y);
                        if (m_node != 9 || m_annot_page.GetPageNo() == pos.pageno) {
                            m_annot_rect0[0] = m_annot_page.ToPDFX(m_annot_rect[0], m_layout.vGetX());
                            m_annot_rect0[1] = m_annot_page.ToPDFY(m_annot_rect[3], m_layout.vGetY());
                            m_annot_rect0[2] = m_annot_page.ToPDFX(m_annot_rect[2], m_layout.vGetX());
                            m_annot_rect0[3] = m_annot_page.ToPDFY(m_annot_rect[1], m_layout.vGetY());
                            //add to redo/undo stack.
                            float[] rect = m_annot.GetRect();
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
                                float[] rect = m_annot.GetRect();
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
        }
    };
    private final IAnnotOP m_annot_op_line = new IAnnotOP() {
        private final Paint m_paint_s = NewPaintBorder();
        private final Paint m_paint_l = NewPaintLine();
        private final Paint m_paint_f = NewPaintFill();
        private int m_gap = 0;
        private int m_node = 0;
        private float[] m_pts0;
        private float[] m_pte0;
        private float[] m_pts;
        private float[] m_pte;
        @Override
        public void onDraw(Canvas canvas) {
            if (m_gap == 0) m_gap = dp2px(getContext(), 4);
            canvas.drawRect(m_annot_rect[0], m_annot_rect[1], m_annot_rect[2], m_annot_rect[3], m_paint_s);

            if (m_pts == null)
            {
                m_pts = m_annot.GetLinePoint(0);
                m_pts[0] = m_annot_page.GetVX(m_pts[0]) - m_layout.vGetX();
                m_pts[1] = m_annot_page.GetVY(m_pts[1]) - m_layout.vGetY();
            }
            if (m_pte == null)
            {
                m_pte = m_annot.GetLinePoint(1);
                m_pte[0] = m_annot_page.GetVX(m_pte[0]) - m_layout.vGetX();
                m_pte[1] = m_annot_page.GetVY(m_pte[1]) - m_layout.vGetY();
            }
            canvas.drawLine(m_pts[0], m_pts[1], m_pte[0], m_pte[1], m_paint_l);

            canvas.drawRect(m_pts[0] - m_gap, m_pts[1] - m_gap, m_pts[0] + m_gap, m_pts[1] + m_gap, m_paint_f);
            canvas.drawRect(m_pts[0] - m_gap, m_pts[1] - m_gap, m_pts[0] + m_gap, m_pts[1] + m_gap, m_paint_s);

            canvas.drawRect(m_pte[0] - m_gap, m_pte[1] - m_gap, m_pte[0] + m_gap, m_pte[1] + m_gap, m_paint_f);
            canvas.drawRect(m_pte[0] - m_gap, m_pte[1] - m_gap, m_pte[0] + m_gap, m_pte[1] + m_gap, m_paint_s);
        }

        @Override
        public void onTouch(MotionEvent event) {
            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN:
                    if (m_gap == 0) m_gap = dp2px(getContext(), 4);
                    if (m_pts0 == null)
                    {
                        m_pts0 = m_annot.GetLinePoint(0);
                        m_pts0[0] = m_annot_page.GetVX(m_pts0[0]) - m_layout.vGetX();
                        m_pts0[1] = m_annot_page.GetVY(m_pts0[1]) - m_layout.vGetY();
                        m_pts = new float[2];
                        m_pts[0] = m_pts0[0];
                        m_pts[1] = m_pts0[1];
                    }
                    if (m_pte0 == null)
                    {
                        m_pte0 = m_annot.GetLinePoint(1);
                        m_pte0[0] = m_annot_page.GetVX(m_pte0[0]) - m_layout.vGetX();
                        m_pte0[1] = m_annot_page.GetVY(m_pte0[1]) - m_layout.vGetY();
                        m_pte = new float[2];
                        m_pte[0] = m_pte0[0];
                        m_pte[1] = m_pte0[1];
                    }

                    m_annot_x0 = event.getX();
                    m_annot_y0 = event.getY();
                    m_annot_rect0 = new float[4];
                    m_annot_rect0[0] = m_annot_rect[0];
                    m_annot_rect0[1] = m_annot_rect[1];
                    m_annot_rect0[2] = m_annot_rect[2];
                    m_annot_rect0[3] = m_annot_rect[3];
                    if (m_annot_x0 >= m_pts[0] - m_gap && m_annot_x0 <= m_pts[0] + m_gap &&
                        m_annot_y0 >= m_pts[1] - m_gap && m_annot_y0 <= m_pts[1] + m_gap)
                        m_node = 1;
                    else if (m_annot_x0 >= m_pte[0] - m_gap && m_annot_x0 <= m_pte[0] + m_gap &&
                            m_annot_y0 >= m_pte[1] - m_gap && m_annot_y0 <= m_pte[1] + m_gap)
                        m_node = 2;
                    else if (m_annot_x0 > m_annot_rect[0] && m_annot_y0 > m_annot_rect[1] &&
                            m_annot_x0 < m_annot_rect[2] && m_annot_y0 < m_annot_rect[3])
                        m_node = 3;
                    else
                    {
                        m_node = 0;
                        m_annot_rect0 = null;
                    }
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (m_node > 0) {
                        float x = event.getX();
                        float y = event.getY();
                        switch(m_node)
                        {
                            case 1://start point
                                m_pts[0] = m_pts0[0] + x - m_annot_x0;
                                m_pts[1] = m_pts0[1] + y - m_annot_y0;
                                if (m_pts[0] > m_pte[0])
                                {
                                    m_annot_rect[0] = m_pte[0];
                                    m_annot_rect[2] = m_pts[0];
                                }
                                else
                                {
                                    m_annot_rect[0] = m_pts[0];
                                    m_annot_rect[2] = m_pte[0];
                                }
                                if (m_pts[1] > m_pte[1])
                                {
                                    m_annot_rect[1] = m_pte[1];
                                    m_annot_rect[3] = m_pts[1];
                                }
                                else
                                {
                                    m_annot_rect[1] = m_pts[1];
                                    m_annot_rect[3] = m_pte[1];
                                }
                                break;
                            case 2://end point
                                m_pte[0] = m_pte0[0] + x - m_annot_x0;
                                m_pte[1] = m_pte0[1] + y - m_annot_y0;
                                if (m_pts[0] > m_pte[0])
                                {
                                    m_annot_rect[0] = m_pte[0];
                                    m_annot_rect[2] = m_pts[0];
                                }
                                else
                                {
                                    m_annot_rect[0] = m_pts[0];
                                    m_annot_rect[2] = m_pte[0];
                                }
                                if (m_pts[1] > m_pte[1])
                                {
                                    m_annot_rect[1] = m_pte[1];
                                    m_annot_rect[3] = m_pts[1];
                                }
                                else
                                {
                                    m_annot_rect[1] = m_pts[1];
                                    m_annot_rect[3] = m_pte[1];
                                }
                                break;
                           default:
                               MovRect(x - m_annot_x0, y - m_annot_y0);
                                break;
                        }
                    }
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    if (m_node > 0) {
                        float x = event.getX();
                        float y = event.getY();
                        PDFPos pos = m_layout.vGetPos((int) x, (int) y);
                        if (m_node != 3)
                        {
                            m_pts[0] = m_annot_page.ToPDFX(m_pts[0], m_layout.vGetX());
                            m_pts[1] = m_annot_page.ToPDFY(m_pts[1], m_layout.vGetY());
                            m_pte[0] = m_annot_page.ToPDFX(m_pte[0], m_layout.vGetX());
                            m_pte[1] = m_annot_page.ToPDFY(m_pte[1], m_layout.vGetY());
                            m_annot.SetLinePoint(m_pts[0], m_pts[1], m_pte[0], m_pte[1]);
                            m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                            m_layout.vRenderSync(m_annot_page);
                            if (m_listener != null)
                                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                        }
                        else if (m_annot_page.GetPageNo() == pos.pageno) {
                            m_annot_rect0[0] = m_annot_page.ToPDFX(m_annot_rect[0], m_layout.vGetX());
                            m_annot_rect0[1] = m_annot_page.ToPDFY(m_annot_rect[3], m_layout.vGetY());
                            m_annot_rect0[2] = m_annot_page.ToPDFX(m_annot_rect[2], m_layout.vGetX());
                            m_annot_rect0[3] = m_annot_page.ToPDFY(m_annot_rect[1], m_layout.vGetY());
                            if (m_annot_rect0[0] > m_annot_rect0[2])
                            {
                                float tmp = m_annot_rect0[0];
                                m_annot_rect0[0] = m_annot_rect0[2];
                                m_annot_rect0[2] = tmp;
                            }
                            if (m_annot_rect0[1] > m_annot_rect0[3])
                            {
                                float tmp = m_annot_rect0[1];
                                m_annot_rect0[1] = m_annot_rect0[3];
                                m_annot_rect0[3] = tmp;
                            }
                            //add to redo/undo stack.
                            float[] rect = m_annot.GetRect();
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
                                float[] rect = m_annot.GetRect();
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
                    m_pts = null;
                    m_pte = null;
                    m_pts0 = null;
                    m_pte0 = null;
                    m_node = 0;
                    break;
            }
        }
    };
    private final IAnnotOP m_annot_op_poly = new IAnnotOP() {
        private final Paint m_paint_s = NewPaintBorder();
        private final Paint m_paint_l = NewPaintLine();
        private final Paint m_paint_f = NewPaintFill();
        private float[] m_pts;
        private float[] m_pts0;
        private int m_atype;
        private int m_gap;
        private int m_node = -1;
        private final android.graphics.Path m_path = new android.graphics.Path();
        private float[] getPoints()
        {
            m_atype = m_annot.GetType();
            Path path = null;
            int cnt = 0;
            if (m_atype == 7) {
                path = m_annot.GetPolygonPath();
                cnt = path.GetNodeCount() - 1;
            }
            else if (m_atype == 8) {
                path = m_annot.GetPolylinePath();
                cnt = path.GetNodeCount();
            }
            if (path == null) return null;
            float[] pts = new float[cnt * 2];
            float[] pt1 = new float[2];
            int idx = 0;
            for (int ipt = 0; ipt < cnt; ipt++)
            {
                path.GetNode(ipt, pt1);
                pt1[0] = m_annot_page.GetVX(pt1[0]) - m_layout.vGetX();
                pt1[1] = m_annot_page.GetVY(pt1[1]) - m_layout.vGetY();
                pts[idx] = pt1[0];
                pts[idx + 1] = pt1[1];
                idx += 2;
            }
            return pts;
        }
        private void drawPts(Canvas canvas)
        {
            int cnt = m_pts.length;
            m_path.reset();
            m_path.moveTo(m_pts[0], m_pts[1]);
            for (int ipt = 2; ipt < cnt; ipt += 2)
                m_path.lineTo(m_pts[ipt], m_pts[ipt + 1]);
            canvas.drawPath(m_path, m_paint_l);
            for (int ipt = 0; ipt < cnt; ipt += 2)
            {
                canvas.drawRect(m_pts[ipt] - m_gap, m_pts[ipt + 1] - m_gap,
                        m_pts[ipt] + m_gap, m_pts[ipt + 1] + m_gap, m_paint_f);
                canvas.drawRect(m_pts[ipt] - m_gap, m_pts[ipt + 1] - m_gap,
                        m_pts[ipt] + m_gap, m_pts[ipt + 1] + m_gap, m_paint_s);
            }
        }
        private int getNode(float x, float y)
        {
            int cnt = m_pts.length;
            for (int ipt = 0; ipt < cnt; ipt += 2)
            {
                if (x >= m_pts[ipt] - m_gap && x < m_pts[ipt] + m_gap && y >= m_pts[ipt + 1] - m_gap && y < m_pts[ipt + 1] + m_gap)
                    return (ipt >> 1);
            }
            return -1;
        }
        private Path getPath()
        {
            int cnt = m_pts.length;
            Path path = new Path();
            path.MoveTo(m_annot_page.ToPDFX(m_pts[0], m_layout.vGetX()),
                    m_annot_page.ToPDFY(m_pts[1], m_layout.vGetY()));
            for (int ipt = 2; ipt < cnt; ipt += 2)
            {
                path.LineTo(m_annot_page.ToPDFX(m_pts[ipt], m_layout.vGetX()),
                        m_annot_page.ToPDFY(m_pts[ipt + 1], m_layout.vGetY()));
            }
            return path;
        }
        private void updateRect()
        {
            int cnt = m_pts.length;
            m_annot_rect[0] = m_pts[0];
            m_annot_rect[1] = m_pts[1];
            m_annot_rect[2] = m_pts[0];
            m_annot_rect[3] = m_pts[1];
            for (int ipt = 2; ipt < cnt; ipt += 2)
            {
                if (m_annot_rect[0] > m_pts[ipt]) m_annot_rect[0] = m_pts[ipt];
                else if(m_annot_rect[2] < m_pts[ipt]) m_annot_rect[2] = m_pts[ipt];

                if (m_annot_rect[1] > m_pts[ipt + 1]) m_annot_rect[1] = m_pts[ipt + 1];
                else if(m_annot_rect[3] < m_pts[ipt + 1]) m_annot_rect[3] = m_pts[ipt + 1];
            }
        }
        @Override
        public void onDraw(Canvas canvas) {
            if (m_gap == 0) m_gap = dp2px(getContext(), 4);
            if (m_pts == null) m_pts = getPoints();
            canvas.drawRect(m_annot_rect[0], m_annot_rect[1], m_annot_rect[2], m_annot_rect[3], m_paint_s);
            drawPts(canvas);
        }

        @Override
        public void onTouch(MotionEvent event) {
            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN:
                    if (m_gap == 0) m_gap = dp2px(getContext(), 4);
                    if (m_pts == null) m_pts = getPoints();

                    m_annot_x0 = event.getX();
                    m_annot_y0 = event.getY();
                    m_annot_rect0 = new float[4];
                    m_annot_rect0[0] = m_annot_rect[0];
                    m_annot_rect0[1] = m_annot_rect[1];
                    m_annot_rect0[2] = m_annot_rect[2];
                    m_annot_rect0[3] = m_annot_rect[3];
                    m_node = getNode(m_annot_x0, m_annot_y0);
                    if (m_node >= 0) {
                        m_pts0 = new float[m_pts.length];
                        System.arraycopy(m_pts, 0, m_pts0, 0, m_pts.length);
                    }
                    else
                    {
                        if (m_annot_x0 > m_annot_rect[0] && m_annot_y0 > m_annot_rect[1] &&
                                m_annot_x0 < m_annot_rect[2] && m_annot_y0 < m_annot_rect[3])
                            m_node = 0;
                        else m_node = -1;
                        m_pts0 = null;
                    }
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (m_pts != null) {
                        float x = event.getX();
                        float y = event.getY();
                        if (m_pts0 != null)
                        {
                            m_pts[m_node << 1] = m_pts0[m_node << 1] + x - m_annot_x0;
                            m_pts[(m_node << 1) + 1] = m_pts0[(m_node << 1) + 1] + y - m_annot_y0;
                            updateRect();
                        }
                        else
                            MovRect(x - m_annot_x0, y - m_annot_y0);
                    }
                    break;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    if (m_node >= 0) {
                        float x = event.getX();
                        float y = event.getY();
                        PDFPos pos = m_layout.vGetPos((int) x, (int) y);
                        if (m_pts0 != null)
                        {
                            Path path = getPath();
                            if (m_atype == 7)
                            {
                                path.ClosePath();
                                m_annot.SetPolygonPath(path);
                            }
                            else if(m_atype == 8)
                                m_annot.SetPolylinePath(path);
                            m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                            m_layout.vRenderSync(m_annot_page);
                            if (m_listener != null)
                                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                        }
                        else if (m_annot_page.GetPageNo() == pos.pageno) {
                            m_annot_rect0[0] = m_annot_page.ToPDFX(m_annot_rect[0], m_layout.vGetX());
                            m_annot_rect0[1] = m_annot_page.ToPDFY(m_annot_rect[3], m_layout.vGetY());
                            m_annot_rect0[2] = m_annot_page.ToPDFX(m_annot_rect[2], m_layout.vGetX());
                            m_annot_rect0[3] = m_annot_page.ToPDFY(m_annot_rect[1], m_layout.vGetY());
                            if (m_annot_rect0[0] > m_annot_rect0[2])
                            {
                                float tmp = m_annot_rect0[0];
                                m_annot_rect0[0] = m_annot_rect0[2];
                                m_annot_rect0[2] = tmp;
                            }
                            if (m_annot_rect0[1] > m_annot_rect0[3])
                            {
                                float tmp = m_annot_rect0[1];
                                m_annot_rect0[1] = m_annot_rect0[3];
                                m_annot_rect0[3] = tmp;
                            }
                            //add to redo/undo stack.
                            float[] rect = m_annot.GetRect();
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
                                float[] rect = m_annot.GetRect();
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
                    m_pts = null;
                    m_pts0 = null;
                    m_node = 0;
                    break;
            }
        }
    };
    private IAnnotOP m_annot_op;

    private class PDFGestureListener extends GestureDetector.SimpleOnGestureListener {
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
            if (m_status == STA_NONE && e.getActionMasked() == MotionEvent.ACTION_UP)
            {
                float x = e.getX();
                float y = e.getY();
                int pageno = m_layout.vGetPage((int)x, (int)y);
                return (m_listener != null && m_listener.OnPDFDoubleTapped(pageno, x, y));
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
            if(m_status != STA_NONE) return;
            /*
            m_sel_icon1 = BitmapFactory.decodeResource(PDFLayoutView.this.getResources(), R.drawable.pt_start);
            m_sel_icon2 = BitmapFactory.decodeResource(PDFLayoutView.this.getResources(), R.drawable.pt_end);
            m_status = STA_SELECT;
            m_hold_x = e.getX();
            m_hold_y = e.getY();
            if (m_sel != null) {
                m_sel.Clear();
                m_sel = null;
            }
            m_annot_pos = m_layout.vGetPos((int) m_hold_x, (int) m_hold_y);
            m_annot_page = m_layout.vGetPage(m_annot_pos.pageno);
            m_sel = new VSel(m_doc.GetPage(m_annot_pos.pageno));
            invalidate();
            */

            if (m_status == STA_NONE && m_listener != null)
            {
                float x = e.getX();
                float y = e.getY();
                int pageno = m_layout.vGetPage((int)x, (int)y);
                m_listener.OnPDFLongPressed(pageno, x, y);
            }
        }

        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
            return false;
        }

        @Override
        public void onShowPress(MotionEvent e) {
        }

        /**
         * we make it public, because some developers may want to override this method.
         */
        public void onEditAnnot() {
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
                            if (m_annot != null && Global.g_exec_js)
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
            } catch (Exception ignored) { }
        }

        boolean[] mCheckedItems;

        private void onListAnnot() {
            try {
                AlertDialog.Builder alertBuilder = new AlertDialog.Builder(getContext());
                String[] items = new String[m_annot.GetListItemCount()];
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
                        if (m_annot != null && Global.g_exec_js)
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
            if (m_status != STA_NONE && m_status != STA_ANNOT) return false;
            if (m_annot_pg != null) {
                m_annot_pg.Close();
                m_annot_pg = null;
            }
            m_annot_pos = m_layout.vGetPos((int) e.getX(), (int) e.getY());
            m_annot_page = m_layout.vGetPage(m_annot_pos.pageno);
            m_annot_pg = m_doc.GetPage(m_annot_page.GetPageNo());
            m_annot = m_annot_pg.GetAnnotFromPoint(m_annot_pos.x, m_annot_pos.y);
            if (m_annot == null) {
                if (m_listener != null) {
                    if (m_status == STA_ANNOT)
                        m_listener.OnPDFAnnotTapped(m_annot_pos.pageno, null);
                    else
                        m_listener.OnPDFBlankTapped(m_annot_pos.pageno);
                }
                m_annot_page = null;
                m_annot_pos = null;
                m_annot_rect = null;
                m_annot_pg.Close();
                m_annot_pg = null;
                PDFEndAnnot();
                m_status = STA_NONE;
            } else {
                m_annot_pg.ObjsStart();
                m_annot_rect = m_annot.GetRect();
                float tmp = m_annot_rect[1];
                m_annot_rect[0] = m_annot_page.GetVX(m_annot_rect[0]) - m_layout.vGetX();
                m_annot_rect[1] = m_annot_page.GetVY(m_annot_rect[3]) - m_layout.vGetY();
                m_annot_rect[2] = m_annot_page.GetVX(m_annot_rect[2]) - m_layout.vGetX();
                m_annot_rect[3] = m_annot_page.GetVY(tmp) - m_layout.vGetY();
                m_status = STA_ANNOT;
                int atype = m_annot.GetType();
                if (atype == 5 || atype == 6 || atype == 15)//it can resize
                    m_annot_op = m_annot_op_resize;
                else if (atype == 4)//it is line annotation
                    m_annot_op = m_annot_op_line;
                else if (atype == 7 || atype == 8)//it is polygon or polyline annotation
                    m_annot_op = m_annot_op_poly;
                else
                    m_annot_op = m_annot_op_normal;

                int check = m_annot.GetCheckStatus();
                if(Global.g_annot_readonly && m_annot.IsReadOnly()) {
                    Toast.makeText(getContext(), "Readonly annotation", Toast.LENGTH_SHORT).show();
                    if(m_listener != null) m_listener.OnPDFAnnotTapped(m_annot_pos.pageno, m_annot);
                } else if (PDFCanSave() && check >= 0) {//it is checkbox or radio box
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
                    if (m_annot != null && Global.g_exec_js)
                        executeAnnotJS();
                    m_layout.vRenderSync(m_annot_page);
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                    PDFEndAnnot();
                } else if (PDFCanSave() && m_annot.GetEditType() > 0) //if form edit-box.
                    onEditAnnot();
                else if (PDFCanSave() && m_annot.GetComboItemCount() >= 0)//if form choice
                {
                    try {
                        int[] location = new int[2];
                        getLocationOnScreen(location);
                        String[] opts = new String[m_annot.GetComboItemCount()];
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
                        ComboList combo = (ComboList)m_pCombo.getContentView().findViewById(R.id.annot_combo);
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
                                        if (m_annot != null && Global.g_exec_js)
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
                    } catch (Exception ignored) {
                    }
                } else if (PDFCanSave() && m_annot.GetListItemCount() >= 0)  //if list choice
                    onListAnnot();
                else if (PDFCanSave() && m_annot.GetFieldType() == 4 && m_annot.GetSignStatus() == 0 && Global.g_hand_signature)  //signature field
                    handleSignatureField();
                else if(m_annot.GetURI() != null && Global.g_auto_launch_link && m_listener != null) { // launch link automatically
                    m_listener.OnPDFOpenURI(m_annot.GetURI());
                    PDFEndAnnot();
                } else if (m_listener != null) {
                    m_listener.OnPDFAnnotTapped(m_annot_pos.pageno, m_annot);
                    if (PDFCanSave() && m_aMenu != null) {
                        m_aMenu.show(m_annot, m_annot_rect, new UIAnnotMenu.IMemnuCallback() {
                            //the update need new operator in OPStack
                            @Override
                            public void onUpdate() {
                                m_layout.vRenderSync(m_annot_page);
                                if (m_listener != null)
                                    m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                                PDFEndAnnot();
                            }

                            @Override
                            public void onRemove() {
                                PDFRemoveAnnot();
                            }

                            @Override
                            public void onPerform() {
                                PDFPerformAnnot();
                            }

                            @Override
                            public void onCancel() {
                                PDFCancelAnnot();
                            }
                        });
                    }
                }
                invalidate();
            }
            return true;
        }

        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            return false;
        }

        private void handleSignatureField() {
            int ssta = m_annot.GetSignStatus();
            if (ssta < 0) Toast.makeText(getContext(), "only premium licese support signature", Toast.LENGTH_LONG).show();
            else if (m_annot.GetSignStatus() == 1)
            {
                UIAnnotDlgSignProp dlg = new UIAnnotDlgSignProp(getContext());
                dlg.show(m_annot, m_doc, new UIAnnotMenu.IMemnuCallback() {
                    @Override
                    public void onUpdate() { }
                    @Override
                    public void onRemove() { }
                    @Override
                    public void onPerform() { }
                    @Override
                    public void onCancel() { }
                });
            }
            else
            {
                UIAnnotDlgSign dlg = new UIAnnotDlgSign(getContext());
                dlg.show(m_annot, m_doc, new UIAnnotMenu.IMemnuCallback() {
                    @Override
                    public void onUpdate() {
                        m_layout.vRenderSync(m_annot_page);
                        if (m_listener != null)
                            m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                        PDFEndAnnot();
                    }
                    @Override
                    public void onRemove() { }
                    @Override
                    public void onPerform() { }
                    @Override
                    public void onCancel() { }
                });
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

    static class PDFVPageSet {
        PDFVPageSet(int max_len) {
            pages = new VPage[max_len];
            pages_cnt = 0;
        }

        void Insert(VPage vpage) {
            int cur;
            for (cur = 0; cur < pages_cnt; cur++) {
                if (pages[cur] == vpage) return;
            }
            pages[cur] = vpage;
            pages_cnt++;
        }

        VPage[] pages;
        int pages_cnt;
    }

    private ActivityManager m_amgr;
    private final ActivityManager.MemoryInfo m_info = new ActivityManager.MemoryInfo();
    private final Paint m_info_paint = new Paint();

    public PDFLayoutView(Context context) {
        super(context);
        m_doc = null;
        m_gesture = new GestureDetector(context, new PDFGestureListener());
        setBackgroundColor(Global.g_readerview_bg_color);
        if (Global.debug_mode) {
            m_amgr = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            m_info_paint.setColor(0xFFFF0000);
            m_info_paint.setTextSize(30);
        }
    }

    public PDFLayoutView(Context context, AttributeSet attrs) {
        super(context, attrs);
        m_doc = null;
        m_gesture = new GestureDetector(context, new PDFGestureListener());
        setBackgroundColor(Global.g_readerview_bg_color);
        if (Global.debug_mode) {
            m_amgr = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            m_info_paint.setColor(0xFFFF0000);
            m_info_paint.setTextSize(30);
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (m_status == STA_ANNOT)
            PDFEndAnnot();
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
            int[] rect1 = m_sel.GetRect1(scale, pheight, orgx, orgy);
            int[] rect2 = m_sel.GetRect2(scale, pheight, orgx, orgy);
            if (rect1 != null && rect2 != null && Global.g_use_sel_icons) {
                canvas.drawBitmap(m_sel_icon1, rect1[0] - m_sel_icon1.getWidth(), rect1[1] - m_sel_icon1.getHeight(), null);
                canvas.drawBitmap(m_sel_icon2, rect2[2], rect2[3], null);
            }
        }
    }

    private void onDrawAnnot(Canvas canvas) {
        if (m_status == STA_ANNOT && Global.g_highlight_annotation) {
            m_annot_op.onDraw(canvas);
        }
    }

    private void onDrawRect(Canvas canvas) {
        if (m_status == STA_RECT && m_rects != null) {
            int len = m_rects.length;
            int cur;
            Paint paint1 = new Paint();
            Paint paint2 = new Paint();
            paint1.setStyle(Style.STROKE);
            paint1.setStrokeWidth(Global.g_rect_annot_width);
            paint1.setColor(Global.g_rect_annot_color);
            paint2.setStyle(Style.FILL);
            paint2.setColor(Global.g_rect_annot_fill_color);
            float rad = Global.g_rect_annot_width * 0.5f;
            for (cur = 0; cur < len; cur += 4) {
                float[] rect = new float[4];
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
                canvas.drawRect(rect[0] + rad, rect[1] + rad, rect[2] - rad, rect[3] - rad, paint2);
            }
        }
    }

    private void onDrawLine(Canvas canvas) {
        if (m_status == STA_LINE && m_rects != null) {
            int len = m_rects.length;
            int cur;
            Paint paint1 = new Paint();
            paint1.setStyle(Style.STROKE);
            paint1.setStrokeWidth(Global.g_line_annot_width);
            paint1.setColor(Global.g_line_annot_color);
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
                float[] rect = new float[4];
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

    private void onDrawEditbox(Canvas canvas) {
        if (m_status == STA_EDITBOX && m_rects != null) {
            int len = m_rects.length;
            int cur;
            Paint paint1 = new Paint();
            paint1.setStyle(Paint.Style.STROKE);
            paint1.setStrokeWidth(3);
            paint1.setColor(0x80FF0000);
            for (cur = 0; cur < len; cur += 4) {
                float[] rect = new float[4];
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
            paint1.setStrokeWidth(Global.g_oval_annot_width);
            paint1.setColor(Global.g_oval_annot_color);
            paint2.setStyle(Style.FILL);
            paint2.setColor(Global.g_oval_annot_fill_color);
            for (cur = 0; cur < len; cur += 4) {
                float[] rect = new float[4];
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
    private static int dp2px(Context context, float dpValue) {
        return (int)(dpValue * context.getResources().getDisplayMetrics().density);
    }
    private void onDrawPolygon(Canvas canvas)
    {
        if(m_status != STA_POLYGON || m_polygon == null) return;
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setColor(Global.g_line_annot_color);
        paint.setStrokeWidth(Global.g_line_annot_width);
        paint.setStrokeCap(Paint.Cap.BUTT);
        paint.setStrokeJoin(Paint.Join.BEVEL);
        m_polygon.OnDraw(canvas, 0, 0, paint);

        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Global.g_line_annot_fill_color);
        if(m_polygon.GetNodeCount() > 2)
            m_polygon.OnDraw(canvas, 0, 0, paint);
        m_polygon.onDrawPoint(canvas, 0, 0, dp2px(getContext(), 4), paint);
    }

    private void onDrawPolyline(Canvas canvas)
    {
        if(m_status != STA_POLYLINE || m_polygon == null) return;
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.STROKE);
        paint.setColor(Global.g_line_annot_color);
        paint.setStrokeWidth(Global.g_line_annot_width);
        paint.setStrokeCap(Paint.Cap.BUTT);
        paint.setStrokeJoin(Paint.Join.BEVEL);
        m_polygon.OnDraw(canvas, 0, 0, paint);

        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Global.g_line_annot_fill_color);
        m_polygon.onDrawPoint(canvas, 0, 0, dp2px(getContext(), 4), paint);
    }

    /**
     * the draw function invoke onDraw and then call dispatchDraw. so we override only to draw on Canvas to reduce drawing time.
     * @param canvas Canvas object
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
            onDrawEditbox(canvas);
            onDrawPolygon(canvas);
            onDrawPolyline(canvas);
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

    private boolean onTouchEditbox(MotionEvent event) {
        if (m_status != STA_EDITBOX) return false;
        int len = 0;
        if (m_rects != null) len = m_rects.length;
        PDFPos pos;
        int cur;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float[] rects = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                rects[cur    ] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                break;
            case MotionEvent.ACTION_UP://when touch up, it shall popup editbox on page
            case MotionEvent.ACTION_CANCEL:
                m_rects[len - 2] = event.getX();
                m_rects[len - 1] = event.getY();
                pos = m_layout.vGetPos((int) m_rects[0], (int) m_rects[1]);
                m_annot_page = m_layout.vGetPage(pos.pageno);
                m_annot_pg = m_doc.GetPage(m_annot_page.GetPageNo());
                PDFSetEditbox(1);//end editbox.
            {//popup editbox from UI.
                m_annot_pg.ObjsStart();
                m_annot = m_annot_pg.GetAnnot(m_annot_pg.GetAnnotCount() - 1);
                m_annot_rect = m_annot.GetRect();
                float tmp = m_annot_rect[1];
                m_annot_rect[0] = m_annot_page.GetVX(m_annot_rect[0]) - m_layout.vGetX();
                m_annot_rect[1] = m_annot_page.GetVY(m_annot_rect[3]) - m_layout.vGetY();
                m_annot_rect[2] = m_annot_page.GetVX(m_annot_rect[2]) - m_layout.vGetX();
                m_annot_rect[3] = m_annot_page.GetVY(tmp) - m_layout.vGetY();
                if(m_listener != null)
                    m_listener.OnPDFAnnotTapped(m_annot_page.GetPageNo(), m_annot);
                m_status = STA_ANNOT;
                m_annot_op = m_annot_op_normal;
                if (m_pEdit == null) m_pEdit = new UIAnnotPopEdit(this);
                m_pEdit.update(m_annot, m_annot_rect, m_annot_page.vGetScale());
                m_edit_type = 1;
                m_pEdit.setOnDismissListener(new PopupWindow.OnDismissListener() {
                    @Override
                    public void onDismiss() {
                        if (m_annot != null) {
                            if (!m_annot.SetEditText(m_pEdit.getEditText())) {
                                Log.e("RDERR", "set EditText failed.");
                            }
                            m_annot.SetModifyDate(CommonUtil.getCurrentDate());
                            //if (m_annot != null && Global.sExecuteAnnotJS) executeAnnotJS();//there is JS on free text annotation.
                            m_layout.vRenderSync(m_annot_page);
                            if (m_listener != null)
                                m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                            PDFEndAnnot();
                            m_edit_type = 0;
                        }
                    }
                });
                post(new Runnable() {
                    @Override
                    public void run() {
                        int[] location = new int[2];
                        getLocationOnScreen(location);
                        m_pEdit.show(PDFLayoutView.this, (int) m_annot_rect[0] + location[0], (int) (m_annot_rect[1] + location[1]));
                    }
                });
            }
            break;
        }
        invalidate();
        return true;
    }
    private boolean onTouchPolygon(MotionEvent event) {
        if (m_status != STA_POLYGON) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (m_annot_page == null) {
                    PDFPos pos = m_layout.vGetPos((int) event.getX(), (int) event.getY());
                    m_annot_page = m_layout.vGetPage(pos.pageno);
                }
                if(m_polygon.GetNodeCount() < 1)
                    m_polygon.MoveTo(event.getX(), event.getY());
                else
                    m_polygon.LineTo(event.getX(), event.getY());
                break;
        }
        invalidate();
        return true;
    }

    private boolean onTouchPolyline(MotionEvent event) {
        if (m_status != STA_POLYLINE) return false;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (m_annot_page == null) {
                    PDFPos pos = m_layout.vGetPos((int) event.getX(), (int) event.getY());
                    m_annot_page = m_layout.vGetPage(pos.pageno);
                }
                if(m_polygon.GetNodeCount() < 1)
                    m_polygon.MoveTo(event.getX(), event.getY());
                else
                    m_polygon.LineTo(event.getX(), event.getY());
                break;
        }
        invalidate();
        return true;
    }

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
                    m_layout.vMoveEnd();
                    invalidate();
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
                    if (!Global.g_zoomed_stop_on_boundaries)
                        m_layout.vMoveEnd();
                    invalidate();
                    m_hold = false;
                    if (m_listener != null)
                        m_listener.OnPDFZoomEnd();
                }
                break;
            case MotionEvent.ACTION_CANCEL:
                if (m_status == STA_ZOOM)//event captured by system gesture.
                {
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
        int cur;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float[] rects = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                rects[cur    ] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
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
        int cur;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float[] rects = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                rects[cur    ] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
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
        if (m_status != STA_ANNOT || !PDFCanSave()) return false;
        if ((Global.g_annot_lock && m_annot.IsLocked()) || (Global.g_annot_readonly && m_annot.IsReadOnly()) ||
                m_annot.GetType() == 2 ||
                m_annot.GetType() == 9 ||
                m_annot.GetType() == 10 ||
                m_annot.GetType() == 11 ||
                m_annot.GetType() == 12 ||
                m_annot.GetType() == 20) {
            PDFEndAnnot();
            return false;
        }
        m_annot_op.onTouch(event);
        invalidate();
        return true;
    }

    private boolean onTouchLine(MotionEvent event) {
        if (m_status != STA_LINE) return false;
        int len = 0;
        if (m_rects != null) len = m_rects.length;
        int cur;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float[] rects = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                rects[cur    ] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
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
        int cur;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                float[] rects = new float[len + 4];
                for (cur = 0; cur < len; cur++)
                    rects[cur] = m_rects[cur];
                rects[cur    ] = event.getX();
                rects[cur + 1] = event.getY();
                rects[cur + 2] = event.getX();
                rects[cur + 3] = event.getY();
                m_rects = rects;
                break;
            case MotionEvent.ACTION_MOVE:
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
                            VPage[] pages = new VPage[cnt + 1];
                            int[] indecs = new int[cnt + 1];
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
                    float[] pt = new float[2];
                    pt[0] = pos.x;
                    pt[1] = pos.y;
                    page.AddAnnotText(pt);
                    onAnnotCreated(page.GetAnnot(page.GetAnnotCount() - 1));
                    //add to redo/undo stack.
                    m_opstack.push(new OPAdd(pos.pageno, page, page.GetAnnotCount() - 1));
                    m_layout.vRenderSync(vpage);
                    invalidate();
                    //page.Close();
                    m_annot_pg = page;
                    m_annot = m_annot_pg.GetAnnot(m_annot_pg.GetAnnotCount() - 1);
                    m_annot_rect = m_annot.GetRect();
                    float tmp = m_annot_rect[1];
                    m_annot_page = m_layout.vGetPage(pos.pageno);
                    m_annot_rect[0] = m_annot_page.GetVX(m_annot_rect[0]) - m_layout.vGetX();
                    m_annot_rect[1] = m_annot_page.GetVY(m_annot_rect[3]) - m_layout.vGetY();
                    m_annot_rect[2] = m_annot_page.GetVX(m_annot_rect[2]) - m_layout.vGetX();
                    m_annot_rect[3] = m_annot_page.GetVY(tmp) - m_layout.vGetY();
                    if(m_listener != null)
                        m_listener.OnPDFAnnotTapped(m_annot_page.GetPageNo(), m_annot);
                    m_status = STA_ANNOT;
                    m_annot_op = m_annot_op_normal;
                    onEditPopup();
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
            if (!TextUtils.isEmpty(Global.g_annot_def_author))
                annot.SetPopupLabel(Global.g_annot_def_author);
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
        if (onTouchEditbox(event)) return true;
        if (onTouchPolygon(event)) return true;
        if (onTouchPolyline(event)) return true;
        if (onTouchAnnot(event)) return true;
        return true;
    }

    @Override
    public void computeScroll() {
        if (m_layout != null && m_layout.vScrollCompute())
            invalidate();
    }

    public int PDFGetView() { return m_view_mode; }
    public void PDFSetView(int style) {
        PDFPos pos = null;
        if (m_layout != null)
            pos = m_layout.vGetPos(0, 0);
        PDFClose();
        m_view_mode = style;
        switch (style) {
            case 1:
                m_layout = new PDFLayoutHorz(getContext(), Global.g_layout_rtol);
                break;
            case 3: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean[] paras = new boolean[m_doc.GetPageCount()];
                for (int cur = 0; cur < paras.length; cur++)  paras[cur] = false;
                layout.vSetLayoutPara(null, paras, Global.g_layout_rtol, false);
                m_layout = layout;
            }
            break;
            case 4: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean[] paras = new boolean[m_doc.GetPageCount()];
                paras[0] = false;//first page is cover, display as single page.
                for (int cur = 1; cur < paras.length; cur++)
                    paras[cur] = true;
                layout.vSetLayoutPara(null, paras, Global.g_layout_rtol, false);
                m_layout = layout;
            }
            break;
            case 6: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean[] paras = new boolean[m_doc.GetPageCount()];
                paras[0] = false;//first page is cover, display as single page.
                for (int cur = 1; cur < paras.length; cur++)
                    paras[cur] = true;
                layout.vSetLayoutPara(null, paras, Global.g_layout_rtol, false);
                m_layout = layout;
            }
            break;
            case 7:
                m_layout = new PDFLayoutDualV(getContext(), GLLayoutDual.ALIGN_CENTER, Global.g_layout_rtol, true, false);
                break;
            case 8:
                m_layout = new PDFLayoutDualV(getContext(), GLLayoutDual.ALIGN_CENTER, Global.g_layout_rtol, false, false);
                break;
            default: {
                m_layout = new PDFLayoutVert(getContext());
            }
            break;
        }
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
    private int m_view_mode;
    private PDFLayout.PDFPos m_save_pos;
    public void PDFSaveView()
    {
        int w = getWidth();
        int h = getHeight();
        if (m_layout != null) m_save_pos = m_layout.vGetPos(w >> 1, h >> 1);
        else m_save_pos = null;
        PDFSetEditbox(2);//cancel
        if (m_layout != null) {
            PDFLayout layout = m_layout;
            m_layout = null;
            layout.vClose();
        }
    }
    public void PDFRestoreView()
    {
        //reset stack.
        m_opstack = new PDFLayoutOPStack();
        switch (m_view_mode) {
            case 1:
                m_layout = new PDFLayoutHorz(getContext(), Global.g_layout_rtol);
                break;
            case 3: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean[] paras = new boolean[m_doc.GetPageCount()];
                for (int cur = 0; cur < paras.length; cur++)  paras[cur] = false;
                layout.vSetLayoutPara(null, paras, Global.g_layout_rtol, false);
                m_layout = layout;
            }
            break;
            case 4: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean[] paras = new boolean[m_doc.GetPageCount()];
                paras[0] = false;//first page is cover, display as single page.
                for (int cur = 1; cur < paras.length; cur++)
                    paras[cur] = true;
                layout.vSetLayoutPara(null, paras, Global.g_layout_rtol, false);
                m_layout = layout;
            }
            break;
            case 6: {
                PDFLayoutDual layout = new PDFLayoutDual(getContext());
                boolean[] paras = new boolean[m_doc.GetPageCount()];
                paras[0] = false;//first page is cover, display as single page.
                for (int cur = 1; cur < paras.length; cur++)
                    paras[cur] = true;
                layout.vSetLayoutPara(null, null, Global.g_layout_rtol, false);
                m_layout = layout;
            }
            break;
            case 7:
                m_layout = new PDFLayoutDualV(getContext(), GLLayoutDual.ALIGN_CENTER, Global.g_layout_rtol, true, false);
                break;
            case 8:
                m_layout = new PDFLayoutDualV(getContext(), GLLayoutDual.ALIGN_CENTER, Global.g_layout_rtol, false, false);
                break;
            default: {
                m_layout = new PDFLayoutVert(getContext());
            }
            break;
        }
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
            } else if (m_save_pos != null) {
                if(m_view_mode == 3 || m_view_mode == 4 || m_view_mode == 6)
                    m_layout.vGotoPage(m_save_pos.pageno);
                else
                    m_layout.vSetPos(0, 0, m_save_pos);
                m_layout.vMoveEnd();
            }
        }
        invalidate();
    }

    public void PDFOpen(Document doc, ILayoutView.PDFLayoutListener listener) {
        m_doc = doc;
        m_listener = listener;
        PDFSetView(Global.g_view_mode);
    }

    public void setAnnotMenu(UIAnnotMenu amenu) {
        m_aMenu = amenu;
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
            m_goto_pos = new PDFPos();
            m_goto_pos.pageno = pageno;
            m_goto_pos.x = 0;
            m_goto_pos.y = m_doc.GetPageHeight(pageno) + 1;
        } else {
            m_layout.vGotoPage(pageno);
            invalidate();
        }
    }

    @Override
    public void PDFGotoDest(int[] vals) {
        if (m_layout == null) return;
        PDFPos pos = new PDFPos();
        pos.pageno = vals[0];
        pos.x = 0;
        if (vals[1] == 1 || vals[1] == 3 || vals[1] == 5 || vals[1] == 7)
            pos.y = vals[2] / 256.0f;
        else
            pos.y = m_doc.GetPageHeight(vals[0]) + 1;
        if (m_layout.vGetHeight() <= 0 || m_layout.vGetWidth() <= 0) {
            m_goto_pos = pos;
        } else {
            m_layout.vSetPos(0, 0, pos);
            //m_layout.vGotoPage(vals[0]);
            invalidate();
        }
    }

    public void PDFScrolltoPage(int pageno)
    {
        if (m_layout == null) return;
        if (m_layout.vGetHeight() <= 0 || m_layout.vGetWidth() <= 0) {
            m_goto_pos = new PDFPos();
            m_goto_pos.pageno = pageno;
            m_goto_pos.x = 0;
            m_goto_pos.y = m_doc.GetPageHeight(pageno) + 1;
        } else {
            m_layout.vScrolltoPage(pageno);
            invalidate();
        }
    }

    public void PDFCloseOnUI()
    {
        if (m_layout != null)
        {
            PDFCancelAnnot();
            PDFEndAnnot();
        }
    }
    public void PDFClose() {
        if (m_layout != null) {
            m_layout.vClose();
            m_layout = null;
            m_status = STA_NONE;
            m_zooming = false;
            m_pageno = -1;
        }
    }

    public boolean PDFIsOpen() {
        return m_layout != null && m_doc != null && m_doc.IsOpened();
    }

    public void OnPageChanged(int pageno) {
        m_pageno = pageno;
        if (m_listener != null)
            m_listener.OnPDFPageChanged(pageno);
    }

    public void OnPageRendered(int pageno) {
        invalidate();
        if (m_listener != null && m_layout != null)
            m_listener.OnPDFPageRendered(m_layout.vGetPage(pageno));
    }

    @Override
    public void OnCacheRendered(int pageno) {
        invalidate();
    }

    public void OnFound(boolean found) {
        if (found) invalidate();
        else Toast.makeText(getContext(), R.string.no_more_found, Toast.LENGTH_SHORT).show();
        if (m_listener != null)
            m_listener.OnPDFSearchFinished(found);
    }

    public void OnPageDisplayed(Canvas canvas, VPage vpage) {
        if (m_listener != null) m_listener.OnPDFPageDisplayed(canvas, vpage);
    }

    public void OnTimer() {
        if (m_layout != null) {
            if (m_zooming && m_layout.vZoomEnd()) {
                m_zooming = false;
                invalidate();
            }
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
            m_ink = new Ink(Global.g_ink_width, Global.g_ink_color);
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

    public void PDFSetPolygon(int code) {
        if (code == 0)//start
        {
            m_status = STA_POLYGON;
            m_polygon = new Path();
        } else if (code == 1)//end
        {
            m_status = STA_NONE;
            if (m_annot_page != null) {
                Page page = m_doc.GetPage(m_annot_page.GetPageNo());
                if (page != null && m_polygon.GetNodeCount() > 2) {
                    page.ObjsStart();
                    Matrix mat = m_annot_page.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                    mat.TransformPath(m_polygon);
                    page.AddAnnotPolygon(m_polygon, Global.g_line_annot_color, Global.g_line_annot_fill_color, m_annot_page.ToPDFSize(Global.g_line_annot_width));
                    mat.Destroy();
                    int aidx = page.GetAnnotCount() - 1;
                    onAnnotCreated(page.GetAnnot(aidx));
                    //add to redo/undo stack.
                    m_opstack.push(new OPAdd(m_annot_page.GetPageNo(), page, aidx));
                    m_layout.vRenderSync(m_annot_page);
                    page.Close();
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                }
            }
            if (m_polygon != null) m_polygon.Destroy();
            m_polygon = null;
            m_annot_page = null;
            invalidate();
        } else//cancel
        {
            m_status = STA_NONE;
            m_polygon.Destroy();
            m_polygon = null;
            m_annot_page = null;
            invalidate();
        }
    }
    public void PDFSetPolyline(int code) {
        if (code == 0)//start
        {
            m_status = STA_POLYLINE;
            m_polygon = new Path();
        } else if (code == 1)//end
        {
            m_status = STA_NONE;
            if (m_annot_page != null) {
                Page page = m_doc.GetPage(m_annot_page.GetPageNo());
                if (page != null && m_polygon.GetNodeCount() > 1) {
                    page.ObjsStart();
                    Matrix mat = m_annot_page.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
                    mat.TransformPath(m_polygon);
                    page.AddAnnotPolyline(m_polygon, 0, 0, Global.g_line_annot_color, Global.g_line_annot_fill_color, m_annot_page.ToPDFSize(Global.g_line_annot_width));
                    mat.Destroy();
                    int aidx = page.GetAnnotCount() - 1;
                    onAnnotCreated(page.GetAnnot(aidx));
                    //add to redo/undo stack.
                    m_opstack.push(new OPAdd(m_annot_page.GetPageNo(), page, aidx));
                    m_layout.vRenderSync(m_annot_page);
                    page.Close();
                    if (m_listener != null)
                        m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                }
            }
            if (m_polygon != null) m_polygon.Destroy();
            m_polygon = null;
            m_annot_page = null;
            invalidate();
        } else//cancel
        {
            m_status = STA_NONE;
            m_polygon.Destroy();
            m_polygon = null;
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
                        float[] rect = new float[4];
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
                        page.AddAnnotRect(rect, vpage.ToPDFSize(Global.g_rect_annot_width), Global.g_rect_annot_color, Global.g_rect_annot_fill_color);
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
                        float[] rect = new float[4];
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
                        page.AddAnnotEllipse(rect, vpage.ToPDFSize(Global.g_oval_annot_width), Global.g_oval_annot_color, Global.g_oval_annot_fill_color);
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
            if (Global.g_use_sel_icons) {
                m_sel_icon1.recycle();
                m_sel_icon2.recycle();
                m_sel_icon1 = null;
                m_sel_icon2 = null;
            }
            m_annot_page = null;
            m_status = STA_NONE;
            invalidate();
        } else {
            if (Global.g_use_sel_icons) {
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
                        page.AddAnnotLine(pt1, pt2, Global.g_line_annot_style1, Global.g_line_annot_style2, vpage.ToPDFSize(Global.g_line_annot_width), Global.g_line_annot_color, Global.g_line_annot_fill_color);
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
            m_icon = BitmapFactory.decodeResource(this.getResources(), R.drawable.ic_custom_stamp);
            if (m_icon != null) {
                m_dicon = m_doc.NewImage(m_icon, 0);
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
                        float[] rect = new float[4];
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

    public void PDFSetEditbox(int code)
    {
        if (code == 0)//start
        {
            m_status = STA_EDITBOX;
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
                        float[] rect = new float[4];
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
                        if(rect[2] - rect[0] < 80) rect[2] = rect[0] + 80;
                        if(rect[3] - rect[1] < 16) rect[1] = rect[3] - 16;
                        boolean bret = page.AddAnnotEditbox(rect, 0xFFFF0000, vpage.ToPDFSize(3), 0, 12, 0xFFFF0000);
                        mat.Destroy();
                        //add to redo/undo stack.
                        if (!bret)
                            Toast.makeText(getContext(), "Free Text Annotation(Editbox) available only with premium license.", Toast.LENGTH_LONG).show();
                        else
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

    public void PDFCancelAnnot() {
        if (m_status == STA_NOTE) PDFSetNote(2);
        if (m_status == STA_RECT) PDFSetRect(2);
        if (m_status == STA_INK) PDFSetInk(2);
        if (m_status == STA_LINE) PDFSetLine(2);
        if (m_status == STA_STAMP) PDFSetStamp(2);
        if (m_status == STA_ELLIPSE) PDFSetEllipse(2);
        if (m_status == STA_EDITBOX) PDFSetEditbox(2);
        if (m_status == STA_POLYGON) PDFSetPolygon(2);
        if (m_status == STA_POLYLINE) PDFSetPolyline(2);
        if (m_status == STA_ANNOT) PDFEndAnnot();
        invalidate();
    }

    public void PDFRemoveAnnot() {
        if (m_status != STA_ANNOT) return;
        if(!PDFCanSave() || (Global.g_annot_readonly && m_annot.IsReadOnly())
                || (Global.g_annot_lock && m_annot.IsLocked())) {
            Toast.makeText(getContext(), R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
            PDFEndAnnot();
            return;
        }
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
        if (m_aMenu != null) m_aMenu.hide();
        if (m_annot_pg != null) {
            m_annot_pg.Close();
            m_annot_pg = null;
        }
        m_annot_page = null;
        m_annot_pos = null;
        m_annot = null;
        invalidate();
        m_status = STA_NONE;
        try {
            if (m_pEdit != null && m_pEdit.isShowing()) m_pEdit.dismiss();
            if (m_pCombo != null && m_pCombo.isShowing()) m_pCombo.dismiss();
        } catch (Exception ignored) {  }
        if (m_listener != null)
            m_listener.OnPDFAnnotTapped(-1, null);
    }

    public void onEditPopup() {
        if (m_status != STA_ANNOT) return;
        if(!PDFCanSave()) {
            Toast.makeText(getContext(), R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
            PDFEndAnnot();
            return;
        }
        new UIAnnotDlgPopup(getContext()).show(m_annot, new UIAnnotMenu.IMemnuCallback() {
            @Override
            public void onUpdate() {
                if (m_listener != null)
                    m_listener.OnPDFPageModified(m_annot_page.GetPageNo());
                PDFEndAnnot();
            }
            @Override
            public void onRemove() {
            }
            @Override
            public void onPerform() {
            }
            @Override
            public void onCancel() {
                PDFEndAnnot();
            }
        });
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
        if (Global.g_exec_js)
            executeAnnotJS();
        if (m_listener != null && js != null)
            m_listener.OnPDFOpenJS(js);
        String uri = m_annot.GetURI();
        if (m_listener != null && uri != null)
            m_listener.OnPDFOpenURI(uri);
        int index;
        String mov = m_annot.GetMovie();
        if (mov != null) {
            index = mov.lastIndexOf('\\');
            if (index < 0) index = mov.lastIndexOf('/');
            if (index < 0) index = mov.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + mov.substring(index + 1);
            m_annot.GetMovieData(save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenMovie(save_file);
        }
        String snd = m_annot.GetSound();
        if (snd != null) {
            int[] paras = new int[4];
            index = snd.lastIndexOf('\\');
            if (index < 0) index = snd.lastIndexOf('/');
            if (index < 0) index = snd.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + snd.substring(index + 1);
            m_annot.GetSoundData(paras, save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenSound(paras, save_file);
        }
        String att = m_annot.GetAttachment();
        if (att != null) {
            index = att.lastIndexOf('\\');
            if (index < 0) index = att.lastIndexOf('/');
            if (index < 0) index = att.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + att.substring(index + 1);
            m_annot.GetAttachmentData(save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenAttachment(save_file);
        }
        String rend = m_annot.GetRendition();
        if (rend != null) {
            index = rend.lastIndexOf('\\');
            if (index < 0) index = rend.lastIndexOf('/');
            if (index < 0) index = rend.lastIndexOf(':');
            String save_file = Global.tmp_path + "/" + rend.substring(index + 1);
            m_annot.GetRenditionData(save_file);
            if (m_listener != null)
                m_listener.OnPDFOpenRendition(save_file);
        }
        String f3d = m_annot.Get3D();
        if (f3d != null) {
            index = f3d.lastIndexOf('\\');
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
            PDFPos pos = new PDFPos();
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

    @Override
    public boolean PDFSave() {
        return m_doc.Save();
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

    public void PDFUpdatePage(int pageno)
    {
        if (m_layout != null)
            m_layout.vRenderSync(m_layout.vGetPage(pageno));
    }

    public void setReadOnly(boolean readonly) {
        mReadOnly = readonly;
    }

    public void PDFSetZoom(int vx, int vy, PDFPos pos, float zoom) {
        if(m_layout != null) m_layout.vZoomSet(vx, vy, pos, zoom);
    }

    public float PDFGetZoom() {
        return m_layout != null ? m_layout.vGetZoom() : 0;
    }

    public float[] toPDFRect(float[] viewRect) {
        if(m_layout != null) {
            VPage vpage = m_layout.vGetPage(m_pageno);
            Matrix mat = vpage.CreateInvertMatrix(m_layout.vGetX(), m_layout.vGetY());
            mat.TransformRect(viewRect);
        }
        return viewRect;
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
    @Override
    public int GetScreenX(float pdfX, int pageno) {
        VPage vPage = m_layout.vGetPage(pageno);
        return vPage.GetVX(pdfX) - m_layout.vGetX();
    }

    @Override
    public int GetScreenY(float pdfY, int pageno) {
        VPage vPage = m_layout.vGetPage(pageno);
        return vPage.GetVY(pdfY) - m_layout.vGetY();
    }
}