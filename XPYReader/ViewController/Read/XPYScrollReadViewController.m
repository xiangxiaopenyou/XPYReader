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

/// 当前阅读章节数组(只保存本次阅读列表)
@property (nonatomic, strong) NSMutableArray <XPYChapterModel *> *chapters;

@end

@implementation XPYScrollReadViewController

#pragma mark - Initializer
- (instancetype)initWithBook:(XPYBookModel *)book {
    self = [super init];
    if (self) {
        self.bookModel = book;
        // 初始化当前阅读章节数组
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

#pragma mark - Getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[XPYScrollReadTableViewCell class] forCellReuseIdentifier:kXPYScrollReadViewCellIdentifierKey];
    }
    return _tableView;
}

@end
