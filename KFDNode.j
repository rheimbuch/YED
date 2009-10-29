@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>

/*
 * Performs a depth-first-search of an edge set,
 *  tracking each node encountered. If a node is
 *  encountered more than once, then a cycle has 
 *  been found.
 */
KFDNodeGraphHasCycles = function(aNode, traverseParents) 
{
    traverseParents = traverseParents || NO;
    var stack = []
    function isAcyclic(node){
        if([stack containsObject:node])
        {
            return false;
        }
        stack.push(node);

        var targetNode = nil;
        var nodeIter = traverseParents ? [[node inEdges] objectEnumerator] : 
                                         [[node outEdges] objectEnumerator];
        
        traverseParents ? CPLog("Traversing inEdges") : CPLog("Travering outEdges");
        
        while(targetNode = [nodeIter nextObject])
        {
            if(!isAcyclic(targetNode, traverseParents))
            {
                return false;
            }
        }
        stack.pop();
        return true;
    }
    
    return !isAcyclic(aNode);
};

@implementation KFDNode : CPObject
{
    CPSet       outEdges                @accessors(readonly);
    CPSet       inEdges                 @accessors(readonly);
    CPSet       allowsConnectionsTo      @accessors(readonly);
    CPSet       allowsConnectionsFrom    @accessors(readonly);
    
    BOOL        shouldPreventCycles     @accessors;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        outEdges = [CPSet set];
        inEdges = [CPSet set];
        allowsConnectionsTo = [CPSet setWithObject:[self class]];
        allowsConnectionsFrom = [CPSet setWithObject:[self class]];
        shouldPreventCycles = NO;
    }
    return self;
}

- (id)initAcyclic
{
    self = [self init]
    if(self)
    {
        shouldPreventCycles = YES;
    }
    return self;
}

+ (id)node
{
    return [[self alloc] init];
}

+ (id)acyclicNode
{
    return [[self alloc] initAcyclic];
}

- (BOOL)hasOutgoingEdgeTo:(KFDNode)otherNode
{
    return [outEdges containsObject:otherNode];
}

- (BOOL)hasIncomingEdgeFrom:(KFDNode)otherNode
{
    return [otherNode hasOutgoingEdgeTo:self];
}

- (void)directedEdgeTo:(KFDNode)otherNode
{
    if([self canConnectTo:otherNode])
    {
        // If the otherNode has no incoming or outgoing edges, then it cannot introduce
        //  any cycles into the graph. We test because adding a single, indepedent node 
        //  is a common case.
        var otherNodeCannotIntroduceCycles = ![[otherNode inEdges] anyObject] && ![[otherNode outEdges] anyObject];
        
        //Add the node to the graph first
        [[self outEdges] addObject:otherNode];
        [[otherNode inEdges] addObject:self];
        if(shouldPreventCycles && !nodeCannotIndroduceCycles)
        {
            if([self descendentsHaveCycles] || [self parentsHaveCycles])
            {
                //If adding the edge/connection introduces cycles, we should remove it.
                [[self outEdges] removeObject:otherNode];
                [[otherNode inEdges] removeObject:self];
                // Notify caller that we couldn't add the node
            }
            
        }
        
    }
}

- (void)directedEdgeFrom:(KFDNode)otherNode
{
    [otherNode directedEdgeTo:self];
}

/*
 * Is the node allowed to connect to another node.
 * By default all KFDNodes can connect to any other node.
 */
- (BOOL)canConnectTo:(KFDNode)otherNode
{
    var allowTo = false;
    var allowToIter = [allowsConnectionsTo objectEnumerator];
    
    var allowedNodeClass = nil;
    while(allowedNodeClass = [allowToIter nextObject])
    {
        if([otherNode isKindOfClass:allowedNodeClass])
            allowTo = true;
    }
    
    
    
    var allowFrom = false;
    var allowFromIter = [[otherNode allowsConnectionsFrom] objectEnumerator];
    
    var allowedNodeClass = nil;
    while(allowedNodeClass = [allowFromIter nextObject])
    {
        if([self isKindOfClass:allowedNodeClass])
            allowFrom = true;
    }
    
    return allowTo && allowFrom;
}

- (BOOL)canRecieveConnectionFrom:(KFDNode)otherNode
{
    return [otherNode canConnectTo:self];
}

- (CPSet)allDescendents
{
    var descendents = [CPSet set];
    
    function traverse(node) {
        [descendents unionSet:[node outEdges]];
        var iter = [[node outEdges] objectEnumerator];
        while(node = [iter nextObject])
        {
            traverse(node);
        }
    }
    traverse(self);
    return descendents;
}



- (BOOL)descendentsHaveCycles
{
    
}

- (BOOL)parentsHaveCycles
{
    
}


@end