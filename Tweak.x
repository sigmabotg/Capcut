#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wobjc-method-access"

#import <UIKit/UIKit.h>

static BOOL hasShownNotice = NO;

// ============================================================
// 1. NSUSERDEFAULTS
// ============================================================
%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)key {
    NSArray *proKeys = @[
        @"isPro", @"hasPro", @"proUser", @"isProUser", @"hasProAccess",
        @"isPremium", @"hasPremium", @"premiumUser", @"isPremiumUser",
        @"isVip", @"hasVip", @"vipUser", @"isVipUser", @"hasVipAccess",
        @"isSubscribed", @"hasSubscription", @"subscriptionActive",
        @"isTrial", @"inTrial", @"trialActive", @"isTrialUser",
        @"isStandard", @"hasStandard", @"standardUser",
        @"isUnlocked", @"hasUnlocked", @"unlockedUser"
    ];
    for (NSString *k in proKeys) {
        if ([key.lowercaseString containsString:k]) {
            return YES;
        }
    }
    return %orig;
}

- (id)objectForKey:(NSString *)key {
    if ([key containsString:@"subscription"] || 
        [key containsString:@"purchase"] || 
        [key containsString:@"receipt"] ||
        [key containsString:@"pro"] ||
        [key containsString:@"premium"] ||
        [key containsString:@"vip"] ||
        [key containsString:@"trial"]) {
        return @{
            @"status": @"active",
            @"expiry": @"2099-12-31",
            @"plan": @"pro",
            @"is_trial": @NO,
            @"is_pro": @YES,
            @"is_premium": @YES,
            @"is_vip": @YES
        };
    }
    return %orig;
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    NSArray *forceKeys = @[@"pro", @"premium", @"vip", @"unlock", @"trial", @"standard"];
    for (NSString *k in forceKeys) {
        if ([key.lowercaseString containsString:k]) {
            %orig(YES, key);
            return;
        }
    }
    %orig;
}
%end  // <--- 1

// ============================================================
// 2. CAPCUT PRO MANAGER
// ============================================================
%hook CapCutProManager

- (BOOL)isProUser { return YES; }
- (BOOL)hasProFeatures { return YES; }
- (BOOL)isPremiumUnlocked { return YES; }
- (BOOL)isVipUser { return YES; }
- (BOOL)isStandardUser { return YES; }
- (int)getUserTier { return 2; }
%end  // <--- 2

// ============================================================
// 3. SUBSCRIPTION MANAGER
// ============================================================
%hook SubscriptionManager

- (BOOL)hasActiveSubscription { return YES; }
- (BOOL)isSubscribed { return YES; }
- (BOOL)inTrialPeriod { return YES; }
- (BOOL)isTrialExpired { return NO; }
- (int)trialDaysRemaining { return 3650; }
- (id)getSubscriptionInfo {
    return @{
        @"status": @"active",
        @"plan": @"pro",
        @"expiry": @"2099-12-31",
        @"is_trial": @NO,
        @"trial_used": @NO,
        @"trial_expired": @NO,
        @"days_remaining": @3650
    };
}
%end  // <--- 3

// ============================================================
// 4. VIDEO EXPORT
// ============================================================
%hook VideoExportManager

- (BOOL)canExport4K { return YES; }
- (BOOL)canExport60fps { return YES; }
- (BOOL)canRemoveWatermark { return YES; }
- (BOOL)canExportHDR { return YES; }
%end  // <--- 4

// ============================================================
// 5. EFFECT MANAGER
// ============================================================
%hook EffectManager

- (BOOL)hasAccessToProEffects { return YES; }
- (BOOL)isEffectUnlocked:(id)effect { return YES; }
- (BOOL)canUseProFilter:(id)filter { return YES; }
%end  // <--- 5

// ============================================================
// 6. TEMPLATE MANAGER
// ============================================================
%hook TemplateManager

- (BOOL)hasAccessToProTemplates { return YES; }
- (BOOL)isTemplateUnlocked:(id)template { return YES; }
%end  // <--- 6

// ============================================================
// 7. AI MANAGER
// ============================================================
%hook AIManager

- (BOOL)hasAccessToAI { return YES; }
- (BOOL)canUseAITools { return YES; }
%end  // <--- 7

// ============================================================
// 8. SKPAYMENTQUEUE
// ============================================================
%hook SKPaymentQueue

+ (BOOL)canMakePayments { return YES; }
%end  // <--- 8

// ============================================================
// 9. NSBUNDLE
// ============================================================
%hook NSBundle

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key containsString:@"Receipt"] || [key containsString:@"receipt"]) {
        return @"valid";
    }
    return %orig;
}
%end  // <--- 9

// ============================================================
// 10. UIAPPLICATION
// ============================================================
%hook UIApplication

- (BOOL)canOpenURL:(NSURL *)url {
    if ([url.scheme containsString:@"cydia"] || [url.scheme containsString:@"sileo"]) {
        return NO;
    }
    return %orig;
}
%end  // <--- 10

// ============================================================
// 11. NSFILEMANAGER
// ============================================================
%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
    NSArray *jailbreakPaths = @[@"/Applications/Cydia.app", @"/Applications/Sileo.app"];
    for (NSString *jp in jailbreakPaths) {
        if ([path isEqualToString:jp]) return NO;
    }
    return %orig;
}
%end  // <--- 11

// ============================================================
// 12. APPSDELEGATE
// ============================================================
%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    if (!hasShownNotice) {
        hasShownNotice = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            if (window) {
                UIAlertController *alert = [UIAlertController 
                    alertControllerWithTitle:@"CapCut Pro" 
                    message:@"✅ Pro Features Unlocked!\n\n✅ 4K Export\n✅ 60fps\n✅ No Watermark\n✅ Pro Effects\n✅ Pro Templates\n✅ AI Tools\n\n🚀 Enjoy!" 
                    preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [window.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
    }
    return result;
}
%end  // <--- 12

// ============================================================
// 13. CTOR - KHỞI TẠO
// ============================================================
%ctor {
    NSLog(@"=========================================");
    NSLog(@"🚀 CapCut Pro Unlock Loaded!");
    NSLog(@"✅ Pro Features: YES");
    NSLog(@"✅ Standard Features: YES");
    NSLog(@"✅ Trial: EXTENDED");
    NSLog(@"=========================================");
}
// <--- KHÔNG CÓ %END Ở ĐÂY
