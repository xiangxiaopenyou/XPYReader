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

@property (nonatomic, copy) NSArray <XPYBookModel *> *books;

@end

@implementation XPYBookStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.booksTableView];
    [self.booksTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self booksListRequest];
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

@end
