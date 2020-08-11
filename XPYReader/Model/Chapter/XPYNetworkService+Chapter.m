//
//  XPYNetworkService+Chapter.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNetworkService+Chapter.h"
#import "XPYChapterModel.h"

#import "NSString+blowFish.h"

@implementation XPYNetworkService (Chapter)

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
- (void)chapterContentWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId success:(XPYSuccessHandler)success failure:(XPYFailureHandler)failure {
    [self request:XPYHTTPRequestTypeGet path:@"book?action=ots-chapter-content" parameters:@{@"book_id" : bookId, @"chapter_id" : chapterId} success:^(id result) {
        if (result[@"content"] && result[@"key"]) {
            // 内容解密
            NSString *resultContent = [result[@"content"] blowFishDecodingWithKey:result[@"key"]];
            if (success) {
                success(resultContent);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
