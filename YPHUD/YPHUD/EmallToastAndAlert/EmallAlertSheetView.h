//
//  EmallAlertSheetView.h
//  EmallAlert
//
//  Created by 胡文阳 on 2020/10/29.
//

#import <UIKit/UIKit.h>

@interface EmallAlertSheetView : UIView
/// 弹窗中按钮点击事件回调
typedef void(^SheetOperationHandler)(void);

/// 初始化
EmallAlertSheetView *EmallAlertSheet(void);

#pragma mark - 通用方法
- (void)show;

/// 设置alert内title
- (EmallAlertSheetView *(^)(NSString *))setTitle;
/// 设置alert内所有按钮的title
- (EmallAlertSheetView *(^)(NSArray<NSString *> *))setButtonTitles;
/// 设置alert内按钮的handler
- (EmallAlertSheetView *(^)(NSArray<SheetOperationHandler> *))setButtonHandlers;

@end
