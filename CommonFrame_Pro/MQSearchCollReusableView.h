//
//  MQSearchCollReusableView.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/26.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQSearchCollReusableView : UICollectionReusableView

@property (nonatomic, strong) UIImageView * iconImgView;
@property (nonatomic, strong) UILabel * titleLbl;

-(id)initWithFrame:(CGRect)frame;

@end
