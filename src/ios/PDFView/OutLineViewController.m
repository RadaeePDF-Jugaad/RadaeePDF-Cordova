//
//  OutLineViewController.m
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 __Radaee__. All rights reserved.
//

#import "OutLineViewController.h"
extern NSString *pdfFullPath;
@interface OutLineViewController ()

@end

@implementation OutLineViewController

@synthesize outlineTableView;
@synthesize outlineTableViewCell;
@synthesize dicData;
@synthesize arrayData;
@synthesize arrayOriginal;
@synthesize arForTable;
extern bool b_outline;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Outline", @"Localizable");
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    CGRect nav_rect = [self.navigationController.navigationBar bounds];
    /*
    if([[[UIDevice currentDevice]systemVersion] floatValue]>=7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;

    }
     */
    self.outlineTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,cwidth, cheight-nav_rect.size.height-20) style:UITableViewStylePlain];
    self.outlineTableView.delegate   = (id<UITableViewDelegate>)self;
    self.outlineTableView.dataSource = (id<UITableViewDataSource>)self;
    [self.view addSubview:self.outlineTableView];
   // outline_item = [[OUTLINE_ITEM alloc]init];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    b_outline = false;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
/*
struct OUTLINE_ITEM
{
    const char *label;
    int dest;//页码
    PDF_OUTLINE child;
}outline_item;
*/
-(void)setList:(PDFDoc *)doc :(PDFOutline *)parent :(PDFOutline *)first
{
  
    m_doc = doc;
    m_first = first;
    m_parent = parent;
    arForTable=[[NSMutableArray alloc] init] ;
    
    while( first )
    {
        outline_item = [[OUTLINE_ITEM alloc]init];
        outline_item.label = [first label];
        outline_item.dest = [first dest];
        outline_item.child = [first child];
        first = [first next];
        [self.arForTable addObject:outline_item];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.arForTable count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    int row = [indexPath row];
	OUTLINE_ITEM *otl = [self.arForTable objectAtIndex:row];
    
	cell.textLabel.text=otl.label;
	//[cell setIndentationLevel:[[[self.arForTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]];
    if(otl.child!=NULL)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    return cell;
}
-(void)setJump:(RDPDFViewController *)view
{
    m_jump = view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
	OUTLINE_ITEM *otl = [self.arForTable objectAtIndex:row];
    UINavigationController *nav = m_jump.navigationController;
    int pageno = [otl dest];
    if(pageno>0)
    {
        [m_jump PDFGoto:pageno];
    }
    else{return;}
    m_jump.hidesBottomBarWhenPushed = YES;
    [nav popToViewController:m_jump animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
	OUTLINE_ITEM *otl = [self.arForTable objectAtIndex:row];
    
    if( otl.child)
    {
        outlineView = [[OutLineViewController alloc] init];
        //第一个参数为父节点，
        [outlineView setList:m_doc :NULL :otl.child];
        UINavigationController *nav = m_jump.navigationController;
        outlineView.hidesBottomBarWhenPushed = YES;
        [outlineView setJump:m_jump];
        [nav pushViewController:outlineView animated:YES];
        
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    [self.view sizeToFit];
    [self.outlineTableView sizeToFit];
    [self.outlineTableViewCell sizeToFit];
    
}
@end
