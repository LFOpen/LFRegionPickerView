# LFRegionPickerView
 ![image](https://github.com/LFOpen/LFRegionPickerView/raw/master/pics/pic1.PNG)
 ![image](https://github.com/LFOpen/LFRegionPickerView/raw/master/pics/pic2.PNG)
 ![image](https://github.com/LFOpen/LFRegionPickerView/raw/master/pics/pic3.PNG)
  ![image](https://github.com/LFOpen/LFRegionPickerView/raw/master/pics/pic4.PNG)

封装了一个地址选择器，该地址选择器会返回选择的地区名称，如`山东省/济南市/历下区` 和该地区对应的Code, 如: `370000/370100/370102`.

# Cocoapods集成
由于要使用到私有库，所以需要将私有库地址和cocoapods公有库地址全部写好
```
source 'https://github.com/LFOpen/LFOpen.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'asdf' do
  pod 'LFRegionPickerView'
end
```

# 使用方法
首先，导入头文件`#import <LFRegionPickerView.h>`
如果不需要特别的设置，只需要像下面这样使用即可：
```
    [[LFRegionPickerView shared] showInView:self.view result:^(NSString *regionName, NSString *regionCode) {
        NSLog(@"%@", [NSString stringWithFormat:@"region name: %@", regionName]);
        NSLog(@"%@", [NSString stringWithFormat:@"region code: %@", regionCode]);
    }];
```

如果想修改更多的属性，可供修改的部分如下：
```
    // 按钮位置：选择器顶部 | 底部
    [LFRegionPickerView shared].buttonPosition = ButtonPositionBottom;
    // 选择器文字的颜色
    [LFRegionPickerView shared].pickerTitleColor = [UIColor greenColor];
    // 分割线颜色
    [LFRegionPickerView shared].gapLineColor = [UIColor redColor];
    // 确定按钮文字颜色
    [LFRegionPickerView shared].okTitleColor = [UIColor blueColor];
    // 取消按钮文字颜色
    [LFRegionPickerView shared].cancelTitleColor = [UIColor redColor];
    // 按钮的高度
    [LFRegionPickerView shared].buttonHeight = 44.0;
    // 选择器的高度
    [LFRegionPickerView shared].height = 250.0;
    // 需要显示到哪一级：省级 | 市级 | 县/区级
    [LFRegionPickerView shared].regionGrade = RegionGradeArea;
    // 设置默认选中的地区对应的名字
    [LFRegionPickerView shared].currentRegionName = @"山东省/济南市/历下区";
    // 设置默认选中的地区对应的Code
    [LFRegionPickerView shared].currentRegionCode = @"370000/370100/370102";
```
修改完上面的属性后，再调用一下代码来显示即可
```
    [[LFRegionPickerView shared] showInView:self.view result:^(NSString *regionName, NSString *regionCode) {
        NSLog(@"%@", [NSString stringWithFormat:@"region name: %@", regionName]);
        NSLog(@"%@", [NSString stringWithFormat:@"region code: %@", regionCode]);
    }];
```
