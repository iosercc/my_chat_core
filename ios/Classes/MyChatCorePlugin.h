#import <Flutter/Flutter.h>
#import "ChatBaseEvent.h"
#import "ChatMessageEvent.h"
#import "MessageQoSEvent.h"
#import "LocalDataSender.h"
#import "ConfigEntity.h"
#import "ClientCoreSDK.h"

@interface MyChatCorePlugin : NSObject<FlutterPlugin,FlutterStreamHandler,ChatBaseEvent,ChatMessageEvent,MessageQoSEvent>
/* MobileIMSDK是否已被初始化. true表示已初化完成，否则未初始化. */
@property (nonatomic) BOOL _init;
@end
