//
//  FancyTabBarDelegate.h
//  MarvelApp
//
//  Created by Jonathan on 16/05/2014.
//

#import <Foundation/Foundation.h>

@protocol FancyTabBarDelegate <NSObject>

@optional
- (void)optionsButton:(UIButton*)optionButton didSelectItem:(int)index;
- (void)didExpand;
- (void)didCollapse;

@end
