@import "KFDNode.j"
@import "KFDSubjectNode.j"

@implementation KFDOperationNode : KFDNode
{
    
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [[self allowsConnectionsFrom] removeAllObjects];
        [[self allowsConnectionsFrom] addObject:KFDSubjectNode];
        
        [[self allowsConnectionsTo] removeAllObjects];
        [[self allowsConnectionsTo] addObject:KFDSubjectNode];
        
        [self setIsAcyclic:YES];
    }
    return self;
}

@end