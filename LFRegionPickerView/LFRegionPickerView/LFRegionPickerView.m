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

@property (strong, nonatomic) NSDictionary *mProvinceDict;
@property (strong, nonatomic) NSDictionary *mCityDict;
@property (strong, nonatomic) NSDictionary *mAreaDict;

@property (copy, nonatomic) NSString *mCurrentProvinceCode;
@property (copy, nonatomic) NSString *mCurrentCityCode;
@property (copy, nonatomic) NSString *mCurrentAreaCode;

@property (copy, nonatomic) NSString *mCurrentProvinceName;
@property (copy, nonatomic) NSString *mCurrentCityName;
@property (copy, nonatomic) NSString *mCurrentAreaName;

@property (assign, nonatomic) NSInteger lastSelectIndex1;
@property (assign, nonatomic) NSInteger lastSelectIndex2;
@property (assign, nonatomic) NSInteger lastSelectIndex3;

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
        regionPickerView.keepLastSelectedState = NO;
    });
    return regionPickerView;
}

-(void)showInView:(UIView *)superView result:(LFRegionResult)result {
    
    NSData *locationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"location" ofType:@"json"]];
    NSDictionary *locationDict = [NSJSONSerialization JSONObjectWithData:locationData options:NSJSONReadingAllowFragments error:nil];
    
    self.mProvinceDict = [locationDict objectForKey:@"province"];
    self.mCityDict = [locationDict objectForKey:@"city"];
    self.mAreaDict = [locationDict objectForKey:@"area"];
    self.result = result;
    
    if (self.keepLastSelectedState) {
        if (self.regionGrade == RegionGradeCity) {
            [self.mMainPickerView selectRow:self.lastSelectIndex2 inComponent:1 animated:NO];
        } else if (self.regionGrade == RegionGradeArea) {
            [self.mMainPickerView selectRow:self.lastSelectIndex2 inComponent:1 animated:NO];
            [self.mMainPickerView selectRow:self.lastSelectIndex3 inComponent:2 animated:NO];
        } else {
            [self.mMainPickerView selectRow:self.lastSelectIndex1 inComponent:0 animated:NO];
        }
    } else {
        self.mCurrentProvinceCode = self.mProvinceDict.allKeys[0];
        self.mCurrentProvinceName = [self.mProvinceDict objectForKey:self.mProvinceDict.allKeys[0]];
        self.mCurrentCityCode = [self.mCityDict objectForKey:self.mCurrentProvinceCode][0];
        self.mCurrentCityName = [self.mCityDict objectForKey:self.mCurrentProvinceCode][1];
        self.mCurrentAreaCode = [self.mAreaDict objectForKey:self.mCurrentCityCode][0];
        self.mCurrentAreaName = [self.mAreaDict objectForKey:self.mCurrentCityCode][1];
    }
    
    
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
    
    [self addSubview:self.mCancelBtn];
    [self addSubview:self.mBottomGapView];
    [self addSubview:self.mOkBtn];
    [self addSubview:self.mMainPickerView];
    [self addSubview:self.mTopGapView];
    [superView addSubview:self];
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
        return self.mProvinceDict.allKeys.count;
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
        NSString *key = self.mProvinceDict.allKeys[row];
        title = [self.mProvinceDict objectForKey:key];
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
        self.lastSelectIndex1 = row;
        self.mCurrentProvinceCode = self.mProvinceDict.allKeys[row];
        self.mCurrentProvinceName = [self.mProvinceDict objectForKey:self.mCurrentProvinceCode];
        
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
        self.lastSelectIndex2 = row;
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
        self.lastSelectIndex3 = row;
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
    
    [self removeFromSuperview];
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

-(NSDictionary *)mProvinceDict {
    if (_mProvinceDict == nil) {
        _mProvinceDict = [[NSDictionary alloc] init];
    }
    return _mProvinceDict;
}

-(NSDictionary *)mCityDict {
    if (_mCityDict == nil) {
        _mCityDict = [[NSDictionary alloc] init];
    }
    return _mCityDict;
}

-(NSDictionary *)mAreaDict {
    if (_mAreaDict == nil) {
        _mAreaDict = [[NSDictionary alloc] init];
    }
    return _mAreaDict;
}
@end
