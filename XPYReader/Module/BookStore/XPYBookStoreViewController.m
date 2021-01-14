//
//  XPYBookStoreViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookStoreViewController.h"
#import "XPYBookDetailsViewController.h"

#import "XPYBookStoreCell.h"

#import "XPYBookModel.h"

#import "XPYNetworkService+Book.h"

@interface XPYBookStoreViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *booksTableView;
@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, copy) NSArray <XPYBookModel *> *books;

@end

@implementation XPYBookStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.booksTableView];
    [self.booksTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.top.equalTo(self.view.mas_top);
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.leading.trailing.equalTo(self.view);
    }];
    
    // 服务器到期暂时注释网络接口请求
    //[self booksListRequest];
    
    [self.view addSubview:self.errorLabel];
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(150, 50, 150, 50));
    }];
}

#pragma mark - Network
- (void)booksListRequest {
    [[XPYNetworkService sharedService] storeBooksRequestSuccess:^(id result) {
        self.books = [(NSArray *)result copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.booksTableView reloadData];
        });
    } failure:^(NSError *error) {
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.books.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYBookStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XPYBookStoreCell"];
    if (!cell) {
        cell = [[XPYBookStoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XPYBookStoreCell"];
    }
    XPYBookModel *book = self.books[indexPath.row];
    [cell setupData:book];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XPYBookModel *book = self.books[indexPath.row];
    XPYBookDetailsViewController *detailsController = [[XPYBookDetailsViewController alloc] init];
    detailsController.bookId = book.bookId;
    [self.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark - Getters
- (UITableView *)booksTableView {
    if (!_booksTableView) {
        _booksTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _booksTableView.backgroundColor = [UIColor whiteColor];
        _booksTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _booksTableView.rowHeight = 125;
        _booksTableView.dataSource = self;
        _booksTableView.delegate = self;
    }
    return _booksTableView;
}
- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.text = @"    服务器到期原因，网络相关内容暂时无法使用了，包括网络书籍相关接口（书架网络书籍列表、书城书籍列表、书籍详情等）、用户相关接口（登录、同步记录等），当前demo中只能看到本地书相关内容，但是网络相关代码都是在的，大家可以自行参考设计自己的网络接口";
        _errorLabel.textColor = [UIColor blackColor];
        _errorLabel.font = [UIFont boldSystemFontOfSize:15];
        _errorLabel.numberOfLines = 0;
    }
    return _errorLabel;
}


@end
