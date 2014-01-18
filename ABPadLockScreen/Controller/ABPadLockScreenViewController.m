//
//  ABPadLockScreenViewController.m
//  ABPadLockScreen
//
//  Created by Aron Bury on 18/01/2014.
//  Copyright (c) 2014 Aron's IT Consultancy. All rights reserved.
//

#import "ABPadLockScreenViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"

#define lockScreenView ((ABPadLockScreenView *) [self view])

@interface ABPadLockScreenViewController ()

@property (nonatomic, strong) NSString *currentPin;

- (void)setUpButtonMapping;
- (BOOL)isPinValid:(NSString *)pin;
- (void)newPinSelected:(NSInteger)pinNumber;
- (void)deleteFromPin;

- (void)buttonSelected:(UIButton *)sender;
- (void)cancelButtonSelected:(UIButton *)sender;
- (void)deleteButtonSeleted:(UIButton *)sender;

@end

@implementation ABPadLockScreenViewController
#pragma mark -
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<ABPadLockScreenViewControllerDelegate>)delegate pin:(NSString *)pin
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        _pin = pin;
        _currentPin = @"";
    }
    return self;
}

#pragma mark -
#pragma mark - View Controller Lifecycele Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[ABPadLockScreenView alloc] initWithFrame:self.view.frame];
    [self setUpButtonMapping];
    [lockScreenView.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [lockScreenView.deleteButton addTarget:self action:@selector(deleteButtonSeleted:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIUserInterfaceIdiom interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    if (interfaceIdiom == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll;
    if (interfaceIdiom == UIUserInterfaceIdiomPhone) return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    
    return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark - Helper Methods
- (void)setUpButtonMapping
{
    for (UIButton *button in [lockScreenView buttonArray])
    {
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark -
#pragma mark - Attempts
- (void)setAllowedAttempts:(NSInteger)allowedAttempts
{
    _totalAttempts = allowedAttempts;
    _remainingAttempts = allowedAttempts;
}

- (void)setLockScreenTitle:(NSString *)title
{
    self.title = title;
    lockScreenView.enterPasscodeLabel.text = title;
}

#pragma mark -
#pragma mark - Pin Validation
- (void)processPin
{
    
}

- (BOOL)isPinValid:(NSString *)pin
{
    if ([_pin isEqualToString:pin]) return YES;
    
    _remainingAttempts --;
    return NO;
}

#pragma mark -
#pragma mark - Pin Selection
- (void)newPinSelected:(NSInteger)pinNumber
{
    if ([self.currentPin length] >= 4)
    {
        return;
    }
    
    self.currentPin = [NSString stringWithFormat:@"%@%ld", self.currentPin, (long)pinNumber];
    
    if ([self.currentPin length] == 1)
    {
        [lockScreenView.pinOneSelectionView setSelected:YES animated:YES completion:nil];
        [lockScreenView showDeleteButtonAnimated:YES completion:nil];
    }
    else if ([self.currentPin length] == 2)
    {
        [lockScreenView.pinTwoSelectionView setSelected:YES animated:YES completion:nil];
    }
    else if ([self.currentPin length] == 3)
    {
        [lockScreenView.pinThreeSelectionView setSelected:YES animated:YES completion:nil];
    }
    else if ([self.currentPin length] == 4)
    {
        [lockScreenView.pinFourSelectionView setSelected:YES animated:YES completion:nil];
        [self processPin];
    }
}

- (void)deleteFromPin
{
    if ([self.currentPin length] == 0)
    {
        return;
    }
    
    self.currentPin = [self.currentPin substringWithRange:NSMakeRange(0, [self.currentPin length] - 1)];
    
    if ([self.currentPin length] == 2)
    {
        [lockScreenView.pinThreeSelectionView setSelected:NO animated:YES completion:nil];
    }
    else if ([self.currentPin length] == 1)
    {
        [lockScreenView.pinTwoSelectionView setSelected:NO animated:YES completion:nil];
    }
    else if ([self.currentPin length] == 0)
    {
        [lockScreenView.pinOneSelectionView setSelected:NO animated:YES completion:nil];
        [lockScreenView showCancelButtonAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - Button Selection
- (void)buttonSelected:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    [self newPinSelected:tag];
}

- (void)cancelButtonSelected:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockWasCancelledForPadLockScreenViewController:)])
    {
        [self.delegate unlockWasCancelledForPadLockScreenViewController:self];
    }
}

- (void)deleteButtonSeleted:(UIButton *)sender
{
    [self deleteFromPin];
}

@end