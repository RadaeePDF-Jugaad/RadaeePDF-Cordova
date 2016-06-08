package com.radaee.reader;

import com.radaee.pdf.Document;
import com.radaee.pdf.Page;

import java.util.Vector;

/**
 * Created by radaee on 2016/1/29.
 */

abstract class OPItem
{
    OPItem(int pgno, int idx)
    {
        m_pageno = pgno;
        m_idx = idx;
    }
    int m_pageno;
    int m_idx;
    abstract void op_undo(Document doc);
    abstract void op_redo(Document doc);
    int get_pgno(int idx) {return m_pageno;}
}

class OPDel extends OPItem
{
    long hand;
    OPDel(int pgno, Page page, int idx)
    {
        super(pgno, idx);
        hand = page.GetAnnot(idx).GetRef();
    }
    @Override
    void op_undo(Document doc) {
        Page page = doc.GetPage(m_pageno);
        page.ObjsStart();
        page.AddAnnot(hand, m_idx);
        page.Close();
    }

    @Override
    void op_redo(Document doc) {
        Page page = doc.GetPage(m_pageno);
        page.ObjsStart();
        Page.Annotation annot = page.GetAnnot(m_idx);
        annot.RemoveFromPage();
        page.Close();
    }
}

class OPAdd extends OPItem
{
    long hand;
    OPAdd(int pgno, Page page, int idx)
    {
        super(pgno, idx);
        hand = page.GetAnnot(idx).GetRef();
    }
    @Override
    void op_undo(Document doc) {
        Page page = doc.GetPage(m_pageno);
        page.ObjsStart();
        Page.Annotation annot = page.GetAnnot(m_idx);
        annot.RemoveFromPage();
        page.Close();
    }

    @Override
    void op_redo(Document doc) {
        Page page = doc.GetPage(m_pageno);
        page.ObjsStart();
        page.AddAnnot(hand, m_idx);
        page.Close();
    }
}

class OPMove extends OPItem
{
    int m_pageno0;
    int m_pageno1;
    float[] m_rect0 = new float[4];
    float[] m_rect1 = new float[4];
    OPMove(int src_pageno, float[] src_rect, int dst_pageno, int dst_idx, float[] dst_rect)
    {
        super(-1, dst_idx);
        m_pageno0 = src_pageno;
        m_rect0[0] = src_rect[0];
        m_rect0[1] = src_rect[1];
        m_rect0[2] = src_rect[2];
        m_rect0[3] = src_rect[3];

        m_pageno1 = dst_pageno;
        m_rect1[0] = dst_rect[0];
        m_rect1[1] = dst_rect[1];
        m_rect1[2] = dst_rect[2];
        m_rect1[3] = dst_rect[3];
    }
    @Override
    void op_undo(Document doc)
    {
        m_pageno = m_pageno0;
        if(m_pageno == m_pageno1)
        {
            Page page = doc.GetPage(m_pageno);
            page.ObjsStart();
            Page.Annotation annot = page.GetAnnot(m_idx);
            annot.SetRect(m_rect0[0], m_rect0[1], m_rect0[2], m_rect0[3]);
            page.Close();
        }
        else
        {
            Page page0 = doc.GetPage(m_pageno0);
            Page page1 = doc.GetPage(m_pageno1);
            page1.ObjsStart();
            page0.ObjsStart();
            Page.Annotation annot = page1.GetAnnot(m_idx);
            annot.MoveToPage(page0, m_rect0);
            m_idx = page1.GetAnnotCount();
            page0.Close();
            page1.Close();
        }
    }

    @Override
    void op_redo(Document doc)
    {
        m_pageno = m_pageno1;
        if(m_pageno == m_pageno0)
        {
            Page page = doc.GetPage(m_pageno);
            page.ObjsStart();
            Page.Annotation annot = page.GetAnnot(m_idx);
            annot.SetRect(m_rect1[0], m_rect1[1], m_rect1[2], m_rect1[3]);
            page.Close();
        }
        else
        {
            Page page0 = doc.GetPage(m_pageno0);
            Page page1 = doc.GetPage(m_pageno1);
            page1.ObjsStart();
            page0.ObjsStart();
            Page.Annotation annot = page0.GetAnnot(page0.GetAnnotCount() - 1);
            annot.MoveToPage(page1, m_rect1);
            page0.Close();
            page1.Close();
        }
    }
    int get_pgno(int idx)
    {
        if(idx == 0)
            return m_pageno0;
        else
            return m_pageno1;
    }
}

public class PDFLayoutOPStack
{
    private final Vector<OPItem> m_stack = new Vector<OPItem>();
    private int m_pos = -1;
    public void push(OPItem op)
    {
        m_pos++;
        m_stack.setSize(m_pos);
        m_stack.add(m_pos, op);
    }
    public OPItem undo()
    {
        if(m_pos < 0) return null;
        OPItem ret = m_stack.get(m_pos);
        m_pos--;
        return ret;
    }
    public OPItem redo()
    {
        if(m_pos > m_stack.size() - 2) return null;
        m_pos++;
        return m_stack.get(m_pos);
    }
    public boolean can_undo()
    {
        return (m_pos >= 0);
    }
    public boolean can_redo()
    {
        return m_pos < m_stack.size() - 1;
    }
}
