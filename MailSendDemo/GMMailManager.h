//
//  GMMailManager.h
//  MailSendDemo
//
//  Created by 小飞鸟 on 2019/04/13.
//  Copyright © 2019 小飞鸟. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMMailManager : NSObject
/*发送邮件的单例类*/
@property(class,nonatomic,readonly)GMMailManager * shareMailManager;
/*接收者集合*/
@property(nonatomic,strong) NSSet *toRecipients;
/*抄送者者集合*/
@property(nonatomic,strong) NSSet *ccRecipients;
/*密送者者集合*/
@property(nonatomic,strong) NSSet *bccRecipients;
/*消息题*/
@property(nonatomic,copy)NSString * messageBody;
/*邮件主题*/
@property(nonatomic,copy)NSString * subject;
/*文件路径 主要是 针对发送 Image Video MP3*/
@property(nonatomic,strong)NSString * filePath;
/*邮件 优先使用的邮箱*/
@property(nonatomic,copy)NSString * preferredSEmailAddress;


/*邮件发送*/
-(void)sendEmailContent:(NSDictionary*)mailContent Completion:(void(^)(NSString *alert))completion;

@end

NS_ASSUME_NONNULL_END
