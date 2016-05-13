//
//  UIActionSheet+NSCookBook.h
//  q
//
//  Created by miura on 2014/02/25.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet(NSCookBook)

- (void)showWithCompletion:(UIView *)parent completionBlock:(void(^)(UIActionSheet *actionSheet, NSInteger buttonIndex))completion;

@end
