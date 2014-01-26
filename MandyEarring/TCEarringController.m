//
//  TCEarringController.m
//  BTTest
//
//  Created by Joachim Bengtsson on 2014-01-19.
//  Copyright (c) 2014 ThirdCog. All rights reserved.
//

#import "TCEarringController.h"
@import CoreBluetooth;

static NSString *kVibrationService        = @"195AE58A-437A-489B-B0CD-B7C9C394bAE4";
static NSString *kVibrationCharacteristic = @"5FC569A0-74A9-4FA4-B8B7-8354C86E45A4";

@interface TCEarringController () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
	CBCentralManager *_central;
	CBPeripheral *_earring;
	CBService *_vibrationService;
	CBCharacteristic *_vibrationCharacteristic;
}
@property(nonatomic,readwrite) BOOL connected;
@end

@implementation TCEarringController
- (id)init
{
	if(!(self = [super init]))
		return nil;
	
	_central = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
	
	return self;
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	NSLog(@"CM state is %d", (int)central.state);
	if(central.state < CBCentralManagerStatePoweredOn) {
		_earring = nil;
	} else {
		[self scan];
	}
}

- (void)scan
{
	[_central scanForPeripheralsWithServices:@[
		[CBUUID UUIDWithString:kVibrationService],
	] options:@{
		CBCentralManagerOptionShowPowerAlertKey: @YES,
		CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
		CBConnectPeripheralOptionNotifyOnNotificationKey: @YES,
		
	}];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"Found this: %@", peripheral);
	if(_earring) {
		NSLog(@"Ignoring: already connected");
		return;
	}
	
	_earring = peripheral;
	[_central connectPeripheral:peripheral options:@{
		CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
		CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
		CBConnectPeripheralOptionNotifyOnNotificationKey: @YES,
	}];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	NSLog(@"Connected to %@ %@", peripheral, peripheral.services);
	peripheral.delegate = self;
	[peripheral discoverServices:@[
		[CBUUID UUIDWithString:kVibrationService],
	]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSLog(@"Now we have services: %@ %@", peripheral.services, [[peripheral services] valueForKey:@"UUID"]);
	for(CBService *service in peripheral.services) {
		if([service.UUID isEqual:[CBUUID UUIDWithString:kVibrationService]]) {
			_vibrationService = service;
			break;
		}
	}
	NSLog(@"Scanning for characteristics in %@", _vibrationService);
	[_earring discoverCharacteristics:@[
		[CBUUID UUIDWithString:kVibrationCharacteristic],
	] forService:_vibrationService];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	NSLog(@"%@ found %@ %@ %@", service, service.characteristics, [service.characteristics valueForKey:@"UUID"], [service.characteristics valueForKey:@"value"]);
	for(CBCharacteristic *characteristic in service.characteristics) {
		if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kVibrationCharacteristic]]) {
			_vibrationCharacteristic = characteristic;
			break;
		}
	}
	[_earring setNotifyValue:YES forCharacteristic:_vibrationCharacteristic];
	_vibrating = _vibrationCharacteristic.value.length > 0 ? ((char*)_vibrationCharacteristic.value.bytes)[0] : NO;
	self.connected = YES;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	NSLog(@"Characteristic %@ -> %@ changed value to %@", peripheral, characteristic, characteristic.value);
}

- (void)setVibrating:(BOOL)vibrating
{
	[_earring writeValue:[NSData dataWithBytes:(char[]){vibrating} length:1] forCharacteristic:_vibrationCharacteristic type:CBCharacteristicWriteWithResponse];
	//[_earring readValueForCharacteristic:_vibrationCharacteristic];
	_vibrating = vibrating;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	NSLog(@"Disconnected from %@: %@", _earring, error);
	[self disconnected];
}

- (void)disconnected
{
	_earring = nil;
	_vibrationService = nil;
	_vibrationCharacteristic = nil;
	self.connected = NO;
	[self scan];
}
@end
