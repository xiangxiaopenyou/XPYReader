//
//  XPYReadHelper.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/12.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadHelper.h"
#import "XPYChapterHelper.h"
#import "XPYReadRecordManager.h"
#import "XPYChapterDataManager.h"
#import "XPYViewControllerHelper.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

#import "XPYNetworkService+Book.h"

@implementation XPYReadHelper

+ (void)readyForReadingWithBook:(XPYBookModel *)bookModel success:(void (^)(XPYBookModel * _Nonnull))success failure:(void (^)(NSString * _Nonnull))failure {
    if (bookModel.chapter) {
        // 存在历史阅读记录，更新阅读时间
        [XPYReadRecordManager updateOpenTimeWithModel:bookModel];
        if (bookModel.chapter.content) {
            // 存在章节内容，直接返回
            !success ?: success(bookModel);
        } else {
            // 不存在章节内容，先获取章节内容
            [XPYChapterHelper chapterWithBookId:bookModel.bookId chapterId:bookModel.chapter.chapterId success:^(XPYChapterModel * _Nonnull chapter) {
                bookModel.chapter = [chapter copy];
                !success ?: success(bookModel);
            } failure:^(NSString * _Nonnull tip) {
                !failure ?: failure(tip);
            }];
        }
    } else {
        // 不存在历史阅读记录，则设置第一章第一页为阅读内容
        [XPYChapterHelper chapterWithBookId:bookModel.bookId chapterId:nil success:^(XPYChapterModel * _Nonnull chapter) {
            bookModel.chapter = chapter;
            bookModel.page = 0;
            // 保存阅读记录
            [XPYReadRecordManager insertOrReplaceRecordWithModel:bookModel];
            !success ?: success(bookModel);
        } failure:^(NSString * _Nonnull tip) {
            !failure ?: failure(tip);
        }];
    }
}

+ (void)addToBookStackWithBook:(XPYBookModel *)bookModel complete:(void (^)(void))complete {
    XPYBookModel *recordBook = [XPYReadRecordManager recordWithBookId:bookModel.bookId];
    if (recordBook) {
        // 存在阅读记录，则只要更新书架状态
        recordBook.isInStack = YES;
        [XPYReadRecordManager updateInStackStatusWithModel:recordBook];
        !complete ?: complete();
    } else {
        // 不存在阅读记录，需要插入书籍
        bookModel.isInStack = YES;
        [XPYReadRecordManager insertOrReplaceRecordWithModel:bookModel];
        !complete ?: complete();
    }
}
+ (void)removeFormBookStackWithBook:(XPYBookModel *)bookModel complete:(void (^)(void))complete {
    XPYBookModel *recordBook = [XPYReadRecordManager recordWithBookId:bookModel.bookId];
    if (!recordBook) {
        !complete ?: complete();
        return;
    }
    // 更新书架状态
    recordBook.isInStack = NO;
    [XPYReadRecordManager updateInStackStatusWithModel:recordBook];
    if (!recordBook.chapter) {
        // 如果阅读记录没有章节内容，则直接移除该记录
        [XPYReadRecordManager deleteRecordWithModel:recordBook];
        !complete ?: complete();
    } else {
        !complete ?: complete();
    }
}

+ (void)synchronizeStackBooksAndReadRecordsComplete:(void (^)(void))complete {
    NSArray *stackBooks = [[XPYReadRecordManager allBooksInStack] copy];
    if (stackBooks.count == 0) {
        // 无书架书籍，直接完成
        !complete ?: complete();
        return;
    }
    [XPYAlertManager showAlertWithTitle:@"温馨提示" message:@"是否将书架和阅读记录数据同步至本账号" cancel:@"取消同步" confirm:@"立即同步" inController:[XPYViewControllerHelper currentViewController] confirmHandler:^{
        NSMutableArray *needSynchronizeBookIds = [[NSMutableArray alloc] init];
        for (XPYBookModel *book in stackBooks) {
            // 拼接BookId
            [needSynchronizeBookIds addObject:[NSString stringWithFormat:@"%@-0-0", book.bookId]];
        }
        NSString *bookIdsString = [needSynchronizeBookIds componentsJoinedByString:@","];
        // 同步书架书籍到服务端
        [[XPYNetworkService sharedService] synchronizeStackBooksWithBooksString:bookIdsString success:^(id result) {
            !complete ?: complete();
        } failure:^(NSError *error) {
            !complete ?: complete();
        }];
    } cancelHandler:^{
        // 选择不同步数据，则删除本地数据
        [XPYReadRecordManager deleteAllReadRecords];
        [XPYChapterDataManager deleteAllChaters];
        !complete ?: complete();
    }];
}

@end
