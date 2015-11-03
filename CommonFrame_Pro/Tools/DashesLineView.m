//
//  DashesLineView.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/2.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import"DashesLineView.h"
#import "UICommon.h"

@implementation DashesLineView

- (id)initWithFrame:(CGRect)frame

{
    
    self= [super initWithFrame:frame];
    
    if(self) {
        
        // Initialization code
        
        self.lineColor = [UIColor grayLineColor];
        self.startPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(SCREENWIDTH - 14 * 2, 0);
        
    }
    
    return self;
    
}

// Only override drawRect: if you perform custom drawing.

// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect

{
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGContextSetLineWidth(context,0.5);//线宽度
    
    CGContextSetStrokeColorWithColor(context,self.lineColor.CGColor);
    
    CGFloat lengths[] = {4,2};//先画4个点再画2个点
    
    CGContextSetLineDash(context,0, lengths,2);//注意2(count)的值等于lengths数组的长度
    
    CGContextMoveToPoint(context,self.startPoint.x,self.startPoint.y);
    
    CGContextAddLineToPoint(context,self.endPoint.x,self.endPoint.y);
    
    CGContextStrokePath(context);
    
    CGContextClosePath(context);
    
}

@end
