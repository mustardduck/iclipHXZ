//
//  MegListController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/23.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MegListController.h"
#import "CommonFile.h"
#import "UICommon.h"
#import "MessageCenter.h"
#import "LoginUser.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MJRefresh.h>
#import "UIColor+HexString.h"
#import "ICWorkingDetailViewController.h"

@interface MegListController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView* _tableView;
    NSInteger               _pageNo;
    NSInteger               _pageRowCount;

    NSMutableArray * _megArr;
}

@end

@implementation MegListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    _pageNo = 1;
    _pageRowCount = 10;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self addRefrish];

}

- (void)addRefrish
{
    NSString* userid = [LoginUser loginUserID];
    
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        
        _pageNo = 1;
        
        NSMutableArray * mcArr = [MessageCenter getMessageListByUserID:userid currentPageIndex:_pageNo pageSize:_pageRowCount workGroupId:_workGroupId];
        
        _megArr = mcArr;
        
        [_tableView reloadData];
        
        [_tableView.header endRefreshing];
        
        if (_megArr.count == 0) {
            [_tableView.footer beginRefreshing];
        }
        
    }];
    
    
    [_tableView.header beginRefreshing];
    
    [_tableView addLegendFooterWithRefreshingBlock:^{
        
        _pageNo++;
        
        NSMutableArray * newArr = [MessageCenter getMessageListByUserID:userid currentPageIndex:_pageNo pageSize:_pageRowCount workGroupId:_workGroupId];
        
        if (newArr.count > 0) {
            [_megArr addObjectsFromArray:newArr];
            
            [_tableView reloadData];
            
            
            MessageCenter* m = [newArr objectAtIndex:0];
            if (_pageNo >= m.totalPages) {
                [_tableView.footer endRefreshing];
                
                [_tableView.footer noticeNoMoreData];
            }
            else
            {
                [_tableView.footer endRefreshing];
            }
        }
        else
        {
            [_tableView.footer endRefreshing];
            [_tableView.footer noticeNoMoreData];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        return cell.frame.size.height;
    }
    else
    {
        return 85;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _megArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MegCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.frame = CGRectMake(0, 0, SCREENWIDTH, 85);
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    MessageCenter * mc = _megArr[indexPath.row];
    
    UIImageView * photo = [[UIImageView alloc] init];
    photo.frame = CGRectMake(14, 14, 50, 50);
    [photo setRoundCorner:5];
    [photo setImageWithURL:[NSURL URLWithString:mc.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    photo.tag = 5;
    
    UILabel * nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, SCREENWIDTH - 150 -180 - 80 * 2, 16)];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textColor = [UIColor grayTitleColor];
    nameLbl.text = mc.userName;
    nameLbl.textAlignment = NSTextAlignmentLeft;
    nameLbl.font = Font(14);
    nameLbl.tag = 1;
    
    CGSize boundSize = CGSizeMake(SCREENWIDTH - 50 - 60 - 53, CGFLOAT_MAX);
    
    UILabel * commentLbl = [[UILabel alloc] init];
    commentLbl.frame = CGRectMake(77, 37, boundSize.width, boundSize.height);
    commentLbl.backgroundColor = [UIColor clearColor];
    commentLbl.textColor = [UIColor whiteColor];
//    NSString * com = @"哈咯后斤斤计较么哈咯后哈哈咯后斤斤计较哈咯哈咯后斤斤计较么哈咯后哈哈咯后斤斤计较哈咯后斤斤计较么哈咯后哈哈咯后斤斤计较么咯后斤斤计较么斤斤计较么么咯后斤斤计较么斤斤计较么后斤斤计较么哈咯后哈哈咯后斤斤计较么咯后斤斤计较么斤斤计较么么咯后斤斤计较么斤斤计较么";
    commentLbl.text = mc.commentText;
    commentLbl.font = Font(14);
    commentLbl.numberOfLines = 0;
    commentLbl.tag = 2;
    
    UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(77, commentLbl.bottom + 10, 200, 16)];
    dateLbl.backgroundColor = [UIColor clearColor];
    dateLbl.textColor = [UIColor grayTitleColor];
    NSString * dateStr = [UICommon dayAndHourFromString:mc.createTime formatStyle:@"MM月dd日 HH:mm"];
    dateLbl.text = dateStr;
    dateLbl.textAlignment = NSTextAlignmentLeft;
    dateLbl.font = Font(12);
    dateLbl.tag = 3;
    

    CGFloat he = 0;
    if(mc.commentText.length)
    {
        CGSize requiredSize = [UICommon getSizeFromString:mc.commentText withSize:boundSize withFont:commentLbl.font];
        commentLbl.height = requiredSize.height;
        
        he = requiredSize.height + 70;
        
        if(he < 85)
        {
            he = 85;
        }
    }
    
    
    CGRect rect = cell.frame;
    rect.size.height = he;
    cell.frame = rect;
    
    if(mc.rightImg.length)
    {
        UIImageView * rightPhoto = [[UIImageView alloc] init];
        rightPhoto.frame = CGRectMake(SCREENWIDTH - 60 - 14, 14, 60, 60);
        [rightPhoto setImageWithURL:[NSURL URLWithString:mc.rightImg] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        rightPhoto.tag = 6;
        [cell.contentView addSubview:rightPhoto];
    }
    else
    {
        UILabel * rightLbl = [[UILabel alloc] init];
        rightLbl.frame = CGRectMake(SCREENWIDTH - 60 - 14, 14, 60, 60);
        rightLbl.backgroundColor = [UIColor clearColor];
        rightLbl.textColor = [UIColor grayTitleColor];
        rightLbl.text = mc.missionText;
        rightLbl.font = Font(12);
        rightLbl.numberOfLines = 3;
        rightLbl.tag = 4;
        
        [cell.contentView addSubview:rightLbl];
    }


    
    [cell.contentView addSubview:photo];
    [cell.contentView addSubview:nameLbl];
    [cell.contentView addSubview:commentLbl];
    [cell.contentView addSubview:dateLbl];
    
    UIView * nameView = [cell viewWithTag:1];
    UIView * commentView = [cell viewWithTag:2];
    UIView * dateView = [cell viewWithTag:3];
    UIView * rightView = [cell viewWithTag:4];


    nameView.left = 77;
    commentView.left = 77;
    commentView.top = 37;
    dateView.left = 77;
    dateView.top = commentView.bottom + 10;
    rightView.left = SCREENWIDTH - 60 - 14;
    rightView.top = 14;
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(14, H(cell) - 0.5, SCREENWIDTH - 14, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [cell.contentView addSubview:line];

    cell.contentView.backgroundColor = [UIColor backgroundColor];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCenter * mc = _megArr[indexPath.row];

    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
    ((ICWorkingDetailViewController*)vc).taskId = mc.taskId;
    ((ICWorkingDetailViewController*)vc).messageId = mc.megId;

    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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
