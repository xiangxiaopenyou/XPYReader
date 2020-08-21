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
#import "XPYChapterHelper.h"
#import "XPYReadParser.h"
#import "XPYReadRecordManager.h"

@interface XPYPageReadViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, XPYReadViewControllerDelegate>

@property (nonatomic, strong) XPYBookModel *bookModel;

@end

@implementation XPYPageReadViewController

#pragma mark - Initializer
- (instancetype)initWithBook:(XPYBookModel *)book pageType:(XPYReadPageType)pageType {
    UIPageViewControllerTransitionStyle style = pageType == XPYReadPageTypeCurl ? UIPageViewControllerTransitionStylePageCurl : UIPageViewControllerTransitionStyleScroll;
    // options:仿真翻页时设置书脊的位置为Min，滑动翻页时设置页面间距为0
    NSDictionary *options = style == UIPageViewControllerTransitionStylePageCurl ? @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)} : @{UIPageViewControllerOptionInterPageSpacingKey : @0};
    self = [super initWithTransitionStyle:style navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
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
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 当前章节分页并设置阅读页
    [XPYReadParser parseChapterWithContent:self.bookModel.chapter.content chapterName:self.bookModel.chapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
        self.bookModel.chapter.attributedContent = chapterContent;
        self.bookModel.chapter.pageRanges = [pageRanges copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            XPYReadViewController *readViewController = [self createReadViewControllerWithChapter:self.bookModel.chapter page:self.bookModel.page pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:self.bookModel.page pageRanges:pageRanges]];
            [self setViewControllers:@[readViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        });
    }];
    
    // 预加载其他章节
    [self preloadChapters];
}

#pragma mark - UI
- (void)configureUI {
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Private methods

/// 创建阅读控制器
/// @param chapter 章节Model
/// @param page 控制器章节页码
/// @param pageContent 页码内容
- (XPYReadViewController *)createReadViewControllerWithChapter:(XPYChapterModel *)chapter
                                                          page:(NSInteger)page
                                                   pageContent:(NSAttributedString *)pageContent {
    XPYReadViewController *readController = [[XPYReadViewController alloc] init];
    [readController setupChapter:chapter page:page pageContent:pageContent];
    readController.delegate = self;
    return readController;
}

/// 获取上一页/下一页页面控制器
/// @param viewController 当前页控制器
/// @param isNext 是否下一页
- (UIViewController *)viewControllerAfterOrBeforeViewController:(UIViewController *)viewController next:(BOOL)isNext {
    // 当前页信息
    XPYReadViewController *currentController = (XPYReadViewController *)viewController;
    XPYChapterModel *currentChapter = currentController.chapterModel;
    NSInteger currentPage = currentController.page;
    NSAttributedString *currentChapterContent = currentController.chapterModel.attributedContent;
    NSArray *currentPageRanges = [currentController.chapterModel.pageRanges copy];
    
    UIPageViewControllerNavigationDirection direction = isNext ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    if (!isNext && currentPage == 0 && currentChapter.chapterIndex == 1) {
        // 第一章第一页上一页返回空
        return nil;
    }
    if (isNext && currentPage == currentPageRanges.count - 1 && currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章最后一页下一页返回空
        return nil;
    }
    if ((isNext && currentPage == currentPageRanges.count - 1) || (!isNext && currentPage == 0)) {
        // 下一章或上一章
        XPYChapterModel *otherChapter = isNext ? [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter] : [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (!otherChapter) {
            return nil;
        }
        if (XPYIsEmptyObject(otherChapter.content)) {
            // 下一章或上一章的章节内容为空
            // 获取章节内容
            [XPYChapterHelper chapterWithBookId:self.bookModel.bookId chapterId:otherChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                [XPYReadParser parseChapterWithContent:chapter.content chapterName:chapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                    otherChapter.attributedContent = chapterContent;
                    otherChapter.pageRanges = [pageRanges copy];
                    if (isNext) {
                        // 下一章第一页
                        XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter page:0 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:0 pageRanges:pageRanges]];
                        [self setViewControllers:@[afterReadController] direction:direction animated:YES completion:nil];
                    } else {
                        // 上一章最后一页
                        XPYReadViewController *beforeReadController = [self createReadViewControllerWithChapter:otherChapter page:pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:pageRanges.count - 1 pageRanges:pageRanges]];
                        [self setViewControllers:@[beforeReadController] direction:direction animated:YES completion:nil];
                    }
                    // 跨章节时更新阅读记录
                    [self updateReadRecord];
                }];
            } failure:^(NSString * _Nonnull tip) {
                [MBProgressHUD xpy_showTips:tip];
            }];
        } else {
            __block XPYReadViewController *readController;
            [XPYReadParser parseChapterWithContent:otherChapter.content chapterName:otherChapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                otherChapter.attributedContent = chapterContent;
                otherChapter.pageRanges = [pageRanges copy];
                readController = [self createReadViewControllerWithChapter:otherChapter page:isNext ? 0 : pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:isNext ? 0 : pageRanges.count - 1 pageRanges:pageRanges]];
            }];
            return readController;
        }
    } else {
        // 正常翻页
        XPYReadViewController *readController = [self createReadViewControllerWithChapter:currentChapter page:isNext ? currentPage + 1 : currentPage - 1 pageContent:[XPYReadParser pageContentWithChapterContent:currentChapterContent page:isNext ? currentPage + 1 : currentPage - 1 pageRanges:currentPageRanges]];
        return readController;
    }
    return nil;
}

/// 左右平移或者无动画翻页模式获取上一页/下一页并更新阅读页面
/// @param isNext 是否下一页
- (void)updateAfterOrBeforeViewControllerWithNext:(BOOL)isNext {
    // 当前页信息
    XPYReadViewController *currentController = (XPYReadViewController *)self.viewControllers.firstObject;
    XPYChapterModel *currentChapter = currentController.chapterModel;
    NSInteger currentPage = currentController.page;
    NSAttributedString *currentChapterContent = currentController.chapterModel.attributedContent;
    NSArray *currentPageRanges = [currentController.chapterModel.pageRanges copy];
    UIPageViewControllerNavigationDirection direction = isNext ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    // 是否需要动画
    BOOL isAnimated = !([XPYReadConfigManager sharedInstance].pageType == XPYReadPageTypeNone);
    if (!isNext && currentPage == 0 && currentChapter.chapterIndex == 1) {
        // 第一章第一页上一页直接返回
        return;
    }
    if (isNext && currentPage == currentPageRanges.count - 1 && currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章最后一页下一页直接返回
        return;
    }
    if ((isNext && currentPage == currentPageRanges.count - 1) || (!isNext && currentPage == 0)) {
        // 下一章或上一章
        XPYChapterModel *otherChapter = isNext ? [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter] : [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (!otherChapter) {
            return;
        }
        if (XPYIsEmptyObject(otherChapter.content)) {
            // 下一章或上一章的章节内容为空
            // 获取章节内容
            [XPYChapterHelper chapterWithBookId:self.bookModel.bookId chapterId:otherChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                [XPYReadParser parseChapterWithContent:chapter.content chapterName:chapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                    otherChapter.attributedContent = chapterContent;
                    otherChapter.pageRanges = [pageRanges copy];
                    if (isNext) {
                        // 下一章第一页
                        XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter page:0 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:0 pageRanges:pageRanges]];
                        [self setViewControllers:@[afterReadController] direction:direction animated:isAnimated completion:nil];
                    } else {
                        // 上一章最后一页
                        XPYReadViewController *beforeReadController = [self createReadViewControllerWithChapter:otherChapter page:pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:pageRanges.count - 1 pageRanges:pageRanges]];
                        [self setViewControllers:@[beforeReadController] direction:direction animated:isAnimated completion:nil];
                    }
                    // 跨章节时更新阅读记录
                    [self updateReadRecord];
                }];
            } failure:^(NSString * _Nonnull tip) {
                [MBProgressHUD xpy_showTips:tip];
            }];
        } else {
            // 内容不为空则直接分页显示
            [XPYReadParser parseChapterWithContent:otherChapter.content chapterName:otherChapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                otherChapter.attributedContent = chapterContent;
                otherChapter.pageRanges = [pageRanges copy];
                XPYReadViewController *readController = [self createReadViewControllerWithChapter:otherChapter page:isNext ? 0 : pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:isNext ? 0 : pageRanges.count - 1 pageRanges:pageRanges]];
                [self setViewControllers:@[readController] direction:direction animated:isAnimated completion:nil];
            }];
        }
    } else {
        // 正常翻页
        XPYReadViewController *readController = [self createReadViewControllerWithChapter:currentChapter page:isNext ? currentPage + 1 : currentPage - 1 pageContent:[XPYReadParser pageContentWithChapterContent:currentChapterContent page:isNext ? currentPage + 1 : currentPage - 1 pageRanges:currentPageRanges]];
        [self setViewControllers:@[readController] direction:direction animated:isAnimated completion:nil];
    }
}

/// 更新阅读记录
- (void)updateReadRecord {
    NSString *oldChapterId = self.bookModel.chapter.chapterId;
    
    // 获取当前阅读页面
    XPYReadViewController *currentReadController = self.viewControllers.firstObject;
    self.bookModel.chapter = currentReadController.chapterModel;
    self.bookModel.page = currentReadController.page;
    [XPYReadRecordManager insertOrReplaceRecordWithModel:self.bookModel];
    
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
    return [self viewControllerAfterOrBeforeViewController:viewController next:YES];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self viewControllerAfterOrBeforeViewController:viewController next:NO];
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
