//
//  RDAnnotToolBar.m
//  PDFViewer
//
//  Created by strong on 2018/3/26.
//

#import "RDAnnotToolBar.h"

@interface RDAnnotToolBar()
{
    NSMutableArray *normalToolBarArray;
    NSArray *performToolBarArray;
    NSArray *searchToolBarArray;
}
@end

@implementation RDAnnotToolBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.barStyle = UIBarStyleBlackOpaque;
        [self sizeToFit];
    }
    return self;
}

- (void)setupToolBarArray
{
    UIImage *closeImg = (_closeImage) ? _closeImage : [UIImage imageNamed:@"btn_back"];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:closeImg style:UIBarButtonItemStylePlain target:self action:@selector(closeClick)];
    closeButton.width = ICON_WIDTH;
    
    UIImage *searchImg = (_searchImage) ? _searchImage : [UIImage imageNamed:@"btn_search"];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithImage:searchImg style:UIBarStyleBlackOpaque target:self action:@selector(searchClick)];
    searchButton.width = ICON_WIDTH;
    
    UIImage *drawImg = (_drawImage) ? _drawImage : [UIImage imageNamed:@"btn_ink"];
    UIBarButtonItem *drawButton = [[UIBarButtonItem alloc]initWithImage:drawImg style:UIBarButtonItemStylePlain target:self action:@selector(drawModeClick)];
    drawButton.width = ICON_WIDTH;
    
    UIImage *selectImg = (_selectImage) ? _selectImage : [UIImage imageNamed:@"btn_select"];
    UIBarButtonItem *selectText = [[UIBarButtonItem alloc] initWithImage:selectImg style:UIBarButtonItemStylePlain target:self action:@selector(selectClick)];
    selectText.width = ICON_WIDTH;
    
    UIImage *undoImg = (_undoImage) ? _undoImage : [UIImage imageNamed:@"btn_undo"];
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc]initWithImage:undoImg style:UIBarButtonItemStylePlain target:self action:@selector(undoClick)];
    undoButton.width = ICON_WIDTH;
    
    UIImage *redoImg = (_redoImage) ? _redoImage : [UIImage imageNamed:@"btn_redo"];
    UIBarButtonItem *redoButton=[[UIBarButtonItem alloc]initWithImage:redoImg style:UIBarButtonItemStylePlain target:self action:@selector(redoClick)];
    redoButton.width = ICON_WIDTH;
    
    UIImage *gridImg = (_gridImage) ? _gridImage : [UIImage imageNamed:@"btn_grid"];
    UIBarButtonItem *gridButton=[[UIBarButtonItem alloc]initWithImage:gridImg style:UIBarButtonItemStylePlain target:self action:@selector(gridlick)];
    gridButton.width = ICON_WIDTH;
    
    UIImage *moreImg = (_moreImage) ? _moreImage : [UIImage imageNamed:@"btn_more"];
    _moreButton = [[UIBarButtonItem alloc] initWithImage:moreImg style:UIBarButtonItemStylePlain target:self action:@selector(moreClick)];
    normalToolBarArray = [[NSMutableArray alloc] initWithObjects:searchButton,drawButton,selectText,undoButton,redoButton,gridButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], _moreButton,nil];
    
    UIImage *rightImg = (_nextImage) ? _nextImage : [UIImage imageNamed:@"btn_right"];
    UIBarButtonItem *nextbutton=[[UIBarButtonItem alloc]initWithImage:rightImg style:UIBarStyleBlackOpaque target:self action:@selector(nextword)];
    nextbutton.width = ICON_WIDTH;
    
    UIImage *leftImg = (_prevImage) ? _prevImage : [UIImage imageNamed:@"btn_left"];
    UIBarButtonItem *prevbutton=[[UIBarButtonItem alloc]initWithImage:leftImg style:UIBarStyleBlackOpaque target:self action:@selector(prevword)];
    prevbutton.width = ICON_WIDTH;
    
    UIImage *removeImg = (_removeImage) ? _removeImage : [UIImage imageNamed:@"btn_annot_remove"];
    UIBarButtonItem *searchCancelbtn=[[UIBarButtonItem alloc]initWithImage:removeImg style:UIBarStyleBlackOpaque target:self action:@selector(searchCancel)];
    searchCancelbtn.width = ICON_WIDTH;
    searchToolBarArray = [[NSArray alloc]initWithObjects:prevbutton,nextbutton,searchCancelbtn,nil];
    
    UIImage *performImg = (_performImage) ? _performImage : [UIImage imageNamed:@"btn_perform"];
    UIBarButtonItem *playbutton=[[UIBarButtonItem alloc]initWithImage:performImg style:UIBarStyleBlackOpaque target:self action:@selector(performAnnot)];
    playbutton.width = ICON_WIDTH;
    
    UIImage *deleteImg = (_deleteImage) ? _deleteImage : [UIImage imageNamed:@"btn_remove"];
    UIBarButtonItem *deletebutton=[[UIBarButtonItem alloc]initWithImage:deleteImg style:UIBarStyleBlackOpaque target:self action:@selector(deleteAnnot)];
    deletebutton.width = ICON_WIDTH;
    
    UIImage *cancelImg = (_removeImage) ? _removeImage : [UIImage imageNamed:@"btn_annot_remove"];
    UIBarButtonItem *cancelbtn=[[UIBarButtonItem alloc]initWithImage:cancelImg style:UIBarStyleBlackOpaque target:self action:@selector(annotCancel)];
    cancelbtn.width = ICON_WIDTH;
    performToolBarArray = [[NSArray alloc]initWithObjects:playbutton,deletebutton,cancelbtn,nil];
    
    
    NSMutableArray *hiddenItems = [NSMutableArray arrayWithObjects: [NSNumber numberWithBool:_hideSearchImage], [NSNumber numberWithBool:_hideDrawImage], [NSNumber numberWithBool:_hideSelImage], [NSNumber numberWithBool:_hideUndoImage], [NSNumber numberWithBool:_hideRedoImage],  [NSNumber numberWithBool:_hideGridImage], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:_hideMoreImage], nil];
    
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    for (int i = 0; i < hiddenItems.count; i++) {
        if ([[hiddenItems objectAtIndex:i] boolValue]) {
            [objectsToRemove addObject:[normalToolBarArray objectAtIndex:i]];
        }
    }
    
    [normalToolBarArray removeObjectsInArray:objectsToRemove];
    [normalToolBarArray insertObject:closeButton atIndex:0];
    
    [self changeToNormalToolBar];
}

- (void)changeToPerformToolBar
{
    [self setItems:performToolBarArray];
}

- (void)changeToSearchToolBar
{
    [self setItems:searchToolBarArray];
}

- (void)changeToNormalToolBar
{
    [self setItems:normalToolBarArray];
}
#pragma mark - Delegate
// normalbar delegate
- (void)closeClick
{
    if (self.m_delegate) {
        [_m_delegate closeView];
    }
}
- (void)searchClick;
{
    if (self.m_delegate) {
        [_m_delegate searchView];
    }
}
- (void)drawModeClick;
{
    if (self.m_delegate) {
        [_m_delegate showDrawModeTableView];
    }
}
- (void)selectClick;
{
    if (self.m_delegate) {
        [_m_delegate selectIsStarting];
    }
}
- (void)undoClick;
{
    if (self.m_delegate) {
        [_m_delegate undoAnnot];
    }
}
- (void)redoClick;
{
    if (self.m_delegate) {
        [_m_delegate redoAnnot];
    }
}
- (void)gridlick;
{
    if (self.m_delegate) {
        [_m_delegate toggleGrid];
    }
}
- (void)moreClick;
{
    if (self.m_delegate) {
        [_m_delegate showMoreButtons];
    }
}
//performbar delegate
- (void)nextword;
{
    if (self.m_delegate) {
        [_m_delegate nextword];
    }
}
- (void)prevword;
{
    if (self.m_delegate) {
        [_m_delegate prevword];
    }
}
- (void)searchCancel;
{
    if (self.m_delegate) {
        [_m_delegate searchCancel];
    }
}
//searchbar delegate
- (void)performAnnot;
{
    if (self.m_delegate) {
        [_m_delegate performAnnot];
    }
}
- (void)deleteAnnot;
{
    if (self.m_delegate) {
        [_m_delegate deleteAnnot];
    }
}
- (void)annotCancel;
{
    if (self.m_delegate) {
        [_m_delegate annotCancel];
    }
}

@end
