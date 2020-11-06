//
//  EmallAlertSheetView.m
//  EmallAlert
//
//  Created by 胡文阳 on 2020/10/29.
//

#import "EmallAlertSheetView.h"
#define ColorWithDynamic(Tagter,LightColor,DarkColor) if (@available(iOS 13.0, *)) {\
Tagter = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {\
if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {\
return DarkColor;\
}else {\
return LightColor;\
}\
}];\
} else {\
Tagter = LightColor;\
}

#define NOTCHED_SCREEN      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?\
(\
CGSizeEqualToSize(CGSizeMake(375, 812),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(812, 375),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(414, 896),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(896, 414),[UIScreen mainScreen].bounds.size))\
:\
NO)

// 底部安全区域高度
#define SAFEAREA_BTM             (NOTCHED_SCREEN ? 34.0f : 0.0f)

@interface EmallAlertSheetView ()
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSString *> *buttonTitles;
@property (nonatomic, copy) NSArray<SheetOperationHandler> *buttonHandlers;

@end

@implementation EmallAlertSheetView

EmallAlertSheetView *EmallAlertSheet(void) {
    return [[EmallAlertSheetView alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    }
    return self;
}

#pragma mark - 展示、关闭
- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUI];
        UIView *window = [UIApplication sharedApplication].keyWindow;
        self.frame = window.bounds;
        [window addSubview:self];
    });
}

- (void)closeAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)operationHandler:(UIButton *)btn {
    SheetOperationHandler op = self.buttonHandlers[btn.tag - 8000];
    if (op) {
        op();
        [self closeAlert];
    }
}

- (void)setUI {
    NSAssert(self.buttonTitles.count > 0, @"EmallAlertSheetView 中 button不能少于一个");
    NSAssert(self.buttonTitles.count == self.buttonHandlers.count, @"EmallAlertSheetView 中 button和handle没有对应");
    
    CGFloat contentViewHeight = (self.buttonTitles.count * 56);
    contentViewHeight += (self.buttonTitles.count - 1);//中间线
    contentViewHeight += (self.title ? 56 : 0);
    self.cancleButton.frame = CGRectMake(15, ([UIScreen mainScreen].bounds.size.height - SAFEAREA_BTM - 56), ([UIScreen mainScreen].bounds.size.width - 30), 56);
    self.contentView.frame = CGRectMake(CGRectGetMinX(self.cancleButton.frame), (CGRectGetMinY(self.cancleButton.frame) - 15 - contentViewHeight), CGRectGetWidth(self.cancleButton.frame), contentViewHeight);
    CGFloat titleMaxY = 0;
    if (self.title) {
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 56);
        [self addLineViewWithY:56];
        titleMaxY = 57;
    } else {
        self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 0);
    }
    
    for (int i = 0; i<self.buttonTitles.count; i++) {
        NSString *str = self.buttonTitles[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:str forState:UIControlStateNormal];
        [self setButtonTitleColorWithButton:btn];
        btn.tag = 8000 + i;
        btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [btn addTarget:self action:@selector(operationHandler:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, (56 * i + i) + titleMaxY, CGRectGetWidth(self.contentView.frame), 56);
        [self.contentView addSubview:btn];
        [self addLineViewWithY:CGRectGetMaxY(btn.frame)];
    }
}

- (void)addLineViewWithY:(CGFloat)y {
    UIView *lineView = [UIView new];
    ColorWithDynamic(lineView.backgroundColor,[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0],[UIColor colorWithRed:84/255.0 green:84/255.0 blue:88/255.0 alpha:1.0])
    lineView.frame = CGRectMake(0, y, CGRectGetWidth(self.contentView.frame), 1);
    [self.contentView addSubview:lineView];
}

- (void)setButtonTitleColorWithButton:(UIButton *)btn {
    UIColor *col;
    if (@available(iOS 13.0, *)) {
        col = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor whiteColor];
            }else {
                return [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            }
        }];
    } else {
        col = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    }
    [btn setTitleColor:col forState:UIControlStateNormal];
}

#pragma mark - 设置内容
- (EmallAlertSheetView *(^)(NSString *))setTitle {
    return ^EmallAlertSheetView *(NSString *title) {
        self.title = title;
        return self;
    };
}

- (EmallAlertSheetView *(^)(NSArray<NSString *> *))setButtonTitles {
    return ^EmallAlertSheetView *(NSArray<NSString *> *titleArr) {
        self.buttonTitles = titleArr;
        return self;
    };
}

- (EmallAlertSheetView *(^)(NSArray<SheetOperationHandler> *))setButtonHandlers {
    return ^EmallAlertSheetView *(NSArray<SheetOperationHandler> *handlerArr) {
        self.buttonHandlers = handlerArr;
        return self;
    };
}

#pragma mark - UI懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        ColorWithDynamic(_titleLabel.textColor,[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0],[UIColor colorWithWhite:1 alpha:0.7])
        _titleLabel.text = self.title;
    }
    return _titleLabel;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        ColorWithDynamic(_contentView.backgroundColor,[UIColor whiteColor],[UIColor colorWithRed:37/255.0 green:37/255.0 blue:43/255.0 alpha:1.0])
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)cancleButton {
    if (!_cancleButton) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [self setButtonTitleColorWithButton:_cancleButton];
        _cancleButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _cancleButton.layer.cornerRadius = 10;
        _cancleButton.layer.masksToBounds = YES;
        [_cancleButton addTarget:self action:@selector(closeAlert) forControlEvents:UIControlEventTouchUpInside];
        ColorWithDynamic(_cancleButton.backgroundColor,[UIColor whiteColor],[UIColor colorWithRed:37/255.0 green:37/255.0 blue:43/255.0 alpha:1.0])
        [self addSubview:_cancleButton];
    }
    return _cancleButton;
}

@end
