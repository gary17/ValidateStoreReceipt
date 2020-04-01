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

@end
