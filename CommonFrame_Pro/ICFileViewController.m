//
//  ICFileViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/13.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICFileViewController.h"
#import "UIColor+HexString.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

#define BASE_URL @"http://120.26.113.44:8080/clip_basic"

typedef enum {
    TableDataTypeFile           = 0,
    TableDataTypeUpload         = 1
}TableDataType;

@interface ICFileViewController()<UITableViewDataSource,UITableViewDelegate,ASIProgressDelegate>
{
    UITableView*    _tableView;
    UIButton*       _btnUpload;
    UIButton*       _btnFile;
    
    TableDataType   _tableDataType;
    
    NSMutableArray*        _uploadArray;
    NSMutableArray*        _myFilesArray;
    
    NSInteger       _fileIndex;
    BOOL            _isContinue;
    
    NSMutableArray*         _AccessoryArray;
    
    NSOperationQueue* queue;
    
    NSMutableArray*     _tmpData;
    BOOL                _isDone;
}

@end

@implementation ICFileViewController

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
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneClicked:)];
    [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor disableGreyColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, cWidth, [UIScreen mainScreen].bounds.size.height - 66)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    [self setExtraCellLineHidden:_tableView];
    
    [self.view addSubview:_tableView];
    
    _tableView.tableHeaderView = ({
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cWidth, 45)];
        [view setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
        
        UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cWidth/2 , 45)];
        [leftView setBackgroundColor:[UIColor clearColor]];
        leftView.tag = 201;
        
        _btnFile = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width, 44)];
        [_btnFile setTitle:@"文件夹" forState:UIControlStateNormal];
        [_btnFile setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnFile addTarget:self action:@selector(btnFileClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* leftBottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 44.5, cWidth/2, 0.5)];
        [leftBottomLine setBackgroundColor:[UIColor grayColor]];
        
        [leftView addSubview:_btnFile];
        [leftView addSubview:leftBottomLine];
        
        
        UIView* rightView = [[UIView alloc] initWithFrame:CGRectMake(cWidth/2, 0, cWidth/2, 45)];
        [rightView setBackgroundColor:[UIColor clearColor]];
         rightView.tag = 202;
        
         _btnUpload = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width, 44)];
        [_btnUpload setTitle:@"上传列表" forState:UIControlStateNormal];
        [_btnUpload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnUpload addTarget:self action:@selector(btnUploadClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* rightBottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 44.5, cWidth/2, 0.5)];
        [rightBottomLine setBackgroundColor:[UIColor grayColor]];

        [rightView addSubview:_btnUpload];
        [rightView addSubview:rightBottomLine];
        
        [view addSubview:leftView];
        [view addSubview:rightView];
        
        view;
    });
    
    
    if (_myFilesArray == nil) {
        _myFilesArray = [NSMutableArray array];
    }
//     _myFilesArray = [NSMutableArray arrayWithArray:[CommonFile getFileFromDocument]];
    _myFilesArray = [NSMutableArray arrayWithArray:[Accessory getAccessoryListByWorkGroupID:_workGroupId]];
    
    if (_hasUploadedFileArray.count > 0)
    {
        _tmpData = [NSMutableArray arrayWithArray:_hasUploadedFileArray];
    }
    
    if (self.uploadFileArray.count > 0) {
        if (_uploadArray == nil) {
            _uploadArray = [NSMutableArray array];
        }

        for (int j = 0; j < self.uploadFileArray.count; j++) {
            if ([[self.uploadFileArray objectAtIndex:j] isKindOfClass:[ALAsset class]]) {
                
                ALAsset* asset = (ALAsset*)[self.uploadFileArray objectAtIndex:j];
                ALAssetRepresentation* representation = [asset defaultRepresentation];
                
                NSString* filename = [representation filename];
                
                BOOL isEx = NO;
                
                for (int i = 0; i < self.hasUploadedFileArray.count; i++) {
                    Accessory * ac = [self.hasUploadedFileArray objectAtIndex:i];
                    
                    if ([filename isEqualToString:ac.name]) {
                        isEx = YES;
                        break;
                    }
                }
                
                if (!isEx) {
                    [_uploadArray addObject:asset];
                }
            }
        }
        
        //[_uploadArray addObjectsFromArray:self.uploadFileArray];
        _isContinue = YES;
        dispatch_queue_t queue1 = dispatch_queue_create("upload", NULL);
        
        dispatch_async(queue1, ^{
            sleep(1);
            [self upload:_uploadArray];
        });
        
        
    }
    
}

- (BOOL)imgInUploaded:(NSString*)filename
{
   
    for (int i = 0; i < self.hasUploadedFileArray.count; i++) {
        Accessory * ac = [self.hasUploadedFileArray objectAtIndex:i];
        
        if ([filename isEqualToString:ac.name]) {
            return YES;
        }
    }

    return NO;
}

- (void)upload:(NSArray*)objs
{
     queue = [[NSOperationQueue alloc] init];
    
    
    int i = 0;
    
    NSString* base_url = [HttpBaseFile baseURL];
    
    for (id obj in objs)
    {
        if ([obj isKindOfClass:[ALAsset class]])
        {
            ALAsset* asset = (ALAsset*)obj;
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
            NSString* filename = [representation filename];

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
            
            imgH = [UIImage
                    imageWithCGImage:[representation fullScreenImage]
                    scale:[representation scale]
                    orientation:UIImageOrientationUp];
            
            NSData* data = UIImageJPEGRepresentation(imgH, 1.0f);
            
            NSString* filePath = [CommonFile saveImageToDocument:data fileName:filename];
            
            ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/file/upload.hz",base_url]]];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-Type" value:@"image/jpg"];
            [request setFile:filePath forKey:@"photo"];
            [request setUploadProgressDelegate:self];
            [request setShowAccurateProgress:YES];
            [request setTag:i];

            __block NSString*  resString = nil;
            __block NSError*    error;
            __block NSInteger  tag;
            
            [request setCompletionBlock:^{
                
                resString = [request responseString];
                tag = request.tag;
                NSLog(@"%ld finished: %@",(long)tag,resString);
                
                Accessory* acc = [Accessory jsonToObj:resString];
                if (acc != nil) {
                    
                    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    
                    acc.isComplete = 1;
                    acc.source = 1;
                    acc.status = 1;
                    //acc.tmpImg = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                    if (_AccessoryArray == nil) {
                        _AccessoryArray = [NSMutableArray array];
                    }
                    
                    [_AccessoryArray addObject:acc];
                }
            }];
            
            [request setFailedBlock:^{
                _isDone = NO;
                error = [request error];
                NSLog(@"Error:%@",[error description]);
            }];
            
            [queue addOperation:request];
            
            while (1) {
                if (_isContinue) {
                    break;
                }
            }
            
            //[request startAsynchronous];
            
            _fileIndex = i;
            _isContinue = NO;
            
            
        }
        i++;
    }
    
}

-(void)setProgress:(float)newProgress
{
    NSInteger index = 0;
    
    for (ALAsset* al in _uploadFileArray) {
        
        ALAsset* a = [_uploadArray objectAtIndex:_fileIndex];
        if (a == al) {
           // _fileIndex = index;
            break;
        }
        index++;
    }
    
    NSLog(@"index:%ld value:%f",index,newProgress);
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    for (UIControl* control in cell.contentView.subviews) {
        if ([control isKindOfClass:[UIProgressView class]]) {
            [((UIProgressView*)control) setProgress:newProgress animated:YES];
        }
        else if (control.tag == 1012) {
            if (newProgress < 1) {
                NSString* vs = [NSString stringWithFormat:@"%f",newProgress * 100];
                int v = [vs intValue];
                [((UILabel*)control) setText:[NSString stringWithFormat:@"%d％",v]];
            }
            else
            {
                [((UILabel*)control) setText:@"上传完成"];
                [self removeItem];
            }
        }
    }
    
    if (newProgress < 1) {
        _isContinue = NO;
    }
    else
        _isContinue = YES;
}

- (void)removeItem
{
    
    /*
    if (_uploadArray.count == _fileIndex + 1) {
        NSMutableArray* tmp = [NSMutableArray array];
        for (int i =0; i <=_fileIndex; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [tmp addObject:indexPath];
        }
        
        _uploadArray = [NSMutableArray array];
        
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:tmp withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView reloadData];
        [_tableView endUpdates];
    }
    */
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_uploadFileArray.count > 0) {
        [_btnUpload sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [_btnFile sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.icPublishMissionController respondsToSelector:@selector(setCAccessoryArray:)]) {
        
        if (_hasUploadedFileArray.count > 0) {
            
            for (int i = 0; i < _hasUploadedFileArray.count; i++) {
                Accessory* ac = [_hasUploadedFileArray objectAtIndex:i];
                BOOL isEx = NO;
                for (int j = 0; j < _AccessoryArray.count; j++) {
                    Accessory* acc = [_AccessoryArray objectAtIndex:j];
                    
                    if ([ac.name isEqualToString:acc.name]) {
                        isEx = YES;
                        break;
                    }
                }
                if (!isEx) {
                    [_AccessoryArray addObject:ac];
                }
            }
            
            //[_AccessoryArray addObjectsFromArray:_hasUploadedFileArray];
        }
        
        if (!_isDone) {
            _AccessoryArray = [NSMutableArray arrayWithArray:_tmpData];
        }
        
        [self.icPublishMissionController setValue:_AccessoryArray forKey:@"cAccessoryArray"];
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


- (void)btnDoneClicked:(id)sender
{
    _isDone = YES;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnCloseClicked:(id)sender
{
//    NSInteger tag = ((UIButton*)sender).tag;
//    
//    NSDictionary* dic = [_myFilesArray objectAtIndex:tag];
//    NSString* imgName = [dic.allKeys objectAtIndex:0];
//    NSString* imgPath = [dic valueForKey:imgName];
//    
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    
//    NSError* err;
//    BOOL isRemoved = [fileManager removeItemAtPath:imgPath error:&err];
//    if (isRemoved) {
//        [_myFilesArray removeObjectAtIndex:tag];
//        [_tableView reloadData];
//    }
}


- (void)btnUpCloseClicked:(id)sender
{
    UIButton* btn = sender;
    NSInteger index = btn.tag;
    
    NSInteger count = queue.operationCount;
    
    if (count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"提示" message:@"还有数据正在处理中，请稍后再试？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
    else
    {
        if (_hasUploadedFileArray.count > 0) {
            
            for (int i = 0; i < _hasUploadedFileArray.count; i++) {
                Accessory* ac = [_hasUploadedFileArray objectAtIndex:i];
                BOOL isEx = NO;
                for (int j = 0; j < _AccessoryArray.count; j++) {
                    Accessory* acc = [_AccessoryArray objectAtIndex:j];
                    
                    if ([ac.name isEqualToString:acc.name]) {
                        isEx = YES;
                        break;
                    }
                }
                if (!isEx) {
                    [_AccessoryArray addObject:ac];
                }
            }
            
        }
        
        if(_uploadArray.count > index)
        {
            [_uploadArray removeObjectAtIndex:index];
        }
        if(_uploadFileArray.count > index)
        {
            ALAsset* asset = [_uploadFileArray objectAtIndex:index];
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            NSString* filename = [representation filename];
            
            for (Accessory* acc in _AccessoryArray) {
                if ([acc.name isEqualToString:filename]) {
                    [_AccessoryArray removeObject:acc];
                    break;
                }
            }
            
            [_uploadFileArray removeObjectAtIndex:index];
        }
        
        _hasUploadedFileArray = [NSMutableArray arrayWithArray:_AccessoryArray];
        
        [_tableView reloadData];
        
    }
}


- (void)btnFileClicked:(UIButton*)sender
{
    [self btnStyle:sender];
    _tableDataType = TableDataTypeFile;
    [_tableView reloadData];
}

- (void)btnUploadClicked:(UIButton*)sender
{
    [self btnStyle:sender];
    _tableDataType = TableDataTypeUpload;
    [_tableView reloadData];
}

- (void)btnStyle:(UIButton*)sender
{
    UIView* pView = sender.superview;
    
    NSInteger pTag = pView.tag;
    
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    for (UIControl* contorl in pView.subviews) {
        if ([contorl isKindOfClass:[UILabel class]]) {
            UILabel* lbl = (UILabel*)contorl;
            CGRect frm = lbl.frame;
            [lbl setFrame:CGRectMake(frm.origin.x, frm.origin.y - 0.5, frm.size.width, 1)];
            [lbl setBackgroundColor:[UIColor colorWithHexString:@"#5a70df"]];
            break;
        }
    }
    
    UIView* ppView = pView.superview;
    
    for (UIControl* con in ppView.subviews)
    {
        if ([con isKindOfClass:[UIView class]])
        {
            if (con.tag != pTag)
            {
                for (UIControl* contorl in ((UIView*)con).subviews)
                {
                    if ([contorl isKindOfClass:[UILabel class]]) {
                        UILabel* lbl = (UILabel*)contorl;
                        CGRect frm = lbl.frame;
                        [lbl setFrame:CGRectMake(frm.origin.x,  44.5, frm.size.width, 0.5)];
                        [lbl setBackgroundColor:[UIColor grayColor]];
                    }
                    else if ([contorl isKindOfClass:[UIButton class]]) {
                        UIButton* btn = (UIButton*)contorl;
                        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tableDataType == TableDataTypeUpload) {
        return _uploadFileArray.count;
    }
    else
        return _myFilesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupListTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_tableDataType == TableDataTypeFile)
    {
        id obj = [_myFilesArray objectAtIndex:indexPath.row];
        
        if ([obj isKindOfClass:[NSString class]]) {
            
        }
        else if ([obj isKindOfClass:[Accessory class]]) {
            
            Accessory * ac = (Accessory *)obj;
            NSString* imgName = ac.name;
            NSString* imgPath = ac.address;
            
            UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(6, 4, 20, 20)];
            [photo setImageWithURL:[NSURL URLWithString: ac.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [photo setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:photo];
            
            UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(photo.frame.origin.x + photo.frame.size.width + 4, photo.frame.origin.y + 4, 40, 12)];
            [name setText:ac.userName];
            [name setTextColor:[UIColor whiteColor]];
            [name setFont:[UIFont systemFontOfSize:13]];
            [cell.contentView addSubview:name];
            
            UILabel* time = [[UILabel alloc] initWithFrame:CGRectMake(cWidth - 70, photo.frame.origin.y + 4, 60, 12)];
            
            NSString * dateStr = [UICommon dayAndHourFromString:ac.addTime formatStyle:@"MM/dd HH:mm"];
            [time setText:dateStr ];
            [time setTextColor:[UIColor grayColor]];
            [time setFont:[UIFont systemFontOfSize:10]];
            [time setTextAlignment:NSTextAlignmentRight];
            [cell.contentView addSubview:time];
            
            
            UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(name.frame.origin.x,photo.frame.origin.y + photo.frame.size.height + 5, 44, 44)];
//            [img setImage:[UIImage imageWithContentsOfFile:imgPath]];
            
            [img setImageWithURL:[NSURL URLWithString: imgPath] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [img setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:img];
            
            UILabel* imgname = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x + img.frame.size.width + 10,
                                                                         img.frame.origin.y,
                                                                         cWidth - (img.frame.origin.x + img.frame.size.width + 10) - 10,
                                                                         32)];
            [imgname setText:imgName];
            [imgname setTextColor:[UIColor whiteColor]];
            [imgname setFont:[UIFont systemFontOfSize:12]];
            [imgname setNumberOfLines:0];
            imgname.numberOfLines = 0;
            [imgname setLineBreakMode:NSLineBreakByTruncatingMiddle];
            [cell.contentView addSubview:imgname];
            
            
//            UILabel* workName = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x + img.frame.size.width + 10,
//                                                                          img.frame.origin.y + img.frame.size.height - 10,
//                                                                          60,
//                                                                          10)];
//            [workName setText:@"回形针项目"];
//            [workName setTextColor:[UIColor grayColor]];
//            [workName setFont:[UIFont systemFontOfSize:10]];
//            [workName setTextAlignment:NSTextAlignmentLeft];
//            [cell.contentView addSubview:workName];
//            
//            UILabel* status = [[UILabel alloc] initWithFrame:CGRectMake(workName.frame.origin.x + workName.frame.size.width + 5,
//                                                                        workName.frame.origin.y,
//                                                                        80,
//                                                                        10)];
//            [status setText:@"上传完成"];
//            [status setTextColor:[UIColor grayColor]];
//            [status setFont:[UIFont systemFontOfSize:10]];
//            [status setTextAlignment:NSTextAlignmentLeft];
//            [cell.contentView addSubview:status];
            
//            
//            UIButton* delete = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 30, 62, 16, 14.4)];
//            [delete setBackgroundImage:[UIImage imageNamed:@"btn_guanbi_1"] forState:UIControlStateNormal];
//            [delete setTag:indexPath.row];
//            [delete addTarget:self action:@selector(btnCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:delete];
            
        }        
    }
    else
    {
        //NSInteger index = indexPath.row;
        
        ALAsset* asset = [_uploadFileArray objectAtIndex:indexPath.row];
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
        NSString* filename = [representation filename];
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
         
         imgH = [UIImage
                 imageWithCGImage:[representation fullScreenImage]
                 scale:[representation scale]
                 orientation:UIImageOrientationUp];
        
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(12,10, 50, 50)];
        [img setImage:imgH];
        [cell.contentView addSubview:img];
        
        UILabel* imgname = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x + img.frame.size.width + 10,
                                                                     img.frame.origin.y,
                                                                     cWidth - (img.frame.origin.x + img.frame.size.width + 10) - 40,
                                                                     32)];
        [imgname setText:filename];
        [imgname setTextColor:[UIColor whiteColor]];
        [imgname setFont:[UIFont systemFontOfSize:12]];
        [imgname setNumberOfLines:0];
        imgname.numberOfLines = 0;
        [imgname setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [cell.contentView addSubview:imgname];
        
        
        UILabel* workName = [[UILabel alloc] initWithFrame:CGRectMake(img.frame.origin.x + img.frame.size.width + 10,
                                                                      img.frame.origin.y + img.frame.size.height - 10,
                                                                      60,
                                                                      10)];
        [workName setText:@"回形针项目"];
        [workName setTextColor:[UIColor grayColor]];
        [workName setFont:[UIFont systemFontOfSize:10]];
        [workName setTextAlignment:NSTextAlignmentLeft];
        [cell.contentView addSubview:workName];
        
        UILabel* status = [[UILabel alloc] initWithFrame:CGRectMake(workName.frame.origin.x + workName.frame.size.width + 5,
                                                                    workName.frame.origin.y,
                                                                    80,
                                                                    10)];
        BOOL isUp = NO;
        if ([self imgInUploaded:filename]) {
            [status setText:@"上传完成"];
            isUp = YES;
        }
        else
            [status setText:@"等待上传"];
        [status setTextColor:[UIColor grayColor]];
        [status setFont:[UIFont systemFontOfSize:10]];
        [status setTextAlignment:NSTextAlignmentLeft];
        [status setTag:1012];
        [cell.contentView addSubview:status];
        
        
        UIProgressView* pv = [[UIProgressView alloc] initWithFrame:CGRectMake(img.frame.origin.x, img.frame.origin.y + img.frame.size.height + 10, cWidth - img.frame.origin.x - 15, 20)];
        [pv setProgressViewStyle:UIProgressViewStyleDefault];
        if (isUp) {
            [pv setProgress:1.0f animated:NO];
        }
        else
            [pv setProgress:0.0f animated:YES];
        [cell.contentView addSubview:pv];
        
        UIButton* delete = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 30, 40, 20, 18)];
        [delete setBackgroundImage:[UIImage imageNamed:@"btn_guanbi_1"] forState:UIControlStateNormal];
        [delete setTag:indexPath.row];
        [delete addTarget:self action:@selector(btnUpCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:delete];
    }
    
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 79.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    [cell setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableDataType == TableDataTypeFile)
    {
        id obj = [_myFilesArray objectAtIndex:indexPath.row];
        
        if ([obj isKindOfClass:[NSString class]]) {
            
        }
        else if ([obj isKindOfClass:[Accessory class]]) {
            
            _isDone = YES;

            Accessory * acc = (Accessory *)obj;
            
            if (acc != nil) {
                
                _AccessoryArray = [NSMutableArray array];

                [_AccessoryArray addObject:acc];
                
            }

            
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
