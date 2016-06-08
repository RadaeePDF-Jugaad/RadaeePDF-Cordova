//
//  RDFileDetailViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 26/06/2020.
//

#import "RDFileDetailViewController.h"

@interface RDFileDetailViewController ()

@end

@implementation RDFileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_cover setImage:_coverImage];
    
    NSString *pdfName = [[_pdfPath lastPathComponent] stringByDeletingPathExtension];
    [_nameField setText:pdfName];
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_pdfPath error:nil];
    NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[attributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    NSString *modificationDate = [dateFormatter stringFromDate:[attributes objectForKey:NSFileModificationDate]];
    NSString *lastModifiedString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Last modified", nil), modificationDate];
    
    [_sizeLabel setText:fileSize];
    [_lastModifiedLabel setText:lastModifiedString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [_metaButton setTitleColor:[RDUtils radaeeBlackColor] forState:UIControlStateNormal];
    [_renameButton setTitleColor:[RDUtils radaeeBlackColor] forState:UIControlStateNormal];
    [_shareButton setTitleColor:[RDUtils radaeeBlackColor] forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[RDUtils radaeeBlackColor] forState:UIControlStateNormal];
    [_metaButton setTitle:NSLocalizedString(@"Meta", nil) forState:UIControlStateNormal];
    [_renameButton setTitle:NSLocalizedString(@"Rename", nil) forState:UIControlStateNormal];
    [_shareButton setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    [_deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
}

- (IBAction)dismissView:(id)sender
{
    [_delegate refreshCollectionOnEdit];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)metaButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self->_delegate showSelectedFileMeta:self->_pdfPath];
    }];
}

- (IBAction)renameButtonTapped:(id)sender
{
    if (!_nameField.userInteractionEnabled) {
        [_nameField setUserInteractionEnabled:YES];
        [_nameField becomeFirstResponder];
        [_renameButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    } else {
        NSError * err = NULL;
        NSFileManager * fm = [[NSFileManager alloc] init];
        NSString *newPath = [[_pdfPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[_nameField.text stringByAppendingPathExtension:@"pdf"]];
        if (![_pdfPath isEqualToString:newPath] && [fm fileExistsAtPath:newPath]) {
            NSString *message = [NSString stringWithFormat:@"%@ %@",[newPath lastPathComponent],NSLocalizedString(@"already exist", nil)];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:^{
                [self->_nameField setText:[[self->_pdfPath lastPathComponent] stringByDeletingPathExtension]];
            }];
            return;
        }
        BOOL result = [fm moveItemAtPath:_pdfPath toPath:newPath error:&err];
        if(!result)
            NSLog(@"Error: %@", err);
        _pdfPath = newPath;
        [_renameButton setTitle:NSLocalizedString(@"Rename", nil) forState:UIControlStateNormal];
        [_nameField resignFirstResponder];
        [_nameField setUserInteractionEnabled:NO];
    }
}

- (IBAction)shareButtonTapped:(id)sender
{
    NSURL *fileUrl = [NSURL fileURLWithPath:_pdfPath];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[fileUrl]
                                    applicationActivities:nil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)deleteButtonTapped:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Are you sure you want to delete this file?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:self->_pdfPath error:nil];
        [self dismissView:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dismissKeyboard
{
    [self renameButtonTapped:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
