//
//  MQMyMessageListController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/21.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQMyMessageListController.h"
#import "UICommon.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MJRefresh.h>
#import "ICWorkingDetailViewController.h"
#import "MessageCenter.h"
#import "LoginUser.h"
#import "SystemMessage.h"
#import "ICWorkingDetailViewController.h"
#import "SVProgressHUD.h"

@interface MQMyMessageListController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView* _tableView;
    
    NSInteger               _pageNo;
    NSInteger               _pageRowCount;
    
    NSMutableArray * _megArr;
    NSString * _keyString;
    
    UIButton * _commentBtn;
    UIButton * _sysBtn;
    UIView * _redPoint;
    UIView * _yellowLine;
    UITextField * _searchField;
    UIButton * _searchBtn;
    
    BOOL _sysBtnSelected;
}

@end

@implementation MQMyMessageListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _keyString = @"";
    
    
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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    _pageNo = 1;
    _pageRowCount = 30;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setBackgroundColor:[UIColor backgroundColor]];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self addRefrish];
    
    [self initHeaderView];
    
    [self resetHeaderView];
}

- (void) commentBtnClicked:(id) sender
{
    _sysBtnSelected = NO;
    [self resetHeaderView];
    [_tableView.footer resetNoMoreData];
    
    _commentBtn.backgroundColor = [UIColor backgroundColor];
    [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _sysBtn.backgroundColor = RGBCOLOR(40, 40, 40);
    [_sysBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
    
    _yellowLine.left = 0;

}

- (void) systemBtnClicked:(id) sender
{
    _redPoint.hidden = YES;
    _keyString = @"";
    _searchField.text = @"";
    
    [_searchField resignFirstResponder];

    _sysBtnSelected = YES;
    [self resetHeaderView];
    [_tableView.footer resetNoMoreData];

    _sysBtn.backgroundColor = [UIColor backgroundColor];
    [_sysBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _commentBtn.backgroundColor = RGBCOLOR(40, 40, 40);
    [_commentBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
    
    _yellowLine.left = SCREENWIDTH / 2;
}

- (void) initHeaderView
{
    _commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH / 2, 44)];
    [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_commentBtn setTitle:@"评论消息" forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = Font(16);
    _commentBtn.backgroundColor = [UIColor backgroundColor];
    [_commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _sysBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2, 0, SCREENWIDTH / 2, 44)];
    [_sysBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
    [_sysBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    [_sysBtn setTitle:@"系统消息" forState:UIControlStateNormal];
    _sysBtn.titleLabel.font = Font(16);
    _sysBtn.backgroundColor = RGBCOLOR(40, 40, 40);
    [_sysBtn addTarget:self action:@selector(systemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _redPoint = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH / 2 ) * 5 / 3, 11, 7, 7)];
    _redPoint.backgroundColor = [UIColor redTextColor];
    [_redPoint setRoundCorner:W(_redPoint) / 2];
    
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(27, 0, SCREENWIDTH - 41 - 14 - 70, 34)];
    _searchField.backgroundColor = [UIColor clearColor];
    _searchField.placeholder = @"请输入您要查找的关键字";
    [_searchField setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
    _searchField.font = Font(15);
    _searchField.textColor = [UIColor grayTitleColor];
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addDoneToKeyboard:_searchField];
    
    _searchBtn =  [[UIButton alloc] initWithFrame:CGRectMake(XW(_searchField), 0, 70, 34)];
    _searchBtn.backgroundColor = RGBCOLOR(238, 238, 238);
    [_searchBtn setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
    [_searchBtn setTitle:@"查找" forState:UIControlStateNormal];
    _searchBtn.titleLabel.font = Font(15);
    [_searchBtn addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _yellowLine = [[UIView alloc] initWithFrame:CGRectMake(0, 41, SCREENWIDTH / 2, 3)];
    _yellowLine.backgroundColor = [UIColor yellowTitleColor];
}

- (void) hiddenKeyboard
{
    [_searchField resignFirstResponder];
}

- (void) searchBtnClicked:(id)sender
{
    [_searchField resignFirstResponder];
    
    _keyString = _searchField.text;
    
    [self resetHeaderView];
    [_tableView.footer resetNoMoreData];

}

- (UIView *) searchHeaderView
{
    UIView * mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44 + 62)];
    
    [mainView addSubview:_commentBtn];
    [mainView addSubview:_sysBtn];
    if(_isShowRedPoint)
    {
        [mainView addSubview:_redPoint];
    }
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [mainView addSubview:line];
    
    [mainView addSubview:_yellowLine];
    
    UIView * searchView = [[UIView alloc] initWithFrame:CGRectMake(14, _sysBtn.bottom + 14, SCREENWIDTH - 14 * 2, 34)];
    searchView.backgroundColor = [UIColor whiteColor];
    [searchView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
    [mainView addSubview:searchView];
    
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 14, 14)];
    icon.image = [UIImage imageNamed:@"icon_sousuo"];
    [searchView addSubview:icon];
    
    [searchView addSubview:_searchField];
    [searchView addSubview:_searchBtn];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(W(searchView) - 70, 0, 0.5, 34)];
    line.backgroundColor = [UIColor grayLineColor];
    [searchView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, H(mainView) - 0.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [mainView addSubview:line];
    
    return mainView;
}

- (UIView *) systemHeaderView
{
    UIView * mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    
    [mainView addSubview:_commentBtn];
    [mainView addSubview:_sysBtn];
    if(_isShowRedPoint)
    {
        [mainView addSubview:_redPoint];
    }
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [mainView addSubview:line];
    
    _yellowLine.left = SCREENWIDTH / 2;
    [mainView addSubview:_yellowLine];

    return mainView;
}

- (void) resetHeaderView
{
    _tableView.tableHeaderView = nil;
    
    if(!_sysBtnSelected)
    {
        _tableView.tableHeaderView = ({
            [self searchHeaderView];
        });
    }
    else
    {
        _tableView.tableHeaderView = ({
            [self systemHeaderView];
        });
    }
    [_tableView.header beginRefreshing];
}

- (void)addRefrish
{
    NSString* userid = [LoginUser loginUserID];
    
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        
        _pageNo = 1;
        
        NSMutableArray * mcArr;
        
        if(!_sysBtnSelected)
        {
            mcArr = [MessageCenter findMessageCenterByMessage:userid currentPageIndex:_pageNo pageSize:_pageRowCount keyString:_keyString];
        }
        else
        {
            mcArr = [SystemMessage findSysMessage:userid currentPageIndex:_pageNo pageSize:_pageRowCount];
        }
        
        
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
        
        NSMutableArray * newArr;
        
        if(!_sysBtnSelected)
        {
            newArr = [MessageCenter findMessageCenterByMessage:userid currentPageIndex:_pageNo pageSize:_pageRowCount keyString:_keyString];
        }
        else
        {
            newArr = [SystemMessage findSysMessage:userid currentPageIndex:_pageNo pageSize:_pageRowCount];
        }
        
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

- (IBAction)btnBackButtonClicked:(id)sender
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
    
    if(!_sysBtnSelected)
    {
        MessageCenter * mc = _megArr[indexPath.row];
        
        UIImageView * photo = [[UIImageView alloc] init];
        photo.frame = CGRectMake(14, 14, 50, 50);
        [photo setRoundCorner:5];
        [photo setImageWithURL:[NSURL URLWithString:mc.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        UILabel * nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 14, 13, SCREENWIDTH - XW(photo) - 14 * 2, 16)];
        nameLbl.backgroundColor = [UIColor clearColor];
        nameLbl.textColor = [UIColor grayTitleColor];
        nameLbl.text = mc.userName;
        nameLbl.textAlignment = NSTextAlignmentLeft;
        nameLbl.font = Font(15);
        
        CGSize boundSize = CGSizeMake(W(nameLbl), CGFLOAT_MAX);
        
        UILabel * commentLbl = [[UILabel alloc] init];
        commentLbl.frame = CGRectMake(X(nameLbl), nameLbl.bottom + 9, boundSize.width, boundSize.height);
        commentLbl.backgroundColor = [UIColor clearColor];
        commentLbl.textColor = [UIColor whiteColor];
        //    NSString * com = @"哈咯后斤斤计较么哈咯后哈哈咯后斤斤计较哈咯哈咯后斤斤计较么哈咯后哈哈咯后斤斤计较哈咯后斤斤计较么哈咯后哈哈咯后斤斤计较么咯后斤斤计较么斤斤计较么么咯后斤斤计较么斤斤计较么后斤斤计较么哈咯后哈哈咯后斤斤计较么咯后斤斤计较么斤斤计较么么咯后斤斤计较么斤斤计较么";
        commentLbl.text = mc.commentText;
        commentLbl.font = Font(15);
        commentLbl.numberOfLines = 0;
        commentLbl.tag = 1;
        
        //部门
        UILabel * wgLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(nameLbl), commentLbl.bottom + 10, SCREENWIDTH - XW(photo) - 14 - 100 , 16)];
        wgLbl.backgroundColor = [UIColor clearColor];
        wgLbl.textColor = [UIColor grayTitleColor];
        wgLbl.text = mc.wgName;
        wgLbl.textAlignment = NSTextAlignmentLeft;
        wgLbl.font = Font(12);
        wgLbl.tag = 2;
        
        //日期
        UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 100 - 14, commentLbl.bottom + 10, 100, 16)];
        dateLbl.backgroundColor = [UIColor clearColor];
        dateLbl.textColor = [UIColor grayTitleColor];
        NSString * dateStr = [UICommon dayAndHourFromString:mc.createTime formatStyle:@"MM月dd日 HH:mm"];
        dateLbl.text = dateStr;
        dateLbl.textAlignment = NSTextAlignmentRight;
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
        
        [cell.contentView addSubview:photo];
        [cell.contentView addSubview:nameLbl];
        [cell.contentView addSubview:commentLbl];
        [cell.contentView addSubview:wgLbl];
        [cell.contentView addSubview:dateLbl];
        
        UIView * commentView = [cell viewWithTag:1];
        UIView * wgNameView = [cell viewWithTag:2];
        UIView * dateView = [cell viewWithTag:3];
        
        commentView.top = nameLbl.bottom + 7;
        wgNameView.top = commentLbl.bottom + 8;
        dateView.top = commentLbl.bottom + 8;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(14, H(cell) - 0.5, SCREENWIDTH - 14, 0.5)];
        line.backgroundColor = [UIColor grayLineColor];
        [cell.contentView addSubview:line];
        
        cell.contentView.backgroundColor = [UIColor backgroundColor];
        
        return cell;
    }
    else
    {
        SystemMessage * sm = _megArr[indexPath.row];
        
        UIImageView * photo = [[UIImageView alloc] init];
        photo.frame = CGRectMake(14, 14, 50, 50);
        [photo setRoundCorner:5];
        photo.image = [UIImage imageNamed:@"icon_xiaoxizhushou"];
        
        UILabel * nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 14, 13, SCREENWIDTH - XW(photo) - 14 * 2, 16)];
        nameLbl.backgroundColor = [UIColor clearColor];
        nameLbl.textColor = [UIColor grayTitleColor];
        nameLbl.text = @"系统助手";
        nameLbl.textAlignment = NSTextAlignmentLeft;
        nameLbl.font = Font(15);

        [cell.contentView addSubview:photo];
        [cell.contentView addSubview:nameLbl];
        
        CGFloat contentHeight;
        
        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(nameLbl), nameLbl.bottom + 9, SCREENWIDTH - X(nameLbl) - 14, 16)];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.textAlignment = NSTextAlignmentLeft;
        titleLbl.font = Font(15);
        [cell.contentView addSubview:titleLbl];
        
        if([sm.source intValue] == 10)//超时
        {
            contentHeight = 114;
            
            titleLbl.text = [NSString stringWithFormat:@"您的任务：\"%@\"", sm.title];
            
            titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(nameLbl), titleLbl.bottom + 9, SCREENWIDTH - X(nameLbl) - 14, 16)];
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.textColor = [UIColor whiteColor];
            titleLbl.text = @"已超时，请点击处理。";
            titleLbl.textAlignment = NSTextAlignmentLeft;
            titleLbl.font = Font(15);
            
            //部门
            UILabel * wgLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(nameLbl), titleLbl.bottom + 10, SCREENWIDTH - X(titleLbl) - 100 , 16)];
            wgLbl.backgroundColor = [UIColor clearColor];
            wgLbl.textColor = [UIColor grayTitleColor];
            wgLbl.text = sm.wgName;
            wgLbl.textAlignment = NSTextAlignmentLeft;
            wgLbl.font = Font(12);
            
            //日期
            UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 100 - 14, titleLbl.bottom + 10, 100, 16)];
            dateLbl.backgroundColor = [UIColor clearColor];
            dateLbl.textColor = [UIColor grayTitleColor];
            NSString * dateStr = [UICommon dayAndHourFromString:sm.createTime formatStyle:@"MM月dd日 HH:mm"];
            dateLbl.text = dateStr;
            dateLbl.textAlignment = NSTextAlignmentRight;
            dateLbl.font = Font(12);
            
            UIButton * taskDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, contentHeight)];
            taskDetailBtn.backgroundColor = [UIColor clearColor];
            [taskDetailBtn addTarget:self action:@selector(jumpToTaskDetail:) forControlEvents:UIControlEventTouchUpInside];
            taskDetailBtn.tag = indexPath.row;
            [cell.contentView addSubview:taskDetailBtn];
            
            [cell.contentView addSubview:titleLbl];
            [cell.contentView addSubview:wgLbl];
            [cell.contentView addSubview:dateLbl];

        }
        else if ([sm.source intValue] == 9)//审核
        {
            if([sm.status intValue] == -2)//审核不过
            {
                contentHeight = 85;
                
                titleLbl.text = [NSString stringWithFormat:@"\"%@\"申请加入%@。", sm.userName, sm.orgName];
                
                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(X(nameLbl), titleLbl.bottom + 10, 8, 9)];
                icon.image = [UIImage imageNamed:@"icon_jujue"];
                
                UILabel * wgLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(nameLbl) + 16, titleLbl.bottom + 6, SCREENWIDTH - X(titleLbl) - 120 , 16)];
                wgLbl.backgroundColor = [UIColor clearColor];
                wgLbl.textColor = [UIColor grayTitleColor];
                wgLbl.text = @"已拒绝";
                wgLbl.textAlignment = NSTextAlignmentLeft;
                wgLbl.font = Font(12);
                
                //日期
                UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 100 - 14, titleLbl.bottom + 6, 100, 16)];
                dateLbl.backgroundColor = [UIColor clearColor];
                dateLbl.textColor = [UIColor grayTitleColor];
                NSString * dateStr = [UICommon dayAndHourFromString:sm.createTime formatStyle:@"MM月dd日 HH:mm"];
                dateLbl.text = dateStr;
                dateLbl.textAlignment = NSTextAlignmentRight;
                dateLbl.font = Font(12);
                
                [cell.contentView addSubview:wgLbl];
                [cell.contentView addSubview:icon];
                [cell.contentView addSubview:dateLbl];
            }
            else if ([sm.status intValue] == 0)//待审核
            {
                contentHeight = 155;
                
                titleLbl.text = [NSString stringWithFormat:@"\"%@\"申请加入%@。", sm.userName, sm.orgName];
                
                UIButton * agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(X(titleLbl), titleLbl.bottom + 26, (SCREENWIDTH - X(titleLbl) - 14 - 28) / 2, 41)];
                [agreeBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
                [agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                agreeBtn.backgroundColor = [UIColor grayMarkColor];
                [agreeBtn addTarget:self action:@selector(agreeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                agreeBtn.tag = indexPath.row;
                
                UIButton * rejectBtn = [[UIButton alloc] initWithFrame:CGRectMake(XW(agreeBtn) + 28, titleLbl.bottom + 26, (SCREENWIDTH - X(titleLbl) - 14 - 28) / 2, 41)];
                [rejectBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                [rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
                [rejectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                rejectBtn.backgroundColor = [UIColor grayMarkColor];
                [rejectBtn addTarget:self action:@selector(rejectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                rejectBtn.tag = indexPath.row;
                
                [cell.contentView addSubview:agreeBtn];
                [cell.contentView addSubview:rejectBtn];
            }
            else if ([sm.status intValue] == 1)//审核通过
            {
                contentHeight = 85;

                titleLbl.text = [NSString stringWithFormat:@"\"%@\"申请加入%@。", sm.userName, sm.orgName];
                
                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(X(nameLbl), titleLbl.bottom + 10, 8, 9)];
                icon.image = [UIImage imageNamed:@"icon_tongguo"];
                
                
                UILabel * wgLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(nameLbl) + 16, titleLbl.bottom + 6, SCREENWIDTH - X(titleLbl) - 120 , 16)];
                wgLbl.backgroundColor = [UIColor clearColor];
                wgLbl.textColor = [UIColor grayTitleColor];
                wgLbl.text = @"已同意";
                wgLbl.textAlignment = NSTextAlignmentLeft;
                wgLbl.font = Font(12);
                
                //日期
                UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 100 - 14, titleLbl.bottom + 6, 100, 16)];
                dateLbl.backgroundColor = [UIColor clearColor];
                dateLbl.textColor = [UIColor grayTitleColor];
                NSString * dateStr = [UICommon dayAndHourFromString:sm.createTime formatStyle:@"MM月dd日 HH:mm"];
                dateLbl.text = dateStr;
                dateLbl.textAlignment = NSTextAlignmentRight;
                dateLbl.font = Font(12);
                
                [cell.contentView addSubview:wgLbl];
                [cell.contentView addSubview:icon];
                [cell.contentView addSubview:dateLbl];
            }
        }
        
        CGRect rect = cell.frame;
        rect.size.height = contentHeight;
        cell.frame = rect;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(14, H(cell) - 0.5, SCREENWIDTH - 14, 0.5)];
        line.backgroundColor = [UIColor grayLineColor];
        [cell.contentView addSubview:line];
        
        cell.contentView.backgroundColor = [UIColor backgroundColor];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        return cell;
    }
}

- (void) agreeBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    SystemMessage * sm = _megArr[btn.tag];
    
    [SVProgressHUD showInfoWithStatus:@"审核提交中..."];
    
    BOOL isOk = [SystemMessage examineUserApply:sm.sourceId status:@"1"];
    
    if(isOk)
    {
        [SVProgressHUD dismiss];
        [self resetHeaderView];
        [_tableView.footer resetNoMoreData];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"审核成员失败"];
    }
}

- (void) rejectBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    SystemMessage * sm = _megArr[btn.tag];
    
    [SVProgressHUD showInfoWithStatus:@"审核提交中..."];

    BOOL isOk = [SystemMessage examineUserApply:sm.sourceId status:@"-2"];
    
    if(isOk)
    {
        [SVProgressHUD dismiss];
        
        [self resetHeaderView];
        [_tableView.footer resetNoMoreData];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"审核成员失败"];
    }
}

- (void) jumpToTaskDetail:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    SystemMessage * sm = _megArr[btn.tag];

    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
    ((ICWorkingDetailViewController*)vc).taskId = sm.sourceId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_sysBtnSelected)
    {
        MessageCenter * mc = _megArr[indexPath.row];
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
        ((ICWorkingDetailViewController*)vc).taskId = mc.taskId;
        ((ICWorkingDetailViewController*)vc).messageId = mc.megId;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    return YES;
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
