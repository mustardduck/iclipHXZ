//
//  UICommon.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/8/4.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "UICommon.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSStringEx.h"

static UIViewController *imagePicker = nil;

@implementation UICommon

+ (NSString *) findFileType:(NSString *) name
{
    NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
    
    NSString * fileType = [name substringFromIndex:range.location + 1];
    
    NSString * fileNum = @"";
    
    if([fileType equalsIgnoreCase:@"doc"] || [fileType equalsIgnoreCase:@"docx"])
    {
        fileNum = @"1";
    }
    else if ([fileType equalsIgnoreCase:@"xls"] || [fileType equalsIgnoreCase:@"xlsx"])
    {
        fileNum = @"2";
    }
    else if ([fileType equalsIgnoreCase:@"ppt"] || [fileType equalsIgnoreCase:@"pptx"])
    {
        fileNum = @"3";
    }
    else if ([fileType equalsIgnoreCase:@"pdf"])
    {
        fileNum = @"4";
    }
    else if ([fileType equalsIgnoreCase:@"png"] || [fileType equalsIgnoreCase:@"jpg"])
    {
        fileNum = @"0";
    }
    else
    {
        fileNum = @"6";
    }
    return fileNum;
}

+ (UIImage *)changeImageOrientation:(UIImage *)image
{
    UIImageOrientation imageOrientation=image.imageOrientation;
    if(imageOrientation!=UIImageOrientationUp)
    {//图片旋转
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    return image;
}

+ (CGSize)getWidthFromLabel:(UILabel *)label
{
    CGSize size = CGSizeMake(MAXFLOAT, H(label));
    if ([UICommon getSystemVersion] > 7.0)//IOS 7.0 以上
    {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:label.font, NSFontAttributeName,nil];
        size =[label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }
    else
    {
        size = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];//ios7以上已经摒弃的这个方法
    }
    
    return size;
}

+(float)getSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (UIViewController *)getOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController
{
    id ret = nil;
    
    NSArray *array = navController.viewControllers;
    
    if (!array && array.count == 0) return nil;
    
    for (id object in array)
    {
        if ([object isKindOfClass:[viewCon class]])
        {
            ret = object;
        }
    }
    UIViewController *popTarget = ret;
    return popTarget;
}

+ (void)popOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController
{
    UIViewController *model =  [self getOldViewController:viewCon withNavController:navController];
    if (model && [model isKindOfClass:[UIViewController class]])
        [navController popToViewController:model animated:YES];
}

+ (CGSize) getSizeFromString:(NSString *)str withSize:(CGSize)cSize withFont:(UIFont*)font
{
    CGSize size = CGSizeZero;
    
    if([UICommon getSystemVersion] >= 7.0)
    {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName,[NSParagraphStyle defaultParagraphStyle],NSParagraphStyleAttributeName, nil];
        
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        
        size = [str boundingRectWithSize:cSize options:options attributes:attributes context:nil].size;
        
        if(size.height > cSize.height)
        {
            size.height = cSize.height;
        }
        
        size.width = ceil(size.width);
        
    }
    else
    {
        size = [str sizeWithFont:font constrainedToSize:cSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return size;
}

+ (CGSize)getHeightFromLabel:(UILabel *)label
{
    NSDictionary *attribute = @{NSFontAttributeName: label.font};
    
    CGSize retSize = CGSizeZero;
    
    if([UICommon getSystemVersion] >= 7.0)
    {
        retSize = [label.text boundingRectWithSize:CGSizeMake(W(label), MAXFLOAT)
                   
                                           options:\
                   
                   NSStringDrawingTruncatesLastVisibleLine |
                   
                   NSStringDrawingUsesLineFragmentOrigin |
                   
                   NSStringDrawingUsesFontLeading
                   
                                        attributes:attribute
                   
                                           context:nil].size;
    }
    else
        retSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(W(label), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat ret = (H(label) - retSize.height)/2;
    retSize.height += ret;
    return retSize;
}

+ (NSString *)dayAndHourFromString:(NSString *)dateString formatStyle:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];;
    [formatter setDateFormat:format];
    return [formatter stringFromDate:destDate];
    
}

+ (NSDate *) formatDate:(NSString *)input
{
    if ([input length] == 0) {
        
        return nil;
    }
    
    NSString *text = [input stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
    if ([text length] > 16) {
        
        text = [text substringToIndex:16];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];

    NSDate *destDate= [dateFormatter dateFromString:text];

    return destDate;
}

+ (NSString*) formatTime:(NSString*)input withLength:(int)length{
    
    if ([input length] == 0) {
        
        return @"";
    }
    
    NSString *text = [input stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
    if ([text length] > length) {
        
        text = [text substringToIndex:length];
    }
    
    return text;
}

#pragma mark camera utility
+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void) showImagePicker:(id)delegate view:(UIViewController*)controller{
    imagePicker  = controller;
    if ([self isPhotoLibraryAvailable]) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        pickerController.mediaTypes = mediaTypes;
        pickerController.delegate = delegate;
        [imagePicker presentViewController:pickerController
                                  animated:YES
                                completion:^(void){
                                    NSLog(@"Picker View Controller is presented");
                                }];
    }
    
}

+ (void) showCamera:(id)delegate view:(UIViewController*) controller allowsEditing:(BOOL)allow{
    imagePicker  = controller;
    // 拍照
    if ([UICommon isCameraAvailable] && [UICommon doesCameraSupportTakingPhotos]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = delegate;
        [imagePicker presentViewController:controller
                                  animated:YES
                                completion:^(void){
                                    NSLog(@"Picker View Controller is presented");
                                }];
    }else{
        [UICommon showImagePicker:delegate view:controller];
    }
}

@end

#pragma mark - UIView
@implementation UIView (RCMethod)

- (void)setRoundCorner:(float)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
}

- (void)setRoundColorCorner:(float)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor grayMarkLineColor].CGColor;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setRoundColorCorner:(float)cornerRadius withColor:(UIColor *)color
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = color.CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
}

- (void)setBorderWithColor:(UIColor *)color
{
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = color.CGColor;
}
- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin: (CGPoint) aPoint
{
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize: (CGSize) aSize
{
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

- (CGPoint)bottomRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)bottomLeft
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)topRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight: (CGFloat) newheight
{
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth: (CGFloat) newwidth
{
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newtop
{
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft: (CGFloat) newleft
{
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom: (CGFloat) newbottom
{
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight: (CGFloat) newright
{
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

@end

@implementation UIViewController (expanded)

- (void) hiddenKeyboard{}

- (void) sendComment{}

- (void) addSendToKeyboard:(UIView *)activeView
{
    //定义完成按钮
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    [topView setBarStyle:UIBarStyleBlack];
    if ([UICommon getSystemVersion] < 7.0)
    {
        [topView setTintColor:RGBCOLOR(174, 178, 185)];
    }
    else
    {
        [topView setBarTintColor:RGBCOLOR(174, 178, 185)];
    }
    
    UIBarButtonItem * button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendComment)];
    
    doneButton.tintColor = RGBCOLOR(85, 85, 85);
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    if([activeView isKindOfClass:[UITextField class]])
    {
        UITextField * text = (UITextField *)activeView;
        
        [text setInputAccessoryView:topView];
        
    }
    else
    {
        UITextView * textView = (UITextView *)activeView;
        
        [textView setInputAccessoryView:topView];
    }
}

- (void) addDoneToKeyboard:(UIView *)activeView
{
    //定义完成按钮
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    [topView setBarStyle:UIBarStyleBlack];
    if ([UICommon getSystemVersion] < 7.0)
    {
        [topView setTintColor:RGBCOLOR(174, 178, 185)];
    }
    else
    {
        [topView setBarTintColor:RGBCOLOR(174, 178, 185)];
    }
    
    UIBarButtonItem * button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyboard)];
    
    doneButton.tintColor = RGBCOLOR(85, 85, 85);
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    if([activeView isKindOfClass:[UITextField class]])
    {
        UITextField * text = (UITextField *)activeView;
        
        [text setInputAccessoryView:topView];
        
    }
    else
    {
        UITextView * textView = (UITextView *)activeView;
        
        [textView setInputAccessoryView:topView];
    }
}

@end

@implementation UIColor (Addition)

+ (UIColor *) disableGreyColor
{
    return RGBCOLOR(99, 99, 102);
}

+ (UIColor *) greyStatusBarColor
{
    return RGBCOLOR(35, 34, 39);
}

+ (UIColor *) cellHoverBackgroundColor
{
    return RGBCOLOR(43, 42, 47);
}

+ (UIColor *) grayLineColor//灰色线
{
    return RGBCOLOR(119, 119, 119);
}

+ (UIColor *) grayMarkLineColor//灰色线
{
    return RGBCOLOR(69, 69, 69);
}

+ (UIColor *) grayTitleColor//灰色线
{
    return RGBCOLOR(172, 172, 173);
}

+ (UIColor *) grayMarkColor
{
    return RGBCOLOR(64, 64, 64);
}

+ (UIColor *) grayMarkHoverTitleColor
{
    return RGBACOLOR(255, 255, 255, 0.3);
}

+ (UIColor *) grayMarkHoverBackgroundColor
{
    return RGBCOLOR(52, 52, 52);
}

+ (UIColor *) backgroundColor
{
    return RGBCOLOR(47, 47, 47);
}

+ (UIColor *) tagBlueBackColor
{
    return RGBCOLOR(90, 112, 223);
}

+ (UIColor *) blueTextColor
{
    return RGBCOLOR(53, 159, 219);
}

+ (UIColor *) pdfBackColor
{
    return RGBCOLOR(143, 57, 231);
}
+ (UIColor *) wordBackColor
{
    return RGBCOLOR(57, 161, 231);
}
+ (UIColor *) excelBackColor
{
    return RGBCOLOR(73, 204, 178);
}
+ (UIColor *) qitaBackColor
{
    return RGBCOLOR(172, 172, 173);
}
+ (UIColor *) pptBackColor
{
    return RGBCOLOR(245, 124, 36);
}

@end
