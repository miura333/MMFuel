//
//  MFLCarsView.h
//  myFuel
//
//  Created by miura on 2014/10/22.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFLCarsView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *array_cars;

@property (strong) UITableViewCell *cell_add;

@end
