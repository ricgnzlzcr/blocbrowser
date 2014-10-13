//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Ricardo Gonzalez on 10/3/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIButton *currentButton;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
        
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            button.backgroundColor = colorForThisButton;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            //Testing way to get the button I need
            [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(buttonTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
    
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

- (void) layoutSubviews {
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Touch Handling

- (UIButton *) buttonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UIButton *)subview;
}

- (void)buttonTouched:(UIButton *)button {
    NSLog(@"Button touched. yup");
    self.currentButton = button;
    self.currentButton.alpha = 0.5;
}

- (void)buttonTouchEnded:(UIButton *)button {
    self.currentButton = button;
    self.currentButton.alpha = 1;
    
    NSString *buttonString = button.titleLabel.text;
    
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:buttonString];
    }
    
    self.currentButton = nil;
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //UILabel *label = [self labelFromTouches:touches withEvent:event];
    UIButton *button = [self buttonFromTouches:touches withEvent:event];
    //self.currentLabel = label;
    //self.currentLabel.alpha = 0.5;
    self.currentButton = button;
    self.currentButton.alpha = 0.5;
    
}
 */


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   
    
    UIButton *button = [self buttonFromTouches:touches withEvent:event];
    
    if (self.currentButton != button) {
        // The label being touched is no longer the initial label
        self.currentButton.alpha = 1;
    } else {
        // The label being touched is the initial label
        self.currentButton.alpha = 0.5;
    }
}




- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   // self.currentLabel.alpha = 1;
   // self.currentLabel = nil;
    self.currentButton.alpha = 1;
    self.currentButton = nil;
}


- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchToolbar:)]) {
            [self.delegate floatingToolbar:self didPinchToolbar:recognizer];
        }
        
        NSLog(@"Pinching");
        
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press occured");
        
        NSMutableArray *oldColors = [self.colors mutableCopy];
        
        for (int i = 0; i < 4; i++) {
            if (i > 0) {
                oldColors[i] = self.colors[i - 1];
            } else {
                oldColors[0] = self.colors[3];
            }
        }
        
        self.colors = [oldColors copy];
        
        
        NSMutableArray *replacementButtons = [self.buttons mutableCopy];
        int index = 0;
        for (UIButton *button in replacementButtons) {
            button.backgroundColor = oldColors[index];
            index++;
        }
        self.buttons = [replacementButtons copy];
        
        
    }
}


#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
