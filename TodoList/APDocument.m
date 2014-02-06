//
//  APDocument.m
//  TodoList
//
//  Created by Ankur Patel on 2/5/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

#import "APDocument.h"
#import "APTodoListCellView.h"
#import "APTodo.h"

int temporaryViewPosition = -1;
int startViewPosition = -2;
int endViewPosition = -3;

#define temporaryViewPositionNum [NSNumber numberWithInt:temporaryViewPosition]
#define startViewPositionNum [NSNumber numberWithInt:startViewPosition]
#define endViewPositionNum [NSNumber numberWithInt:endViewPosition]


@interface APDocument ()

@property (nonatomic, retain) NSMutableArray *todos;

@end


@implementation APDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"APDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    [self.tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [self.tableColumn setResizingMask:NSTableColumnAutoresizingMask];
    [self.completedTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [self.completedTableColumn setResizingMask:NSTableColumnAutoresizingMask];
    
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObjects:@"DemoItemsDropType", nil]];
    
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (IBAction)toggleCheckbox:(NSButton*)checkBox
{
    NSInteger row = 0;
    if ([self.tabView.tabViewItems indexOfObject:self.tabView.selectedTabViewItem] == 0) {
        row = [self.tableView rowForView:checkBox];
    } else {
        row = [self.completedTableView rowForView:checkBox];
    }
    if (row < self.todos.count) {
        APTodo *todo = [self.todos objectAtIndex:row];
        todo.isComplete = checkBox.state;
    }
    [self save];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if ([tableColumn.identifier isEqualToString:@"ListCell"]) {
        APTodoListCellView *todoCellView = (APTodoListCellView*)cellView;
        if ([self.tabView.tabViewItems indexOfObject:self.tabView.selectedTabViewItem] == 0) {
            if (row < self.todos.count) {
                APTodo *todo = [self.todos objectAtIndex:row];
                todoCellView.checkBox.state = todo.isComplete;
                todoCellView.textField.stringValue = (todo.text) ? todo.text : @"";
            } else {
                todoCellView.checkBox.state = NO;
                todoCellView.textField.stringValue = @"";
            }
        } else {
            APTodo *todoForRow;
            for (APTodo *todo in self.todos) {
                todoForRow = todo;
                if (todo.isComplete && --row == -1) {
                    break;
                }
                todoForRow = nil;
            }
            if (todoForRow) {
                todoCellView.checkBox.state = todoForRow.isComplete;
                todoCellView.textField.stringValue = todoForRow.text;
            }
        }
    }
    return cellView;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    NSTextField *textfield = (NSTextField*)aNotification.object;
    NSInteger row = 0;
    if ([self.tabView.tabViewItems indexOfObject:self.tabView.selectedTabViewItem] == 0) {
        row = [self.tableView rowForView:textfield];
        if (row > -1) {
            if (row < self.todos.count) {
                APTodo *todo = [self.todos objectAtIndex:row];
                [todo setText:textfield.stringValue];
                [self save];
            } else {
                NSManagedObjectContext *context = [self managedObjectContext];
                APTodo *todo = (APTodo *)[NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:context];
                if (textfield.stringValue.length > 0) {
                    todo.text = textfield.stringValue;
                    [self save];
                    [self.tableView reloadData];
                }
            }
        }
    } else {
        row = [self.completedTableView rowForView:textfield];
    }
}


- (void)save
{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Todo" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setSortDescriptors:[self sortDescriptors]];
    NSError *error = nil;
    int totalRowCount = 0;
    
    if ([self.tabView.tabViewItems indexOfObject:self.tabView.selectedTabViewItem] == 0) {
        totalRowCount = 1;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isComplete == YES)"];
        [request setPredicate:predicate];
    }
    self.todos = [[context executeFetchRequest:request error:&error] mutableCopy];
    return self.todos.count + totalRowCount;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([self.tabView.tabViewItems indexOfObject:tabViewItem] == 0) {
        [self.tableView reloadData];
    } else {
        [self.completedTableView reloadData];
    }
}


- (NSArray *)sortDescriptors
{
	if (_sortDescriptors == nil)
	{
		_sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"viewPosition" ascending:YES]];
	}
	return _sortDescriptors;
}

@end
