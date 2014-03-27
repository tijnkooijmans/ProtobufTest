//
//  PBViewController.h
//  ProtobufTest
//
//  Created by Tijn Kooijmans on 27/03/14.
//  Copyright (c) 2014 Studio Sophisti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/AsyncSocket.h>

@interface PBViewController : UIViewController
{
    AsyncSocket *socket;
}
@end
