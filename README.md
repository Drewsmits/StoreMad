# StoreMad

StoreMad is a collection of helpful categories and controllers that encourage a healthy relationship with Core Data.

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


