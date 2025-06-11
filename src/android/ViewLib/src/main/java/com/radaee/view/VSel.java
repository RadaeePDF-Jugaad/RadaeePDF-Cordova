package com.radaee.view;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;

import com.radaee.pdf.Global;
import com.radaee.pdf.Page;

public class VSel
{
	protected Page m_page;
	protected int m_index1;
	protected int m_index2;
	protected boolean m_ok = false;
	protected boolean m_swiped = false;
	Paint m_paint = new Paint();
	public VSel( Page page )
	{
		m_page = page;
		m_index1 = -1;
		m_index2 = -1;
		m_paint.setStyle(Style.FILL);
	}
	public void Clear()
	{
		if( m_page != null )
		{
			m_page.Close();
			m_page = null;
		}
	}
	public int[] GetRect1(float scale, float page_height, int orgx, int orgy)
	{
		if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return null;
		float[] rect = new float[4];
		if( m_swiped )
			m_page.ObjsGetCharRect(m_index2, rect);
		else
			m_page.ObjsGetCharRect(m_index1, rect);
		int[] rect_draw = new int[4];
		rect_draw[0] = (int)(rect[0] * scale) + orgx;
		rect_draw[1] = (int)((page_height - rect[3]) * scale) + orgy;
		rect_draw[2] = (int)(rect[2] * scale) + orgx;
		rect_draw[3] = (int)((page_height - rect[1]) * scale) + orgy;
		return rect_draw;
	}
	public int[] GetRect2(float scale, float page_height, int orgx, int orgy)
	{
		if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return null;
		float[] rect = new float[4];
		if( m_swiped )
			m_page.ObjsGetCharRect(m_index1, rect);
		else
			m_page.ObjsGetCharRect(m_index2, rect);
		int[] rect_draw = new int[4];
		rect_draw[0] = (int)(rect[0] * scale) + orgx;
		rect_draw[1] = (int)((page_height - rect[3]) * scale) + orgy;
		rect_draw[2] = (int)(rect[2] * scale) + orgx;
		rect_draw[3] = (int)((page_height - rect[1]) * scale) + orgy;
		return rect_draw;
	}
	public void SetSel( float x1, float y1, float x2, float y2 )
	{
		if( !m_ok )
		{
			m_page.ObjsStart();
			m_ok = true;
		}
		float[] pt = new float[2];
		pt[0] = x1;
		pt[1] = y1;
		m_index1 = m_page.ObjsGetCharIndex(pt);
		pt[0] = x2;
		pt[1] = y2;
		m_index2 = m_page.ObjsGetCharIndex(pt);
		if( m_index1 > m_index2 )
		{
			int tmp = m_index1;
			m_index1 = m_index2;
			m_index2 = tmp;
			m_swiped = true;
		}
		else
			m_swiped = false;
		m_index1 = m_page.ObjsAlignWord(m_index1, -1);
		m_index2 = m_page.ObjsAlignWord(m_index2, 1);
	}
    public Page GetPage()
    {
        return m_page;
    }
	public boolean SetSelMarkup(int type)
	{
		if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return false;
		return m_page.AddAnnotMarkup(m_index1, m_index2, type);
	}
	public String GetSelString()
	{
		if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return null;
		return m_page.ObjsGetString(m_index1, m_index2 + 1);
	}
	public void DrawSel( Canvas canvas, float scale, float page_height, int orgx, int orgy )
	{
		if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return;
		float[] rect = new float[4];
		float[] rect_word = new float[4];
		float[] rect_draw = new float[4];
		m_paint.setColor(Global.g_sel_color);
		m_page.ObjsGetCharRect(m_index1, rect);
		rect_word[0] = rect[0];
		rect_word[1] = rect[1];
		rect_word[2] = rect[2];
		rect_word[3] = rect[3];
		int tmp = m_index1 + 1;
		while( tmp <= m_index2 )
		{
			m_page.ObjsGetCharRect(tmp, rect);
			float gap = (rect[3] - rect[1])/2;
			if( rect_word[1] == rect[1] && rect_word[3] == rect[3] &&
				rect_word[2] + gap > rect[0] && rect_word[0] - gap < rect[2] )
			{
				if( rect_word[0] > rect[0] ) rect_word[0] = rect[0];
				if( rect_word[2] < rect[2] ) rect_word[2] = rect[2];
			}
			else
			{
				rect_draw[0] = rect_word[0] * scale;
				rect_draw[1] = (page_height - rect_word[3]) * scale;
				rect_draw[2] = rect_word[2] * scale;
				rect_draw[3] = (page_height - rect_word[1]) * scale;
				canvas.drawRect((orgx + rect_draw[0]), (orgy + rect_draw[1]), (orgx + rect_draw[2]), (int)(orgy + rect_draw[3]), m_paint);
				rect_word[0] = rect[0];
				rect_word[1] = rect[1];
				rect_word[2] = rect[2];
				rect_word[3] = rect[3];
			}
			tmp++;
		}
		rect_draw[0] = rect_word[0] * scale;
		rect_draw[1] = (page_height - rect_word[3]) * scale;
		rect_draw[2] = rect_word[2] * scale;
		rect_draw[3] = (page_height - rect_word[1]) * scale;
		canvas.drawRect((orgx + rect_draw[0]), (orgy + rect_draw[1]), (orgx + rect_draw[2]), (int)(orgy + rect_draw[3]), m_paint);
	}
}
