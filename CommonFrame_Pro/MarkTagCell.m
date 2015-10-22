//
//  MarkTabCell.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/22.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MarkTagCell.h"
#import "UICommon.h"

@implementation MarkTagCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tagBlueBackColor];
        
        self.delBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width * 0.8 - 2, 0, frame.size.width * 0.2, frame.size.height)];
        _delBtn.backgroundColor = [UIColor clearColor];
        
        UIImageView * delIcon = [[UIImageView alloc] init];
        delIcon.image = [UIImage imageNamed:@"btn_shanchu_2"];
        delIcon.frame = CGRectMake((W(_delBtn) - 8) / 2, (H(_delBtn) - 8) / 2, 8, 8);
        
        [_delBtn addSubview:delIcon];
        
        self.titleLbl = [[UILabel alloc] init];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = [UIColor whiteColor];
        _titleLbl.font = Font(10);
        _titleLbl.frame = CGRectMake(0, 0, frame.size.width * 0.8, frame.size.height);
        
        [self addSubview:self.delBtn];
        [self addSubview:self.titleLbl];
    }
    
    return self;
}

@end
