//
//  XPYBookModel+WCTTableCoding.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookModel.h"

#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYBookModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(bookType)
WCDB_PROPERTY(bookId)
WCDB_PROPERTY(bookName)
WCDB_PROPERTY(bookIntroduction)
WCDB_PROPERTY(bookCoverURL)
WCDB_PROPERTY(openTime)
WCDB_PROPERTY(isInStack)
WCDB_PROPERTY(chapterCount)
WCDB_PROPERTY(chapter)
WCDB_PROPERTY(page)

@end

NS_ASSUME_NONNULL_END
