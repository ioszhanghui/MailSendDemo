//
//  GMMailManager.m
//  MailSendDemo
//
//  Created by 小飞鸟 on 2019/04/13.
//  Copyright © 2019 小飞鸟. All rights reserved.
//

#import "GMMailManager.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface GMMailManager ()<MFMailComposeViewControllerDelegate>
/*邮件发送结果回调*/
@property(nonatomic,copy)void(^MailCall)(NSString * alert);

@end

static dispatch_once_t onceToken;

@implementation GMMailManager
+(GMMailManager*)shareMailManager{
    static  GMMailManager * mailManager = nil;
    dispatch_once(&onceToken, ^{
        mailManager =[[GMMailManager alloc]init];
    });
    return mailManager;
}

-(instancetype)init{
    if (self=[super init]) {
        
    }
    return self;
}

 static inline bool isNotNilObject(id obj){
    if ([obj isKindOfClass:[NSString class]]) {
        return obj&&((NSString*)obj).length;
    }else if ([obj isKindOfClass:[NSArray class]]){
       return obj&&((NSArray*)obj).count;
    }else if ([obj isKindOfClass:[NSSet class]]){
         return obj&&((NSSet*)obj).count;
    }else if ([obj isKindOfClass:[NSDictionary class]]){
        return obj&&((NSSet*)obj).count;
    }
    return NO;
}

/*邮件发送*/
-(void)sendEmailContent:(NSDictionary*)mailContent Completion:(void(^)(NSString *alert))completion;{
    _MailCall = completion;
    
    if (isNotNilObject(mailContent)) {
        self.toRecipients = [mailContent objectForKey:@"toRecipients"];
        self.ccRecipients = [mailContent objectForKey:@"ccRecipients"];
        self.bccRecipients = [mailContent objectForKey:@"bccRecipients"];
        self.subject = [mailContent objectForKey:@"subject"];
        self.messageBody = [mailContent objectForKey:@"messageBody"];
        self.filePath = [mailContent objectForKey:@"filePath"];
        self.preferredSEmailAddress = [mailContent objectForKey:@"preferredSEmailAddress"];
    }
        
    if ([MFMailComposeViewController canSendMail]) {
        //苹果自带的邮箱 登录的有账户
        MFMailComposeViewController * mailVC = [[MFMailComposeViewController alloc]init];
        //设置收件人
        [mailVC setToRecipients:[self.toRecipients allObjects]];
        if (isNotNilObject(self.subject)) {
            //设置 主题
            [mailVC setSubject:self.subject];
        }

        if (isNotNilObject(self.ccRecipients)) {
            //设置抄送者
            [mailVC setCcRecipients:[self.ccRecipients allObjects]];
        }
        if (isNotNilObject(self.bccRecipients)) {
            //设置密送者
            [mailVC setBccRecipients:self.bccRecipients.allObjects];
        }
        if (isNotNilObject(self.messageBody)) {
            [mailVC setMessageBody:self.messageBody isHTML:NO];
        }
        if (isNotNilObject(self.preferredSEmailAddress)) {
            if (@available(iOS 11.0, *)) {
                //设置 指定发送账户
                [mailVC setPreferredSendingEmailAddress:self.preferredSEmailAddress];
            }
        }
        BOOL fileExit = [[NSFileManager defaultManager]fileExistsAtPath:self.filePath];
        if (isNotNilObject(self.filePath)&&fileExit) {
            //富文本 Image Video MP3
            NSString * fileName = self.filePath.lastPathComponent;
            //l扩展
            NSString * fileType = self.filePath.pathExtension;
            //文件内容
            NSData * fileData = [[NSData alloc]initWithContentsOfFile:self.filePath];
            [mailVC addAttachmentData:fileData mimeType:fileType fileName:fileName];
        }

        mailVC.mailComposeDelegate = self;
        UIViewController * currentVC =[self getCurrentViewController:[self getRootViewController]];
        [currentVC presentViewController:mailVC animated:YES completion:nil];
    }else{
        //没有设置 发送者
        NSMutableString * mailUrl = [[NSMutableString alloc]init];
        //添加收件人
        if (isNotNilObject(self.toRecipients)) {
            [mailUrl appendFormat:@"mailto:%@", [[self.toRecipients allObjects] componentsJoinedByString:@","]];
        }
        if (isNotNilObject(self.ccRecipients)) {
            //添加抄送
            [mailUrl appendFormat:@"?cc=%@", [[self.ccRecipients allObjects] componentsJoinedByString:@","]];
        }
        if (isNotNilObject(self.bccRecipients)) {
            //添加密送
            [mailUrl appendFormat:@"&bcc=%@", [[self.bccRecipients allObjects] componentsJoinedByString:@","]];
        }
        
        if (isNotNilObject(self.subject)) {
            //添加主题
            [mailUrl appendString:[@"&subject=" stringByAppendingString:self.subject]];
        }
        
        if (isNotNilObject(self.messageBody)) {
             //添加邮件内容
            [mailUrl appendFormat:@"&body=%@",self.messageBody];
        }
       mailUrl = (NSMutableString*)[mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:mailUrl]];
    }
}

/*获取当前 控制器*/
-(UIViewController*)getCurrentViewController:(UIViewController*)VC{
    UIViewController * rootVC = VC;
    if (!rootVC) {
        return nil;
    }
    if ([rootVC isKindOfClass:[UIViewController class]]) {
        if (rootVC.presentingViewController) {
            [self getCurrentViewController:rootVC.presentingViewController];
        }else{
            return rootVC;
        }
    }else if ([rootVC isKindOfClass:[UINavigationController class]]){
        return [rootVC.childViewControllers lastObject];
    }else if ([rootVC isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbarVC = (UITabBarController*)rootVC;
        [self getCurrentViewController:tabbarVC.selectedViewController];
    }
    return nil;
}


/*获取根控制器*/
-(UIViewController*)getRootViewController{
    
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

#pragma mark 邮件发送结果
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    
    NSString * alert = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            alert = @"邮件已取消发送";
            NSLog(@"邮件已取消发送");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"邮件已保存");
            alert = @"邮件已保存";
            break;
        case MFMailComposeResultSent:
            NSLog(@"邮件已发送");
            alert = @"邮件已发送";
            break;
        case MFMailComposeResultFailed:
            NSLog(@"邮件发送失败");
             alert = @"邮件发送失败";
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.MailCall(alert);
    [self clear];
}

#pragma mark 单例清除
-(void)clear{
    onceToken = 0;
}

@end
