
#import <UIKit/UIKit.h>

@interface ModalAlert : NSObject
+ (NSString *) ask: (NSString *) question withTextPrompt: (NSString *) prompt;
+ (NSUInteger) ask: (NSString *) question withTitle: (NSString *) ttl withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons;
+ (void) say: (id)formatstring,...;
+ (BOOL) ask: (id)formatstring,...;
+ (BOOL) confirm: (id)formatstring,...;
@end
