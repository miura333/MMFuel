//
//  MFLBaseView.m
//  myFuel
//
//  Created by miura on 2014/10/22.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLBaseView.h"
#import "DefineAll.h"
#import "ARUTUtil.h"
#import "MFLCoreDataCtrl.h"
#import "MFLCDCars.h"
#import "MFLMainView.h"

#import "UIAlertView+NSCookBook.h"

@implementation MFLBaseView

- (void)prefButtonTapped:(id)sender {
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    _carsView = [[MFLCarsView alloc] initWithFrame:CGRectMake(0, height, width, height)];
    [self addSubview:_carsView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_carsView setFrame:CGRectMake(0, 0, width, height)];
    }completion:^(BOOL finished){
    }];
}

- (void)createPage:(MFLCDCars *)car index:(int)index {
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    MFLMainView *mainView = [[MFLMainView alloc] initWithFrame:CGRectMake(width*index, 0, width, height)];
    mainView.car_id = [car.car_id intValue];
    mainView.car_name = car.car_name;
    mainView.parent_view = self;
    
    [_scrollView addSubview:mainView];
    
    [mainView updateValues];
    
    [_array_cars addObject:mainView];
}

- (void)setupPages {
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    //車の登録をチェック。1台もなければ登録する
    NSArray *array_item = [ARUTUtil selectRecordArray:@"MFL_CARS" predicate:nil sortKeyName:@"car_id" limit:0];
    if(array_item == nil){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add" message:@"Please input your car name." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
            if (tf == nil || buttonIndex == 0) return;
            
            if([ARUTUtil isNSStringValid:tf.text] != YES) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Car name is empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [self setupPages];
                return;
            }
            
            [[MFLCoreDataCtrl sharedObject] addCar:tf.text];
            [self setupPages];
            return;
        }];
        
        return;
    }
    //配列クリア
    int i = 0;
    if([_array_cars count] > 0) {
        for(i = 0; i < [_array_cars count]; i++){
            MFLMainView *mainView = [_array_cars objectAtIndex:i];
            [mainView removeFromSuperview];
        }
        [_array_cars removeAllObjects];
    }
    
    //
    for(i = 0; i < [array_item count]; i++){
        MFLCDCars *car = [array_item objectAtIndex:i];
        [self createPage:car index:i];
    }
    
    NSUInteger pageCount = [array_item count];
    _pageCtrl.numberOfPages = pageCount;
    [_scrollView setContentSize:CGSizeMake(width*pageCount, height - 64 - 25)];
    
    MFLMainView *mainView = [_array_cars objectAtIndex:_pageCtrl.currentPage];
    [_label_name setText:mainView.car_name];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSInteger curPage = [defaults integerForKey:mflCurrentPageIndex];
    _pageCtrl.currentPage = curPage;
    [self pageCtrlPageChanged:nil];
    
}

- (void)setupHeader:(int)width {
    int headerHeight = ([ARUTUtil isVersionOver70] ? 64 : 44);
    int offset_y = ([ARUTUtil isVersionOver70] ? 20 : 0);
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, headerHeight)];
    [header setBackgroundColor:COLOR_HEADER];
    [self addSubview:header];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight-1, width, 1)];
    [line1 setBackgroundColor:COLOR_HEADER_BORDER];
    [self addSubview:line1];
    
    _label_name = [[UILabel alloc] initWithFrame:CGRectMake(60, offset_y, width-60*2, 44)];
    [_label_name setFont:[UIFont systemFontOfSize:18]];
    [_label_name setTextColor:[UIColor blackColor]];
    [_label_name setBackgroundColor:[UIColor clearColor]];
    [_label_name setTextAlignment:NSTextAlignmentCenter];
    [header addSubview:_label_name];
    
    UIButton *btn_pref = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_pref setFrame:CGRectMake(width-49, offset_y, 44, 44)];
    [btn_pref setImage:[UIImage imageNamed:@"mfl_btn_edit_car_normal"] forState:UIControlStateNormal];
    [btn_pref addTarget:self action:@selector(prefButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_pref];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults addObserver:self forKeyPath:mflCarsViewClosed options:0 context:nil];
        
        int width = 0, height = 0;
        [ARUTUtil getSubViewDimension:&width height:&height];
        
        [self setupHeader:width];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, width, height-64-25)];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        _pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, height-25, width, 25)];
        [_pageCtrl addTarget:self action:@selector(pageCtrlPageChanged:) forControlEvents:UIControlEventValueChanged];
        [_pageCtrl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [_pageCtrl setCurrentPageIndicatorTintColor:COLOR_HEADER_BORDER];
        [self addSubview:_pageCtrl];
        
        _array_cars = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self setupPages];
    }
    return self;
}

- (void)dealloc {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:mflCarsViewClosed];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    if([keyPath isEqualToString:mflCarsViewClosed] == YES) {
        
        [UIView animateWithDuration:0.3 animations:^{
            [_carsView setFrame:CGRectMake(0, height, width, height)];
        }completion:^(BOOL finished){
            [_carsView removeFromSuperview];
            [self setupPages];
        }];
    }
}

#pragma mark UIScrollViewDelegate
- (void)pageCtrlPageChanged:(id)sender {

    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * _pageCtrl.currentPage;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = _scrollView.frame.size.width;
    _pageCtrl.currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    MFLMainView *mainView = [_array_cars objectAtIndex:_pageCtrl.currentPage];
    [_label_name setText:mainView.car_name];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:_pageCtrl.currentPage forKey:mflCurrentPageIndex];
    [defaults synchronize];
}

@end
