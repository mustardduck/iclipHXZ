//
//  PartiCell.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/11/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartiCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * photoView;
@property (nonatomic, strong) UILabel * isReadLbl;
@property (nonatomic, strong) UILabel * titleLbl;

-(id)initWithFrame:(CGRect)frame;

@end
