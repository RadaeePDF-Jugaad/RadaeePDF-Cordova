//
//  UnderLineViewController.m
//  PDFViewer
//
//  Created by radaee on 13-05-30.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "HighlightColorViewController.h"
#import "RDVGlobal.h"

@implementation HighlightColorViewController
@synthesize partitationTableView;
@synthesize partitationTableViewCell;
@synthesize dicData;
@synthesize arrayData;
@synthesize checkStatus;
static int currentIndex=2;

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
    // Do any additional setup after loading the view from its nib.
    //GEAR
    //setting moved in ViewWillAppear
    self.title = NSLocalizedString(@"Highlight Color", @"Localizable");
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    //  self.partitationTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.partitationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,cwidth, cheight) style:UITableViewStyleGrouped];
    self.partitationTableView.delegate =self;
    self.partitationTableView.dataSource = self;
    
    self.partitationTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.partitationTableView];
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"HightLightColorList" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    self.dicData = dictionary;
    
    NSArray *array = [self.dicData allKeys];
    self.arrayData = array;
}

//GEAR
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    GLOBAL.g_annot_highlight_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"HighlightColor"];
    if(GLOBAL.g_annot_highlight_clr ==0)
    {
        GLOBAL.g_annot_highlight_clr =0xFFFFFF00;
    }
    
    if (GLOBAL.g_annot_highlight_clr == 0xFFFF0000) currentIndex =0;
    
    if (GLOBAL.g_annot_highlight_clr == 0xFF000000)currentIndex =1;
    if (GLOBAL.g_annot_highlight_clr == 0xFF0000FF)currentIndex =2;
    if (GLOBAL.g_annot_highlight_clr == 0xFFFFFF00)currentIndex =3;
    if (GLOBAL.g_annot_highlight_clr == 0xFFFFFFFF)currentIndex =4;
    
    [self.partitationTableView reloadData];
    
    self.partitationTableView.frame = self.view.bounds;
}
//END

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrayData count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *stringDataKey = [self.arrayData objectAtIndex:section];
    NSArray *arraySection = [self.dicData objectForKey:stringDataKey];
    return [arraySection count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]animated:YES];
    if(indexPath.row == currentIndex)
    {
        return;
    }
    switch (indexPath.row) {
        case 0:
            GLOBAL.g_annot_highlight_clr = 0xFFFF0000;
            break;
        case 1:
            GLOBAL.g_annot_highlight_clr = 0xFF000000;
            break;
        case 2:
            GLOBAL.g_annot_highlight_clr = 0xFF0000FF;
            break;
        case 3:
            GLOBAL.g_annot_highlight_clr = 0xFFFFFF00;
            break;
        case 4:
            GLOBAL.g_annot_highlight_clr = 0xFFFFFFFF;
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_annot_highlight_clr forKey:@"HighlightColor"];
    //GEAR
    [[NSUserDefaults standardUserDefaults] synchronize];
    //END
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    
    
    if(cell.accessoryType==UITableViewCellAccessoryCheckmark)
        
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        /*
         check[row].value =TRUE;
         for(int i= 0 ; i<N_ENTRIES;i++)
         {
         
         if(i!=row)
         {
         check[i].value = FALSE;
         }
         }
         */
    }
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if(oldCell.accessoryType==UITableViewCellAccessoryCheckmark)
        
    {
        oldCell.accessoryType=UITableViewCellAccessoryNone;
    }
    else
    {
        oldCell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    currentIndex = (int)indexPath.row;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *key =[self.arrayData objectAtIndex:section];
    NSArray *arraySection = [self.dicData objectForKey:key];
    
    static NSString *partitation = @"partitation";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:partitation];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:partitation];
        
    }
    cell.textLabel.text = [arraySection objectAtIndex:row];
    
    cell.accessoryType = UITableViewCellStyleDefault;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = [self.arrayData objectAtIndex:section];
    return key;
}

@end
