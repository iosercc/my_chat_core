#import "MyChatCorePlugin.h"

@implementation MyChatCorePlugin{
    FlutterEventSink _eventSink;
  }

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    MyChatCorePlugin* instance = [[MyChatCorePlugin alloc] init];
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"my_chat_core"
            binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:channel];
    FlutterEventChannel* streamChannel =
         [FlutterEventChannel eventChannelWithName:@"my_chat_core_status"
                                   binaryMessenger:[registrar messenger]];
    [streamChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *dic = call.arguments;
    @try {
        if ([@"getPlatformVersion" isEqualToString:call.method]) {
          result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        } else  if ([@"init" isEqualToString:call.method]) {
            [self initWithIP:dic[@"ip"] andContent:[dic[@"port"] intValue]];
          result(@true);
        } else  if ([@"login" isEqualToString:call.method]) {
          int code = [[LocalDataSender sharedInstance] sendLogin:dic[@"name"]  withToken:dic[@"token"] ];
          result([NSNumber numberWithInt:code]);
        } else  if ([@"loginOut" isEqualToString:call.method]) {
            int code = [[LocalDataSender sharedInstance] sendLoginout];
            [[ClientCoreSDK sharedInstance] releaseCore];
            self._init = NO;
            // 清空设置的回调
            [ClientCoreSDK sharedInstance].chatBaseEvent = nil;
            [ClientCoreSDK sharedInstance].chatMessageEvent = nil;
            [ClientCoreSDK sharedInstance].messageQoSEvent = nil;
            result([NSNumber numberWithInt:code]);
        } else  if ([@"sendMassage" isEqualToString:call.method]) {
          [[LocalDataSender sharedInstance] sendCommonDataWithStr:dic[@"message"] toUserId:dic[@"uid"] qos:true fp:dic[@"fingerId"] withTypeu:[dic[@"type"] intValue]];
          result(@true);
        } else{
          result(FlutterMethodNotImplemented);
        }
    } @catch (NSException *exception) {
        result(@false);
    } @finally {
         
    }
  
}
/**
 * IM框架初始化方法，本方法在退出APP前必须被调用1次，否则IM底层框架将无法工作。
 */
- (void)initWithIP:(NSString *)ip andContent:(int )port
{
    if(!self._init)
    {
        [ConfigEntity setServerIp:ip];
        [ConfigEntity setServerPort:port];
        
        [ClientCoreSDK sharedInstance].chatBaseEvent = self;
        [ClientCoreSDK sharedInstance].chatMessageEvent = self;
        [ClientCoreSDK sharedInstance].messageQoSEvent = self;
  
        self._init = YES;
    }
}


#pragma mark IM相关回调

/*!
 @Override
* 本地用户的登陆结果回调事件通知。
*
* @param errorCode 服务端反馈的登录结果：0 表示登陆成功，否则为服务端自定义的出错代码（按照约定通常为>=1025的数）
*/
- (void) onLoginResponse:(int)errorCode{
    @try {
        NSDictionary *dic = @{@"fun":@"onLoginResponse",@"code":[NSNumber numberWithInt:errorCode]};
        _eventSink(dic);
    } @catch (NSException *exception) {
        _eventSink(@{@"fun":@"onLoginResponse"});
    } @finally {
         
    }
    
}
/*!
 @Override
* 与服务端的通信断开的回调事件通知。
*
* <br>
* 该消息只有在客户端连接服务器成功之后网络异常中断之时触发。
* 导致与与服务端的通信断开的原因有（但不限于）：无线网络信号不稳定、WiFi与2G/3G/4G等同开情
* 况下的网络切换、手机系统的省电策略等。
*
* @param errorCode 本回调参数表示表示连接断开的原因，目前错误码没有太多意义，仅作保留字段，目前通常为-1
*/
- (void) onLinkClose:(int)errorCode{
    @try {
        NSDictionary *dic = @{@"fun":@"onLinkClose",@"code":[NSNumber numberWithInt:errorCode]};
        _eventSink(dic);
    } @catch (NSException *exception) {
        _eventSink(@{@"fun":@"onLinkClose"});
    } @finally {
         
    }
}
/*!
 @Override
* 收到普通消息的回调事件通知。
* <br>
* 应用层可以将此消息进一步按自已的IM协议进行定义，从而实现完整的即时通信软件逻辑。
*
* @param fingerPrintOfProtocal 当该消息需要QoS支持时本回调参数为该消息的特征指纹码，否则为null
* @param userid 消息的发送者id（RainbowCore框架中规定发送者id=“0”即表示是由服务端主动发过的，否则表示的是其它客户端发过来的消息）
* @param dataContent 消息内容的文本表示形式
 map.put("fun", "onRecieveMessage");
            map.put("fingerId", fingerId);
            map.put("userId", userId);
            map.put("dataContent", dataContent);
            map.put("type", type);
*/
- (void) onRecieveMessage:(NSString *)fingerPrintOfProtocal withUserId:(NSString *)userid andContent:(NSString *)dataContent andTypeu:(int)typeu
{
    @try {
        NSDictionary *dic = @{@"fun":@"onRecieveMessage",@"fingerId":fingerPrintOfProtocal  == nil ? @"" : fingerPrintOfProtocal,
                              @"userId":userid  == nil ? @"" : userid,
                              @"dataContent":dataContent  == nil ? @"" : dataContent,
                              @"type":[NSNumber numberWithInt:typeu],
        };
        _eventSink(dic);
    } @catch (NSException *exception) {
        _eventSink(@{@"fun":@"onRecieveMessage"});
    } @finally {
         
    }
}
/*!
 @Override
* 服务端反馈的出错信息回调事件通知。
*
* @param errorCode 错误码，定义在常量表 ErrorCode 中有关服务端错误码的定义
* @param errorMsg 描述错误内容的文本信息
* @see ErrorCode
*/
- (void) onErrorResponse:(int)errorCode withErrorMsg:(NSString *)errorMsg
{
    @try {
        NSDictionary *dic = @{@"fun":@"onErrorResponse",@"errorCode":[NSNumber numberWithInt:errorCode],@"errorMsg": errorMsg == nil ? @"" : errorMsg};
        _eventSink(dic);
    } @catch (NSException *exception) {
        _eventSink(@{@"fun":@"onErrorResponse"});
    } @finally {
         
    }
}
/**
 * MobileIMSDK框架的消息未送达的回调事件通知.
 * <p>
 * 发生场景：比如用户刚发完消息但网络已经断掉了的情况下，表现形式：就像手机qq或微信一样
 * 消息气泡边上会出现红色图标以示没有发送成功）.
 * </p>
 *
 * @param lostMessages 由MobileIMSDK QoS算法判定出来的未送达消息列表（此列表
 * 中的Protocal对象是原对象的clone（即原对象的深拷贝），请放心使用哦），应用层
 * 可通过指纹特征码找到原消息并可以UI上将其标记为”发送失败“以便即时告之用户
 */
- (void) messagesLost:(NSMutableArray*)lostMessages
{
    @try {
        NSDictionary *dic = @{@"fun":@"onErrorResponse",@"arrayList":lostMessages == nil ? @"" : lostMessages};
        _eventSink(dic);
    } @catch (NSException *exception) {
        _eventSink(@{@"fun":@"onErrorResponse"});
    } @finally {
         
    }
}

/**
 * MobileIMSDK框架的消息已被对方收到的回调事件通知.
 * <p>
 * <b>目前，判定消息被对方收到是有两种可能：</b><br>
 * 1) 对方确实是在线并且实时收到了；<br>
 * 2) 对方不在线或者服务端转发过程中出错了，由服务端进行离线存储成功后的反馈
 * （此种情况严格来讲不能算是“已被收到”，但对于应用层来说，离线存储了的消息
 * 原则上就是已送达了的消息：因为用户下次登陆时肯定能通过HTTP协议取到）。
 *
 * @param theFingerPrint 已被收到的消息的指纹特征码（唯一ID），应用层可据此ID
 * 来找到原先已发生的消息并可在UI是将其标记为”已送达“或”已读“以便提升用户体验
 */
- (void) messagesBeReceived:(NSString *)theFingerPrint
{
    @try {
        NSDictionary *dic = @{@"fun":@"messagesBeReceived",@"message":theFingerPrint == nil ? @"" : theFingerPrint};
        _eventSink(dic);
    } @catch (NSException *exception) {
        _eventSink(@{@"fun":@"messagesBeReceived"});
    } @finally {
         
    }
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    
  _eventSink = nil;
  return nil;
}
@end
