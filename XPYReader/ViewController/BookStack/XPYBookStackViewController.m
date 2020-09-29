//
//  XPYBookStackViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookStackViewController.h"
#import "XPYReaderManagerController.h"

#import "XPYBookStackCollectionViewCell.h"

#import "XPYOpenBookAnimation.h"

#import "XPYBookModel.h"
#import "XPYNetworkService+Book.h"
#import "XPYNetworkService+Chapter.h"
#import "XPYReadRecordManager.h"
#import "XPYReadHelper.h"
#import "XPYUserManager.h"

#import "UIViewController+Transition.h"

static NSString *kXPYBookStackCollectionViewCellIdentifierKey = @"XPYBookStackCollectionViewCellIdentifier";

@interface XPYBookStackViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<XPYBookModel *> *dataSource;

@end

@implementation XPYBookStackViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取本地书架所有书籍
    self.dataSource = [[XPYReadRecordManager allBooksInStack] copy];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 设置NavigationController代理，实现自定义转场动画
    self.navigationController.delegate = self;
    
    // 请求网络书架中的书籍
    [self booksRequest];
    
    // 注册书架书籍发生变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stackBooksChanged:) name:XPYBookStackDidChangeNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self stackBooksChanged:nil];
}

#pragma mark - Network
- (void)booksRequest {
    if ([XPYUserManager sharedInstance].isLogin) {
        
    } else {
        [[XPYNetworkService sharedService] stackBooksRequestSuccess:^(NSArray * _Nonnull books) {
            NSArray *resultArray = [books copy];
            if (resultArray.count > 0) {
                [self synchronizeBooks:resultArray];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD xpy_showTips:@"网络错误"];
        }];
    }
}

#pragma mark - Private methods
/// 同步本地书架和网络书架(网络书架包括推荐书籍)
/// @param resultBooks 网络书架书籍数组
- (void)synchronizeBooks:(NSArray *)resultBooks {
    NSMutableArray *tempArray = [self.dataSource mutableCopy];
    for (XPYBookModel *networkingBook in resultBooks) {
        if (![self booksArray:self.dataSource isContainsBook:networkingBook]) {
            // 本地书架中不存在该书籍，则添加该书籍到本地书架
            networkingBook.isInStack = YES;
            [tempArray addObject:networkingBook];
            [XPYReadRecordManager insertOrReplaceRecordWithModel:networkingBook];
        }
    }
    self.dataSource = [tempArray copy];
}

/// 判断书籍数组中是否存在某本书
/// @param books 书籍数组
/// @param book 书籍
- (BOOL)booksArray:(NSArray <XPYBookModel *> *)books isContainsBook:(XPYBookModel *)book {
    for (XPYBookModel *tempBook in books) {
        if ([tempBook.bookId isEqualToString:book.bookId]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Notifications
- (void)stackBooksChanged:(NSNotification *)notification {
    self.dataSource = [[XPYReadRecordManager allBooksInStack] copy];
    [self.collectionView reloadData];
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
    XPYBookStackCollectionViewCell *cell = (XPYBookStackCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    // 设置将要打开的书籍视图
    UIView *snapshotView = [cell.bookCoverImageView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = [cell.bookCoverImageView convertRect:cell.bookCoverImageView.frame toView:XPYKeyWindow];
    self.bookCoverView = snapshotView;
    
    XPYBookModel *book = self.dataSource[indexPath.item];
    [XPYReadHelper readWithBook:book];
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

#pragma mark - Override methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XPYBookStackDidChangeNotification object:nil];
}

@end
