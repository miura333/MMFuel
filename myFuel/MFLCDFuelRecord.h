//
//  MFLCDFuelRecord.h
//  myFuel
//
//  Created by miura on 2014/10/21.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MFLCDFuelRecord : NSManagedObject

@property (strong) NSNumber *record_id;
@property (strong) NSNumber *car_id;
@property (strong) NSDate *date;
@property (strong) NSNumber *fuel;
@property (strong) NSNumber *fuel_rate;
@property (strong) NSNumber *price_of_fuel;
@property (strong) NSNumber *trip;
@property (strong) NSString *date_section;

@end
