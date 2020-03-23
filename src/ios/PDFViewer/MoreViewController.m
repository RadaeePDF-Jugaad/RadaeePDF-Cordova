//
//  MoreViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-12-9.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "MoreViewController.h"

#define KURL @"https://itunes.apple.com/us/app/radaee-pdf-reader/id599403029?l=zh&ls=1&mt=8"
@implementation MoreViewController
@synthesize partitationTableView;
@synthesize partitationTableViewCell;
@synthesize dicData;
@synthesize arrayData;




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
    NSString *title =[[NSString alloc]initWithFormat:NSLocalizedString(@"More", @"Localizable")];
    // Do any additional setup after loading the view from its nib.
    self.title =title;
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    //  self.partitationTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.partitationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,cwidth, cheight-100) style:UITableViewStyleGrouped];
    
    self.partitationTableView.delegate =self;
    self.partitationTableView.dataSource = self;
    self.partitationTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.partitationTableView];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"MoreViewPlist" withExtension:@"plist"];
   
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    self.dicData = dictionary;
   
    NSArray *array = [self.dicData allKeys];
    self.arrayData = array;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.partitationTableView.frame = self.view.bounds;
}
 
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
    /*
    if(indexPath.section==1 &&indexPath.row==1)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.radaee.com/en"]];
    }
    */
    /*if(indexPath.section == 1 && indexPath.row ==0)
    {
        if( sendMailView == nil )
        {
            
            sendMailView = [[RDMailViewController alloc] initWithNibName:@"RDMailViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        sendMailView.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:sendMailView animated:YES];
    }
     */
    if(indexPath.section ==0 && indexPath.row == 1)
    {
        NSString *str=KURL;
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
    }
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]animated:YES];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *key =[self.arrayData objectAtIndex:section];
    NSArray *arraySection = [self.dicData objectForKey:key];
    static NSString *partitation=nil;
    partitation=[NSString stringWithFormat:@"partitation%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:partitation];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:partitation];
        
    }
    UISwitch *switchView = [[UISwitch alloc]init];
    [switchView setOn:NO];
    
    NSString *label =[arraySection objectAtIndex:row];
    NSString *text;
    if([[label substringToIndex:0] isEqualToString:@"%"])
    {
        text = [label substringFromIndex:2];
    }
    else text = label;
    cell.textLabel.text = text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if(indexPath.section==0 &&indexPath.row==1 )
    {
       // cell.accessoryView = switchView;
    }
    if(indexPath.section==0 &&indexPath.row==0 )
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if(indexPath.section==0 &&indexPath.row==2)
    {
        //cell.accessoryView = switchView;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = [self.arrayData objectAtIndex:section];
    
    NSString *text;
    NSString *temp=[key substringToIndex:1];
    if([temp compare:@"%"] == NSOrderedSame)
    {
        text = [key substringFromIndex:2];
    }
    else text = key;
    
    return text;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}
-(void)performWillRotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect rect =[[UIScreen mainScreen]bounds];
    if ([self isPortrait])
    {
        if (rect.size.height < rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    else
    {
        if (rect.size.height > rect.size.width) {
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    [self.view setFrame:rect];
    [self.view sizeThatFits:rect.size];
    
}
@end
