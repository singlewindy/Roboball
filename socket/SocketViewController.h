//
//  SocketViewController.h
//  socket
//
//  Created by Stan Zhang on 1/27/13.
//  Copyright (c) 2013 SingleWindy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SocketViewController : UIViewController <NSStreamDelegate> {
    CLLocationManager *gps;
    UITextView *trueHeading;
    UITextView *receiveData;
    UIView *mainView;
    UIView *beginView;
    UIView *joinView;
    UIView *chatView;
    UIView *checkView;
    UITextField * ipAddress;
    UITextField * port;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}


@property (retain, nonatomic) IBOutlet UITextView *receiveData;

@property (retain, nonatomic) IBOutlet UITextField *ipAddress;

@property (nonatomic, retain) IBOutlet UIView *joinView;

@property (retain, nonatomic) IBOutlet UIView *beginView;

@property (retain, nonatomic) IBOutlet UIView *checkView;

@property (nonatomic, retain) IBOutlet UIView *chatView;

@property (retain, nonatomic) IBOutlet UIView *mainView;

@property (retain, nonatomic) IBOutlet UITextField *port;

@property (retain, nonatomic) IBOutlet UITextView *trueHeading;

- (IBAction)showInfoPressed:(id)sender;

- (IBAction)returnChatPressed:(id)sender;

- (IBAction)buttonPressed:(id)sender;

- (IBAction)textFieldDoneEditing:(id)sender;

- (IBAction)directionPressed:(id)sender;



- (void)sendMessage: (NSString *) message;

@end
