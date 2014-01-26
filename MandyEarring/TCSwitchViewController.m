//
//  TCSwitchViewController.m
//  BTTest
//
//  Created by Joachim Bengtsson on 2014-01-19.
//  Copyright (c) 2014 ThirdCog. All rights reserved.
//

#import "TCSwitchViewController.h"
#import "TCEarringController.h"
#import "TCPatternPlayer.h"
@import CoreTelephony;

@interface TCSwitchViewController ()
{
	TCEarringController *_earring;
	TCPatternPlayer *_player;
	IBOutlet UIButton *_button;
	CTCallCenter *_callCenter;
	UIBackgroundTaskIdentifier _bgTask;
}
@end

@implementation TCSwitchViewController
- (void)viewDidLoad
{
	_earring = [TCEarringController new];
	_player = [TCPatternPlayer new];
	_player.earring = _earring;
	[_earring addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionInitial context:NULL];
	[_earring addObserver:self forKeyPath:@"vibrating" options:NSKeyValueObservingOptionInitial context:NULL];
	
	_callCenter = [CTCallCenter new];
	__weak __typeof(self) weakSelf = self;
	_callCenter.callEventHandler = ^(CTCall *call) {
		[weakSelf callChanged:call];
	};
}

- (void)callChanged:(CTCall*)call
{
	if([call.callState isEqual:CTCallStateIncoming]) {
		_bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[_player stop];
			[[UIApplication sharedApplication] endBackgroundTask:_bgTask];
		}];
		[_player playRingingVibration];
	} else {
		[_player stop];
		[[UIApplication sharedApplication] endBackgroundTask:_bgTask];
		_bgTask = UIBackgroundTaskInvalid;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	_button.enabled = _earring.connected;
	_button.selected = _earring.vibrating;
}

- (IBAction)toggle:(UIButton*)sender
{
	_earring.vibrating = !sender.selected;
}

- (IBAction)messageVibration:(id)sender
{
	[_player playMessageVibration];
}

- (IBAction)toggleRinging:(UIButton*)sender
{
	sender.selected = !sender.selected;
	if(sender.selected) {
		[_player playRingingVibration];
	} else {
		[_player stop];
	}
}

@end
