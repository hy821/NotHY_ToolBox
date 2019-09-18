//
//  MOBCoreDataHelper.m
//  LJDownloadDemo
//
//  Created by MOB on 2018/9/14.
//  Copyright © 2018年 YouZu. All rights reserved.
//

#import "MOBCoreDataHelper.h"

/**
 *    @brief    升序
 */
const NSString *MOBSORT_ASC = @"ASC";

/**
 *    @brief    降序
 */
const NSString *MOBSORT_DESC = @"DESC";

@implementation MOBCoreDataHelper

- (id)initWithDataModel:(NSString *)dataModel
{
    if (self = [super init])
    {
        //初始化持久化存储调度器
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModel withExtension:@"momd"];
#ifdef DEBUG
        NSLog(@"model url = %@", modelURL.absoluteString);
#endif
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        
        //添加持久化存储
        NSString *storeUrlString = [NSString stringWithFormat:
                                    @"%@/Library/Caches/%@.sqlite",
                                    NSHomeDirectory(),
                                    dataModel];
#ifdef DEBUG
        NSLog(@"store url = %@", storeUrlString);
#endif
        NSURL *storeURL = [NSURL fileURLWithPath:storeUrlString];
        
        //自动合并数据库版本
        NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption : @YES,
                                       NSMigratePersistentStoresAutomaticallyOption: @YES};
        
        _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                     configuration:nil
                                                                               URL:storeURL
                                                                           options:storeOptions
                                                                             error:nil];
        
        //创建受控对象上下文
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext performBlockAndWait:^{
            [self->_managedObjectContext setPersistentStoreCoordinator:self->_persistentStoreCoordinator];
        }];
        
#ifdef DEBUG
        NSLog(@"init core data framework success");
#endif
    }
    
    return self;
}

- (NSArray *)selectObjectsWithEntityName:(NSString *)name
                               condition:(NSPredicate *)condition
                                    sort:(NSDictionary *)sort
                                   error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:name];
    
    if (sort)
    {
        NSMutableArray *sortDescriptors = [NSMutableArray array];
        NSArray *keys = [sort allKeys];
        for (NSString *key in keys)
        {
            BOOL ascending = [MOBSORT_ASC isEqualToString:[sort objectForKey:key]] ? YES : NO;
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
            [sortDescriptors addObject:descriptor];
        }
        request.sortDescriptors = sortDescriptors;
    }
    
    if (condition)
    {
        request.predicate = condition;
    }
    
    __block NSArray *arr;
    [_managedObjectContext performBlockAndWait:^{
        arr = [self->_managedObjectContext executeFetchRequest:request error:error];
    }];
    return arr;
}

- (NSArray *)selectObjectsWithEntityName:(NSString *)name
                               condition:(NSPredicate *)condition
                                    sort:(NSDictionary *)sort
                                  offset:(NSUInteger)offset
                                   limit:(NSUInteger)limit
                                   error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:name];
    
    if (sort)
    {
        NSMutableArray *sortDescriptors = [NSMutableArray array];
        NSArray *keys = [sort allKeys];
        for (NSString *key in keys)
        {
            BOOL ascending = [MOBSORT_ASC isEqualToString:[sort objectForKey:key]] ? YES : NO;
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
            [sortDescriptors addObject:descriptor];
        }
        request.sortDescriptors = sortDescriptors;
    }
    
    if (condition)
    {
        request.predicate = condition;
    }
    
    request.fetchOffset = offset;
    request.fetchLimit = limit;
    
    __block NSArray *arr;
    [_managedObjectContext performBlockAndWait:^{
        arr = [self->_managedObjectContext executeFetchRequest:request error:error];
    }];
    return arr;
}

- (id)createObjectWithName:(NSString *)name
{
    __block id instance;
    [_managedObjectContext performBlockAndWait:^{
        instance = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self->_managedObjectContext];
    }];
    return instance;
}

- (void)deleteObject:(id)object
{
    [_managedObjectContext performBlockAndWait:^{
        [self->_managedObjectContext deleteObject:object];
    }];
}

- (void)flush:(NSError *__autoreleasing *)error
{
    [_managedObjectContext performBlockAndWait:^{
        if ([self->_managedObjectContext hasChanges])
        {
            [self->_managedObjectContext save:error];
        }
    }];
}

- (void)rollback
{
    [_managedObjectContext performBlockAndWait:^{
        [self->_managedObjectContext rollback];
    }];
}

@end
