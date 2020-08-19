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

@interface XPYPageReadViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) XPYBookModel *bookModel;

/// 当前阅读章节数组(只保存本次阅读列表)
@property (nonatomic, strong) NSMutableArray <XPYChapterModel *> *chaptersArray;

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
        self.chaptersArray = [@[book.chapter] mutableCopy];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            XPYReadViewController *readViewController = [self createReadViewControllerWithChapter:self.bookModel.chapter chapterContent:chapterContent pageRanges:pageRanges page:self.bookModel.page pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:self.bookModel.page pageRanges:pageRanges]];
            [self setViewControllers:@[readViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        });
    }];
}

#pragma mark - UI
- (void)configureUI {
    self.view.backgroundColor = [UIColor whiteColor];
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
    NSInteger currentPage = currentController.page;
    NSAttributedString *currentChapterContent = currentController.chapterContent;
    NSArray *currentPageRanges = [currentController.pageRanges copy];
    
    UIPageViewControllerNavigationDirection direction = isAfter ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    if (!isAfter && currentPage == 0 && currentChapter.chapterIndex == 1) {
        // 第一章第一页上一页返回空
        return nil;
    }
    if (isAfter && currentPage == currentPageRanges.count - 1 && currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章最后一页下一页返回空
        return nil;
    }
    if ((isAfter && currentPage == currentPageRanges.count - 1) || (!isAfter && currentPage == 0)) {
        // 下一章或上一章
        XPYChapterModel *otherChapter = isAfter ? [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter] : [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (!otherChapter) {
            return nil;
        }
        if (XPYIsEmptyObject(otherChapter.content)) {
            // 下一章或上一章的章节内容为空
            // 获取章节内容
            [XPYChapterHelper chapterWithBookId:self.bookModel.bookId chapterId:otherChapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                [XPYReadParser parseChapterWithContent:chapter.content chapterName:chapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                    if (isAfter) {
                        // 下一章第一页
                        XPYReadViewController *afterReadController = [self createReadViewControllerWithChapter:otherChapter chapterContent:chapterContent pageRanges:pageRanges page:0 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:0 pageRanges:pageRanges]];
                        [self setViewControllers:@[afterReadController] direction:direction animated:YES completion:nil];
                    } else {
                        // 上一章最后一页
                        XPYReadViewController *beforeReadController = [self createReadViewControllerWithChapter:otherChapter chapterContent:chapterContent pageRanges:pageRanges page:pageRanges.count - 1 pageContent:[XPYReadParser pageContentWithChapterContent:chapterContent page:pageRanges.count - 1 pageRanges:pageRanges]];
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
    XPYReadViewController *currentReadController = self.viewControllers.firstObject;
    self.bookModel.chapter = currentReadController.chapterModel;
    self.bookModel.page = currentReadController.page;
    [XPYReadRecordManager insertOrReplaceRecordWithModel:self.bookModel];
}

#pragma mark - Page view controller data source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self viewControllerAfterOrBeforeViewController:viewController after:YES];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self viewControllerAfterOrBeforeViewController:viewController after:NO];
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
    [self updateReadRecord];
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

@end
