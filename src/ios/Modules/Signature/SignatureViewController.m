//
//  SignatureViewController.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 15/01/18.
//

#import "SignatureViewController.h"
#import "UviSignatureView.h"

@interface SignatureViewController () {
    
    UviSignatureView *sigView;
    UIToolbar *toolbar;
}

@end

extern bool g_fit_signature_to_field;

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(getImage)];
    UIBarButtonItem *reset = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleDone target:self action:@selector(resetImage)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toolbar = [[UIToolbar alloc] init];
    [toolbar setItems:@[done, flex, reset]];
    
    sigView = [[UviSignatureView alloc] init];
    self.view = sigView;
    
    [sigView addSubview:toolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [toolbar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
}

- (void)getImage
{
    // Save image to temp path
    [sigView signatureImage:CGPointZero text:@"" fitSignature:g_fit_signature_to_field];
    [_delegate didSign];
}

- (void)resetImage
{
    [sigView erase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
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
