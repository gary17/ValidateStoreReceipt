/* 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in
 the documentation and/or other materials provided with the distribution.
 
 Neither the name of the copyright holders nor the names of its contributors may be used to endorse or promote products derived 
 from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
 BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

#import "validatereceipt.h"

int main (int argc, const char *argv[]) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
	// put the example receipt on the desktop (or change that path)
	NSString *pathToReceipt = @"~/Desktop/receipt";
	
	// in your own code you have to do:
	// NSString *pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
	// this example is not a bundle so it wont work here.
	
	// WARNING: using [[NSBundle mainBundle] bundleIdentifier] and [[NSBundle mainBundle]
	// objectForInfoDictionaryKey:@"CFBundleShortVersionString"] might not be secure:
	//
	// http://www.craftymind.com/2011/01/06/mac-app-store-hacked-how-developers-can-better-protect-themselves/
	//
	// so use hard-coded values instead (probably even obfuscated somehow)
	
	// Overwrite with example GUID for use with example receipt
	// unsigned char guid[] = { 0x00, 0x17, 0xf2, 0xc4, 0xbc, 0xc0 };
	// guidData = [NSData dataWithBytes:guid length:sizeof(guid)];
	
	if (![ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]
				withBundleVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
					withMachineIdentifier:[ValidateStoreReceipt currentMachineIdentifier]])
	{
		exit(173);
	}
	
    NSLog(@"Hello, correctly validated World!");
#if !__has_feature(objc_arc)
    [pool drain];
#endif
    return 0;
}
