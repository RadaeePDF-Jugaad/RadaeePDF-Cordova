package com.radaee.view;

import android.graphics.Canvas;
import android.os.Bundle;

import com.radaee.pdf.Document;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;

public interface ILayoutView {
    interface PDFLayoutListener
    {
        /**
         * call when page changed.
         * @param pageno
         */
        void OnPDFPageModified(int pageno);

        /**
         * call when page scrolling.
         * @param pageno
         */
        void OnPDFPageChanged(int pageno);

        /**
         * call when annotation tapped.
         * @param pno
         * @param annot
         */
        void OnPDFAnnotTapped(int pno, Page.Annotation annot);

        /**
         * call when blank tapped on page, this mean not annotation tapped.
         */
        void OnPDFBlankTapped();

        /**
         * call select status end.
         * @param text selected text string
         */
        void OnPDFSelectEnd(String text);

        void OnPDFOpenURI(String uri);
        void OnPDFOpenJS(String js);
        void OnPDFOpenMovie(String path);
        void OnPDFOpenSound(int[] paras, String path);
        void OnPDFOpenAttachment(String path);
        void OnPDFOpen3D(String path);

        /**
         * call when zoom start.
         */
        void OnPDFZoomStart();

        /**
         * call when zoom end
         */
        void OnPDFZoomEnd();
        boolean OnPDFDoubleTapped(float x, float y);
        void OnPDFLongPressed(float x, float y);

        /**
         * call when search finished. each search shall call back each time.
         * @param found
         */
        void OnPDFSearchFinished(boolean found);

        /**
         * call when page displayed on screen.
         * @param canvas
         * @param vpage
         */
        void OnPDFPageDisplayed(Canvas canvas, IVPage vpage);
        /**
         * call when page is rendered by backing thread.
         * @param vpage
         */
        void OnPDFPageRendered(IVPage vpage);
    }
    interface IVPage
    {
        public int GetPageNo();
        public int GetVX(float pdfx);
        public int GetVY(float pdfy);
        public float ToPDFX( float x, float scrollx );
        public float ToPDFY( float y, float scrolly );
        public float ToDIBX( float x );
        public float ToDIBY( float y );
        public float ToPDFSize( float val );
        public Matrix CreateInvertMatrix(float scrollx, float scrolly );
    }
    /**
     * attach PDF document object to reader. and initialize reader
     * @param doc PDF Document object
     * @param listener callback listener.
     */
    void PDFOpen(Document doc, PDFLayoutListener listener);

    /**
     * close reader.
     */
    void PDFClose();
    /**
     * set view mode, it sam as Global.def_mode.
     * @param vmode view mode
     * 0:vertical<br/>
     * 1:horizon<br/>
     * 2:curl effect(opengl only)<br/>
     * 3:single<br/>
     * 4:SingleEx<br/>
     * 5:Reflow(opengl only)<br/>
     * 6:show 2 page as 1 page in land scape mode
     */
    void PDFSetView(int vmode);

    /**
     * set Ink status.
     * @param code <br/>
     * 0: set to Ink status<br/>
     * 1: end and confirm Ink status<br/>
     * 2: cancel Ink status
     */
    void PDFSetInk(int code);

    /**
     * set Rect status.
     * @param code <br/>
     * 0: set to Rect status<br/>
     * 1: end and confirm Rect status<br/>
     * 2: cancel Rect status
     */
    void PDFSetRect(int code);

    /**
     * set Ellipse status.
     * @param code <br/>
     * 0: set to Ellipse status<br/>
     * 1: end and confirm Ellipse status<br/>
     * 2: cancel Ellipse status
     */
    void PDFSetEllipse(int code);

    /**
     * set select status or end status.<br/>
     * if current status is select status, set status to none.<br/>
     * if current status is none status, set status to select.
     */
    void PDFSetSelect();

    /**
     * set Note status.
     * @param code <br/>
     * 0: set to Note status<br/>
     * 1: end and confirm Note status<br/>
     * 2: cancel Note status
     */
    void PDFSetNote(int code);
    /**
     * set Line status.
     * @param code <br/>
     * 0: set to Line status<br/>
     * 1: end and confirm Line status<br/>
     * 2: cancel Line status
     */
    void PDFSetLine(int code);
    /**
     * set Stamp status.
     * @param code <br/>
     * 0: set to Stamp status<br/>
     * 1: end and confirm Stamp status<br/>
     * 2: cancel Stamp status
     */
    void PDFSetStamp(int code);

    /**
     * set editbox status.
     * @param code <br/>
     * 0: set to Editbox status<br/>
     * 1: end and confirm Editbox status<br/>
     * 2: cancel Editbox status
     */
    void PDFSetEditbox(int code);
    boolean PDFSetAttachment(String attachmentPath);
    void PDFCancelAnnot();
    void PDFRemoveAnnot();
    void PDFEndAnnot();
    void PDFEditAnnot();
    void PDFPerformAnnot();
    void PDFFindStart(String key, boolean match_case, boolean whole_word);
    void PDFFind(int dir);
    void PDFFindEnd();

    boolean PDFSetSelMarkup(int type);
    Document PDFGetDoc();
    void BundleSavePos(Bundle bundle);
    void BundleRestorePos(Bundle bundle);
    void PDFGotoPage(int pageno);
    void PDFScrolltoPage(int pageno);
    void PDFUndo();
    void PDFRedo();
    boolean PDFCanSave();
    boolean PDFSave();
    void PDFUpdateCurrPage();
    int PDFGetCurrPage();
    void PDFAddAnnotRect(float x, float y, float width, float height, int p);


    int GetScreenX(float pdfX, int pageno);
    int GetScreenY(float pdfY, int pageno);

}
