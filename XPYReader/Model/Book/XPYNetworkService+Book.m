//
//  XPYNetworkService+Book.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService+Book.h"
#import "XPYBookModel.h"

@implementation XPYNetworkService (Book)

- (void)stackBooksRequestSuccess:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypeGet path:@"user-bookshelf?action=default_book" parameters:@{@"i_version" : @2} success:^(id  _Nonnull result) {
        NSArray *books = [XPYBookModel modelArrayWithJSON:result[@"list"]];
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
    NSDictionary *params = @{
        @"is_serial" : @-1,
        @"ptype" : @2,
        @"timeType" : @"all",
        @"topType" : @"sold",
        @"page" : @1
    };
    [self request:XPYHTTPRequestTypeGet path:@"book?action=top" parameters:params success:^(id result) {
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
    [self request:XPYHTTPRequestTypeGet path:@"book?action=detail" parameters:@{@"i_version" : @"4", @"book_id" : bookId} success:^(id result) {
        XPYBookModel *book = [XPYBookModel yy_modelWithJSON:[result objectForKey:@"bookdetail"]];
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
    [self request:XPYHTTPRequestTypePost path:@"user-bookshelf?action=data_sync" parameters:@{@"book_ids" : booksString, @"i_version" : @2} success:^(id result) {
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
