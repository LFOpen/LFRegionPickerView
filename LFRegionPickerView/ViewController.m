//
//  ViewController.m
//  LFRegionPickerView
//
//  Created by archerLj on 2018/3/7.
//  Copyright © 2018年 com.bocodo.csr. All rights reserved.
//

#import "ViewController.h"
#import "LFRegionPickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [LFRegionPickerView shared].buttonPosition = ButtonPositionBottom;
//    [LFRegionPickerView shared].pickerTitleColor = [UIColor greenColor];
//    [LFRegionPickerView shared].gapLineColor = [UIColor redColor];
//    [LFRegionPickerView shared].okTitleColor = [UIColor blueColor];
//    [LFRegionPickerView shared].cancelTitleColor = [UIColor redColor];
//    [LFRegionPickerView shared].keepLastSelectedState = YES;
//    [LFRegionPickerView shared].buttonHeight = 44.0;
//    [LFRegionPickerView shared].height = 250.0;
//    [LFRegionPickerView shared].regionGrade = RegionGradeArea;
//    [LFRegionPickerView shared].buttonPosition = ButtonPositionTop;
//    [LFRegionPickerView shared].currentRegionName = @"";
    [LFRegionPickerView shared].currentRegionName = @"山东省/济南市/历下区";
    [LFRegionPickerView shared].showAllBeforeArea = YES;
    [LFRegionPickerView shared].showAllBeforeCity = YES;
    [LFRegionPickerView shared].showAllBeforeProvince = YES;
    [[LFRegionPickerView shared] showInView:self.view result:^(NSArray *regionNames, NSArray *regionCodes) {
        
        NSLog(@"%@", [regionNames componentsJoinedByString:@"/"]);
        NSLog(@"%@", [regionCodes componentsJoinedByString:@"/"]);
    }];
}


@end
