//
//  RDAnnotPickerViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 24/06/2020.
//

#import "RDAnnotPickerViewController.h"
#import "RDVGlobal.h"
#import "RDUtils.h"

@interface RDAnnotPickerViewController ()

@end

@implementation RDAnnotPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _paletteView.backgroundColor = (_colorBtn.tag == 1) ? [UIColorFromRGB([self getAnnotColor]) colorWithAlphaComponent:1.0f] : UIColorFromRGB([self getAnnotColor]);
    
    if (_colorBtn.tag == 1) {
        _alphaSlider.userInteractionEnabled = NO;
        _alphaTextField.userInteractionEnabled = NO;
    }

    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [_paletteView.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    _redSlider.value = red * 255;
    _greenSlider.value = green * 255;
    _blueSlider.value = blue * 255;
    _alphaSlider.value = alpha;
    _redTextField.text = [NSString stringWithFormat:@"%i", (int)_redSlider.value];
    _greenTextField.text = [NSString stringWithFormat:@"%i", (int)_greenSlider.value];
    _blueTextField.text = [NSString stringWithFormat:@"%i", (int)_blueSlider.value];
    _alphaTextField.text = [NSString stringWithFormat:@"%.01f",_alphaSlider.value];
    
    
    [_redSlider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [_greenSlider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [_blueSlider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [_alphaSlider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [_redTextField addTarget:self action:@selector(onTextFieldTextChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_greenTextField addTarget:self action:@selector(onTextFieldTextChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_blueTextField addTarget:self action:@selector(onTextFieldTextChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_alphaTextField addTarget:self action:@selector(onTextFieldTextChanged:) forControlEvents:UIControlEventEditingDidEnd];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    if (_colorBtn) {
        [[_pickerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
        [[_pickerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor] setActive:YES];
    }
    
    _paletteView.layer.shadowColor = [RDUtils radaeeBlackColor].CGColor;
}

-(void)dismissKeyboard
{
    [_redTextField resignFirstResponder];
    [_greenTextField resignFirstResponder];
    [_blueTextField resignFirstResponder];
    [_alphaTextField resignFirstResponder];
}

-(void)onSliderValueChange:(UISlider*)slider
{
    [self updatePaletteViewColor];
    _redTextField.text = [NSString stringWithFormat:@"%i", (int)_redSlider.value];
    _greenTextField.text = [NSString stringWithFormat:@"%i", (int)_greenSlider.value];
    _blueTextField.text = [NSString stringWithFormat:@"%i", (int)_blueSlider.value];
    _alphaTextField.text = [NSString stringWithFormat:@"%.01f",_alphaSlider.value];
}

-(void)onTextFieldTextChanged:(UITextField *)textField
{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
    if ([alphaNums isSupersetOfSet:inStringSet])
    {
        if ([textField.text floatValue] <= 255.0 && textField != _alphaTextField) {
            _redSlider.value = [_redTextField.text floatValue];
            _greenSlider.value = [_greenTextField.text floatValue];
            _blueSlider.value = [_blueTextField.text floatValue];
        } else if ([textField.text floatValue] <= 1.0 && textField == _alphaTextField) {
            _alphaSlider.value = [_alphaTextField.text floatValue];
        } else {
            _redSlider.value = (textField == _redTextField) ? 255 : [_redTextField.text floatValue];
            _greenSlider.value = (textField == _greenTextField) ? 255 : [_greenTextField.text floatValue];
            _blueSlider.value = (textField == _blueTextField) ? 255 : [_blueTextField.text floatValue];
            _alphaSlider.value = (textField == _alphaTextField) ? 1 : [_alphaTextField.text floatValue];
            textField.text = (textField == _alphaTextField) ? @"1.0" : @"255";
        }
        [self updatePaletteViewColor];
    }
}

- (void)updatePaletteViewColor
{
    _paletteView.backgroundColor = [UIColor colorWithRed:_redSlider.value/255 green:_greenSlider.value/255 blue:_blueSlider.value/255 alpha:_alphaSlider.value];
}

- (IBAction)dismissPicker:(id)sender
{
    unsigned int color;
    color = [self hexFromColor:_paletteView.backgroundColor];
    
    if (!_colorBtn) {
        switch (_annotType) {
            case 1:
                GLOBAL.g_line_color = color;
                break;
            case 3:
                GLOBAL.g_rect_color = color;
                break;
            case 4:
                GLOBAL.g_oval_color = color;
                break;
            default:
                GLOBAL.g_ink_color = color;
                break;
        }
    } else {
        [_colorBtn setColor:color :YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelPicker:(id)sender
{
    if (_colorBtn) {
        [_colorBtn showViews];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (uint)getAnnotColor
{
    uint rgbValue;
    if (!_colorBtn) {
        switch (_annotType) {
            case 1:
                rgbValue = GLOBAL.g_line_color;
                break;
            case 3:
                rgbValue = GLOBAL.g_rect_color;
                break;
            case 4:
                rgbValue = GLOBAL.g_oval_color;
                break;
            default:
                rgbValue = GLOBAL.g_ink_color;
                break;
        }
    } else {
        rgbValue = _colorBtn.color;
    }
    return rgbValue;
}
    
- (uint)hexFromColor:(UIColor *)color {
    uint m_color = 0xFF000000|((int)_redSlider.value << 16)|((int)_greenSlider.value << 8)|(int)_blueSlider.value;
    uint ia = 255 * _alphaSlider.value;
    m_color = (m_color&0xFFFFFF)|(ia << 24);
    return m_color;
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
