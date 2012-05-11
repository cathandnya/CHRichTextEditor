//
//  SampleViewController.h
//  CHRichTextEditor
//
//  Created by Naomoto nya on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHRichTextEditorViewController.h"

@interface SampleViewController : UIViewController<CHRichTextEditorViewControllerDelegate> {
}

@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) NSString *text;

@end
