package com.radaee.util;

import android.content.Context;

import com.radaee.pdf.BMDatabase;

import java.io.File;

public class RDRecent
{
    private BMDatabase m_db;
    private long m_rec_set;
    private File m_file;
    public RDRecent(Context ctx)
    {
        File file = ctx.getExternalFilesDir(null);
        m_file = new File(file.getAbsoluteFile() + "/recent.db");
        m_db = new BMDatabase();
        m_db.OpenOrCreate(m_file.getAbsolutePath());
        m_rec_set = m_db.RecOpen("recent");
        if (m_file.length() > (1<<16))
        {
            int cnt = m_db.RecGetCount(m_rec_set);
            String[] svals = new String[cnt];
            int[] ivals = new int[cnt];
            for (int cur = 0; cur < cnt; cur++)
            {
                svals[cur] = m_db.RecItemGetName(m_rec_set, cur);
                ivals[cur] = m_db.RecItemGetPage(m_rec_set, cur);
            }
            m_db.RecClose(m_rec_set);
            m_db.Close();
            m_file.delete();

            m_db.OpenOrCreate(m_file.getAbsolutePath());
            m_rec_set = m_db.RecOpen("recent");
            for (int cur = 0; cur < cnt; cur++)
                m_db.RecItemInsert(m_rec_set, svals[cur], ivals[cur]);
        }
    }
    public int GetCount()
    {
        return m_db.RecGetCount(m_rec_set);
    }
    public void Close()
    {
        if (m_db == null) return;
        m_db.RecClose(m_rec_set);
        m_db.Close();
        m_rec_set = 0;
        m_db = null;
    }
    public void insert(String path, int pageno, int vtype)
    {
        int val = (vtype << 28) | pageno;
        int cnt = m_db.RecGetCount(m_rec_set);
        for (int cur = 0; cur < cnt; cur++)
        {
            String spath = m_db.RecItemGetName(m_rec_set, cur);
            if(spath.compareTo(path) == 0)//exists in list.
            {
                m_db.RecItemRemove(m_rec_set, cur);
                m_db.RecItemInsert(m_rec_set, path, val);
                return;//just swap position.
            }
        }
        if (cnt > 15) m_db.RecItemRemove(m_rec_set, 0);//only keep 16 recent open record.
        m_db.RecItemInsert(m_rec_set, path, val);
    }
    public void remove(String path)
    {
        int cnt = m_db.RecGetCount(m_rec_set);
        for (int cur = 0; cur < cnt; cur++)
        {
            String spath = m_db.RecItemGetName(m_rec_set, cur);
            if(spath.compareTo(path) == 0)//exists in list.
            {
                m_db.RecItemRemove(m_rec_set, cur);
                return;//just swap position.
            }
        }
    }
    public void remove(int idx)
    {
        m_db.RecItemRemove(m_rec_set, idx);
    }
    public String get_path(int idx)
    {
        return m_db.RecItemGetName(m_rec_set, idx);
    }
    public int get_page(int idx)
    {
        return (m_db.RecItemGetPage(m_rec_set, idx) & ((1<<28) - 1));
    }
    public int get_vtype(int idx)
    {
        return (m_db.RecItemGetPage(m_rec_set, idx) >> 28);
    }
    public void clear()
    {
        m_db.RecClose(m_rec_set);
        m_db.Close();
        m_file.delete();
        m_db.OpenOrCreate(m_file.getAbsolutePath());
        m_rec_set = m_db.RecOpen("recent");
    }
}
