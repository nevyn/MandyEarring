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

@interface TCSwitchViewController ()
{
	TCEarringController *_earring;
	TCPatternPlayer *_player;
	IBOutlet UIButton *_button;
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
