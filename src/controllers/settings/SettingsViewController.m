/*

Copyright (C) 2010  CycleStreets Ltd

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

//  Settings.m
//  CycleStreets
//
//  Created by Alan Paxton on 02/03/2010.
//

#import "SettingsViewController.h"
#import "CycleStreets.h"
#import "Query.h"
#import "AppDelegate.h"
#import "Files.h"
#import "MapViewController.h"
#import "GenericConstants.h"
#import "AppConstants.h"
#import "SettingsManager.h"
#import "GlobalUtilities.h"

@interface SettingsViewController()

@property (nonatomic, strong)		SettingsVO								* dataProvider;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* planControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* speedControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* mapStyleControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* imageSizeControl;
@property (nonatomic, strong)		IBOutlet UISegmentedControl				* routeUnitControl;
@property (nonatomic, strong)		IBOutlet UISwitch						* routePointSwitch;
@property (nonatomic, strong)		IBOutlet UIView							* controlView;
@property (nonatomic, strong)		IBOutlet UILabel						* speedTitleLabel;


@end

@implementation SettingsViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		[SettingsManager sharedInstance];
		self.dataProvider=[SettingsManager sharedInstance].dataProvider;
		
    }
    return self;
}

- (void) select:(UISegmentedControl *)control byString:(NSString *)selectTitle {
	for (NSInteger i = 0; i < [control numberOfSegments]; i++) {
		NSString *title = [[control titleForSegmentAtIndex:i] lowercaseString];
		if (NSOrderedSame == [title compare: selectTitle]) {
			control.selectedSegmentIndex = i;
			break;
		}
	}	
}


- (void)viewDidLoad {
	
	[self select:_speedControl byString:_dataProvider.speed];
	[self select:_planControl byString:_dataProvider.plan];
	[self select:_imageSizeControl byString:_dataProvider.imageSize];
	[self select:_mapStyleControl byString:[_dataProvider.mapStyle lowercaseString]];
	[self select:_routeUnitControl byString:_dataProvider.routeUnit];
	_routePointSwitch.on=_dataProvider.showRoutePoint;
	
	[_routeUnitControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_planControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_imageSizeControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_mapStyleControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_speedControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	[_routePointSwitch addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];

	
	[self.view addSubview:_controlView];
	[(UIScrollView*) self.view setContentSize:CGSizeMake(SCREENWIDTH, _controlView.frame.size.height)];
	
	 [super viewDidLoad];
	
}


- (void) save {

	[[SettingsManager sharedInstance] saveData];	
}


- (IBAction) changed:(id)sender {
	
	BetterLog(@"");
	
	// Note: we have to update the routeunit first then update the linked segments before getting the definitive values;
	_dataProvider.routeUnit = [[_routeUnitControl titleForSegmentAtIndex:_routeUnitControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.plan = [[_planControl titleForSegmentAtIndex:_planControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.imageSize = [[_imageSizeControl titleForSegmentAtIndex:_imageSizeControl.selectedSegmentIndex] lowercaseString];
	_dataProvider.mapStyle = [_mapStyleControl titleForSegmentAtIndex:_mapStyleControl.selectedSegmentIndex];
	_dataProvider.showRoutePoint = _routePointSwitch.isOn;
	
	UISegmentedControl *control=(UISegmentedControl*)sender;
	
	if(control==_mapStyleControl)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMapStyleChanged" object:nil];
	
	[self updateRouteUnitDisplay];
	
	_dataProvider.speed = [[_speedControl titleForSegmentAtIndex:_speedControl.selectedSegmentIndex] lowercaseString];
	
	[[SettingsManager sharedInstance] saveData];
}

-(void)updateRouteUnitDisplay{
	
	if([_dataProvider.routeUnit isEqualToString:MILES]){
		_speedTitleLabel.text=@"Route speed (mph)";
		
		[_speedControl setTitle:@"10" forSegmentAtIndex:0];
		[_speedControl setTitle:@"12" forSegmentAtIndex:1];
		[_speedControl setTitle:@"15" forSegmentAtIndex:2];
		
	}else {
		_speedTitleLabel.text=@"Route speed (km/h)";
		
		[_speedControl setTitle:@"16" forSegmentAtIndex:0];
		[_speedControl setTitle:@"20" forSegmentAtIndex:1];
		[_speedControl setTitle:@"24" forSegmentAtIndex:2];
	}
	
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end