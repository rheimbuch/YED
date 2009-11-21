@import "YEDNode.j"
@import "YEDOperationNode.j"

@implementation YEDSubjectNode : YEDNode
{
    
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [[self allowsConnectionsFrom] removeAllObjects];
        [[self allowsConnectionsFrom] addObject:[YEDOperationNode className]];
        
        [[self allowsConnectionsTo] removeAllObjects];
        [[self allowsConnectionsTo] addObject:[YEDOperationNode className]];
        
        [self setIsAcyclic:YES];
    }
    return self;
}

@end