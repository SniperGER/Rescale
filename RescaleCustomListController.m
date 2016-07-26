#include "RescaleCustomListController.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/ml.festival.rescale.plist"

@implementation RescaleCustomListController
int height;
int width;

extern NSString* PSDeletionActionKey;

NSDictionary *prefs;

- (NSArray *)specifiers {
    NSMutableArray *specifiers = [[NSMutableArray alloc] init];
    
    CFStringRef appID = CFSTR("ml.festival.rescale");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    if (keyList) {
        prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        int numCustoms = [prefs[@"count"] intValue];
        for (int i=1; i<=numCustoms; i++) {
            NSString *name = [NSString stringWithFormat:@"%@x%@", [prefs objectForKey:[NSString stringWithFormat:@"custom%d-x", i]], [prefs objectForKey:[NSString stringWithFormat:@"custom%d-y", i]]];
            SEL newMethod = NSSelectorFromString([NSString stringWithFormat:@"custom%d", i]);
            class_addMethod([self class], newMethod, (IMP) applyCustomResolution, "v@:");
            PSSpecifier* specCustomNew = [PSSpecifier preferenceSpecifierNamed:name
                                                                        target:self
                                                                           set:NULL
                                                                           get:NULL
                                                                        detail:Nil
                                                                          cell:PSLinkCell
                                                                          edit:Nil];
            specCustomNew->action = newMethod;
            [specCustomNew setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
            [specifiers addObject:specCustomNew];
        }
        
        if ([specifiers count] < 1) {
            [specifiers addObject:[self returnZeroCustomEntries]];
        }
    } else {
        [specifiers addObject:[self returnZeroCustomEntries]];
    }
    if (!_specifiers) {
        _specifiers = [[NSArray arrayWithArray:specifiers] retain];
        //_specifiers = [[self loadSpecifiersFromPlistName:@"CustomList" target:self] retain];
    }
    
    return _specifiers;
}

-(PSSpecifier*)returnZeroCustomEntries {
    PSSpecifier* noEntrySpecifier = [PSSpecifier preferenceSpecifierNamed:[[self getLocalization] objectForKey:@"CUSTOM_NO_ENTRY"]
                                                                target:self
                                                                   set:NULL
                                                                   get:NULL
                                                                detail:Nil
                                                                  cell:PSStaticTextCell
                                                                  edit:Nil];
    return noEntrySpecifier;
}

-(NSDictionary*)getLocalization {
    NSString* langKey = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSDictionary* langDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/Rescale.bundle/%@.lproj/Localizable.strings", langKey]];
    
    if (![langDict objectForKey:@"MESSAGE_CONFIRM"]) {
        langDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/Rescale.bundle/%@.lproj/Localizable.strings", @"en"]];
    }
    return langDict;
}

-(void)confirmRescale {
    [self.view endEditing:YES];

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

void applyCustomResolution(id self, SEL _cmd) {
    NSString *methodName = NSStringFromSelector(_cmd);
    width = [[prefs objectForKey:[NSString stringWithFormat:@"%@-x", methodName]] intValue];
    height = [[prefs objectForKey:[NSString stringWithFormat:@"%@-y", methodName]] intValue];
    [self confirmRescale];
}

-(void)removedSpecifier:(PSSpecifier*)specifier{
    int count = [[prefs objectForKey:@"count"] intValue];
    NSString *name = NSStringFromSelector(specifier->action);
    int number;
    number = [[name substringFromIndex:6] intValue];
    for (int i=number+1; i<=count; i++) {
        NSString *customVal = [NSString stringWithFormat:@"custom%d-x", i];
        int resNumber = [[prefs objectForKey:customVal] intValue];
        customVal = [NSString stringWithFormat:@"custom%d-x", i-1];
        CFPreferencesSetAppValue ( (__bridge CFStringRef)customVal, (__bridge CFNumberRef)[NSNumber numberWithInt:resNumber], CFSTR("ml.festival.rescale") );
        customVal = [NSString stringWithFormat:@"custom%d-y", i];
        resNumber = [[prefs objectForKey:customVal] intValue];
        customVal = [NSString stringWithFormat:@"custom%d-y", i-1];
        CFPreferencesSetAppValue ( (__bridge CFStringRef)customVal, (__bridge CFNumberRef)[NSNumber numberWithInt:resNumber], CFSTR("ml.festival.rescale") );
    }
    count--;
    CFPreferencesSetAppValue ( CFSTR("count"), (__bridge CFNumberRef)[NSNumber numberWithInt:count], CFSTR("ml.festival.rescale") );
    CFStringRef appID = CFSTR("ml.festival.rescale");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
    [self reloadSpecifiers];
}

@end