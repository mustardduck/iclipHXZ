//
//  ICSearchViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/24.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICSearchViewController.h"
#import "UIColor+HexString.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "InputText.h"

@interface ICSearchViewController() <UITableViewDataSource,UITableViewDelegate,InputTextDelegate,UITextFieldDelegate>
{
    UITableView*        _tableView;
    
    //Search bar
    UILabel*        _lblSearch;
    UITextField*    _txtSearch;
}

@property (nonatomic,assign) BOOL chang;

@end

@implementation ICSearchViewController

- (void)viewDidLoad
{
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
    
    
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, [UIScreen mainScreen].bounds.size.height - 44 )];
    [_tableView setBackgroundColor:[UIColor blackColor]];
    [_tableView setSectionIndexColor:[UIColor blueColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    _tableView.tableHeaderView = ({
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
        [view setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
        
        UIView* searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
        [searchView setBackgroundColor: [UIColor blackColor]];
        
        UIImageView* sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 14, 14)];
        [sImageView setBackgroundColor:[UIColor clearColor]];
        [sImageView setImage:[UIImage imageNamed:@"icon_sousuo"]];
        [searchView addSubview:sImageView];
        
        InputText *inputText = [[InputText alloc] init];
        inputText.delegate = self;
        
        _txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(30, 5, tableWidth - 75, 30)];
        [_txtSearch setBackgroundColor:[UIColor orangeColor]];
        [_txtSearch setBorderStyle:UITextBorderStyleNone];
        [_txtSearch setFont:[UIFont systemFontOfSize:17]];
        [_txtSearch setTextColor:[UIColor whiteColor]];
        _txtSearch.returnKeyType = UIReturnKeySearch;
        [_txtSearch addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        _txtSearch.delegate = self;
        
        _txtSearch = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtSearch showBottomLine:NO];
        
        _lblSearch = [[UILabel alloc] init];
        _lblSearch.text = @"搜索";
        _lblSearch.font = [UIFont systemFontOfSize:16];
        _lblSearch.textColor = [UIColor grayColor];
        _lblSearch.frame = _txtSearch.frame;
        
        [searchView addSubview:_txtSearch];
        [searchView addSubview:_lblSearch];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [view addSubview:bottomLine];
        
        [view addSubview:searchView];
        
        view;
    });
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 2) {
            return 25;
        }
        return 66;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            return 25;
        }
        return 60;
    }
    else if(indexPath.section == 2){
        if (indexPath.row == 2) {
            return 25;
        }
        return  [UIScreen mainScreen].bounds.size.height * 0.321;
    }
    
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [UIView new];
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 80, 20)];
    name.font = [UIFont boldSystemFontOfSize:12];
    name.textAlignment = NSTextAlignmentLeft;
    name.textColor = [UIColor whiteColor];
    if(section == 0)
        name.text = @"群组";
    else if(section == 1)
        name.text = @"成员";
    else if(section == 2)
        name.text = @"发布";
    
    [view addSubview:name];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 29.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [view addSubview:bottomLine];
    
    [view setBackgroundColor:[UIColor colorWithHexString:@"#393b48"]];
    
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupListTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    NSInteger section = indexPath.section;
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (section == 0) {
        
        if (indexPath.row == 2) {
            [cell.contentView setBackgroundColor:[UIColor blackColor]];
            return cell;
        }
        
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 46, 46)];
        //[imgView setImage:[UIImage imageNamed:@"icon_touxiang"]];
        [imgView setImageWithURL:[NSURL URLWithString:@"icon"] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell.contentView addSubview:imgView];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(72, 22, 120, 20)];
        lbl.text = @"模具中心";
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:15];
        lbl.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:lbl];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 65.5, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
        
        cell.tag = indexPath.row;
    }
    else if (section == 1) {
        
        if (indexPath.row == 2) {
            [cell.contentView setBackgroundColor:[UIColor blackColor]];
            return cell;
        }
        
        UIImageView* photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 36, 36)];
        //photoImageView.image = [UIImage imageNamed:@"icon_chengyuan"];
        [photoImageView setImageWithURL:[NSURL URLWithString:@"icon"] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(12 + 36 + 6, 15, 150, 30)];
        name.textColor = [UIColor whiteColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.text = @"梅西";
        name.font = [UIFont systemFontOfSize:15];
        
        [cell.contentView addSubview:photoImageView];
        [cell.contentView addSubview:name];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
        
    }
    else if (section == 2) {
        
        if (indexPath.row == 2) {
            [cell.contentView setBackgroundColor:[UIColor blackColor]];
            return cell;
        }
        
        NSInteger index = indexPath.row;
        
        Mission* ms = [Mission new];
        ms.monthAndDay = @"3/20";
        ms.hour = @"12:21";
        ms.userImg = @"icon";
        ms.userName = @"梅西";
        ms.workGroupName = @"基因重组";
        ms.main = @"这仅仅只是个开始！";
        
        if (cell.contentView.subviews.count == 0) {
            
            CGFloat cellHeight = [UIScreen mainScreen].bounds.size.height * 0.321;
            if (index > 0) {
                cellHeight = cellHeight - 4;
            }
            
            
            CGFloat contentHeight = cellHeight;
            CGFloat contentWidth = [UIScreen mainScreen].bounds.size.height;
            
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
            
            CGRect dateFrame = CGRectMake(0, isFristIndex?64:60, 50, 12);
            UILabel* dateMon = [[UILabel alloc] initWithFrame:dateFrame];
            dateMon.font = [UIFont boldSystemFontOfSize:12];
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
            
            
            UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(55, isFristIndex?68:64, 5, 5)];
            corner.layer.cornerRadius = 2;
            corner.backgroundColor = [UIColor whiteColor];
            corner.layer.borderColor = [UIColor whiteColor].CGColor;
            corner.layer.borderWidth = 1.0f;
            corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
            corner.layer.masksToBounds = YES;
            corner.clipsToBounds = YES;
            [cell.contentView addSubview:corner];
            
            
            UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(dirLine.frame.origin.x + 20, isFristIndex?19:15, 36, 36)];
            //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
            [photo setImageWithURL:[NSURL URLWithString:ms.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [photo setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:photo];
            
            
            CGRect nameFrame =CGRectMake(photo.frame.origin.x + photo.frame.size.width + 6, photo.frame.origin.y + 12,
                                         contentWidth - (photo.frame.origin.x + photo.frame.size.width + 6 + 39) , 21);
            UILabel* name = [[UILabel alloc] initWithFrame: nameFrame];
            name.text  = [NSString stringWithFormat:@"%@ 发布到 %@", ms.userName, ms.workGroupName];
            name.textColor = [UIColor whiteColor];
            name.font = [UIFont boldSystemFontOfSize:12];
            [cell.contentView addSubview:name];
            
            CGRect contentFrame = CGRectMake(photo.frame.origin.x, photo.frame.origin.y + photo.frame.size.height + 8,
                                             contentWidth - (photo.frame.origin.x + 39),
                                             cellHeight - (photo.frame.origin.y + photo.frame.size.height + 8 + 14));
            UILabel* content = [[UILabel alloc] init];
            content.frame = contentFrame;
            [content setNumberOfLines:0];
            content.textColor = [UIColor grayColor];
            content.font = [UIFont boldSystemFontOfSize:12];
            content.text = ms.main;
            [content setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:content];
            
            
            if (ms.isAccessory) {
                UIImageView* attachment = [[UIImageView alloc] initWithFrame:CGRectMake(contentWidth - 39, contentHeight / 2 , 15, 13)];
                attachment.image = [UIImage imageNamed:@"icon_fujian"];
                [cell.contentView addSubview:attachment];
            }
            
            UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(photo.frame.origin.x - 10, contentHeight - 0.5, cWidth - photo.frame.origin.x, 0.5)];
            [bottomLine setBackgroundColor:[UIColor whiteColor]];
            [cell.contentView addSubview:bottomLine];
            
            //[cell.contentView addSubview:pView];
            
            //[cell.contentView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
        }

        
    }
    
    
    
    [cell setBackgroundColor:[UIColor colorWithHexString:@"#393b48"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblSearch];
    
    if (textField == _txtSearch)
    {
        [self diminishTextName:_lblSearch];
        
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtSearch)
    {
        [self restoreTextName:_lblSearch textField:_txtSearch];
        if (textField.text != nil && ![textField.text isEqualToString:@""]) {
            
            NSLog(@"Value:");
            
        }
    }
    
    return YES;
}
- (void)diminishTextName:(UILabel *)label
{
    [UIView animateWithDuration:0.5 animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, -16);
        label.font = [UIFont systemFontOfSize:9];
    }];
}
- (void)restoreTextName:(UILabel *)label textField:(UITextField *)textFieled
{
    [textFieled resignFirstResponder];
    [self textFieldTextChange:textFieled];
    if (self.chang) {
        [UIView animateWithDuration:0.5 animations:^{
            label.transform = CGAffineTransformIdentity;
            label.font = [UIFont systemFontOfSize:16];
        }];
    }
}
- (void)textFieldTextChange:(UITextField *)textField
{
    if (textField.text.length != 0) {
        self.chang = NO;
    } else {
        self.chang = YES;
    }
}
- (void)textFieldDidChange
{
    
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self restoreTextName:_lblSearch textField:_txtSearch];
}



@end
