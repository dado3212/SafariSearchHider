#import <objc/runtime.h>

NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.safarisearchhider.plist";

@interface WBSHistory : NSObject
-(id)itemVisitedAtURLString:(id)arg1 title:(id)arg2 timeOfVisit:(double)arg3 wasHTTPNonGet:(BOOL)arg4 wasFailure:(BOOL)arg5 increaseVisitCount:(BOOL)arg6 origin:(int)arg7;
-(id)_removeItemForURLString:(id)arg1 ;
@end

@interface WBSBookmarkAndHistoryCompletionMatch: NSObject
-(id)originalURLString;
-(id)title;
@end

@interface WBSHistoryVisit : NSObject
-(id)item;
@end

@interface WBSHistoryItem : NSObject
-(id)urlString;
@end

static BOOL doesMatch(NSString *url, NSArray *regexes) {
	if (url == nil || ![url length]) {
		return NO;
	}
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

%hook WBSURLCompletionDatabase
-(void)getBestMatchesForTypedString:(id)arg1 topHits:(id*)tH matches:(id*)m limit:(unsigned long long)arg4 {
	// Request twice as many to try and get enough that aren't dirty
	%orig(arg1, tH, m, arg4 * 2);
	NSArray *regexes = [[NSArray alloc] initWithContentsOfFile:prefPath];

	// Examine matches
	NSMutableArray *modifiedMatches = [[NSMutableArray alloc] init];
	id matches = *m;
	for (int i = 0; i < [matches count]; i++) {
		id match = matches[i];
		
		if (!doesMatch([match originalURLString], regexes) && !doesMatch([match title], regexes)) {
			[modifiedMatches addObject:match];
		}
	}
	*m = modifiedMatches;

	// Examine top hits
	NSMutableArray *modifiedTopHits = [[NSMutableArray alloc] init];
	id topHits = *tH;
	for (int i = 0; i < [topHits count]; i++) {
		id match = topHits[i];
		
		if (!doesMatch([match originalURLString], regexes) && !doesMatch([match title], regexes)) {
			[modifiedTopHits addObject:match];
		}
	}
	*tH = modifiedTopHits;

	return;
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