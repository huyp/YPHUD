//
//  EmallToastView.h
//  EmallAlert
//
//  Created by 胡文阳 on 2020/10/29.
//

#import <UIKit/UIKit.h>

#define kEmallToastCenterSucceedImage [UIImage imageNamed:@"EmallAlert-succeed"]
#define kEmallToastCenterFailedImage [UIImage imageNamed:@"EmallAlert-failed"]
#define kEmallToastLeftSucceedImage [UIImage imageNamed:@"EmallAlert-succeed-small"]
#define kEmallToastLeftFailedImage [UIImage imageNamed:@"EmallAlert-failed-small"]

@interface EmallToastView : UIView

#pragma mark - 初始化方法
EmallToastView *EmallToast(void);

#pragma mark - 通用方法
- (void)show;

#pragma mark - 设值方法
/// 设置toast内message
- (EmallToastView *(^)(NSString *))setMessage;
/// 设置toast内左侧image
- (EmallToastView *(^)(UIImage *))setLeftImage;
/// 设置toast内中间image
- (EmallToastView *(^)(UIImage *))setCenterImage;
@end

