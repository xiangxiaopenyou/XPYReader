//
//  XPYScrollReadViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYScrollReadViewController.h"
#import "XPYScrollReadTableViewCell.h"
#import "XPYReadView.h"

#import "XPYReadParser.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"
#import "XPYChapterPageModel.h"

#import "XPYTimerProxy.h"

/// 列表滚动到达位置
typedef NS_ENUM(NSInteger, XPYScrollReadPosition) {
    XPYScrollReadPositionNormal,     // 正常位置
    XPYScrollReadPositionTop,        // 顶部
    XPYScrollReadPositionBottom      // 底部
};

static NSString * const kXPYScrollReadViewCellIdentifierKey = @"XPYScrollReadViewCellIdentifier";

@interface XPYScrollReadViewController () <UITableViewDataSource, UITableViewDelegate>

/// 主阅读视图列表
@property (nonatomic, strong) UITableView *tableView;
/// 章节名
@property (nonatomic, strong) UILabel *chapterNameLabel;
/// 当前页码
@property (nonatomic, strong) UILabel *currentPageLabel;

/// 当前书籍
@property (nonatomic, strong) XPYBookModel *bookModel;
/// 当前阅读章节ID数组
@property (nonatomic, strong) NSMutableArray <NSString *> *chapterIds;
/// 正在预加载的章节ID数组
@property (nonatomic, strong) NSMutableArray <NSString *> *preloadingChapterIds;
/// 当前阅读章节数组(只保存本次阅读列表)
@property (nonatomic, strong) NSMutableArray <XPYChapterModel *> *chapters;
/// 列表滚动方式是否向下
@property (nonatomic, assign) BOOL isScrollOrientationDown;
/// 列表OffsetY坐标，用于判断列表滚动方向
@property (nonatomic, assign) CGFloat tableOffsetY;
/// 列表当前位置
@property (nonatomic, assign) XPYScrollReadPosition scrollViewPosition;
/// 自动阅读计时器
@property (nonatomic, strong) CADisplayLink *autoReadTimer;
/// 是否显示自动阅读菜单（显示菜单时滑动列表不操作启计时器）
@property (nonatomic, assign) BOOL isShowingAutoReadMenu;

@end

@implementation XPYScrollReadViewController

#pragma mark - Initializer
- (instancetype)initWithBook:(XPYBookModel *)book {
    self = [super init];
    if (self) {
        self.bookModel = book;
        // 初始化数组
        self.chapterIds = [@[book.chapter.chapterId] mutableCopy];
        self.chapters = [@[book.chapter] mutableCopy];
        self.preloadingChapterIds = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    XPYChapterModel *currentChapter = self.chapters.firstObject;
    // 分页(避免横竖屏错位问题)
    NSArray *pageModels = [XPYReadParser parseChapterWithChapterContent:currentChapter.content chapterName:currentChapter.chapterName];
    currentChapter.pageModels = [pageModels copy];
    if (self.bookModel.page >= pageModels.count) {
        // 横竖屏切换可能导致当前页超过总页数
        self.bookModel.page = pageModels.count - 1;
    }
    
    [self configureUI];
    
    [self refreshInformationViews];
    
    // 列表滚动至阅读记录位置
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.bookModel.page inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    if ([XPYReadConfigManager sharedInstance].isAutoRead) {
        [self loadTimer];
    }
}

- (void)dealloc {
    if (self.autoReadTimer) {
        [self.autoReadTimer invalidate];
        self.autoReadTimer = nil;
    }
}

#pragma mark - UI
- (void)configureUI {
    self.view.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.chapterNameLabel];
    [self.chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.bottom.equalTo(self.tableView.mas_top).mas_offset(-10);
        make.width.equalTo(self.tableView.mas_width).multipliedBy(0.5).mas_offset(-XPYReadViewLeftSpacing - 5);
    }];
    
    [self.view addSubview:self.currentPageLabel];
    [self.currentPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(-XPYReadViewRightSpacing);
        make.bottom.equalTo(self.tableView.mas_top).mas_offset(-10);
    }];
}      

#pragma mark - Instance methods
- (void)updateAutoReadStatus:(BOOL)status {
    if (![XPYReadConfigManager sharedInstance].isAutoRead) {
        return;
    }
    if (!self.autoReadTimer) {
        return;
    }
    if ([self isScrollAtBottom] && self.autoReadTimer.isPaused) {
        return;
    }
    self.autoReadTimer.paused = !status;
    // 改变是否显示自动阅读菜单状态
    _isShowingAutoReadMenu = !status;
}

#pragma mark - Private methods
- (void)refreshInformationViews {
    self.chapterNameLabel.text = self.bookModel.chapter.chapterName;
    self.currentPageLabel.text = [NSString stringWithFormat:@"第%@页/总%@页", @(self.bookModel.page + 1), @(self.bookModel.chapter.pageModels.count)];
}
- (void)preloadChapters {
    XPYChapterModel *currentChapter = self.bookModel.chapter;
    if (currentChapter.chapterIndex == 1) {
        // 当前为第一章
        XPYChapterModel *tempChapter = [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter];
        if (!tempChapter || [self.chapterIds containsObject:tempChapter.chapterId] || [self.preloadingChapterIds containsObject:tempChapter.chapterId]) {
            // 章节获取失败或者当前阅读数组已存在或者正在加载
            return;
        }
        // 保存正在加载章节ID
        [self.preloadingChapterIds addObject:tempChapter.chapterId];
        // 加载下一章
        [self preloadNextChapterOfCurrentChapter:currentChapter];
    } else if (currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 当前为最后一章
        XPYChapterModel *tempChapter = [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (!tempChapter || [self.chapterIds containsObject:tempChapter.chapterId] || [self.preloadingChapterIds containsObject:tempChapter.chapterId]) {
            // 章节获取失败或者当前阅读数组已存在或者正在加载
            return;
        }
        // 保存正在加载章节ID
        [self.preloadingChapterIds addObject:tempChapter.chapterId];
        // 加载上一章
        [self preloadLastChapterOfCurrentChapter:currentChapter];
    } else {
        // 当前为中间章节
        XPYChapterModel *tempNextChapter = [XPYChapterHelper nextChapterOfCurrentChapter:currentChapter];
        XPYChapterModel *tempLastChapter = [XPYChapterHelper lastChapterOfCurrentChapter:currentChapter];
        if (tempNextChapter && ![self.chapterIds containsObject:tempNextChapter.chapterId] && ![self.preloadingChapterIds containsObject:tempNextChapter.chapterId]) {
            // 保存正在加载章节ID
            [self.preloadingChapterIds addObject:tempNextChapter.chapterId];
            // 加载下一章
            [self preloadNextChapterOfCurrentChapter:currentChapter];
        }
        if (tempLastChapter && ![self.chapterIds containsObject:tempLastChapter.chapterId] && ![self.chapterIds containsObject:tempLastChapter.chapterId]) {
            // 保存正在加载章节ID
            [self.preloadingChapterIds addObject:tempLastChapter.chapterId];
            // 加载上一章
            [self preloadLastChapterOfCurrentChapter:currentChapter];
        }
    }
}

/// 加载当前章节下一章
/// @param currentChapter 当前章节
- (void)preloadNextChapterOfCurrentChapter:(XPYChapterModel *)currentChapter {
    [XPYChapterHelper preloadNextChapterWithCurrentChapter:currentChapter complete:^(XPYChapterModel * _Nullable    nextChapter) {
        if (nextChapter && !XPYIsEmptyObject(nextChapter.content)) {
            // 保存分页信息
            nextChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:nextChapter.content chapterName:nextChapter.chapterName] copy];
            // 插入预加载的下一个章节到当前阅读中
            [self safeInsertChapter:nextChapter atFirstOrLast:NO];
            // 当前预加载列表移除
            [self.preloadingChapterIds removeObject:nextChapter.chapterId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

/// 加载当前章节上一章
/// @param currentChapter 当前章节
- (void)preloadLastChapterOfCurrentChapter:(XPYChapterModel *)currentChapter {
    [XPYChapterHelper preloadLastChapterWithCurrentChapter:currentChapter complete:^(XPYChapterModel * _Nullable lastChapter) {
        if (lastChapter && !XPYIsEmptyObject(lastChapter.content)) {
            // 保存分页信息
            lastChapter.pageModels = [[XPYReadParser parseChapterWithChapterContent:lastChapter.content chapterName:lastChapter.chapterName] copy];
            // 插入预加载的上一个章节到当前阅读章节中
            [self safeInsertChapter:lastChapter atFirstOrLast:YES];
            // 当前预加载列表移除
            [self.preloadingChapterIds removeObject:lastChapter.chapterId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                // 计算章节总高度
                CGFloat chapterContentTotalHeight = 0;
                for (XPYChapterPageModel *pageModel in lastChapter.pageModels) {
                    chapterContentTotalHeight += (pageModel.extraHeaderHeight + pageModel.contentHeight);
                }
                // 更新列表位置
                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + chapterContentTotalHeight) animated:NO];
            });
        }
    }];
}

/// 当前章节数组安全插入章节数据
/// @param chapter 章节
/// @param first 是否插入到最前
- (void)safeInsertChapter:(XPYChapterModel *)chapter atFirstOrLast:(BOOL)first {
    if ([self.chapterIds containsObject:chapter.chapterId]) {
        return;
    }
    if (first) {
        @synchronized (self) {
            [self.chapterIds insertObject:chapter.chapterId atIndex:0];
            [self.chapters insertObject:chapter atIndex:0];
        }
    } else {
        @synchronized (self) {
            [self.chapterIds addObject:chapter.chapterId];
            [self.chapters addObject:chapter];
        }
    }
}

/// 更新阅读记录
- (void)updateReadRecord {
    NSArray *indexPaths = [self.tableView.indexPathsForVisibleRows copy];
    if (!indexPaths || indexPaths.count == 0) {
        return;
    }
    // indexPaths排序
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    // 获取目标IndexPath（滚动方向不同结果不同）
    NSIndexPath *indexPath = nil;
    if (_scrollViewPosition == XPYScrollReadPositionTop) {
        indexPath = sortedIndexPaths.firstObject;
    } else if (_scrollViewPosition == XPYScrollReadPositionBottom) {
        indexPath = sortedIndexPaths.lastObject;
    } else {
        indexPath = _isScrollOrientationDown ? sortedIndexPaths.firstObject : sortedIndexPaths.lastObject;
    }
    XPYChapterModel *chapter = self.chapters[indexPath.section];
    if (self.bookModel.chapter.chapterIndex == chapter.chapterIndex && self.bookModel.page == indexPath.row) {
        // 未翻页时无须更新记录
        return;
    }
    self.bookModel.chapter = self.chapters[indexPath.section];
    self.bookModel.page = indexPath.row;
    [XPYReadRecordManager updateReadRecordWithModel:self.bookModel];
    
    // 更新信息视图
    [self refreshInformationViews];
}

/// 加载计时器
- (void)loadTimer {
    self.autoReadTimer = [CADisplayLink displayLinkWithTarget:[XPYTimerProxy proxyWithTarget:self] selector:@selector(scrollAutoRead:)];
    [self.autoReadTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.autoReadTimer.paused = NO;
}

- (void)resolveChapter {
    NSInteger currentChapterIndex = [self.chapterIds indexOfObject:self.bookModel.chapter.chapterId];
    if (_scrollViewPosition == XPYScrollReadPositionBottom && self.bookModel.page == self.bookModel.chapter.pageModels.count - 1 && currentChapterIndex == self.chapters.count - 1) {
        // 最后一页的下一页
        [MBProgressHUD xpy_showTips:@"当前为本书最后一页"];
        if (self.scrollReadDelegate && [self.scrollReadDelegate respondsToSelector:@selector(scrollReadViewControllerDidReadEnding)]) {
            [self.scrollReadDelegate scrollReadViewControllerDidReadEnding];
        }
    } else if (_scrollViewPosition == XPYScrollReadPositionTop && self.bookModel.page == 0 && currentChapterIndex == 0) {
        // 第一页的上一页
        [MBProgressHUD xpy_showTips:@"当前为本书第一页"];
    }
}

/// 判断列表是否滚动到底部
- (BOOL)isScrollAtBottom {
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat tableHeight = CGRectGetHeight(self.tableView.bounds);
    NSInteger currentChapterIndex = [self.chapterIds indexOfObject:self.bookModel.chapter.chapterId];
    if (offsetY + tableHeight >= self.tableView.contentSize.height && self.bookModel.page == self.bookModel.chapter.pageModels.count - 1 && currentChapterIndex == self.chapters.count - 1) {
        return YES;
    }
    return NO;
}

#pragma mark - Event response
- (void)scrollAutoRead:(CADisplayLink *)timer {
    CGFloat speed = [XPYReadConfigManager sharedInstance].autoReadSpeed / 8.0 + 0.35;
    if ([self isScrollAtBottom]) {
        // 滚动到最底部，暂停自动阅读
        [self updateAutoReadStatus:NO];
        [self resolveChapter];
    } else {
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + speed)];
        // 更新阅读记录
        [self updateReadRecord];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 每一章节设置成一个section
    return self.chapters.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 章节的每一页设置成一个row
    XPYChapterModel *chapter = self.chapters[section];
    if (chapter.pageModels) {
        return chapter.pageModels.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYScrollReadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXPYScrollReadViewCellIdentifierKey forIndexPath:indexPath];
    XPYChapterModel *chapter = self.chapters[indexPath.section];
    XPYChapterPageModel *pageModel = chapter.pageModels[indexPath.row];
    [cell setupChapterPageModel:pageModel chapterModel:chapter];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYChapterModel *chapter = self.chapters[indexPath.section];
    XPYChapterPageModel *pageModel = chapter.pageModels[indexPath.row];
    return pageModel.contentHeight + pageModel.extraHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self preloadChapters];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section {
    [self preloadChapters];
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 拖动列表前走代理方法，隐藏菜单工具栏
    if (self.scrollReadDelegate && [self.scrollReadDelegate respondsToSelector:@selector(scrollReadViewControllerWillBeginDragging)]) {
        [self.scrollReadDelegate scrollReadViewControllerWillBeginDragging];
    }
    // 保存拖动开始时坐标
    _tableOffsetY = scrollView.contentOffset.y;
    _isScrollOrientationDown = NO;
    
    if ([XPYReadConfigManager sharedInstance].isAutoRead && !self.autoReadTimer.isPaused && !_isShowingAutoReadMenu) {
        // 手动拖动时暂停自动阅读(自动阅读菜单必须是隐藏状态)
        self.autoReadTimer.paused = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self resolveChapter];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 拖动结束更新阅读记录
    [self updateReadRecord];
    if ([XPYReadConfigManager sharedInstance].isAutoRead && self.autoReadTimer.isPaused && !_isShowingAutoReadMenu) {
        // 拖动结束继续自动阅读(自动阅读菜单必须是隐藏状态)
        self.autoReadTimer.paused = NO;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    // 动画开始更新阅读记录
    [self updateReadRecord];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 动画结束更新阅读记录
    [self updateReadRecord];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取滚动方向
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    // 内容高度
    CGFloat contentHeight = scrollView.contentSize.height;
    // 视图高度
    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.bounds);
    // 判断列表位置
    if (contentOffsetY <= 0) {
        // 滚动到顶部
        _scrollViewPosition = XPYScrollReadPositionTop;
    } else if (scrollViewHeight + contentOffsetY >= contentHeight) {
        // 滚动到底部
        _scrollViewPosition = XPYScrollReadPositionBottom;
    } else {
        // 正常滚动
        _scrollViewPosition = XPYScrollReadPositionNormal;
    }
    
    // 判断滚动方向
    if (_tableOffsetY - contentOffsetY < 0) {
        NSLog(@"up");
        _isScrollOrientationDown = NO;
    } else if (_tableOffsetY - contentOffsetY > 0) {
        NSLog(@"down");
        _isScrollOrientationDown = YES;
    }
    _tableOffsetY = contentOffsetY;
}

#pragma mark - Getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(XPYReadViewLeftSpacing, XPYReadViewTopSpacing, XPYReadViewWidth, XPYReadViewHeight) style:UITableViewStylePlain];
        // 设置TableView的backgroundView
        UIView *tableBackgroundView = [[UIView alloc] initWithFrame:_tableView.bounds];
        tableBackgroundView.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
        _tableView.backgroundView = tableBackgroundView;
        _tableView.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[XPYScrollReadTableViewCell class] forCellReuseIdentifier:kXPYScrollReadViewCellIdentifierKey];
    }
    return _tableView;
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
