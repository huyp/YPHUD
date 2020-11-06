//
//  EmallAlertView.h
//  EmallAlert
//
//  Created by 胡文阳 on 2020/10/29.
//

#import <UIKit/UIKit.h>

@interface EmallAlertView : UIView
/// 弹窗中按钮点击事件回调
typedef void(^OperationHandler)(EmallAlertView *alterView);

#pragma mark - 初始化方法
EmallAlertView *EmallAlert(void);

#pragma mark - 通用方法
- (void)show;

#pragma mark - 设值方法
/// 设置alert内title
- (EmallAlertView *(^)(NSString *))setTitle;
/// 设置alert内secondTtile
- (EmallAlertView *(^)(NSAttributedString *))setSecondTitle;
/// 设置alert内message
- (EmallAlertView *(^)(NSString *))setMessage;
/// 设置alert内CenterImage
- (EmallAlertView *(^)(UIImage *))setCenterImage;
/// 设置alert内FillImage
- (EmallAlertView *(^)(UIImage *))setFillImage;
/// 设置alert内确认按钮内的文字
- (EmallAlertView *(^)(NSString *))setConfirmButtonTitle;
/// 设置alert内辅助按钮内的文字
- (EmallAlertView *(^)(NSString *))setOtherButtonTitle;
/// 设置主操作事件回调
- (void)setConfirmButtonHandler:(OperationHandler)OperationHandler;
/// 设置辅助按钮事件回调
- (void)setOtherButtonHandler:(OperationHandler)OperationHandler;
@end
