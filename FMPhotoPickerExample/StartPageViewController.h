//
//  ViewController.h
//  GLViewPagerViewController
//
//  Created by Yanci on 17/4/18.
//  Copyright © 2017年 Yanci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLViewPagerViewController.h"
//#import "FMPhotoPickerExample-Swift.h"
#import "MKStoreKit.h"
#import "MBProgressHUD.h"
#import "PurchaseViewController.h"
@interface StartPageViewController : GLViewPagerViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    __weak IBOutlet UIImageView *selectedImage;
    __weak IBOutlet UIButton *btnNext;
    __weak IBOutlet UIButton *btnClose;
    __weak IBOutlet UIView *viewImage;
    __weak IBOutlet NSLayoutConstraint *viewImageHeightConstraint;
    
    MBProgressHUD *hud;
}

@property (assign, nonatomic) BOOL isSelectingImage;

-(IBAction)openSettings:(id)sender;

@end

