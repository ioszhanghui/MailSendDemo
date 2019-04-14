//
//  ViewController.m
//  MailSendDemo
//
//  Created by 小飞鸟 on 2019/04/13.
//  Copyright © 2019 小飞鸟. All rights reserved.
//

#import "ViewController.h"

#import <MessageUI/MFMailComposeViewController.h>
#import "GMMailManager.h"

@interface ViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    
    UIButton * button2 = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 100)];
    [button2 setTitle:@"发送2" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(sendAction2) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button2];
    
}

-(void)sendAction2{
    
    GMMailManager * shareManager = [GMMailManager shareMailManager];
    shareManager.toRecipients = [NSSet setWithObjects:@"ioszhanghui@163.com", nil];
    shareManager.ccRecipients = [NSSet setWithObjects:@"3140243602@qq.com", nil];
    shareManager.bccRecipients = [NSSet setWithObjects:@"1981510349@qq.com", nil];
    shareManager.messageBody = @"Test a Message ";
    shareManager.filePath = [[NSBundle mainBundle] pathForResource:@"3.png" ofType:nil];
    [shareManager sendEmailContent:@{} Completion:^(NSString * _Nonnull alert) {
        
    }];
    //0x00000001c0092cf0  0x000000010330a560
}

-(void)sendAction{
    
   GMMailManager * shareManager = [GMMailManager shareMailManager];
//    shareManager.toRecipients = [NSSet setWithObjects:@"ioszhanghui@163.com", nil];
//    shareManager.ccRecipients = [NSSet setWithObjects:@"3140243602@qq.com", nil];
//    shareManager.bccRecipients = [NSSet setWithObjects:@"1981510349@qq.com", nil];
//    shareManager.messageBody = @"Test a Message ";
//    shareManager.filePath = [[NSBundle mainBundle] pathForResource:@"3.png" ofType:nil];
    
    NSDictionary * mailContent = @{
                                   @"toRecipients":[NSSet setWithObjects:@"ioszhanghui@163.com", nil],
                                   @"ccRecipients":[NSSet setWithObjects:@"3140243602@qq.com", nil],
                                   @"bccRecipients":[NSSet setWithObjects:@"1981510349@qq.com", nil],
                                   @"messageBody":@"Test a Message ",
                                   @"filePath":[[NSBundle mainBundle] pathForResource:@"3.png" ofType:nil]
                                   };
    [shareManager sendEmailContent:mailContent Completion:^(NSString * _Nonnull alert) {
        
    }];
}

#pragma mark 邮件发送结果
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"邮件已取消发送");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"邮件已保存");
            break;
        case MFMailComposeResultSent:
            NSLog(@"邮件已发送");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"邮件发送失败");
            break;
        default:
            break;
    }
}


@end
