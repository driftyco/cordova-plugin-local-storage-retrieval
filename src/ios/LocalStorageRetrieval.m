#import "LocalStorageRetrieval.h"

@implementation LocalStoragePlugin

- (void)pluginInitialize {

}

- (void) save:(CDVInvokedUrlCommand*)command {
    id localStorageJSON = [command.arguments objectAtIndex:0];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localStorageJSON
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    CDVPluginResult* pluginResult;
    if (error != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION
                                         messageAsString:[NSString stringWithFormat:@"Error serializing localStorage JSON, error: %@", [error localizedDescription]]];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:jsonData forKey:@"localStorage"];
        // maybe not the most performant, but guarantees values are written to disk
        // if the app quits before iOS syncs
        // [defaults synchronize];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) load:(CDVInvokedUrlCommand*)command {
    NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localStorage"];
    CDVPluginResult* pluginResult;
    if (jsonData == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if (error != nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION
                                             messageAsString:[NSString stringWithFormat:@"Error serializing localStorage JSON, error: %@", [error localizedDescription]]];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                          messageAsDictionary:json];
        }
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) clear:(CDVInvokedUrlCommand*)command {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"localStorage"];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

@end
