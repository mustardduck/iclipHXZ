//
//  ICCreateNewGroupViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/25.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICCreateNewGroupViewController.h"
#import "InputText.h"
#import <ZYQAssetPickerController.h>
#import "UIButton+UIActivityIndicatorForSDWebImage.h"
#import "ICMainViewController.h"
#import "VPImageCropperViewController.h"

@interface ICCreateNewGroupViewController()<InputTextDelegate,UITextFieldDelegate,ZYQAssetPickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, VPImageCropperDelegate>
{
    IBOutlet UIView* _contentView;
    
    UILabel*        _lblGroupName;
    UITextField*    _txtGroupName;
    
    UILabel*        _lblSignature;
    UITextField*    _txtSignature;
    
    UIButton*       _imgButton;
    
    NSMutableArray*         _accessoryArray;
    BOOL            _hasCreatedNew;
    
    NSString        *_workGroupId;
    
    NSString *      _currentFileName;
}
@property (nonatomic,assign) BOOL chang;

@end

@implementation ICCreateNewGroupViewController

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
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat top = 65;
    
    UILabel* line = [[UILabel alloc] initWithFrame:CGRectMake(0, top, width, 0.5)];
    [line setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line];
    
    UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, top + 50, width, 0.5)];
    [line1 setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line1];
    
    UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, line1.frame.origin.y + 50, width, 0.5)];
    [line2 setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line2];
    
    UILabel* line3 = [[UILabel alloc] initWithFrame:CGRectMake(0, line2.frame.origin.y + 30, width, 0.5)];
    [line3 setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line3];
    
    UILabel* line4 = [[UILabel alloc] initWithFrame:CGRectMake(0, line3.frame.origin.y + 80, width, 0.5)];
    [line4 setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line4];
    
    
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [img setBackgroundColor:[UIColor clearColor]];
    [img setImage:[UIImage imageNamed:@"icon_touxiang"]];
    
    _imgButton = [[UIButton alloc] initWithFrame:CGRectMake(10, line3.frame.origin.y + 10, 60, 60)];
    [_imgButton setImage:[img image] forState:UIControlStateNormal];
    [_imgButton addTarget:self action:@selector(btnImgClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_imgButton];
    
    UILabel* iphoto = [[UILabel alloc] initWithFrame:CGRectMake(80, line3.frame.origin.y + 25, 150, 30)];
    [iphoto setBackgroundColor:[UIColor clearColor]];
    [iphoto setTextColor:[UIColor grayColor]];
    [iphoto setTextAlignment:NSTextAlignmentLeft];
    [iphoto setText:@"修改群组头像"];
    [iphoto setFont:[UIFont systemFontOfSize:16]];
    [_contentView addSubview:iphoto];

    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;

    _txtGroupName = [[UITextField alloc] initWithFrame:CGRectMake(10, line.frame.origin.y + 10, width - 20, 30)];
    [_txtGroupName setBackgroundColor:[UIColor orangeColor]];
    [_txtGroupName setBorderStyle:UITextBorderStyleNone];
    [_txtGroupName setFont:[UIFont systemFontOfSize:17]];
    [_txtGroupName setTextColor:[UIColor whiteColor]];
    [_txtGroupName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtGroupName.delegate = self;
    
    _txtGroupName = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtGroupName showBottomLine:NO];
    
    _lblGroupName = [[UILabel alloc] init];
    _lblGroupName.text = @"群组名称";
    _lblGroupName.font = [UIFont systemFontOfSize:16];
    _lblGroupName.textColor = [UIColor grayColor];
    _lblGroupName.frame = _txtGroupName.frame;
    
    [_contentView addSubview:_txtGroupName];
    [_contentView addSubview:_lblGroupName];
    
    
    _txtSignature = [[UITextField alloc] initWithFrame:CGRectMake(10, line1.frame.origin.y + 10,  width - 20, 30)];
    [_txtSignature setBackgroundColor:[UIColor orangeColor]];
    [_txtSignature setBorderStyle:UITextBorderStyleNone];
    [_txtSignature setFont:[UIFont systemFontOfSize:17]];
     [_txtSignature setTextColor:[UIColor whiteColor]];
    [_txtSignature addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtSignature.delegate = self;
    
    _txtSignature = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtSignature showBottomLine:NO];
    
    _lblSignature = [[UILabel alloc] init];
    _lblSignature.text = @"签名";
    _lblSignature.font = [UIFont systemFontOfSize:16];
    _lblSignature.textColor = [UIColor grayColor];
    _lblSignature.frame = _txtSignature.frame;
    
    [_contentView addSubview:_txtSignature];
    [_contentView addSubview:_lblSignature];
    
    
    if (self.viewType == ViewTypeEdit) {
        if (self.workGroup != nil) {
            _txtGroupName.text = self.workGroup.workGroupName;
            _txtSignature.text = self.workGroup.workGroupMain;
            [_imgButton setImageWithURL:[NSURL URLWithString:self.workGroup.workGroupImg]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            if (_txtGroupName.text != nil) {
                [self diminishTextName:_lblGroupName];
            }
            if (_txtSignature.text != nil) {
                [self diminishTextName:_lblSignature];
            }
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.cAccessoryArray != nil){
        NSLog(@"%@",self.cAccessoryArray);
        if (_cAccessoryArray.count > 0) {
            int i = 0;
            for (ALAsset* ass in _accessoryArray)
            {
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
                
                i++;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.viewType == ViewTypeEdit) {
        if ([self.icSettingController respondsToSelector:@selector(setWorkGroup:)]) {
            [self.icSettingController setValue:_workGroup forKey:@"workGroup"];
        }
    }
    
    if (_hasCreatedNew) {
        if ([self.icMainController respondsToSelector:@selector(setHasCreatedNewGroup:)]) {
//            [self.icMainController setValue:@"1" forKey:@"hasCreatedNewGroup"];
            [self.icMainController setValue:_workGroupId forKey:@"hasCreatedNewGroup"];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender
{
    if (self.viewType == ViewTypeEdit) {
        
        NSString* name = _txtGroupName.text;
        NSString* desc = _txtSignature.text;
        NSString* img = self.workGroup.workGroupImg;
        NSString* wgid = self.workGroup.workGroupId;
        
        if (_cAccessoryArray.count > 0) {
            Accessory* acc = [_cAccessoryArray objectAtIndex:0];
            img = acc.address;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isOk = [Group updateGroup:wgid name:name description:desc groupImage:img];
            if (isOk) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"群组资料修改成功!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                _workGroup.workGroupName = name;
                _workGroup.workGroupMain = desc;
                _workGroup.workGroupImg = img;
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
        });
    }
    else
    {
        
        NSString* name = _txtGroupName.text;
        NSString* desc = _txtSignature.text;
        
        if ((name == nil || [name isEqualToString:@""]) || (desc == nil || [desc isEqualToString:@""])) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"群组名称和标签不能为空!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
               
        NSString* img = @"";
        
        if (_cAccessoryArray.count > 0) {
             Accessory* acc = [_cAccessoryArray objectAtIndex:0];
            img = acc.address;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString * workGId = @"";
            
            BOOL isOk = [Group createNewGroup:name description:desc groupImage:img workGroupId:&workGId];
            if (isOk) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"群组已创建!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                _hasCreatedNew = YES;
                
                _workGroupId = [NSString stringWithFormat:@"%@", workGId];
                
                [self jumpToMainView:_workGroupId];
                
//                [self.navigationController popViewControllerAnimated:YES];
            }
            
        });
        
        
        
    }
}

- (void) jumpToMainView:(NSString *)workGroupId
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMainViewController"];
    ((ICMainViewController*)vc).pubGroupId = workGroupId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblGroupName];
    
    if (textField == _txtGroupName)
    {
        [self diminishTextName:_lblGroupName];
        [self restoreTextName:_lblSignature textField:_txtSignature];
    }
    else if (textField == _txtSignature)
    {
        [self diminishTextName:_lblSignature];
        [self restoreTextName:_lblGroupName textField:_txtGroupName];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtGroupName)
    {
        return [_txtSignature becomeFirstResponder];
    }
    else {
        [self restoreTextName:_lblSignature textField:_txtSignature];
        return [_txtSignature resignFirstResponder];
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
    [self restoreTextName:_lblGroupName textField:_txtGroupName];
    [self restoreTextName:_lblSignature textField:_txtSignature];
}


-(IBAction)btnSubmit:(id)sender
{
    UIView* v  = [[UIView alloc] init];
    v.frame = self.view.frame;
    v.tag = 201;
    [v setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:v];
}

- (IBAction)btnRegister:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberRegisterViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)btnImgClicked:(id)sender
{
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取",nil];
    [as showInView:self.view];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        _currentFileName = @"IMG_test.JPG";
        
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
        
        self.workGroup.workGroupImg = userImgPath;
    }
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma UIActionSheet Deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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


#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"%@",assets);
    
    [picker dismissViewControllerAnimated:YES completion:^()
    {
        if (assets.count > 0) {
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
        }
    }];
   
}

@end
