//
//  MFLMainView.m
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLMainView.h"
#import "ARUTUtil.h"
#import "DefineAll.h"

#import "MFLCoreDataCtrl.h"
#import "MFLCDFuelRecord.h"

#import "UIAlertView+NSCookBook.h"

@implementation MFLMainView

- (void)historyTapped:(id)sender {
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    _historyView = [[MFLHistoryView alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    [_parent_view addSubview:_historyView]; //selfだとヘッダーが隠れてしまうため親ビューから出す
    
    [_historyView initializeView:_car_id];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_historyView setFrame:CGRectMake(0, 0, width, height)];
    }completion:^(BOOL finished){
    }];
}

- (void)addButtonTapped:(id)sender {
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    _inputView = [[MFLInputView alloc] initWithFrame:CGRectMake(0, height, width, height)];
    _inputView.car_id = _car_id;
    [_parent_view addSubview:_inputView];
    
    [_inputView initializeTrip];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_inputView setFrame:CGRectMake(0, 0, width, height)];
    }completion:^(BOOL finished){
    }];
}

- (void)createButton:(int)x y:(int)y title:(NSString *)title iconName:(NSString *)iconName action:(SEL)action {
    //ボタン
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(x, y, 90, 90)];
    [btn1 setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [btn1 addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn1];
    
    //テキスト
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 100, 90, 20)];
    [label2 setFont:[UIFont systemFontOfSize:14]];
    [label2 setTextColor:COLOR_HEADER_BORDER];
    [label2 setBackgroundColor:[UIColor clearColor]];
    [label2 setTextAlignment:NSTextAlignmentCenter];
    [label2 setText:title];
    [self addSubview:label2];
}

- (void)updateValues {
    double fuel_rate = 0.0;
    MFLCDFuelRecord *record = [[MFLCoreDataCtrl sharedObject] getLastFuelRecord:_car_id];
    if(record != nil) fuel_rate = [record.fuel_rate doubleValue];
    
    NSDictionary *stringAttributes1 = @{ NSForegroundColorAttributeName : COLOR_HEADER_BORDER,
                                         NSFontAttributeName : [UIFont systemFontOfSize:80.0f] };
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f",fuel_rate] attributes:stringAttributes1];
    
    NSDictionary *stringAttributes2 = @{ NSForegroundColorAttributeName : COLOR_HEADER_BORDER,
                                         NSFontAttributeName : [UIFont systemFontOfSize:18.0f] };
    NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:@"km/l" attributes:stringAttributes2];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    [mutableAttributedString appendAttributedString:string1];
    [mutableAttributedString appendAttributedString:string2];
    
    [_label_latest setAttributedText:mutableAttributedString];
    
    //--
    
    double fuel_rate_average = [[MFLCoreDataCtrl sharedObject] getAverageFuelRate:_car_id];
    
    NSDictionary *stringAttributes3 = @{ NSForegroundColorAttributeName : COLOR_HEADER_BORDER,
                                         NSFontAttributeName : [UIFont systemFontOfSize:80.0f] };
    NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f",fuel_rate_average] attributes:stringAttributes3];
    
    NSDictionary *stringAttributes4 = @{ NSForegroundColorAttributeName : COLOR_HEADER_BORDER,
                                         NSFontAttributeName : [UIFont systemFontOfSize:18.0f] };
    NSAttributedString *string4 = [[NSAttributedString alloc] initWithString:@"km/l" attributes:stringAttributes4];
    
    NSMutableAttributedString *mutableAttributedString2 = [[NSMutableAttributedString alloc] init];
    [mutableAttributedString2 appendAttributedString:string3];
    [mutableAttributedString2 appendAttributedString:string4];
    
    [_label_average setAttributedText:mutableAttributedString2];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults addObserver:self forKeyPath:mflAddViewClosed options:0 context:nil];
        [defaults addObserver:self forKeyPath:mflHistoryViewClosed options:0 context:nil];
        
        int width = 0, height = 0;
        [ARUTUtil getSubViewDimension:&width height:&height];
        
        int offset_y = 64;
        
        UILabel *label_latest_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 80-offset_y, width, 25)];
        [label_latest_title setFont:[UIFont systemFontOfSize:18]];
        [label_latest_title setTextColor:COLOR_HEADER_BORDER];
        [label_latest_title setBackgroundColor:[UIColor clearColor]];
        [label_latest_title setTextAlignment:NSTextAlignmentCenter];
        [label_latest_title setText:@"Latest"];
        [self addSubview:label_latest_title];
        
        _label_latest = [[UILabel alloc] initWithFrame:CGRectMake(0, 105-offset_y, width, 80)];
        [_label_latest setBackgroundColor:[UIColor clearColor]];
        [_label_latest setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label_latest];
        
        //Average
        UILabel *label_average_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 220-offset_y, width, 25)];
        [label_average_title setFont:[UIFont systemFontOfSize:18]];
        [label_average_title setTextColor:COLOR_HEADER_BORDER];
        [label_average_title setBackgroundColor:[UIColor clearColor]];
        [label_average_title setTextAlignment:NSTextAlignmentCenter];
        [label_average_title setText:@"Average"];
        [self addSubview:label_average_title];
        
        _label_average = [[UILabel alloc] initWithFrame:CGRectMake(0, 245-offset_y, width, 80)];
        [_label_average setBackgroundColor:[UIColor clearColor]];
        [_label_average setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label_average];
        
        [self createButton:width/4-90/2 y:height/2 + height/4 -90/2-offset_y title:@"Add" iconName:@"mfl_home_add_normal" action:@selector(addButtonTapped:)];

        [self createButton:width/2 + width/4 - 90/2 y:height/2 + height/4 -90/2-offset_y title:@"History" iconName:@"mfl_home_history_normal" action:@selector(historyTapped:)];

    }
    return self;
}

- (void)dealloc {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:mflAddViewClosed];
    [defaults removeObserver:self forKeyPath:mflHistoryViewClosed];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    if ([keyPath isEqualToString:mflAddViewClosed] == YES) {
        [UIView animateWithDuration:0.3 animations:^{
            [_inputView setFrame:CGRectMake(0, height, width, height)];
            [self updateValues];
        }completion:^(BOOL finished){
            [_inputView removeFromSuperview];
        }];
    }else if([keyPath isEqualToString:mflHistoryViewClosed] == YES) {
        
        [UIView animateWithDuration:0.3 animations:^{
            [_historyView setFrame:CGRectMake(width, 0, width, height)];
            [self updateValues];
        }completion:^(BOOL finished){
            [_historyView removeFromSuperview];
        }];
    }
}

@end
