//
//  RDAnnotPickerViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 24/06/2020.
//

#import <UIKit/UIKit.h>
#import "PDFObjc.h"
#import "UIColorBtn.h"
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x0000FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x000000FF) >>  0))/255.0 \
alpha:((float)((rgbValue & 0xFF000000) >>  24))/255.0]

@interface RDAnnotPickerViewController : UIViewController

@property (nonatomic) int annotType;
@property (nonatomic) uint annotColor;
@property (strong, nonatomic) PDFAnnot *annot;

@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *paletteView;

@property (strong, nonatomic) IBOutlet UISlider *redSlider;
@property (strong, nonatomic) IBOutlet UITextField *redTextField;

@property (strong, nonatomic) IBOutlet UISlider *greenSlider;
@property (strong, nonatomic) IBOutlet UITextField *greenTextField;

@property (strong, nonatomic) IBOutlet UISlider *blueSlider;
@property (strong, nonatomic) IBOutlet UITextField *blueTextField;

@property (strong, nonatomic) IBOutlet UISlider *alphaSlider;
@property (strong, nonatomic) IBOutlet UITextField *alphaTextField;

@property (strong, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) UIColorBtn *colorBtn;

- (IBAction)dismissPicker:(id)sender;
- (IBAction)cancelPicker:(id)sender;

@end

