//
//  MFLMainView.h
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFLInputView.h"
#import "MFLHistoryView.h"

@interface MFLMainView : UIView

@property (strong) MFLInputView *inputView;
@property (strong) MFLHistoryView *historyView;

@property (strong) UILabel *label_latest;
@property (strong) UILabel *label_average;

@property (readwrite) int car_id;
@property (strong) NSString *car_name;
@property (weak) UIView *parent_view;

- (void)updateValues;

@end
