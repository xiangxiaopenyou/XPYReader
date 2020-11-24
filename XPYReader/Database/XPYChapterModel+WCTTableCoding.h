//
//  XPYChapterModel+WCTTableCoding.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/5.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYChapterModel.h"

#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYChapterModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(chapterId)
WCDB_PROPERTY(bookId)
WCDB_PROPERTY(chapterIndex)
WCDB_PROPERTY(chapterName)
WCDB_PROPERTY(content)
WCDB_PROPERTY(charNum)

@end

NS_ASSUME_NONNULL_END
