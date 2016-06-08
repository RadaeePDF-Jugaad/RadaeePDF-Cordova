package com.radaee.pdf;

/**
 * Created by lyz on 2017/6/3.
 */

public class Sign {
    protected long m_hand;
    private static native String getIssue(long sign);
    private static native String getSubject(long sign);
    private static native long getVersion(long sign);

    private static native String getName(long sign);
    private static native String getLocation(long sign);
    private static native String getReason(long sign);
    private static native String getContact(long sign);
    private static native String getModDT(long sign);

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

    /**
     * get signer name.
     * @return name string.
     */
    public String GetName()
    {
        return getName(m_hand);
    }
    /**
     * sign location.
     * @return location description.
     */
    public String GetLocation()
    {
        return getLocation(m_hand);
    }

    /**
     * sign reason
     * @return reason string
     */
    public String GetReason()
    {
        return getReason(m_hand);
    }

    /**
     * sign contact string
     * @return contact address or phone.
     */
    public String GetContact()
    {
        return getContact(m_hand);
    }

    /**
     * sign date time
     * @return date time.
     */
    public String GetModDateTime()
    {
        return getModDT(m_hand);
    }
}