//
//  RACLoginViewController.m
//  ToolBox
//
//  Created by ZRBhy on 16/12/13.
//  Copyright © 2016年 NotHY. All rights reserved.
//

#import "RACLoginViewController.h"
#import "loginViewModel.h"

@interface RACLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *juhuaView;

@property (strong, nonatomic) loginViewModel *viewModel;

@end

@implementation RACLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.juhuaView.hidden = YES;
    _viewModel = [[loginViewModel alloc]init];
    
    @weakify(self)
    RAC(self.viewModel, userName) = self.userNameTF.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordTF.rac_textSignal;
    self.loginBtn.rac_command = self.viewModel.loginCommand;
    [[self.viewModel.loginCommand executionSignals]
     subscribeNext:^(RACSignal *x) {
         @strongify(self)
         self.juhuaView.hidden = NO;
         [x subscribeNext:^(NSString *x) {
             self.juhuaView.hidden = YES;
             NSLog(@"%@",x);
         }];
     }];
    
}

@end
