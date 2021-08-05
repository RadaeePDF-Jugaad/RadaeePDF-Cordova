//
//  PDFPagesCtrl.m
//  PDFViewer
//
//  Created by Radaee Lou on 2020/8/13.
//

#import <Foundation/Foundation.h>
#import "PDFPagesCtrl.h"
#import "PDFObjc.h"

@implementation PDFPagesCtrl
-(void)setCallback:(PDFDoc *)doc :(PagesDone)done
{
    m_doc = doc;
    m_done = done;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.navigationController)
        self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [mPages open:m_doc];
}

- (IBAction)OnBtnBack:(id)sender {
    if(self.navigationController) [self.navigationController popViewControllerAnimated:YES];
    else [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)OnBtnDone:(id)sender {
    if([mPages modified])
    {
        int pcnt = [m_doc pageCount];
        int *rots = (int *)malloc((sizeof(int) + sizeof(bool)) * pcnt);
        bool *dels = (bool *)(rots + pcnt);
        [mPages getEditData:dels :rots];
        m_done(dels, rots);
        free(rots);
    }
    if(self.navigationController) [self.navigationController popViewControllerAnimated:YES];
    else [self dismissViewControllerAnimated:YES completion:nil];
}
@end
