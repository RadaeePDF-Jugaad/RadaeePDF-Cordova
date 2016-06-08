package com.radaee.util;

import java.util.HashMap;
import java.util.Map;

public class RDLockerSet {
    private static class RDLocker {
        protected RDLocker()
        {
            m_ref_cnt = 1;
            unlock();
        }
        private int m_ref_cnt;
        private boolean is_notified = false;
        private boolean is_waitting = false;
        protected synchronized void lock() {
            m_ref_cnt++;
            try {
                if (is_notified) {
                    is_notified = false;
                } else {
                    is_waitting = true;
                    wait();
                    is_waitting = false;
                }
            } catch (Exception ignored) {
            }
        }

        protected synchronized void unlock() {
            if (is_waitting)
                notify();
            else {
                is_notified = true;
            }
            m_ref_cnt--;
        }
    }
    private final Map<String, RDLocker> m_set;
    public RDLockerSet()
    {
        m_set = new HashMap<String, RDLocker>();
    }
    public Object Lock(String key)
    {
        RDLocker obj;
        synchronized (m_set) {
            obj = m_set.get(key);
            if (obj == null) {
                obj = new RDLocker();
                m_set.put(key, obj);
            }
        }
        obj.lock();
        return obj;
    }
    public void Unlock(String key, Object locker)
    {
        RDLocker obj = (RDLocker)locker;
        obj.unlock();
        synchronized (m_set) {
            if (obj.m_ref_cnt <= 0)
                m_set.remove(key);
        }
    }
}
