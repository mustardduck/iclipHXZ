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
        
        if(!_dataListArr.count)
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
    Mission* ms = [_dataArray objectAtIndex:indexPath.row];
    
    CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:Font(18)].height;
    
    CGFloat cellHeight = contentH + 70 + 42;
    
    if (indexPath.row == 0) {
        cellHeight = cellHeight + 37;
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
        
        CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:Font(18)].height;
        
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
            //[menuButton setImageWithURL:[NSURL URLWithString:[_imageList objectAtIndex:index]]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
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
        dateMon.text = ms.monthAndDay;
        [cell.contentView addSubview:dateMon];
        
        UILabel* dateHour = [[UILabel alloc] initWithFrame:CGRectMake(0, dateMon.frame.origin.y + 12 + 4, 50, 8)];
        dateHour.font = [UIFont systemFontOfSize:8];
        dateHour.textAlignment = NSTextAlignmentRight;
        dateHour.textColor = [UIColor whiteColor];
        dateHour.text = ms.hour;
        [cell.contentView addSubview:dateHour];
        
        UILabel* readLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, dateHour.frame.origin.y + 13, 50, 8)];
        readLbl.font = [UIFont systemFontOfSize:12];
        readLbl.textAlignment = NSTextAlignmentRight;
        readLbl.textColor = [UIColor whiteColor];
        
        
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
        [photo setImageWithURL:[NSURL URLWithString:ms.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [photo setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:photo];
        
        CGRect nameFrame =CGRectMake(photo.frame.origin.x + photo.frame.size.width + 6, photo.frame.origin.y + 10,
                                     contentWidth - (photo.frame.origin.x + photo.frame.size.width + 6 + 39) , 21);
        UILabel* name = [[UILabel alloc] initWithFrame: nameFrame];
        name.text  = [NSString stringWithFormat:@"%@ 发送到 %@", ms.userName, ms.workGroupName];
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
        content.text = ms.main;
        [content setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:content];
        
        
        //        if (ms.isAccessory) {
        
        UIImageView* attachment = [[UIImageView alloc] initWithFrame:CGRectMake(X(content), YH(content) + 20 , 12, 10)];
        attachment.image = [UIImage imageNamed:@"btn_fujianIcon"];
        [cell.contentView addSubview:attachment];
        
        UILabel* fujianLbl = [[UILabel alloc] init];
        fujianLbl.textColor = [UIColor grayColor];
        fujianLbl.font = [UIFont boldSystemFontOfSize:10];
        [fujianLbl setBackgroundColor:[UIColor clearColor]];
        fujianLbl.text = [NSString stringWithFormat:@"附件 (%d)", ms.accessoryNum];
        
        fujianLbl.frame = CGRectMake(XW(attachment) + 5, Y(attachment) - 2, [UICommon getWidthFromLabel:fujianLbl].width, 14);
        [cell.contentView addSubview:fujianLbl];
        
        UIImageView* plIcon = [[UIImageView alloc] initWithFrame:CGRectMake(XW(fujianLbl) + 21, YH(content) + 20 , 12, 10)];
        plIcon.image = [UIImage imageNamed:@"btn_pinglun"];
        [cell.contentView addSubview:plIcon];
        
        UILabel* plLbl = [[UILabel alloc] init];
        plLbl.textColor = [UIColor grayColor];
        plLbl.font = [UIFont boldSystemFontOfSize:10];
        [plLbl setBackgroundColor:[UIColor clearColor]];
        plLbl.text = [NSString stringWithFormat:@"评论 (%d)", ms.replayNum];
        
        plLbl.frame = CGRectMake(XW(plIcon) + 5, Y(attachment) - 2, [UICommon getWidthFromLabel:plLbl].width, 14);
        [cell.contentView addSubview:plLbl];
        
        //[cell.contentView addSubview:pView];
        
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
        
        CGRect rect = cell.frame;
        rect.size.height = contentHeight - 10;
        
    }
    
    //[cell.imageView setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/mingxing0605.jpg"] placeholderImage:[UIImage imageNamed:@"menuUsers"] options:SDWebImageContinueInBackground usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //cell.textLabel.text = @"aaáâ";
    
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
