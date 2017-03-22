//
//  FirstViewController.m
//  L3smartBoat
//
//  Created by Jerome Godefroy on 22/03/2017.
//  Copyright © 2017 Jerome Godefroy. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Methode permettant de recuperer les données du simulateur buggé ---------------

- (void)serialPortReadData:(NSDictionary *)dataDictionary
{
    // this method is called if data arrives
    // @"data" is the actual data, @"serialPort" is the sending port
    AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
    NSData *data = [dataDictionary objectForKey:@"data"];
    if ([data length] > 0) {
        NSString *text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        [outputTextView insertText:text];
        [text release];
        // continue listening
        [sendPort readDataInBackground];
    } else { // port closed
        [outputTextView insertText:@"port closed\r"];
    }
    [outputTextView setNeedsDisplay:YES];
    [outputTextView displayIfNeeded];
}

@end
