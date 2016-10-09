#import <objc/runtime.h>

NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.safarisearchhider.plist";

@interface WBSHistory : NSObject
-(id)itemVisitedAtURLString:(id)arg1 title:(id)arg2 timeOfVisit:(double)arg3 wasHTTPNonGet:(BOOL)arg4 wasFailure:(BOOL)arg5 increaseVisitCount:(BOOL)arg6 origin:(int)arg7;
-(id)_removeItemForURLString:(id)arg1 ;
@end

@interface WBSHistoryVisit : NSObject
-(id)item;
@end

@interface WBSHistoryItem : NSObject
-(id)urlString;
@end

static BOOL doesMatch(NSString *url, NSArray *regexes) {
	for (NSArray *regexArray in regexes) {
		NSError *error = nil;
		if ([regexArray count] == 3 && [regexArray[0] boolValue]) {
			NSString *regex;
			if ([regexArray[1] boolValue]) {
				NSRegularExpression *replace = [NSRegularExpression regularExpressionWithPattern:@"([\\.\\^\\$\\*\\+\\?\\(\\)\\[\\{\\\\|])" options:0 error:&error];
				regex = [replace stringByReplacingMatchesInString:regexArray[2] options:0 range:NSMakeRange(0, [regexArray[2] length]) withTemplate:@"\\\\$1"];
				regex = [regex stringByReplacingOccurrencesOfString:@"\\*" withString:@".*"];
			} else {
				regex = regexArray[2];
			}

			NSRegularExpression* test = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];

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

// Handles removing search suggestions
%hook WBSRecentWebSearchesController
	-(id)recentSearchesMatchingPrefix:(id)arg1 {
		id recentSearches = %orig;

		NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];
		NSMutableArray *modifiedSearches = [[NSMutableArray alloc] init];

		for (int i = 0; i < [recentSearches count]; i++) {
			NSString *string = recentSearches[i];
			
			if (!doesMatch(string, regexes)) {
				[modifiedSearches addObject:string];
			}
		}

		return modifiedSearches;
	}
%end

%hook WBSHistory
	// Match based on URL
	- (id)itemVisitedAtURLString:(id)arg1 title:(id)arg2 timeOfVisit:(double)arg3 wasHTTPNonGet:(BOOL)arg4 wasFailure:(BOOL)arg5 increaseVisitCount:(BOOL)arg6 origin:(int)arg7 {
		NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];
		if (doesMatch(arg1, regexes))
			return nil;
		else
			return %orig;
	}

	// Match based on title
	-(void)updateTitle:(id)arg1 forVisit:(id)arg2 {
		NSString *url = [(WBSHistoryItem*)[(WBSHistoryVisit*)arg2 item] urlString];
		NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];
		if (doesMatch(url, regexes))
			[self _removeItemForURLString:url];
		else
			return %orig;
	}
%end