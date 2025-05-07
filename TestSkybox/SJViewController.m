//
//  SJViewController.m
//  TestSkybox
//
//  Created by Sidharth Juyal on 22/06/12.
//  Copyright (c) 2012 whackylabs. All rights reserved.
//

#import "SJViewController.h"

//+X
#define RIGHT	@"posx"
//-X
#define LEFT	@"negx"
//+Y
#define TOP		@"posy"
//-Y
#define BOTTOM	@"negy"
//+Z
#define FRONT	@"posz"
//-Z
#define BACK	@"negz"

#define ROTATE_X 0
#define ROTATE_Y 1
#define ROTATE_Z 0

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface SJViewController () {
	GLKSkyboxEffect *sEffect_;
    float _rotation;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKSkyboxEffect *sEffect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation SJViewController

@synthesize context = _context;
@synthesize sEffect = sEffect_;

- (void)dealloc
{
    [_context release];
    [sEffect_ release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
	
	NSArray *images = [NSArray arrayWithObjects:
					   [[NSBundle mainBundle]pathForResource:RIGHT ofType:@"jpg"],
					   [[NSBundle mainBundle]pathForResource:LEFT ofType:@"jpg"],
					   [[NSBundle mainBundle]pathForResource:TOP ofType:@"jpg"],
					   [[NSBundle mainBundle]pathForResource:BOTTOM ofType:@"jpg"],
					   [[NSBundle mainBundle]pathForResource:FRONT ofType:@"jpg"],
					   [[NSBundle mainBundle]pathForResource:BACK ofType:@"jpg"],
					   nil];
	GLKTextureInfo *tex = [GLKTextureLoader cubeMapWithContentsOfFiles:images options:nil error:nil];
	//GLKTextureInfo *tex = [GLKTextureLoader cubeMapWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"skybox_ground" ofType:@"jpg"] options:nil error:nil];
    self.sEffect = [[[GLKSkyboxEffect alloc] init] autorelease];
	[self.sEffect.textureCubeMap setName:tex.name];
	[self.sEffect setCenter:GLKVector3Make(0, 0, 0)];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    
    self.sEffect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
	// baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, ROTATE_X, ROTATE_Y, ROTATE_Z);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.sEffect.transform.modelviewMatrix = modelViewMatrix; 
	self.sEffect.transform.projectionMatrix = projectionMatrix;
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.sEffect prepareToDraw];
	[self.sEffect draw];
}
@end