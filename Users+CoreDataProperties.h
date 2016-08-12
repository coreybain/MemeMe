//
//  Users+CoreDataProperties.h
//  
//
//  Created by Corey Baines on 6/8/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Users.h"

NS_ASSUME_NONNULL_BEGIN

@interface Users (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSSet<Memes *> *memes;

@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addMemesObject:(Memes *)value;
- (void)removeMemesObject:(Memes *)value;
- (void)addMemes:(NSSet<Memes *> *)values;
- (void)removeMemes:(NSSet<Memes *> *)values;

@end

NS_ASSUME_NONNULL_END
