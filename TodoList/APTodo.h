//
//  APListItem.h
//  TodoList
//
//  Created by Ankur Patel on 2/5/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APTodo : NSManagedObject

@property (nonatomic, assign) int viewPosition;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, retain) NSString *text;

@end
