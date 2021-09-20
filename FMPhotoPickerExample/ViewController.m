//
//  ViewController.m
//  BasicFilters
//
//  Created by Kanwarpal Singh on 25/07/17.
//  Copyright © 2017 Kanwarpal Singh. All rights reserved.
//

#import "ViewController.h"
#import "CLImageEditorTheme+Private.h"
#import "UIView+Frame.h"
#import "CLImageToolBase.h"
#import "ToolBarItem.h"
#import <StoreKit/StoreKit.h>
#import "FMPhotoPickerExample-Swift.h"
#import "Constant.h"

//@import GoogleMobileAds;

@interface ViewController ()

@property (nonatomic, strong, readwrite) CLImageToolBase *currentTool;
//@property(nonatomic, strong) GADInterstitialAd *interstitial;

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden {
    return YES; // or NO
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.barColor = [UIColor colorWithRed:18.0/255.0 green:18.0/255.0 blue:18.0/255.0 alpha:1];
    
//    GADRequest *request = [GADRequest request];
//    [GADInterstitialAd loadWithAdUnitID:@"ca-app-pub-4618660522470619/7739090658"
//                                request:request
//                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
//      if (error) {
//        NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
//        return;
//      }
//      self.interstitial = ad;
//    }];
    
    [self initNavigationBar];
    [self refreshImageView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self resetImageViewFrame];
    [self refreshToolSettings];
    [self scrollViewDidZoom:_scrollView];
}

- (void)refreshImageView{
    _imageView = [UIImageView new];
    [self.scrollView addSubview:_imageView];

    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

-(UIBarButtonItem *)buttonWithImageName:(NSString *)imageName selector:(SEL)selector{
    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake( 0, 0, 30, 30 );
    btn.tintColor   =   [UIColor whiteColor];
    [btn setImage:image forState:UIControlStateNormal];
    btn.clipsToBounds   = true;
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return barBtn;
}

- (void)initNavigationBar{
    UIBarButtonItem *rightBarButtonItem =   nil;
    rightBarButtonItem      =   [self buttonWithImageName:@"OK" selector:@selector(pushedFinishBtn:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if(_navigationBar==nil){
        UINavigationItem *navigationItem  = [[UINavigationItem alloc] initWithTitle:@"Photo Effect Enhancer"];
        navigationItem.leftBarButtonItem  = [self buttonWithImageName:@"Close" selector:@selector(pushedCloseBtn:)];
        navigationItem.rightBarButtonItem = rightBarButtonItem;
        CGFloat dy = MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
        
        CGFloat startY = dy;
        
//        if (@available(iOS 11.0, *)) {
//            UIWindow *window = UIApplication.sharedApplication.keyWindow;
//            CGFloat topPadding = window.safeAreaInsets.top;
//
//            startY += topPadding;
//        }
        
        UINavigationBar *navigationBar  =   [[UINavigationBar alloc] initWithFrame:CGRectMake(0, startY, self.view.width, kNavBarHeight)];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        navigationBar.delegate          =   self;
        [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

        if(self.navigationController){
            [self.navigationController.view addSubview:navigationBar];
        }
        else{
            [self.view addSubview:navigationBar];
        }
        _navigationBar = navigationBar;
    }
    
    if(self.navigationController!=nil){
        _navigationBar.frame  = self.navigationController.navigationBar.frame;
        _navigationBar.hidden = YES;
        [_navigationBar popNavigationItemAnimated:NO];
    }
    else{
        _navigationBar.topItem.title = @"Photo Effect Enhancer";
    }
    _navigationBar.translucent = true;
    
    _navigationBar.backgroundColor = [UIColor colorWithRed:18.0/255.0 green:18.0/255.0 blue:18.0/255.0 alpha:1];
    _navigationBar.barTintColor = [UIColor colorWithRed:18.0/255.0 green:18.0/255.0 blue:18.0/255.0 alpha:1];
}

- (void)initMenuScrollView
{
    self.menuScrollView.backgroundColor = [CLImageEditorTheme toolbarColor];
}

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
        self.imageViewWidth.constant    =   W;
        self.imageViewHeight.constant   =   H;
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
    _scrollView.maximumZoomScale = 0.95*minZoomScale;
    _scrollView.minimumZoomScale = 0.95*minZoomScale;
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:2 animated:animated];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.frame.size.width;
    CGFloat H = _imageView.frame.size.height;
    
    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rct;
}

- (void)refreshToolSettings
{
    for(UIView *sub in self.menuScrollView.subviews){ [sub removeFromSuperview]; }
    
    CGFloat W = 70;
    CGFloat x = 0;

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        W   =   100;
    }

    CGFloat H = self.menuScrollView.height;
    
    int toolCount = 0;
    CGFloat padding = 0;
    
    for(ToolInfo *info in [self editingTools]){
        toolCount++;
    }
    
    CGFloat diff = self.menuScrollView.frame.size.width - toolCount * W;
    if (0<diff && diff<2*W) {
        padding = diff/(toolCount+1);
    }
    
    for(ToolInfo *info in [self editingTools]){
        ToolBarItem *view = [ToolBarItem menuItemWithFrame:CGRectMake(x+padding, 0, W, H) target:self action:@selector(tappedMenuView:) toolInfo:info isIcon:true];
        [self.menuScrollView addSubview:view];
        x += W+padding;
    }
    
    self.menuScrollView.contentSize = CGSizeMake(MAX(x, self.menuScrollView.frame.size.width+1), 0);
    
}

-(NSArray *)editingTools{
    NSMutableArray *toolsArr    =   [NSMutableArray new];
    
    NSArray *tools              =   [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Tools" ofType:@"plist"]];
    
    for(NSDictionary *tolDict in tools){
        ToolInfo *tool          =   [[ToolInfo alloc] init];
        tool.toolId             =   [tolDict objectForKey:@"ToolId"];
        tool.toolName           =   [tolDict objectForKey:@"ToolName"];
        tool.title              =   [tolDict objectForKey:@"Title"];
        tool.iconImage          =   [UIImage imageNamed:[tolDict objectForKey:@"ToolIcon"]];
        [toolsArr addObject:tool];
    }
    
    return toolsArr;
}

- (void)tappedMenuView:(UITapGestureRecognizer*)sender
{
    ToolBarItem *view = (ToolBarItem*) sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    [self setupToolWithToolInfo:view.toolInfo];
}

- (void)setupToolWithToolInfo:(ToolInfo*)info
{
    if(self.currentTool){ return; }
    
    Class toolClass = NSClassFromString(info.toolName);
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[CLImageToolBase class]]){
            instance = [instance initWithImageEditor:self withToolInfo:info];
            self.currentTool = instance;
        }
    }
}

#pragma mark- Tool actions

- (void)setCurrentTool:(CLImageToolBase *)currentTool
{
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
        [self swapToolBarWithEditing:(_currentTool!=nil)];
    }
}

#pragma mark- Menu actions

- (void)swapMenuViewWithEditing:(BOOL)editing
{
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         if(editing){
                             _menuScrollView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuScrollView.top);
                         }
                         else{
                             _menuScrollView.transform = CGAffineTransformIdentity;
                         }
                     }
     ];
}

- (void)swapNavigationBarWithEditing:(BOOL)editing
{
    if(self.navigationController==nil){
        return;
    }
    
    if(editing){
        _navigationBar.hidden = NO;
        _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
        
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -self.navigationController.navigationBar.height-20);
                             _navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
    else{
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
                             _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
                         }
                         completion:^(BOOL finished) {
                             _navigationBar.hidden = YES;
                             _navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
}

- (void)swapToolBarWithEditing:(BOOL)editing
{
    [self swapMenuViewWithEditing:editing];
    [self swapNavigationBarWithEditing:editing];
    
    if(self.currentTool){
        UINavigationItem *item  = [[UINavigationItem alloc] initWithTitle:[self.currentTool.toolInfo.title uppercaseString]];
        
        item.rightBarButtonItem          =   [self buttonWithImageName:[CLImageEditorTheme localizedString:@"CLImageEditor_OKBtnTitle" withDefault:@"OK"] selector:@selector(pushedDoneBtn:)];
        
        item.leftBarButtonItem          =   [self buttonWithImageName:[CLImageEditorTheme localizedString:@"CLImageEditor_BackBtnTitle" withDefault:@"Back"] selector:@selector(pushedCancelBtn:)];
        
        [_navigationBar pushNavigationItem:item animated:(self.navigationController==nil)];
    }
    else{
        [_navigationBar popNavigationItemAnimated:(self.navigationController==nil)];
    }
}

-(void)pushedCancelBtn:(id)send{
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    
    self.currentTool = nil;
}

- (IBAction)pushedDoneBtn:(id)sender
{
    self.view.userInteractionEnabled = NO;
    
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if(error){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(image){
            _originalImage      = image;
            _imageView.image    = image;
            
            [self resetImageViewFrame];
            self.currentTool = nil;
        }
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)pushedCloseBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showAds{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if (self.interstitial) {
//           [self.interstitial presentFromRootViewController:self];
//         } else {
//           NSLog(@"Ad wasn't ready");
//         }
    });
}


- (void)pushedFinishBtn:(UIBarButtonItem *)sender{
    [self showAds];
    
    NSData *pngData = UIImagePNGRepresentation(_imageView.image);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
    NSString* title         =   @"Share";
    NSArray* dataToShare    =   @[title, _imageView.image];
    
    UIActivityViewController* activityViewController =  [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if(completed){
            [self askForReview];
        }
    }];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:^{
        }];
    }
    //if iPad
    else {
        activityViewController.modalPresentationStyle   = UIModalPresentationPopover;
        activityViewController.popoverPresentationController.sourceView = sender;
        
        [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if(completed){
                [self askForReview];
            }
        }];
        
        [self presentViewController:activityViewController animated:YES completion:^{
        }];
    }
}

-(void)askForReview{
    NSUInteger numberOfPhotosEdited   =   [[NSUserDefaults standardUserDefaults] integerForKey:@"PHOTO_EDITED_USER_DEFAULTS_KEY"];
    
    if(numberOfPhotosEdited > 1){
        if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
            [SKStoreReviewController requestReview];
        }
    }
    else{
        [[NSUserDefaults standardUserDefaults] setInteger:numberOfPhotosEdited + 1 forKey:@"PHOTO_EDITED_USER_DEFAULTS_KEY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
