//
//  UIAlertView+NSCookBook.h
//  mmView2
//
//  Created by miura on 2013/12/29.
//  Copyright (c) 2013年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (NSCookBook)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
