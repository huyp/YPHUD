//
//  EmallAlertView.m
//  EmallAlert
//
//  Created by 胡文阳 on 2020/10/29.
//

#import "EmallAlertView.h"

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

typedef NS_ENUM(NSUInteger, EmallAlertViewImageStyle) {
    EmallAlertViewImageStyleCenter= 0,
    EmallAlertViewImageStyleFill
};

@interface EmallAlertView ()
/// 记录弹窗样式
@property (nonatomic, assign) EmallAlertViewImageStyle style;
/// 获取弹窗图片
@property (nonatomic, strong) UIImage *image;
/// 获取弹窗title
@property (nonatomic, copy) NSString *title;
///获取弹窗secondTitle
@property (nonatomic, strong) NSAttributedString *secondTitle;
/// 获取弹窗内message
@property (nonatomic, copy) NSString *message;
/// 获取主操作按钮内的文字
@property (nonatomic, copy) NSString *confirmButtonTitle;
/// 获取辅助按钮内的文字
@property (nonatomic, copy) NSString *otherButtonTitle;
/// 获取主操作事件回调
@property (nonatomic, copy) OperationHandler confirmHandler;
///// 获取辅助按钮事件回调
@property (nonatomic, copy) OperationHandler otherHandler;

@property (nonatomic, strong) UIView*shadeCoverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *secondTitleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *otherButton;
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) UIImageView *closeImageview;
@end

@implementation EmallAlertView
#pragma mark - 初始化
EmallAlertView *EmallAlert(void) {
    return [[EmallAlertView alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ColorWithDynamic(self.backgroundColor,UIColor.whiteColor,[UIColor colorWithRed:22/255.0 green:22/255.0 blue:26/255.0 alpha:1.0])
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.style = EmallAlertViewImageStyleCenter;
        self.title = nil;
        self.image = nil;
        self.message = nil;
        self.confirmButtonTitle = @"确认";
        self.otherButtonTitle = nil;
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    NSAssert(self.message.length != 0, @"EmallAlertView 中 message 不能为空");
    CGFloat height = 0;
    // 图片
    if (_image == nil) {
        height += 25;
    } else {
        [self addSubview:self.imageview];
        [self addSubview:self.closeImageview];
        self.closeImageview.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100), 0, 30, 30);
        switch (_style) {
            case EmallAlertViewImageStyleCenter:{
                height += 25;
                self.imageview.frame = CGRectMake(0, height, 100, 100);
                self.imageview.center = CGPointMake(([UIScreen mainScreen].bounds.size.width - 70) * 0.5, self.imageview.center.y);
                height += 100;
                break;
            }
            case EmallAlertViewImageStyleFill:{
                self.imageview.frame = CGRectMake(0, height, ([UIScreen mainScreen].bounds.size.width - 70), 125);
                height += 125;
                break;
            }
            default:
                break;
        }
        height += 20;
    }
    
    // 标题
    if (self.title) {
        [self addSubview:self.titleLabel];
        self.titleLabel.frame = CGRectMake(35, height, ([UIScreen mainScreen].bounds.size.width - 140), 20);
        height += 30;
    }
    
    // 副标题
    if (self.secondTitle) {
        [self addSubview:self.secondTitleLabel];
        self.secondTitleLabel.frame = CGRectMake(35, height, ([UIScreen mainScreen].bounds.size.width - 140), 20);
        height += 30;
    }
    
    // 内容
    if (self.message.length > 200) {
        [self addSubview:self.messageTextView];
        self.messageTextView.frame = CGRectMake(35, height, ([UIScreen mainScreen].bounds.size.width - 140), [UIScreen mainScreen].bounds.size.height/3.0);
        height += ([UIScreen mainScreen].bounds.size.height/3.0);
    } else {
        [self addSubview:self.messageLabel];
        CGSize size = [self getMessageStringSizeWith];
        self.messageLabel.frame = CGRectMake(35, height, ([UIScreen mainScreen].bounds.size.width - 140), size.height + 10);
        height += (size.height + 10);
    }
    
    height += 20;
    
    // 按钮
    if (self.otherButtonTitle) {
        [self addSubview:self.confirmButton];
        [self addSubview:self.otherButton];
        self.otherButton.frame = CGRectMake(30, height, 110, 36);
        self.confirmButton.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 210), height, 110, 36);
        [self.closeImageview removeFromSuperview];
    } else {
        [self addSubview:self.confirmButton];
        self.confirmButton.frame = CGRectMake(30, height, ([UIScreen mainScreen].bounds.size.width - 130), 36);
    }
    
    height += 56;
    
    [self mainButtonAddBackgroundcolor];
    self.frame = CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width - 70), height);
    
}

#pragma mark - 展示、关闭
- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUI];
        UIView *window = [UIApplication sharedApplication].keyWindow;
        self.shadeCoverView.frame = window.bounds;
        self.center = self.shadeCoverView.center;
        [self.shadeCoverView addSubview:self];
        [window addSubview:self.shadeCoverView];
    });
}

- (void)closeAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        [self.shadeCoverView removeFromSuperview];
    });
}

#pragma mark - 点击事件
- (void)confirmButtonAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.confirmHandler) {
            self.confirmHandler(self);
        }
        [self closeAlert];
    });
}

- (void)otherButtonAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.otherHandler) {
            self.otherHandler(self);
        }
        [self closeAlert];
    });
}

#pragma mark - 工具方法
- (CGSize)getMessageStringSizeWith {
    CGFloat messageWidth = ([UIScreen mainScreen].bounds.size.width - 140);
    CGSize size = CGSizeMake(messageWidth, CGFLOAT_MAX);
    size = [self.message boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.messageLabel.font} context:nil].size;
    return size;
}

- (void)mainButtonAddBackgroundcolor {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:245/255.0 green:114/255.0 blue:79/255.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:232/255.0 green:62/255.0 blue:39/255.0 alpha:1.0].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 0);
    gradientLayer.frame = self.confirmButton.bounds;
    [self.confirmButton.layer insertSublayer:gradientLayer atIndex:0];
}

#pragma mark - 懒加载
-(UIView *)shadeCoverView {
    if (!_shadeCoverView) {
        _shadeCoverView = [UIView new];
        _shadeCoverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    }
    return _shadeCoverView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        ColorWithDynamic(_titleLabel.textColor,[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0],UIColor.whiteColor)
        _titleLabel.text = self.title;
    }
    return _titleLabel;
}

- (UILabel *)secondTitleLabel {
    if (!_secondTitleLabel) {
        _secondTitleLabel = [[UILabel alloc]init];
        _secondTitleLabel.textAlignment = NSTextAlignmentCenter;
        _secondTitleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        ColorWithDynamic(_secondTitleLabel.textColor,[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0],UIColor.whiteColor)
        _secondTitleLabel.attributedText = self.secondTitle;
    }
    return _secondTitleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        ColorWithDynamic(_messageLabel.textColor,[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0],UIColor.whiteColor)
        _messageLabel.text = self.message;
    }
    return _messageLabel;
}

- (UITextView *)messageTextView {
    if (!_messageTextView) {
        _messageTextView = [[UITextView alloc] init];
        _messageTextView.text = self.message;
        _messageTextView.selectable = NO;
        _messageTextView.editable = NO;
        _messageTextView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        ColorWithDynamic(_messageTextView.backgroundColor,UIColor.whiteColor,[UIColor colorWithRed:22/255.0 green:22/255.0 blue:26/255.0 alpha:1.0])
        ColorWithDynamic(_messageTextView.textColor,[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0],UIColor.whiteColor)
    }
    return _messageTextView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _confirmButton.layer.cornerRadius = 18;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)otherButton {
    if (!_otherButton) {
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherButton setTitle:self.otherButtonTitle forState:UIControlStateNormal];
        [_otherButton setTitleColor:[UIColor colorWithRed:232/255.0 green:62/255.0 blue:39/255.0 alpha:1.0] forState:UIControlStateNormal];
        _otherButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _otherButton.layer.cornerRadius = 18;
        _otherButton.layer.masksToBounds = YES;
        _otherButton.layer.borderWidth = 1;
        _otherButton.layer.borderColor = [UIColor colorWithRed:232/255.0 green:62/255.0 blue:39/255.0 alpha:1.0].CGColor;
        [_otherButton addTarget:self action:@selector(otherButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherButton;
}

- (UIImageView *)imageview {
    if (!_imageview) {
        _imageview = [[UIImageView alloc]init];
        _imageview.contentMode = UIViewContentModeScaleAspectFit;
        _imageview.layer.masksToBounds = YES;
        _imageview.image = self.image;
    }
    return _imageview;
}

- (UIImageView *)closeImageview {
    if (!_closeImageview) {
        _closeImageview = [[UIImageView alloc]init];
        _closeImageview.userInteractionEnabled = YES;
        _closeImageview.image = [UIImage imageNamed:@"EmallAlert-close"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeAlert)];
        [_closeImageview addGestureRecognizer:tap];
    }
    return _closeImageview;
}

#pragma mark - set方法
- (EmallAlertView *(^)(NSString *))setTitle {
    return ^EmallAlertView *(NSString *title) {
        self.title = title;
        return self;
    };
}

- (EmallAlertView *(^)(NSAttributedString *))setSecondTitle {
    return ^EmallAlertView *(NSAttributedString *title) {
        NSAssert([title isKindOfClass:[NSAttributedString class]], @"EmallAlertView 中 secondTitle的值必须是一个NSAttributedString 或 NSMutableAttributedString 类型");
        self.secondTitle = title;
        return self;
    };
}

- (EmallAlertView *(^)(NSString *))setMessage {
    return ^EmallAlertView *(NSString *message) {
        self.message = message;
        return self;
    };
}

- (EmallAlertView *(^)(UIImage *))setCenterImage {
    return ^EmallAlertView *(UIImage *img) {
        self.image = img;
        self.style = EmallAlertViewImageStyleCenter;
        return self;
    };
}

- (EmallAlertView *(^)(UIImage *))setFillImage {
    return ^EmallAlertView *(UIImage *img) {
        self.image = img;
        self.style = EmallAlertViewImageStyleFill;
        return self;
    };
}

- (EmallAlertView *(^)(NSString *))setConfirmButtonTitle {
    return ^EmallAlertView *(NSString *confirmButtonTitle) {
        self.confirmButtonTitle = confirmButtonTitle;
        return self;
    };
}

- (EmallAlertView *(^)(NSString *))setOtherButtonTitle {
    return ^EmallAlertView *(NSString *otherButtonTitle) {
        self.otherButtonTitle = otherButtonTitle;
        return self;
    };
}

- (void)setConfirmButtonHandler:(OperationHandler)operationHandler {
    self.confirmHandler = operationHandler;
}

- (void)setOtherButtonHandler:(OperationHandler)operationHandler {
     self.otherHandler = operationHandler;
}

@end
