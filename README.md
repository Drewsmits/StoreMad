# StoreMad

StoreMad is a collection of helpful categories and controllers that encourage a healthy relationship with Core Data. Your best bet it to sit down and learn Core Data, as you will be way better off in the long term. At the very least, there are some patterns that you may find helpful here.

# Store Controller

The SMStoreController is the main controller you use to add Core Data to your app. Instantiate a new SMStoreController which points to your sqlite store URL and momd URL.

```objective-c
#import <StoreMad/StoreMad.h>

- (SMStoreController *)storeController
{
    if (_storeController) return _storeController;

    // sqlite
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocDirectory URLByAppendingPathComponent:@"StoreMadApp.sqlite"];

    // momd
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"StoreMadApp" withExtension:@"momd"];
    
    // controller
    SMStoreController *newStoreController = [SMStoreController storeControllerWithStoreURL:storeURL
                                                                               andModelURL:modelURL];
    
    //
    // Context saves when app changes state
    //
    [newStoreController shouldSaveOnAppStateChanges:YES];
  
    _storeController = newStoreController;
  
    return _storeController;
}
```

## SMContextObserverController

This controller is intended to be used much the same way that you interact with `NSNotificationCenter`. An `NSManagedObjectContext` emits various notifications when it performs inserts, updates, and deletes. Using `SMContextObserverController`,  you can run a block on an object or set of objects of interest. This is an essential Core Data pattern for updating your UI, and decoupling your data and UI later.

## Observe an Object

Here is a simple pattern for observing changes to an NSManagedObject. Note that whenever you add an observer, you must remove it when finished, just like NSNotificationCenter.

```objective-c
#import <StoreMad/StoreMad.h>

@interface MyViewController ()

@property (nonatomic, strong) id observer;

@property (nonatomic, weak) IBOutlet UILabel *employmentStatusLabel;

@end

@implementation MyViewController

- (void)dealloc
{
	[[SMContextObserverController defaultController] removeContextObserver:self.observer];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    Employee *employee = [Employee createInContext:context];
    
    __weak MyViewController *weakSelf = self;
    self.observer = [[SMContextObserverController defaultController] addContextObserverForChangesToObject:employee
                                                                                                workBlock:^(NSManagedObject *object) {
                                                                                                    [weakSelf configureWithEmployee:object];
                                                                                                }];
}

- (void)configureWithEmployee:(Employee *)employee
{
    _employmentStatusLabel.text = employee.isFired ? @"Fired" : "Hired";
}

@end
```

