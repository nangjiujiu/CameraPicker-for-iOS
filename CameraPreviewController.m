//
//  CameraPreviewController
//  CameraPicker
//
//  Created by Orlando Aleman Ortiz on 15/04/13.
//
//

#import "CameraPreviewController.h"
#import "UIScrollView+Extras.h"


@interface CameraPreviewController () {
    UITapGestureRecognizer *doubletapRecognizer_;
}

- (IBAction)done:(id)sender;
- (IBAction)retake:(id)sender;

@property (nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (nonatomic) IBOutlet UIBarButtonItem *retakeBtn;
@property (nonatomic) IBOutlet UIBarButtonItem *titleBtn;
@property (nonatomic) IBOutlet UIToolbar *bottomBar;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@end


@implementation CameraPreviewController

- (id)init
{
    self = [super initWithNibName:@"CameraPreviewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createView];
    [self refreshView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDissappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)createView
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.scrollView addSubview:self.imageView];
    
    self.titleBtn.title = NSLocalizedString(@"Preview", nil);
    self.doneBtn.title = NSLocalizedString(@"Use", nil);
    
    doubletapRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler)];
    doubletapRecognizer_.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubletapRecognizer_];
}


- (void)refreshView
{
    if (!self.image) {
        return;
    }
    
    self.imageView.image = self.image;
    CGSize imageSize = self.image.size;
    self.imageView.frame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    self.scrollView.contentSize = imageSize;

    // Ajuste de escala
    CGRect scrollFrame = self.scrollView.bounds;
    
    CGFloat widthRatio = scrollFrame.size.width / imageSize.width;
    CGFloat heightRatio = scrollFrame.size.height / imageSize.height;
    CGFloat initialZoom = MIN(heightRatio, widthRatio);
    
    self.scrollView.minimumZoomScale = initialZoom;
    self.scrollView.maximumZoomScale = 4;
    self.scrollView.zoomScale = initialZoom;
}


#pragma mark - Setters, getters

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (self.isViewLoaded) {
        [self refreshView];
    }
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate cameraPreviewControllerDidFinish:self];
}


- (IBAction)retake:(id)sender
{
    [self.delegate cameraPreviewControllerWantsRetake:self];
}


- (void)doubleTapHandler
{
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        // Zoom-out
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else {
        // Zoom-in
        CGRect zoomRect = [self zoomRectForScale:self.scrollView.maximumZoomScale
                                      withCenter:[doubletapRecognizer_ locationInView:doubletapRecognizer_.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    zoomRect.size.height = CGRectGetHeight(self.imageView.frame) / scale;
    zoomRect.size.width = CGRectGetWidth(self.imageView.frame) / scale;
    
    center = [self.imageView convertPoint:center fromView:self.scrollView];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}


#pragma mark - UIScrollView delegated

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.frame = [self.scrollView centeredFrameForView:self.imageView];
}


@end