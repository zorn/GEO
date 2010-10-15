
#import "CPTimeFormatter.h"

/**	@brief A number formatter that converts time intervals to dates.
 *  Useful for formatting labels on an axis. If you choose the numerical 
 *  scale of the plot space to be in seconds, axis labels can be directly
 *  generated by setting a CPTimeFormatter as the tickLabelFormatter.
 **/
@implementation CPTimeFormatter

/**	@property dateFormatter
 *  @brief The date formatter used to generate strings from time intervals.
 **/
@synthesize dateFormatter;

/**	@property referenceDate
 *  @brief Date from which time intervals are taken.
 *  If nil, the standard reference date (1 January 2001, GMT) is used.
 **/
@synthesize referenceDate;

#pragma mark -
#pragma mark Init/Dealloc

/**	@brief Initializes new instance with a default date formatter.
 *	The default formatter uses <code>NSDateFormatterMediumStyle</code> for dates and times.
 *	@return The new instance.
 **/
-(id)init
{
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    newDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    newDateFormatter.timeStyle = NSDateFormatterMediumStyle;
	
	self = [self initWithDateFormatter:newDateFormatter];
	[newDateFormatter release];
	
    return self;
}

/**	@brief Initializes new instance with the date formatter passed.
 *	@param aDateFormatter The date formatter.
 *	@return The new instance.
 **/
-(id)initWithDateFormatter:(NSDateFormatter *)aDateFormatter
{
	if ( self = [super init] ) {
		dateFormatter = [aDateFormatter retain];
		referenceDate = nil;
	}
	return self;	
}

-(void)dealloc
{
    [referenceDate release];
	[dateFormatter release];
	[super dealloc];
}

#pragma mark -
#pragma mark Formatting

/**	@brief Converts decimal number for the time into a date string.
 *  Uses the date formatter to do the conversion. Conversions are relative to the
 *  reference date, unless it is nil, in which case the standard reference date
 *  of 1 January 2001, GMT is used.
 *	@param coordinateValue The time value.
 *	@return The date string.
 **/
-(NSString *)stringForObjectValue:(NSDecimalNumber *)coordinateValue
{
	NSDate *date;
    if ( self.referenceDate ) 
        date = [[NSDate alloc] initWithTimeInterval:[coordinateValue doubleValue] sinceDate:self.referenceDate];
    else
        date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[coordinateValue doubleValue]];
	NSString *string = [self.dateFormatter stringFromDate:date];
    [date release];
    return string;
}

@end
