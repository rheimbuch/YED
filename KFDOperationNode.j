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
        [[self allowConnectionsFrom] removeAllObjects];
        [[self allowConnectionsFrom] addObject:KFDSubjectNode];
        
        [[self allowConnectionsTo] removeAllObjects];
        [[self allowConnectionsTo] addObject:KFDSubjectNode];
        
        [self setIsAcyclic:YES];
    }
    return self;
}

@end