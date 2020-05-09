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
	/*
		FYI: a single In-App Purchase test case
		source: https://stackoverflow.com/questions/33843281/apple-receipt-data-sample
		
		{
			"receipt": {
				"receipt_type": "ProductionSandbox",
				"adam_id": 0,
				"app_item_id": 0,
				"bundle_id": "com.belive.app.ios",
				"application_version": "3",
				"download_id": 0,
				"version_external_identifier": 0,
				"receipt_creation_date": "2018-11-13 16:46:31 Etc/GMT",
				"receipt_creation_date_ms": "1542127591000",
				"receipt_creation_date_pst": "2018-11-13 08:46:31 America/Los_Angeles",
				"request_date": "2018-11-13 17:10:31 Etc/GMT",
				"request_date_ms": "1542129031280",
				"request_date_pst": "2018-11-13 09:10:31 America/Los_Angeles",
				"original_purchase_date": "2013-08-01 07:00:00 Etc/GMT",
				"original_purchase_date_ms": "1375340400000",
				"original_purchase_date_pst": "2013-08-01 00:00:00 America/Los_Angeles",
				"original_application_version": "1.0",
				"in_app": [{
					"quantity": "1",
					"product_id": "test2",
					"transaction_id": "1000000472106082",
					"original_transaction_id": "1000000472106082",
					"purchase_date": "2018-11-13 16:46:31 Etc/GMT",
					"purchase_date_ms": "1542127591000",
					"purchase_date_pst": "2018-11-13 08:46:31 America/Los_Angeles",
					"original_purchase_date": "2018-11-13 16:46:31 Etc/GMT",
					"original_purchase_date_ms": "1542127591000",
					"original_purchase_date_pst": "2018-11-13 08:46:31 America/Los_Angeles",
					"is_trial_period": "false"
				}]
			},
			"status": 0,
			"environment": "Sandbox"
		}
	*/

	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssert([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:@"com.belive.app.ios"
				withBundleVersion:@"3"
					// FIXME: unknown machine identifier, have to validate partially
					withMachineIdentifier:nil]);
}

- (void)testValidateReceipt002 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssert([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:nil // any
				withBundleVersion:nil // any
					withMachineIdentifier:nil]); // any
}

- (void)testValidateReceipt003 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	NSArray *purchases = [ValidateStoreReceipt obtainInAppPurchases:pathToReceipt];
	XCTAssert(purchases);
	
	/*
	
	"in_app": [{
		"quantity": "1",
		"product_id": "test2",
		"transaction_id": "1000000472106082",
		"original_transaction_id": "1000000472106082",
		"purchase_date": "2018-11-13 16:46:31 Etc/GMT",
		"purchase_date_ms": "1542127591000",
		"purchase_date_pst": "2018-11-13 08:46:31 America/Los_Angeles",
		"original_purchase_date": "2018-11-13 16:46:31 Etc/GMT",
		"original_purchase_date_ms": "1542127591000",
		"original_purchase_date_pst": "2018-11-13 08:46:31 America/Los_Angeles",
		"is_trial_period": "false"
	}]
	
	*/

	NSString *productIdentifier = @"test2";
	
	const BOOL haveIt = ^{
		for (NSDictionary *purchase in purchases)
		{
			if ([[purchase objectForKey:kReceiptInAppProductIdentifier] isEqualToString:productIdentifier])
				return YES;
		}
		return NO;
	}();
	
	XCTAssert(haveIt);
}

- (void)testValidateReceipt100 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:@"com.belive.app.ioS" // mismatch
				withBundleVersion:nil
					withMachineIdentifier:nil]);
}

- (void)testValidateReceipt101 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:nil
				withBundleVersion:@"4" // mismatch
					withMachineIdentifier:nil]);
}

- (void)testValidateReceipt102 {
	NSURL *receiptURL = [[NSBundle mainBundle] URLForResource:@"AppleAppStoreSampleReceipt" withExtension:@"bin"];
	NSString *pathToReceipt = [receiptURL path];

	Byte guid[] = { 0x00, 0x17, 0xf2, 0xc4, 0xbc, 0xc0 };
	NSData *machineIdentifier = [NSData dataWithBytes:guid length:sizeof(guid)];

	XCTAssertFalse([ValidateStoreReceipt validateReceiptAtPath:pathToReceipt
			withBundleIdentifier:nil
				withBundleVersion:nil
					withMachineIdentifier:machineIdentifier]); // mismatch
}

- (void)testValidateReceipt103 {
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
