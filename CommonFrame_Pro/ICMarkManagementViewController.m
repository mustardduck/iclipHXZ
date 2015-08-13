//
//  ICMarkManagementViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMarkManagementViewController.h"
#import "UIColor+HexString.h"

@interface ICMarkManagementViewController()
{
    IBOutlet UIView*    _markView;
    BOOL                _editButtonClicked;
    NSMutableArray*     _markList;
    NSMutableArray*     _authority;
    UITextField*        _txtUpdate;
}

@end

@implementation ICMarkManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 10, 18)];
    [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
    [leftButton addSubview:imgview];
    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 50, 20)];
    [ti setBackgroundColor:[UIColor clearColor]];
    [ti setTextColor:[UIColor whiteColor]];
    [ti setText:@"返回"];
    [ti setFont:[UIFont systemFontOfSize:17]];
    [leftButton addSubview:ti];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    if(!_justRead)
    {
        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        [rightBtn addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBtn setBackgroundColor:[UIColor clearColor]];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
    }
    
    [self.navigationItem setTitle:@"分类列表"];
    
    if(self.workGroupId != nil)
        _markList = [NSMutableArray arrayWithArray:[Mark getMarkListByWorkGroupID:self.workGroupId loginUserID:[LoginUser loginUserID]]];
    
    //_markList = [NSMutableArray arrayWithArray:@[@"工作汇报",@"会议概要",@"申请",@"质量与维修报损",@"请假",@"会计部",@"议"]] ;
    //_authority = [NSMutableArray arrayWithArray:@[@"0",@"0",@"1",@"1",@"1",@"1",@"1"]];
    
    _editButtonClicked = NO;
    [self showMark:NO];
}


- (void)showMark:(BOOL)isEdit
{
    if (_markList.count == 0) {
        return;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat viWidth = 0;
    CGFloat viHight = 42;
    CGFloat tmpTotalWidth = 0;
    CGFloat interval = 2;
    CGFloat x = interval;
    CGFloat y = interval;
    CGFloat labelInterval = 10;
    CGFloat btnNeedWidth = 0;
    CGFloat participantsWidth = 40;
    
    for (UIControl* control in _markView.subviews) {
        [control removeFromSuperview];
    }
    
    for (int i = 0; i < _markList.count; i++) {
        
        Mark* m = [_markList objectAtIndex:i];
        
        NSString *str = m.labelName;
        
        UIFont* font = [UIFont boldSystemFontOfSize:14];
        
        NSDictionary *attribute = @{NSFontAttributeName: font};
        CGSize size = [str boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine |
                       NSStringDrawingUsesLineFragmentOrigin |
                       NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        BOOL isCustom = !m.isSystem;
        
        if(isEdit){
            if (isCustom) {
                 btnNeedWidth = 0;
            }
            else
                btnNeedWidth = 0;
        }
        
        viWidth = (size.width + participantsWidth) + labelInterval + btnNeedWidth;
        
        x = tmpTotalWidth + interval;
        tmpTotalWidth = tmpTotalWidth + viWidth + interval;
        if (tmpTotalWidth >= width) {
            tmpTotalWidth = viWidth + interval;
            y = y + viHight + interval;
            x = interval;
        }
        
        UIView* vi = [[UIView alloc] initWithFrame:CGRectMake(x, y, viWidth, viHight)];
        [vi setBackgroundColor:[UIColor colorWithHexString:@"#262630"]];
        [vi setTag:i];
        
        CGFloat lblWidth = viWidth - labelInterval - btnNeedWidth;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelInterval / 2, 6, lblWidth, 30)];
        label.font = font;
        label.numberOfLines = 1;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [label setBackgroundColor:[UIColor clearColor]];
        label.text = str;
        
        [vi addSubview:label];
        
        if (isEdit) {
            
            if (isCustom) {
                
                UIButton* editButton = [[UIButton alloc] initWithFrame:CGRectMake((viWidth/3) - 15, 11, 20, 20)];
                [editButton setBackgroundColor:[UIColor blueColor]];
                [editButton setImage:[UIImage imageNamed:@"btn_bianji"]  forState:UIControlStateNormal];
                [editButton addTarget:self action:@selector(btnUpdateClicked:) forControlEvents:UIControlEventTouchUpInside];
                [editButton setTag:i];
                
                [editButton.layer setCornerRadius:10.0f];
                [editButton.layer setMasksToBounds:YES];
                
                [vi addSubview:editButton];
                
                
                
                UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake((viWidth/3)*2 - 5, 11, 20, 20)];
                [closeButton setBackgroundColor:[UIColor redColor]];
                [closeButton setImage:[UIImage imageNamed:@"btn_shanchu"]  forState:UIControlStateNormal];
                [closeButton addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setTag:i];
                
                [closeButton.layer setCornerRadius:10.0f];
                [closeButton.layer setMasksToBounds:YES];
                
                [vi addSubview:closeButton];
            }
            else
            {
                UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake((viWidth/2) - 10, 11, 20, 20)];
                [closeButton setBackgroundColor:[UIColor greenColor]];
                [closeButton  setImage:[UIImage imageNamed:@"btn_shezhi"]  forState:UIControlStateNormal];
                //[closeButton addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setTag:i];
                
                [closeButton.layer setCornerRadius:10.0f];
                [closeButton.layer setMasksToBounds:YES];
                
                [vi addSubview:closeButton];
            }
        }
        
        [_markView addSubview:vi];
    }

}

- (void)btnDeleteClicked:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    NSInteger tag = btn.tag;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        Mark* m = [_markList objectAtIndex:tag];
        
        BOOL isOK = [Mark remove:m.labelId workGroupId:_workGroupId];
        if (isOK) {
            [_markList removeObjectAtIndex:tag];
            //[_authority removeObjectAtIndex:tag];
            [self showMark:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"标签删除失败！请稍后再试！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    });
    
}

- (void)btnUpdateClicked:(UIButton*)button
{
    UIView* pView = button.superview;
    NSInteger tag = pView.tag;
    
    Mark* m = [_markList objectAtIndex:tag];
    
    if (_txtUpdate != nil) {
        [_txtUpdate removeFromSuperview];
    }
    _txtUpdate = [[UITextField alloc] initWithFrame:pView.frame];
    [_txtUpdate setBackgroundColor:pView.backgroundColor];
    [_txtUpdate setTextColor:[UIColor whiteColor]];
    [_txtUpdate setText:m.labelName];
    _txtUpdate.tag = tag;
    [self.view addSubview:_txtUpdate];
    [_txtUpdate becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editButtonClicked:(UIButton *) barButton
{
    if (!_editButtonClicked) {
        [self showMark:YES];
        _editButtonClicked = YES;
        [barButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    else{
        [self showMark:NO];
        _editButtonClicked = NO;
        [barButton setTitle:@"编辑" forState:UIControlStateNormal];

    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_txtUpdate != nil) {
        
        NSInteger tag = _txtUpdate.tag;
        NSString* newName = _txtUpdate.text;
        
        if (newName != nil && ![newName isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                Mark* m = [_markList objectAtIndex:tag];
                
                m.labelName = newName;
                BOOL isOK = [Mark update:m.labelId labelName:newName];
                if (isOK) {
                    [_markList removeObjectAtIndex:tag];
                    [_markList insertObject:m atIndex:tag];
                    //[_authority removeObjectAtIndex:tag];
                    [self showMark:YES];
                }
                
            });
        }
        
        [_txtUpdate removeFromSuperview];
    }
}

@end
