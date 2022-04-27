//
//  iOSLanPlay-Bridging-Header.h
//  iOSLanPlay
//
//  Created by Eliott on 03/12/2021.
//

#ifndef iOSLanPlay_Bridging_Header_h
#define iOSLanPlay_Bridging_Header_h


#endif /* iOSLanPlay_Bridging_Header_h */

#import <Foundation/Foundation.h>
@interface NSTask : NSObject

- (instancetype __nonnull)init;
- (void)launch;
- (void)setArguments:(NSArray<NSString *> * __nullable)arg1;
- (void)setLaunchPath:(NSString * __nullable)arg1;
- (void)setStandardError:(id __nullable)arg1;
- (void)setStandardOutput:(id __nullable)arg1;
- (void)setcurrentDirectoryURL:(NSURL* __nullable)arg1;
- (void)waitUntilExit;
- (long long)terminationReason;
 @property(readonly) int terminationStatus;
 @property (readonly) long long terminationReason;
@end
