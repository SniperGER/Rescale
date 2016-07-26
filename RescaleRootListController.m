#include "RescaleRootListController.h"

#define DEVICE_TYPE    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@implementation RescaleRootListController
int height;
int width;

NSDictionary *prefs;

- (NSArray *)specifiers {
    CFStringRef appID = CFSTR("ml.festival.rescale");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    
	}

    //NSURL* pluginLocation = [[NSURL fileURLWithPath:] URLByResolvingSymlinksInPath];
    //NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
    
	return _specifiers;
}

-(NSDictionary*)getLocalization {
    NSString* langKey = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSDictionary* langDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/Rescale.bundle/%@.lproj/Localizable.strings", langKey]];
    
    if (![langDict objectForKey:@"MESSAGE_CONFIRM"]) {
        langDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/Rescale.bundle/%@.lproj/Localizable.strings", @"en"]];
    }
    return langDict;
}

-(NSString*)machineName {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
}

/* iPhone 4s (3.5 inch) */
-(void)set35inch {
    if ( DEVICE_TYPE == IPAD ) {
        width = 0;
        height = 0;
        [self showUserIsUsingiPad];
    } else {
        width = 640;
        height = 960;
        [self confirmRescale];
    }
}

/* iPhone 5/5s/5c (4 inch) */
-(void)set4inch {
    if ( DEVICE_TYPE == IPAD ) {
        width = 0;
        height = 0;
        [self showUserIsUsingiPad];
    } else {
        width = 640;
        height = 1136;
        [self confirmRescale];
    }
}

/* iPhone 6/6s (4.7 inch) */
-(void)set47inch {
    if ( DEVICE_TYPE == IPAD ) {
        width = 0;
        height = 0;
        [self showUserIsUsingiPad];
    } else {
        width = 750;
        height = 1334;
        [self confirmRescale];
    }
}

/* iPhone 6 Plus/6s Plus (5.5 inch) */
-(void)set55inch {
    if ( DEVICE_TYPE == IPAD ) {
        width = 0;
        height = 0;
        [self showUserIsUsingiPad];
    } else {
        width = 827;
        height = 1472;
        [self confirmRescale];
    }
}

/* iPad 2/iPad mini (9.7 inch) */
-(void)set97inch {
    if ( DEVICE_TYPE == IPAD ) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] >= 2.0) {
            width = 0;
            height = 0;
            [self showUserIsUsingiPadRetina];
        } else {
            width = 768;
            height = 1024;
            [self confirmRescale];
        }
    } else {
        width = 0;
        height = 0;
        [self showUserIsUsingiPhone];
    }
}

/* iPad Retina (9.7 inch) */
-(void)set97inch_retina {
    if ( DEVICE_TYPE == IPAD ) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] >= 2.0) {
            width = 1536;
            height = 2048;
            [self confirmRescale];
        } else {
            width = 0;
            height = 0;
            [self showUserIsUsingiPadNonRetina];
        }
    } else {
        width = 0;
        height = 0;
        [self showUserIsUsingiPhone];
    }
}

/* iPad Pro (12.9 inch) */
- (void)set129inch {
    if ( DEVICE_TYPE == IPAD ) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] >= 2.0) {
            width = 2048;
            height = 2731;
            
            // Detect iPad Pro
            
            if ([[self machineName] isEqualToString:@"iPad6,7"] || [[self machineName] isEqualToString:@"iPad6,8"]) {
                height = 2732;
            }
            [self confirmRescale];
        } else {
            width = 0;
            height = 0;
            [self showUserIsUsingiPadNonRetina];
        }
    } else {
        width = 0;
        height = 0;
        [self showUserIsUsingiPhone];
    }
}

/* Custom Resolution */

-(void)setYValue:(id)value {
    height = [value intValue];
}
-(id)getYValue {
    return height ? [NSNumber numberWithInt:height] : nil;
}
-(void)setXValue:(id)value {
    width = [value intValue];
}
-(id)getXValue {
    return width ? [NSNumber numberWithInt:width] : nil;
}

/* Error Messages */
-(void)showUserIsUsingiPadRetina {
    UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                           message:[[self getLocalization] objectForKey:@"ERROR_IPAD_NO_RETINA"]
                                                          delegate:nil
                                                 cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                 otherButtonTitles:nil];
    [alert_Dialog show];
    [alert_Dialog release];
    return;
}

-(void)showUserIsUsingiPadNonRetina {
    UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                           message:[[self getLocalization] objectForKey:@"ERROR_IPAD_RETINA"]
                                                          delegate:nil
                                                 cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                 otherButtonTitles:nil];
    [alert_Dialog show];
    [alert_Dialog release];
    return;
}

-(void)showUserIsUsingiPad {
    UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                           message:[[self getLocalization] objectForKey:@"ERROR_IPHONE"]
                                                          delegate:nil
                                                 cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                 otherButtonTitles:nil];
    [alert_Dialog show];
    [alert_Dialog release];
    return;
}

-(void)showUserIsUsingiPhone {
    UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                           message:[[self getLocalization] objectForKey:@"ERROR_IPAD"]
                                                          delegate:nil
                                                 cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                 otherButtonTitles:nil];
    [alert_Dialog show];
    [alert_Dialog release];
    return;
}

/* Confirm Dialog */
-(void)confirmRescale {
    [self.view endEditing:YES];
    if (width == 0 || height == 0 || !height || !width) {
        UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                               message:[[self getLocalization] objectForKey:@"ERROR_VALUES_EMPTY"]
                                                              delegate:nil
                                                     cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                     otherButtonTitles:nil];
        [alert_Dialog show];
        [alert_Dialog release];
        return;
    } else if (width < 640 || height < 960 || width > 2048 || height > 2732) {
        UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                               message:[[self getLocalization] objectForKey:@"ERROR_VALUES_INVALID"]
                                                              delegate:nil
                                                     cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                     otherButtonTitles:nil];
        [alert_Dialog show];
        [alert_Dialog release];
        return;
    }
    UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                           message:[NSString stringWithFormat:[[self getLocalization] objectForKey:@"MESSAGE_CONFIRM"], width, height]
                                                          delegate:self
                                                 cancelButtonTitle:[[self getLocalization] objectForKey:@"MESSAGE_CONFIRM_CANCEL"]
                                                 otherButtonTitles:nil];
    [alert_Dialog addButtonWithTitle:[[self getLocalization] objectForKey:@"MESSAGE_CONFIRM_PROCEED"]];
    [alert_Dialog show];
    [alert_Dialog release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        CGSize size = CGSizeMake(width, height);
        [PSMagnifyController commitMagnifyMode:[PSMagnifyMode magnifyModeWithSize:size name:@"" localizedName:@"" isZoomed:1]];
    }
}

/* Create new custom resolution */
- (void)createNewResolution {
    [self.view endEditing:YES];
    
    if (width == 0 || height == 0 || !height || !width) {
        UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                               message:[[self getLocalization] objectForKey:@"ERROR_VALUES_EMPTY"]
                                                              delegate:nil
                                                     cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                     otherButtonTitles:nil];
        [alert_Dialog show];
        [alert_Dialog release];
        return;
    } else if (width < 640 || height < 960 || width > 2048 || height > 2732) {
        UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                               message:[[self getLocalization] objectForKey:@"ERROR_VALUES_INVALID"]
                                                              delegate:nil
                                                     cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                     otherButtonTitles:nil];
        [alert_Dialog show];
        [alert_Dialog release];
        return;
    }
    
    int count = [[prefs objectForKey:@"count"] intValue];
    count++;
    NSString *customVal = [NSString stringWithFormat:@"custom%d-x", count];
    CFPreferencesSetAppValue ( (__bridge CFStringRef)customVal, (__bridge CFNumberRef)[NSNumber numberWithInt:width], CFSTR("ml.festival.rescale") );
    customVal = [NSString stringWithFormat:@"custom%d-y", count];
    CFPreferencesSetAppValue ( (__bridge CFStringRef)customVal, (__bridge CFNumberRef)[NSNumber numberWithInt:height], CFSTR("ml.festival.rescale") );
    CFPreferencesSetAppValue ( CFSTR("count"), (__bridge CFNumberRef)[NSNumber numberWithInt:count], CFSTR("ml.festival.rescale") );

    
    UIAlertView* alert_Dialog = [[UIAlertView alloc] initWithTitle:@"Re:Scale"
                                                           message:[NSString stringWithFormat:[[self getLocalization] objectForKey:@"CUSTOM_VALUES_SAVED"], width, height]
                                                          delegate:nil
                                                 cancelButtonTitle:[[self getLocalization] objectForKey:@"ERROR_OK"]
                                                 otherButtonTitles:nil];
    [alert_Dialog show];
    [alert_Dialog release];
    return;
}



@end
