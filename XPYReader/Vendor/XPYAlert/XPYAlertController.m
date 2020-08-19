//
//  XPYAlertController.m
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2019/6/21.
//  Copyright © 2019 xpy. All rights reserved.
//

#import "XPYAlertController.h"

@implementation XPYAlertModel

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style {
    self = [super init];
    if (self) {
        self.alertTitle = title;
        self.alertMessage = message;
        self.preferredStyle = style;
    }
    return self;
}
@end

@implementation XPYAlertController
+ (XPYAlertController *)makeAlert:(XPYAlert)block alertModel:(XPYAlertModel *)model {
    XPYAlertController *alert = [XPYAlertController alertControllerWithTitle:model.alertTitle message:model.alertMessage preferredStyle:model.preferredStyle];
    block(alert);
    return alert;
}
- (XPYActions)actionItems {
    XPYActions actionsBlock = ^(NSArray<UIAlertAction *> *actions) {
        [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addAction:obj];
        }];
        return self;
    };
    return actionsBlock;
}
- (XPYShowAlert)showAlert {
    XPYShowAlert showBlock = ^(UIViewController *controller) {
        [controller presentViewController:self animated:YES completion:nil];
        return self;
    };
    return showBlock;
}
- (XPYSourceView)sourceView {
    XPYSourceView sourceViewBlock = ^(UIView *sourceView) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            UIPopoverPresentationController *popPresenter = self.popoverPresentationController;
            popPresenter.sourceView = sourceView;
            popPresenter.sourceRect = sourceView.bounds;
            popPresenter.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        return self;
    };
    return sourceViewBlock;
}


@end
