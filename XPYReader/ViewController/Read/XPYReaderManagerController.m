//
//  XPYReaderManagerController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReaderManagerController.h"
#import "XPYPageReadViewController.h"
#import "XPYScrollReadViewController.h"
#import "XPYReadViewController.h"

#import "XPYReadMenu.h"

#import "XPYBookModel.h"

#import "XPYReadHelper.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"

@interface XPYReaderManagerController () <XPYReadMenuDelegate, UIGestureRecognizerDelegate, XPYPageReadViewControllerDelegate, XPYScrollReadViewControllerDelegate>

/// 仿真、左右平移、无效果翻页控制器
@property (nonatomic, strong) XPYPageReadViewController *pageViewController;

/// 左右平移翻页控制器
@property (nonatomic, strong) XPYScrollReadViewController *scrollReadController;

/// 菜单工具栏管理
@property (nonatomic, strong) XPYReadMenu *readMenu;

/// 章节信息
@property (nonatomic, copy) NSArray <XPYChapterModel *> *chapters;

@end

@implementation XPYReaderManagerController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取章节信息
    [XPYChapterHelper chaptersWithBookId:self.book.bookId success:^(NSArray * _Nonnull chapters) {
        self.chapters = chapters;
        // 更新书籍章节数量
        if (self.book.chapterCount != chapters.count) {
            self.book.chapterCount = chapters.count;
            [XPYReadRecordManager updateChapterCountWithBookId:self.book.bookId count:self.book.chapterCount];
        }
        [self initialize];
    } failure:^(NSString * _Nonnull tip) {
        [MBProgressHUD xpy_showTips:tip];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
}

/// 初始化内容
- (void)initialize {
    
    [self configureUI];
    
    // 初始化菜单工具栏
    self.readMenu = [[XPYReadMenu alloc] initWithView:self.view];
    self.readMenu.delegate = self;
    
    // 点击事件（弹出工具栏）
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

#pragma mark - UI
- (void)configureUI {
    // 隐藏导航栏
    self.fd_prefersNavigationBarHidden = YES;
    // 取消右滑返回手势
    self.fd_interactivePopDisabled = YES;
    
    [self createReaderWithPageType:[XPYReadConfigManager sharedInstance].pageType];
}

#pragma mark - Private methods
/// 根据翻页模式创建阅读器
/// @param pageType 翻页模式
- (void)createReaderWithPageType:(XPYReadPageType)pageType {
    if (_pageViewController) {
        [_pageViewController.view removeFromSuperview];
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    if (_scrollReadController) {
        [_scrollReadController.view removeFromSuperview];
        [_scrollReadController removeFromParentViewController];
        _scrollReadController = nil;
    }
    switch (pageType) {
        case XPYReadPageTypeCurl:
        case XPYReadPageTypeNone:
        case XPYReadPageTypeTranslation: {
            [self addChildViewController:self.pageViewController];
        }
            break;
        case XPYReadPageTypeVerticalScroll: {
            [self addChildViewController:self.scrollReadController];
        }
            break;
    }
}

#pragma mark - Actions
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.view];
    // 限制弹出菜单工具栏的点击区域为屏幕中间，宽度为屏幕一半
    CGFloat width = CGRectGetWidth(self.view.bounds) / 4.0;
    if (touchPoint.x > width && touchPoint.x < width * 3) {
        NSLog(@"弹出或隐藏工具栏");
        if (self.readMenu.isShowing) {
            [self.readMenu hidden];
        } else {
            [self.readMenu show];
        }
    }
}

#pragma mark - Notifications
/// 屏幕方向旋转
- (void)orientationChanged:(NSNotification *)notification {
    // 当前章节分页并设置阅读页
    [self createReaderWithPageType:[XPYReadConfigManager sharedInstance].pageType];
}
#pragma mark - XPYPageReadViewControllerDelegate
- (void)pageReadViewControllerWillTransition {
    if (self.readMenu.isShowing) {
        [self.readMenu hidden];
    }
}

#pragma mark - XPYScrollReadViewControllerDelegate
- (void)scrollReadViewControllerWillBeginDragging {
    if (self.readMenu.isShowing) {
        [self.readMenu hidden];
    }
}

#pragma mark - XPYReadMenuDelegate
- (void)readMenuDidClickBack {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)readMenuDidChangePageType:(XPYReadPageType)pageType {
    [self createReaderWithPageType:pageType];
}

#pragma mark - Gesture recognizer delegete
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Getters
- (XPYPageReadViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[XPYPageReadViewController alloc] initWithBook:self.book pageType:[XPYReadConfigManager sharedInstance].pageType];
        _pageViewController.pageReadDelegate = self;
        [self.view addSubview:_pageViewController.view];
        [self.view sendSubviewToBack:_pageViewController.view];
    }
    return _pageViewController;
}
- (XPYScrollReadViewController *)scrollReadController {
    if (!_scrollReadController) {
        _scrollReadController = [[XPYScrollReadViewController alloc] initWithBook:self.book];
        _scrollReadController.scrollReadDelegate = self;
        [self.view addSubview:_scrollReadController.view];
        [self.view sendSubviewToBack:_scrollReadController.view];
    }
    return _scrollReadController;
}

#pragma mark - Override methods
// 阅读器设置可以横屏
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
