//
//  XPYPageReadViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYPageReadViewController.h"
#import "XPYReadViewController.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"
#import "XPYChapterPageModel.h"

#import "XPYChapterHelper.h"
#import "XPYReadParser.h"
#import "XPYReadRecordManager.h"

@interface XPYPageReadViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, XPYReadViewControllerDelegate>

@property (nonatomic, strong) XPYBookModel *bookModel;

@end

@implementation XPYPageReadViewController

#pragma mark - Initializer
- (instancetype)initWithBook:(XPYBookModel *)book {
    // options:仿真翻页设置书脊的位置为Min
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    if (self) {
        self.bookModel = book;
        if (XPYIsEmptyObject(self.bookModel.chapter.content)) {
            [XPYChapterHelper chapterWithBookId:self.bookModel.bookId chapterId:self.bookModel.chapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                self.bookModel.chapter = [chapter copy];
            } failure:^(NSString * _Nonnull tip) {
                [MBProgressHUD xpy_showTips:@"无章节内容"];
            }];
        }
        // 初始化当前阅读章节
        self.dataSource = self;
        self.delegate = self;
        
        self.doubleSided = YES;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
    
    // 当前章节分页
    NSArray *pageModels = [XPYReadParser parseChapterWithChapterContent:self.bookModel.chapter.content chapterName:self.bookModel.chapter.chapterName];
    self.bookModel.chapter.pageModels = [pageModels copy];
    if (self.bookModel.page >= pageModels.count) {
        // 横竖屏切换可能导致当前页超过总页数
        self.bookModel.page = pageModels.count - 1;
    }
    
    // 设置阅读页
    XPYReadViewController *readViewController = [self createReadViewControllerWithChapter:self.bookModel.chapter pageModel:self.bookModel.chapter.pageModels[self.bookModel.page] isBackView:NO];
    [self setViewControllers:@[readViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // 预加载其他章节
    [self preloadChapters];
}

#pragma mark - Private methods

/// 创建阅读控制器
/// @param chapter 章节Model
/// @param pageModel 页码信息
/// @param isBackView 是否背面视图
- (XPYReadViewController *)createReadViewControllerWithChapter:(XPYChapterModel *)chapter
                                                     pageModel:(XPYChapterPageModel *)pageModel
                                                    isBackView:(BOOL)isBackView {
    XPYReadViewController *readController = [[XPYReadViewController alloc] init];
    [readController setupChapter:chapter pageModel:pageModel isBackView:isBackView];
    readController.delegate = self;
    return readController;
}

/// 获取上一页/下一页页面控制器
/// @param viewController 当前页控制器
/// @param isNext 是否下一页
/// @param isBackView 是否背面视图
- (UIViewController *)viewControllerAfterOrBeforeViewController:(UIViewController *)viewController next:(BOOL)isNext isBackView:(BOOL)isBackView {
    if ([XPYReadConfigManager sharedInstance].pageType == XPYReadPageTypeNone) {
        return nil;
    }
    // 当前页信息
    XPYReadViewController *currentController = (XPYReadViewController *)viewController;
    XPYChapterModel *currentChapter = currentController.chapterModel;
    XPYChapterPageModel *currentPageModel = currentController.pageModel;
    
    UIPageViewControllerNavigationDirection direction = isNext ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    if (!isNext && currentPageModel.pageIndex == 0 && currentChapter.chapterIndex == 1) {
        // 第一章第一页上一页返回空
        [MBProgressHUD xpy_showTips:@"当前为本书第一页"];
        return nil;
    }
    if (isNext && currentPageModel.pageIndex == currentChapter.pageModels.count - 1 && currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章最后一页下一页返回空
        [MBProgressHUD xpy_showTips:@"当前为本书最后一页"];
        return nil;
    }
    if ((isNext && currentPageModel.pageIndex == currentChapter.pageModels.count - 1) || (!isNext && currentPageModel.pageIndex == 0)) {
        // 下一章或上一章
        __block XPYChapterModel *otherChapter = isNext ? [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter] : [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (!otherChapter) {
            return nil;
        }
        if (XPYIsEmptyObject(otherChapter.content)) {
            // 下一章或上一章的章节内容为空
            // 获取章节内容
            [XPYChapterHelper chapterWithBookId:self.bookModel.bookId chapterId:otherChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                otherChapter = [chapter copy];
                otherChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:otherChapter.content chapterName:otherChapter.chapterName] copy];
                if (isNext) {
                    // 下一章第一页
                    XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter pageModel:otherChapter.pageModels.firstObject isBackView:NO];
                    // 背面（这里的背面是当前页的背面）
                    XPYReadViewController *afterBackViewController = [self createReadViewControllerWithChapter:currentChapter pageModel:currentPageModel isBackView:YES];
                    [self setViewControllers:@[afterReadController, afterBackViewController] direction:direction animated:YES completion:nil];
                } else {
                    // 上一章最后一页
                    XPYReadViewController *beforeReadController = [self createReadViewControllerWithChapter:otherChapter pageModel:otherChapter.pageModels.lastObject isBackView:NO];
                    // 背面（这里的背面是上一页的背面，与上一页相同）
                    XPYReadViewController *beforeBackViewController = [self createReadViewControllerWithChapter:otherChapter pageModel:otherChapter.pageModels.lastObject isBackView:YES];
                    [self setViewControllers:@[beforeReadController, beforeBackViewController] direction:direction animated:YES completion:nil];
                }
                // 跨章节时更新阅读记录
                [self updateReadRecord];
            } failure:^(NSString * _Nonnull tip) {
                // 获取章节内容失败
                [MBProgressHUD xpy_showTips:tip];
                XPYReadViewController *readController = [self createReadViewControllerWithChapter:currentChapter pageModel:currentController.pageModel isBackView:NO];
                [self setViewControllers:@[readController] direction:direction animated:NO completion:nil];
            }];
        } else {
            // 上一章/下一章有内容，则直接分页
            otherChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:otherChapter.content chapterName:otherChapter.chapterName] copy];
            XPYReadViewController *readController = [self createReadViewControllerWithChapter:otherChapter pageModel:isNext ? otherChapter.pageModels.firstObject : otherChapter.pageModels.lastObject isBackView:isBackView];
            return readController;
        }
    } else {
        // 正常翻页
        XPYReadViewController *readController = [self createReadViewControllerWithChapter:currentChapter pageModel:isNext ? currentChapter.pageModels[currentPageModel.pageIndex + 1] : currentChapter.pageModels[currentPageModel.pageIndex - 1] isBackView:isBackView];
        return readController;
    }
    return nil;
}

/// 无动画翻页模式获取上一页/下一页并更新阅读页面
/// @param isNext 是否下一页
- (void)updateAfterOrBeforeViewControllerWithNext:(BOOL)isNext {
    // 当前页信息
    XPYReadViewController *currentController = (XPYReadViewController *)self.viewControllers.firstObject;
    XPYChapterModel *currentChapter = currentController.chapterModel;
    XPYChapterPageModel *currentPageModel = currentController.pageModel;
    
    UIPageViewControllerNavigationDirection direction = isNext ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    // 是否需要动画
    BOOL isAnimated = !([XPYReadConfigManager sharedInstance].pageType == XPYReadPageTypeNone);
    if (!isNext && currentPageModel.pageIndex == 0 && currentChapter.chapterIndex == 1) {
        // 第一章第一页上一页返回空
        [MBProgressHUD xpy_showTips:@"当前为本书第一页"];
        return;
    }
    if (isNext && currentPageModel.pageIndex == currentChapter.pageModels.count - 1 && currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章最后一页下一页返回空
        [MBProgressHUD xpy_showTips:@"当前为本书最后一页"];
        return;
    }
    if ((isNext && currentPageModel.pageIndex == currentChapter.pageModels.count - 1) || (!isNext && currentPageModel.pageIndex == 0)) {
        // 下一章或上一章
        XPYChapterModel *otherChapter = isNext ? [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter] : [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (!otherChapter) {
            return;
        }
        if (XPYIsEmptyObject(otherChapter.content)) {
            // 下一章或上一章的章节内容为空
            // 获取章节内容
            [XPYChapterHelper chapterWithBookId:self.bookModel.bookId chapterId:otherChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                otherChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:otherChapter.content chapterName:otherChapter.chapterName] copy];
                if (isNext) {
                    // 下一章第一页
                    XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter pageModel:otherChapter.pageModels.firstObject isBackView:NO];
                    [self setViewControllers:@[afterReadController] direction:direction animated:YES completion:nil];
                } else {
                    // 上一章最后一页
                    XPYReadViewController *beforeReadController = [self createReadViewControllerWithChapter:otherChapter pageModel:otherChapter.pageModels.lastObject isBackView:NO];
                    [self setViewControllers:@[beforeReadController] direction:direction animated:YES completion:nil];
                }
                // 跨章节时更新阅读记录
                [self updateReadRecord];
            } failure:^(NSString * _Nonnull tip) {
                [MBProgressHUD xpy_showTips:tip];
            }];
        } else {
            otherChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:otherChapter.content chapterName:otherChapter.chapterName] copy];
            XPYReadViewController *readController = [self createReadViewControllerWithChapter:otherChapter pageModel:isNext ? otherChapter.pageModels.firstObject : otherChapter.pageModels.lastObject isBackView:NO];
            [self setViewControllers:@[readController] direction:direction animated:isAnimated completion:nil];
        }
    } else {
        // 正常翻页
        XPYReadViewController *readController = [self createReadViewControllerWithChapter:currentChapter pageModel:isNext ? currentChapter.pageModels[currentPageModel.pageIndex + 1] : currentChapter.pageModels[currentPageModel.pageIndex - 1] isBackView:NO];
        [self setViewControllers:@[readController] direction:direction animated:isAnimated completion:nil];
    }
}

/// 更新阅读记录
- (void)updateReadRecord {
    NSString *oldChapterId = self.bookModel.chapter.chapterId;
    
    // 获取当前阅读页面
    XPYReadViewController *currentReadController = self.viewControllers.firstObject;
    self.bookModel.chapter = currentReadController.chapterModel;
    self.bookModel.page = currentReadController.pageModel.pageIndex;
    [XPYReadRecordManager updateReadRecordWithModel:self.bookModel];
    
    // 预加载其他章节
    if (![oldChapterId isEqualToString:self.bookModel.chapter.chapterId]) {
        [self preloadChapters];
    }
}

- (void)preloadChapters {
    // 章节翻页时预加载其他章节
    XPYChapterModel *chapterModel = self.bookModel.chapter;
    if (chapterModel.chapterIndex == 0) {
        // 第一章时预加载下一章
        [XPYChapterHelper preloadNextChapterWithCurrentChapter:chapterModel complete:nil];
    } else if (chapterModel.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章时预加载上一章
        [XPYChapterHelper preloadLastChapterWithCurrentChapter:chapterModel complete:nil];
    } else {
        // 中间章节时同时预加载上一章和下一章
        [XPYChapterHelper preloadNextChapterWithCurrentChapter:chapterModel complete:nil];
        [XPYChapterHelper preloadLastChapterWithCurrentChapter:chapterModel complete:nil];
    }
}

#pragma mark - Page view controller data source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.transitionStyle == UIPageViewControllerTransitionStylePageCurl) {
        XPYReadViewController *readController = (XPYReadViewController *)viewController;
        if (!readController.isBackView) {
            // 不是背面视图时返回下一页为背面视图
            return [self createReadViewControllerWithChapter:readController.chapterModel pageModel:readController.pageModel isBackView:YES];
        }
    }
    // 返回主页面
    return [self viewControllerAfterOrBeforeViewController:viewController next:YES isBackView:NO];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.transitionStyle == UIPageViewControllerTransitionStylePageCurl) {
        XPYReadViewController *readController = (XPYReadViewController *)viewController;
        if (!readController.isBackView) {
            // 不是背面视图时返回上一页为背面视图
            XPYReadViewController *backReadController = (XPYReadViewController *)[self viewControllerAfterOrBeforeViewController:viewController next:NO isBackView:YES];
            return backReadController;
        }
        // 是背面视图时创建上一页为主页面
        return [self createReadViewControllerWithChapter:readController.chapterModel pageModel:readController.pageModel isBackView:NO];
    }
    // 返回主页面
    return [self viewControllerAfterOrBeforeViewController:viewController next:NO isBackView:NO];
}

#pragma mark - Page view controller delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    // 动画开始前走代理方法，隐藏菜单工具栏
    if (self.pageReadDelegate && [self.pageReadDelegate respondsToSelector:@selector(pageReadViewControllerWillTransition)]) {
        [self.pageReadDelegate pageReadViewControllerWillTransition];
    }
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    // 动画完成更新阅读记录
    if (completed) {
        [self updateReadRecord];
    }
}

#pragma mark - XPYReadViewControllerDelegate
- (void)readViewControllerShowNextPage {
    [self updateAfterOrBeforeViewControllerWithNext:YES];
    // 更新阅读记录
    [self updateReadRecord];
    
    // 需要隐藏菜单工具栏
    if (self.pageReadDelegate && [self.pageReadDelegate respondsToSelector:@selector(pageReadViewControllerWillTransition)]) {
        [self.pageReadDelegate pageReadViewControllerWillTransition];
    }
}
- (void)readViewControllerShowLastPage {
    [self updateAfterOrBeforeViewControllerWithNext:NO];
    // 更新阅读记录
    [self updateReadRecord];
    
    // 需要隐藏菜单工具栏
    if (self.pageReadDelegate && [self.pageReadDelegate respondsToSelector:@selector(pageReadViewControllerWillTransition)]) {
        [self.pageReadDelegate pageReadViewControllerWillTransition];
    }
}

@end
