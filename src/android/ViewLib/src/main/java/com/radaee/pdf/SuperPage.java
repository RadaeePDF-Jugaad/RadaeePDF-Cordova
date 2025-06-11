package com.radaee.pdf;

public class SuperPage extends Page
{
    private SuperDoc.DocInfo m_dinfo;
    public SuperPage(Page page, SuperDoc.DocInfo dinfo)
    {
        hand = page.hand;
        m_doc = page.m_doc;
        m_dinfo = dinfo;
        page.hand = 0;
        page.m_doc = null;
    }
    @Override
    public void Close()
    {
        super.Close();
        if(m_dinfo == null) return;
        m_dinfo.DecRef();
        m_dinfo = null;
    }
}
