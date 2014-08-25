//
//  FlappyMyScene.m
//  flappyBird
//
//  Created by Joel on 28/02/2014.
//  Copyright (c) 2014 Joel. All rights reserved.
//

#import "FlappyMyScene.h"

@implementation FlappyMyScene

static const uint32_t birdCategory = 0x1 << 0;
static const uint32_t pipeCategory = 0x1 << 1;


-(void)spawnPipes;
{
    
    int random = (arc4random() % (int)self.frame.size.height-150)+250;
    
    //Add pipe end
    SKSpriteNode *upperPipe = [SKSpriteNode spriteNodeWithImageNamed:@"open.png"];
    upperPipe.size = CGSizeMake(70, 25);
    upperPipe.position = CGPointMake(250, random);
    
    //Add pipe middles
    SKSpriteNode *lowerPipe = [SKSpriteNode spriteNodeWithImageNamed:@"open.png"];
    lowerPipe.size = CGSizeMake(70, 25);
    lowerPipe.position = CGPointMake(upperPipe.position.x, upperPipe.position.y-150);
    
    //Rest below
    SKSpriteNode *restBelow = [SKSpriteNode spriteNodeWithImageNamed:@"middle.png"];
    restBelow.size = CGSizeMake(60, lowerPipe.position.y);
    restBelow.position = CGPointMake(lowerPipe.position.x, lowerPipe.position.y-restBelow.size.height/2-lowerPipe.size.height/2+1);
    
    //Rest above
    SKSpriteNode *restAbove = [SKSpriteNode spriteNodeWithImageNamed:@"middle.png"];
    restAbove.size = CGSizeMake(60, self.frame.size.height+upperPipe.position.y);
    restAbove.position = CGPointMake(upperPipe.position.x, upperPipe.position.y+restAbove.size.height/2+upperPipe.size.height/2-2);
    
    [self addChild:upperPipe];
    [self addChild:lowerPipe];
    [self addChild:restBelow];
    [self addChild:restAbove];
    
    [pipeArray addObject:upperPipe];
    [pipeArray addObject:lowerPipe];
    [pipeArray addObject:restBelow];
    [pipeArray addObject:restAbove];
    
    for (int i = 0; i < [pipeArray count]; i++) {
        
        SKSpriteNode *sprite = [pipeArray objectAtIndex:i];
        sprite.physicsBody= [SKPhysicsBody bodyWithRectangleOfSize:sprite.frame.size];
        sprite.physicsBody.usesPreciseCollisionDetection = YES;
        sprite.physicsBody.categoryBitMask = pipeCategory;
        sprite.physicsBody.affectedByGravity = NO;
        sprite.physicsBody.mass = 1000.0;
        sprite.name = [NSString stringWithFormat:@"beforeBird"];
    }
    
}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        //Start pipes
        pipeArray = [[NSMutableArray alloc]init];
        
        score = 0;
        
        //Bird
        bird = [SKSpriteNode spriteNodeWithImageNamed:@"bird.png"];
        bird.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        bird.size = CGSizeMake(30, 30);
        bird.zPosition = 3;
        
        bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bird.frame.size];
        bird.physicsBody.usesPreciseCollisionDetection = YES;
        bird.physicsBody.mass = 0.2;
        bird.physicsBody.affectedByGravity = NO;
        bird.physicsBody.categoryBitMask = birdCategory;
        bird.physicsBody.dynamic = YES;
        
        bird.physicsBody.collisionBitMask = birdCategory | pipeCategory;
        bird.physicsBody.contactTestBitMask = birdCategory | pipeCategory;
        
        
        [self addChild:bird];
        
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.text = [NSString stringWithFormat:@"%d", score];
        scoreLabel.fontColor = [SKColor whiteColor];
        scoreLabel.fontSize = 40;
        scoreLabel.position = CGPointMake(self.size.width/2, self.size.height/1.5);
        scoreLabel.zPosition = 2;
        [self addChild:scoreLabel];
        
        //Background
        bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        bg.position = CGPointMake(160, 284);
        bg.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self addChild:bg];
        
        //Spawns pipes
        [self spawnPipes];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(spawnPipes) userInfo:nil repeats:YES];

        
        //Set touch boolean for touches began methods
        firstTouch = YES;
        

        
    }
    return self;
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKSpriteNode *firstSprite;
    SKSpriteNode *secondSprite;
    
    firstSprite = (SKSpriteNode *)contact.bodyA.node;
    secondSprite = (SKSpriteNode *)contact.bodyB.node;
    
    if ((contact.bodyA.categoryBitMask == birdCategory) && (contact.bodyB.categoryBitMask == pipeCategory)) {
        
        [pipeArray removeAllObjects];
        [bird.physicsBody setAffectedByGravity:NO];
        [timer invalidate];
        scoreLabel.fontSize = 30;
        scoreLabel.text = [NSString stringWithFormat:@"GAME OVER %d", score];
        
    }
}

-(void)didMoveToView:(SKView *)view {
    
    self.physicsWorld.contactDelegate = self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    [bird.physicsBody applyImpulse:CGVectorMake(0.0, 60)];
    
    //Adding in the "drop or dip" functionality
    [bird runAction:[SKAction rotateByAngle:degToRad(-32.0f) duration:10.0]];

    
    if (firstTouch == YES) {
        
        firstTouch = NO;
        bird.physicsBody.affectedByGravity = YES;
        
    }
    

}

-(void)update:(CFTimeInterval)currentTime {

    if ([pipeArray count] > 1) {
        
        SKSpriteNode *sprite = [pipeArray objectAtIndex:1];
        
        if (sprite.position.x < bird.position.x && [sprite.name isEqualToString:@"beforeBird"] && sprite.position.x > 0) {
            
            score ++;
            scoreLabel.text = [NSString stringWithFormat:@"%d", score];
            sprite.name = @"afterBird";
        }
    }
    
    
    for (int i = 0; i < [pipeArray count]; i++) {
        
        SKSpriteNode *pipe = [pipeArray objectAtIndex:i];
        
        if (pipe.position.x < -50) {
            
            SKSpriteNode *spNext = [[SKSpriteNode alloc]init];
            spNext = [pipeArray objectAtIndex:i+1];
            spNext.position = CGPointMake(spNext.position.x-3, spNext.position.y);
            
            [pipe removeFromParent];
            [pipeArray removeObject:pipe];
        }
        
        
        pipe.position = CGPointMake(pipe.position.x-3, pipe.position.y);
        
    }

}

float degToRad(float degree) {
    return degree / 180.0f * M_PI;
}

@end
