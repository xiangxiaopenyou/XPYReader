//
//  XPYBookCatalogViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/11/24.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookCatalogViewController.h"
#import "XPYBookCatalogCell.h"

#import "XPYChapterHelper.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

static NSString * const kXPYBookCatalogCellIdentifierKey = @"XPYBookCatalogCellIdentifier";

@interface XPYBookCatalogViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *catalogTableView;

@property (nonatomic, copy) NSArray *chapters;

@end

@implementation XPYBookCatalogViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"目录";
    
    [self.view addSubview:self.catalogTableView];
    [self.catalogTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [XPYChapterHelper chaptersWithBookId:self.book.bookId success:^(NSArray * _Nonnull chapters) {
        self.chapters = [chapters copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.catalogTableView reloadData];
            NSInteger currentIndex = self.book.chapter.chapterIndex - 1;
            if (currentIndex >= self.chapters.count) {
                currentIndex = self.chapters.count - 1;
            }
            // 选中并且滚动到当前章节
            [self.catalogTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        });
    } failure:^(NSString * _Nonnull tip) {
        [MBProgressHUD xpy_showErrorTips:tip];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapters.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYBookCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:kXPYBookCatalogCellIdentifierKey forIndexPath:indexPath];
    [cell setupChapter:self.chapters[indexPath.row]];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYChapterModel *tempModel = self.chapters[indexPath.row];
    if (tempModel.chapterIndex == self.book.chapter.chapterIndex) {
        // 同一章节
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (!XPYIsEmptyObject(tempModel.content)) {
        // 章节内容存在
        if (self.delegate && [self.delegate respondsToSelector:@selector(bookCatalog:didSelectChapter:)]) {
            [self.delegate bookCatalog:self didSelectChapter:tempModel];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        // 章节内容为空（网络书籍需要请求下载）
        [MBProgressHUD xpy_showHUD];
        [XPYChapterHelper chapterWithBookId:self.book.bookId chapterId:tempModel.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
            [MBProgressHUD xpy_dismissHUD];
            if (self.delegate && [self.delegate respondsToSelector:@selector(bookCatalog:didSelectChapter:)]) {
                [self.delegate bookCatalog:self didSelectChapter:chapter];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSString * _Nonnull tip) {
            [MBProgressHUD xpy_showErrorTips:tip];
        }];
    }
}

#pragma mark - Getters
- (UITableView *)catalogTableView {
    if (!_catalogTableView) {
        _catalogTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _catalogTableView.backgroundColor = [UIColor whiteColor];
        _catalogTableView.estimatedRowHeight = 0;
        _catalogTableView.estimatedSectionFooterHeight = 0;
        _catalogTableView.estimatedSectionHeaderHeight = 0;
        _catalogTableView.rowHeight = 50;
        _catalogTableView.separatorColor = XPYColorFromHex(0xE6E6E6);
        _catalogTableView.delegate = self;
        _catalogTableView.dataSource = self;
        [_catalogTableView registerClass:[XPYBookCatalogCell class] forCellReuseIdentifier:kXPYBookCatalogCellIdentifierKey];
    }
    return _catalogTableView;
}

@end
