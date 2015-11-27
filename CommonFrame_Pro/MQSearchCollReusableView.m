//
//  MQSearchCollReusableView.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/26.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQSearchCollReusableView.h"
#import "UICommon.h"

@implementation MQSearchCollReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor backgroundColor];
        
        self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 13, 13)];

        self.titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(_iconImgView)+ 7, Y(_iconImgView), 100, 16)];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.textColor = [UIColor grayTitleColor];
        _titleLbl.font = Font(15);
        
        [self addSubview:_iconImgView];
        [self addSubview:_titleLbl];

    }
    return self;
}

@end
