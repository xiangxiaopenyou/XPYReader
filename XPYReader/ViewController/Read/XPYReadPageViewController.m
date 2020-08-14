//
//  XPYReadPageViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadPageViewController.h"
#import "XPYReadViewController.h"

#import "XPYReadMenu.h"

#import "XPYChapterModel.h"
#import "XPYBookModel.h"

#import "XPYReadParser.h"
#import "XPYReadHelper.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"

#import "XPYNetworkService+Chapter.h"

/// 阅读器文字区域Rect
#define kXPYReadViewBounds CGRectMake(0, 0, XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing, XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)

@interface XPYReadPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, XPYReadMenuDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

/// 菜单工具栏管理
@property (nonatomic, strong) XPYReadMenu *readMenu;

@property (nonatomic, copy) NSArray <XPYChapterModel *> *chapters;  // 章节信息

@end

@implementation XPYReadPageViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    // 获取章节信息
    [XPYChapterHelper chaptersWithBookId:self.book.bookId success:^(NSArray * _Nonnull chapters) {
        self.chapters = chapters;
    } failure:^(NSString * _Nonnull tip) {
        [MBProgressHUD xpy_showTips:tip];
    }];
    
    // 当前章节分页并设置阅读页
    [XPYReadParser parseChapterWithContent:self.book.chapter.content chapterName:self.book.chapter.chapterName bounds:kXPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
        dispatch_async(dispatch_get_main_queue(), ^{
            XPYReadViewController *readViewController = [self createReadViewControllerWithChapter:self.book.chapter chapterContent:chapterContent pageRanges:pageRanges page:self.book.page pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:self.book.page pageRanges:pageRanges]];
            [self.pageViewController setViewControllers:@[readViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        });
    }];
    
    // 初始化菜单工具栏
    self.readMenu = [[XPYReadMenu alloc] initWithView:self.view];
    self.readMenu.delegate = self;
    
    // 点击事件（弹出工具栏）
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // 屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)configureUI {
    // 隐藏导航栏
    self.fd_prefersNavigationBarHidden = YES;
    // 取消右滑返回手势
    self.fd_interactivePopDisabled = YES;
    [self addChildViewController:self.pageViewController];
}

#pragma mark - Network

/// 章节内容网络请求
/// @param chapterId 章节Id
/// @param success 成功回调
- (void)chapterContentRequestWithChapter:(NSString *)chapterId success:(XPYSuccessHandler)success {
    [[XPYNetworkService sharedService] chapterContentWithBookId:self.book.bookId chapterId:chapterId success:^(id result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        [MBProgressHUD xpy_showTips:@"网络错误"];
    }];
}

#pragma mark - Private methods

/// 创建阅读控制器
/// @param chapter 章节Model
/// @param chapterContent 章节全部内容
/// @param pageRanges 章节分页
/// @param page 控制器章节页码
/// @param pageContent 页码内容
- (XPYReadViewController *)createReadViewControllerWithChapter:(XPYChapterModel *)chapter
                                                chapterContent:(NSAttributedString *)chapterContent
                                                    pageRanges:(NSArray *)pageRanges
                                                          page:(NSInteger)page
                                                   pageContent:(NSAttributedString *)pageContent {
    XPYReadViewController *readController = [[XPYReadViewController alloc] init];
    [readController setupChapter:chapter chapterContent:chapterContent pageRanges:pageRanges page:page pageContent:pageContent];
    return readController;
}

/// 获取上一页/下一页页面控制器
/// @param viewController 当前页控制器
/// @param isAfter 是否下一页
- (UIViewController *)viewControllerAfterOrBeforeViewController:(UIViewController *)viewController after:(BOOL)isAfter {
    // 当前页信息
    XPYReadViewController *currentController = (XPYReadViewController *)viewController;
    XPYChapterModel *currentChapter = currentController.chapterModel;
    NSInteger currentChapterIndex = currentController.chapterIndex;
    NSInteger currentPage = currentController.page;
    NSAttributedString *currentChapterContent = currentController.chapterContent;
    NSArray *currentPageRanges = [currentController.pageRanges copy];
    
    UIPageViewControllerNavigationDirection direction = isAfter ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    if (!isAfter && currentPage == 0 && currentChapterIndex == 0) {
        // 第一章第一页上一页返回空
        return nil;
    }
    if (isAfter && currentPage == currentPageRanges.count - 1 && currentChapterIndex == self.chapters.count - 1) {
        // 最后一章最后一页下一页返回空
        return nil;
    }
    if ((isAfter && currentPage == currentPageRanges.count - 1) || (!isAfter && currentPage == 0)) {
        // 下一章或上一章
        XPYChapterModel *otherChapter = isAfter ? self.chapters[currentChapterIndex + 1] : self.chapters[currentChapterIndex - 1];
        if (XPYIsEmptyObject(otherChapter.content)) {
            // 下一章或上一章的章节内容为空
            // 获取章节内容
            [XPYChapterHelper chapterWithBookId:self.book.bookId chapterId:otherChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                [XPYReadParser parseChapterWithContent:chapter.content chapterName:chapter.chapterName bounds:kXPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                    if (isAfter) {
                        // 下一章第一页
                        XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter chapterContent:chapterContent pageRanges:pageRanges page:0 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:0 pageRanges:pageRanges]];
                        [self.pageViewController setViewControllers:@[afterReadController] direction:direction animated:YES completion:nil];
                    } else {
                        // 上一章最后一页
                        XPYReadViewController *beforeReadController = [self createReadViewControllerWithChapter:otherChapter chapterContent:chapterContent pageRanges:pageRanges page:pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:pageRanges.count - 1 pageRanges:pageRanges]];
                        [self.pageViewController setViewControllers:@[beforeReadController] direction:direction animated:YES completion:nil];
                    }
                    // 跨章节时更新阅读记录
                    [self updateReadRecord];
                }];
            } failure:^(NSString * _Nonnull tip) {
                [MBProgressHUD xpy_showTips:tip];
            }];
        } else {
            __block XPYReadViewController *readController;
            [XPYReadParser parseChapterWithContent:otherChapter.content chapterName:otherChapter.chapterName bounds:kXPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                readController = [self createReadViewControllerWithChapter:otherChapter chapterContent:chapterContent pageRanges:pageRanges page:isAfter ? 0 : pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:isAfter ? 0 : pageRanges.count - 1 pageRanges:pageRanges]];
            }];
            return readController;
        }
    } else {
        // 正常翻页
        XPYReadViewController *readController = [self createReadViewControllerWithChapter:currentChapter chapterContent:currentChapterContent pageRanges:currentPageRanges page:isAfter ? currentPage + 1 : currentPage - 1 pageContent:[XPYReadParser pageContentWithChapterContent:currentChapterContent page:isAfter ? currentPage + 1 : currentPage - 1 pageRanges:currentPageRanges]];
        return readController;
    }
    return nil;
}

/// 更新阅读记录
- (void)updateReadRecord {
    // 获取当前阅读页面
    XPYReadViewController *currentReadController = self.pageViewController.viewControllers.firstObject;
    self.book.chapter = currentReadController.chapterModel;
    self.book.page = currentReadController.page;
    [XPYReadRecordManager insertOrReplaceRecordWithModel:self.book];
}

#pragma mark - Actions
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.view];
    CGFloat width = CGRectGetWidth(self.view.bounds) / 3.0;
    if (touchPoint.x > width && touchPoint.x < width * 2) {
        NSLog(@"弹出工具栏");
        [self.readMenu show];
    }
}

#pragma mark - Notifications
/// 屏幕方向旋转
- (void)orientationChanged:(NSNotification *)notification {
}

#pragma mark - XPYReadMenuDelegate
- (void)readMenuDidClickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Page view controller data source
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    return [self viewControllerAfterOrBeforeViewController:viewController after:YES];
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    return [self viewControllerAfterOrBeforeViewController:viewController after:NO];
}

#pragma mark - Page view controller delegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    // 动画完成更新阅读记录
    [self updateReadRecord];
}

#pragma mark - Gesture recognizer delegete
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Getters
- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)}];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        _pageViewController.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
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
