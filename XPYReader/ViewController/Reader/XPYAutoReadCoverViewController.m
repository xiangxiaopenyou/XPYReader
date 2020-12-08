//
//  XPYAutoReadCoverViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/28.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYAutoReadCoverViewController.h"

#import "XPYReadView.h"
#import "XPYAutoReadCoverView.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"
#import "XPYChapterPageModel.h"

#import "XPYReadRecordManager.h"
#import "XPYReadParser.h"
#import "XPYChapterHelper.h"

#import "XPYTimerProxy.h"

@interface XPYAutoReadCoverViewController ()

/// 当前阅读视图
@property (nonatomic, strong) XPYReadView *readView;
/// 覆盖视图
@property (nonatomic, strong) XPYAutoReadCoverView *coverView;
/// 章节名
@property (nonatomic, strong) UILabel *chapterNameLabel;
/// 当前页码
@property (nonatomic, strong) UILabel *currentPageLabel;

/// 自动阅读计时器
@property (nonatomic, strong) CADisplayLink *timer;

/// 当前书籍
@property (nonatomic, strong) XPYBookModel *bookModel;

/// 当前阅读章节
@property (nonatomic, strong) XPYChapterModel *currentChapterModel;
/// 下一章
@property (nonatomic, strong) XPYChapterModel *nextChapterModel;
/// 当前阅读视图页面信息
@property (nonatomic, strong) XPYChapterPageModel *currentPageModel;
/// 是否显示自动阅读菜单（显示菜单时滑动列表不操作启计时器）
@property (nonatomic, assign) BOOL isShowingAutoReadMenu;
/// 拖动开始时覆盖视图高度
@property (nonatomic, assign) CGFloat coverViewPanHeight;

@end

@implementation XPYAutoReadCoverViewController

#pragma mark - Initializer
- (instancetype)initWithBook:(XPYBookModel *)book {
    self = [super init];
    if (self) {
        self.bookModel = book;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置当前阅读章节
    self.currentChapterModel = [self.bookModel.chapter copy];
    // 分页
    NSArray *pageModels = [XPYReadParser parseChapterWithChapterContent:self.currentChapterModel.content chapterName:self.currentChapterModel.chapterName];
    self.currentChapterModel.pageModels = [pageModels copy];
    if (self.bookModel.page >= pageModels.count) {
        // 横竖屏切换可能导致当前页超过总页数
        self.bookModel.page = pageModels.count - 1;
    }
    
    [self configureUI];
    
    [self refreshInformationViews];
    
    // 设置当前页面信息
    self.currentPageModel = self.currentChapterModel.pageModels[self.bookModel.page];
    
    // 设置当前阅读视图内容
    [self.readView setupPageModel:self.currentPageModel chapter:self.currentChapterModel];
    
    if (self.currentChapterModel.chapterIndex != self.bookModel.chapterCount)  {
        // 当前章节不是最后一章，先预加载下一章
        [XPYChapterHelper preloadNextChapterWithCurrentChapter:self.currentChapterModel complete:^(XPYChapterModel * _Nullable nextChapter) {
            if (nextChapter && !XPYIsEmptyObject(nextChapter.content)) {
                // 保存分页信息
                nextChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:nextChapter.content chapterName:nextChapter.chapterName] copy];
                // 设置下一章
                self.nextChapterModel = nextChapter;
            } else {
                self.nextChapterModel = nil;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 配置覆盖视图
                [self configureCoverView];
                // 初始化计时器
                [self loadTimer];
                // 更新覆盖视图内容
                [self updateCoverViewContent];
                // 设置拖动手势
                [self configurePanGesture];
            });
        }];
    } else {
        self.nextChapterModel = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 配置覆盖视图
            [self configureCoverView];
            // 初始化计时器
            [self loadTimer];
            // 更新覆盖视图内容
            [self updateCoverViewContent];
            // 设置拖动手势
            [self configurePanGesture];
        });
    }
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - UI
- (void)configureUI {
    self.view.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
    
    [self.view addSubview:self.readView];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(- XPYReadViewRightSpacing);
        make.top.equalTo(self.view.mas_top).mas_offset(XPYReadViewTopSpacing);
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(- XPYReadViewBottomSpacing);
    }];
    
    [self.view addSubview:self.chapterNameLabel];
    [self.chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.bottom.equalTo(self.readView.mas_top).mas_offset(-10);
        make.width.equalTo(self.readView.mas_width).multipliedBy(0.5).mas_offset(-XPYReadViewLeftSpacing - 5);
    }];
    
    [self.view addSubview:self.currentPageLabel];
    [self.currentPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(-XPYReadViewRightSpacing);
        make.bottom.equalTo(self.readView.mas_top).mas_offset(-10);
    }];
}

/// 初始化拖动手势
- (void)configurePanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCoverView:)];
    [self.view addGestureRecognizer:pan];
}

#pragma mark - Instance methods
- (void)updateAutoReadStatus:(BOOL)status {
    if (![XPYReadConfigManager sharedInstance].isAutoRead) {
        return;
    }
    if (!self.timer) {
        return;
    }
    if ([self currentPageIsLastPage] && self.timer.isPaused) {
        // 最后一页并且计时器已经暂停则不更新状态
        return;
    }
    self.timer.paused = !status;
    // 改变是否显示自动阅读菜单状态
    _isShowingAutoReadMenu = !status;
}

#pragma mark - Private methods
- (void)configureCoverView {
    // 当前页为最后一章最后一页时不需要显示coverView
    if (self.currentPageModel.pageIndex != self.currentChapterModel.pageModels.count - 1 || self.nextChapterModel) {
        [self.view addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.top.equalTo(self.view.mas_top).mas_offset(XPYReadViewTopSpacing - kXPYCoverViewMinHeight);
            make.height.mas_offset(kXPYCoverViewMinHeight);
        }];
    }
}

- (void)refreshInformationViews {
    self.chapterNameLabel.text = self.bookModel.chapter.chapterName;
    self.currentPageLabel.text = [NSString stringWithFormat:@"第%@页/总%@页", @(self.bookModel.page + 1), @(self.bookModel.chapter.pageModels.count)];
}
/// 预加载下一章
- (void)preloadNextChapter {
    if (self.currentChapterModel.chapterIndex == self.bookModel.chapterCount) {
        // 最后一章，下一章设为nil
        self.nextChapterModel = nil;
        return;
    }
    // 预加载下一章
    [XPYChapterHelper preloadNextChapterWithCurrentChapter:self.currentChapterModel complete:^(XPYChapterModel * _Nullable nextChapter) {
        if (nextChapter && !XPYIsEmptyObject(nextChapter.content)) {
            // 保存分页信息
            nextChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:nextChapter.content chapterName:nextChapter.chapterName] copy];
            // 插入预加载的下一个章节到当前阅读中
            self.nextChapterModel = [nextChapter copy];
        }
    }];
}

/// 加载下一页
- (void)loadNextPage {
    if (self.currentPageModel.pageIndex == self.currentChapterModel.pageModels.count - 1) {
        // 当前readView为当前章节最后一页
        if (!self.nextChapterModel) {
            // 无下一章内容（最后一章或者下一章并未加载）
            return;
        }
        // 更新当前章节
        self.currentChapterModel = self.nextChapterModel;
        // 先设置下一章节为空
        self.nextChapterModel = nil;
        // 预加载下一章节
        [self preloadNextChapter];
        // 更新当前页信息
        self.currentPageModel = self.currentChapterModel.pageModels.firstObject;
        // 更新阅读记录
        [self updateReadRecord];
        // 更新视图
        [self.readView setupPageModel:self.currentPageModel chapter:self.currentChapterModel];
        // 更新覆盖视图
        [self updateCoverViewContent];
    } else {
        // 直接加载当前章节下一页
        self.currentPageModel = self.currentChapterModel.pageModels[self.currentPageModel.pageIndex + 1];
        // 更新阅读记录
        [self updateReadRecord];
        [self.readView setupPageModel:self.currentPageModel chapter:self.currentChapterModel];
        [self updateCoverViewContent];
    }
}

/// 更新覆盖视图内容（当前readView的下一页）
- (void)updateCoverViewContent {
    if (self.currentPageModel.pageIndex == self.currentChapterModel.pageModels.count - 1) {
        // 当前readView为当前章节最后一页
        if (!self.nextChapterModel) {
            // 无下一章内容
            [self updateAutoReadStatus:NO];
            if (self.currentChapterModel.chapterIndex == self.bookModel.chapterCount) {
                // 最后一章最后一页
                [MBProgressHUD xpy_showTips:@"当前为本书最后一页"];
                if (self.delegate && [self.delegate respondsToSelector:@selector(autoReadCoverViewControllerDidEndEnding)]) {
                    [self.delegate autoReadCoverViewControllerDidEndEnding];
                }
            } else {
                // 设置覆盖视图为下一章第一页
                [self.coverView updateCurrentChapter:self.nextChapterModel pageModel:self.nextChapterModel.pageModels.firstObject];
            }
        } else {
            // 设置覆盖视图为下一章第一页
            [self.coverView updateCurrentChapter:self.nextChapterModel pageModel:self.nextChapterModel.pageModels.firstObject];
        }
    } else {
        [self.coverView updateCurrentChapter:self.currentChapterModel pageModel:self.currentChapterModel.pageModels[self.currentPageModel.pageIndex + 1]];
    }
}

/// 更新覆盖视图高度
- (void)updateCoverViewConstraints:(CGFloat)constraints {
    [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(constraints);
    }];
    [self.view layoutIfNeeded];
}

/// 更新阅读记录
- (void)updateReadRecord {
    self.bookModel.chapter = self.currentChapterModel;
    self.bookModel.page = self.currentPageModel.pageIndex;
    [XPYReadRecordManager updateReadRecordWithModel:self.bookModel];
    
    [self refreshInformationViews];
}

/// 加载计时器
- (void)loadTimer {
    self.timer = [CADisplayLink displayLinkWithTarget:[XPYTimerProxy proxyWithTarget:self] selector:@selector(autoRead:)];
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.timer.paused = NO;
}

/// 判断当前页是否最后一页
- (BOOL)currentPageIsLastPage {
    if (self.currentPageModel.pageIndex == self.currentChapterModel.pageModels.count - 1 && !self.nextChapterModel) {
        return YES;
    }
    return NO;
}

#pragma mark - Event response
- (void)autoRead:(CADisplayLink *)timer {
    CGFloat speed = [XPYReadConfigManager sharedInstance].autoReadSpeed / 8.0 + 0.35;
    //覆盖模式覆盖视图高度变化
    CGFloat currentHeight = CGRectGetHeight(self.coverView.frame);
    if (currentHeight > kXPYCoverViewMaxHeight) {
        // 覆盖视图高度超过页面高度
        // 加载下一页
        [self loadNextPage];
        // 重置覆盖视图到初始位置
        [self updateCoverViewConstraints:kXPYCoverViewMinHeight];
    } else {
        [self updateCoverViewConstraints:currentHeight + speed];
    }
}
- (void)panCoverView:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            // 手势开始暂停计时器
            self.timer.paused = YES;
            // 记录开始时覆盖视图高度
            self.coverViewPanHeight = CGRectGetHeight(self.coverView.frame);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            // 移动坐标
            CGPoint point = [pan translationInView:self.view];
            CGFloat changedHeight = self.coverViewPanHeight + point.y;
            if (changedHeight < kXPYCoverViewMinHeight) {
                [self updateCoverViewConstraints:kXPYCoverViewMinHeight];
            } else if (changedHeight > kXPYCoverViewMaxHeight) {
                [self updateCoverViewConstraints:kXPYCoverViewMaxHeight];
            } else {
                [self updateCoverViewConstraints:changedHeight];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.timer.paused = NO;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Getters
- (XPYReadView *)readView {
    if (!_readView) {
        _readView = [[XPYReadView alloc] initWithFrame:CGRectMake(XPYReadViewLeftSpacing, XPYReadViewTopSpacing, XPYReadViewWidth, XPYReadViewHeight)];
    }
    return _readView;
}
- (XPYAutoReadCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[XPYAutoReadCoverView alloc] initWithFrame:CGRectMake(0, XPYReadViewTopSpacing - kXPYCoverViewMinHeight, XPYScreenWidth, kXPYCoverViewMinHeight)];
    }
    return _coverView;
}
- (UILabel *)chapterNameLabel {
    if (!_chapterNameLabel) {
        _chapterNameLabel = [[UILabel alloc] init];
        _chapterNameLabel.textColor = [XPYReadConfigManager sharedInstance].currentTextColor;
        _chapterNameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _chapterNameLabel;
}
- (UILabel *)currentPageLabel {
    if (!_currentPageLabel) {
        _currentPageLabel = [[UILabel alloc] init];
        _currentPageLabel.textColor = [XPYReadConfigManager sharedInstance].currentTextColor;
        _currentPageLabel.font = [UIFont systemFontOfSize:12];
    }
    return _currentPageLabel;
}

@end
