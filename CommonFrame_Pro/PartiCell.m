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
        
        self.isReadLbl = [[UILabel alloc] init];
        _isReadLbl.backgroundColor = [UIColor tagBlueBackColor];
        _isReadLbl.textAlignment = NSTextAlignmentCenter;
        _isReadLbl.textColor = [UIColor whiteColor];
        _isReadLbl.font = Font(10);
        _isReadLbl.frame = CGRectMake(0, YH(_photoView) - 14, W(_photoView), 14);
        _isReadLbl.text = @"已读";
        _isReadLbl.hidden = YES;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_isReadLbl.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(3.3, 3.3)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _isReadLbl.bounds;
        maskLayer.path = maskPath.CGPath;
        _isReadLbl.layer.mask = maskLayer;
        
        [self addSubview:self.isReadLbl];

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
