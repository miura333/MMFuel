//
//  MFLHistoryView.m
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLHistoryView.h"
#import "ARUTUtil.h"
#import "DefineAll.h"
#import "AppDelegate.h"
#import "MFLCDFuelRecord.h"

#import "UIActionSheet+NSCookBook.h"

@interface MFLHistoryView ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MFLHistoryView

- (void)showImportView {
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    _importView = [[MFLImportView alloc] initWithFrame:CGRectMake(0, height, width, height)];
    _importView.car_id = _car_id;
    [self addSubview:_importView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_importView setFrame:CGRectMake(0, 0, width, height)];
    }completion:^(BOOL finished){
    }];
}

- (void)actionButtonTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"File"
                                                             delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Import", @"Export", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showWithCompletion:self completionBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        if (buttonIndex == 0) {
            //import
            [self performSelectorOnMainThread:@selector(showImportView) withObject:nil waitUntilDone:NO];
            
        }else if (buttonIndex == 1) {
            //export
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSString stringWithFormat:@"%d", _car_id] forKey:mflMailViewRequired];
            [defaults synchronize];
        }else{
            
        }
    }];
}

- (void)backButtonTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:mflHistoryViewClosed];
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
    [label1 setText:@"History"];
    [header addSubview:label1];
    
    UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setFrame:CGRectMake(0, offset_y, 44, 44)];
    [btn_back setImage:[UIImage imageNamed:@"00-btn_arrow"] forState:UIControlStateNormal];
    [btn_back addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_back];
    
    UIButton *btn_action = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_action setFrame:CGRectMake(width-49, offset_y, 44, 44)];
    [btn_action setImage:[UIImage imageNamed:@"mfl_btn_import_export"] forState:UIControlStateNormal];
    [btn_action addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_action];
    
}

- (void)initializeView:(int)car_id {
    _car_id = car_id;
    
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, width, height - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];
    
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
        [_tableView reloadData];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults addObserver:self forKeyPath:mflImportViewClosed options:0 context:nil];
        
        int width = 0, height = 0;
        [ARUTUtil getSubViewDimension:&width height:&height];
        
        [self setupHeader:width];
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)dealloc {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:mflImportViewClosed];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    if ([keyPath isEqualToString:mflImportViewClosed] == YES) {
        [UIView animateWithDuration:0.3 animations:^{
            [_importView setFrame:CGRectMake(0, height, width, height)];
        }completion:^(BOOL finished){
            [_importView removeFromSuperview];
            
            NSError *error;
            if ([self.fetchedResultsController performFetch:&error]) {
                [_tableView reloadData];
            }
        }];
    }
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PREF_CELL_HEIGHT;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"mtkCell";
    
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    UILabel *label_date;
    UILabel *label_fuel_rate;
    UILabel *label_trip;
    UILabel *label_fuel;
    UILabel *label_price;
    UIView *baseView;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, PREF_CELL_HEIGHT)];
        [baseView setBackgroundColor:[UIColor whiteColor]];
        baseView.tag = 0;
        [cell.contentView addSubview:baseView];
        
        label_date = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 50)];
        label_date.font = [UIFont systemFontOfSize:20];
        [label_date setTextColor:COLOR_HEADER_BORDER];
        [label_date setBackgroundColor:[UIColor clearColor]];
        label_date.tag = 1;
        [baseView addSubview:label_date];
        
        label_fuel_rate = [[UILabel alloc] initWithFrame:CGRectMake(width - 200, 5, 170, 50)];
        label_fuel_rate.font = [UIFont systemFontOfSize:20];
        [label_fuel_rate setTextColor:COLOR_HEADER_BORDER];
        [label_fuel_rate setBackgroundColor:[UIColor clearColor]];
        [label_fuel_rate setTextAlignment:NSTextAlignmentRight];
        label_fuel_rate.tag = 2;
        [baseView addSubview:label_fuel_rate];
        
        label_trip = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 100, PREF_CELL_HEIGHT-50)];
        label_trip.font = [UIFont systemFontOfSize:12];
        [label_trip setTextColor:[UIColor lightGrayColor]];
        [label_trip setBackgroundColor:[UIColor clearColor]];
        label_trip.tag = 3;
        [baseView addSubview:label_trip];
        
        label_fuel = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 100, PREF_CELL_HEIGHT-50)];
        label_fuel.font = [UIFont systemFontOfSize:12];
        [label_fuel setTextColor:[UIColor lightGrayColor]];
        [label_fuel setBackgroundColor:[UIColor clearColor]];
        label_fuel.tag = 4;
        [baseView addSubview:label_fuel];
        
        label_price = [[UILabel alloc] initWithFrame:CGRectMake(210, 50, 100, PREF_CELL_HEIGHT-50)];
        label_price.font = [UIFont systemFontOfSize:12];
        [label_price setTextColor:[UIColor lightGrayColor]];
        [label_price setBackgroundColor:[UIColor clearColor]];
        label_price.tag = 5;
        [baseView addSubview:label_price];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, PREF_CELL_HEIGHT-1, width, 1)];
        [line1 setBackgroundColor:COLOR_HEADER_BORDER];
        [baseView addSubview:line1];
        
    }else{
        baseView = [cell.contentView viewWithTag:0];
        label_date = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:1];
        label_fuel_rate = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        label_trip = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        label_fuel = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:4];
        label_price = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:5];
    }
    
    MFLCDFuelRecord *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [label_date setText:[ARUTUtil convDate2String:history.date]];
    [label_fuel_rate setText:[NSString stringWithFormat:@"%.3f km/l", [history.fuel_rate doubleValue]]];
    [label_trip setText:[NSString stringWithFormat:@"%.1f km", [history.trip doubleValue]]];
    [label_fuel setText:[NSString stringWithFormat:@"%.1f liters", [history.fuel doubleValue]]];
    [label_price setText:[NSString stringWithFormat:@"%.1f yen/l", [history.price_of_fuel doubleValue]]];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MFL_FUEL_RECORD" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"car_id == %d", _car_id];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Sort using the timeStamp property.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"record_id" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"date_section" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor,sortDescriptor2]];
    
    // Use the sectionIdentifier property to group into sections.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"date_section" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
