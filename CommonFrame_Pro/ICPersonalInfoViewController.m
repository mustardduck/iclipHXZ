//
//  ICPersonalInfoViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/2.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICPersonalInfoViewController.h"
#import <SlideNavigationController.h>
#import "LoginUser.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <ZYQAssetPickerController.h>
#import "VPImageCropperViewController.h"
#import "SVProgressHUD.h"


@interface ICPersonalInfoViewController ()<UITableViewDelegate,UITableViewDataSource,ZYQAssetPickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, VPImageCropperDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView*   _tableView;
    LoginUser*              _user;
     BOOL                _editButtonClicked;
    UITextField*  _txtPhoneName;
    UITextField*  _txtEmailName;
    UITextField*  _txtName;
    
    UIButton*       _imgButton;
    
     NSMutableArray*         _accessoryArray;
    BOOL            _hasChanged;
    
    NSString *          _currentFileName;
    
    UITextField * _currentField;
}

@end

@implementation ICPersonalInfoViewController

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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    UIBarButtonItem* rarButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonClicked:)];
    [rarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rarButton;
    
    _editButtonClicked = NO;
    _hasChanged = NO;
    
    [_tableView setSeparatorColor:[UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:(id)self];
    
    [self setExtraCellLineHidden:_tableView];
    
    _user = [LoginUser getLoginInfo];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (self.cAccessoryArray != nil){
//        NSLog(@"%@",self.cAccessoryArray);
//        if (_cAccessoryArray.count > 0) {
//            int i = 0;
//            for (ALAsset* ass in _accessoryArray)
//            {
//                ALAssetRepresentation* representation = [ass defaultRepresentation];
//                UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
//                imgH = [UIImage
//                        imageWithCGImage:[representation fullScreenImage]
//                        scale:[representation scale]
//                        orientation:UIImageOrientationUp];
//                UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//                [img setBackgroundColor:[UIColor clearColor]];
//                [img setImage:imgH];
//                
//                [_imgButton setImage:img.image forState:UIControlStateNormal];
//                
//                i++;
//            }
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnPhotoClicked:(id)sender
{
//    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的文件夹", @"拍照", @"从相册选取",@" ", nil];
//    [as showInView:self.view];
    
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取",nil];
    [as showInView:self.view];
    
    
}

- (void)editButtonClicked:(UIBarButtonItem*)barButton
{
    if (!_editButtonClicked) {
        
        [barButton setTitle:@"完成"];
        _editButtonClicked = YES;
    }
    else{
        if(_txtName.text == nil && [_txtName.text isEqualToString:@""])
        {
            [SVProgressHUD showErrorWithStatus:@"名字不能为空"];
            
            [_txtName becomeFirstResponder];
            
            return;
        }
        if(![UICommon firstStringIsChineseOrLetter:_txtName.text])
        {
            [SVProgressHUD showErrorWithStatus:@"姓名的第一位必须为中文或字母"];
            
            [_txtName becomeFirstResponder];
            
            return;
        }
        if(_txtPhoneName.text == nil && [_txtPhoneName.text isEqualToString:@""])
        {
            [SVProgressHUD showErrorWithStatus:@"手机号不能为空"];

            [_txtPhoneName becomeFirstResponder];
            
            return;
        }
        if(_txtPhoneName.text != nil && ![_txtPhoneName.text isEqualToString:@""] && _txtPhoneName.text.length != 11)
        {
            [SVProgressHUD showErrorWithStatus:@"请输入11位手机号码"];
            
            [_txtPhoneName becomeFirstResponder];
            
            return;
        }

        
        _editButtonClicked = NO;
        [barButton setTitle:@"编辑"];
  
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* na = _txtName.text;
            BOOL isOk = [LoginUser updateInfo:na phone:_txtPhoneName.text email:_txtEmailName.text photo:(_cAccessoryArray.count > 0? ((Accessory*)[_cAccessoryArray objectAtIndex:0]).address:_user.img)];
            if (isOk) {
                
                [_currentField resignFirstResponder];
                
                [SVProgressHUD showSuccessWithStatus:@"更新资料成功"];

                _user = [LoginUser getLoginInfo];
                [_tableView reloadData];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"更新资料失败"];
            }
            
        });
    }
   [_tableView reloadData];
}

#pragma mark -
#pragma mark TableViewDelaget

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PersonalCellIdentifier";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger index = indexPath.row;
    
    if (index == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 144.0f)];
        
        UILabel* topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [topLine setBackgroundColor:[UIColor grayColor]];
        [view addSubview:topLine];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30, 85, 85)];
        //imageView.image = [UIImage imageNamed:@"avatar@2x.jpg"];
        [imageView setImageWithURL:[NSURL URLWithString:_user.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        if (_editButtonClicked) {
            _imgButton = [[UIButton alloc] initWithFrame:imageView.frame];
            [_imgButton setImage:[imageView image] forState:UIControlStateNormal];
            [_imgButton addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:_imgButton];
        }
        else
            [view addSubview:imageView];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, 60, SCREENWIDTH - 130 - 14, 24)];
        label.text = _user.name;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        //[label sizeToFit];
        
        if (_editButtonClicked) {
            _txtName = [[UITextField alloc] initWithFrame:label.frame];
            [_txtName setBackgroundColor:[UIColor grayColor]];
            [_txtName setBorderStyle:UITextBorderStyleNone];
            [_txtName setFont:[UIFont systemFontOfSize:17]];
            [_txtName setTextColor:[UIColor whiteColor]];
            _txtName.text = _user.name;
            _txtName.delegate = self;
            
            [view addSubview:_txtName];
        }
        else
            [view addSubview:label];
        
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 133.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [view addSubview:bottomLine];
        
        [cell.contentView addSubview:view];
    }
    else if (index == 2) {
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, [UIScreen mainScreen].bounds.size.width - 40, 20)];
        lbl.textColor = [UIColor grayColor];
        lbl.font = [UIFont systemFontOfSize:17];
        lbl.backgroundColor = [UIColor clearColor];
        
        UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine1 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine1];
        
        if (_editButtonClicked) {
            
            _txtPhoneName = [[UITextField alloc] initWithFrame:lbl.frame];
            [_txtPhoneName setBackgroundColor:[UIColor grayColor]];
            [_txtPhoneName setBorderStyle:UITextBorderStyleNone];
            [_txtPhoneName setFont:[UIFont systemFontOfSize:17]];
            [_txtPhoneName setTextColor:[UIColor whiteColor]];
            _txtPhoneName.delegate = self;
            _txtPhoneName.text = _user.mobile;
            
            [cell.contentView addSubview:_txtPhoneName];
        }
        else
        {
            lbl.text = [NSString stringWithFormat:@"手机: %@",_user.mobile];
            [cell.contentView addSubview:lbl];
        }
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
        
    }
    else if (index == 3)
    {
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, [UIScreen mainScreen].bounds.size.width - 40, 20)];
        lbl.textColor = [UIColor grayColor];
        lbl.font = [UIFont systemFontOfSize:17];
        lbl.backgroundColor = [UIColor clearColor];
        
        if (_editButtonClicked) {
            _txtEmailName = [[UITextField alloc] initWithFrame:lbl.frame];
            [_txtEmailName setBackgroundColor:[UIColor grayColor]];
            [_txtEmailName setBorderStyle:UITextBorderStyleNone];
            [_txtEmailName setFont:[UIFont systemFontOfSize:17]];
            [_txtEmailName setTextColor:[UIColor whiteColor]];
            _txtEmailName.text = _user.email;
            _txtEmailName.delegate = self;

            [cell.contentView addSubview:_txtEmailName];
            
        }
        else
        {
            lbl.text = [NSString stringWithFormat:@"邮箱: %@",_user.email];
            [cell.contentView addSubview:lbl];
        }
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
    }
    
    
    //cell.imageView.image = [_buttonList objectAtIndex:index];
    //cell.textLabel.text = [NSString stringWithFormat:@"data cell %ld",(long)indexPath.row];
    
    return cell;
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
  
    
    return myView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 134;
    }
    else if (indexPath.row == 1) {
        return 20;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStroryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc;
    
    switch (indexPath.row) {
        case 3:
            vc = [mainStroryboard instantiateViewControllerWithIdentifier:@"ICMainViewController"];
            break;
        case 2:
            vc = [mainStroryboard instantiateViewControllerWithIdentifier:@"ICAccountViewController"];
            break;
        default:
            vc = [mainStroryboard instantiateViewControllerWithIdentifier:@"ICMainViewController"];
            break;
    }
    
    //[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:YES andCompletion:nil];
    
    /*
     case 7:
     [_tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
     [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
     break;
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        NSString * dateTime = [[info[@"UIImagePickerControllerMediaMetadata"] objectForKey:@"{TIFF}"] objectForKey:@"DateTime"];
        
        _currentFileName = [NSString stringWithFormat:@"%@.png", dateTime];
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark -
#pragma UIActionSheet Deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex == 0) {
//        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICFileViewController"];
//        
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    if (buttonIndex == 0)
    {
        UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
        ctrl.delegate = self;
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
        picker.maximumNumberOfSelection = 1;
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.showEmptyGroups=NO;
        picker.delegate=self;
        picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                return duration >= 5;
            } else {
                return YES;
            }
        }];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    NSString * userImgPath = @"";
    
    BOOL isOk = [LoginUser uploadImageWithScale:editedImage fileName:_currentFileName userImgPath:&userImgPath];
    
    if(isOk)
    {
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [img setBackgroundColor:[UIColor clearColor]];
        [img setImage:editedImage];
        
        [_imgButton setImage:img.image forState:UIControlStateNormal];
        
        _user.img = userImgPath;
    }
    
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"%@",assets);
    
    if (assets.count > 0) {
        
        [picker dismissViewControllerAnimated:YES completion:^() {
//            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            ALAsset * ass = assets[0];
            
            ALAssetRepresentation* representation = [ass defaultRepresentation];
            UIImage* portraitImg = [UIImage imageWithCGImage:[representation fullResolutionImage]];
            portraitImg = [UIImage
                    imageWithCGImage:[representation fullScreenImage]
                    scale:[representation scale]
                    orientation:UIImageOrientationUp];

            _currentFileName = [representation filename];
            
            portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
            // present the cropper view controller
            VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
            imgCropperVC.delegate = self;
            [self presentViewController:imgCropperVC animated:YES completion:^{
                // TO DO
            }];
        }];

        
        //ALAssetRepresentation* representation = [asset defaultRepresentation];
        /*
         CGSize dimension = [representation dimensions];
         UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
         NSString* filename = [representation filename];
         NSLog(@"filename:%@",filename);
         CGFloat size = [representation size];
         NSDictionary* dic = [representation metadata];
         NSURL* url = [representation url];
         NSLog(@"url:%@",url);
         NSLog(@"uti:%@",[representation UTI]);
         */
        
        //momo
        /*
        if (_accessoryArray == nil) {
            _accessoryArray = [NSMutableArray array];
        }
        
        for (ALAsset* asset in assets)
        {
            BOOL isExits = NO;
            for (ALAsset* acc in _accessoryArray) {
                ALAssetRepresentation* representation = [asset defaultRepresentation];
                ALAssetRepresentation* accRepresentation = [acc defaultRepresentation];
                if ([representation.filename isEqualToString:accRepresentation.filename]) {
                    isExits = YES;
                    break;
                }
            }
            if (!isExits) {
                [_accessoryArray addObject:asset];
            }
        }
        
        if (_accessoryArray.count > 0) {
            
//            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICFileViewController"];
//            ((ICFileViewController*)vc).uploadFileArray = _accessoryArray;
//            ((ICFileViewController*)vc).hasUploadedFileArray = (_cAccessoryArray == nil? [NSMutableArray array] :[NSMutableArray arrayWithArray:_cAccessoryArray]);
//            ((ICFileViewController*)vc).icPublishMissionController = self;
//            
//            [self.navigationController pushViewController:vc animated:YES];
            
            NSString * userImgPath = @"";
            
            BOOL isOk = [LoginUser uploadImage:_accessoryArray withUserImgPath:&userImgPath];
            
            if(isOk)
            {
                ALAsset * ass = _accessoryArray[0];
                
                ALAssetRepresentation* representation = [ass defaultRepresentation];
                UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                imgH = [UIImage
                        imageWithCGImage:[representation fullScreenImage]
                        scale:[representation scale]
                        orientation:UIImageOrientationUp];
                UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
                [img setBackgroundColor:[UIColor clearColor]];
                [img setImage:imgH];
                
                [_imgButton setImage:img.image forState:UIControlStateNormal];
                
                _user.img = userImgPath;
            }
        }
          */
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    _currentField = textField;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
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
