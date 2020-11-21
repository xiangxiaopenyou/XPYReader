//
//  XPYReadMenuBottomBar.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/19.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadMenuBottomBar.h"

#import "XPYBookModel.h"
#import "XPYChapterModel.h"

@interface XPYReadMenuBottomBar ()

/// 章节进度
@property (nonatomic, strong) UISlider *slider;
/// 上一章
@property (nonatomic, strong) UIButton *lastChapterButton;
/// 下一章
@property (nonatomic, strong) UIButton *nextChapterButton;
/// 目录
@property (nonatomic, strong) UIButton *catalogButton;
/// 背景
@property (nonatomic, strong) UIButton *backgorundButton;
/// 翻页效果
@property (nonatomic, strong) UIButton *pageTypeButton;
/// 设置
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation XPYReadMenuBottomBar

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    return self;
}

#pragma mark - UI
- (void)configureUI {
    self.backgroundColor = XPYColorFromHex(0x222222);
    
    [self addSubview:self.lastChapterButton];
    [self addSubview:self.nextChapterButton];
    [self addSubview:self.slider];
    
    [self.lastChapterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).mas_offset(5);
        } else {
            make.leading.equalTo(self.mas_leading).mas_offset(5);
        }
        make.top.equalTo(self.mas_top);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.nextChapterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).mas_offset(- 5);
        } else {
            make.trailing.equalTo(self.mas_trailing).mas_offset(- 5);
        }
        make.top.equalTo(self.mas_top);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lastChapterButton.mas_trailing).offset(10);
        make.trailing.equalTo(self.nextChapterButton.mas_leading).offset(- 10);
        make.top.equalTo(self.mas_top).offset(10);
        make.height.mas_equalTo(30);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = XPYColorFromHex(0x555555);
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_top).offset(50);
        make.height.mas_equalTo(0.5);
    }];
    
    [self addSubview:self.catalogButton];
    [self addSubview:self.backgorundButton];
    [self addSubview:self.pageTypeButton];
    [self addSubview:self.settingButton];
    
    [self.catalogButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.top.equalTo(line.mas_bottom);
        make.height.mas_offset(60);
        // 四分之一宽
        make.width.equalTo(self.mas_width).multipliedBy(0.25);
    }];
    
    [self.backgorundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.catalogButton.mas_trailing);
        make.top.equalTo(line.mas_bottom);
        make.height.mas_offset(60);
        // 四分之一宽
        make.width.equalTo(self.mas_width).multipliedBy(0.25);
    }];
    
    [self.pageTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backgorundButton.mas_trailing);
        make.top.equalTo(line.mas_bottom);
        make.height.mas_offset(60);
        // 四分之一宽
        make.width.equalTo(self.mas_width).multipliedBy(0.25);
    }];
    
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.pageTypeButton.mas_trailing);
        make.top.equalTo(line.mas_bottom);
        make.height.mas_offset(60);
        // 四分之一宽
        make.width.equalTo(self.mas_width).multipliedBy(0.25);
    }];
}

#pragma mark - Instance methods
- (void)updatePageProgressWithBook:(XPYBookModel *)book {
    if (!book) {
        return;
    }
    // 设置最大值
    self.slider.maximumValue = book.chapter.pageModels.count;
    // 设置当前值
    self.slider.value = book.page + 1;
    // 设置上/下一章按钮是否可点击
    self.nextChapterButton.enabled = book.chapter.chapterIndex != book.chapterCount;
    self.lastChapterButton.enabled = book.chapter.chapterIndex != 1;
}

#pragma mark - Actions
- (void)lastChapterAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidClickLastChapter)]) {
        [self.delegate bottomBarDidClickLastChapter];
    }
}
- (void)nextChapterAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidClickNextChapter)]) {
        [self.delegate bottomBarDidClickNextChapter];
    }
}
/// 页码进度选择
- (void)sliderValueChanged {
    NSInteger value = (NSInteger)self.slider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidChangePage:)]) {
        [self.delegate bottomBarDidChangePage:value];
    }
}
/// 页码进度选择完成
- (void)sliderTouchedUp {
    NSInteger value = (NSInteger)self.slider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidChangePageProgress:)]) {
        [self.delegate bottomBarDidChangePageProgress:value];
    }
}

- (void)catalogAction {
    
}
- (void)backgroundAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidClickBackground)]) {
        [self.delegate bottomBarDidClickBackground];
    }
}
- (void)pageTypeAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidClickPageType)]) {
        [self.delegate bottomBarDidClickPageType];
    }
}
- (void)settingAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBarDidClickSetting)]) {
        [self.delegate bottomBarDidClickSetting];
    }
}

#pragma mark - Getters
- (UIButton *)lastChapterButton {
    if (!_lastChapterButton) {
        _lastChapterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lastChapterButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_lastChapterButton setTitleColor:XPYColorFromHex(0x3c3c3c) forState:UIControlStateDisabled];
        _lastChapterButton.titleLabel.font = FontRegular(13);
        [_lastChapterButton setTitle:@"上一章" forState:UIControlStateNormal];
        [_lastChapterButton addTarget:self action:@selector(lastChapterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastChapterButton;
}
- (UIButton *)nextChapterButton {
    if (!_nextChapterButton) {
        _nextChapterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextChapterButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        [_nextChapterButton setTitleColor:XPYColorFromHex(0x3c3c3c) forState:UIControlStateDisabled];
        _nextChapterButton.titleLabel.font = FontRegular(13);
        [_nextChapterButton setTitle:@"下一章" forState:UIControlStateNormal];
        [_nextChapterButton addTarget:self action:@selector(nextChapterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextChapterButton;
}
- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 1;
        _slider.maximumValue = 1;
        _slider.minimumTrackTintColor = [UIColor yellowColor];
        _slider.maximumTrackTintColor = [UIColor grayColor];
        [_slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderTouchedUp) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _slider;
}
- (UIButton *)catalogButton {
    if (!_catalogButton) {
        _catalogButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_catalogButton setTitle:@"章节目录" forState:UIControlStateNormal];
        [_catalogButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _catalogButton.titleLabel.font = FontRegular(11);
        [_catalogButton addTarget:self action:@selector(catalogAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _catalogButton;
}
- (UIButton *)backgorundButton {
    if (!_backgorundButton) {
        _backgorundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgorundButton setTitle:@"背景模式" forState:UIControlStateNormal];
        [_backgorundButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _backgorundButton.titleLabel.font = FontRegular(11);
        [_backgorundButton addTarget:self action:@selector(backgroundAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgorundButton;
}
- (UIButton *)pageTypeButton {
    if (!_pageTypeButton) {
        _pageTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pageTypeButton setTitle:@"翻页模式" forState:UIControlStateNormal];
        [_pageTypeButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _pageTypeButton.titleLabel.font = FontRegular(11);
        [_pageTypeButton addTarget:self action:@selector(pageTypeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageTypeButton;
}
- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingButton setTitle:@"设置" forState:UIControlStateNormal];
        [_settingButton setTitleColor:XPYColorFromHex(0xdddddd) forState:UIControlStateNormal];
        _settingButton.titleLabel.font = FontRegular(11);
        [_settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

@end
