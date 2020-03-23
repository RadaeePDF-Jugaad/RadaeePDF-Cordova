//
//  OutLineViewController.m
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 __Radaee__. All rights reserved.
//

#import "OutLineViewController.h"

@interface OutLineViewController ()

@end

@implementation OutLineViewController
@synthesize outlineTableView;
@synthesize outlineTableViewCell;
@synthesize dicData;
@synthesize arrayData;
@synthesize arrayOriginal;
@synthesize arForTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     
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

    self.outlineTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,cwidth, cheight-nav_rect.size.height-20) style:UITableViewStylePlain];
    self.outlineTableView.delegate   = (id<UITableViewDelegate>)self;
    self.outlineTableView.dataSource = (id<UITableViewDataSource>)self;
    [self.view addSubview:self.outlineTableView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void)setList:(PDFDoc *)doc :(PDFOutline *)parent :(PDFOutline *)first
{
  
    m_doc      = doc;
    m_first    = first;
    m_parent   = parent;
    arForTable = [[NSMutableArray alloc] init] ;
    
    while(first){
        outline_item = [[OUTLINE_ITEM alloc]init];
        outline_item.label = [first label];
        outline_item.dest = [first dest];
        outline_item.link = [first fileLink];
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
    NSInteger row = [indexPath row];
	OUTLINE_ITEM *otl = [self.arForTable objectAtIndex:row];
    
	cell.textLabel.text=otl.label;
    if(otl.child != NULL){
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    return cell;
}
-(void)setJump:(RDLoPDFViewController *)view
{
    m_jump = view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
	OUTLINE_ITEM *otl = [self.arForTable objectAtIndex:row];
    int pageno = [otl dest];
    if(pageno>0){
        [m_jump PDFGoto:pageno];
    }
    else{return;}
    m_jump.hidesBottomBarWhenPushed = YES;
    [self.navigationController popToViewController:m_jump animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
	OUTLINE_ITEM *otl = [self.arForTable objectAtIndex:row];
    
    if( otl.child)
    {
        outlineView = [[OutLineViewController alloc] init];
        //First para is parent node
        [outlineView setList:m_doc :NULL :otl.child];
        UINavigationController *nav = m_jump.navigationController;
        outlineView.hidesBottomBarWhenPushed = YES;
        [outlineView setJump:m_jump];
        [nav pushViewController:outlineView animated:YES];
        
    }
}

@end
