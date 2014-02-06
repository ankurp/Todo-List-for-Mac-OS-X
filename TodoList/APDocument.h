//
//  APDocument.h
//  TodoList
//
//  Created by Ankur Patel on 2/5/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APDocument : NSPersistentDocument {
	NSArray *_sortDescriptors;
}

@property (weak, nonatomic) IBOutlet NSTabView *tabView;
@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (weak, nonatomic) IBOutlet NSTableView *completedTableView;
@property (weak, nonatomic) IBOutlet NSTableColumn *tableColumn;
@property (weak, nonatomic) IBOutlet NSTableColumn *completedTableColumn;

@property (weak, nonatomic) IBOutlet NSArrayController *todoArrayController;

- (IBAction)toggleCheckbox:(NSButton*)checkBox;

@end
