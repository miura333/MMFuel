//
//  MFLImportView.h
//  myFuel
//
//  Created by miura on 2014/10/22.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFLImportView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) UITableView *tableView;
@property (readwrite) int car_id;

@property (strong) NSMutableArray *array_files;

@end
