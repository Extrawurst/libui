// 14 august 2015
#import "uipriv_darwin.h"

@interface libui_spinbox : NSView<NSTextFieldDelegate> {
	NSTextField *tf;
	NSNumberFormatter *formatter;
	NSStepper *stepper;

	NSInteger value;
	NSInteger minimum;
	NSInteger maximum;

	uiSpinbox *spinbox;
}
- (id)initWithFrame:(NSRect)r spinbox:(uiSpinbox *)sb;
// see https://github.com/andlabs/ui/issues/82
- (NSInteger)libui_value;
- (void)libui_setValue:(NSInteger)val;
- (void)setMinimum:(NSInteger)min;
- (void)setMaximum:(NSInteger)max;
- (IBAction)stepperClicked:(id)sender;
- (void)controlTextDidChange:(NSNotification *)note;
@end

struct uiSpinbox {
	uiDarwinControl c;
	libui_spinbox *spinbox;
	void (*onChanged)(uiSpinbox *, void *);
	void *onChangedData;
};

@implementation libui_spinbox

- (id)initWithFrame:(NSRect)r spinbox:(uiSpinbox *)sb
{
	self = [super initWithFrame:r];
	if (self) {
		self->tf = newEditableTextField();
		[self->tf setTranslatesAutoresizingMaskIntoConstraints:NO];

		self->formatter = [NSNumberFormatter new];
		[self->formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[self->formatter setLocalizesFormat:NO];
		[self->formatter setUsesGroupingSeparator:NO];
		[self->formatter setHasThousandSeparators:NO];
		[self->formatter setAllowsFloats:NO];
		[self->tf setFormatter:self->formatter];

		self->stepper = [[NSStepper alloc] initWithFrame:NSZeroRect];
		[self->stepper setIncrement:1];
		[self->stepper setValueWraps:NO];
		[self->stepper setAutorepeat:YES];              // hold mouse button to step repeatedly
		[self->stepper setTranslatesAutoresizingMaskIntoConstraints:NO];

		[self->tf setDelegate:self];
		[self->stepper setTarget:self];
		[self->stepper setAction:@selector(stepperClicked:)];

		[self addSubview:self->tf];
		[self addSubview:self->stepper];

		[self addConstraint:mkConstraint(self->tf, NSLayoutAttributeLeading,
			NSLayoutRelationEqual,
			self, NSLayoutAttributeLeading,
			1, 0,
			@"uiSpinbox left edge")];
		[self addConstraint:mkConstraint(self->stepper, NSLayoutAttributeTrailing,
			NSLayoutRelationEqual,
			self, NSLayoutAttributeTrailing,
			1, 0,
			@"uiSpinbox right edge")];
		[self addConstraint:mkConstraint(self->tf, NSLayoutAttributeTop,
			NSLayoutRelationEqual,
			self, NSLayoutAttributeTop,
			1, 0,
			@"uiSpinbox top edge text field")];
		[self addConstraint:mkConstraint(self->tf, NSLayoutAttributeBottom,
			NSLayoutRelationEqual,
			self, NSLayoutAttributeBottom,
			1, 0,
			@"uiSpinbox bottom edge text field")];
		[self addConstraint:mkConstraint(self->stepper, NSLayoutAttributeTop,
			NSLayoutRelationEqual,
			self, NSLayoutAttributeTop,
			1, -1,			// TODO make sure this is right
			@"uiSpinbox top edge stepper")];
		[self addConstraint:mkConstraint(self->stepper, NSLayoutAttributeBottom,
			NSLayoutRelationEqual,
			self, NSLayoutAttributeBottom,
			1, -1,		// TODO make sure this is right
			@"uiSpinbox bottom edge stepper")];
		[self addConstraint:mkConstraint(self->tf, NSLayoutAttributeTrailing,
			NSLayoutRelationEqual,
			self->stepper, NSLayoutAttributeLeading,
			1, -3,		// TODO
			@"uiSpinbox space between text field and stepper")];

		self->spinbox = sb;
	}
	return self;
}

- (void)dealloc
{
	[self->tf setDelegate:nil];
	[self->tf removeFromSuperview];
	[self->tf release];
	[self->formatter release];
	[self->stepper setTarget:nil];
	[self->stepper removeFromSuperview];
	[self->stepper release];
	[super dealloc];
}

- (NSInteger)libui_value
{
	return self->value;
}

- (void)libui_setValue:(NSInteger)val
{
	self->value = val;
	if (self->value < self->minimum)
		self->value = self->minimum;
	if (self->value > self->maximum)
		self->value = self->maximum;
	[self->tf setIntegerValue:self->value];
	[self->stepper setIntegerValue:self->value];
}

- (void)setMinimum:(NSInteger)min
{
	self->minimum = min;
	[self->formatter setMinimum:[NSNumber numberWithInteger:self->minimum]];
	[self->stepper setMinValue:((double) (self->minimum))];
}

- (void)setMaximum:(NSInteger)max
{
	self->maximum = max;
	[self->formatter setMaximum:[NSNumber numberWithInteger:self->maximum]];
	[self->stepper setMaxValue:((double) (self->maximum))];
}

- (IBAction)stepperClicked:(id)sender
{
	[self libui_setValue:[self->stepper integerValue]];
	(*(self->spinbox->onChanged))(self->spinbox, self->spinbox->onChangedData);
}

- (void)controlTextDidChange:(NSNotification *)note
{
	[self libui_setValue:[self->tf integerValue]];
	(*(self->spinbox->onChanged))(self->spinbox, self->spinbox->onChangedData);
}

@end

uiDarwinControlAllDefaults(uiSpinbox, spinbox)

intmax_t uiSpinboxValue(uiSpinbox *s)
{
	return [s->spinbox libui_value];
}

void uiSpinboxSetValue(uiSpinbox *s, intmax_t value)
{
	[s->spinbox libui_setValue:value];
}

void uiSpinboxOnChanged(uiSpinbox *s, void (*f)(uiSpinbox *, void *), void *data)
{
	s->onChanged = f;
	s->onChangedData = data;
}

static void defaultOnChanged(uiSpinbox *s, void *data)
{
	// do nothing
}

uiSpinbox *uiNewSpinbox(intmax_t min, intmax_t max)
{
	uiSpinbox *s;

	// TODO implicitly swap instead?
	if (min >= max)
		userbug("min >= max is invalid for a uiSpinbox.");

	uiDarwinNewControl(uiSpinbox, s);

	s->spinbox = [[libui_spinbox alloc] initWithFrame:NSZeroRect spinbox:s];
	[s->spinbox setMinimum:min];
	[s->spinbox setMaximum:max];
	[s->spinbox libui_setValue:min];

	uiSpinboxOnChanged(s, defaultOnChanged, NULL);

	return s;
}
