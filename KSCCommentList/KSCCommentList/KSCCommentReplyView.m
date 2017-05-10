//
//  KSCCommentView.m
//  KSCCommentList
//
//  Created by KanSC on 2017/5/10.
//  Copyright © 2017年 KanSC. All rights reserved.
//

#import "KSCCommentView.h"
#import "MLLinkLabel.h"
#import <SDAutoLayout.h>
#import "KSCCommentInfo.h"

@interface KSCCommentView ()

@property (nonatomic, strong) UIImageView    *bgImageView;
@property (nonatomic, strong) NSArray        *commentItemsArray;
@property (nonatomic, strong) NSMutableArray *commentLabelsArray;
@property (nonatomic, strong) UIView         *likeLableBottomLine;

@end

@implementation KSCCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initSubviews];
    }
    return self;
}
- (void)initSubviews {
    
    _bgImageView = [UIImageView new];
    UIImage *bgImage = [[[UIImage imageNamed:@"LikeCmtBg"] stretchableImageWithLeftCapWidth:40 topCapHeight:30] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _bgImageView.image = bgImage;
    _bgImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgImageView];
    
    _likeLableBottomLine = [UIView new];
    [self addSubview:_likeLableBottomLine];
    
    _bgImageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
}

- (void)setCommentItemsArray:(NSArray *)commentItemsArray {
    
    _commentItemsArray = commentItemsArray;
    
    long originalLabelsCount = self.commentLabelsArray.count;
    long needsToAddCount = commentItemsArray.count > originalLabelsCount ? (commentItemsArray.count - originalLabelsCount) : 0;
    for (int i = 0; i < needsToAddCount; i++) {
        MLLinkLabel *label = [MLLinkLabel new];
        UIColor *highLightColor = [UIColor colorWithRed:92/255.0 green:140/255.0 blue:193/255.0 alpha:1.0];
        label.linkTextAttributes = @{NSForegroundColorAttributeName : highLightColor};
        label.font = [UIFont systemFontOfSize:14];
        label.delegate = self;
        [self addSubview:label];
        [self.commentLabelsArray addObject:label];
    }
    
    for (int i = 0; i < commentItemsArray.count; i++) {
        KSCCommentReplyInfo *model = commentItemsArray[i];
        MLLinkLabel *label = self.commentLabelsArray[i];
        if (!model.attributedContent) {
            model.attributedContent = [self generateAttributedStringWithCommentItemModel:model];
        }
        label.attributedText = model.attributedContent;
    }
}
- (void)setupWithCommentItemsArray:(NSArray *)commentItemsArray {
    
    self.commentItemsArray = commentItemsArray;
    
    if (self.commentLabelsArray.count) {
        [self.commentLabelsArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            [label sd_clearAutoLayoutSettings];
            label.hidden = YES; //重用时先隐藏所以评论label，然后根据评论个数显示label
        }];
    }
    
    if (!commentItemsArray.count) {
        self.fixedWidth = @(0); // 如果没有评论或者点赞，设置commentview的固定宽度为0（设置了fixedWith的控件将不再在自动布局过程中调整宽度）
        self.fixedHeight = @(0); // 如果没有评论或者点赞，设置commentview的固定高度为0（设置了fixedHeight的控件将不再在自动布局过程中调整高度）
        return;
    } else {
        self.fixedHeight = nil; // 取消固定宽度约束
        self.fixedWidth = nil; // 取消固定高度约束
    }
    
    CGFloat margin = 5;
    
    UIView *lastTopView = nil;
    
    if (self.commentItemsArray.count) {
        _likeLableBottomLine.sd_resetLayout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .heightIs(1)
        .topSpaceToView(lastTopView, 3);
        
        lastTopView = _likeLableBottomLine;
    } else {
        _likeLableBottomLine.sd_resetLayout.heightIs(0);
    }
    
    for (int i = 0; i < self.commentItemsArray.count; i++) {
        UILabel *label = (UILabel *)self.commentLabelsArray[i];
        label.hidden = NO;
        CGFloat topMargin = i==0?10:5;
        label.sd_layout
        .leftSpaceToView(self, 8)
        .rightSpaceToView(self, 5)
        .topSpaceToView(lastTopView, topMargin)
        .autoHeightRatio(0);
        
        label.isAttributedContent = YES;
        lastTopView = label;
    }
    
    [self setupAutoHeightWithBottomView:lastTopView bottomMargin:6];
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (NSMutableAttributedString *)generateAttributedStringWithCommentItemModel:(KSCCommentReplyInfo *)model {
    
    NSString *text = model.firstUserName;
    if (model.secondUserName.length) {
        text = [text stringByAppendingString:[NSString stringWithFormat:@"回复%@", model.secondUserName]];
    }
    text = [text stringByAppendingString:[NSString stringWithFormat:@"：%@", model.commentString]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    [attString setAttributes:@{NSLinkAttributeName : model.firstUserId} range:[text rangeOfString:model.firstUserName]];
    if (model.secondUserName) {
        [attString setAttributes:@{NSLinkAttributeName : model.secondUserId} range:[text rangeOfString:model.secondUserName]];
    }
    return attString;
}
#pragma mark - <懒加载>
- (NSMutableArray *)commentLabelsArray {
    if (!_commentLabelsArray) {
        _commentLabelsArray = [NSMutableArray new];
    }
    return _commentLabelsArray;
}

@end
