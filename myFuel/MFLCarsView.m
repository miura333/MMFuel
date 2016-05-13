//
//  MFLCarsView.m
//  myFuel
//
//  Created by miura on 2014/10/22.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLCarsView.h"
#import "DefineAll.h"
#import "ARUTUtil.h"
#import "MFLCDCars.h"

#import "MFLCoreDataCtrl.h"
#import "UIAlertView+NSCookBook.h"

@implementation MFLCarsView

- (void)createAddCell {
    _cell_add = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"carAddCell"];
    
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, PREF_CELL_HEIGHT_2)];
    [baseView setBackgroundColor:[UIColor whiteColor]];
    baseView.tag = 0;
    [_cell_add.contentView addSubview:baseView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, PREF_CELL_HEIGHT_2)];
    label1.font = [UIFont systemFontOfSize:16];
    [label1 setTextColor:COLOR_HEADER_BORDER];
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Add New Car"];
    label1.tag = 1;
    [baseView addSubview:label1];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, PREF_CELL_HEIGHT_2-1, width, 1)];
    [line1 setBackgroundColor:COLOR_HEADER_BORDER];
    [baseView addSubview:line1];
}

- (void)backButtonTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:mflCarsViewClosed];
    [defaults synchronize];
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
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(60, offset_y, 200, 44)];
    [label1 setFont:[UIFont systemFontOfSize:18]];
    [label1 setTextColor:[UIColor blackColor]];
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Cars"];
    [header addSubview:label1];
    
    UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setFrame:CGRectMake(0, offset_y, 44, 44)];
    [btn_back setImage:[UIImage imageNamed:@"00-btn_close"] forState:UIControlStateNormal];
    [btn_back addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_back];
    
}

- (void)updateTableView {
    [_array_cars removeAllObjects];
    
    NSArray *array_item = [ARUTUtil selectRecordArray:@"MFL_CARS" predicate:nil sortKeyName:@"car_id" limit:0];
    if(array_item != nil){
        _array_cars = [array_item mutableCopy];
        [_tableView reloadData];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int width = 0, height = 0;
        [ARUTUtil getSubViewDimension:&width height:&height];
        
        [self setupHeader:width];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, width, height - 64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        [self createAddCell];
        
        _array_cars = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self updateTableView];
    }
    return self;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_cars count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PREF_CELL_HEIGHT_2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [_array_cars count]){
        return _cell_add;
    }
    
    static NSString *CellIdentifier = @"carsViewCell";
    
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    UILabel *label_car_name;
    UIView *baseView;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, PREF_CELL_HEIGHT_2)];
        [baseView setBackgroundColor:[UIColor whiteColor]];
        baseView.tag = 0;
        [cell.contentView addSubview:baseView];
        
        label_car_name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-20, PREF_CELL_HEIGHT_2)];
        label_car_name.font = [UIFont systemFontOfSize:16];
        [label_car_name setTextColor:COLOR_HEADER_BORDER];
        [label_car_name setBackgroundColor:[UIColor clearColor]];
        label_car_name.tag = 1;
        [baseView addSubview:label_car_name];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, PREF_CELL_HEIGHT_2-1, width, 1)];
        [line1 setBackgroundColor:COLOR_HEADER_BORDER];
        [baseView addSubview:line1];
    }else{
        baseView = [cell.contentView viewWithTag:0];
        label_car_name = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:1];
        
    }
    
    MFLCDCars *car = [_array_cars objectAtIndex:indexPath.row];
    [label_car_name setText:car.car_name];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.row == [_array_cars count]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add" message:@"Please input your car name." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
            if (tf == nil || buttonIndex == 0) return;
            
            if([ARUTUtil isNSStringValid:tf.text] != YES) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Car name is empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            [[MFLCoreDataCtrl sharedObject] addCar:tf.text];
            [self updateTableView];
        }];
    }
}

@end
