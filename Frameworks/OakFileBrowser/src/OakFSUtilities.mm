#import "OakFSUtilities.h"
#import <io/io.h>
#import <OakFoundation/NSString Additions.h>
#import <OakAppKit/OakFileIconImage.h>

NSURL* kURLLocationComputer;
NSURL* kURLLocationHome;
NSURL* kURLLocationDesktop;
NSURL* kURLLocationFavorites;
NSURL* kURLLocationBundles;

__attribute__((constructor)) // executed after +loads and initializers in linked frameworks
static void initializeConstants ()
{
	@autoreleasepool {
		kURLLocationComputer  = [[NSURL alloc] initWithString:@"computer:///"];
		kURLLocationHome      = [[NSURL alloc] initFileURLWithPath:NSHomeDirectory() isDirectory:YES];
		kURLLocationDesktop   = [[NSURL alloc] initFileURLWithPath:[NSString stringWithCxxString:path::desktop()] isDirectory:YES];
		kURLLocationFavorites = [[NSURL alloc] initFileURLWithPath:[NSString stringWithCxxString:path::join(path::home(), "Library/Application Support/TextMate/Favorites")] isDirectory:YES];
		kURLLocationBundles   = [[NSURL alloc] initWithString:@"bundles:///"];
	}
}

NSURL* ParentForURL (NSURL* url)
{
	struct statfs buf;
	NSString* currentPath = [url path];
	NSString* parentPath  = [currentPath stringByDeletingLastPathComponent];

	if([[url scheme] isEqualToString:[kURLLocationComputer scheme]])
		return nil;
	else if([currentPath isEqualToString:parentPath] || [url isFileURL] && statfs([currentPath fileSystemRepresentation], &buf) == 0 && path::normalize(buf.f_mntonname) == path::normalize([currentPath fileSystemRepresentation]))
		return kURLLocationComputer;
	else if([url isFileURL])
		return [NSURL fileURLWithPath:parentPath isDirectory:YES];
	else if([[url scheme] isEqualToString:@"scm"])
		return [NSURL fileURLWithPath:[url path] isDirectory:YES];
	else if([@[ @"xcodeproj", @"search" ] containsObject:[url scheme]])
		return [NSURL fileURLWithPath:parentPath isDirectory:YES];
	else
		return [[NSURL alloc] initWithScheme:[url scheme] host:[url host] path:parentPath];
}
