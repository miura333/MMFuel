//
//  DefineAll.h
//  mitaka
//
//  Created by miura on 2014/07/10.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#ifndef _DEFINE_ALL_H_
#define _DEFINE_ALL_H_

#ifdef DEBUG
# define LOG(...) NSLog(__VA_ARGS__)
# define LOG_METHOD_START NSLog(@"%s start", __func__)
# define LOG_METHOD_END NSLog(@"%s end", __func__)
#else
# define LOG(...) ;
# define LOG_METHOD_START ;
# define LOG_METHOD_END ;
#endif

#define USE_TESTFLIGHT_SDK                  //TestFlight SDKを使うかどうか。リリース時にはコメントアウト

#define RGB(r, g, b)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define BG_DEFAULT      RGB(238, 238, 238)
#define COLOR_HEADER  RGB(247, 247, 247)
#define COLOR_HEADER_BORDER  RGB(79, 79, 79)

#define DAY_INTERVAL (60*60*24)

#define PREF_CELL_HEIGHT        72
#define PREF_CELL_HEIGHT_2        44
#define PREF_DATE_VIEW_HEIGHT   260     //216+44

#define mflAddViewClosed        @"MFL_ADD_VIEW_CLOSED"
#define mflHistoryViewClosed    @"MFL_HISTORY_VIEW_CLOSED"
#define mflCarsViewClosed    @"MFL_CARS_VIEW_CLOSED"
#define mflImportViewClosed    @"MFL_IMPORT_VIEW_CLOSED"
#define mflMailViewRequired     @"MFL_MAIL_VIEW_REQUIRED"
#define mflCurrentPageIndex     @"MFL_CURRENT_PAGE_INDEX"

#endif