//
//  SocketViewController.m
//  socket
//
//  Created by Stan Zhang on 1/27/13.
//  Copyright (c) 2013 SingleWindy. All rights reserved.
//

#import "SocketViewController.h"

@interface SocketViewController ()

@end

@implementation SocketViewController
@synthesize ipAddress;
@synthesize port;
@synthesize beginView;
@synthesize joinView;
@synthesize chatView;
@synthesize checkView;
@synthesize mainView;
@synthesize trueHeading;
@synthesize receiveData;

NSMutableData *data; 

- (void)initNetworkCommunication: (NSString *) hostStr port:(int) portStr
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)hostStr, portStr, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

- (void)sendMessage: (NSString *) message
{
    NSString *response  = [NSString stringWithFormat:@"msg:%@", message];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}


//- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
//   
//    switch(eventCode) {
//        case NSStreamEventHasBytesAvailable:
//        {
//            if (data == nil) {
//                data = [[NSMutableData alloc] init];
//            }
//            uint8_t buf[1024];
//            unsigned int len = 0;
//            len = [(NSInputStream *)stream read:buf maxLength:1024];
//            if(len) {
//                [data appendBytes:(const void *)buf length:len];
//                int bytesRead;
//                bytesRead += len;
//            } else {
//                NSLog(@"No data.");
//            }
//            
//            NSString *str =[[NSString alloc] initWithData:data
//                                                 encoding:NSUTF8StringEncoding];
////
//            receiveData.text = [receiveData.text stringByAppendingString:str];
//            receiveData.text = [receiveData.text stringByAppendingString:@"\n\n"];
//
//            NSLog(str);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fromserver"
//                                                            message:str
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            data = nil;
//        } break;
//    }
//}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %i", streamEvent);
    NSLog(@"%@",theStream);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == inputStream) {
				
				uint8_t buffer[1024];
                
				int len;
				
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
                            receiveData.text = [receiveData.text stringByAppendingString:output];
                            receiveData.text = [receiveData.text stringByAppendingString:@"\n"];

							
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
	}
    
}


- (void)button1Pressed:(UIButton*)button {
    
    [self initNetworkCommunication:@"192.168.1.1" port:8000];
    [self.mainView bringSubviewToFront:chatView];
    
    gps = [ [ CLLocationManager alloc ] init ];
	gps.delegate = self;
	gps.desiredAccuracy = kCLLocationAccuracyBest;
	gps.distanceFilter = kCLDistanceFilterNone;
	//gps.headingFilter = 2.0f;       //设置此变量试试？
    [gps startUpdatingLocation];
	[gps startUpdatingHeading];

       
}

- (void)button2Pressed:(UIButton*)button {
    
    [self.mainView bringSubviewToFront:joinView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mainView addSubview:beginView];
    [self.mainView addSubview:checkView];
    [self.mainView addSubview:joinView];
    [self.mainView addSubview:chatView];
    [self.mainView bringSubviewToFront:beginView];
    self.beginView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_yellow.png"]];
    self.joinView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.checkView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_yellow.png"]];

    UIImage* panel = [UIImage imageNamed:@"panel.png"];
    UIImageView* panelView = [[UIImageView alloc] initWithImage:panel];
    panelView.frame = CGRectMake(70, 90, 176, 264);
    panelView.userInteractionEnabled = YES;
    [self.view addSubview:panelView];
    
    CGFloat halfPanelHeight = floorf(panelView.frame.size.height / 2);
    
    UIButton* one = [UIButton buttonWithType:UIButtonTypeCustom];
    one.tag = 1;
    [one setImage:[UIImage imageNamed:@"arrow_1.png"] forState:UIControlStateNormal];
    [one sizeToFit];
    one.frame = CGRectMake(floorf((panelView.frame.size.width - one.frame.size.width) / 2),
                           floorf((halfPanelHeight - one.frame.size.height) / 2),
                           one.frame.size.width,
                           one.frame.size.height);
    [one addTarget:self action:@selector(button1Pressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* two = [UIButton buttonWithType:UIButtonTypeCustom];
    two.tag = 2;
    [two setImage:[UIImage imageNamed:@"arrow_2.png"] forState:UIControlStateNormal];
    [two sizeToFit];
    two.frame = CGRectMake(floorf((panelView.frame.size.width - two.frame.size.width) / 2),
                           halfPanelHeight + floorf((halfPanelHeight - two.frame.size.height) / 2),
                           two.frame.size.width,
                           two.frame.size.height);
    
    [two addTarget:self action:@selector(button2Pressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [panelView addSubview:one];
    [panelView addSubview:two];
    [beginView addSubview:panelView];
    
    UIImage* firstTextFieldBackground = [UIImage imageNamed:@"input1.png"];
    UIImageView* firstTextFieldContainer = [[UIImageView alloc] initWithFrame:CGRectMake(86, 170, 192, 30)];
    firstTextFieldContainer.userInteractionEnabled = YES;
    firstTextFieldContainer.image = firstTextFieldBackground;
    
    [self.joinView addSubview:firstTextFieldContainer];
    
    [firstTextFieldContainer addSubview:ipAddress];
    
    UIImage* secondTextFieldBackground = [UIImage imageNamed:@"input2.png"];
    UIImageView* secondTextFieldContainer = [[UIImageView alloc] initWithFrame:CGRectMake(86, 248, 192, 30)];
    secondTextFieldContainer.userInteractionEnabled = YES;
    secondTextFieldContainer.image = secondTextFieldBackground;
    
    [self.joinView addSubview:secondTextFieldContainer];
    
    [secondTextFieldContainer addSubview:port];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.trueHeading.text = [NSString stringWithFormat:@"Heading: %fn",
                   newHeading.trueHeading];
	NSString *direction = [NSString stringWithFormat:@"%f",
                          newHeading.trueHeading];
    [self sendMessage:direction];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return YES;
}


//- (int)connectToHost:(NSString *) host port:(int) port
//{
//    if(socket == nil)
//    {
//        socket = [[AsyncSocket alloc] initWithDelegate:self];
//        NSError *err = nil;
//        if (![socket connectToHost:host onPort:port error:&err]) // Asynchronous!
//        {
//            // If there was an error, it's likely something like "already connected" or "no delegate set"
//            NSLog(@"I goofed: %@", err);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Connection failed to host " stringByAppendingString:host]
//                                message:[[[NSString alloc]initWithFormat:@"%d",[err code]] stringByAppendingString:[err localizedDescription]]
//                                delegate:self
//                                cancelButtonTitle:@"OK"
//                                otherButtonTitles:nil];
//            [alert show];
//            return SRV_CONNECT_FAIL;
//        }
//        else
//        {
//            NSLog(@"Connect Success!");
//            return SRV_CONNECT_SUC;
//        }
//    }
//    else
//    {
//        [socket readDataWithTimeout:-1 tag:0];
//        return SRV_CONNECTED;
//    }
//}
//
//- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
//{
//    NSLog(@"Cool, I'm connected! That was easy.");
//}

- (IBAction)showInfoPressed:(id)sender {
    [self.mainView bringSubviewToFront:checkView];
}

- (IBAction)returnChatPressed:(id)sender {
    [self.mainView bringSubviewToFront:chatView];
}

- (IBAction)buttonPressed:(id)sender
{
    NSString * ipAddressStr = self.ipAddress.text;
    NSInteger portNumber = self.port.text.integerValue;
    [self initNetworkCommunication:ipAddressStr port:portNumber];
    [self.mainView bringSubviewToFront:chatView];
    
    gps = [ [ CLLocationManager alloc ] init ];
	gps.delegate = self;
	gps.desiredAccuracy = kCLLocationAccuracyBest;
	gps.distanceFilter = kCLDistanceFilterNone;
	//gps.headingFilter = 2.0f;       //设置此变量试试？
    [gps startUpdatingLocation];
	[gps startUpdatingHeading];
//    NSString *logContent = [contentStr stringByAppendingString:@"\r\n"];
//    NSLog(@"%@", logContent);
//    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
//    [socket writeData:data withTimeout:-1 tag:0];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)directionPressed:(id)sender {
    NSString *currentTitle = [sender currentTitle];
    if ([currentTitle isEqualToString:@"UP"])
        [self sendMessage:@"W"];
    else if ([currentTitle isEqualToString:@"RIGHT"])
        [self sendMessage:@"D"];
    else if ([currentTitle isEqualToString:@"LEFT"])
        [self sendMessage:@"A"];
    else if ([currentTitle isEqualToString:@"DOWN"])
        [self sendMessage:@"S"];
}


@end
