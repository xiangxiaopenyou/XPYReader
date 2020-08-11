//
//  XPYBookStackViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookStackViewController.h"
#import "XPYReadPageViewController.h"

#import "XPYBookStackCollectionViewCell.h"

#import "XPYBookModel.h"
#import "XPYNetworkService+Book.h"
#import "XPYNetworkService+Chapter.h"

static NSString *kXPYBookStackCollectionViewCellIdentifierKey = @"XPYBookStackCollectionViewCellIdentifier";

@interface XPYBookStackViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<XPYBookModel *> *dataSource;

@end

@implementation XPYBookStackViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self booksRequest];
}

#pragma mark - Network
- (void)booksRequest {
    [[XPYNetworkService sharedService] stackBooksRequestSuccess:^(NSArray * _Nonnull books) {
        self.dataSource = [books copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD xpy_showTips:@"网络错误"];
    }];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XPYBookStackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kXPYBookStackCollectionViewCellIdentifierKey forIndexPath:indexPath];
    [cell setupData:self.dataSource[indexPath.item]];
    return cell;
}

#pragma mark - Collection view delegate & flow layout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XPYBookModel *book = self.dataSource[indexPath.item];
    [MBProgressHUD xpy_showActivityHUDWithTips:nil];
    [[XPYNetworkService sharedService] bookChaptersWithBookId:book.bookId success:^(id result) {
        [MBProgressHUD xpy_hideHUD];
        dispatch_async(dispatch_get_main_queue(), ^{
            XPYReadPageViewController *readPageController = [[XPYReadPageViewController alloc] init];
            readPageController.chapters = [(NSArray *)result copy];
            readPageController.book = [book copy];
            [self.navigationController pushViewController:readPageController animated:YES];
        });
    } failure:^(NSError *error) {
        [MBProgressHUD xpy_hideHUD];
    }];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(75, 140);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 15, 10, 15);
}

#pragma mark - Getters
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[XPYBookStackCollectionViewCell class] forCellWithReuseIdentifier:kXPYBookStackCollectionViewCellIdentifierKey];
    }
    return _collectionView;
}

@end
