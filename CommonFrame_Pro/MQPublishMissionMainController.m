//
//  MQPublishMissionMainController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/27.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQPublishMissionMainController.h"
#import "MQPublishMissionMainCell.h"
#import "Mission.h"
#import "UICommon.h"

@interface MQPublishMissionMainController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray * _dataArray;
    
    NSInteger _dataCount;
    
    UITextField * _currentField;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;


@end

@implementation MQPublishMissionMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(btnBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    [self.view setBackgroundColor:[UIColor backgroundColor]];
    
    _dataCount = 1;
}

- (IBAction)btnBackButtonClicked:(id)sender
{
//    [self hiddenKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MQMissionMainCell";
    MQPublishMissionMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[MQPublishMissionMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if(indexPath.row == _dataCount - 1)
    {
        cell.addView.hidden = NO;        
        UIView * line = [cell viewWithTag:1];
        if(!line)
        {
            line = [[UIView alloc] initWithFrame:CGRectMake(26.5, 0, 0.5, 35)];
            line.backgroundColor = [UIColor grayLineColor];
            line.tag = 1;
        }
        line.height = 35;
        [cell.contentView addSubview:line];
        
        UIView * line2 = [cell viewWithTag:2];
        if(!line2)
        {
            line2 = [[UIView alloc] initWithFrame:CGRectMake(27, 35.5, 13, 0.5)];
            line2.backgroundColor = [UIColor grayLineColor];
            line2.tag = 2;
        }
        [cell.contentView addSubview:line2];
        
        [cell.addBtn addTarget:self action:@selector(addMissionCell:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.addView.hidden = YES;

        UIView * line = [cell viewWithTag:1];
        if(!line)
        {
            line = [[UIView alloc] initWithFrame:CGRectMake(26.5, 0, 0.5, 60)];
            line.backgroundColor = [UIColor grayLineColor];
            line.tag = 1;
        }
        line.height = 60;
        [cell.contentView addSubview:line];
        
        UIView * line2 = [cell viewWithTag:2];
        if(!line2)
        {
            line2 = [[UIView alloc] initWithFrame:CGRectMake(27, 35.5, 13, 0.5)];
            line2.backgroundColor = [UIColor grayLineColor];
            line2.tag = 2;
        }
        [cell.contentView addSubview:line2];
        
        [self addDoneToKeyboard:cell.titleLbl];
    }
//    Mission* ms = [_dataArray objectAtIndex:indexPath.row];

    [cell.titleView setRoundColorCorner:5 withColor:[UIColor grayLineColor]];
    
    return cell;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    _currentField = textField;
}

- (void) hiddenKeyboard
{
    [_currentField resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void) addMissionCell:(id)sender
{
    _dataCount ++;
    
    [_mainTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
