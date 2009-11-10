@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>
@import <Foundation/CPException.j>
@import <Foundation/CPNotificationCenter.j>
@import "KFDNode.j"

// Exceptions
KFDGraphCannotCreateDirectedEdgeException = @"KFDGraphCannotCreateDirectedEdgeException";
KFDGraphNodeTypeNotAllowedException = @"KFDGraphNodeTypeNotAllowedException";

// Notifications
KFDGraphNodeAddedNotification = @"KFDGraphNodeAddedNotification";
KFDGraphNodeRemovedNotification = @"KFDGraphNodeRemovedNotification";
KFDGraphEdgeNotAllowedNotification = @"KFDGraphEdgeNotAllowedNotification";
KFDGraphEdgeWouldCauseCycleNotification = @"KFDGraphEdgeWouldCauseCycleNotification";
KFDGraphEdgeAddedNotification = @"KFDGraphEdgeAddedNotification";
KFDGraphEdgeRemovedNotification = @"KFDGraphEdgeRemovedNotification"
@implementation KFDGraph : CPObject
{
    CPSet   nodes       @accessors;
    CPSet   allowedNodeTypes;
    id      delegate    @accessors;
}


- (id)init
{
    self = [super init];
    if(self)
    {
        nodes = [CPSet set];
        allowedNodeTypes = [CPSet setWithObject:KFDNode];
    }
    return self;
}

- (id)initWithNodes:(CPArray)otherNodes
{
    var self = [self init];
    if(self)
    {
        var nodeIter = [otherNodes objectEnumerator];
        var otherNode = nil;
    
        while(otherNode = [nodeIter nextObject])
        {
            [self addNode:otherNode];
        }
    }
    return self;
}

+ (id)graph
{
    return [[self alloc] init];
}

+ (id)graphWithNodes:(CPArray)nodes
{
    return [[self alloc] initWithNodes:nodes];
}

- (void)addNode:(KFDNode)aNode
{
    if([self allowsNode:aNode]) 
    {
        if([delegate respondsToSelector:@selector(willAddNode:toGraph:)])
            [delegate willAddNode:aNode toGraph:self];
            
        [nodes addObject:aNode];
        
        if([delegate respondsToSelector:@selector(didAddNode:toGraph:)])
            [delegate didAddNode:aNode toGraph:self];
    }
}

- (void)removeNode:(KFDNode)aNode
{
    if([nodes containsObject:aNode])
    {
        if([delegate respondsToSelector:@selector(willRemoveNode:fromGraph:)])
            [delegate willRemoveNode:aNode fromGraph:self];
            
        [aNode disconnectFromAllNodes];
        [nodes removeObject:aNode];
            
        if([delegate respondsToSelector:@selector(didRemoveNode:fromGraph:)])
            [delegate didRemoveNode:aNode fromGraph:self];
    }
}

- (void)createDirectedEdgeFrom:(KFDNode)fromNode to:(KFDNode)toNode
{ 
    // if(![nodes containsObject:fromNode])
    //     [self addNode:fromNode];
    // 
    // if(![nodes containsObject:toNode])
    //     [self addNode:toNode];
    
    // If the nodes aren't in the nodes set, then they aren't allowed
    if(![nodes containsObject:fromNode] || ![nodes containsObject:toNode])
    {
        [CPException raise:KFDGraphCannotCreateDirectedEdge reason:"One of the nodes is not in the graph."];
        return;
    }
        
    if([delegate respondsToSelector:@selector(willAddEdgeFrom:to:inGraph:)])
        [delegate willAddEdgeFrom:fromNode to:toNode inGraph:self];
        
    [fromNode directedEdgeTo:toNode];
    
    if([delegate respondsToSelector:@selector(didAddEdgeFrom:to:inGraph:)])
        [delegate didAddEdgeFrom:fromNode to:toNode inGraph:self];
}

- (void)removeDirectedEdgeFrom:(KFDNode)fromNode to:(KFDNode)toNode
{
    // Only remove the edge if both nodes are in the graph
    if(![nodes containsObject:fromNode] || ![nodes containsObject:toNode])
        return;
    
    if([delegate respondsToSelector:@selector(willRemoveEdgeFrom:to:inGraph:)])
        [delegate willRemoveEdgeFrom:fromNode to:toNode inGraph:self];
        
    [fromNode removeDirectedEdgeTo:toNode];
    
    if([delegate respondsToSelector:@selector(didRemoveEdgeFrom:to:inGraph:)])
        [delegate didRemoveEdgeFrom:fromNode to:toNode inGraph:self];
}

- (BOOL)containsNode:(KFDNode)aNode
{
    return [nodes containsObject:aNode];
}

- (void)allowsNode:(KFDNode)aNode
{
    var isAllowed = NO,
        allowedNodeTypeIter = [allowedNodeTypes objectEnumerator],
        allowedNodeType = nil;
    
    while(allowedNodeType = [allowedNodeTypeIter nextObject])
    {
        if([aNode isKindOfClass:allowedNodeType])
        {
            isAllowed = YES;
            break;
        }
    }
    return isAllowed;
}



@end