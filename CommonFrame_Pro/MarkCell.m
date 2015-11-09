//
//  MarkCell.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/21.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MarkCell.h"
#import "UICommon.h"

@implementation MarkCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayMarkColor];
        
        self.markBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.markBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_markBtn setTitleColor:[UIColor grayTitleColor] forState:UIControlStateHighlighted];
        self.markBtn.titleLabel.font = Font(12);
        self.markBtn.titleLabel.numberOfLines = 0;
        self.markBtn.backgroundColor = [UIColor clearColor];
        
//        self.markTitle.textAlignment = NSTextAlignmentCenter;
//        self.markTitle.backgroundColor = [UIColor clearColor];
//        self.markTitle.textColor = [UIColor grayTitleColor];

        [self addSubview:self.markBtn];
    }
    
    return self;
}

@end
