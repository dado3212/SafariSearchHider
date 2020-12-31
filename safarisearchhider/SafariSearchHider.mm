#import <Preferences/PSListController.h>
#import <Preferences/PSEditableListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTextFieldSpecifier.h>
#import "PSTableCell.h"

NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.safarisearchhider.plist";

@interface SafariSearchHiderListController: PSEditableListController
@end

@interface SafariSearchHiderRegex : PSListController {
    int index;
    NSMutableArray *regexes;
}
@end

// CUSTOM CELL
@interface AddCell : PSTableCell
@end

@interface PrefsListController
-(void)popToRoot;
@end

extern NSString *PSDeletionActionKey;
BOOL authenticated = NO;

@implementation SafariSearchHiderListController

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 0
        ? NO
        : [super tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (void)viewDidLoad {
    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
    if (regexes == nil) {
        regexes = [[NSMutableArray alloc] init];
    }
    // Add password field to "regexes"
    if ([regexes count] == 0 || ([regexes[0] count] != 2)) {
        [regexes insertObject:@[@NO, @""] atIndex:0];
    }
    [regexes writeToFile:prefPath atomically:YES];

    if (authenticated || ![regexes[0][0] boolValue]) {
        authenticated = YES;
    } else {
        UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Passcode Required"
                                            message:@"A passcode is required to view settings."
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* cancelButton =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                   [[self parentController] popToRoot];
                               }];

        UIAlertAction* unlockButton =
        [UIAlertAction actionWithTitle:@"Unlock"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
                                    UITextField *passwordField = alert.textFields.firstObject;
                                    if ([passwordField.text isEqualToString:regexes[0][1]]) {
                                        authenticated = YES;
                                        [self viewDidLoad];
                                        [self reloadSpecifiers];
                                    } else {
                                        UIAlertController* failureAlert =
                                        [UIAlertController alertControllerWithTitle:@"Authentication Failed"
                                                                            message:@"Incorrect Password."
                                                                     preferredStyle:UIAlertControllerStyleAlert];

                                        UIAlertAction* cancelButton =
                                        [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * action) {
                                                                   [[self parentController] popToRoot];
                                                               }];

                                        [failureAlert addAction:cancelButton];

                                        UIViewController* parent = [UIApplication sharedApplication].keyWindow.rootViewController;
                                        [parent presentViewController:failureAlert animated:YES completion:nil];
                                    }
                                }];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *passwordField) {
            passwordField.placeholder = @"";
            passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
            passwordField.keyboardType = UIKeyboardTypeDecimalPad;
            passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
            passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
            passwordField.secureTextEntry = YES;
        }];

        [alert addAction:cancelButton];
        [alert addAction:unlockButton];

        UIViewController* parent = [UIApplication sharedApplication].keyWindow.rootViewController;
        [parent presentViewController:alert animated:YES completion:nil];
    }
    [super viewDidLoad];
}

-(void)viewWillDisappear:(BOOL)arg1 {
    authenticated = NO;
    [super viewWillDisappear:arg1];
}

-(id)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray array];

        if (authenticated) {
            PSSpecifier* group = [PSSpecifier preferenceSpecifierNamed:@"Regexes"
                target:self
                set:NULL
                get:NULL
                detail:Nil
                cell:PSGroupCell
                edit:Nil];
            [specs addObject:group];

            NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];

            for (int i = 1; i < [regexes count]; i++) {
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
            PSSpecifier* button = [PSSpecifier preferenceSpecifierNamed:@""
                                                         target:self
                                                                set:NULL
                                                                get:NULL
                                                         detail:Nil
                                                           cell:PSButtonCell
                                                           edit:Nil];
            [button setButtonAction:@selector(addRegex)];
            [button setProperty:[AddCell class] forKey:@"cellClass"];
            [specs addObject:button];

            //initialize password protect
            group = [PSSpecifier preferenceSpecifierNamed:@"Security"
                             target:self
                                set:NULL
                                get:NULL
                             detail:Nil
                               cell:PSGroupCell
                               edit:Nil];
            [specs addObject:group];

            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:@"Passcode Enabled"
                                                   target:self
                                                        set:@selector(setPreferenceValue:specifier:)
                                                        get:@selector(readPreferenceValue:)
                                                   detail:Nil
                                                       cell:PSSwitchCell
                                                       edit:Nil];
            [specs addObject:spec];

            PSTextFieldSpecifier *textSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:@""
                                                                              target:self
                                                                                     set:@selector(setPreferenceValue:specifier:)
                                                                                     get:@selector(readPreferenceValue:)
                                                                                detail:Nil
                                                                                    cell:PSSecureEditTextCell
                                                                                    edit:nil];
            [textSpec setPlaceholder:@"Enter passcode"];
            [textSpec setProperty:@"passcode" forKey:@"key"];
            [textSpec setKeyboardType:UIKeyboardTypeDecimalPad
                                             autoCaps:UITextAutocapitalizationTypeNone
                                 autoCorrection:UITextAutocorrectionTypeNo];

            [specs addObject:textSpec];

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
            [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SafariSearchHider.bundle/paypal.png"] forKey:@"iconImage"];
            [specs addObject:button];

            button = [PSSpecifier preferenceSpecifierNamed:@"Source Code on Github"
                target:self
                set:NULL
                get:NULL
                detail:Nil
                cell:PSButtonCell
                edit:Nil];
            [button setButtonAction:@selector(source)];
            [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SafariSearchHider.bundle/github.png"] forKey:@"iconImage"];
            [specs addObject:button];

            button = [PSSpecifier preferenceSpecifierNamed:@"Email Developer"
                target:self
                set:NULL
                get:NULL
                detail:Nil
                cell:PSButtonCell
                edit:Nil];
            [button setButtonAction:@selector(email)];
            [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SafariSearchHider.bundle/mail.png"] forKey:@"iconImage"];
            [specs addObject:button];

            // Get the current year
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSString *yearString = [formatter stringFromDate:[NSDate date]];

            group = [PSSpecifier emptyGroupSpecifier];
        [group setProperty:[NSString stringWithFormat: @"© 2015-%@ Alex Beals", yearString] forKey:@"footerText"];
            [group setProperty:@(1) forKey:@"footerAlignment"];
            [specs addObject:group];
        }

        _specifiers = [[NSArray arrayWithArray:specs] retain];
    }
    return _specifiers;
}

- (void)deleteRegex:(PSSpecifier *)specifier {
    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
    [regexes removeObjectAtIndex:([_specifiers indexOfObject:specifier])];
    [regexes writeToFile:prefPath atomically:YES];

    [self reloadSpecifiers];
}

- (void)addRegex {
    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
    regexes = (regexes != nil) ? regexes : [[NSMutableArray alloc] init];
    [regexes addObject:@[@YES, @YES, @""]];
    [regexes writeToFile:prefPath atomically:YES];

    [self reloadSpecifiers];
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
    NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];
    if ([[specifier name] isEqualToString:@"Passcode Enabled"]) {
        return regexes[0][0];
    } else {
        return regexes[0][1];
    }
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableArray *regexes = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
     if ([[specifier name] isEqualToString:@"Passcode Enabled"]) {
        regexes[0][0] = value;
    } else {
        regexes[0][1] = value;
    }
    [regexes writeToFile:prefPath atomically:YES];
}

-(void)viewWillAppear:(BOOL)arg1 {
    [self reloadSpecifiers];
    [super viewWillAppear:arg1];
}

- (void)source {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/dado3212/SafariSearchHider"] options:@{} completionHandler:nil];
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/AlexBeals/5"] options:@{} completionHandler:nil];
}

- (void)email {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:Alex.Beals.18@dartmouth.edu?subject=Cydia%3A%20SafariSearchHider"] options:@{} completionHandler:nil];
}

@end

@implementation AddCell

- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {

     id s = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];

     UIImage *image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SafariSearchHider.bundle/add.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(6,self.frame.size.height*(1.0/8.0),self.frame.size.height*(3.0/4.0),self.frame.size.height*(3.0/4.0));

    [s addSubview:imageView];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"Add Regex";
    label.font=[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    label.textColor = [UIColor colorWithRed:0.0f green:116.0f/255.0f blue:1.0f alpha:1.0f];
    [label sizeToFit];
    label.frame = CGRectMake(45,(self.frame.size.height - label.frame.size.height)/2,label.frame.size.width,label.frame.size.height);

    [s addSubview:label];

     return s;
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

-(id)readPreferenceValue:(PSSpecifier*)specifier {
    if ([[specifier name] isEqualToString:@"Enabled"]) {
        return regexes[index][0];
    } else if ([[specifier name] isEqualToString:@"Segment"]) {
        return regexes[index][1];
    } else {
        return regexes[index][2];
    }
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
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
    authenticated = YES;
}
@end
