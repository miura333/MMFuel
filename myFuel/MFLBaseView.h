//
//  MFLBaseView.h
//  myFuel
//
//  Created by miura on 2014/10/22.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MFLCarsView.h"

@interface MFLBaseView : UIView <UIScrollViewDelegate>

@property (strong) UIScrollView *scrollView;
@property (strong) UIPageControl *pageCtrl;
@property (strong) MFLCarsView *carsView;

@property (strong) NSMutableArray *array_cars;

@property (strong) UILabel *label_name;

@end
