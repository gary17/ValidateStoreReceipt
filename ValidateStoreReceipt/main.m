//
//  main.m
//  ValidateStoreReceipt
//
//  Created by User on 3/30/20.
//  Copyright © 2020 self. All rights reserved.
//

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

#import <UIKit/UIKit.h>

#import "validatereceipt.h"
#import "AppDelegate.h"

int main(int argc, char * argv[]) {

#ifdef IN_PRODUCTION
	// i.e., [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"]
	NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];

	NSString *pathToReceipt = [receiptURL path];

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
#else
	// see AppleAppStoreSampleReceipt.base64, AppleAppStoreSampleReceipt.bin, AppleAppStoreSampleReceipt.txt
	// source: https://stackoverflow.com/questions/33843281/apple-receipt-data-sample

	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];

	NSString *pathToReceipt = [receiptURL path];

	if (![ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:@"com.belive.app.ios"
				withBundleVersion:@"3"
					withMachineIdentifier:/* FIXME: unknown, have to validate partially*/ nil])
	{
		exit(173);
	}
#endif

    NSLog(@"Hello, correctly validated World!");

	//

	NSString * appDelegateClassName;
	@autoreleasepool {
	    // Setup code that might create autoreleased objects goes here.
	    appDelegateClassName = NSStringFromClass([AppDelegate class]);
	}
	return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
