//
//  ARUTUtil.m
//  AEONScan2
//
//  Created by miura on 2013/10/15.
//  Copyright (c) 2013年 miura. All rights reserved.
//
//ARARA基礎クラスユーティリティ
//便利機能

#import "ARUTUtil.h"
#import "DefineAll.h"
#import "AppDelegate.h"

@implementation ARUTUtil

+ (NSPredicate *)createDatePredicate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:date];
    //create a date with these components
    NSDate *startDate = [calendar dateFromComponents:components];
    [components setMonth:1];
    [components setDay:0]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    return [NSPredicate predicateWithFormat:@"((date >= %@) AND (date < %@)) || (date = nil)", startDate, endDate];
}

+ (NSArray *)selectRecordArray:(NSString *)entityName predicate:(NSPredicate *)pred sortKeyName:(NSString *)sortKeyName limit:(int)limit {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchBatchSize:100];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortKeyName ascending:NO];
    //NSArray *sort = [[NSArray alloc] initWithObjects:nil];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    if(pred != nil){
        [fetchRequest setPredicate:pred];
    }
    
    if(limit > 0) [fetchRequest setFetchLimit:limit];
    
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:entityName];
    
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSArray *result = resultsController.fetchedObjects;
    if(result == nil || [result count] == 0) return nil;
    
    return result;
}

//+ (BOOL)showExpireAlert {
//    //1日前になったら出す
//    NSDate *expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:mtkLicenceExpireDate];
//    NSDate *availableDate = [expireDate dateByAddingTimeInterval:DAY_INTERVAL*-1];
//    NSDate *now = [NSDate date];
//    NSComparisonResult result = [now compare:availableDate];
//    if(result == NSOrderedDescending){
//        return YES;
//    }
//    return NO;
//}
//
//+ (BOOL)isShareAvailable {
//    //8日前から延長可能
//    NSDate *expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:mtkLicenceExpireDate];
//    NSDate *availableDate = [expireDate dateByAddingTimeInterval:DAY_INTERVAL*-8];
//    NSDate *now = [NSDate date];
//    NSComparisonResult result = [now compare:availableDate];
//    if(result == NSOrderedDescending){
//        return YES;
//    }
//    return NO;
//}
//
//+ (BOOL)isLicenceAvailable {
//    NSDate *expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:mtkLicenceExpireDate];
//    NSDate *now = [NSDate date];
//    NSComparisonResult result = [now compare:expireDate];
//    if(result == NSOrderedAscending){
//        return YES;
//    }
//    return NO;
//}

+ (BOOL)isNSStringValid:(NSString *)str {
    if(str != nil && [str isEqualToString:@""] != YES) return YES;
    return NO;
}

//iOSバージョンが7以上かどうか
+ (BOOL)isVersionOver70 {
    return YES; //常にYesを返却
//	NSString *osVer = [[UIDevice currentDevice] systemVersion];
//	NSComparisonResult compResult = [osVer compare:@"7.0"];
//	if(compResult == NSOrderedSame || compResult == NSOrderedDescending){
//		return YES;
//	}
//	return NO;
}

//画面解像度を取得する
+ (void)getSubViewDimension:(int *)width height:(int *)height {
    int offset = ([self isVersionOver70] == YES ? 0 : 20);
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    int width1 = result.width;
    int height1 = result.height;
    
    *width = width1;
    *height = height1 - offset;
}

+ (NSString *)getDocumentDirPath {
    NSArray*    paths;
    NSString*   path;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    return path;
}


//日付を文字列に変換
+ (NSString *)convDate2String:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	//[dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
	
	return [dateFormatter stringFromDate:date];
}

+ (NSString *)convDate2StringHHmm:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	[dateFormatter setDateFormat:@"HH:mm"];
	
	return [dateFormatter stringFromDate:date];
}

+ (NSString *)convDate2StringYYYYMM:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy.MM"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)convDate2StringExport:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ssZZZZ"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)convString2Date:(NSString *)dateString {
    //NSString *dateString1 = [NSString stringWithFormat:@"%@+0900", dateString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

@end
