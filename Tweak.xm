@interface TableViewRetainColor : UIView

@property (nonatomic, retain) UIColor *oldBackgroundColor;

@end

@implementation TableViewRetainColor

@end


%group ForLater

		%hook HookerAndSinker

		- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
		{
			%orig;
			tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			//if (cell.backgroundView == nil || (cell.backgroundView != nil && ![cell.backgroundView isKindOfClass:[TableViewRetainColor class]])){
				CGFloat cornerRadius = 5.f;
				CAShapeLayer *layer = [[CAShapeLayer alloc] init];
				CGMutablePathRef pathRef = CGPathCreateMutable();
				CGRect bounds = CGRectInset(cell.bounds, 10, 0);
				BOOL addLine = NO;
				if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
				    CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
				} else if (indexPath.row == 0) {
				    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
				    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
				    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
				    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
				    addLine = YES;
				} else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
				    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
				    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
				    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
				    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
				} else {
				    CGPathAddRect(pathRef, nil, bounds);
				    addLine = YES;
				}
				layer.path = pathRef;
				CFRelease(pathRef);
				layer.fillColor = cell.backgroundColor.CGColor;

				if (addLine == YES) {
				    CALayer *lineLayer = [[CALayer alloc] init];
				    CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
				    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
				    lineLayer.backgroundColor = tableView.separatorColor.CGColor;
				    [layer addSublayer:lineLayer];
				}

				if (cell.backgroundView != nil && [cell.backgroundView isKindOfClass:[TableViewRetainColor class]]){
					layer.fillColor = [(TableViewRetainColor *)cell.backgroundView oldBackgroundColor].CGColor;
					[cell.backgroundView.layer replaceSublayer:cell.backgroundView.layer.sublayers[0] with:layer];
				} else {
					TableViewRetainColor *testView = [[TableViewRetainColor alloc] initWithFrame:bounds];
					testView.oldBackgroundColor = cell.backgroundColor;
					[testView.layer insertSublayer:layer atIndex:0];
					testView.backgroundColor = UIColor.clearColor;
					if (cell.backgroundView != nil && ![cell.backgroundView isKindOfClass:[TableViewRetainColor class]]){
						[testView addSubview:cell.backgroundView];
					} else {

					}
					cell.backgroundColor = UIColor.clearColor;
					cell.backgroundView = testView;
				}

			//}
		}

		%end

%end

void shiiiiitttt(id self, SEL _cmd, UITableView *arg1, UITableViewCell *arg2, NSIndexPath* arg3){}

%hook UITableView

-(void)setDelegate:(id)arg1{
	
	if(![arg1 respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]){
		class_addMethod([arg1 class], @selector(tableView:willDisplayCell:forRowAtIndexPath:), (IMP)shiiiiitttt, "@@:@@");
	}

	%init(ForLater, HookerAndSinker = [arg1 class]);
	%orig;
	self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

%end

%ctor{
	%init;
}