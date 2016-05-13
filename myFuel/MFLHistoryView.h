//
//  MFLHistoryView.h
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MFLImportView.h"

@interface MFLHistoryView : UIView <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong) UITableView *tableView;
@property (readwrite) int car_id;
@property (strong) MFLImportView *importView;

- (void)initializeView:(int)car_id;

@end
