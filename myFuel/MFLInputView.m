//
//  MFLInputView.m
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLInputView.h"
#import "ARUTUtil.h"
#import "DefineAll.h"

#import "MFLCoreDataCtrl.h"
#import "MFLCDFuelRecord.h"

#define MFL_TRIP_TAG        30001
#define MFL_LITERS_TAG        30002
#define MFL_PRICE_TAG        30003

@implementation MFLInputView

- (void)updateButtonBackground:(int)btn_id {
    UIButton *btn_trip = (UIButton *)[self viewWithTag:MFL_TRIP_TAG];
    if(btn_trip) [btn_trip setBackgroundColor:[UIColor whiteColor]];
    UIButton *btn_liters = (UIButton *)[self viewWithTag:MFL_LITERS_TAG];
    if(btn_liters) [btn_liters setBackgroundColor:[UIColor whiteColor]];
    UIButton *btn_price = (UIButton *)[self viewWithTag:MFL_PRICE_TAG];
    if(btn_price) [btn_price setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *btn1 = (UIButton *)[self viewWithTag:btn_id];
    if(btn1){
        [btn1 setBackgroundColor:BG_DEFAULT];
    }
}

- (void)backButtonTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:mflAddViewClosed];
    [defaults synchronize];
}

- (void)saveButtonTapped:(id)sender {
    [[MFLCoreDataCtrl sharedObject] addRecord:_car_id fuel:[_tf_liter.text doubleValue] trip:[_label_trip.text doubleValue] price:[_tf_price.text doubleValue]];
    [self backButtonTapped:nil];
}

- (void)tripButtonTapped:(id)sender {
    [_tf_price resignFirstResponder];
    [_tf_liter resignFirstResponder];
    
    [self updateButtonBackground:MFL_TRIP_TAG];
}

- (void)litersButtonTapped:(id)sender {
    [self updateButtonBackground:MFL_LITERS_TAG];
    [_tf_liter becomeFirstResponder];
}

- (void)priceButtonTapped:(id)sender {
    [self updateButtonBackground:MFL_PRICE_TAG];
    [_tf_price becomeFirstResponder];
}

- (void)setupHeader:(int)width {
    int headerHeight = ([ARUTUtil isVersionOver70] ? 64 : 44);
    int offset_y = ([ARUTUtil isVersionOver70] ? 20 : 0);
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, headerHeight)];
    [header setBackgroundColor:COLOR_HEADER];
    [self addSubview:header];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight-1, width, 1)];
    [line1 setBackgroundColor:COLOR_HEADER_BORDER];
    [self addSubview:line1];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(60, offset_y, 200, 44)];
    [label1 setFont:[UIFont systemFontOfSize:18]];
    [label1 setTextColor:[UIColor blackColor]];
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Add"];
    [header addSubview:label1];
    
    UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setFrame:CGRectMake(0, offset_y, 44, 44)];
    [btn_back setImage:[UIImage imageNamed:@"00-btn_close"] forState:UIControlStateNormal];
    [btn_back addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_back];
    
    UIButton *btn_save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn_save setFrame:CGRectMake(width - 60, offset_y, 60, 44)];
    [btn_save setTitle:@"Save" forState:UIControlStateNormal];
    [btn_save setTitle:@"Save" forState:UIControlStateHighlighted];
//    [btn_save setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [btn_save setTitleColor:COLOR_HEADER_BORDER forState:UIControlStateHighlighted];
    [btn_save addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_save];
    
}

- (void)setupGroupItem:(NSString *)title y:(int)y action:(SEL)action btn_id:(int)btn_id{
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    //20141003 miura mod iPhone6+対応
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(0, y, width, PREF_CELL_HEIGHT)];
    [btn1 setBackgroundColor:[UIColor whiteColor]];
    btn1.tag = btn_id;
    if(action != nil){
        [btn1 addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:btn1];
    
    UILabel *label_text1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 250, PREF_CELL_HEIGHT)];
    [label_text1 setFont:[UIFont systemFontOfSize:16]];
    [label_text1 setTextColor:[UIColor blackColor]];
    [label_text1 setBackgroundColor:[UIColor clearColor]];
    [label_text1 setTextAlignment:NSTextAlignmentLeft];
    [label_text1 setText:title];
    [btn1 addSubview:label_text1];
    
//    UIImageView *cell_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(width - 25, (PREF_CELL_HEIGHT-1)/2 - 15/2, 15, 15)];
//    [cell_arrow setImage:[UIImage imageNamed:@"00-cell_arrow"]];
//    [btn1 addSubview:cell_arrow];
//    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, PREF_CELL_HEIGHT-1, width, 1)];
    [line1 setBackgroundColor:COLOR_HEADER_BORDER];
    [btn1 addSubview:line1];
}

- (void)initializeTrip {
    MFLCDFuelRecord *record = [[MFLCoreDataCtrl sharedObject] getLastFuelRecord:_car_id];
    if(record == nil) return;
    
    double lastTrip = [record.trip doubleValue];
    int value = lastTrip*10;
    int i = 0;
    for(i = 7; i >= 0; i--) {
        if(i == 6) continue;
        
        int amari = value%10;   //余りだけ日本語。。。
        value = value/10;
        
        [_tripPicker selectRow:amari inComponent:i animated:NO];
        
        if(value == 0) break;
    }
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int width = 0, height = 0;
        [ARUTUtil getSubViewDimension:&width height:&height];
        
        [self setupHeader:width];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        int y1 = 72;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, y1-1, width, 1)];
        [line1 setBackgroundColor:COLOR_HEADER_BORDER];
        [self addSubview:line1];
        
        [self setupGroupItem:@"Trip" y:y1 action:@selector(tripButtonTapped:) btn_id:MFL_TRIP_TAG];
        
        _label_trip = [[UILabel alloc] initWithFrame:CGRectMake(width - 200, y1, 170, PREF_CELL_HEIGHT)];
        [_label_trip setFont:[UIFont systemFontOfSize:20]];
        [_label_trip setTextColor:COLOR_HEADER_BORDER];
        [_label_trip setBackgroundColor:[UIColor clearColor]];
        [_label_trip setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_label_trip];
        
        y1 += PREF_CELL_HEIGHT;
        [self setupGroupItem:@"Liters" y:y1 action:@selector(litersButtonTapped:) btn_id:MFL_LITERS_TAG];
        
        _tf_liter = [[UITextField alloc] initWithFrame:CGRectMake(width - 200, y1, 170, PREF_CELL_HEIGHT)];
        [_tf_liter setFont:[UIFont systemFontOfSize:20]];
        [_tf_liter setTextColor:COLOR_HEADER_BORDER];
        [_tf_liter setBackgroundColor:[UIColor clearColor]];
        [_tf_liter setTextAlignment:NSTextAlignmentRight];
        [_tf_liter setKeyboardType:UIKeyboardTypeDecimalPad];
        _tf_liter.delegate = self;
        [self addSubview:_tf_liter];
        
        y1 += PREF_CELL_HEIGHT;
        [self setupGroupItem:@"Price" y:y1 action:@selector(priceButtonTapped:) btn_id:MFL_PRICE_TAG];
        
        _tf_price = [[UITextField alloc] initWithFrame:CGRectMake(width - 200, y1, 170, PREF_CELL_HEIGHT)];
        [_tf_price setFont:[UIFont systemFontOfSize:20]];
        [_tf_price setTextColor:COLOR_HEADER_BORDER];
        [_tf_price setBackgroundColor:[UIColor clearColor]];
        [_tf_price setTextAlignment:NSTextAlignmentRight];
        [_tf_price setKeyboardType:UIKeyboardTypeDecimalPad];
        _tf_price.delegate = self;
        [self addSubview:_tf_price];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, height-2-216, width, 1)];
        [line2 setBackgroundColor:COLOR_HEADER_BORDER];
        [self addSubview:line2];
        
        _tripPicker = [[UIPickerView alloc] init];
        _tripPicker.center = CGPointMake(width/2, height-216/2);
        _tripPicker.delegate = self;
        _tripPicker.dataSource = self;
        [self addSubview:_tripPicker];
        
        //20141229 miura add 初期状態では必ずトリップなのでトリップを変える
        [self updateButtonBackground:MFL_TRIP_TAG];
        
    }
    return self;
}

#pragma mark UIPickerView Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 8;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if(component != 6){
        return 10;
    }else{
        return 1;  //小数点
    }
}

-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 6){
        return @".";
    }
    
    // 行インデックス番号を返す
    return [NSString stringWithFormat:@"%d", row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSInteger trip0 = [_tripPicker selectedRowInComponent:0];
    NSInteger trip1 = [_tripPicker selectedRowInComponent:1];
    NSInteger trip2 = [_tripPicker selectedRowInComponent:2];
    NSInteger trip3 = [_tripPicker selectedRowInComponent:3];
    NSInteger trip4 = [_tripPicker selectedRowInComponent:4];
    NSInteger trip5 = [_tripPicker selectedRowInComponent:5];
    NSInteger trip6 = [_tripPicker selectedRowInComponent:7];
    
    _trip_data = trip0*100000+trip1*10000+trip2*1000+trip3*100+trip4*10+trip5+trip6*0.1;
    
    [_label_trip setText:[NSString stringWithFormat:@"%.1f", _trip_data]];
    
}

#pragma mark UITextField Delegate
-(void)textFieldDidBeginEditing:(UITextField*)textField {
    if(textField == _tf_liter) {
        [self updateButtonBackground:MFL_LITERS_TAG];
    }else if(textField == _tf_price) {
        [self updateButtonBackground:MFL_PRICE_TAG];
    }
}


@end
