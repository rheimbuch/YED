@import "KFDNode.j"
@import "KFDOperationNode.j"

@implementation KFDSubjectNode : KFDNode
{
    
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [[self allowsConnectionsFrom] removeAllObjects];
        [[self allowsConnectionsFrom] addObject:KFDOperationNode];
        
        [[self allowsConnectionsTo] removeAllObjects];
        [[self allowsConnectionsTo] addObject:KFDOperationNode];
        
        [self setIsAcyclic:YES];
    }
    return self;
}

@end