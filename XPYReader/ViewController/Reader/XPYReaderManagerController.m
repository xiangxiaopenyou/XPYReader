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
#import "XPYBookStackViewController.h"
#import "XPYBookCatalogViewController.h"

#import "XPYReadView.h"

#import "XPYReadMenu.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

#import "XPYReadHelper.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"

#import "UIGestureRecognizer+XPYTag.h"

@interface XPYReaderManagerController () <XPYReadMenuDelegate, UIGestureRecognizerDelegate, XPYHorizontalScrollReadViewControllerDelegate, XPYPageReadViewControllerDelegate, XPYScrollReadViewControllerDelegate, XPYAutoReadCoverViewControllerDelegate, XPYBookCatalogDelegate>

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

/// 菜单工具栏显示/隐藏单机手势
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation XPYReaderManagerController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取章节信息
    [XPYChapterHelper chaptersWithBookId:self.book.bookId success:^(NSArray * _Nonnull chapters) {
        // 更新书籍章节数量
        if (self.book.chapterCount != chapters.count) {
            self.book.chapterCount = chapters.count;
            [XPYReadRecordManager updateChapterCountWithBookId:self.book.bookId count:self.book.chapterCount];
        }
    } failure:^(NSString * _Nonnull tip) {
        [MBProgressHUD xpy_showTips:tip];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self initialize];
}

#pragma mark - Private methods

- (void)configureUI {
    // 隐藏导航栏
    self.fd_prefersNavigationBarHidden = YES;
    // 取消右滑返回手势
    self.fd_interactivePopDisabled = YES;
    
    [self createReader];
}

/// 初始化内容
- (void)initialize {
    
    [self configureUI];
    
    // 初始化菜单工具栏
    self.readMenu = [[XPYReadMenu alloc] initWithView:self.view];
    self.readMenu.delegate = self;
    
    // 点击手势（弹出工具栏）
    [self.view addGestureRecognizer:self.tap];
    
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    // App即将进入不活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

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

#pragma mark - Event response
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.view];
    // 自动阅读和上下滚动翻页模式弹出菜单左右点击区域为全屏
    // 其他情况限制弹出菜单工具栏的左右点击区域为屏幕中间，宽度为屏幕一半
    CGFloat width = CGRectGetWidth(self.view.bounds) / 4.0;
    // 左边无效区域边界
    CGFloat leftWidth = 0;
    // 右边无效区域边界
    CGFloat rightWidth = 0;
    if (![XPYReadConfigManager sharedInstance].isAutoRead && [XPYReadConfigManager sharedInstance].pageType != XPYReadPageTypeVerticalScroll) {
        leftWidth = width;
        rightWidth = width;
    }
    // 点击是否在边界内
    BOOL isTouchInRect = CGRectContainsPoint(CGRectMake(leftWidth, 0, CGRectGetWidth(self.view.bounds) - leftWidth - rightWidth, CGRectGetHeight(self.view.bounds)), touchPoint);
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
            [self.readMenu showWithBook:self.book];
        }
    }
}
- (void)longPress:(UILongPressGestureRecognizer *)press {
    
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
- (void)scrollReadViewControllerDidReadEnding {
    if ([XPYReadConfigManager sharedInstance].isAutoRead && [XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeScroll) {
        // 如果是自动阅读模式，则需要结束自动阅读
        [XPYReadConfigManager sharedInstance].isAutoRead = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createReader];
            if (self.readMenu.isShowingAutoReadSetting) {
                [self.readMenu hideAutoReadSetting];
            }
        });
    }
}

#pragma mark - XPYAutoReadCoverViewControllerDelegate
- (void)autoReadCoverViewControllerDidEndEnding {
    if ([XPYReadConfigManager sharedInstance].isAutoRead && [XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeCover) {
        // 如果是自动阅读模式，则需要结束自动阅读
        [XPYReadConfigManager sharedInstance].isAutoRead = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createReader];
            if (self.readMenu.isShowingAutoReadSetting) {
                [self.readMenu hideAutoReadSetting];
            }
        });
    }
}

#pragma mark - XPYBookCatalogDelegate
- (void)bookCatalog:(XPYBookCatalogViewController *)catalogController didSelectChapter:(XPYChapterModel *)chapter {
    if (self.readMenu.isShowing) {
        [self.readMenu hiddenWithComplete:nil];
    }
    self.book.chapter = chapter;
    self.book.page = 0;
    
    // 更新阅读记录
    [XPYReadRecordManager updateReadRecordWithModel:self.book];
    [self createReader];
}

#pragma mark - XPYReadMenuDelegate
- (void)readMenuHideStatusDidChange:(BOOL)isHide {
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)readMenuDidExitReader {
    [self.readMenu hiddenWithComplete:^{
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
            // 如果阅读器为横屏则强制旋转屏幕
            XPYChangeInterfaceOrientation(UIInterfaceOrientationPortrait);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)readMenuDidChangePageProgress:(NSInteger)progress {
    // 更新当前页
    if (self.book.page == progress - 1) {
        return;
    }
    self.book.page = progress - 1;
    // 更新记录
    [XPYReadRecordManager updateReadRecordWithModel:self.book];
    [self createReader];
}
- (void)readMenuDidChangeChapter:(BOOL)isNext {
    // 先隐藏菜单
    if (self.readMenu.isShowing) {
        [self.readMenu hiddenWithComplete:nil];
    }
    XPYChapterModel *changedChapter = isNext ? [[XPYChapterHelper nextChapterOfCurrentChapter:self.book.chapter] copy] : [[XPYChapterHelper lastChapterOfCurrentChapter:self.book.chapter] copy];
    if (XPYIsEmptyObject(changedChapter.content)) {
        // 章节内容为空，需要获取章节信息
        [XPYChapterHelper chapterWithBookId:self.book.bookId chapterId:changedChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
            self.book.chapter = chapter;
            self.book.page = 0;
            // 更新记录
            [XPYReadRecordManager updateReadRecordWithModel:self.book];
            // 刷新阅读器
            [self createReader];
        } failure:^(NSString * _Nonnull tip) {
            [MBProgressHUD xpy_showErrorTips:tip];
        }];
    } else {
        // 存在章节内容
        self.book.chapter = changedChapter;
        self.book.page = 0;
        // 更新记录
        [XPYReadRecordManager updateReadRecordWithModel:self.book];
        // 刷新阅读器
        [self createReader];
    }
}
- (void)readMenuDidOpenCatalog {
    XPYBookCatalogViewController *catalogController = [[XPYBookCatalogViewController alloc] init];
    catalogController.book = self.book;
    catalogController.delegate = self;
    [self.navigationController pushViewController:catalogController animated:YES];
}
- (void)readMenuDidChangePageType {
    [self createReader];
}
- (void)readMenuDidChangeBackground {
    self.view.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
    [self createReader];
}
- (void)readMenuDidChangeFontSize {
    [self createReader];
}
- (void)readMenuDidChangeSpacing {
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
- (void)readMenuDidChangeAutoReadSpeed:(NSInteger)speed {
    [[XPYReadConfigManager sharedInstance] updateAutoReadSpeed:speed];
    // 继续自动阅读
    if ([XPYReadConfigManager sharedInstance].autoReadMode == XPYAutoReadModeScroll) {
        [self.scrollReadController updateAutoReadStatus:YES];
    } else {
        [self.coverReadController updateAutoReadStatus:YES];
    }
}
- (void)readMenuDidChangeAllowLandscape:(BOOL)yesOrNo {
    if (!yesOrNo) {
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
            // 切换为不允许横屏时若为横屏转态则需要强制旋转屏幕
            XPYChangeInterfaceOrientation(UIInterfaceOrientationPortrait);
        }
    }
    [[XPYReadConfigManager sharedInstance] updateAllowLandscape:yesOrNo];
}

#pragma mark - Gesture recognizer delegete
// 手势覆盖问题处理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer.tag == XPYReadViewLongPressTag || otherGestureRecognizer.tag == XPYReadViewSingleTapTag) {
        return NO;
    }
    return YES;
}
// 根据点击位置判断是否有效点击
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isMemberOfClass:[XPYReadView class]];
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
        _pageViewController = [[XPYPageReadViewController alloc] initWithBook:self.book];
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
        _coverReadController.delegate = self;
        [self.view addSubview:_coverReadController.view];
        [self.view sendSubviewToBack:_coverReadController.view];
    }
    return _coverReadController;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _tap.delegate = self;
    }
    return _tap;
}

#pragma mark - Override methods
// 阅读器设置可以横屏
- (BOOL)shouldAutorotate {
    if ([XPYReadConfigManager sharedInstance].isAutoRead || ![XPYReadConfigManager sharedInstance].isAllowLandscape) {
        // 自动阅读或者设置为不跟随系统横竖屏时不允许横屏
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
