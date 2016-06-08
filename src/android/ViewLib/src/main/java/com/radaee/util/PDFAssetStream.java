package com.radaee.util;

import android.content.res.AssetManager;
import android.util.Log;
import com.radaee.pdf.Document.PDFStream;
import java.io.InputStream;
import java.lang.reflect.Array;

/**
 * Asset stream, an implement class for PDFStream, which used in Document.OpenStream
 * @author radaee
 */
public class PDFAssetStream implements PDFStream
{
	private byte[] m_buf;
	private int m_pos;
	private int m_len;
	public boolean open( AssetManager assets, String symbol )
	{
		try
		{
			InputStream stream = assets.open(symbol);
			m_len = (int)stream.skip(0x7FFFFFFF);
			m_pos = 0;
			stream.reset();
			m_buf = new byte[m_len];
			stream.read(m_buf);
			stream.close();
			return true;
		}
		catch( Exception e )
		{
			return false;
		}
	}
	public void close()
	{
		m_buf = null;
	}
	public boolean writeable()
	{
		return false;
	}
	public int get_size()
	{
		return m_len;
	}

	public int read(byte[] data)
	{
		int len = data.length;
		if(len + m_pos > m_len) len = m_len - m_pos;
		if(len <= 0) return 0;
		System.arraycopy(m_buf, m_pos, data, 0, len);
				m_pos += len;
				return len;
			}

	public int write(byte[] data)
	{
		return 0;
	}

	public void seek(int pos)
	{
		m_pos = pos;
		if(m_pos < 0) m_pos = 0;
		if(m_pos > m_len) m_pos = m_len;
	}

	public int tell()
	{
	    return m_pos;
	}
    @Override
    protected void finalize() throws Throwable
    {
        close();
        super.finalize();
    }
}
