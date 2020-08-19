//
//  XPYAlertController.h
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2019/6/21.
//  Copyright © 2019 xpy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XPYAlertController;

@interface XPYAlertModel : NSObject

@property (nonatomic, copy) NSString * _Nullable alertTitle;
@property (nonatomic, copy) NSString * _Nullable alertMessage;
@property (nonatomic, assign) UIAlertControllerStyle preferredStyle;

- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style;

@end

typedef void (^XPYAlert)(XPYAlertController *alert);

typedef XPYAlertController * _Nonnull (^XPYShowAlert)(UIViewController *controller);
typedef XPYAlertController * _Nonnull (^XPYSourceView)(UIView *sourceView);
typedef XPYAlertController * _Nonnull (^XPYActions)(NSArray<UIAlertAction *> *actions);

@interface XPYAlertController : UIAlertController

+ (XPYAlertController *)makeAlert:(XPYAlert)block alertModel:(XPYAlertModel *)model;

/**
 设置Actions

 @return Self
 */
- (XPYActions)actionItems;

/**
当设备为ipad时设置SourceView

@return Self
*/
- (XPYSourceView)sourceView;

/**
 显示Alert

 @return Self
 */
- (XPYShowAlert)showAlert;

@end

NS_ASSUME_NONNULL_END
