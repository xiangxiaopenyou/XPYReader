//
//  XPYBookStackViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookStackViewController.h"

#import "XPYBookStackCollectionViewCell.h"

#import "XPYOpenBookAnimation.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"
#import "XPYReadRecordManager.h"
#import "XPYChapterDataManager.h"
#import "XPYReadParser.h"
#import "XPYReadHelper.h"
#import "XPYUserManager.h"
#import "XPYTransitionManager.h"

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
    
    // 首次安装解析本地测试书籍
    if (![[NSUserDefaults standardUserDefaults] objectForKey:XPYIsFirstInstallKey]) {
        NSArray *bookNames = @[@"从灵气复苏到末法时代", @"孤单的飞", @"诡异天地", @"汉末文枭"];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(bookNames.count);
        for (NSString *bookName in bookNames) {
            NSString *localFilePath = [[NSBundle mainBundle] pathForResource:bookName ofType:@"txt"];
            // 书籍分章节
            [XPYReadParser parseLocalBookWithFilePath:localFilePath success:^(NSArray<XPYChapterModel *> * _Nonnull chapters) {
                // 创建书籍模型
                XPYBookModel *bookModel = [[XPYBookModel alloc] init];
                bookModel.bookType = XPYBookTypeLocal;
                bookModel.bookName = bookName;
                // 本地书随机生成ID
                bookModel.bookId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970] * 1000)];
                bookModel.chapterCount = chapters.count;
                for (XPYChapterModel *chapter in chapters) {
                    chapter.bookId = bookModel.bookId;
                }
                [XPYReadHelper addToBookStackWithBook:bookModel complete:^{
                    [XPYChapterDataManager insertChaptersWithModels:chapters];
                    dispatch_semaphore_signal(semaphore);
                }];
            } failure:^(NSError *error) {
                [MBProgressHUD xpy_showErrorTips:error.userInfo[NSUnderlyingErrorKey]];
                dispatch_semaphore_signal(semaphore);
            }];
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:XPYIsFirstInstallKey];
    }
    
    // 获取本地书架所有书籍
    self.dataSource = [[XPYReadRecordManager allBooksInStack] copy];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.leading.trailing.equalTo(self.view);
    }];
    
    // 请求网络书架中的书籍（服务器到期暂时注释了网络书籍请求）
    //[self booksRequest];
    
    // 注册书架书籍发生变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stackBooksChanged:) name:XPYBookStackDidChangeNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self stackBooksChanged:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    XPYBookModel *bookModel = self.dataSource[indexPath.item];
    XPYBookStackCollectionViewCell *cell = (XPYBookStackCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    // 书籍封面截图
    UIView *snapshotView = [cell.bookCoverImageView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = [cell.bookCoverImageView convertRect:cell.bookCoverImageView.frame toView:XPYKeyWindow];
    // 设置pushView
    [XPYTransitionManager shareManager].pushView = snapshotView;
    [XPYReadHelper readWithBook:bookModel];
    
    // 进入阅读器后默认将书籍排在最前位置，所以需要获取第一本书籍的frame
    XPYBookStackCollectionViewCell *firstCell = (XPYBookStackCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UIView *readerSnapshotView = [cell.bookCoverImageView snapshotViewAfterScreenUpdates:NO];
    readerSnapshotView.frame = [firstCell.bookCoverImageView convertRect:firstCell.bookCoverImageView.frame toView:XPYKeyWindow];
    // 设置popView
    [XPYTransitionManager shareManager].popView = readerSnapshotView;
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
