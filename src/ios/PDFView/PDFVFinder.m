//
//  PDFVFinder.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVFinder.h"

@implementation PDFVFinder
-(id)init
{
    if( self = [super init] )
    {
		m_str = NULL;
		m_case = false;;
		m_whole = false;
		m_page_no = -1;
		m_page_find_index = -1;
		m_page_find_cnt = 0;
		m_page = NULL;
		m_doc = NULL;
		m_finder = NULL;
		m_dir = 0;
		is_cancel = true;
		is_notified = false;
		is_waitting = false;
        m_eve = [[PDFVEvent alloc] init];
    }
    return self;
}
-(void) find_start:(PDFDoc *) doc :(int)page_start :(NSString *)str :(bool) match_case :(bool) whole
{
    m_str = str;
    m_case = match_case;
    m_whole = whole;
    m_doc = doc;
    m_page_no = page_start;
    if( m_page )
    {
        if( m_finder )
        {
            m_finder = NULL;
        }
        m_page = NULL;
    }
    m_page_find_index = -1;
    m_page_find_cnt = 0;

}
-(int)find_prepare:(int) dir
{
    if( !is_cancel ) [m_eve wait];
    m_dir = dir;
    [m_eve reset];
    if( m_page == NULL )
    {
        is_cancel = false;
        return -1;
    }
    is_cancel = true;
    if( dir < 0 )
    {
        if( m_page_find_index >= 0) m_page_find_index--;
        if( m_page_find_index < 0 )
        {
            if( m_page_no <= 0)
            {
                return 0;
            }
            else
            {
                is_cancel = false;
                return -1;
            }
        }
        else
            return 1;
    }
    else
    {
        if( m_page_find_index < m_page_find_cnt ) m_page_find_index++;
        if( m_page_find_index >= m_page_find_cnt )
        {
            if( m_page_no >= [m_doc pageCount] - 1 )
            {
                return 0;
            }
            else
            {
                is_cancel = false;
                return -1;
            }
        }
        else
            return 1;
    }
    return 0;
}
-(int)find
{
    int ret = 0;
    int pcnt = [m_doc pageCount];
    if( m_dir < 0 )
    {
        while( (m_page == NULL || m_page_find_index < 0) && m_page_no >= 0 && !is_cancel )
        {
            if( m_page == NULL )
            {
                if( m_page_no >= pcnt ) m_page_no = pcnt - 1;
                m_page = [m_doc page:m_page_no];
                [m_page objsStart];
                m_finder = [m_page find: m_str: m_case: m_whole];
                if( m_finder == NULL ) m_page_find_cnt = 0;
                else m_page_find_cnt = [m_finder count];
                m_page_find_index = m_page_find_cnt - 1;
            }
            if( m_page_find_index < 0 )
            {
                if( m_finder != NULL )
                {
                    m_finder = NULL;
                }
                m_page = NULL;
                m_page_find_cnt = 0;
                m_page_no--;
            }
        }
        if( is_cancel || m_page_no < 0 )
        {
            if( m_finder != NULL )
            {
                m_finder = NULL;
            }
            if( m_page != NULL )
            {
                m_page = NULL;
            }
            ret = 0;//find error, notify UI process
        }
        else
            ret = 1;//find finished, notify UI process
    }
    else
    {
        while( (m_page == NULL || m_page_find_index >= m_page_find_cnt) && m_page_no < pcnt && !is_cancel )
        {
            if( m_page == NULL )
            {
                if( m_page_no < 0 ) m_page_no = 0;
                m_page = [m_doc page:m_page_no];
                [m_page objsStart];
                m_finder = [m_page find:m_str: m_case: m_whole];
                if( m_finder == NULL ) m_page_find_cnt = 0;
                else m_page_find_cnt = [m_finder count];
                m_page_find_index = 0;
            }
            if( m_page_find_index >= m_page_find_cnt )
            {
                if( m_finder != NULL )
                {
                    m_finder = NULL;
                }
                m_page = NULL;
                m_page_find_cnt = 0;
                m_page_no++;
            }
        }
        if( is_cancel || m_page_no >= pcnt )
        {
            if( m_finder != NULL )
            {
                m_finder = NULL;
            }
            if( m_page != NULL )
            {
                m_page = NULL;
            }
            ret = 0;////find error, notify UI process
        }
        else
            ret = 1;//find finished, notify UI process
    }
    [m_eve notify];
    return ret;
}

-(bool)find_get_pos:(PDF_RECT *)rect//get current found's bound.
{
    if( m_finder != NULL )
    {
        int ichar = [m_finder objsIndex:m_page_find_index];
        //int ifcnd = [m_finder count];
        int icnt = [m_page objsCount];
        if( ichar < 0 || ichar >= icnt ) return false;
        [m_page objsCharRect:ichar: rect];
        return true;
    }
    else
        return false;
}
-(void)find_draw:(PDFVCanvas *)canvas :(PDFVPage *)page//draw current found
{
    if( !is_cancel )
    {
        [m_eve wait];
        is_cancel = true;
    }
    if( m_str == NULL ) return;
    if( m_finder != NULL && m_page_find_index >= 0 && m_page_find_index < m_page_find_cnt )
    {
        int ichar = [m_finder objsIndex:m_page_find_index];
        int ichar_end = ichar + [m_str length];
        PDF_RECT rect;
        PDF_RECT rect_word;
        PDF_RECT rect_draw;
        [m_page objsCharRect:ichar: &rect];
        rect_word = rect;
        ichar++;
        while( ichar < ichar_end )
        {
            [m_page objsCharRect:ichar: &rect];
            float gap = (rect.bottom - rect.top)/2;
            if( rect_word.top == rect.top && rect_word.bottom == rect.bottom &&
               rect_word.right + gap > rect.left && rect_word.left - gap < rect.right )
            {
                if( rect_word.left > rect.left ) rect_word.left = rect.left;
                if( rect_word.right < rect.right ) rect_word.right = rect.right;
            }
            else
            {
                rect_draw.left = [page ToDIBX:rect_word.left] + [page GetX];
                rect_draw.top = [page ToDIBY:rect_word.bottom] + [page GetY];
                rect_draw.right = [page ToDIBX:rect_word.right] + [page GetX];
                rect_draw.bottom = [page ToDIBY:rect_word.top] + [page GetY];
                [canvas FillRect:CGRectMake(rect_draw.left, rect_draw.top, (rect_draw.right - rect_draw.left), (rect_draw.bottom - rect_draw.top)): g_sel_color];
                rect_word = rect;
            }
            ichar++;
        }
        rect_draw.left = [page ToDIBX:rect_word.left] + [page GetX];
        rect_draw.top = [page ToDIBY:rect_word.bottom] + [page GetY];
        rect_draw.right = [page ToDIBX:rect_word.right] + [page GetX];
        rect_draw.bottom = [page ToDIBY:rect_word.top] + [page GetY];
        [canvas FillRect:CGRectMake(rect_draw.left, rect_draw.top, (rect_draw.right - rect_draw.left), (rect_draw.bottom - rect_draw.top)): g_sel_color];
    }
}
-(int)find_get_page
{
    return m_page_no;
}
-(void)find_end
{
    if( !is_cancel )
    {
        is_cancel = true;
        [m_eve wait];
    }
    m_str = NULL;
    if( m_page != NULL )
    {
        if( m_finder != NULL )
        {
            m_finder = NULL;
        }
        m_page = NULL;
    }
}
@end