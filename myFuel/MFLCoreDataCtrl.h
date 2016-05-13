//
//  MFLCoreDataCtrl.h
//  myFuel
//
//  Created by miura on 2014/10/21.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFLCDFuelRecord.h"

@interface MFLCoreDataCtrl : NSObject

+ (instancetype)sharedObject;

- (MFLCDFuelRecord *)getLastFuelRecord:(int)car_id;
- (void)addCar:(NSString *)car_name;
- (void)addRecordFromCSV:(int)car_id csvArray:(NSArray *)csvArray;
- (void)addRecord:(int)car_id fuel:(double)fuel trip:(double)trip price:(double)price;
- (double)getAverageFuelRate:(int)car_id;

@end
