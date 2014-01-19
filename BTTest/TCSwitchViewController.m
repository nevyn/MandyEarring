//
//  TCSwitchViewController.m
//  BTTest
//
//  Created by Joachim Bengtsson on 2014-01-19.
//  Copyright (c) 2014 ThirdCog. All rights reserved.
//

#import "TCSwitchViewController.h"
#import "TCEarringController.h"

@interface TCSwitchViewController ()
{
	TCEarringController *_earring;
	IBOutlet UIButton *_button;
}
@end

@implementation TCSwitchViewController
- (void)viewDidLoad
{
	_earring = [TCEarringController new];
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

@end