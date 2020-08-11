//
//  XPYReadPageViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadPageViewController.h"
#import "XPYReadViewController.h"

#import "XPYChapterModel.h"

#import "XPYReadParser.h"

#import "XPYNetworkService+Chapter.h"

/// 阅读器文字区域Rect
#define kXPYReadViewBounds CGRectMake(0, 0, XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing, XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)

@interface XPYReadPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation XPYReadPageViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.pageViewController];
    
    if (!self.book.chapter) {
        if (self.chapters.count == 0) {
            [MBProgressHUD xpy_showTips:@"章节为空"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        self.book.chapter = self.chapters[0];
    }
    if (XPYIsEmptyObject(self.book.chapter.content)) {
        // 当前章节内容为空
        [self resolveEmptyChapterContentWithChapter:self.book.chapter complete:^(NSAttributedString *chapterContent, NSArray *pageRanges) {
            dispatch_async(dispatch_get_main_queue(), ^{
                XPYReadViewController *readViewController = [self createReadViewControllerWithChapter:self.book.chapter chapterContent:chapterContent pageRanges:pageRanges page:self.book.page pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:self.book.page pageRanges:pageRanges]];
                [self.pageViewController setViewControllers:@[readViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            });
        }];
    }
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

/// 章节内容为空情况处理
/// @param chapterModel 章节基本信息
/// @param complete 处理完成回调
- (void)resolveEmptyChapterContentWithChapter:(XPYChapterModel *)chapterModel complete:(void (^)(NSAttributedString *chapterContent, NSArray *pageRanges))complete {
    [self chapterContentRequestWithChapter:chapterModel.chapterId success:^(id result) {
        chapterModel.content = (NSString *)result;
        [XPYReadParser parseChapterWithContent:chapterModel.content chapterName:chapterModel.chapterName bounds:kXPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
            if (complete) {
                complete(chapterContent, pageRanges);
            }
        }];
    }];
}

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
            __block XPYReadViewController *readController;
            [self resolveEmptyChapterContentWithChapter:otherChapter complete:^(NSAttributedString *chapterContent, NSArray *pageRanges) {
                if (isAfter) {
                    // 后一页设置为非镜像
                    XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter chapterContent:chapterContent pageRanges:pageRanges page:0 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:0 pageRanges:pageRanges]];
                    [self.pageViewController setViewControllers:@[afterReadController] direction:direction animated:YES completion:nil];
                } else {
                    
                }
            }];
            return readController;
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



@end
