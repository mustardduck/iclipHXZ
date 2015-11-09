//
//  DashesLineView.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/2.
//  Copyright © 2015年 ionitech. All rights reserved.
//


#import<UIKit/UIKit.h>

@interface DashesLineView :UIView

@property(nonatomic)CGPoint startPoint;//虚线起点

@property(nonatomic)CGPoint endPoint;//虚线终点

@property(nonatomic,strong)UIColor* lineColor;//虚线颜色

- (id)initWithFrame:(CGRect)frame;

@end
