//
//  XPYNetworkService+Book.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService+Book.h"
#import "XPYBookModel.h"
#import "XPYChapterModel.h"

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
- (void)bookChaptersWithBookId:(NSString *)bookId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypeGet path:@"book?action=ots-chapter-list" parameters:@{@"type" : @"down", @"book_id" : bookId} success:^(id result) {
        NSArray *chapters = [XPYChapterModel modelArrayWithJSON:result];
        if (success) {
            success(chapters);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
