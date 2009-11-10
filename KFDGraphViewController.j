@import <AppKit/CPViewController.j>
@import "KFDGraph.j"
@import "KFDGraphView.j"
@import "KFDNodeViewRegistry.j"

@implementation KFDGraphViewController : CPViewController 
{
    CPArray                 nodeViews;
    KFDNodeViewRegistry     nodeViewRegistry    @accessors;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        nodeViews = [];
        nodeViewRegistry = [KFDNodeViewRegistry registry];

    }
    return self;
}

// - (void)loadRepresentedObject
// {
//     [self setRepresentedObject: [KFDGraph graph]];
// }

- (void)loadView
{
    if(_view)
        return;
    
    _view = [[KFDGraphView alloc] init];
}

- (void)_loadNodeViewsFromGraph
{
    if(!_representedObject)
        return;
    
    
    [nodeViews removeAllObjects];
    [[self view] removeAllNodeViews];
    
    var nodeIter = [[[self representedObject] nodes] objectEnumerator];
    var node = nil;
    while(node = [nodeIter nextObject])
    {
        [self addNodeToView:node];
    }
}

- (void)_setupObservers
{
    var center = [CPNotificationCenter defaultCenter];
    var graph = [self representedObject];
    
    [center addObserver:self 
            selector:@selector(graphNodeAdded:) 
            name:KFDGraphNodeAddedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphNodeRemoved:)
            name:KFDGraphNodeRemovedNotification
            object:graph];
    
}

- (void)_removeObservers
{
    var center = [CPNotificationCenter defaultCenter];
    var graph = [self representedObject];
    
    [center removeObserver:self
            name:KFDGraphNodeAddedNotification
            object:graph];
    [center removeObserver:self
            name:KFDGraphNodeRemovedNotification
            object:graph];
}

- (void)graphNodeAdded:(CPNotification)notification
{
    var node = [[notification userInfo] objectForKey:"node"];
    [self addNodeToView:node];
}

- (void)graphNodeRemoved:(CPNotification)notification
{
    var node = [[notification userInfo] objectForKey:"node"];
    [self removeNodeFromView:node];
}

- (void)addNodeToView:(KFDNode)node
{
    // If the node isn't already in the graph, we don't want to add it to the view
    if(![[self graph] containsNode:node])
        return;
    
    var view = [nodeViewRegistry viewFor:node];
    [nodeViews addObject:view];
    [[self view] addNodeView:view];
}

- (void)removeNodeFromView:(KFDNode)node
{
    // If the node is still in the graph, we don't want to remove it from the view
    if([[self graph] containsNode:node])
        return;
    // Find the nodeview associated with this node and remove it
    var viewIter = [nodeViews objectEnumerator];
    var view = nil
    while(view = [viewIter nextObject])
    {
        if([view representedObject] === node)
        {
            [view removeFromSuperview];
            [nodeViews removeObject:view];
            [view setRepresentedObject:nil];
            
            return;
        }
    }
}

- (void)setRepresentedObject:(id)object
{
    if([self representedObject])
    {
        [self _removeObservers];
    }
    [super setRepresentedObject:object];
    
    [self _loadNodeViewsFromGraph];
    [self _setupObservers];
}

- (void)graph
{
    return [self representedObject];
}

- (void)setGraph:(KFDGraph)aGraph
{
    [self willChangeValueForKey:@"graph"];
    [self setRepresentedObject:aGraph];
    [self didChangeValueForKey:@"graph"];
}



@end