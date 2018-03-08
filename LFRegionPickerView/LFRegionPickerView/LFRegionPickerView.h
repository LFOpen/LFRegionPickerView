//
//  LFRegionPickerView.h
//  LFRegionPickerView
//
//  Created by archerLj on 2018/3/7.
//  Copyright © 2018年 com.bocodo.csr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ButtonPosition) {
    ButtonPositionTop, // 按钮在视图顶部
    ButtonPositionBottom // 按钮在视图底部
};

typedef NS_ENUM(NSUInteger, RegionGrade) {
    RegionGradeProvince, // 显示到省级
    RegionGradeCity, // 显示到市级
    RegionGradeArea // 显示到县/区级
};

typedef void(^LFRegionResult)(NSString *regionName, NSString *regionCode);

@interface LFRegionPickerView : UIView
@property (assign, nonatomic) CGFloat buttonHeight; // 取消/确定按钮高度
@property (assign, nonatomic) CGFloat height;  // 整个选择区域控件的高度

@property (strong, nonatomic) UIColor *pickerTitleColor; // 区域选择部分的文字颜色
@property (strong, nonatomic) UIColor *gapLineColor; // 分割线颜色
@property (strong, nonatomic) UIColor *cancelTitleColor; // 取消按钮颜色
@property (strong, nonatomic) UIColor *okTitleColor; // 确定按钮颜色

@property (assign, nonatomic) RegionGrade regionGrade; // 区域显示需要到哪一级：省/市/区
@property (assign, nonatomic) ButtonPosition buttonPosition; // 按钮的位置：上部|下部

@property (copy, nonatomic) NSString *currentRegionName; // 比如: 山东省/济南市/历下区
@property (copy, nonatomic) NSString *currentRegionCode; // 比如: 370000/370100/370102

+(instancetype)shared;
-(void)showInView:(UIView *)superView
            result:(LFRegionResult)result;

@end
