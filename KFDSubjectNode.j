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
        [[self allowConnectionsFrom] removeAllObjects];
        [[self allowConnectionsFrom] addObject:KFDOperationNode];
        
        [[self allowConnectionsTo] removeAllObjects];
        [[self allowConnectionsTo] addObject:KFDOperationNode];
        
        [self setShouldPreventCycles:YES];
    }
    return self;
}

@end