@import "YEDNode.j"
@import "YEDSubjectNode.j"

@implementation YEDOperationNode : YEDNode
{
    
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [[self allowsConnectionsFrom] removeAllObjects];
        [[self allowsConnectionsFrom] addObject:YEDSubjectNode];
        
        [[self allowsConnectionsTo] removeAllObjects];
        [[self allowsConnectionsTo] addObject:YEDSubjectNode];
        
        [self setIsAcyclic:YES];
    }
    return self;
}

@end