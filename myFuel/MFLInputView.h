//
//  MFLInputView.h
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFLInputView : UIView <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    double _trip_data;
}

@property (strong) UIPickerView *tripPicker;
@property (strong) UITextField *tf_liter;
@property (strong) UITextField *tf_price;
@property (strong) UILabel *label_trip;

@property (readwrite) int car_id;

- (void)initializeTrip;

@end
