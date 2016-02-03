//
//  MQCreateNewGroupVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/29.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQCreateNewGroupVC.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "SVProgressHUD.h"
#import "MQSettingGroupVC.h"
#import "UICommon.h"
#import "VPImageCropperViewController.h"
#import <ZYQAssetPickerController.h>

@interface MQCreateNewGroupVC ()<UIActionSheetDelegate, ZYQAssetPickerControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate,UINavigationControllerDelegate>
{
    NSString *      _currentFileName;

}

@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property (weak, nonatomic) IBOutlet UIButton *photoImgBtn;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTxt;
@property (weak, nonatomic) IBOutlet UITextView *sloganTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sloganHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineBottomCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sloganTextViewTopCons;

@end

@implementation MQCreateNewGroupVC

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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    if (self.viewType == MQViewTypeEdit) {
        if (self.workGroup != nil) {
            _groupNameTxt.text = self.workGroup.workGroupName;
            

            _sloganTextView.text = self.workGroup.workGroupMain;
                        
            CGFloat he = [UICommon getSizeFromString:_sloganTextView.text withSize:CGSizeMake(SCREENWIDTH - 114, 63) withFont:_sloganTextView.font].height;
            
            if(he < 20)
            {
                _sloganHeightCons.constant = 44;
                _sloganTextViewTopCons.constant = 5;
                _lineBottomCons.constant = 19;
            }
            
            [_photoImgView setImageWithURL:[NSURL URLWithString:self.workGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        }
    }
    
}

- (IBAction)btnImgClicked:(id)sender
{
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取",nil];
    [as showInView:self.view];
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
    if (self.viewType == MQViewTypeEdit) {
        
        NSString* name = _groupNameTxt.text;
        NSString* desc = _sloganTextView.text;
        NSString* img = self.workGroup.workGroupImg;
        NSString* wgid = self.workGroup.workGroupId;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isOk = [Group updateGroup:wgid name:name description:desc groupImage:img];
            if (isOk) {
                
                [SVProgressHUD showSuccessWithStatus:@"群组资料修改成功!"];
                
                _workGroup.workGroupName = name;
                _workGroup.workGroupMain = desc;
                _workGroup.workGroupImg = img;
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
        });
    }
    
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

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    [SVProgressHUD showInfoWithStatus:@"图片上传中..."];
    
    NSString * userImgPath = @"";
    
    BOOL isOk = [LoginUser uploadImageWithScale:editedImage fileName:_currentFileName userImgPath:&userImgPath];
    
    if(isOk)
    {
        [SVProgressHUD dismiss];
        
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [img setBackgroundColor:[UIColor clearColor]];
        [img setImage:editedImage];
        
        _photoImgView.image = img.image;
        
        self.workGroup.workGroupImg = userImgPath;
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.viewType == MQViewTypeEdit) {
        if ([self.icSettingController respondsToSelector:@selector(setWorkGroup:)]) {
            [self.icSettingController setValue:_workGroup forKey:@"workGroup"];
        }
    }
}
- (void) hiddenKeyboard
{
    [_groupNameTxt resignFirstResponder];
    [_sloganTextView resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
