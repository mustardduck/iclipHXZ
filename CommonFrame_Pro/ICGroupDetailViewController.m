//
//  ICGroupDetailViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/24.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICGroupDetailViewController.h"
#import "UIColor+HexString.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <MJRefresh.h>
#import "Mission.h"
#import "UICommon.h"

@interface ICGroupDetailViewController()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView* _tableView;
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    NSMutableArray*         _contentArray;
    NSInteger               _pageNo;
    NSInteger               _pageRowCount;
}

@end

@implementation ICGroupDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
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
    
    [self.navigationItem setTitle:_group.workGroupName];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    _pageNo = 1;
    _pageRowCount = 10;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   [_tableView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    //[_tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(reloadTableData)];
    //[_tableView.header beginRefreshing];
    
    //[_tableView addLegendFooterWithRefreshingBlock:^{
    //    [_tableView.footer endRefreshing];
    //}];
    
    //_tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    //_tableView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    
    
    [self addRefrish];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_group != nil) {
        CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
        _tableView.tableHeaderView = ({
            
            UIView* hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 300)];
            [hView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
            
            UIImageView* bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 256)];
            [bgImage setBackgroundColor:[UIColor clearColor]];
            //[bgImage setImage:[UIImage imageNamed:@"bimg.jpg"]];
            [bgImage setImageWithURL:[NSURL URLWithString:_group.workGroupImg] placeholderImage:[UIImage imageNamed:@"bimg.jpg"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [hView addSubview:bgImage];
            
            UIView* sView = [[UIView alloc] initWithFrame:CGRectMake(tableWidth - 90, 196, 80, 80)];
            [sView setBackgroundColor:[UIColor colorWithHexString:@"#393b48"]];
            
            UIImageView* sImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            [sImage setBackgroundColor:[UIColor clearColor]];
            [sImage setImage:[UIImage imageNamed:@"icon_touxiang"]];
            [sImage setImageWithURL:[NSURL URLWithString:_group.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            UIButton* btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
            [btnPhoto setBackgroundColor:[UIColor clearColor]];
            [btnPhoto setBackgroundImage:sImage.image forState:UIControlStateNormal];
            [btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [sView addSubview:btnPhoto];
            
            [hView addSubview:sView];
            
            UILabel* gName = [[UILabel alloc ] initWithFrame:CGRectMake(20, 219, 190, 20)];
            [gName setBackgroundColor:[UIColor clearColor]];
            [gName setFont:[UIFont boldSystemFontOfSize:19]];
            [gName setTextAlignment:NSTextAlignmentRight];
            [gName setTextColor:[UIColor whiteColor]];
            [gName setNumberOfLines:1];
            
            [gName setText:_group.workGroupName];
            
            [hView addSubview:gName];
            
            
            
            UILabel* lbl = [[UILabel alloc ] initWithFrame:CGRectMake(15, 276, tableWidth - 30, 20)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setFont:[UIFont systemFontOfSize:15]];
            [lbl setTextAlignment:NSTextAlignmentRight];
            [lbl setTextColor:[UIColor grayColor]];
            [lbl setNumberOfLines:1];
            
            [lbl setText:_group.workGroupMain];
            
            [hView addSubview:lbl];
            
            hView;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addRefrish
{
    NSString* userid = [LoginUser loginUserID];
    NSString* workGroupId = self.group.workGroupId;
    
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        
        _pageNo = 1;
        _contentArray =  [NSMutableArray arrayWithArray:[Mission getMssionListbyUserID:userid currentPageIndex:_pageNo pageSize:_pageRowCount workGroupId:workGroupId termString:@""]];
        
        NSLog(@"Header:%@",_contentArray);
        
        [_tableView reloadData];
        
        [_tableView.header endRefreshing];
        
        if (_contentArray.count == 0) {
            [_tableView.footer beginRefreshing];
        }
        
    }];
    
    
    [_tableView.header beginRefreshing];
    
    [_tableView addLegendFooterWithRefreshingBlock:^{
        
        _pageNo++;
        
        NSArray* newArr = [Mission getMssionListbyUserID:userid currentPageIndex:_pageNo pageSize:_pageRowCount  workGroupId:workGroupId termString:@""];
        
        if (newArr.count > 0) {
            [_contentArray addObjectsFromArray:newArr];
            
            NSLog(@"%@",_contentArray);
            
            [_tableView reloadData];
            
            Mission* m = [newArr objectAtIndex:0];
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
        
        
        
        //[_tableView.footer setTitle:@"wo cao" forState:MJRefreshFooterStateNoMoreData];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnPhotoClicked:(id)sender
{
//    if (_group.isAdmin) {
        UIStoryboard* mainStrory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* controller = [mainStrory instantiateViewControllerWithIdentifier:@"ICSettingGroupViewController"];
        ((ICSettingGroupViewController*)controller).workGroupId = _group.workGroupId;
        ((ICSettingGroupViewController*)controller).workGroup = _group;
        ((ICSettingGroupViewController*)controller).icGroupDetailController = self;
        [self.navigationController pushViewController:controller animated:YES];
//    }
//    else
//    {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"权限不足，因为您不是该工作组创建者！" delegate:self
//                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    
    
}


#pragma mark -
#pragma mark Table View Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat cellHeight = _screenHeight * 0.321;
//    if (indexPath.row > 0) {
//        cellHeight = cellHeight - 4;
//    }
    
    Mission* mi = [_contentArray objectAtIndex:indexPath.row];
    
    CGFloat contentH = [UICommon getSizeFromString:mi.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:18].height;
    
    CGFloat cellHeight = contentH + 70 + 42;
    
    if (indexPath.row == 0) {
        
        cellHeight = cellHeight + 37;
        
    }
    
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArray.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    UIView* dirLine = [[UIView alloc] init];
    NSInteger ind = indexPath.row;
    
    CGFloat contentHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (ind == 0) {
        dirLine.frame = CGRectMake(50 + 7.5, 19 + 15, 0.5, contentHeight - 19 - 15 + 1);
    }
    else
    {
        dirLine.frame = CGRectMake(57.5, 0, 0.5, contentHeight + 1);
    }
    [dirLine setBackgroundColor:[UIColor whiteColor]];
    [cell.selectedBackgroundView addSubview:dirLine];
    
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.156 * _screenWidth + 15, contentHeight - 1, _screenWidth - (0.156 * _screenWidth + 15) - 12, 0.5)];
    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupDetailTableViewCellId2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSInteger index = indexPath.row;
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_contentArray.count == 0) {
        return cell;
    }
    
    Mission* mi = [_contentArray objectAtIndex:index];

    if (cell.contentView.subviews.count == 0) {
        
//        CGFloat cellHeight = _screenHeight * 0.321;
//        if (index > 0) {
//            cellHeight = cellHeight - 4;
//        }
        
        CGFloat contentH = [UICommon getSizeFromString:mi.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:18].height;
        
        CGFloat cellHeight = contentH + 70 + 42;
        
        if (indexPath.row == 0) {
            cellHeight = cellHeight + 37;
        }
        
        CGFloat contentHeight = cellHeight;
        CGFloat contentWidth = _screenWidth;
        
        UIView* dirLine = [[UIView alloc] init];
        
        BOOL isFristIndex = NO;
        
        if (index == 0) {
            isFristIndex = YES;
            UIImageView* timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(50, 19, 15, 15)];
            [timeIcon setImage:[UIImage imageNamed:@"icon_shijian"]];
            [timeIcon setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:timeIcon];
            
            
            dirLine.frame = CGRectMake(timeIcon.frame.origin.x + 7.5, timeIcon.frame.origin.y + 15, 0.5, contentHeight - timeIcon.frame.origin.y - timeIcon.frame.size.height);
        }
        else
        {
            dirLine.frame = CGRectMake(57.5, 0, 0.5, contentHeight);
        }
        [dirLine setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview:dirLine];
        
        CGRect dateFrame = CGRectMake(0, isFristIndex?64:30, 50, 12);
        UILabel* dateMon = [[UILabel alloc] initWithFrame:dateFrame];
        dateMon.font = [UIFont boldSystemFontOfSize:15];
        dateMon.textAlignment = NSTextAlignmentRight;
        dateMon.textColor = [UIColor whiteColor];
        dateMon.text = mi.monthAndDay;
        [cell.contentView addSubview:dateMon];
        
        UILabel* dateHour = [[UILabel alloc] initWithFrame:CGRectMake(0, dateMon.frame.origin.y + 12 + 4, 50, 8)];
        dateHour.font = [UIFont systemFontOfSize:8];
        dateHour.textAlignment = NSTextAlignmentRight;
        dateHour.textColor = [UIColor whiteColor];
        dateHour.text = mi.hour;
        [cell.contentView addSubview:dateHour];
        
        //读
        BOOL isRead = mi.isRead;
        
        UILabel* readLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, dateHour.frame.origin.y + 13, 50, 8)];
        readLbl.font = [UIFont systemFontOfSize:12];
        readLbl.textAlignment = NSTextAlignmentRight;
        readLbl.textColor = [UIColor whiteColor];
        
        if(!isRead)
        {
            readLbl.text = @"未读";
            [cell.contentView addSubview:readLbl];
            
            UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(18, dateHour.frame.origin.y + 17 , 5, 5)];
            iconView.image = [UIImage imageNamed:@"icon_du"];
            [cell.contentView addSubview:iconView];
        }
        else
        {
            readLbl.text = @"已读";
            [cell.contentView addSubview:readLbl];
        }
        
        UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(55, isFristIndex?68:34, 5, 5)];
        corner.layer.cornerRadius = 2;
        corner.backgroundColor = [UIColor whiteColor];
        corner.layer.borderColor = [UIColor whiteColor].CGColor;
        corner.layer.borderWidth = 1.0f;
        corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
        corner.layer.masksToBounds = YES;
        corner.clipsToBounds = YES;
        [cell.contentView addSubview:corner];
        
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.156 * contentWidth + 15, contentHeight - 1, contentWidth - (0.156 * contentWidth + 15) - 12, 0.5)];
        [bottomLine setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview:bottomLine];
        
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(dirLine.frame.origin.x + 20, isFristIndex?52:15, 36, 36)];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:mi.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [photo setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:photo];
        
        
        CGRect nameFrame =CGRectMake(photo.frame.origin.x + photo.frame.size.width + 6, photo.frame.origin.y + 10,
                                     contentWidth - (photo.frame.origin.x + photo.frame.size.width + 6 + 39) , 21);
        UILabel* name = [[UILabel alloc] initWithFrame: nameFrame];
        name.text  = [NSString stringWithFormat:@"%@ 发送到 %@",mi.userName,mi.workGroupName];
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:name];
        
        CGRect contentFrame = CGRectMake(photo.frame.origin.x, photo.frame.origin.y + photo.frame.size.height + 18,
                                         contentWidth - (photo.frame.origin.x + 39),
                                         contentH);
        UILabel* content = [[UILabel alloc] init];
        content.frame = contentFrame;
        [content setNumberOfLines:0];
        content.textColor = [UIColor grayColor];
        content.font = [UIFont boldSystemFontOfSize:15];
        content.text = mi.main;
        [content setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:content];
        
        
        UIImageView* attachment = [[UIImageView alloc] initWithFrame:CGRectMake(X(content), YH(content) + 20 , 12, 10)];
        attachment.image = [UIImage imageNamed:@"btn_fujianIcon"];
        [cell.contentView addSubview:attachment];
        
        UILabel* fujianLbl = [[UILabel alloc] init];
        fujianLbl.textColor = [UIColor grayColor];
        fujianLbl.font = [UIFont boldSystemFontOfSize:10];
        [fujianLbl setBackgroundColor:[UIColor clearColor]];
        fujianLbl.text = [NSString stringWithFormat:@"附件 (%d)", mi.accessoryNum];
        
        fujianLbl.frame = CGRectMake(XW(attachment) + 5, Y(attachment) - 2, [UICommon getWidthFromLabel:fujianLbl].width, 14);
        [cell.contentView addSubview:fujianLbl];
        
        UIImageView* plIcon = [[UIImageView alloc] initWithFrame:CGRectMake(XW(fujianLbl) + 21, YH(content) + 20 , 12, 10)];
        plIcon.image = [UIImage imageNamed:@"btn_pinglun"];
        [cell.contentView addSubview:plIcon];
        
        UILabel* plLbl = [[UILabel alloc] init];
        plLbl.textColor = [UIColor grayColor];
        plLbl.font = [UIFont boldSystemFontOfSize:10];
        [plLbl setBackgroundColor:[UIColor clearColor]];
        plLbl.text = [NSString stringWithFormat:@"评论 (%d)", mi.replayNum];
        
        plLbl.frame = CGRectMake(XW(plIcon) + 5, Y(attachment) - 2, [UICommon getWidthFromLabel:plLbl].width, 14);
        [cell.contentView addSubview:plLbl];
        
        //[cell.contentView addSubview:pView];
        
        //[cell.contentView setBackgroundColor:[UIColor blackColor]];
        
//        [cell.contentView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
        
        cell.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadTableData
{
    //[_tableView.header endRefreshing];

}

@end
