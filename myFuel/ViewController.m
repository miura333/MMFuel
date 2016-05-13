//
//  ViewController.m
//  myFuel
//
//  Created by miura on 2014/10/20.
//  Copyright (c) 2014年 miura. All rights reserved.
//

#import "ViewController.h"
#import "MFLBaseView.h"
#import "ARUTUtil.h"
#import "DefineAll.h"
#import "MFLCDFuelRecord.h"

@interface ViewController ()

@end

@implementation ViewController

- (NSData *)createCSVData {
    NSString *car_id_str = [[NSUserDefaults standardUserDefaults] objectForKey:mflMailViewRequired];
    int car_id = [car_id_str intValue];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"car_id == %d", car_id];
    NSArray *array_item = [ARUTUtil selectRecordArray:@"MFL_FUEL_RECORD" predicate:pred sortKeyName:@"date" limit:0];
    if(array_item != nil){
        NSString *str = @"日付、走行距離計、走行距離計の単位、給油量、給油量の単位、価格、燃費、燃費の単位,非満タン給油\n";
        
        int i = 0;
        for(i = 0; i < [array_item count]; i++){
            MFLCDFuelRecord *record = [array_item objectAtIndex:i];
            
            NSString *str1 = [NSString stringWithFormat:@"%@,%.3f,km,%.3f,L,%.3f,%.3f,km/L,0\n", [ARUTUtil convDate2StringExport:record.date], [record.trip doubleValue], [record.fuel doubleValue], [record.price_of_fuel doubleValue], [record.fuel_rate doubleValue]];
            str = [str stringByAppendingString:str1];
        }
        return [str dataUsingEncoding:NSShiftJISStringEncoding];
    }
    
    return nil;
}

- (void)openMailComposer {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    picker.mailComposeDelegate = self;
    //20111020 miura mod
    NSData *data = [self createCSVData];
    if(data == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [picker addAttachmentData:data mimeType:@"text/plain" fileName:@"hoge.csv"];
    
    [self presentViewController:picker animated:YES completion:^(void) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:mflMailViewRequired options:0 context:nil];
    
    int width = 0, height = 0;
    [ARUTUtil getSubViewDimension:&width height:&height];
    
    MFLBaseView *mainView = [[MFLBaseView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:mainView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:mflMailViewRequired];
}

#pragma mark mailComposeDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:mflMailViewRequired] == YES) {
        [self openMailComposer];
    }
}

@end
