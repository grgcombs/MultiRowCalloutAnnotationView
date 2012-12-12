//
//  Representative.h
//  Created by Greg Combs on 11/30/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

@class MultiRowCalloutCell;
@interface Representative : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *party;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,copy) NSString *representativeID;
@property (unsafe_unretained, nonatomic,readonly) MultiRowCalloutCell *calloutCell;

+ (Representative *)representativeWithName:(NSString *)name party:(NSString *)party image:(UIImage *)image representativeID:(NSString *)representativeID;
@end
