//
//  DotView.m
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "DotView.h"
#import "Angelina_AppDelegate.h"

@implementation DotView

@synthesize isEZMode,slate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor=[UIColor clearColor];
		isEZMode=YES;
		currentPuzzle=-1;
		touchBeganDot=-1;
		red=[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"reddot" ofType:@"png"]];
		blue=[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bluedot" ofType:@"png"]];
		black=[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackdot" ofType:@"png"]];
		blue_active=[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bluedot_active" ofType:@"png"]];
		startHere=[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dotsstartheretext" ofType:@"png"]]];
		lines=[[NSMutableArray alloc] init];
		dots=[[NSMutableArray alloc] init];
		dotImages=[[NSMutableArray alloc] init];
		//start animation loop
		timer=[[NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(run) userInfo:nil repeats:YES] retain];
    }
    return self;
}

-(void)setPuzzle:(int)puzzle{
	//if (puzzle!=currentPuzzle){
		[self initPuzzle:puzzle :isEZMode];
	//}
}

-(void) setDifficulty:(BOOL)ezMode{
	//if (ezMode!=isEZMode) {
		[self initPuzzle:currentPuzzle :ezMode];
	//}
}

-(void)initPuzzle:(int)puzzle :(BOOL)ezMode{
	//remove any old stuff
	while ([[self subviews] count]>0) {
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	}
	while ([[slate subviews] count]>0) {
		[[[slate subviews] objectAtIndex:0] removeFromSuperview];
	}
	[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
	[lines removeAllObjects];
	[dots removeAllObjects];
	[dotImages removeAllObjects];	
	self.alpha=1.0;
	//reset
	isEZMode=ezMode;
	nextDot=0;
	currentPuzzle=puzzle;
	furthestDot=0;
	errors=0;
	
	//get the array for the current image and mode
	NSArray *array;
	NSString *eh=ezMode?@"easy":@"hard";
	array=[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"dots%d_%@",(currentPuzzle+1),eh] ofType:@"plist"]];
	
	for (uint i=0; i<[array count]; ++i) {
		//load data for lines
		Dot *data=[Dot dotWithDictionary:[array objectAtIndex:i]];
		[lines addObject:data];
		if (data.dotNum!=-1) {
			//load image for dot
			[dots addObject:data];
			DotImageView *dot=[[[DotImageView alloc] initWithImage:black] autorelease];
			dot.userInteractionEnabled=YES;
			dot.index=data.dotNum;
			UIImageView *number=[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"dotnumber_%d",(data.dotNum+1)] ofType:@"png"]]] autorelease];
			[dot addSubview:number];
			dot.frame=CGRectMake(data.dotX-20, data.dotY-20, dot.frame.size.width, dot.frame.size.height);
			[self addSubview:dot];
			[dotImages addObject:dot];
		}
	}
	//mark first dot
	((Dot*)[dots objectAtIndex:0]).dotState=1;
	((UIImageView*)[dotImages objectAtIndex:0]).image=blue_active;
	if (ezMode) {
		//show "start here" only in easy mode
		startHere.frame=CGRectMake([[[array objectAtIndex:0] objectForKey:@"startX"] floatValue], [[[array objectAtIndex:0] objectForKey:@"startY"] floatValue], startHere.frame.size.width, startHere.frame.size.height);
		[self addSubview:startHere];
	}	
	[self setNeedsDisplay];
	
	UIImageView *image=[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"dotimage_%d",(currentPuzzle+1)] ofType:@"png"]]] autorelease];
	image.alpha = 1.0;
	[self addSubview:image];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:3.0f];
	image.alpha = 0;
	[UIView commitAnimations];
}
  
  

-(void)dotTouchBegan:(DotImageView *)dot{
	if (nextDot==-1 || nextDot>dot.index) {
		return;
	}
	touchBeganDot=dot.index;	 
}

-(void)dotTouchEnded:(DotImageView *)dot{
	if (nextDot==-1 || nextDot>dot.index) {
		return;
	}
	if (touchBeganDot==dot.index && ((Dot*)[dots objectAtIndex:dot.index]).dotState!=-1) {
		//clicking the first dot is optional
		if (nextDot==0 && touchBeganDot==1) {
			((UIImageView*)[dotImages objectAtIndex:nextDot]).image=blue;
			((Dot*)[dots objectAtIndex:nextDot]).dotState=-2;
			++nextDot;
			if (isEZMode) {
				[startHere removeFromSuperview];
			}			
		}		
		if (touchBeganDot==nextDot) {
			//clicked the correct dot
			
			errors=0;
			
			if (nextDot==0 && isEZMode) {
				//remove "start here
				[startHere removeFromSuperview];
			}
			
			//if (touchBeganDot==(int)[dots count]-1) {
				//fade in image
				//do this after line drawing is complete instead
			//}
			
			//set dot as clicked
			((UIImageView*)[dotImages objectAtIndex:nextDot]).image=blue;
			((Dot*)[dots objectAtIndex:nextDot]).dotState=-2;
			
			++nextDot;
			if (nextDot==(int)[dots count]) {
				//we're done
				nextDot=-1;
			}else if (isEZMode) {
				//indicate next dot if we're playing easymode
				((UIImageView*)[dotImages objectAtIndex:nextDot]).image=blue_active;
			}
			[self playSound:0];
			//instantly draws line
			//[self setFurthestDot];
		}else {
			++errors;
			if (errors==3 && !isEZMode) {
				((UIImageView*)[dotImages objectAtIndex:nextDot]).image=blue_active;
			}
			//clicked the wrong dot, make it red for a second
			((UIImageView*)[dotImages objectAtIndex:dot.index]).image=red;
			Dot* errorDot=[dots objectAtIndex:dot.index];
			errorDot.dotState=-1;
			[self performSelector:@selector(restoreRedDot:) withObject:errorDot afterDelay:1.0f];
			[self playSound:1];
		}
		[self setNeedsDisplay];
	}
	touchBeganDot=-1;
}

-(void)setFurthestDot{
	//instantly advance line to next dot
	Dot* dot=[lines objectAtIndex:furthestDot];
	while (true){
		if (dot.dotNum>=nextDot-1 && nextDot!=-1) {
			break;
		}
		if (furthestDot==(int)[lines count]-1) {
			break;
		}
		++furthestDot;
		dot=[lines objectAtIndex:furthestDot];
	}
}

-(void)run{
	//gradually advance line to next dot
	if (lines==nil || [lines count]==0 || nextDot==0 || nextDot==1) {
		return;
	}
	if ([[slate subviews] count]!=0) {
		return;
	}
	Dot* dot=[lines objectAtIndex:furthestDot];
	if (dot.dotNum>=nextDot-1 && nextDot!=-1) {
		return;
	}
	if (furthestDot==(int)[lines count]-1) {
		UIImageView *image=[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"dotimage_%d",(currentPuzzle+1)] ofType:@"png"]]] autorelease];
		image.alpha = 0.0;
		[slate addSubview:image];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:1.0f];
		image.alpha = 1.0;
		self.alpha=0;
		[UIView commitAnimations];
		[self playSound:2];
		return;
	}
	++furthestDot;
	[self setNeedsDisplay];
}

-(void)restoreRedDot:(Dot*)dot{
	((UIImageView*)[dotImages objectAtIndex:dot.dotNum]).image=black;
	dot.dotState=0;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	if (lines==nil || [lines count]==0 || nextDot==0 || nextDot==1) {
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextSetLineWidth(ctx, 2.0); 
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetStrokeColorWithColor(ctx, [RGB(0,84,149) CGColor]);
	int i=0;
	Dot *dot;
	//draw lines until we reach current end
	while (i<=furthestDot) {
		dot=[lines objectAtIndex:i];
		switch (dot.type) {
			case 0:
				CGContextMoveToPoint(ctx, dot.dotX, dot.dotY);
				break;
			case 1:
				CGContextAddLineToPoint(ctx, dot.dotX, dot.dotY);
				break;
			case 2:
				CGContextAddCurveToPoint(ctx,  dot.cp1X,dot.cp1Y,dot.cp2X,dot.cp2Y,dot.dotX,dot.dotY);
				break;
			default:
				break;
		}
		++i;
	}
	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	touchBeganDot=-1;
}

-(void) playSound:(int)sound{
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	
	NSString *mypath;
	
	//TODO: real sounds
	if (sound==0) {
		mypath=[NSString stringWithFormat:@"dots_push"];
	}else if (sound==1) {
	mypath=[NSString stringWithFormat:@"dots_wrong"];
	}else {
		mypath=[NSString stringWithFormat:@"dots_payoff"];
	}		
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
	appDelegate.fxPlayer = thePlayer;
		[thePlayer release];
		appDelegate.fxPlayer.volume = 0.6;
		[appDelegate startFXPlayback];
	}
}

- (void)dealloc {
	[timer invalidate];
	[timer release];
	[dots release];
	[lines release];
	[dotImages release];
	[fade release];
	[red release];
	[blue release];
	[black release];
	[blue_active release];
	[startHere release];
    [super dealloc];
}


@end
