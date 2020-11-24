//
//  XPYBookCatalogCell.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/11/24.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBookCatalogCell.h"

#import "XPYChapterModel.h"
#import "XPYChapterHelper.h"

@interface XPYBookCatalogCell ()

@property (nonatomic, strong) XPYChapterModel *chapter;

@end

@implementation XPYBookCatalogCell

#pragma mark - Initializer
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.font = XPYFontRegular(16);
        self.textLabel.textColor = [UIColor yellowColor];
        
    }
    return self;
}

#pragma mark - Instance methods
- (void)setupChapter:(XPYChapterModel *)chapter {
    self.chapter = chapter;
    self.textLabel.text = self.chapter.chapterName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (XPYIsEmptyObject(self.chapter.content)) {
        // 章节内容为空（未下载）
        self.textLabel.textColor = [UIColor grayColor];
    } else {
        self.textLabel.textColor = selected ? [UIColor yellowColor] : XPYColorFromHex(0x333333);
    }
}

@end
