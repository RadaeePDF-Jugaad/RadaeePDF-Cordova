//
//  PDFNavCtrl.m
//  RDPDFReader
//
//  Created by Radaee on 2020/5/3.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import "PDFNavCtrl.h"
#import "UICellView.h"
#import "PDFReaderCtrl.h"

@implementation PDFNavCtrl

- (void)show_error:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)show_password :(UICellView *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Password" message:@"Need password to open the PDF file." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *txt = [alert textFields][0];
        [self process_open :cell :[txt text]];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    [alert addAction:conform];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)process_delete:(UICellView *)cell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete" message:@"Do you confirm to delete the PDF file?" preferredStyle:UIAlertControllerStyleAlert];
    PDFNavThumb *vw = mNav;
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [cell UIDelete];
        [vw refresh];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:conform];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)process_open:(UICellView *)cell :(NSString *)pswd
{
    int err = 0;
    PDFReaderCtrl *reader;
    PDFDoc *doc = [cell UIGetDoc:pswd :&err];
    switch(err)
    {
        case err_ok://goto reader page.
            reader = [[UIStoryboard storyboardWithName:@"PDFReaderCtrl" bundle:nil] instantiateViewControllerWithIdentifier:@"rdpdfreader"];
            [reader setDoc:doc];
            [self presentViewController:reader animated:YES completion:nil];
            break;
        case err_open:
            [self show_error:@"can't open file. file can't be readable."];
            doc = nil;
            break;
        case err_password:
            [self show_password:cell];
            doc = nil;
            break;
        case err_encrypt:
            [self show_error:@"unknown encryption."];
            doc = nil;
            break;
        case err_bad_file:
            [self show_error:@"PDF file damaged."];
            doc = nil;
            break;
        default:
            [self show_error:@"Unknown error."];
            doc = nil;
            break;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [mNav refresh];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [mNav setCallback
     :^(id cell) {
        UICellView *view = (UICellView *)cell;
        [self process_open:view :nil];
     }
     :^(id cell){
        UICellView *view = (UICellView *)cell;
         [self process_delete:view];
    }];
    NSString *folder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    [mNav setDir:folder];
}


- (IBAction)OnUpdate:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    int isel = (int)[seg selectedSegmentIndex];
    if(isel == 0)
    {
        NSString *folder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        [mNav setDir:folder];
    }
    else
    {
        NSString *folder = [[NSBundle mainBundle] pathForResource:@"PDFRes" ofType:nil];
        [mNav setDir:folder];
    }
}
@end
