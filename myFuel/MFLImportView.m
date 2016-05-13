//
//  MFLImportView.m
//  myFuel
//
//  Created by miura on 2014/10/22.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "MFLImportView.h"
#import "ARUTUtil.h"
#import "DefineAll.h"
#import "UIAlertView+NSCookBook.h"

#import "MFLCoreDataCtrl.h"

@implementation MFLImportView

- (void)backButtonTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:mflImportViewClosed];
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
    [label1 setText:@"Import"];
    [header addSubview:label1];
    
    UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setFrame:CGRectMake(0, offset_y, 44, 44)];
    [btn_back setImage:[UIImage imageNamed:@"00-btn_close"] forState:UIControlStateNormal];
    [btn_back addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn_back];
}

- (void)showNoFileError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Data" message:@"Please send files from iTunes>App>File Sharing connecting your iPhone to PC/Mac." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)updateTableView {
    NSString *rootDir = [ARUTUtil getDocumentDirPath];
    NSError *err1;
    NSArray *array_files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootDir error:&err1];	//子フォルダまで検索しない。enumeratorAtPathだと子フォルダまで対象となる。
    if(array_files == nil || [array_files count] == 0) {
        [self showNoFileError];
        return;
    }

    [_array_files removeAllObjects];
    
    // ファイル名を次々に取り出す
    NSString *file;
    int cnt = 0;
    for(file in array_files){
        NSString *ext = [file pathExtension];
        if([ext caseInsensitiveCompare:@"csv"] != NSOrderedSame) continue;
        
        NSString *filePath = [rootDir stringByAppendingPathComponent:file];
        [_array_files addObject:filePath];
        
        cnt++;
    }
    
    if(cnt == 0) {
        [self showNoFileError];
        return;
    }
    
    [_tableView reloadData];
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
        
        _array_files = [[NSMutableArray alloc] initWithCapacity:1];
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
    return [_array_files count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PREF_CELL_HEIGHT_2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"importViewCell";
    
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    UILabel *label_file_name;
    UIView *baseView;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, PREF_CELL_HEIGHT_2)];
        [baseView setBackgroundColor:[UIColor whiteColor]];
        baseView.tag = 0;
        [cell.contentView addSubview:baseView];
        
        label_file_name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-20, PREF_CELL_HEIGHT_2)];
        label_file_name.font = [UIFont systemFontOfSize:16];
        [label_file_name setTextColor:COLOR_HEADER_BORDER];
        [label_file_name setBackgroundColor:[UIColor clearColor]];
        label_file_name.tag = 1;
        [baseView addSubview:label_file_name];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, PREF_CELL_HEIGHT_2-1, width, 1)];
        [line1 setBackgroundColor:COLOR_HEADER_BORDER];
        [baseView addSubview:line1];
    }else{
        baseView = [cell.contentView viewWithTag:0];
        label_file_name = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:1];
        
    }
    
    NSString *filePath = [_array_files objectAtIndex:indexPath.row];
    [label_file_name setText:[filePath lastPathComponent]];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Would you like to import this file?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) return;
        
        NSString *filePath = [_array_files objectAtIndex:indexPath.row];
        NSData *csvData = [NSData dataWithContentsOfFile:filePath];
        NSString *csv = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
        
        NSScanner *scanner = [NSScanner scannerWithString:csv];
        // 改行文字の選定
        NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
        NSString *line;
        
        int i = 0;
        
        for(i = 0; ![scanner isAtEnd]; i++) {
            // 一行づつ読み込んでいく
            [scanner scanUpToCharactersFromSet:chSet intoString:&line];
            NSArray *array = [line componentsSeparatedByString:@","];
            
            if(i > 0){
                [[MFLCoreDataCtrl sharedObject] addRecordFromCSV:_car_id csvArray:array];
            }
            
            // 改行文字をスキップ
            [scanner scanCharactersFromSet:chSet intoString:NULL];
        }
        
    }];
}

@end
