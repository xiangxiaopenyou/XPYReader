//
//  XPYNetworkService+Book.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService+Book.h"
#import "XPYBookModel.h"

/// 书架列表
static NSString * const kXPYStackBooksURL = @"/book/stack";
/// 书城列表
static NSString * const kXPYStoreBooksURL = @"/book/store";
/// 书籍详情
static NSString * const kXPYBookDetailsURL = @"/book/details";
/// 同步书架
static NSString * const kXPYSynchronizeStackBooksURL = @"/book/synchronize_stack";
/// 同步阅读记录
static NSString * const kXPYSynchronizeReadRecordURL = @"/book/synchronize_record";

@implementation XPYNetworkService (Book)

- (void)stackBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypeGet path:kXPYStackBooksURL parameters:@{} success:^(id  _Nonnull result) {
        NSArray *books = [XPYBookModel modelArrayWithJSON:result];
        if (success) {
            success(books);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}
- (void)storeBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypeGet path:kXPYStoreBooksURL parameters:@{} success:^(id result) {
        NSArray *books = [XPYBookModel modelArrayWithJSON:result];
        if (success) {
            success(books);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)bookDetailsRequestWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypeGet path:kXPYBookDetailsURL parameters:@{} success:^(id result) {
        XPYBookModel *book = [XPYBookModel yy_modelWithJSON:result];
        if (success) {
            success(book);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)synchronizeStackBooksWithBooksString:(NSString *)booksString success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypePost path:kXPYSynchronizeStackBooksURL parameters:@{} success:^(id result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)synchronizeReadRecordWithRecords:(NSArray *)records success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypePost path:kXPYSynchronizeReadRecordURL parameters:@{} success:^(id result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
