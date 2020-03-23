//
//  BookMarkViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-12-9.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "BookMarkViewController.h"

@interface BookMarkViewController ()
{
    NSString *pdfFullPath;
}

@end

@implementation BookMarkViewController


int bookMarkNum =0;

- (void)addBookMarks:(NSString *)dpath :(NSString *)subdir :(NSFileManager *)fm :(int)level
{
    NSMutableArray *bookmarks = [NSMutableArray array];
    
    NSDirectoryEnumerator *fenum = [fm enumeratorAtPath:dpath];
    NSString *fName;
    while(fName = [fenum nextObject])
    {
        NSLog(@"%@", [dpath stringByAppendingPathComponent:fName]);
        NSString *dst = [dpath stringByAppendingPathComponent:fName];
        NSString *tempString;
        
        if(fName.length >10)
        {
            tempString = [fName pathExtension];
        }
        
        if( [tempString isEqualToString:@"bookmark"] )
        {
            //add to list.
            NSFileHandle *fileHandle =[NSFileHandle fileHandleForReadingAtPath:dst];
            NSString *content = [[NSString alloc]initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
            NSArray *myarray =[content componentsSeparatedByString:@","];
            [myarray objectAtIndex:0];
            NSArray *arr = [fName componentsSeparatedByString:@"_"];
            NSString *filename = @"";
            
            for (int x = 0; x < arr.count; x++) {
                if (x + 1 < arr.count) {
                    filename = [filename stringByAppendingFormat:@"%@_", [arr objectAtIndex:x]];
                }
            }
            
            if (filename.length > 0) {
                filename = [filename substringToIndex:filename.length - 1];
            }
            
            [bookmarks addObject:@{@"Page": [NSNumber numberWithInteger:[[myarray objectAtIndex:0] intValue]], @"Label": filename, @"Path": [dpath stringByAppendingPathComponent:filename]}];
            
        }
    }
    
    m_files = bookmarks;
}

- (void)delBookMarks:(NSString *)dpath :(NSString *)subdir :(NSFileManager *)fm :(int)level
{
    
    NSDirectoryEnumerator *fenum = [fm enumeratorAtPath:dpath];
    NSString *fName;
    while(fName = [fenum nextObject])
    {
        BOOL dir;
        NSString *dst = [dpath stringByAppendingFormat:@"/%@",fName];
        if( [fm fileExistsAtPath:dst isDirectory:&dir] )
        {
            if( dir )
            {
                [self addBookMarks:dpath :dst :fm :level+1];
            }
            else if( [dst hasSuffix:@".bookmark"] )
            {
                NSString *dis = [subdir stringByAppendingFormat:@"/%@",fName];//display name
                
                NSArray *arr = [[NSArray alloc] initWithObjects:dis,dst,level, nil];
                
                [m_files addObject:arr];
            }
        }
    }
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *title =[[NSString alloc]initWithFormat:NSLocalizedString(@"Marks", @"Localizable")];
    // Do any additional setup after loading the view from its nib.
    self.title =title;
    UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:@"manage_mark.png"] tag:0];
    self.tabBarItem =item;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}
-(void)viewWlllDisAppear:(BOOL)animated
{
    [self viewWillDisappear:animated];
}
-(void)viewWillAppear:(BOOL)animated
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dpath=[paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    m_files = [[NSMutableArray alloc] init];
    [self addBookMarks:dpath :@"" :fm :0];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookMarkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dict = [m_files objectAtIndex:indexPath.row];
    
    int pageno = [[dict objectForKey:@"Page"] intValue];
    pageno++;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %i", [dict objectForKey:@"Label"], pageno];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger row = [indexPath row];
    if( m_pdf1 == nil )
    {
        m_pdf1 = [[RDLoPDFViewController alloc] initWithNibName:@"RDLoPDFViewController" bundle:nil];
    }
    
    NSArray *row_item = [m_files objectAtIndex:indexPath.row];
    NSString *path = [row_item objectAtIndex:5];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
    /*
     NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *dpath=[paths objectAtIndex:0];
     */
    
    [m_files removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( m_pdf1 == nil )
    {
        m_pdf1 = [[RDLoPDFViewController alloc] initWithNibName:@"RDLoPDFViewController" bundle:nil];
    }
    
    NSString *pwd = NULL;
    NSDictionary *row_item = [m_files objectAtIndex:indexPath.row];
    NSString *path = [row_item objectForKey:@"Path"];
    GLOBAL.g_pdf_path = [[path stringByDeletingLastPathComponent] mutableCopy];
    GLOBAL.g_pdf_name = [[[path lastPathComponent] stringByAppendingPathExtension:@"pdf"] mutableCopy];
    NSString *temp2=[row_item objectForKey:@"Page"];
    int pageno = [temp2 intValue];
    pdfFullPath = path;
    int result = [m_pdf1 PDFOpen:[GLOBAL.g_pdf_path stringByAppendingPathComponent:GLOBAL.g_pdf_name] :pwd];
    
    if(result == 1)
    {
        UINavigationController *nav = self.navigationController;
        m_pdf1.hidesBottomBarWhenPushed = YES;
        nav.hidesBottomBarWhenPushed =NO;
        [nav pushViewController:m_pdf1 animated:YES];
        //[m_pdf1 initbar:pageno];
        [m_pdf1 PDFGoto:pageno];
        
    }
    //Return value is encrypted document
    else if(result == 2)
    {
        [self presentPwdAlertControllerWithTitle:NSLocalizedString(@"Please Enter PassWord", @"Localizable") message:nil];
    }
    else if (result == 0)
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Error Document,Can't open", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                   message:str2
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if( m_pdf1 == nil )
    {
        m_pdf1 = [[RDLoPDFViewController alloc] initWithNibName:@"RDLoPDFViewController" bundle:nil];
    }
    
    NSString *pwd = NULL;
    NSArray *row_item = [m_files objectAtIndex:indexPath.row];
    NSString *path = [row_item objectAtIndex:0];
    NSArray *arr = [m_files objectAtIndex:indexPath.row];
    GLOBAL.g_pdf_name = (NSMutableString *)[[arr objectAtIndex:1] stringByAppendingFormat:@".pdf"];
    NSString *temp2=[arr objectAtIndex:2];
    //int pageno = [temp2 intValue];
    pdfFullPath = path;
    int result = [m_pdf1 PDFOpen:path :pwd];
    
    if(result == 1)
    {
        UINavigationController *nav = self.navigationController;
        m_pdf1.hidesBottomBarWhenPushed = YES;
        nav.hidesBottomBarWhenPushed =NO;
        [nav pushViewController:m_pdf1 animated:YES];
    }
    //Return value is encrypted document
    else if(result == 2)
    {
        [self presentPwdAlertControllerWithTitle:NSLocalizedString(@"Please Enter PassWord", @"Localizable") message:nil];
    }
    else if (result == 0)
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Error Document,Can't open", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                   message:str2
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

/*
- (void)alertView:(UIAlertView *)pwdDlg clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int result;
    if(buttonIndex == 0)
    {
        
        NSString *pwd = GLOBAL.text;
        result = [m_pdf1 PDFOpen:pdfFullPath :pwd];
    }else{
        result = 0;
    }
    if(result == 1)
    {
        UINavigationController *nav = self.navigationController;
        m_pdf1.hidesBottomBarWhenPushed = YES;
        nav.hidesBottomBarWhenPushed =NO;
        [nav pushViewController:m_pdf1 animated:YES];
    }
    else if(result == 2)
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Error PassWord", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:nil cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        
    }
}
*/

- (void)presentPwdAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *pwdAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [pwdAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"PassWord", @"Localizable");
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UITextField *password = pwdAlert.textFields.firstObject;
        if (![password.text isEqualToString:@""]) {
            int result = [self->m_pdf1 PDFOpen:self->pdfFullPath :password.text];
                if(result == 1)
                {
                    UINavigationController *nav = self.navigationController;
                    self->m_pdf1.hidesBottomBarWhenPushed = YES;
                    nav.hidesBottomBarWhenPushed =NO;
                    [nav pushViewController:self->m_pdf1 animated:YES];
                }
                else if(result == 2)
                {
                    NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
                    NSString *str2=NSLocalizedString(@"Error PassWord", @"Localizable");
                    [self presentPwdAlertControllerWithTitle:str1 message:str2];
                }
        }
        else
        {
            [self presentViewController:pwdAlert animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Localizable")  style:UIAlertActionStyleCancel handler:nil];
    
    [pwdAlert addAction:okAction];
    [pwdAlert addAction:cancel];
    [self presentViewController:pwdAlert animated:YES completion:nil];
}

@end
