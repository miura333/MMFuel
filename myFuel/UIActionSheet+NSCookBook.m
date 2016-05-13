//
//  UIActionSheet+NSCookBook.m
//  q
//
//  Created by miura on 2014/02/25.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import <objc/runtime.h>
#import "UIActionSheet+NSCookBook.h"

@interface NSCBActionsheetWrapper : NSObject <UIActionSheetDelegate>

@property (copy) void(^completionBlock)(UIActionSheet *actionSheet, NSInteger buttonIndex);

@end

@implementation NSCBActionsheetWrapper

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock)
        self.completionBlock(actionSheet, buttonIndex);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    // Just simulate a cancel button click
    if (self.completionBlock)
        self.completionBlock(actionSheet, actionSheet.cancelButtonIndex);
}

@end

static const char kNSCBActionsheetWrapper;
@implementation UIActionSheet(NSCookBook)

- (void)showWithCompletion:(UIView *)parent completionBlock:(void(^)(UIActionSheet *actionSheet, NSInteger buttonIndex))completion
{
    NSCBActionsheetWrapper *actionsheetWrapper = [[NSCBActionsheetWrapper alloc] init];
    actionsheetWrapper.completionBlock = completion;
    self.delegate = actionsheetWrapper;
    
    // Set the wrapper as an associated object
    objc_setAssociatedObject(self, &kNSCBActionsheetWrapper, actionsheetWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Show the alert as normal
    [self showInView:parent];
}


@end
