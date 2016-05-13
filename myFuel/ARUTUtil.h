//
//  ARUTUtil.h
//  AEONScan2
//
//  Created by miura on 2013/10/15.
//  Copyright (c) 2013年 miura. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARUTUtil : NSObject

+ (NSPredicate *)createDatePredicate:(NSDate *)date;
+ (NSArray *)selectRecordArray:(NSString *)entityName predicate:(NSPredicate *)pred sortKeyName:(NSString *)sortKeyName limit:(int)limit;

//+ (BOOL)showExpireAlert;
//+ (BOOL)isShareAvailable;
//+ (BOOL)isLicenceAvailable;

+ (BOOL)isNSStringValid:(NSString *)str;
+ (BOOL)isVersionOver70;
+ (void)getSubViewDimension:(int *)width height:(int *)height;
+ (NSString *)convDate2String:(NSDate *)date;
+ (NSString *)convDate2StringHHmm:(NSDate *)date;
+ (NSString *)convDate2StringYYYYMM:(NSDate *)date;
+ (NSString *)convDate2StringExport:(NSDate *)date;

+ (NSDate *)convString2Date:(NSString *)dateString;

+ (NSString *)getDocumentDirPath;

@end
