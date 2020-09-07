//
//  XPYReaderManagerController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReaderManagerController.h"
#import "XPYPageReadViewController.h"
#import "XPYHorizontalScrollReadViewController.h"
#import "XPYScrollReadViewController.h"
#import "XPYAutoReadCoverViewController.h"
#import "XPYReadViewController.h"

#import "XPYReadMenu.h"

#import "XPYBookModel.h"

#import "XPYReadHelper.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"

@interface XPYReaderManagerController () <XPYReadMenuDelegate, UIGestureRecognizerDelegate, XPYHorizontalScrollReadViewControllerDelegate, XPYPageReadViewControllerDelegate, XPYScrollReadViewControllerDelegate>

/// 仿真、无效果翻页控制器
@property (nonatomic, strong) XPYPageReadViewController *pageViewController;

/// 左右平移翻页控制器
@property (nonatomic, strong) XPYHorizontalScrollReadViewController *horizontalScrollReadController;

/// 上下滑动翻页和自动阅读滚屏模式控制器
@property (nonatomic, strong) XPYScrollReadViewController *scrollReadController;

/// 自动阅读覆盖模式控制器
@property (nonatomic, strong) XPYAutoReadCoverViewController *coverReadController;

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
    // App即将进入不活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
}

#pragma mark - UI
- (void)configureUI {
    // 隐藏导航栏
    self.fd_prefersNavigationBarHidden = YES;
    // 取消右滑返回手势
    self.fd_interactivePopDisabled = YES;
    
    [self createReader];
}

#pragma mark - Private methods
/// 创建阅读器
- (void)createReader {
    if (_pageViewController) {
        [_pageViewController.view removeFromSuperview];
        [_pageViewController removeFromParentViewController];
        _pageViewController = nil;
    }
    if (_horizontalScrollReadController) {
        [_horizontalScrollReadController.view removeFromSuperview];
        [_horizontalScrollReadController removeFromParentViewController];
        _horizontalScrollReadController = nil;
    }
    if (_scrollReadController) {
        [_scrollReadController.view removeFromSuperview];
        [_scrollReadController removeFromParentViewController];
        _scrollReadController = nil;
    }
    if (_coverReadController) {
        [_coverReadController.view removeFromSuperview];
        [_coverReadController removeFromParentViewController];
        _coverReadController = nil;
    }
    if ([XPYReadConfigManager sharedInstance].isAutoRead) {
        if ([XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeScroll) {
            // 自动阅读滚屏模式
            [self addChildViewController:self.scrollReadController];
        } else {
            // 自动阅读覆盖模式
            [self addChildViewController:self.coverReadController];
        }
        
    } else {
        // 非自动阅读模式
        XPYReadPageType pageType = [XPYReadConfigManager sharedInstance].pageType;
        switch (pageType) {
            case XPYReadPageTypeCurl:
            case XPYReadPageTypeNone: {
                [self addChildViewController:self.pageViewController];
            }
                break;
            case XPYReadPageTypeTranslation: {
                [self addChildViewController:self.horizontalScrollReadController];
            }
                break;
            case XPYReadPageTypeVerticalScroll: {
                [self addChildViewController:self.scrollReadController];
            }
                break;
        }
    }
}

#pragma mark - Actions
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.view];
    // 自动阅读和上下滚动翻页模式弹出菜单左右点击区域为全屏
    // 弹出菜单的情况下上下点击区域需要减去菜单高度
    // 其他情况限制弹出菜单工具栏的左右点击区域为屏幕中间，宽度为屏幕一半，上下为全屏
    CGFloat width = CGRectGetWidth(self.view.bounds) / 4.0;
    // 左边无效区域边界
    CGFloat leftWidth = 0;
    // 右边无效区域边界
    CGFloat rightWidth = 0;
    // 顶部无效区域边界
    CGFloat topHeight = 0;
    // 底部无效区域边界
    CGFloat bottomHeight = 0;
    if (![XPYReadConfigManager sharedInstance].isAutoRead && [XPYReadConfigManager sharedInstance].pageType != XPYReadPageTypeVerticalScroll) {
        leftWidth = width;
        rightWidth = width;
    }
    if (self.readMenu.isShowing) {
        topHeight = kXPYTopBarHeight;
        bottomHeight = kXPYBottomBarHeight;
    }
    // 点击是否在边界内
    BOOL isTouchInRect = CGRectContainsPoint(CGRectMake(leftWidth, topHeight, CGRectGetWidth(self.view.bounds) - leftWidth - rightWidth, CGRectGetHeight(self.view.bounds) - topHeight - bottomHeight), touchPoint);
    if (!isTouchInRect) {
        return;
    }
    if ([XPYReadConfigManager sharedInstance].isAutoRead) {
        // 如果自动阅读模式
        if (self.readMenu.isShowingAutoReadSetting) {
            [self.readMenu hideAutoReadSetting];
            // 继续自动阅读
            if ([XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeScroll) {
                [self.scrollReadController updateAutoReadStatus:YES];
            } else {
                [self.coverReadController updateAutoReadStatus:YES];
            }
        } else {
            [self.readMenu showAutoReadSetting];
            // 暂停自动阅读
            if ([XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeScroll) {
                [self.scrollReadController updateAutoReadStatus:NO];
            } else {
                [self.coverReadController updateAutoReadStatus:NO];
            }
        }
    } else {
        // 普通阅读模式
        if (self.readMenu.isShowing) {
            [self.readMenu hiddenWithComplete:nil];
        } else {
            [self.readMenu show];
        }
    }
}

#pragma mark - Notifications
/// 屏幕方向旋转
- (void)orientationChanged:(NSNotification *)notification {
    // 当前章节分页并设置阅读页
    [self createReader];
}
- (void)appWillEnterResignActive {
    if ([XPYReadConfigManager sharedInstance].isAutoRead) {
        // 自动阅读暂停
        [self.readMenu showAutoReadSetting];
        if ([XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeScroll) {
            [self.scrollReadController updateAutoReadStatus:NO];
        } else {
            [self.coverReadController updateAutoReadStatus:NO];
        }
    }
}

#pragma mark - XPYPageReadViewControllerDelegate
- (void)pageReadViewControllerWillTransition {
    if (self.readMenu.isShowing) {
        [self.readMenu hiddenWithComplete:nil];
    }
}

#pragma mark - XPYHorizontalScrollReadViewControllerDelegate
- (void)horizontalScrollReadViewControllerWillBeginScroll {
    if (self.readMenu.isShowing) {
        [self.readMenu hiddenWithComplete:nil];
    }
}

#pragma mark - XPYScrollReadViewControllerDelegate
- (void)scrollReadViewControllerWillBeginDragging {
    if (self.readMenu.isShowing) {
        [self.readMenu hiddenWithComplete:nil];
    }
}

#pragma mark - XPYReadMenuDelegate
- (void)readMenuHideStatusDidChange:(BOOL)isHide {
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)readMenuDidExitReader {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)readMenuDidChangePageType {
    [self createReader];
}
- (void)readMenuDidChangeBackground {
    self.view.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
    [self createReader];
}
- (void)readMenuDidOpenAutoRead {
    [self.readMenu hiddenWithComplete:^{
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
            // 开启自动阅读时如果阅读器为横屏则强制旋转屏幕
            XPYChangeInterfaceOrientation(UIInterfaceOrientationPortrait);
        }
        [XPYReadConfigManager sharedInstance].isAutoRead = YES;
        [self createReader];
    }];
}
- (void)readMenuDidCloseAutoRead {
    [XPYReadConfigManager sharedInstance].isAutoRead = NO;
    [self createReader];
}
- (void)readMenuDidChangeAutoReadMode:(XPYAutoReadMode)mode {
    [[XPYReadConfigManager sharedInstance] updateAutoReadMode:mode];
    [self createReader];
}

#pragma mark - Gesture recognizer delegete
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - UITraitEnvironment
/// 系统深色/浅色模式切换
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection] && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
            // 更新选中背景
            [self.readMenu updateSelectedBackgroundWithColorIndex:[XPYReadConfigManager sharedInstance].currentColorIndex];
            if ([XPYReadConfigManager sharedInstance].isAutoRead) {
                // 自动阅读阅读时切换系统深浅模式会出现问题所以先关闭自动阅读
                [self.readMenu hideAutoReadSetting];
                [XPYReadConfigManager sharedInstance].isAutoRead = NO;
            }
            [self createReader];
        }
    }
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
- (XPYHorizontalScrollReadViewController *)horizontalScrollReadController {
    if (!_horizontalScrollReadController) {
        _horizontalScrollReadController = [[XPYHorizontalScrollReadViewController alloc] initWithBook:self.book];
        _horizontalScrollReadController.delegate = self;
        [self.view addSubview:_horizontalScrollReadController.view];
        [self.view sendSubviewToBack:_horizontalScrollReadController.view];
    }
    return _horizontalScrollReadController;
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

- (XPYAutoReadCoverViewController *)coverReadController {
    if (!_coverReadController) {
        _coverReadController = [[XPYAutoReadCoverViewController alloc] initWithBook:self.book];
        [self.view addSubview:_coverReadController.view];
        [self.view sendSubviewToBack:_coverReadController.view];
    }
    return _coverReadController;
}

#pragma mark - Override methods
// 阅读器设置可以横屏
- (BOOL)shouldAutorotate {
    if ([XPYReadConfigManager sharedInstance].isAutoRead) {
        // 自动阅读不允许横屏
        return NO;
    }
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([XPYReadConfigManager sharedInstance].isAutoRead) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return !self.readMenu.isShowing;
}

@end
