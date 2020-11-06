//
//  EmallToastView.m
//  EmallAlert
//
//  Created by 胡文阳 on 2020/10/29.
//

#import "EmallToastView.h"

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

typedef NS_ENUM(NSUInteger, EmallToastViewStyle) {
    EmallToastViewStyleDefault = 0,
    EmallToastViewStyleCenterImage,
    EmallToastViewStyleLeftImage
};

@interface EmallToastView ()
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) float deltaTime;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) EmallToastViewStyle style;
@end

@implementation EmallToastView

EmallToastView *EmallToast(void) {
    return [[EmallToastView alloc]init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ColorWithDynamic(self.backgroundColor,[UIColor colorWithWhite:0 alpha:0.6],[UIColor colorWithRed:22/255.0 green:22/255.0 blue:26/255.0 alpha:0.65])
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.deltaTime = 2;
        self.style = EmallToastViewStyleDefault;
    }
    return self;
}

#pragma mark - show
- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUI];
        UIView *window = [UIApplication sharedApplication].keyWindow;
        self.center = window.center;
        [window addSubview:self];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.deltaTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.36 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        });
    });
}

#pragma mark - UI布局
- (void)setUI {
    NSAssert(self.message.length != 0, @"EmallToastView 中 message 不能为空");
    if (_style == EmallToastViewStyleCenterImage) {
        [self setCenterImageLayout];
    } else if (_style == EmallToastViewStyleLeftImage){
        [self setLeftImageLayout];
    } else {
        [self setNoneImageLayout];
    }
}

- (void)setCenterImageLayout {
    self.messageLabel.numberOfLines = 1;
    [self addSubview:self.imageview];
    self.imageview.frame = CGRectMake(42, 25, 36, 36);
    self.messageLabel.frame = CGRectMake(10, 74, 100, 16);
    self.frame = CGRectMake(0, 0, 120, 114);
}

- (void)setLeftImageLayout {
    self.messageLabel.numberOfLines = 1;
    self.messageLabel.font = [UIFont systemFontOfSize:17];
    CGFloat messageWidth = ([UIScreen mainScreen].bounds.size.width - 240);
    CGSize size = [self getMessageStringSizeWithLimitWidth:messageWidth];
    [self addSubview:self.imageview];
    
    if (size.height > self.messageLabel.font.lineHeight) {
        self.messageLabel.frame = CGRectMake(60, 12, messageWidth, 48);
        self.frame = CGRectMake(0, 0, messageWidth + 30 + 60, 72);
    }else{
        self.messageLabel.frame = CGRectMake(60, 12, size.width, 48);
        self.frame = CGRectMake(0, 0, size.width + 30 + 60, 72);
    }
    self.imageview.frame = CGRectMake(30, 26, 20, 20);
}

- (void)setNoneImageLayout {
    self.messageLabel.numberOfLines = 0;
    CGFloat messageWidth = ([UIScreen mainScreen].bounds.size.width - 180);
    CGSize size = [self getMessageStringSizeWithLimitWidth:messageWidth];
    if (size.height > self.messageLabel.font.lineHeight) {
        self.messageLabel.frame = CGRectMake(15, 10, messageWidth, size.height);
        self.frame = CGRectMake(0, 0, messageWidth + 30, size.height + 20);
    }else{
        self.messageLabel.frame = CGRectMake(15, 10, size.width, 16);
        self.frame = CGRectMake(0, 0, size.width + 30, self.messageLabel.font.lineHeight + 20);
    }
}

#pragma mark - 获取文字的size，并根据文字长度改变延时时长
- (CGSize)getMessageStringSizeWithLimitWidth:(CGFloat)limitWidth {
    CGSize size = CGSizeMake(limitWidth, CGFLOAT_MAX);
    size = [self.message boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.messageLabel.font} context:nil].size;
    int lineCount = size.height / self.messageLabel.font.lineHeight;
    if (lineCount > 2) {
        self.deltaTime += ((lineCount-2)*0.5);
    } else {
        self.deltaTime = 2;
    }
    return size;
}

#pragma mark - 设置图片和message
- (EmallToastView *(^)(NSString *))setMessage {
    return ^EmallToastView *(NSString *message) {
        self.message = message;
        return self;
    };
}

- (EmallToastView *(^)(UIImage *))setLeftImage {
    return ^EmallToastView *(UIImage *img) {
        self.image = img;
        self.style = EmallToastViewStyleLeftImage;
        return self;
    };
}

- (EmallToastView *(^)(UIImage *))setCenterImage {
    return ^EmallToastView *(UIImage *img) {
        self.image = img;
        self.style = EmallToastViewStyleCenterImage;
        return self;
    };
}

#pragma mark - UI懒加载
- (UIImageView *)imageview {
    if (!_imageview) {
        _imageview = [[UIImageView alloc]init];
        _imageview.contentMode = UIViewContentModeScaleAspectFit;
        _imageview.image = self.image;
        [self addSubview:_imageview];
    }
    return _imageview;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _messageLabel.text = self.message;
        _messageLabel.textColor = [UIColor colorWithWhite:1 alpha:1.0];
        [self addSubview:_messageLabel];
    }
    return _messageLabel;
}

@end
