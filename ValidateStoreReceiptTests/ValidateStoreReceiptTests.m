//
//  ValidateStoreReceiptTests.m
//  ValidateStoreReceiptTests
//
//  Created by User on 3/30/20.
//  Copyright © 2020 self. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ValidateStoreReceipt.h"

@interface ValidateStoreReceiptTests : XCTestCase

@end

@implementation ValidateStoreReceiptTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testValidateReceipt001 {
	// see AppleAppStoreSampleReceipt.base64, AppleAppStoreSampleReceipt.bin, AppleAppStoreSampleReceipt.txt
	// source: https://stackoverflow.com/questions/33843281/apple-receipt-data-sample

	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssert([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:@"com.belive.app.ios"
				withBundleVersion:@"3"
					withMachineIdentifier:/* FIXME: unknown, have to validate partially */ nil]);
}

- (void)testValidateReceipt002 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:@"com.belive.app.ioS" // mismatch
				withBundleVersion:nil
					withMachineIdentifier:nil]);
}

- (void)testValidateReceipt003 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:nil
				withBundleVersion:@"4" // mismatch
					withMachineIdentifier:nil]);
}

- (void)testValidateReceipt004 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	Byte guid[] = { 0x00, 0x17, 0xf2, 0xc4, 0xbc, 0xc0 };
	NSData *machineIdentifier = [NSData dataWithBytes:guid length:sizeof(guid)];

	XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:nil
				withBundleVersion:nil
					withMachineIdentifier:machineIdentifier]); // mismatch
}

- (void)testValidateReceipt005 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceiptLHS = [receiptURL path];

	NSString *tmpDir = NSTemporaryDirectory();
	NSString *pathToReceiptRHS = [tmpDir stringByAppendingPathComponent:@"AppleAppStoreSampleReceipt2.bin"];

	//
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// perform a number of attempts to corrupt a receipt to confirm detection of a validation failure
	const NSUInteger CORRUPTION_ATTEMPT_COUNT = 100;

	for (NSUInteger i = 0; i < CORRUPTION_ATTEMPT_COUNT; i++)
	{
		NSError *error = nil;

		// clean up

		if ([fileManager fileExistsAtPath:pathToReceiptRHS])
		{
			[fileManager removeItemAtPath:pathToReceiptRHS error:&error];
			XCTAssert(error == nil);
		}
		
		XCTAssert([fileManager fileExistsAtPath:pathToReceiptLHS]);
		XCTAssertFalse([fileManager fileExistsAtPath:pathToReceiptRHS]);
		
		// make a copy of the original receipt
		
		[fileManager copyItemAtPath:pathToReceiptLHS toPath:pathToReceiptRHS error:&error];
		
		XCTAssert(error == nil);
		XCTAssert([fileManager fileExistsAtPath:pathToReceiptRHS]);
		
		// sanity: successfully validate the copy of the original receipt
		
		XCTAssert([ValidateStoreReceipt validateReceiptAtPath:pathToReceiptRHS
				withBundleIdentifier:nil // disregard
					withBundleVersion:nil // disregard
						withMachineIdentifier:nil]); // disregard
						
		// change (thus corrupt) a number of bytes at random within the copy of the original receipt
		
		// FIXME: corrupting fewer than 5 bytes at a time sometimes goes undetected - find out why that is, exactly
		const NSUInteger CORRUPTED_BYTE_COUNT = 5;
		
		NSData *data = [NSData dataWithContentsOfFile:pathToReceiptRHS options:NSDataReadingUncached error:&error];

		XCTAssert(error == nil);
		XCTAssert(data.length > 0);
		
		NSMutableData *mutable = [NSMutableData dataWithData:data]; // only ~5Kb, copy in its entirety
		
		for (NSUInteger v = 0; v < CORRUPTED_BYTE_COUNT; v++)
		{
			// FIXME: we might process the same byte (at the same random index) more than once,
			// thus corrupting it twice or even by chance reverting it back to the original, but
			// such coincidence is probably statistically insignificant

			const NSUInteger randomIndex = arc4random_uniform((uint32_t) data.length - 1); // from zero, inclusive
			
			for (;;) {
				const Byte randomByte[] = { arc4random_uniform(255) };
				const NSRange range = NSMakeRange(randomIndex, sizeof(randomByte));
				
				// get the valid (unchanged) byte
				
				Byte originalByte[] = { 0 };
				[mutable getBytes:originalByte range:range];
				
				// make sure it is, indeed, changed to something different, thus an invalid byte

				if (randomByte[0] != originalByte[0])
				{
					[mutable replaceBytesInRange:range withBytes:randomByte];
					break;
				}
			}
			
			XCTAssert([mutable writeToFile:pathToReceiptRHS atomically:YES]);
		}

		// re-validate the copy of the original receipt
		
		XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceiptRHS
				withBundleIdentifier:nil // disregard
					withBundleVersion:nil // disregard
						withMachineIdentifier:nil]); // disregard
	} // for
}

@end
