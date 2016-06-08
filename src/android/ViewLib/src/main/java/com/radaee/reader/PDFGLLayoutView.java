package com.radaee.reader;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import com.radaee.annotui.UIAnnotMenu;
import com.radaee.pdf.Document;
import com.radaee.view.GLLayout;
import com.radaee.view.ILayoutView;

public class PDFGLLayoutView extends RelativeLayout implements ILayoutView {
    public PDFGLLayoutView(Context context) {
        super(context);
        init(context);
    }

    public PDFGLLayoutView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private GLView m_view;
    private GLCanvas m_canvas;
    private UIAnnotMenu m_annot_menu;

    private void init(Context context) {
        m_view = new GLView(context);
        m_canvas = new GLCanvas(context);
        addView(m_view, 0);
        addView(m_canvas, 1);
        m_annot_menu = new UIAnnotMenu(this);
    }

    public void PDFOpen(Document doc, ILayoutView.PDFLayoutListener listener) {
        m_view.PDFOpen(doc, listener, m_canvas, 4);
        m_view.setAnnotMenu(m_annot_menu);
        m_canvas.vOpen(m_view);
    }

    public void PDFSetView(int vmode) {
        m_view.PDFSetView(vmode);
    }
    public int PDFGetView() { return m_view.PDFGetView(); }

    public void PDFCloseOnUI() {
        m_view.PDFCloseOnUI();
    }
    public void PDFClose() {
        m_view.PDFClose();
    }

    public void PDFSetInk(int code) {
        m_view.PDFSetInk(code);
    }

    public void PDFSetPolygon(int code) {
        m_view.PDFSetPolygon(code);
    }

    public void PDFSetPolyline(int code) {
        m_view.PDFSetPolyline(code);
    }

    public void PDFSetRect(int code) {
        m_view.PDFSetRect(code);
    }

    public void PDFSetEllipse(int code) {
        m_view.PDFSetEllipse(code);
    }

    public void PDFSetSelect() {
        m_view.PDFSetSelect();
    }

    public void PDFSetNote(int code) {
        m_view.PDFSetNote(code);
    }

    public void PDFSetLine(int code) {
        m_view.PDFSetLine(code);
    }

    public void PDFSetStamp(int code) {
        m_view.PDFSetStamp(code);
    }

    public void PDFSetEditbox(int code)
    {
        m_view.PDFSetEditbox(code);
    }
    @Override
    public boolean PDFSetAttachment(String attachmentPath) { //TODO
        return false;
    }

    public void PDFCancelAnnot() {
        m_view.PDFCancelAnnot();
    }

    public void PDFRemoveAnnot() {
        m_view.PDFRemoveAnnot();
    }

    public void PDFEndAnnot() {
        m_view.PDFEndAnnot();
    }

    public void PDFEditAnnot() {
        m_view.PDFEditAnnot();
    }

    public void PDFPerformAnnot() {
        m_view.PDFPerformAnnot();
    }

    public final void PDFFindStart(String key, boolean match_case, boolean whole_word) {
        m_view.PDFFindStart(key, match_case, whole_word);
    }

    public final void PDFFind(int dir) {
        m_view.PDFFind(dir);
    }

    @Override
    public void PDFFindEnd() {
        m_view.PDFFindEnd();
    }

    public boolean PDFSetSelMarkup(int type) {
        return m_view.PDFSetSelMarkup(type);
    }

    public Document PDFGetDoc() {
        return m_view.PDFGetDoc();
    }

    public void BundleSavePos(Bundle bundle) {
        m_view.BundleSavePos(bundle);
    }

    public void BundleRestorePos(Bundle bundle) {
        m_view.BundleRestorePos(bundle);
    }

    public void PDFGotoPage(int pageno) {
        m_view.PDFGotoPage(pageno);
    }
    public void PDFScrolltoPage(int pageno) {
        m_view.PDFScrolltoPage(pageno);
    }

    public void PDFUndo() {
        m_view.PDFUndo();
    }

    public void PDFRedo() {
        m_view.PDFRedo();
    }

    public boolean PDFCanSave() {
        return m_view.PDFCanSave();
    }

    @Override
    public boolean PDFSave() {
        return m_view.PDFSave();
    }

    public void PDFUpdatePage(int pageno)
    {
        m_view.PDFUpdatePage(pageno);
    }

    public void PDFSetBGColor(int color) {
        m_view.PDFSetBGColor(color);
    }

    /*
    @Override
    public void PDFAddAnnotRect(float x, float y, float width, float height, int p)
    {
        m_view.PDFAddAnnotRect(x, y, width, height, p);
    }
    */
    @Override
    public int GetScreenX(float pdfX, int pageno) {
        return 0;
    }

    @Override
    public int GetScreenY(float pdfY, int pageno) {
        return 0;
    }

    public float[] toPDFRect(float[] viewRect) {
        return m_view.toPDFRect(viewRect);
    }

    public void setReadOnly(boolean readonly) {
        m_view.setReadOnly(readonly);
    }

    public void PDFSaveView()
    {
        m_view.PDFSaveView();
    }
    public void PDFRestoreView()
    {
        m_view.PDFRestoreView();
    }
    public final GLLayout.PDFPos PDFGetPos(int x, int y) {
        if (m_view != null)
            return m_view.PDFGetPos(x, y);
        else return null;
    }
    public void onPause()
    {
        m_view.onPause();
    }
    public void onResume()
    {
        m_view.onResume();
    }
}