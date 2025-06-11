package com.radaee.pdf;

import android.os.SystemClock;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.nio.ShortBuffer;

import javax.microedition.khronos.opengles.GL10;

public class DIB
{
	/**
	 * create or resize dib, and reset all pixels in dib.<br/>
	 * if dib is 0, function create a new dib object.<br/>
	 * otherwise function resize the dib object.
	 */
	private static native long get(long dib, int width, int height);
	/**
	 * draw a dib to another dib
	 * @param dib
	 * @param dst_dib
	 * @param x
	 * @param y
	 */
	private static native void drawToDIB( long dib, long dst_dib, int x, int y );
	/**
	 * draw dib to bmp.
	 *
	 * @param bmp
	 *            handle value, that returned by lockBitmap.
	 * @param dib
	 * @param x
	 *            origin position in bmp.
	 * @param y
	 *            origin position in bmp.
	 */
	private static native void drawToBmp(long dib, long bmp, int x, int y);
	/**
	 * draw dib to bmp, with scale
	 * @param bmp
	 * @param dib
	 * @param x
	 * @param y
	 * @param w
	 * @param h
	 */
	private static native void drawToBmp2(long dib, long bmp, int x, int y, int w, int h);
	private static native void drawRect(long dib, int color, int x, int y, int width, int height, int mode);
	private static native int glGenTexture(long dib, boolean linear);
	private static native boolean saveRaw( long bmp, String path );
	private static native long restoreRaw( long bmp, String path, int[] info );
	private static native void makeGray(long hand);
	/**
	 * free dib object.
	 */
	private static native int free(long dib);
	protected long hand = 0;
	private int m_w,m_h;
	public final boolean IsEmpty(){return hand == 0;}
	public final void CreateOrResize(int w, int h)
	{
		hand = get(hand, w, h);
		m_w = w;
		m_h = h;
	}
	public final void DrawToDIB(DIB dst, int x, int y)
	{
		if(dst == null) return;
		drawToDIB(hand, dst.hand, x, y);
	}
	public final void DrawToBmp(BMP bmp, int x, int y)
	{
		if(bmp == null) return;
		drawToBmp(hand, bmp.hand, x, y);
	}

	/**
	 * make DIB to gray.<br/>
	 * it not change pixel format, after this call invoked, pixels still are 32 bits.<br/>
	 * but pixels value changed to gray.
	 */
	public final void MakeGray()
	{
		makeGray(hand);
	}
	/**
	 * draw dib to bmp, with scale
	 * @param bmp
	 * @param x
	 * @param y
	 * @param w
	 * @param h
	 */
	public final void DrawToBmp2(BMP bmp, int x, int y, int w, int h)
	{
		if(bmp == null) return;
		drawToBmp2(hand, bmp.hand, x, y, w, h);
	}
	public final void DrawRect(int color, int x, int y, int width, int height, int mode)
	{
		drawRect(hand, color, x, y, width, height, mode);
	}
	public int GLGenTexture()
	{
		return glGenTexture(hand, true);
	}
	public int GetWidth()
	{
		return m_w;
	}
	public int GetHeight()
	{
		return m_h;
	}
	public final void Free()
	{
		free(hand);
		hand = 0;
	}
	/**
	 * save pixels data to file. saved as RGBA_8888 format.
	 * @param path path-name to the file.
	 * @return true or false
	 */
	public final boolean SavePixs(String path)
	{
		return saveRaw(hand, path);
	}

	/**
	 * restore pixels data from file. must be RGBA_8888 format.
	 * @param path path-name to the file
	 * @return true or false. pixels format of pixels must match to DIB object, otherwise return false.
	 */
	public final boolean RestorePixs(String path)
	{
		int info[] = new int[2];
		long tmp = restoreRaw(hand, path, info);
		if(info[0] > 0 && info[1] > 0)
		{
			m_w = info[0];
			m_h = info[1];
			hand = tmp;
			return true;
		}
		else
			return false;
	}
	@Override
	protected void finalize() throws Throwable
	{
		Free();
		super.finalize();
	}
}