@import <AppKit/CPViewController.j>
@import "KFDGraph.j"
@import "KFDGraphView.j"
@import "KFDNodeViewRegistry.j"

@implementation KFDGraphViewController : CPViewController 
{
    CPArray                 nodeViews;
    KFDNodeViewRegistry     nodeViewRegistry    @accessors;
    CPArray                 edgeViews;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        nodeViews = [];
        nodeViewRegistry = [KFDNodeViewRegistry registry];
        edgeViews = [];
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
        if(![self viewForNode:node])
            [self addNodeToView:node];
        
        var edgeIter = [[node outEdges] objectEnumerator],
            endNode = nil;
        
        while(endNode = [edgeIter nextObject])
        {
            if(![self viewForNode:endNode])
                [self addNodeToView:endNode];
            [self addEdgeToViewFrom:node to:endNode];
        }
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
    [center addObserver:self
            selector:@selector(graphEdgeAdded:)
            name:KFDGraphEdgeAddedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphEdgeRemoved:)
            name:KFDGraphEdgeRemovedNotification
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
    [center removeObserver:self
            name:KFDGraphEdgeAddedNotification
            object:graph];
    [center removeObserver:self
            name:KFDGraphEdgeRemovedNotification
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

- (void)graphEdgeAdded:(CPNotification)notification
{
    CPLog.trace("KFDGraphViewController: graphEdgeAdded");
    var startNode = [[notification userInfo] objectForKey:"fromNode"],
        endNode = [[notification userInfo] objectForKey:"toNode"];
    [self addEdgeToViewFrom:startNode to:endNode];
}

- (void)graphEdgeRemoved:(CPNotification)notification
{
    CPLog.trace("KFDGraphViewController: graphEdgeRemoved");
    var startNode = [[notification userInfo] objectForKey:"fromNode"],
        endNode = [[notification userInfo] objectForKey:"toNode"];
    [self removeEdgeFromViewFrom:startNode to:endNode];
}

- (void)addNodeToView:(KFDNode)node
{
    // If the node isn't already in the graph, we don't want to add it to the view
    if(![[self graph] containsNode:node])
        return;
    
    var view = [nodeViewRegistry viewFor:node];
    var graphCenter = [[self view] center];
    [view setCenter: [[self view] convertPoint:graphCenter fromView:nil]];
    
    var randPointShift = function(point, scale)
    {
        scale = scale || 100;
        var randX = (Math.random() - 0.5) * scale,
            randY = (Math.random() - 0.5) * scale;
        return CGPointMake(point.x + randX, point.y + randY);
    };
    
    var origin = [view frameOrigin];
    [view setFrameOrigin:randPointShift(origin, 200)];
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

- (KFDNodeView)viewForNode:(KFDNode)node
{
    if(![[self graph] containsNode:node])
        return;
    
    var viewIter = [nodeViews objectEnumerator];
    var view = nil
    while(view = [viewIter nextObject])
    {
        if([view representedObject] === node)
        {
            return view;
        }
    }
}

- (void)addEdgeToViewFrom:(KFDNode)start to:(KFDNode)end
{
    CPLog.trace("KFDGraphViewController: addEdgeToViewFrom:to:");
    console.debug(start, end);
    CPLog.trace([[self graph] containsEdgeFromNode:start toNode:end]);
    if(![[self graph] containsEdgeFromNode:start toNode:end])
        return;
    
    CPLog.trace("KFDGraphViewController: addEdgeToViewFrom:to: retrieving views");
    var startView = [self viewForNode:start],
        endView = [self viewForNode:end];
    
    if(!startView || !endView)
        return;
    
    CPLog.trace("KFDGraphViewController: addEdgeToViewFrom:to: creating Edge View");
    var edgeView = [KFDEdgeView edgeFromView:startView toView:endView];
    [edgeViews addObject:edgeView];
    [[self view] addEdgeView:edgeView];
}

- (void)removeEdgeFromViewFrom:(KFDNode)start to:(KFDNode)end
{
    if([[self graph] containsEdgeFromNode:start toNode:end])
        return;
    
    var startView = [self viewForNode:start],
        endView = [self viewForNode:end];
    
    if(!startView || !endView)
        return;
    
    var viewIter = [edgeViews objectEnumerator],
        view = nil;
        
    while(view = [viewIter nextObject])
    {
        if([view startNodeView] === startView && [view endNodeView] === endView)
        {
            [edgeViews removeObject:view];
            [view setStartNodeView:nil];
            [view setEndNodeView:nil];
            [view removeFromSuperview];
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