//
//  LFRegionPickerView.m
//  LFRegionPickerView
//
//  Created by archerLj on 2018/3/7.
//  Copyright © 2018年 com.bocodo.csr. All rights reserved.
//

#import "LFRegionPickerView.h"

#define MAINSCREEN_W [UIScreen mainScreen].bounds.size.width
#define MAINSCREEN_H [UIScreen mainScreen].bounds.size.height
@interface LFRegionPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) UIView *mTopGapView;
@property (strong, nonatomic) UIView *mBottomGapView;
@property (strong, nonatomic) UIPickerView *mMainPickerView;
@property (strong, nonatomic) UIButton *mCancelBtn;
@property (strong, nonatomic) UIButton *mOkBtn;

@property (strong, nonatomic) NSMutableArray *mProvinceArr;
@property (strong, nonatomic) NSMutableDictionary *mCityDict;
@property (strong, nonatomic) NSMutableDictionary *mAreaDict;

@property (copy, nonatomic) NSString *mCurrentProvinceCode;
@property (copy, nonatomic) NSString *mCurrentCityCode;
@property (copy, nonatomic) NSString *mCurrentAreaCode;

@property (copy, nonatomic) NSString *mCurrentProvinceName;
@property (copy, nonatomic) NSString *mCurrentCityName;
@property (copy, nonatomic) NSString *mCurrentAreaName;

@property (copy, nonatomic) LFRegionResult result;
@end

@implementation LFRegionPickerView

+(instancetype)shared {
    static dispatch_once_t onceToken;
    static LFRegionPickerView *regionPickerView;
    dispatch_once(&onceToken, ^{
        regionPickerView = [[LFRegionPickerView alloc] initWithFrame:CGRectZero];
        regionPickerView.buttonPosition = ButtonPositionBottom;
        regionPickerView.pickerTitleColor = [UIColor blackColor];
        regionPickerView.gapLineColor = [UIColor lightGrayColor];
        regionPickerView.cancelTitleColor = [UIColor grayColor];
        regionPickerView.okTitleColor = [UIColor blackColor];
        regionPickerView.regionGrade = RegionGradeArea;
        regionPickerView.buttonHeight = 44.0;
        regionPickerView.height = 250.0;
        
        NSData *locationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"location" ofType:@"json"]];
        NSDictionary *locationDict = [NSJSONSerialization JSONObjectWithData:locationData options:NSJSONReadingAllowFragments error:nil];
        
        NSDictionary *provinceDict = [locationDict objectForKey:@"province"];
        for (NSString *key in provinceDict) {
            [regionPickerView.mProvinceArr addObject:@[key, [provinceDict objectForKey:key]]];
        }
        
        regionPickerView.mCityDict = [[locationDict objectForKey:@"city"] mutableCopy];
        regionPickerView.mAreaDict = [[locationDict objectForKey:@"area"] mutableCopy];
        
        [regionPickerView addSubview:regionPickerView.mCancelBtn];
        [regionPickerView addSubview:regionPickerView.mBottomGapView];
        [regionPickerView addSubview:regionPickerView.mOkBtn];
        [regionPickerView addSubview:regionPickerView.mMainPickerView];
        [regionPickerView addSubview:regionPickerView.mTopGapView];
    });
    return regionPickerView;
}

-(void)showInView:(UIView *)superView result:(LFRegionResult)result {
    
    [self viewInit];
    self.result = result;
    [self pickerViewSetting];
    [superView addSubview:self];
}

-(void)viewInit {
    
    self.frame = CGRectMake(0, MAINSCREEN_H - self.height, MAINSCREEN_W, self.height);
    self.mTopGapView.frame = CGRectMake(0, 0, MAINSCREEN_W, 1.0);
    // 根据ButtonPosition的位置来重新布局
    if (self.buttonPosition == ButtonPositionTop) {
        self.mCancelBtn.frame = CGRectMake(0, 1.0, 100.0, self.buttonHeight);
        self.mOkBtn.frame = CGRectMake(self.bounds.size.width - 100.0, 1.0, 100.0, self.buttonHeight);
        self.mBottomGapView.frame = CGRectMake(0,self.mOkBtn.bounds.size.height + 1.0,MAINSCREEN_W,1.0);
        self.mMainPickerView.frame = CGRectMake(0,1.0 * 2 + self.mOkBtn.bounds.size.height, MAINSCREEN_W,self.bounds.size.height - self.mOkBtn.bounds.size.height-1.0*2);
        
    } else {
        self.mOkBtn.frame = CGRectMake(self.bounds.size.width - 100.0, self.bounds.size.height - self.buttonHeight, 100.0, self.buttonHeight);
        self.mCancelBtn.frame = CGRectMake(0, self.bounds.size.height - self.buttonHeight, 100.0, self.buttonHeight);
        self.mBottomGapView.frame = CGRectMake(0, self.bounds.size.height - self.mOkBtn.bounds.size.height, MAINSCREEN_W, 1.0);
        self.mMainPickerView.frame = CGRectMake(0, 1.0, MAINSCREEN_W, self.bounds.size.height - self.mOkBtn.bounds.size.height-1.0*2);
    }
}

-(void)pickerViewSetting {
    
    if (self.showAll) {
        [self.mProvinceArr insertObject:@[@"000000", @"全部"] atIndex:0];
        for (NSString *key in self.mCityDict.allKeys) {
            NSMutableArray *citys = [[self.mCityDict objectForKey:key] mutableCopy];
            [citys insertObject:@[@"000000", @"全部"] atIndex:0];
            [self.mCityDict setObject:citys forKey:key];
        }
        for (NSString *key in self.mAreaDict.allKeys) {
            NSMutableArray *areas = [[self.mAreaDict objectForKey:key] mutableCopy];
            [areas insertObject:@[@"000000", @"全部"] atIndex:0];
            [self.mAreaDict setObject:areas forKey:key];
        }
    }
    
    if (self.currentRegionCode == nil && self.currentRegionName == nil) {
        self.currentRegionName = @"山东省/济南市/历下区";
        self.currentRegionCode = @"370000/370100/370102";
    }
    
    // 滚动到指定位置
    if (self.currentRegionCode != nil) {
        NSArray *regionCodes = [self.currentRegionCode componentsSeparatedByString:@"/"];
        if (regionCodes.count >= 1) { // 滚动到对应的省
            self.mCurrentProvinceCode = [regionCodes objectAtIndex:0];
            for (int i=0; i<self.mProvinceArr.count; i++) {
                NSArray *province = self.mProvinceArr[i];
                if ([province[0] isEqualToString:self.mCurrentProvinceCode]) {
                    self.mCurrentProvinceName = province[1];
                    [self.mMainPickerView selectRow:i inComponent:0 animated:YES];
                    [self.mMainPickerView reloadAllComponents];
                    break;
                }
            }
            
            
            if (self.regionGrade == RegionGradeCity || self.regionGrade == RegionGradeArea) { // 如果显示到市级或县级
                if (regionCodes.count >= 2) { // 滚动到对应的市/区
                    self.mCurrentCityCode = [regionCodes objectAtIndex:1];
                    NSArray *citys = [self.mCityDict objectForKey:self.mCurrentProvinceCode];
                    
                    for (int i=0; i<citys.count; i++) {
                        if ([citys[i][0] isEqualToString:self.mCurrentCityCode]) {
                            self.mCurrentCityName = citys[i][1];
                            [self.mMainPickerView selectRow:i inComponent:1 animated:YES];
                            [self.mMainPickerView reloadAllComponents];
                            break;
                        }
                    }
                    
                    if (self.regionGrade == RegionGradeArea) { // 如果显示到县级
                        if (regionCodes.count == 3) { // 滚动到对应的县/区
                            self.mCurrentAreaCode = [regionCodes objectAtIndex:2];
                            NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
                            
                            for (int i = 0; i < areas.count; i++) {
                                if ([areas[i][0] isEqualToString:self.mCurrentAreaCode]) {
                                    self.mCurrentAreaName = areas[i][1];
                                    [self.mMainPickerView selectRow:i inComponent:2 animated:YES];
                                    [self.mMainPickerView reloadAllComponents];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        
    } else {
        NSArray *regionNames = [self.currentRegionName componentsSeparatedByString:@"/"];
        if (regionNames.count >= 1) { // 滚动到对应的省
            self.mCurrentProvinceName = [regionNames objectAtIndex:0];
            for (int i=0; i < self.mProvinceArr.count; i++) {
                NSArray *province = self.mProvinceArr[i];
                if ([province[1] isEqualToString:self.mCurrentProvinceName]) {
                    self.mCurrentProvinceCode = province[0];
                    [self.mMainPickerView selectRow:i inComponent:0 animated:NO];
                    [self.mMainPickerView reloadAllComponents];
                    break;
                }
            }
            
            if (self.regionGrade == RegionGradeCity || self.regionGrade == RegionGradeArea) { // 如果显示到市级或县级
                if (regionNames.count >= 2) { // 滚动到对应的市/区
                    self.mCurrentCityName = [regionNames objectAtIndex:1];
                    NSArray *citys = [self.mCityDict objectForKey:self.mCurrentProvinceCode];
                    
                    for (int i=0; i<citys.count; i++) {
                        if ([citys[i][1] isEqualToString:self.mCurrentCityName]) {
                            self.mCurrentCityCode = citys[i][0];
                            [self.mMainPickerView selectRow:i inComponent:1 animated:NO];
                            [self.mMainPickerView reloadAllComponents];
                            break;
                        }
                    }
                    
                    if (self.regionGrade == RegionGradeArea) { // 如果显示到县级
                        if (regionNames.count == 3) { // 滚动到对应的县/区
                            self.mCurrentAreaName = [regionNames objectAtIndex:2];
                            NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
                            
                            for (int i = 0; i < areas.count; i++) {
                                if ([areas[i][1] isEqualToString:self.mCurrentAreaName]) {
                                    self.mCurrentAreaCode = areas[i][0];
                                    [self.mMainPickerView selectRow:i inComponent:2 animated:NO];
                                    [self.mMainPickerView reloadAllComponents];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/******************************************************************/
//             UIPickeriewDelegate && UIPickerViewDataSource
/******************************************************************/
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.regionGrade == RegionGradeArea) {
        return 3;
    }
    if (self.regionGrade == RegionGradeCity) {
        return 2;
    }
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) { // 省/直辖市/特别行政区/自治区等
        return self.mProvinceArr.count;
    } else if (component == 1) { // 市/区
        NSArray *citys = [self.mCityDict objectForKey:self.mCurrentProvinceCode];
        return citys.count;
    } else {
        NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
        return areas.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.regionGrade == RegionGradeProvince) {
        return self.bounds.size.width;
    } else if (self.regionGrade == RegionGradeCity) {
        return self.bounds.size.width / 2;
    } else {
        return self.bounds.size.width / 3;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44.0;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = @"";
    if (component == 0) {
        title = self.mProvinceArr[row][1];
    } else if (component == 1) {
        NSArray *citys = [self.mCityDict objectForKey:self.mCurrentProvinceCode];
        NSArray *city = citys[row];
        title = city[1];
    } else {
        NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
        NSArray *area = areas[row];
        title = area[1];
    }
    
    if (title == nil) {
        return nil;
    }
    
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: self.pickerTitleColor, NSFontAttributeName: [UIFont systemFontOfSize:12.0]}];
    return attrTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        
        self.mCurrentProvinceCode = self.mProvinceArr[row][0];
        self.mCurrentProvinceName = self.mProvinceArr[row][1];
        
        NSArray *citys = [self.mCityDict objectForKey:self.mCurrentProvinceCode];
        NSArray *city = citys[0];
        self.mCurrentCityCode = city[0];
        self.mCurrentCityName = city[1];
        
        NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
        NSArray *area = areas[0];
        self.mCurrentAreaCode = area[0];
        self.mCurrentAreaName = area[1];
        
        if (self.regionGrade == RegionGradeCity) {
            [pickerView selectRow:0 inComponent:1 animated:NO];
        } else if (self.regionGrade == RegionGradeArea) {
            [pickerView selectRow:0 inComponent:1 animated:NO];
            [pickerView selectRow:0 inComponent:2 animated:NO];
        }
        
    } else if (component == 1) {
        
        NSArray *citys = [self.mCityDict objectForKey:self.mCurrentProvinceCode];
        NSArray *city = citys[row];
        self.mCurrentCityCode = city[0];
        self.mCurrentCityName = city[1];
        
        NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
        NSArray *area = areas[0];
        self.mCurrentAreaCode = area[0];
        self.mCurrentAreaName = area[1];
        
        if (self.regionGrade == RegionGradeArea) {
            [pickerView selectRow:0 inComponent:2 animated:NO];
        }
        
    } else {
        
        NSArray *areas = [self.mAreaDict objectForKey:self.mCurrentCityCode];
        NSArray *area = areas[row];
        self.mCurrentAreaCode = area[0];
        self.mCurrentAreaName = area[1];
    }
    
    [pickerView reloadAllComponents];
}



/******************************************************************/
//             Button Actions
/******************************************************************/
-(void)cancelAction {
    [self clearData];
    [self removeFromSuperview];
}

-(void)okAction {
    
    if (self.mCurrentProvinceCode == nil) {
        self.mCurrentProvinceCode = @"";
        self.mCurrentProvinceName = @"";
    }
    
    if (self.mCurrentCityCode == nil) {
        self.mCurrentCityCode = @"";
        self.mCurrentCityName = @"";
    }
    
    if (self.mCurrentAreaCode == nil) {
        self.mCurrentAreaCode = @"";
        self.mCurrentAreaName = @"";
    }
    
    if (self.regionGrade == RegionGradeProvince) {
        self.result(self.mCurrentProvinceName, self.mCurrentProvinceCode);
    } else if (self.regionGrade == RegionGradeCity) {
        self.result([NSString stringWithFormat:@"%@/%@", self.mCurrentProvinceName, self.mCurrentCityName], [NSString stringWithFormat:@"%@/%@", self.mCurrentProvinceCode, self.mCurrentCityCode]);
    } else {
        self.result([NSString stringWithFormat:@"%@/%@/%@", self.mCurrentProvinceName, self.mCurrentCityName, self.mCurrentAreaName], [NSString stringWithFormat:@"%@/%@/%@", self.mCurrentProvinceCode, self.mCurrentCityCode, self.mCurrentAreaCode]);
    }
    
    [self clearData];
    [self removeFromSuperview];
}

-(void)clearData {
    self.mCurrentProvinceCode = nil;
    self.mCurrentProvinceName = nil;
    self.mCurrentCityCode = nil;
    self.mCurrentCityName = nil;
    self.mCurrentAreaCode = nil;
    self.mCurrentAreaName = nil;
    
    if (self.showAll) {
        [self.mProvinceArr removeObjectAtIndex:0];
        
        for (NSString *key in self.mCityDict.allKeys) {
            NSMutableArray *citys = [[self.mCityDict objectForKey:key] mutableCopy];
            [citys removeObjectAtIndex:0];
            [self.mCityDict setObject:citys forKey:key];
        }
        for (NSString *key in self.mAreaDict.allKeys) {
            NSMutableArray *areas = [[self.mAreaDict objectForKey:key] mutableCopy];
            [areas removeObjectAtIndex:0];
            [self.mAreaDict setObject:areas forKey:key];
        }
    }
}


/******************************************************************/
//             Setter && Getter
/******************************************************************/
-(UIView *)mTopGapView {
    if (_mTopGapView == nil) {
        _mTopGapView = [[UIView alloc] initWithFrame:CGRectZero];
        [_mTopGapView setBackgroundColor:self.gapLineColor];
    }
    return _mTopGapView;
}

-(UIView *)mBottomGapView {
    if (_mBottomGapView == nil) {
        _mBottomGapView = [[UIView alloc] initWithFrame:CGRectZero];
        [_mBottomGapView setBackgroundColor:self.gapLineColor];
    }
    return _mBottomGapView;
}

-(UIPickerView *)mMainPickerView {
    if (_mMainPickerView == nil) {
        _mMainPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        _mMainPickerView.dataSource = self;
        _mMainPickerView.delegate = self;
    }
    return _mMainPickerView;
}

-(UIButton *)mOkBtn {
    if (_mOkBtn == nil) {
        _mOkBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_mOkBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_mOkBtn setTitleColor:self.okTitleColor forState:UIControlStateNormal];
        [_mOkBtn addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mOkBtn;
}

-(UIButton *)mCancelBtn {
    if (_mCancelBtn == nil) {
        _mCancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_mCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_mCancelBtn setTitleColor:self.cancelTitleColor forState:UIControlStateNormal];
        [_mCancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mCancelBtn;
}

-(NSMutableArray *)mProvinceArr {
    if (_mProvinceArr == nil) {
        _mProvinceArr = [[NSMutableArray alloc] init];
    }
    return _mProvinceArr;
}

-(NSMutableDictionary *)mCityDict {
    if (_mCityDict == nil) {
        _mCityDict = [[NSMutableDictionary alloc] init];
    }
    return _mCityDict;
}

-(NSMutableDictionary *)mAreaDict {
    if (_mAreaDict == nil) {
        _mAreaDict = [[NSMutableDictionary alloc] init];
    }
    return _mAreaDict;
}
@end

