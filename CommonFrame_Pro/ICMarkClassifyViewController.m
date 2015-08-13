//
//  ICMarkClassifyViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMarkClassifyViewController.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface ICMarkClassifyViewController()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView*    _tableView;
                    NSArray*        _markList;
    NSMutableArray*                 _changedArray;
}

@end

@implementation ICMarkClassifyViewController

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
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneClicked:)];
    [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _markList = [NSArray array];
    _changedArray = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
    
        _markList = [NSArray arrayWithArray:[Member getMembersByWorkGroupIDAndLabelID:_workGroupId labelId:_labelId]];
        if (_markList.count > 0) {
            _tableView.dataSource = self;
            _tableView.delegate = self;
            [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [_tableView reloadData];
            [self setExtraCellLineHidden:_tableView];
        }
        
    });
    
    //_markList = [NSMutableArray arrayWithArray:@[@"乃昂梅西",@"乃昂梅西",@"乃昂梅西",@"乃昂梅西",@"乃昂梅西",@"乃昂梅西",@"乃昂梅西"]] ;
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnDoneClicked:(id)sender
{
    if (_changedArray.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isOk = [Mark updateMarkMember:_labelId workGroupID:_workGroupId memberIdArray:_changedArray];
            if (isOk) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"工作组成员标签更改成功！" delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    }
}

#pragma mark -
#pragma mark Table View Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_markList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    static NSString *cellId = @"MarkClassifyTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    Member* m = [_markList objectAtIndex:index];
    
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 36, 36)];
    img.image = [UIImage imageNamed:@"icon_chengyuan"];
    [img setImageWithURL:[NSURL URLWithString:m.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [cell.contentView addSubview:img];
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(54, 24, 160, 13)];
    name.text = m.name;
    name.textColor = [UIColor whiteColor];
    name.font = [UIFont systemFontOfSize:15];
    
    [cell.contentView addSubview:name];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    UISwitch* swi = [[UISwitch alloc] initWithFrame:CGRectMake(width - 65, 15, 60, 40)];
    if(m.isHave){
        swi.on = YES;
        [_changedArray addObject:m.workContractsId];
    }
    else
    {
        swi.on = NO;
    }
    swi.tag = index;
    [swi addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    [cell.contentView addSubview:swi];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [cell.contentView addSubview:bottomLine];
    
    return cell;
}

-(void)switchChanged:(id)sender
{
    UISwitch* swi = (UISwitch*)sender;
    NSInteger tag = swi.tag;
    Member* m = [_markList objectAtIndex:tag];
    if (swi.on) {
        [_changedArray addObject:m.workContractsId];
    }
    else
    {
        for (NSString* tm in _changedArray) {
            if (tm  == m.workContractsId) {
                [_changedArray removeObject:tm];
                break;
            }
        }
    }
    
    NSLog(@"%ld",tag);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    
    myView.backgroundColor = tableView.backgroundColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 24, 120, 9)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=@"工作汇报";
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    
    [myView addSubview:titleLabel];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [myView addSubview:bottomLine];
    
    return myView;
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    
}


@end
