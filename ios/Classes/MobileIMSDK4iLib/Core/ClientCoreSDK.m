#import "ClientCoreSDK.h"
#import "ChatMessageEvent.h"
#import "ChatBaseEvent.h"
#import "MessageQoSEvent.h"
#import "Reachability.h"

#import "QoS4SendDaemon.h"
#import "KeepAliveDaemon.h"
#import "LocalDataReciever.h"
#import "LocalSocketProvider.h"
#import "QoS4ReciveDaemon.h"
#import "AutoReLoginDaemon.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 静态全局类变量
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static BOOL ENABLED_DEBUG = NO;
static BOOL autoReLogin = YES;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 私有API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ClientCoreSDK ()

@property (nonatomic) BOOL _init;
@property (nonatomic) Reachability *internetReachability;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 本类的代码实现
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ClientCoreSDK

static ClientCoreSDK *instance = nil;

+ (ClientCoreSDK *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (BOOL) isENABLED_DEBUG
{
    return ENABLED_DEBUG;
}
+ (void) setENABLED_DEBUG:(BOOL)enabledDebug
{
    ENABLED_DEBUG = enabledDebug;
}

+ (BOOL) isAutoReLogin
{
    return autoReLogin;
}
+ (void) setAutoReLogin:(BOOL)arl
{
    autoReLogin = arl;
}

- (id)init
{
    if (![super init])
        return nil;
    
//    NSLog(@"ClientCoreSDK已经init了！");
    
//    // 内部变量初始化
//    [self initCore];
    
    return self;
}

- (void)initCore
{
    if(!self._init)
    {
        // 变量初始化
//      self.localDeviceNetworkOk = NO;
        self.connectedToServer = NO;
        self.loginHasInit = NO;
        
        if(self.internetReachability == nil)
        {
            /*
             Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
             */
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
            self.internetReachability = [Reachability reachabilityForInternetConnection];
        }
        [self.internetReachability startNotifier];
        // 本地网络状态初始化
//      self.localDeviceNetworkOk = [self internetReachable];
        
        self._init = YES;
        
        NSLog(@"ClientCoreSDK已经完成initCore了！");
    }
}

- (void) releaseCore
{
    [[AutoReLoginDaemon sharedInstance] stop]; // 2014-11-08 add by Jack Jiang
    [[QoS4SendDaemon sharedInstance] stop];
    [[KeepAliveDaemon sharedInstance] stop];
//    [[LocalUDPDataReciever sharedInstance] stop];
    [[QoS4ReciveDaemon sharedInstance] stop];
    [[LocalSocketProvider sharedInstance] closeLocalSocket];

    //## Bug FIX: 20180103 by Jack Jiang START
    [[QoS4SendDaemon sharedInstance] clear];
    [[QoS4ReciveDaemon sharedInstance] clear];
    //## Bug FIX: 20180103 by Jack Jiang END

    [self.internetReachability stopNotifier];
    
    self._init = NO;
    self.loginHasInit = NO;
    self.connectedToServer = NO;
}


#pragma mark -  公开的方法

- (BOOL) isInitialed
{
    return self._init;
}

- (BOOL)internetReachable
{
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    return netStatus == ReachableViaWWAN || netStatus == ReachableViaWiFi;
}

/*
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* reachability = [note object];
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = NSLocalizedString(@"【IMCORE-TCP】【本地网络通知】检测本地网络连接断开了!", @"Text field text for access is not available");
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            
//          self.localDeviceNetworkOk = false;
            [[LocalSocketProvider sharedInstance] closeLocalSocket];
            
            break;
        }
            
        case ReachableViaWWAN: // 蜂窝网络、3G网络等
        case ReachableViaWiFi: // WIFI
        {
            int wifi = (netStatus == ReachableViaWiFi);
            statusString= [NSString stringWithFormat:NSLocalizedString(@"【IMCORE-TCP】【本地网络通知】检测本地网络已连接上了! WIFI? %d", @""), wifi?@"YES":@"NO"];
            
//          self.localDeviceNetworkOk = true;
            [[LocalSocketProvider sharedInstance] closeLocalSocket];
            
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"【IMCORE-TCP】%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString = [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    
    if(ENABLED_DEBUG)
        NSLog(@"%@", statusString);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
