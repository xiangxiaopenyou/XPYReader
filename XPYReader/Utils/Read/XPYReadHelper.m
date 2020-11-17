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
#import "XPYReaderManagerController.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

#import "XPYNetworkService+Book.h"

@implementation XPYReadHelper

+ (void)readWithBook:(XPYBookModel *)bookModel {
    if (!bookModel) {
        return;
    }
    [MBProgressHUD xpy_showHUD];
    [self readyForReadingWithBook:bookModel success:^(XPYBookModel * _Nonnull book) {
        [MBProgressHUD xpy_dismissHUD];
        XPYReaderManagerController *reader = [[XPYReaderManagerController alloc] init];
        reader.book = book;
        [[XPYViewControllerHelper currentViewController].navigationController pushViewController:reader animated:YES];
    } failure:^(NSString * _Nonnull tip) {
        [MBProgressHUD xpy_showTips:tip];
    }];
}

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
    NSArray *readRecord = [[XPYReadRecordManager allReadBooks] copy];
    if (readRecord.count == 0) {
        // 无任何阅读记录，直接完成
        !complete ?: complete();
        return;
    }
    [XPYAlertManager showAlertWithTitle:@"温馨提示" message:@"是否将书架和阅读记录数据同步至本账号" cancel:@"取消同步" confirm:@"立即同步" inController:[XPYViewControllerHelper currentViewController] confirmHandler:^{
        // 需要同步的书架书籍ID
        NSMutableArray *needSynchronizeBookIds = [[NSMutableArray alloc] init];
        // 需要同步的阅读记录
        NSMutableArray *needSynchronizeRecords = [[NSMutableArray alloc] init];
        for (XPYBookModel *book in readRecord) {
            if (book.chapter) {
                NSDictionary *record = @{@"book_id" : book.bookId,
                                         @"chapter_id" : book.chapter.chapterId,
                                         @"utime" : @(book.openTime)};
                [needSynchronizeRecords addObject:record];
            }
            if (book.isInStack) {
                // 拼接BookId
                [needSynchronizeBookIds addObject:[NSString stringWithFormat:@"%@-0-0", book.bookId]];
            }
        }
        
        // 同步书架和同步阅读记录分两个接口
        // GCD队列组用信号量处理多个异步网络请求
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("semaphore", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            // 同步书架网络请求
            if (needSynchronizeBookIds.count == 0) {
                // 没有需要同步的书籍，直接发送信号
                dispatch_semaphore_signal(semaphore);
            } else {
                NSString *bookIdsString = [needSynchronizeBookIds componentsJoinedByString:@","];
                // 同步书架书籍到服务端
                [[XPYNetworkService sharedService] synchronizeStackBooksWithBooksString:bookIdsString success:^(id result) {
                    dispatch_semaphore_signal(semaphore);
                } failure:^(NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
            }
            // 信号量等待
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
        
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            // 同步阅读记录请求
            if (needSynchronizeRecords.count == 0) {
                // 没有需要同步的阅读记录，直接发送信号
                dispatch_semaphore_signal(semaphore);
            } else {
                // 同步阅读记录到服务端
                [[XPYNetworkService sharedService] synchronizeReadRecordWithRecords:needSynchronizeRecords success:^(id result) {
                    dispatch_semaphore_signal(semaphore);
                } failure:^(NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
            }
            // 信号量等待
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            // 完成同步
            if (complete) {
                complete();
            }
        });
    } cancelHandler:^{
        // 选择不同步数据，则删除本地数据
        [XPYReadRecordManager deleteAllReadRecords];
        [XPYChapterDataManager deleteAllChapters];
        !complete ?: complete();
    }];
}

@end
