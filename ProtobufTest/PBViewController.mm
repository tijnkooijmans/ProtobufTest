//
//  PBViewController.m
//  ProtobufTest
//
//  Created by Tijn Kooijmans on 27/03/14.
//  Copyright (c) 2014 Studio Sophisti. All rights reserved.
//

#import "PBViewController.h"
#import "ikawa.pb.h"
#include <string.h>

using namespace std;
using namespace ikawa;

@interface PBViewController ()

@end

@implementation PBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    [socket connectToHost:@"127.0.0.1" onPort:10013 withTimeout:5 error:NULL];
}

- (void)debugLogMessage:(::google::protobuf::Message*) message {
    string debugStr = message->DebugString();
    NSString *debugMsg = [NSString stringWithCString:debugStr.c_str()
                                            encoding:[NSString defaultCStringEncoding]];
    NSLog(@"Protobuf message: %@", debugMsg);
}

- (NSData*)nsDataFromMachineStatus:(MachineStatus*)status {
    string str;
    status->SerializeToString(&str);
    return [NSData dataWithBytes:str.c_str() length:str.size()];
}

- (MachineStatus*)newMachineStatusFromNSData:(NSData *)data {
    char raw[[data length]];
    MachineStatus *s = new MachineStatus;
    [data getBytes:raw length:[data length]];
    s->ParseFromArray(raw, [data length]);
    return s;
    
}

- (void)sendMachineStatus {
    
    MachineStatus currentStatus;
    currentStatus.add_fanspeeds(10);
    currentStatus.add_temps(25);
    currentStatus.add_timeintoroasts(0);

    NSData *data = [self nsDataFromMachineStatus:&currentStatus];
    NSLog(@"Sending data: %@", [data description]);
    
    [socket writeData:data withTimeout:-1 tag:0];
}

#pragma mark - AsyncSocket

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"Did disconnect");
    [sock connectToHost:@"127.0.0.1" onPort:10013 withTimeout:5 error:NULL];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Did connect to %@ on %d", host, port);
    
    [self sendMachineStatus];
    
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"Did read data: %@", [data description]);
 
    MachineStatus *currentStatus = [self newMachineStatusFromNSData:data];
    [self debugLogMessage:currentStatus];
    delete currentStatus;
    
    [sock readDataWithTimeout:-1 tag:0];
}


@end
