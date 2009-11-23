@import <AppKit/CPBox.j>
@import <AppKit/CPView.j>

@implementation YEDNodeViewCollectionItem : CPView
{
    CPTextField nameField;
    CPBox       boxView;
}

- (void)setRepresentedObject:(id)object
{
    if(!nameField)
    {
        nameField = [[CPTextField alloc] initWithFrame:CGRectMake(100,15,145,20)];
        [nameField setFont:[CPFont boldSystemFontOfSize:12.0]];
        [self addSubview:nameField];
    }
    
    [nameField setStringValue:[[object representedObject] name]];
    
    if(!boxView)
    {
        boxView = [[CPBox alloc] initWithFrame:CGRectMake(25,0,50,50)];
        [self addSubview:boxView];
    }
    [boxView setBorderType:CPLineBorder];
    [boxView setBorderColor:[object borderColor]];
    [boxView setBorderWidth:[object borderWidth]];
    [boxView setCornerRadius:[object cornerRadius]];
    [boxView setFillColor:[object fillColor]];
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor blueColor] : nil];
    [nameField setTextColor:isSelected ? [CPColor whiteColor] : [CPColor blackColor]];
}

@end