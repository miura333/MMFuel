//
//  MFLCoreDataCtrl.m
//  myFuel
//
//  Created by miura on 2014/10/21.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLCoreDataCtrl.h"
#import "AppDelegate.h"
#import "MFLCDFuelRecord.h"
#import "MFLCDCars.h"
#import "ARUTUtil.h"

@implementation MFLCoreDataCtrl

+ (instancetype)sharedObject {
    static MFLCoreDataCtrl *_sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[MFLCoreDataCtrl alloc] init];
    });
    
    return _sharedObject;
}

- (void)addCar:(NSString *)car_name {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    
    MFLCDCars *newObject1 = [NSEntityDescription insertNewObjectForEntityForName:@"MFL_CARS" inManagedObjectContext:managedObjectContext];
    
    NSInteger lastId = [self maxRecordValue:@"MFL_CARS" tableName:@"car_id" predicate:nil];
    if(lastId == NSNotFound || lastId == 0){
        newObject1.car_id = [NSNumber numberWithInt:1];
    }else{
        newObject1.car_id = [NSNumber numberWithInt:lastId + 1];
    }
    
    newObject1.car_name = car_name;
    
    [delegate saveContext];
}

- (void)addRecordFromCSV:(int)car_id csvArray:(NSArray *)csvArray {
    NSString *date_string = [csvArray objectAtIndex:0];
    NSString *trip_string = [csvArray objectAtIndex:1];
    NSString *fuel_string = [csvArray objectAtIndex:3];
    NSString *price_string = [csvArray objectAtIndex:5];
    NSString *fuel_rate_string = [csvArray objectAtIndex:6];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    
    MFLCDFuelRecord *newObject1 = [NSEntityDescription insertNewObjectForEntityForName:@"MFL_FUEL_RECORD" inManagedObjectContext:managedObjectContext];
    
    NSInteger lastId = [self maxRecordValue:@"MFL_FUEL_RECORD" tableName:@"record_id" predicate:nil];   //IDはテーブル全体の通し番号なのでpredicateなし
    if(lastId == NSNotFound || lastId == 0){
        newObject1.record_id = [NSNumber numberWithInt:1];
    }else{
        newObject1.record_id = [NSNumber numberWithInt:lastId + 1];
    }
    
    NSDate *date1 = [ARUTUtil convString2Date:date_string];
    
    newObject1.car_id = [NSNumber numberWithInt:car_id];
    newObject1.date = date1;
    newObject1.date_section = [ARUTUtil convDate2StringYYYYMM:date1];
    newObject1.fuel = [NSNumber numberWithDouble:[fuel_string doubleValue]];
    newObject1.trip = [NSNumber numberWithDouble:[trip_string doubleValue]];
    newObject1.price_of_fuel = [NSNumber numberWithDouble:[price_string doubleValue]];
    newObject1.fuel_rate = [NSNumber numberWithDouble:[fuel_rate_string doubleValue]];
    
    [delegate saveContext];
}

- (void)addRecord:(int)car_id fuel:(double)fuel trip:(double)trip price:(double)price {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    
    MFLCDFuelRecord *newObject1 = [NSEntityDescription insertNewObjectForEntityForName:@"MFL_FUEL_RECORD" inManagedObjectContext:managedObjectContext];
    
    NSInteger lastId = [self maxRecordValue:@"MFL_FUEL_RECORD" tableName:@"record_id" predicate:nil];   //IDはテーブル全体の通し番号なのでpredicateなし
    if(lastId == NSNotFound || lastId == 0){
        newObject1.record_id = [NSNumber numberWithInt:1];
        newObject1.fuel_rate = [NSNumber numberWithDouble:0.0];
    }else{
        newObject1.record_id = [NSNumber numberWithInt:lastId + 1];
        
        MFLCDFuelRecord *last_record = [self getLastFuelRecord:car_id];     //燃費計算用
        if(last_record != nil) {
            double odd = trip - [last_record.trip doubleValue];
            double rate_fuel = odd / fuel;
            newObject1.fuel_rate = [NSNumber numberWithDouble:rate_fuel];
        }
    }
    
    NSDate *date1 = [NSDate date];
    
    newObject1.car_id = [NSNumber numberWithInt:car_id];
    newObject1.date = date1;
    newObject1.date_section = [ARUTUtil convDate2StringYYYYMM:date1];
    newObject1.fuel = [NSNumber numberWithDouble:fuel];
    newObject1.trip = [NSNumber numberWithDouble:trip];
    newObject1.price_of_fuel = [NSNumber numberWithDouble:price];
    
    [delegate saveContext];
}

- (NSInteger)maxRecordValue:(NSString *)entityName tableName:(NSString *)tableName predicate:(NSPredicate *)predicate
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [req setEntity:entity];
    [req setResultType:NSDictionaryResultType];
    
    if(predicate != nil){
        [req setPredicate:predicate];
    }
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:tableName];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"max_record_id"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    [req setPropertiesToFetch:@[expressionDescription]];
    
    NSError *error = nil;
    NSArray *obj = [managedObjectContext executeFetchRequest:req error:&error];
    NSInteger maxValue = NSNotFound;
    if(obj == nil){
        NSLog(@"error");
    }else if([obj count] > 0){
        maxValue = [obj[0][@"max_record_id"] integerValue];
    }
    return maxValue;
}

- (MFLCDFuelRecord *)getLastFuelRecord:(int)car_id {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"car_id == %d", car_id];
    NSInteger lastId = [self maxRecordValue:@"MFL_FUEL_RECORD" tableName:@"record_id" predicate:predicate];
    if(lastId == NSNotFound || lastId == 0){
        return nil;
    }
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"record_id == %d", lastId];
    NSArray *array_item = [ARUTUtil selectRecordArray:@"MFL_FUEL_RECORD" predicate:pred sortKeyName:@"date" limit:0];
    if(array_item == nil || [array_item count] == 0) return nil;
    
    return [array_item objectAtIndex:0];
}

- (double)getAverageFuelRate:(int)car_id {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"car_id == %d", car_id];
    NSArray *array_item = [ARUTUtil selectRecordArray:@"MFL_FUEL_RECORD" predicate:pred sortKeyName:@"date" limit:0];
    if(array_item == nil || [array_item count] == 0) return 0.0;
    
    int cnt = 0;
    double total_fuel_rate = 0.0;
    
    int i = 0;
    for(i = 0; i < [array_item count]; i++){
        MFLCDFuelRecord *record = [array_item objectAtIndex:i];
        double fuel_rate = [record.fuel_rate doubleValue];
        if(fuel_rate == 0.0) continue;
        
        total_fuel_rate += fuel_rate;
        cnt++;
    }
    
    return (total_fuel_rate / cnt);
    
//    double trip_max = 0.0, trip_min = 0.0, total_fuel = 0.0;
//    int i = 0;
//    for(i = 0; i < [array_item count]; i++){
//        MFLCDFuelRecord *record = [array_item objectAtIndex:i];
//        if(i == 0){
//            trip_max = [record.trip doubleValue];
//            trip_min = [record.trip doubleValue];
//        }else{
//            double trip = [record.trip doubleValue];
//            if(trip_min > trip) trip_min = trip;
//            if(trip_max < trip) trip_max = trip;
//        }
//        
//        total_fuel += [record.fuel doubleValue];
//    }
//    
//    return (trip_max - trip_min) / total_fuel;
    
}


@end
