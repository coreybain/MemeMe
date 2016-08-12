//
//  FontAttributes+CoreDataProperties.h
//  
//
//  Created by Corey Baines on 6/8/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FontAttributes.h"

NS_ASSUME_NONNULL_BEGIN

@interface FontAttributes (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *borderColor;
@property (nullable, nonatomic, retain) NSString *fontColor;
@property (nullable, nonatomic, retain) NSString *fontName;
@property (nullable, nonatomic, retain) NSString *fontSize;
@property (nullable, nonatomic, retain) Memes *memes;

@end

NS_ASSUME_NONNULL_END
