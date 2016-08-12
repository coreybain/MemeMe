//
//  Memes+CoreDataProperties.h
//  
//
//  Created by Corey Baines on 6/8/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Memes.h"

NS_ASSUME_NONNULL_BEGIN

@interface Memes (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bottomLabel;
@property (nullable, nonatomic, retain) NSString *memeImage;
@property (nullable, nonatomic, retain) NSString *savedImage;
@property (nullable, nonatomic, retain) NSString *savedMeme;
@property (nullable, nonatomic, retain) NSString *topLabel;
@property (nullable, nonatomic, retain) NSManagedObject *users;
@property (nullable, nonatomic, retain) NSManagedObject *fontAttributes;

@end

NS_ASSUME_NONNULL_END
