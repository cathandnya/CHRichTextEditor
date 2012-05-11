//
//  SheetViewController.h
//
//  Created by nya on 10/02/05.
//

#import <UIKit/UIKit.h>


@interface CHSheetViewController : UIViewController {
    UIWindow *panel;
}

@property(readwrite, assign, nonatomic) BOOL isPresent;

- (CGFloat) height;
- (CGFloat) width;

- (void) hide;
- (void) show;

- (void) present;
- (void) dismiss;
- (void) toggle;

@end
