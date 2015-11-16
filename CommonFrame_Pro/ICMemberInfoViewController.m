//
//  ICMemberInfoViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberInfoViewController.h"
#import "UIColor+HexString.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MessageUI/MessageUI.h>
#import "PreviewViewController.h"
#import "RRAttributedString.h"
#import "ICWorkingDetailViewController.h"

@interface ICMemberInfoViewController() <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    
    
    __weak IBOutlet UITableView*       _tableView;
    
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    NSInteger               _pageNo;
    NSInteger               _pageRowCount;
    
    NSMutableArray*         _dataArray;
    NSMutableArray*         _imageArray;

}

- (IBAction)btnBackButtonClicked:(id)sender;


@end

@implementation ICMemberInfoViewController

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
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
    [rightButton setImage:[UIImage imageNamed:@"btn_gengduo"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(btnMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
     _pageNo = 1;
    _pageRowCount = 10;

    
    [_tableView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _tableView.tableHeaderView = ({
    
        UIView* infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cWidth, 180)];
        [infoView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
        
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 77, 77)];
        [photo setBackgroundColor:[UIColor clearColor]];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:_memberObj.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [infoView addSubview:photo];
        
        _imageArray = [NSMutableArray array];
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:_memberObj.img forKey:@"PictureUrl"];
        [_imageArray addObject:dic];
        
        UIButton * imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(photo), H(photo))];
        imgBtn.backgroundColor = [UIColor clearColor];
        [imgBtn addTarget:self action:@selector(seeFullScreenImg:) forControlEvents:UIControlEventTouchUpInside];
        [infoView addSubview:imgBtn];
        
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(photo.frame.size.width+photo.frame.origin.x + 20, 20, 75, 15)];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setText:_memberObj.name];
        [name setFont:[UIFont boldSystemFontOfSize:18]];
        [name setTextColor:[UIColor whiteColor]];
        [infoView addSubview:name];
        
        UILabel* posi = [[UILabel alloc] initWithFrame:CGRectMake(name.frame.size.width+name.frame.origin.x + 14, 21, 160, 15)];
        [posi setBackgroundColor:[UIColor clearColor]];
        [posi setText:_memberObj.duty];
        [posi setFont:[UIFont systemFontOfSize:13]];
        [posi setTextColor:[UIColor whiteColor]];
        [infoView addSubview:posi];
        
        
        UILabel* dep = [[UILabel alloc] initWithFrame:CGRectMake(photo.frame.size.width+photo.frame.origin.x + 20, name.frame.size.height + name.frame.origin.y + 26, 140, 15)];
        [dep setBackgroundColor:[UIColor clearColor]];
        [dep setText:@"回形针事业研发部"];
        [dep setFont:[UIFont systemFontOfSize:16]];
        [dep setTextColor:[UIColor whiteColor]];
        [infoView addSubview:dep];
        
        
        if (_memberObj.userId == [LoginUser loginUserID]) {
            UIButton* btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 11 - 40, 23, 40, 15)];
            [btnEdit setBackgroundColor:[UIColor clearColor]];
            [btnEdit setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
            [btnEdit addTarget:self action:@selector(btnEditButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            NSMutableAttributedString* attriNormal = [[NSMutableAttributedString alloc]
                                                      initWithString:@"编辑"
                                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                                   NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3c9ed7"]}];
            NSMutableAttributedString* attriHig = [[NSMutableAttributedString alloc]
                                                   initWithString:@"编辑"
                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                                NSForegroundColorAttributeName:[UIColor grayColor]}];
            [btnEdit setAttributedTitle:attriNormal forState:UIControlStateNormal];
            [btnEdit setAttributedTitle:attriHig forState:UIControlStateHighlighted];
            [infoView addSubview:btnEdit];
        }
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, photo.frame.size.height + photo.frame.origin.y + 11 - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [infoView addSubview:bottomLine];
        
        UILabel* lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(13, bottomLine.frame.size.height + bottomLine.frame.origin.y + 10, 50, 20)];
        [lblPhone setBackgroundColor:[UIColor clearColor]];
        [lblPhone setText:@"手机:"];
        [lblPhone setFont:[UIFont boldSystemFontOfSize:15]];
        [lblPhone setTextColor:[UIColor whiteColor]];
        [infoView addSubview:lblPhone];
        
        UILabel* phone = [[UILabel alloc] initWithFrame:CGRectMake(lblPhone.frame.size.width + lblPhone.frame.origin.x + 1, bottomLine.frame.size.height + bottomLine.frame.origin.y + 10, 160, 20)];
        [phone setBackgroundColor:[UIColor clearColor]];
        [phone setText:_memberObj.mobile];
        [phone setFont:[UIFont systemFontOfSize:15]];
        [phone setTextColor:[UIColor whiteColor]];
        [infoView addSubview:phone];
        
        UIImageView* imgPhone = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
        [imgPhone setBackgroundColor:[UIColor clearColor]];
        [imgPhone setImage:[UIImage imageNamed:@"btn_dianhua"]];
        
        UIButton* btnPhone = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 42,bottomLine.frame.size.height + bottomLine.frame.origin.y + 6, 27, 27)];
        [btnPhone setImage:imgPhone.image forState:UIControlStateNormal];
        [btnPhone setBackgroundColor:[UIColor clearColor]];
        [btnPhone addTarget:self action:@selector(btnPhoneClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [infoView addSubview:btnPhone];
        
        UILabel* bottomLine1= [[UILabel alloc] initWithFrame:CGRectMake(0, bottomLine.frame.size.height + bottomLine.frame.origin.y + 41 - 1, cWidth, 0.5)];
        [bottomLine1 setBackgroundColor:[UIColor grayColor]];
        [infoView addSubview:bottomLine1];
        
        
        
        UILabel* lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(13, bottomLine1.frame.size.height + bottomLine1.frame.origin.y + 10, 50, 20)];
        [lblEmail setBackgroundColor:[UIColor clearColor]];
        [lblEmail setText:@"邮箱:"];
        [lblEmail setFont:[UIFont boldSystemFontOfSize:15]];
        [lblEmail setTextColor:[UIColor whiteColor]];
        [infoView addSubview:lblEmail];
        
        UILabel* email = [[UILabel alloc] initWithFrame:CGRectMake(lblPhone.frame.size.width + lblPhone.frame.origin.x + 1, bottomLine1.frame.size.height + bottomLine1.frame.origin.y + 10, 160, 20)];
        [email setBackgroundColor:[UIColor clearColor]];
        [email setText:_memberObj.email];
        [email setFont:[UIFont systemFontOfSize:15]];
        [email setTextColor:[UIColor whiteColor]];
        [infoView addSubview:email];
        
        UIImageView* imgEmail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
        [imgEmail setBackgroundColor:[UIColor clearColor]];
        [imgEmail setImage:[UIImage imageNamed:@"btn_youxiang"]];
        
        UIButton* btnEmail = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 42, bottomLine1.frame.size.height + bottomLine1.frame.origin.y + 6, 27, 27)];
        [btnEmail setImage:imgEmail.image forState:UIControlStateNormal];
        [btnEmail setBackgroundColor:[UIColor clearColor]];
        [btnEmail addTarget:self action:@selector(btnEmailClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [infoView addSubview:btnEmail];
        
        UILabel* bottomLine2= [[UILabel alloc] initWithFrame:CGRectMake(0, bottomLine1.frame.size.height + bottomLine1.frame.origin.y + 41 - 1, cWidth, 0.5)];
        [bottomLine2 setBackgroundColor:[UIColor grayColor]];
        [infoView addSubview:bottomLine2];

        infoView;
    });
    
    if(_dataListArr.count)
    {
        _dataArray = [NSMutableArray arrayWithArray:_dataListArr];
    }
    else
    {
        _dataArray = [NSMutableArray array];
    }
    
    [self addRefrish];

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)btnMenu
{
    
}

- (void)addRefrish
{
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        
        _pageNo = 1;
        
//        if(!_dataListArr.count)
        {
            _dataArray =  [Mission getMssionListbyWorkGroupID:_memberObj.workGroupId andUserId:_memberObj.userId currentPageIndex:_pageNo pageSize:_pageRowCount];
        }
        
        NSLog(@"Header:%@",_dataArray);
        
        [_tableView reloadData];
        
        [_tableView.header endRefreshing];
        
        if (_dataArray.count == 0) {
            [_tableView.footer beginRefreshing];
        }
        
    }];
    
    
    [_tableView.header beginRefreshing];
    
    [_tableView addLegendFooterWithRefreshingBlock:^{
        
        _pageNo++;
        
        NSArray* newArr = [Mission getMssionListbyWorkGroupID:_memberObj.workGroupId andUserId:_memberObj.userId currentPageIndex:_pageNo pageSize:_pageRowCount];
        
        if (newArr.count > 0) {
            [_dataArray addObjectsFromArray:newArr];
            
            NSLog(@"%@",_dataArray);
            
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

- (void)btnPhoneClicked:(id)sender
{
    //NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"18696602662"];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    if (_memberObj.mobile != nil) {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",_memberObj.mobile];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
}

- (void)btnEmailClicked:(id)sender
{
    [self displayEmail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -
#pragma mark Button Action

- (void)reloadTableData
{
    [_tableView.header endRefreshing];
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnEditButtonClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc;
    vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPersonalInfoViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma -
#pragma mark Table View Delegate Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 244;
    
    if (indexPath.row == 0) {
        cellHeight += 33;
    }
    
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
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
        dirLine.frame = CGRectMake(71, 19 + 15, 1, contentHeight - 19 - 15 + 1);
    }
    else
    {
        dirLine.frame = CGRectMake(71, 0, 1, contentHeight + 1);
    }
    [dirLine setBackgroundColor:RGBCOLOR(119, 119, 119)];
    [cell.selectedBackgroundView addSubview:dirLine];
    
    //
    //    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.156 * _screenWidth + 15, contentHeight - 1, _screenWidth - (0.156 * _screenWidth + 15) - 12, 0.5)];
    //    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    //    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MemberInfoTableViewCellIdentitifer2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSInteger index = indexPath.row;
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (cell.contentView.subviews.count == 0) {
        
        //        CGFloat cellHeight = _screenHeight * 0.321;
        Mission* ms = [_dataArray objectAtIndex:indexPath.row];
        //
        //        CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:Font(18)].height;
        //
        //        CGFloat cellHeight = contentH + 70 + 42 + 28;
        CGFloat cellHeight = 244;
        
        if (indexPath.row == 0) {
            cellHeight = cellHeight + 33;
        }
        
        CGFloat contentHeight = cellHeight;
        CGFloat contentWidth = _screenWidth;
        
        UIView* dirLine = [[UIView alloc] init];
        
        BOOL isFristIndex = NO;
        
        if (index == 0) {
            isFristIndex = YES;
            UIImageView* timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(62, 14, 18, 18)];
            [timeIcon setImage:[UIImage imageNamed:@"icon_shijian"]];
            [timeIcon setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:timeIcon];
            //[menuButton setImageWithURL:[NSURL URLWithString:[_imageList objectAtIndex:index]]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            dirLine.frame = CGRectMake(timeIcon.frame.origin.x + 9, timeIcon.frame.origin.y + 18, 1, contentHeight - timeIcon.frame.origin.y - timeIcon.frame.size.height);
        }
        else
        {
            dirLine.frame = CGRectMake(71, 0, 1, contentHeight);
        }
        
        [dirLine setBackgroundColor:[UIColor grayLineColor]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.contentView addSubview:dirLine];
        });
        
        CGRect dateFrame = CGRectMake(0, isFristIndex?45:10, 56, 24);
        UILabel* dateMon = [[UILabel alloc] initWithFrame:dateFrame];
        dateMon.font = BFont(10);
        dateMon.textAlignment = NSTextAlignmentRight;
        dateMon.textColor = [UIColor whiteColor];
        
        if(ms.monthAndDay.length > 2)
        {
            NSRange range = [ms.monthAndDay rangeOfString:@"/"]; //现获取要截取的字符串位置
            NSInteger month = [[ms.monthAndDay substringToIndex:range.location] integerValue];
            NSString * day = [ms.monthAndDay substringFromIndex:range.location + 1];
            NSString * dateStr = [NSString stringWithFormat:@"%@ %ld月", day, month];
            
            NSAttributedString *attrStr = [RRAttributedString setText:dateStr font:BFont(23) range:NSMakeRange(0, 2)];
            
            dateMon.attributedText = attrStr;
        }
        
        [cell.contentView addSubview:dateMon];
        
        UILabel* dateHour = [[UILabel alloc] initWithFrame:CGRectMake(0, YH(dateMon)+ 7, 56, 14)];
        dateHour.font = Font(12);
        dateHour.textAlignment = NSTextAlignmentRight;
        dateHour.textColor = [UIColor whiteColor];
        dateHour.text = ms.hour;
        [cell.contentView addSubview:dateHour];
        
        //读
        BOOL isRead = ms.isRead;
        
        UILabel* readLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, YH(dateHour) + 7, 56, 18)];
        readLbl.font = Font(16);
        readLbl.textAlignment = NSTextAlignmentRight;
        
        if(!isRead)
        {
            readLbl.text = @"未读";
            readLbl.textColor = RGBCOLOR(53, 159, 219);
            [cell.contentView addSubview:readLbl];
            
            
            UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, YH(dateHour) + 13 , 5, 5)];
            iconView.image = [UIImage imageNamed:@"icon_du"];
            [cell.contentView addSubview:iconView];
        }
        else
        {
            readLbl.text = @"已读";
            readLbl.textColor = RGBCOLOR(122, 122, 122);
            [cell.contentView addSubview:readLbl];
        }
        
        //新评论
        
        BOOL isNewCom = ms.isNewCom;
        //        BOOL isNewCom = YES;
        
        UILabel* comLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, YH(readLbl) + 7, 56, 18)];
        comLbl.font = Font(16);
        comLbl.textAlignment = NSTextAlignmentRight;
        
        if(isNewCom)
        {
            comLbl.text = @"新评论";
            comLbl.font = Font(10);
            comLbl.textColor = RGBCOLOR(76, 216, 100);
            [cell.contentView addSubview:comLbl];
            
            UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(14,YH(readLbl) + 13, 5, 5)];
            corner.layer.cornerRadius = 2;
            corner.backgroundColor = RGBCOLOR(76, 216, 100);
            corner.layer.borderColor = RGBCOLOR(76, 216, 100).CGColor;
            corner.layer.borderWidth = 1.0f;
            corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
            corner.layer.masksToBounds = YES;
            corner.clipsToBounds = YES;
            [cell.contentView addSubview:corner];
        }
        
        //灰点
        UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(69, isFristIndex?72:40, 5, 5)];
        corner.layer.cornerRadius = 2;
        corner.backgroundColor = RGBCOLOR(119, 119, 119);
        corner.layer.borderColor = RGBCOLOR(119, 119, 119).CGColor;
        corner.layer.borderWidth = 1.0f;
        corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
        corner.layer.masksToBounds = YES;
        corner.clipsToBounds = YES;
        [cell.contentView addSubview:corner];
        
        CGFloat bianKuangWidth = SCREENWIDTH - 14 - 82;
        
        UIImageView * backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(XW(corner) + 8, isFristIndex?34:0, bianKuangWidth, 217)];
        backImgView.image = [UIImage imageNamed:@"bg_duihuakuang"];
        [cell.contentView addSubview:backImgView];
        
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(X(dirLine) + 20 + 14, isFristIndex?47:14, 50, 50)];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:ms.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [photo setBackgroundColor:[UIColor clearColor]];
        photo.layer.cornerRadius = 5.0f;
        photo.clipsToBounds = YES;
        
        [cell.contentView addSubview:photo];
        
//        UIButton * photoBtn = [[UIButton alloc] initWithFrame:photo.frame];
//        [photoBtn addTarget:self action:@selector(jumpToPersonalInfo:) forControlEvents:UIControlEventTouchUpInside];
//        photoBtn.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:photoBtn];
        
        UILabel * createNameLbl = [[UILabel alloc] init];
        createNameLbl.frame = CGRectMake(XW(photo) + 14, Y(photo), 100, 20);
        createNameLbl.backgroundColor = [UIColor clearColor];
        createNameLbl.textColor = [UIColor blueTextColor];
        createNameLbl.text = ms.userName;
        createNameLbl.font = Font(17);
        [cell.contentView addSubview:createNameLbl];
        
        CGRect nameFrame =CGRectMake(XW(photo)+ 14, YH(createNameLbl) + 17 , SCREENWIDTH - 196, 14);
        UILabel* name = [[UILabel alloc] initWithFrame: nameFrame];
        name.textColor = [UIColor grayTitleColor];
        name.font = Font(12);
        
        NSString * tagStr = @"";
        
        for (NSDictionary * dic in ms.labelList)
        {
            NSString * lblName = [dic valueForKey:@"labelName"];
            if(ms.labelList.count == 1)
            {
                tagStr = lblName;
            }
            else
            {
                tagStr = [tagStr stringByAppendingString:[NSString stringWithFormat:@"%@ · ", lblName]];
            }
        }
        
        if(tagStr.length >= 3)
        {
            NSString * pointTagStr = [tagStr substringFromIndex:tagStr.length - 3];
            if([pointTagStr isEqualToString:@" · "])
            {
                tagStr = [tagStr substringToIndex:tagStr.length - 3];
            }
        }
        //momo todo
        //        NSString * nameStr = [NSString stringWithFormat:@"%@   %@   %@",ms.userName, ms.workGroupName, tagStr];
        
        //        NSAttributedString *nameAttrStr = [RRAttributedString setText:nameStr font:Font(16) color:RGBCOLOR(53, 159, 219) range:NSMakeRange(0, ms.userName.length)];
        //
        //        name.attributedText = nameAttrStr;
        
        NSString * nameStr = [NSString stringWithFormat:@"%@          负责人：%@",ms.workGroupName, ms.lableUserName];
        
        if(ms.type != 1)
        {
            nameStr = ms.workGroupName;
        }
        
        name.text = nameStr;
        
        
        [cell.contentView addSubview:name];
        
        CGFloat width = [UICommon getSizeFromString:ms.userName withSize:CGSizeMake(100, name.frame.size.height) withFont:Font(16)].width;
        
        CGRect btnRect = name.frame;
        btnRect.origin.y = 0;
        btnRect.size.width = width;
        btnRect.size.height = YH(name);
        
//        photoBtn = [[UIButton alloc] initWithFrame:btnRect];
//        [photoBtn addTarget:self action:@selector(jumpToPersonalInfo:) forControlEvents:UIControlEventTouchUpInside];
//        photoBtn.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:photoBtn];
        
        
        //跳转到群组详细页
        //        photoBtn = [[UIButton alloc] initWithFrame:tag.frame];
        //        [photoBtn addTarget:self action:@selector(jumpToPersonalInfo:) forControlEvents:UIControlEventTouchUpInside];
        //        photoBtn.backgroundColor = [UIColor clearColor];
        //        [cell.contentView addSubview:photoBtn];
        NSString * type = @"";
        
        switch (ms.type) {
            case 1:
                type = @"任务";
                break;
            case 2:
                type = @"异常";
                break;
            case 3:
                type = @"申请";
                break;
            case 8:
                type = @"议题";
                break;
            default:
                break;
        }
        
        CGRect titleFrame = CGRectMake(X(photo), YH(photo) + 14,
                                       SCREENWIDTH - 14 -107,
                                       18);
        UILabel * titleLbl = [[UILabel alloc] init];
        titleLbl.frame = titleFrame;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = RGBCOLOR(251, 251, 251);
        titleLbl.font = Font(16);
        NSString * title = @"";
        if(ms.title.length)
        {
            title = ms.title;
        }
        else
        {
            title = @"无标题";
        }
        
        titleLbl.text = [NSString stringWithFormat:@"%@   %@",type, title];
        
        [cell.contentView addSubview:titleLbl];
        
        CGSize maxSize = CGSizeMake(contentWidth - (X(photo) + 39),
                                    20 * 4 + 8);
        CGRect contentFrame = CGRectMake(X(photo), YH(titleLbl) + 14,
                                         maxSize.width,
                                         maxSize.height);
        
        UILabel* content = [[UILabel alloc] init];
        content.textColor = [UIColor grayTitleColor];
        content.font = Font(14);
        
        CGSize cSize = [UICommon getSizeFromString:ms.main withSize:maxSize withFont:Font(14)];
        content.frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width, cSize.height);
        content.numberOfLines = 4;
        content.text = ms.main;
        
        [content setBackgroundColor:[UIColor clearColor]];
        
        if(ms.childTaskList.count > 0)
        {
            NSInteger chCount = ms.childTaskList.count;
            if(chCount > 3)
            {
                chCount = 3;
            }
            
            for (int i = 0; i < chCount; i ++)
            {
                NSDictionary * dic = ms.childTaskList[i];
                
                UILabel * childLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(photo), YH(titleLbl) + 14 + i * 20, titleFrame.size.width - 27 - 64, 16)];
                childLbl.backgroundColor = [UIColor clearColor];
                childLbl.font = Font(14);
                childLbl.textColor = [UIColor grayTitleColor];
                
                childLbl.text = [NSString stringWithFormat:@"%d. %@", i + 1, [dic valueForKey:@"title"]];
                
                [cell.contentView addSubview:childLbl];
                
                childLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(childLbl) + 27, YH(titleLbl) + 14 + i * 20, titleFrame.size.width - 27 - W(childLbl), 16)];
                childLbl.backgroundColor = [UIColor clearColor];
                childLbl.font = Font(14);
                childLbl.textColor = [UIColor grayTitleColor];
                
                childLbl.text = [dic valueForKey:@"lableUserName"];
                
                [cell.contentView addSubview:childLbl];
                
            }
        }
        else
        {
            [cell.contentView addSubview:content];
            
        }
        
        
        //        if (ms.isAccessory) {
        
        UILabel* plLbl = [[UILabel alloc] init];
        plLbl.textColor = RGBCOLOR(172, 172, 173);
        plLbl.font = Font(10);
        [plLbl setBackgroundColor:[UIColor clearColor]];
        plLbl.text = [NSString stringWithFormat:@"评论 (%d)", ms.replayNum];
        
        CGFloat plWidth = [UICommon getWidthFromLabel:plLbl].width;
        plLbl.frame = CGRectMake(SCREENWIDTH - 25 - plWidth, isFristIndex?192 + 34:192,plWidth, 12);
        
        [cell.contentView addSubview:plLbl];
        
        UIImageView* plIcon = [[UIImageView alloc] initWithFrame:CGRectMake(X(plLbl) - 4 - 12, Y(plLbl) + 2 , 12, 10)];
        plIcon.image = [UIImage imageNamed:@"btn_pinglun"];
        [cell.contentView addSubview:plIcon];
        
        
        UILabel* fujianLbl = [[UILabel alloc] init];
        fujianLbl.textColor = RGBCOLOR(172, 172, 173);
        fujianLbl.font = Font(10);
        [fujianLbl setBackgroundColor:[UIColor clearColor]];
        fujianLbl.text = [NSString stringWithFormat:@"附件 (%d)", ms.accessoryNum];
        
        int space = 17;
        
        CGFloat fujianWidth = [UICommon getWidthFromLabel:fujianLbl].width;
        fujianLbl.frame = CGRectMake(X(plIcon) - space - fujianWidth, Y(plLbl), fujianWidth, 12);
        [cell.contentView addSubview:fujianLbl];
        
        UIImageView* attachment = [[UIImageView alloc] initWithFrame:CGRectMake(X(fujianLbl) - 4 - 12, Y(plLbl) + 2, 12, 10)];
        attachment.image = [UIImage imageNamed:@"btn_fujianIcon"];
        [cell.contentView addSubview:attachment];
        
        
        if(ms.type == 1)
        {
            //子任务
            if([ms.parentId isEqualToString:@"0"])
            {
                fujianLbl = [[UILabel alloc] init];
                fujianLbl.textColor = RGBCOLOR(172, 172, 173);
                fujianLbl.font = Font(10);
                [fujianLbl setBackgroundColor:[UIColor clearColor]];
                fujianLbl.text = [NSString stringWithFormat:@"子任务 (%d)", ms.childNum];
                
                fujianWidth = [UICommon getWidthFromLabel:fujianLbl].width;
                
                fujianLbl.frame = CGRectMake(X(attachment) - space - fujianWidth, Y(plLbl), fujianWidth, 12);
                [cell.contentView addSubview:fujianLbl];
                
                attachment = [[UIImageView alloc] initWithFrame:CGRectMake(X(fujianLbl) - 4 - 12, Y(plLbl), 13, 15)];
                attachment.image = [UIImage imageNamed:@"icon_zirenwu"];
                [cell.contentView addSubview:attachment];
            }
        }
        
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        
        CGRect rect = cell.frame;
        rect.size.height = contentHeight - 10;
        
    }
    
    //[cell.imageView setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/mingxing0605.jpg"] placeholderImage:[UIImage imageNamed:@"menuUsers"] options:SDWebImageContinueInBackground usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //cell.textLabel.text = @"aaáâ";
    
    [cell setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    return cell;
}

- (void) seeFullScreenImg:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"PreviewViewController"];
    if(_imageArray.count)
    {
        ((PreviewViewController*)vc).dataArray = _imageArray;
    }
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Mission* ms = [_dataArray objectAtIndex:indexPath.row];
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
    ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
    ((ICWorkingDetailViewController*)vc).indexInMainArray = indexPath.row;
    ((ICWorkingDetailViewController*)vc).icMainViewController = self;
    ((ICWorkingDetailViewController*)vc).workGroupId = @"0";
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)displayEmail
{
    if (_memberObj.email == nil) {
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:_memberObj.name];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:_memberObj.email];
    
    
    [picker setToRecipients:toRecipients];
    
    // Attach an image to the email
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@"png"];
    //NSData *myData = [NSData dataWithContentsOfFile:path];
    //[picker addAttachmentData:myData mimeType:@"image/png" fileName:@""];
    
    // Fill out the email body text
    
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
