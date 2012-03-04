//
//  PhotoWizardViewController.m
//  CycleStreets
//
//  Created by neil on 28/02/2012.
//  Copyright (c) 2012 CycleStreets Ltd. All rights reserved.
//

#import "PhotoWizardViewController.h"
#import "MapViewController.h"
#import "ImageManipulator.h"
#import "UploadPhotoVO.h"
#import "GlobalUtilities.h"
#import "RMMarkerManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserLocationManager.h"
#import "CycleStreets.h"

static NSInteger MAX_ZOOM = 18;

@interface PhotoWizardViewController(Private) 

-(void)updateViewState:(PhotoWizardViewState)state;

-(void)initPhotoView;
-(void)initLocationView;
-(void)initCategoryView;
-(void)initDescriptionView;
-(void)initUploadView;

-(void)updatePageControlExtents;

-(IBAction)pageControlValueChanged:(id)sender;

-(void)loadLocationFromPhoto;
- (void)startlocationManagerIsLocating;
- (void)stoplocationManagerIsLocating;

-(void)updateSelectionLabels;

-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict;

@end


@implementation PhotoWizardViewController
@synthesize viewState;
@synthesize pageScrollView;
@synthesize pageControl;
@synthesize pageContainer;
@synthesize activePage;
@synthesize maxVisitedPage;
@synthesize viewArray;
@synthesize pageTitleLabel;
@synthesize pageNumberLabel;
@synthesize uploadImage;
@synthesize infoView;
@synthesize continueButton;
@synthesize cancelViewButton;
@synthesize photoPickerView;
@synthesize imagePreview;
@synthesize photoSizeLabel;
@synthesize cameraButton;
@synthesize libraryButton;
@synthesize photoLocationView;
@synthesize locationMapView;
@synthesize locationMarker;
@synthesize locationLabel;
@synthesize locationUpdateButton;
@synthesize locationResetButton;
@synthesize avoidAccidentalTaps;
@synthesize singleTapDidOccur;
@synthesize singleTapPoint;
@synthesize locationManagerIsLocating;
@synthesize categoryView;
@synthesize categoryTypeLabel;
@synthesize categoryDescLabel;
@synthesize pickerView;
@synthesize categoryLoader;
@synthesize categoryIndex;
@synthesize metacategoryIndex;
@synthesize photodescriptionView;
@synthesize descImagePreview;
@synthesize photodescriptionField;
@synthesize photoUploadView;
@synthesize uploadButton;
@synthesize cancelButton;
@synthesize uploadProgressView;
@synthesize uploadLabel;
@synthesize photoResultView;

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:UPLOADUSERPHOTORESPONSE];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"");
	
	[super didReceiveNotification:notification];
	
    if([notification.name isEqualToString:UPLOADUSERPHOTORESPONSE]){
        [self didRecievePhotoImageUploadResponse:notification.userInfo];
    }
	
	
}


-(void)didRecievePhotoImageUploadResponse:(NSDictionary*)dict{
    
    
    
    
}



-(void)refreshUIFromDataProvider{
	
}


//
/***********************************************
 * @description			View Methods
 ***********************************************/
//


- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	[self createPersistentUI];
	
	
}


-(void)createPersistentUI{
    
    categoryIndex=0;
    metacategoryIndex=0;
	
    viewState=-1;
	activePage=0;
	maxVisitedPage=-1;
	
	// set up scroll view with layoutbox for sub items
	self.pageContainer=[[LayoutBox alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
	pageContainer.backgroundColor=[UIColor redColor];
	pageContainer.layoutMode=BUHorizontalLayoutMode;
	pageContainer.paddingTop=10;
    
    self.viewArray=[NSMutableArray arrayWithObjects:@"Information",@"Photo Picker", @"Location",@"Photo Category",@"Description",@"Upload",@"Result", nil];
    
    [pageContainer addSubview:infoView];    
    [pageScrollView addSubview:pageContainer];
	
	pageScrollView.pagingEnabled=YES;
	pageScrollView.delegate=self;
	pageControl.hidesForSinglePage=YES;
    pageControl.defersCurrentPageDisplay=YES;
    pageControl.numberOfPages=1;
	[pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	 [self updateViewState:PhotoWizardViewStateNone];
    
}



-(void)viewWillAppear:(BOOL)animated{
	
    [self createNonPersistentUI];
	
    [super viewWillAppear:animated];
}


-(void)createNonPersistentUI{
    
   
    
}

// complete step
// increment max vs
// increment page control
// init max visited view state


//
/***********************************************
 * @description			view state updates
 ***********************************************/
//

-(void)updateViewState:(PhotoWizardViewState)state{
    
    
    if(viewState!=state){
		
		viewState=state;
        activePage=viewState+1;
        
        if(viewState>maxVisitedPage){
            maxVisitedPage=activePage;
        }
        
        [self updatePageControlExtents];
		
		switch (viewState) {
                
            case PhotoWizardViewStateNone:
                
				
            break;
				
			case PhotoWizardViewStatePhoto:
                
                [self initPhotoView];
				
			break;
				
			case PhotoWizardViewStateLocation:
                
                [self initLocationView];
				
            break;
				
			case PhotoWizardViewStateCategory:
				
				break;
				
			case PhotoWizardViewStateDescription:
				
				break;
				
			case PhotoWizardViewStateUpload:
				
				break;
				
			case PhotoWizardViewStateResult:
				
				break;
				
			default:
				break;
		}
		
	}
	
    pageTitleLabel.text=[viewArray objectAtIndex:viewState];
    pageNumberLabel.text=[NSString stringWithFormat:@"%i of %i",activePage, [viewArray count]];
	    
}



#pragma mark Paging
//
/***********************************************
 * @description			PAGE EVENTS
 ***********************************************/
//

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sc{
	BetterLog(@"");
	CGPoint offset=pageScrollView.contentOffset;
	activePage=offset.x/SCREENWIDTH;
	pageControl.currentPage=activePage;
}


-(IBAction)pageControlValueChanged:(id)sender{
	BetterLog(@"");
	UIPageControl *pc=(UIPageControl*)sender;
    if(pc.currentPage<=maxVisitedPage){
        CGPoint offset=CGPointMake(pc.currentPage*SCREENWIDTH, 0);
        [pageScrollView setContentOffset:offset animated:YES];
        [pageControl updateCurrentPageDisplay];
    }else{
        pc.currentPage=activePage;
    }
	
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)sc{
	BetterLog(@"");
	[self scrollViewDidEndDecelerating:pageScrollView];
}


-(void)updatePageControlExtents{
	
	pageControl.numberOfPages=maxVisitedPage;
	
}

-(void)scrollPageToIndex:(int)index{
    if(index<=maxVisitedPage){
       // scrol to index x screenwidth
        // update page control
    }
}

//
/***********************************************
 * @description			View info methods
 ***********************************************/
//

-(void)initInfoView{
    
}

-(IBAction)continueUploadbuttonSelected:(id)sender{
    
    [self scrollPageToIndex:2];
    
}

-(IBAction)cancelUploadbuttonSelected:(id)sender{
    
}


#pragma mark Photo View
//
/***********************************************
 * @description			PhotoPicker methods
 ***********************************************/
//

-(void)initPhotoView{
	
	if(uploadImage!=nil){
        imagePreview.image=uploadImage.image;
        photoSizeLabel.text=[NSString stringWithFormat:@"%i x %i",uploadImage.width, uploadImage.height];
    }else{
         photoSizeLabel.text=EMPTYSTRING;
    }
	
	
}

-(IBAction)cameraButtonSelected:(id)sender{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.allowsEditing = YES;
		[self presentModalViewController:picker animated:YES];
		[picker release];
		
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing camera" message:@"Device does not have a camera" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
	
}


-(IBAction)libraryButtonSelected:(id)sender{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.navigationBar.backgroundColor=UIColorFromRGBAndAlpha(0xFFFFFF,0);
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.allowsEditing = YES;
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library" message:@"Device does not support a photo library" 
													   delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	
}


#pragma mark imagePickerController  Delegate methods -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// TODO: image should be sized, a) on screen & b) upload size
    // initial image should be max resolution possible for app
    // setttings.imageSize 
	UIImage *image=[ImageManipulator resizeImage:[info objectForKey:UIImagePickerControllerEditedImage] destWidth:320 destHeight:240];
    self.uploadImage=[[UploadPhotoVO alloc]initWithImage:image];
	
	
	NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
	[library assetForURL:referenceURL resultBlock:^(ALAsset *asset){           
		
		CLLocation *location = (CLLocation *)[asset valueForProperty:ALAssetPropertyLocation];
		uploadImage.location=location;
		
	} failureBlock:^(NSError *error) {
		 BetterLog(@"error retrieving image from  - %@",[error localizedDescription]);
	 }];
	
	[library release];
    
	[picker dismissModalViewControllerAnimated:YES];	
    
    [self updateViewState:PhotoWizardViewStateLocation];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}


#pragma mark Location View
//
/***********************************************
 * @description			LOCATION METHODS
 ***********************************************/
//

// Uses normal map logic

-(void)initLocationView{
	
    if(uploadImage.location==nil){
        [RMMapView class];
        [[[RMMapContents alloc] initWithView:locationMapView tilesource:[MapViewController tileSource]] autorelease];
        [locationMapView setDelegate:self];
	}else{
        [self loadLocationFromPhoto];
    }
	
}

// Should only return yes is marker is start/end and we have not a route drawn
- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	BetterLog(@"");
	
	BOOL result=YES;
	locationMapView.enableDragging=!result;
	return result;
}


- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event {
	
	NSSet *touches = [event touchesForView:locationMapView]; 
	
	BetterLog(@"touches=%i",[touches count]);
	
	for (UITouch *touch in touches) {
		CGPoint point = [touch locationInView:locationMapView];
		CLLocationCoordinate2D location = [locationMapView pixelToLatLong:point];
		[[locationMapView markerManager] moveMarker:marker AtLatLon:location];
	}
	
}

- (IBAction) locationButtonSelected {
	BetterLog(@"location");
	if (!locationManagerIsLocating) {
		[self startlocationManagerIsLocating];
	} else {
		[self stoplocationManagerIsLocating];
	}
}

- (void)startlocationManagerIsLocating{
	[[UserLocationManager sharedInstance] startUpdatingLocation];
}

- (void)stoplocationManagerIsLocating{
	[[UserLocationManager sharedInstance] stopUpdatingLocation:nil];
}

-(void)loadLocationFromPhoto{
	
	[locationMapView moveToLatLong:uploadImage.location.coordinate];
		
	if ([locationMapView.contents zoom] < MAX_ZOOM) {
		[locationMapView.contents setZoom:1.0];
	}
	[self stoplocationManagerIsLocating]; 
	
}



#pragma mark Category View
//
/***********************************************
 * @description			Category Methods
 ***********************************************/
//

-(void)initCategoryView{
	
	CycleStreets *cycleStreets = [CycleStreets sharedInstance];
	[cycleStreets.categoryLoader setupCategories];
	
	
}



#pragma mark picker delegate and data source

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0) {
		return [self.categoryLoader.metaCategoryLabels objectAtIndex:row];
	} else {
		return [self.categoryLoader.categoryLabels objectAtIndex:row];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component == 0) {
		return [self.categoryLoader.metaCategoryLabels count];
	} else {
		return [self.categoryLoader.categoryLabels count];
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == 0) {
		metacategoryIndex = row;
	} else {
		categoryIndex = row;
	}
	[self updateSelectionLabels];
}


-(void)updateSelectionLabels{
	
	categoryTypeLabel.text=[self.categoryLoader.metaCategoryLabels objectAtIndex:metacategoryIndex];
	categoryDescLabel.text=[self.categoryLoader.categoryLabels objectAtIndex:categoryIndex];
}


#pragma mark Description View
//
/***********************************************
 * @description			Description Methods
 ***********************************************/
//

-(void)initDescriptionView{
	
	
	
	
}


#pragma mark Upload View
//
/***********************************************
 * @description			Upload Methods
 ***********************************************/
//


-(void)initUploadView{
	
	uploadProgressView.progress=0.0;
	
}


-(IBAction)uploadPhoto:(id)sender{
	
	
	
}

-(IBAction)cancelUploadPhoto:(id)sender{
	
	
	
}


#pragma mark Generic
//
/***********************************************
 * @description			generic
 ***********************************************/
//

-(void)viewDidUnload{
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end