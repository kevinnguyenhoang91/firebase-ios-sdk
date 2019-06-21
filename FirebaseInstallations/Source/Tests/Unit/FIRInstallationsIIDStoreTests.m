/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "FBLPromise+Testing.h"
#import <FirebaseInstanceID/FirebaseInstanceID.h>

#import "FIRInstallationsIIDStore.h"

@interface FIRInstanceID (Tests)
+ (FIRInstanceID *)instanceIDForTests;
@end


@interface FIRInstallationsIIDStoreTests : XCTestCase
@property(nonatomic) FIRInstanceID *instanceID;
@property(nonatomic) FIRInstallationsIIDStore *IIDStore;
@end

@implementation FIRInstallationsIIDStoreTests

- (void)setUp {
  self.instanceID = [FIRInstanceID instanceIDForTests];
  self.IIDStore = [[FIRInstallationsIIDStore alloc] init];
}

- (void)tearDown {
  self.instanceID = nil;
}

- (void)testExistingIIDSuccess {
  NSString *existingIID = [self readExistingIID];

  FBLPromise<NSString *> *IIDPromise = [self.IIDStore existingIID];

  FBLWaitForPromisesWithTimeout(0.5);

  XCTAssertNil(IIDPromise.error);
  XCTAssertEqualObjects(IIDPromise.value, existingIID);
}

#pragma mark - Helpers

- (NSString *)readExistingIID {
  __block NSString *existingIID;

  XCTestExpectation *IIDExpectation = [self expectationWithDescription:@"IIDExpectation"];
  [self.instanceID getIDWithHandler:^(NSString * _Nullable identity, NSError * _Nullable error) {
    XCTAssertNil(error);
    XCTAssertNotNil(identity);
    existingIID = identity;
    [IIDExpectation fulfill];
  }];

  [self waitForExpectations:@[ IIDExpectation ] timeout:20];

  return existingIID;
}

@end