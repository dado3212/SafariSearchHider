#import <objc/runtime.h>

@interface WBSHistory : NSObject
-(id)itemVisitedAtURLString:(id)arg1 title:(id)arg2 timeOfVisit:(double)arg3 wasHTTPNonGet:(BOOL)arg4 wasFailure:(BOOL)arg5 increaseVisitCount:(BOOL)arg6 origin:(int)arg7;
@end

static BOOL doesMatch(NSString *url, NSArray *regexes) {
	for (NSArray *regexArray in regexes) {
		NSError *error = nil;
		if ([regexArray[0] intValue]) {
			NSString *regex;
			if ([regexArray[1] intValue]) {
				NSRegularExpression *replace = [NSRegularExpression regularExpressionWithPattern:@"([\\.\\^\\$\\*\\+\\?\\(\\)\\[\\{\\\\|])" options:0 error:&error];
				regex = [replace stringByReplacingMatchesInString:regexArray[2] options:0 range:NSMakeRange(0, [regexArray[2] length]) withTemplate:@"\\\\$1"];
				regex = [regex stringByReplacingOccurrencesOfString:@"\\*" withString:@".*"];
			} else {
				regex = regexArray[2];
			}

			NSRegularExpression* test = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];

			if (error == nil) {
				NSUInteger numberOfMatches = [test numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])];

				if (numberOfMatches > 0) {
					return YES;
				}
			}
		}
	}
	return NO;
}

%hook WBSHistory
	- (id)itemVisitedAtURLString:(id)arg1 title:(id)arg2 timeOfVisit:(double)arg3 wasHTTPNonGet:(BOOL)arg4 wasFailure:(BOOL)arg5 increaseVisitCount:(BOOL)arg6 origin:(int)arg7 {
		NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hackingdartmouth.safarisearchhider.plist"];
		if (doesMatch(arg1, regexes))
			return nil;
		else
			return %orig;
	}
%end
