//
//  FancyTabBar.h
//  FancyTabBar
//
//  Created by Jonathan on 15/05/2014.
//

#import <UIKit/UIKit.h>
#import "FancyTabBarDelegate.h"

typedef enum {
    FancyTabBarItemsPop_Up,
    FancyTabBarItemsPop_Down
} FancyTabBarItemsPopDirection;

@interface FancyTabBar : UIView{
    
}
/**
 *  Set the direction you want to the choices to pop. This must be set before setting up choices.
 */
@property (assign, nonatomic) FancyTabBarItemsPopDirection currentDirectionToPopOptions;
@property(nonatomic,weak) id<FancyTabBarDelegate> delegate;

- (void) setUpChoices:(UIViewController*) parentViewController choices:(NSArray*) choices withMainButtonImage:(UIImage*)mainButtonImage;
- (void) setUpChoices:(UIViewController*) parentViewController choices:(NSArray*) choices withMainButtonImage:(UIImage*)mainButtonImage andMainButtonCustomOrigin:(CGPoint)customOrigin;
@end
