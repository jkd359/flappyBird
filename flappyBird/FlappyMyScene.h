//
//  FlappyMyScene.h
//  flappyBird
//

//  Copyright (c) 2014 Joel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FlappyMyScene : SKScene <SKPhysicsContactDelegate> {
    
    SKSpriteNode *bird;
    SKSpriteNode *bg;
    
    NSMutableArray *pipeArray;
    
    int score;
    
    SKLabelNode *scoreLabel;
    
    NSTimer *timer;
    
    BOOL firstTouch;
    
    
    
    
}

-(void)spawnPipes;

@end
