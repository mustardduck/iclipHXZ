//
//  PartiCell.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "PartiCell.h"
#import "UICommon.h"

@implementation PartiCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor yellowColor];
        
        self.photoView = [[UIImageView alloc] init];
        _photoView.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        
        [self addSubview:self.photoView];

        self.titleLbl = [[UILabel alloc] init];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = [UIColor whiteColor];
        _titleLbl.font = Font(12);
        _titleLbl.frame = CGRectMake(0, YH(_photoView) + 6, frame.size.width, 14);

        [self addSubview:self.titleLbl];
    }
    
    return self;
}

@end
