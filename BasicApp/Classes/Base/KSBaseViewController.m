//
//  KSBaseViewController.m
//  KSMovie
//
//  Created by young He on 2018/9/11.
//  Copyright © 2018年 youngHe. All rights reserved.
//

#import "KSBaseViewController.h"
#import "UINavigationController+WXSTransition.h"
#import "KSBaseNavViewController.h"

#import "UIBarButtonItem+Extension.h"
#import "LoginViewController.h"

@interface KSBaseViewController ()

@end

@implementation KSBaseViewController

#define  NAVIBARWIDE                10                         //ios7以后导航栏按钮调整

-(NetErrorOrNoDataView *)dataView {
    if(_dataView == nil) {
        _dataView  = [[NetErrorOrNoDataView alloc]initWithVC:self];
    }return _dataView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNetError = SSNetLoading_state;
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.contentMode = UIViewContentModeBottom;
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter]postNotificationName:Menu_Hidden object:nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:Audio_Pause object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2f animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark--设置导航栏名字
-(UILabel*)setTitleName:(NSString *)name andFont:(CGFloat)fontH
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 140, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:fontH];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = name;
    titleLabel.userInteractionEnabled = YES;
    self.navigationItem.titleView=titleLabel;
    return titleLabel;
}

#pragma mark--设置导航栏按钮
-(UIButton*)setNavButtonImageName:(NSString *)imageName andIsLeft:(BOOL)isLeft andTarget:(id)target andAction:(SEL)selector
{
    self.view.contentMode = UIViewContentModeBottom;
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 40, 40);
    btn.showsTouchWhenHighlighted = YES;
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:isLeft?UIControlContentHorizontalAlignmentLeft:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item=[[UIBarButtonItem alloc]initWithCustomView:btn];
    if(isLeft)
    {
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                           target:nil action:nil];
            negativeSpacer.width = -10;//这个数值可以根据情况自由变化
            self.navigationItem.leftBarButtonItems = @[negativeSpacer, item];
        }else{
            self.navigationItem.leftBarButtonItem = item ;
        }
        
    }else{
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                           target:nil action:nil];
            negativeSpacer.width = -NAVIBARWIDE;//这个数值可以根据情况自由变化
            self.navigationItem.rightBarButtonItems = @[negativeSpacer, item];
        }else{
            self.navigationItem.rightBarButtonItem = item ;
        }
    }
    return btn;
}

-(void)setNoNavBarBackBtn {
    UIButton * backBtn = [[UIButton alloc]init];
    [backBtn setImage:Image_Named(@"back_black") forState:UIControlStateNormal];
    [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [backBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(11);
        make.top.equalTo(self.view).offset(34);
        make.width.mas_equalTo(45.f);
        make.height.mas_equalTo(45.f);
    }];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setPresentVCBackBtn {
    if(iOS11Later) {
        UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.frame = CGRectMake(0, 0, 40, 44);
        [firstButton setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
        [firstButton addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
        firstButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [firstButton setImageEdgeInsets:UIEdgeInsetsMake(0,0, 0, 0)];
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:firstButton];
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }else {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -15;
        //设置导航栏的按钮
        UIBarButtonItem *backButton = [UIBarButtonItem itemWithImageName:@"back_black" highImageName:@"back_black" target:self action:@selector(dissmiss)];
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backButton];
    }
}

-(void)dissmiss{
    [self.view endEditing:YES];
    if([g_App.window.rootViewController isKindOfClass:[UITabBarController class]]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        KSTabBarController * tabBar = [[KSTabBarController alloc]init];
        //        g_App.tabBarVC = tabBar;
        [g_App restoreRootViewController:tabBar];
    }
}

#pragma mark--处理导航栏按钮间距
-(void)resoleBarItemForSpaceWithItem:(UIBarButtonItem *)item andIsLeft:(BOOL)isLeft {
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil action:nil];
        negativeSpacer.width = -NAVIBARWIDE;//这个数值可以根据情况自由变化
        if(isLeft)
        {
            self.navigationItem.leftBarButtonItems = @[negativeSpacer, item];
        }else
        {
            self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
        }
        
    }else{
        if(isLeft){
            self.navigationItem.leftBarButtonItem = item ;
        }else
        {
            self.navigationItem.rightBarButtonItem = item;
        }
    }

}

#pragma mark--跳转操作
-(void)pushController:(KSBaseViewController *)view{
    KSBaseNavViewController * base = (KSBaseNavViewController*)g_App.tabBarVC.selectedViewController;
    view.hidesBottomBarWhenPushed = YES;
    [base pushViewController:view animated:YES];
}

-(void)presentController:(UIViewController *)view
{
    KSBaseNavViewController * base = (KSBaseNavViewController*)g_App.tabBarVC.selectedViewController;
    KSBaseViewController * baseView = (KSBaseViewController*)base.topViewController;
    [baseView presentViewController:view animated:YES completion:nil];
}

#pragma mark--导航栏按钮纯文字
-(UIButton*)setNavWithTitle:(NSString *)title Font:(CGFloat)font andTextColor:(NSString*)color andIsLeft:(BOOL)isLeft andTarget:(id)target andAction:(SEL)selector
{
    UIButton * finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = [Helper widthOfString:title font:KFONT(font) height:12]+10;
    finishBtn.frame = CGRectMake(0, 5,width, 55/2.0);
    [finishBtn setContentHorizontalAlignment:isLeft?UIControlContentHorizontalAlignmentLeft:UIControlContentHorizontalAlignmentRight];
    finishBtn.titleLabel.font = KFONT(font);
    [finishBtn setTitleColor:KCOLOR(color) forState:UIControlStateNormal];
    [finishBtn setTitleColor:KCOLOR(color) forState:UIControlStateSelected];
    [finishBtn setTitle:title forState:UIControlStateNormal];
    [finishBtn setTitle:title forState:UIControlStateSelected];
    if(target&&selector){
        [finishBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
    [self resoleBarItemForSpaceWithItem:barItem andIsLeft:isLeft];
    return finishBtn;
}

-(void)dealloc
{
    SSLog(@"%@%s释放",[self getClassName],__func__);
}

- (NSString *)getClassName {
    return NSStringFromClass([self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--登录
-(void)gotoLogin
{
    LoginViewController * login = [[LoginViewController alloc]init];
    KSBaseNavViewController * nav = [[KSBaseNavViewController alloc]initWithRootViewController:login];
    [self wxs_presentViewController:nav makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType =  WXSTransitionAnimationTypeInsideThenPush;
        transition.backGestureEnable = NO;
        transition.backGestureType = WXSGestureTypePanRight;
    }];
}

-(void)gotoLoginWithComplete:(void(^)(void))complete {
    LoginViewController * login = [[LoginViewController alloc]init];
    KSBaseNavViewController * nav = [[KSBaseNavViewController alloc]initWithRootViewController:login];
    [self wxs_presentViewController:nav makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType =  WXSTransitionAnimationTypeInsideThenPush;
        transition.backGestureEnable = NO;
        transition.backGestureType = WXSGestureTypePanRight;
    } completion:^{
        if(complete)
        {
            complete();
        }
    }];
}

-(void)endRefreshPulling:(UIScrollView *)scrollView {
    if(scrollView.isDragging) {
        [scrollView.mj_header setState:MJRefreshStateIdle];
    }
}

//支持旋转
- (BOOL)shouldAutorotate {
    return NO;
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
