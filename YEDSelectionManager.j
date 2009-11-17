@import <Foundation/CPNotificationCenter.j>
@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>

YEDSelectedItemNotification = "YEDSelectedItemNotification";

@implementation YEDSelectionManager : CPObject 
{
    CPSet       selectedItems;
    id          delegate        @accessors;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        selectedItems = [CPSet set];
        [[CPNotificationCenter defaultCenter] addObserver:self
                selector:@selector(selectedItemNotification:)
                name:YEDSelectedItemNotification
                object:nil];
    }
    return self;
}


- (BOOL)allowMultipleSelections
{
    return false;
}

- (void)selectItem:(id)item
{
    //Selecting a nil item deselectes all items;
    if(!item)
    {
        [self deselectAll];
        return;
    }
    if(![self handlesSelectableItem:item])
        return;
    if([selectedItems containsObject:item])
        return;
    
    if(![self allowMultipleSelections]) {
        [self deselectAll];
    }

    [selectedItems addObject:item];
    [item setIsSelected:YES];
}

- (void)deselectAll
{
    CPLog.trace("Deselecting all items");
    var itemIter = [selectedItems objectEnumerator],
        oldItem = nil;
    while(oldItem = [itemIter nextObject])
    {
        [oldItem setIsSelected:NO];
        [selectedItems removeObject:oldItem];
    }
}

/**
    Handles selection notifications from selectable views
*/
- (void)selectedItemNotification:(CPNotification)notification
{
    var item = [notification object],
        info = [notification userInfo],
        mouseDown  = [info objectForKey:@"mouseDown"];
        
    [self selectItem:item];
}

/**
    Ask the delegate if we should handle a given item
*/
- (BOOL)handlesSelectableItem:(id)item
{
    if(!([item respondsToSelector:@selector(isSelected)] && [item respondsToSelector:@selector(setIsSelected:)]))
        return false;
    
    if([delegate respondsToSelector:@selector(selectionManager:shouldHandle:)])
        return [delegate selectionManager:self shouldHandle:item];
    else
        false;
}



@end