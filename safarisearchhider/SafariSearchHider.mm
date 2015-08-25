#import <Preferences/Preferences.h>
#import <Preferences/PSListController.h>

NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.safarisearchhider.plist";

@interface SafariSearchHiderListController: PSEditableListController
@end

@interface SafariSearchHiderRegex : PSListController {
    int index;
    NSMutableArray *regexes;
}
@end

extern NSString *PSDeletionActionKey;

@implementation SafariSearchHiderListController
-(id)specifiers {
    if(_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray array];

        PSSpecifier* group = [PSSpecifier preferenceSpecifierNamed:@"Regexes"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSGroupCell
            edit:Nil];
        [specs addObject:group];

        NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];

        for (int i = 0; i < [regexes count]; i++) {
            PSSpecifier* tempSpec = [PSSpecifier preferenceSpecifierNamed:regexes[i][2]
                                                  target:self
                                                     set:NULL
                                                     get:NULL
                                                  detail:NSClassFromString(@"SafariSearchHiderRegex")
                                                    cell:PSLinkCell
                                                    edit:Nil];
            [tempSpec setProperty:@(i) forKey:@"arrayIndex"];
            [tempSpec setProperty:NSStringFromSelector(@selector(deleteRegex:)) forKey:PSDeletionActionKey];
            [specs addObject:tempSpec];
        }

        //initialize add button
        PSSpecifier* button = [PSSpecifier preferenceSpecifierNamed:@"Add Regex"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSButtonCell
            edit:Nil];
        [button setButtonAction:@selector(addRegex)];
        [button setProperty:[UIImage imageNamed:@"add" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SafariSearchHider.bundle"] compatibleWithTraitCollection:nil] forKey:@"iconImage"];
        [specs addObject:button];

        //initialize about
        group = [PSSpecifier preferenceSpecifierNamed:@"About"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSGroupCell
            edit:Nil];
        [specs addObject:group];

        button = [PSSpecifier preferenceSpecifierNamed:@"Donate to Developer"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSButtonCell
            edit:Nil];
        [button setButtonAction:@selector(donate)];
        [button setProperty:[UIImage imageNamed:@"paypal" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SafariSearchHider.bundle"] compatibleWithTraitCollection:nil] forKey:@"iconImage"];
        [specs addObject:button];

        button = [PSSpecifier preferenceSpecifierNamed:@"Source Code on Github"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSButtonCell
            edit:Nil];
        [button setButtonAction:@selector(source)];
        [button setProperty:[UIImage imageNamed:@"github" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SafariSearchHider.bundle"] compatibleWithTraitCollection:nil] forKey:@"iconImage"];
        [specs addObject:button];

        button = [PSSpecifier preferenceSpecifierNamed:@"Email Developer"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSButtonCell
            edit:Nil];
        [button setButtonAction:@selector(email)];
        [button setProperty:[UIImage imageNamed:@"mail" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SafariSearchHider.bundle"] compatibleWithTraitCollection:nil] forKey:@"iconImage"];
        [specs addObject:button];

        group = [PSSpecifier emptyGroupSpecifier];
        [group setProperty:@"© 2015 Alex Beals" forKey:@"footerText"];
        [group setProperty:@(1) forKey:@"footerAlignment"];
        [specs addObject:group];

        _specifiers = [[NSArray arrayWithArray:specs] retain];
    }
    return _specifiers;
}

- (void)deleteRegex:(PSSpecifier *)specifier {
    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
    [regexes removeObjectAtIndex:([_specifiers indexOfObject:specifier] - 1)];
    [regexes writeToFile:prefPath atomically:YES];
}

- (void)addRegex {
    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
    regexes = (regexes) ?: [[NSMutableArray alloc] init];
    [regexes addObject:@[@YES, @YES, @""]];
    [regexes writeToFile:prefPath atomically:YES];

    [self reloadSpecifiers];
}

-(void)viewWillAppear:(BOOL)arg1 {
    [self reloadSpecifiers];
    [super viewWillAppear:arg1];
}

- (void)source {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/dado3212/SafariSearchHider"]];
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=GA2FFF2GUMMQ2&lc=US&item_name=Alex%20Beals&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"]];
}

- (void)email {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:Alex.Beals.18@dartmouth.edu?subject=Cydia%3A%20SafariSearchHider"]];
}

@end

@implementation SafariSearchHiderRegex
-(void)setSpecifier:(PSSpecifier *)specifier {
    [super setSpecifier:specifier];
    index = [specifier.properties[@"arrayIndex"] intValue];
    regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
}

-(id)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray array];
        PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                              target:self
                                                 set:@selector(setPreferenceValue:specifier:)
                                                 get:@selector(readPreferenceValue:)
                                              detail:Nil
                                                cell:PSSwitchCell
                                                edit:Nil];
        [specs addObject:spec];

        PSSpecifier* group = [PSSpecifier preferenceSpecifierNamed:@"Regex"
            target:self
            set:NULL
            get:NULL
            detail:Nil
            cell:PSGroupCell
            edit:Nil];
        [specs addObject:group];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Segment"
                                              target:self
                                                 set:@selector(setPreferenceValue:specifier:)
                                                 get:@selector(readPreferenceValue:)
                                              detail:Nil
                                                cell:PSSegmentCell
                                                edit:Nil];
        [spec setValues:@[@YES, @NO] titles:@[@"Wildcard", @"Regex"]];
        [specs addObject:spec];

         PSTextFieldSpecifier *textSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:@""
                                                                                  target:self
                                                                                     set:@selector(setPreferenceValue:specifier:)
                                                                                    get:@selector(readPreferenceValue:)
                                                                                 detail:Nil
                                                                                   cell:PSEditTextCell
                                                                                   edit:nil];
        [textSpec setPlaceholder:@"Enter a string to match"];
        [textSpec setProperty:@"regex" forKey:@"key"];
        [textSpec setKeyboardType:UIKeyboardTypeDefault autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];

        [specs addObject:textSpec];

        group = [PSSpecifier emptyGroupSpecifier];
        [group setProperty:@"In 'Wildcard' mode, * will match any characters.  Example: https://*.gov will match any government site with HTTPS." forKey:@"footerText"];
        [specs addObject:group];

        group = [PSSpecifier emptyGroupSpecifier];
        [group setProperty:@"In 'Regex' mode, it needs a valid regex.  (panda|fox).*(gif|jpg|png) will match any panda or fox images." forKey:@"footerText"];
        [specs addObject:group];

        _specifiers = [[specs copy] retain];
    }
    return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
    if ([[specifier name] isEqualToString:@"Enabled"]) {
        return regexes[index][0];
    } else if ([[specifier name] isEqualToString:@"Segment"]) {
        return regexes[index][1];
    } else {
        return regexes[index][2];
    }
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[specifier name] isEqualToString:@"Enabled"]) {
        regexes[index][0] = value;
    } else if ([[specifier name] isEqualToString:@"Segment"]) {
        regexes[index][1] = value;
    } else {
        regexes[index][2] = value;
    }
    [regexes writeToFile:prefPath atomically:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}
@end
