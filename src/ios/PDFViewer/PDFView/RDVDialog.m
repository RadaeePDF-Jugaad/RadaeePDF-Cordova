

#import "RDVDialog.h"
#import "UIColor+Hex.h"

#define BUTTON_HEI 30
#define MARGIN_GAP 5
#define SUBJECT_HEI 30
#define SUBJECT_WID 50

@interface RDVDialog ()
{
    UITapGestureRecognizer *tap;
}

@end

@implementation RDVDialog


- (instancetype)init:(PDFPage *)page withAnnot:(PDFAnnot *)annot
{
    self = [super init];
    if(self)
    {
        m_page = page;
        m_annot = annot;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
    }
    return self;
}

- (void)tapBackground
{
    [contentTextView resignFirstResponder];
    [titleTextView resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)viewDidLoad
{
    NSString *subj = [m_annot getPopupSubject];
    NSString *text = [m_annot getPopupText];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)];
    [self.view addGestureRecognizer:tap];
    
    CGRect vrc = self.view.frame;
    panelView = [[UIView alloc] initWithFrame:CGRectMake(20, 70, vrc.size.width - 40, 160)];
    panelView.backgroundColor = [UIColor colorWithHexString:@"D3D3D3"];
    panelView.clipsToBounds = YES;
    panelView.layer.cornerRadius = 2.f;
    [self.view addSubview:panelView];
    
    vrc = panelView.frame;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_GAP,2* MARGIN_GAP, SUBJECT_WID, SUBJECT_HEI)];
    [lab setFont:[UIFont systemFontOfSize: 10]];
    [lab setText:@"Subject:"];
    [panelView addSubview:lab];
    titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(SUBJECT_WID + MARGIN_GAP * 2 , 2* MARGIN_GAP, vrc.size.width - SUBJECT_WID - MARGIN_GAP * 3, SUBJECT_HEI)];
    [titleTextView setScrollEnabled:NO];
    titleTextView.clipsToBounds = YES;
    titleTextView.layer.cornerRadius = 2.f;
    [titleTextView setText:subj];
    [panelView addSubview:titleTextView];
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_GAP, MARGIN_GAP + SUBJECT_HEI + MARGIN_GAP, SUBJECT_WID, SUBJECT_HEI)];
    [lab setFont:[UIFont systemFontOfSize: 10]];
    [lab setText:@"Content:"];
    [panelView addSubview:lab];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(SUBJECT_WID + MARGIN_GAP * 2, SUBJECT_HEI + MARGIN_GAP * 3, vrc.size.width - SUBJECT_WID - MARGIN_GAP * 3, vrc.size.height - SUBJECT_HEI - BUTTON_HEI - MARGIN_GAP * 6)];
    contentTextView.clipsToBounds = YES;
    contentTextView.layer.cornerRadius = 2.f;
    [contentTextView setScrollEnabled:YES];
    [contentTextView setText:text];
    [panelView addSubview:contentTextView];
    
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_GAP, vrc.size.height - BUTTON_HEI - MARGIN_GAP * 1.5, vrc.size.width / 2 - MARGIN_GAP * 2, BUTTON_HEI)];
    [cancelBtn setBackgroundColor:[UIColor colorWithHexString:@"f6f6f6"]];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize: 15]];
    cancelBtn.clipsToBounds = YES;
    cancelBtn.layer.cornerRadius = 2.f;
    [panelView addSubview:cancelBtn];
   
    confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_GAP + vrc.size.width / 2, vrc.size.height - BUTTON_HEI - MARGIN_GAP*1.5, vrc.size.width / 2 - MARGIN_GAP * 2, BUTTON_HEI)];
    [confirmBtn setTitle:@"OK" forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:[UIColor colorWithHexString:@"f6f6f6"]];
    [confirmBtn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize: 15]];
    confirmBtn.clipsToBounds = YES;
    confirmBtn.layer.cornerRadius = 2.f;
    [panelView addSubview:confirmBtn];

    [confirmBtn addTarget:self action:@selector(clickOK) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickDelete
{
    __weak typeof(self) ws = self;
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 if(ws.deleteAnnotBlock){
                                     ws.deleteAnnotBlock();
                                 }
                             }];
    m_page = nil;
    m_annot = nil;
}

-(void)clickOK
{
    [m_annot setPopupSubject:titleTextView.text];
    [m_annot setPopupText:contentTextView.text];
    
    __weak typeof(self) ws = self;
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 if(ws.okBtnClickBlock){
                                     ws.okBtnClickBlock();
                                 }
                             }];
    m_page = nil;
    m_annot = nil;
}
-(void)clickCancel
{
    __weak typeof(self) ws = self;
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 if(ws.cancelAnnotBlock){
                                     ws.cancelAnnotBlock();
                                 }
                             }];
    m_page = nil;
    m_annot = nil;
}

@end
