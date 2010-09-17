//
//  SonarAnnotation.m
//  RunQuest
//
//  Created by Joe Walsh on 9/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SonarAnnotationView.h"
#import "SonarLayer.h"

@implementation SonarAnnotationView

+ (Class)layerClass {
	return [SonarLayer class];
}

@end
