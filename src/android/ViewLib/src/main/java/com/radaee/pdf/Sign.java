package com.radaee.pdf;

/**
 * Created by lyz on 2017/6/3.
 */

public class Sign {
    protected long m_hand;
    private static native String getIssue(long sign);
    private static native String getSubject(long sign);
    private static native long getVersion(long sign);
    public String GetIssue()
    {
        return getIssue(m_hand);
    }
    public String GetSubject()
    {
        return getSubject(m_hand);
    }
    public long GetVersion()
    {
        return getVersion(m_hand);
    }
}
