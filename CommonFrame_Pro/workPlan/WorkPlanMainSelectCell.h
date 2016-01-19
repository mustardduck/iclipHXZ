//
//  WorkPlanMainSelectCell.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/4.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkPlanMainSelectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIImageView *selectIcon;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *jumpBtn;

@end
