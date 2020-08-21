//
//  XPYScrollReadViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYScrollReadViewController.h"
#import "XPYScrollReadTableViewCell.h"

#import "XPYReadParser.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"

#import "XPYBookModel.h"

static NSString * const kXPYScrollReadViewCellIdentifierKey = @"XPYScrollReadViewCellIdentifier";

@interface XPYScrollReadViewController () <UITableViewDataSource, UITableViewDelegate>

/// 书名
@property (nonatomic, strong) UILabel *bookNameLabel;
/// 章节名
@property (nonatomic, strong) UILabel *chapterNameLabel;
/// 阅读进度（页码）
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UITableView *tableView;

/// 书籍
@property (nonatomic, strong) XPYBookModel *bookModel;

/// 当前阅读章节ID数组
@property (nonatomic, strong) NSMutableArray <NSString *> *chapterIds;
/// 当前阅读章节数组(只保存本次阅读列表)
@property (nonatomic, strong) NSMutableArray <XPYChapterModel *> *chapters;
/// 列表滚动方式是否向下
@property (nonatomic, assign) BOOL isScrollOrientationDown;
/// 列表OffsetY坐标，用于判断列表滚动方向
@property (nonatomic, assign) CGFloat tableOffsetY;

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
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    // chapters中只有当前章节
    XPYChapterModel *currentChapter = self.chapters.firstObject;
    [XPYReadParser parseChapterWithContent:currentChapter.content chapterName:currentChapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
        // 保存分页信息到数组中
        currentChapter.pageRanges = [pageRanges copy];
        currentChapter.attributedContent = chapterContent;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.bookModel.page inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    }];
}

#pragma mark - UI
- (void)configureUI {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).mas_offset(XPYReadViewLeftSpacing);
        make.trailing.equalTo(self.view.mas_trailing).mas_offset(- XPYReadViewRightSpacing);
        make.top.equalTo(self.view.mas_top).mas_offset(XPYReadViewTopSpacing);
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(- XPYReadViewBottomSpacing);
    }];
}

#pragma mark - Private methods
- (void)preloadChapters {
    XPYChapterModel *currentChapter = self.bookModel.chapter;
    if (currentChapter.chapterIndex == 1) {
        // 当前为第一章
        if (![self.chapterIds containsObject:[XPYChapterHelper nextChapterOfCurrentChapter:currentChapter].chapterId]) {
            // 加载下一章
            [self preloadNextChapterOfCurrentChapter:currentChapter];
        }
    } else if (currentChapter.chapterIndex == self.bookModel.chapterCount) {
        // 当前为最后一章
        if (![self.chapterIds containsObject:[XPYChapterHelper lastChapterOfCurrentChapter:currentChapter].chapterId]) {
            // 加载上一章
            [self preloadLastChapterOfCurrentChapter:currentChapter];
        }
    } else {
        // 当前为中间章节
        if (![self.chapterIds containsObject:[XPYChapterHelper nextChapterOfCurrentChapter:currentChapter].chapterId]) {
            // 加载下一章
            [self preloadNextChapterOfCurrentChapter:currentChapter];
        }
        if (![self.chapterIds containsObject:[XPYChapterHelper lastChapterOfCurrentChapter:currentChapter].chapterId]) {
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
            [XPYReadParser parseChapterWithContent:nextChapter.content chapterName:nextChapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                // 保存分页信息到数组中
                nextChapter.pageRanges = [pageRanges copy];
                nextChapter.attributedContent = chapterContent;
                // 插入预加载的下一个章节到当前阅读中
                [self.chapterIds addObject:nextChapter.chapterId];
                [self.chapters addObject:nextChapter];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }];
        }
    }];
}

/// 加载当前章节上一章
/// @param currentChapter 当前章节
- (void)preloadLastChapterOfCurrentChapter:(XPYChapterModel *)currentChapter {
    [XPYChapterHelper preloadLastChapterWithCurrentChapter:currentChapter complete:^(XPYChapterModel * _Nullable lastChapter) {
        if (lastChapter && !XPYIsEmptyObject(lastChapter.content)) {
            [XPYReadParser parseChapterWithContent:lastChapter.content chapterName:lastChapter.chapterName bounds:XPYReadViewBounds complete:^(NSAttributedString * _Nonnull chapterContent, NSArray * _Nonnull pageRanges) {
                // 保存分页信息到数组中
                lastChapter.pageRanges = [pageRanges copy];
                lastChapter.attributedContent = chapterContent;
                // 插入预加载的上一个章节到当前阅读章节中
                [self.chapterIds insertObject:lastChapter.chapterId atIndex:0];
                [self.chapters insertObject:lastChapter atIndex:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    // 更新列表位置
                    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + (XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing) * pageRanges.count) animated:NO];
                });
            }];
        }
    }];
}

/// 更新阅读记录
- (void)updateReadRecord {
    NSArray *indexPaths = [self.tableView.indexPathsForVisibleRows copy];
    if (!indexPaths || indexPaths.count == 0) {
        return;
    }
    NSIndexPath *indexPath = _isScrollOrientationDown ? indexPaths.firstObject : indexPaths.lastObject;
    XPYChapterModel *chapter = self.chapters[indexPath.section];
    if (self.bookModel.chapter.chapterIndex == chapter.chapterIndex && self.bookModel.page == indexPath.row) {
        // 未翻页时无须更新记录
        return;
    }
    self.bookModel.chapter = self.chapters[indexPath.section];
    self.bookModel.page = indexPath.row;
    [XPYReadRecordManager insertOrReplaceRecordWithModel:self.bookModel];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 每一章节设置成一个section
    return self.chapters.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 章节的每一页设置成一个row
    XPYChapterModel *chapter = self.chapters[section];
    if (chapter.pageRanges) {
        return chapter.pageRanges.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYScrollReadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXPYScrollReadViewCellIdentifierKey forIndexPath:indexPath];
    XPYChapterModel *chapter = self.chapters[indexPath.section];
    [cell setupContent:[XPYReadParser pageContentWithChapterContent:chapter.attributedContent page:indexPath.row pageRanges:chapter.pageRanges]];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing;
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
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 拖动结束更新阅读记录
    [self updateReadRecord];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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

@end
