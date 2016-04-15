/*
 *  LightstreamerClientAll.h
 *  Lightstreamer client for iOS UCA
 *
 */

#import "LSLightstreamerClient.h"
#import "LSConnectionDetails.h"
#import "LSConnectionOptions.h"
#import "LSClientDelegate.h"
#import "LSClientMessageDelegate.h"
#import "LSSubscription.h"
#import "LSItemUpdate.h"
#import "LSSubscriptionDelegate.h"
#import "LSLoggerProvider.h"
#import "LSLogger.h"
#import "LSConsoleLoggerProvider.h"
#import "LSConsoleLogger.h"


/**
 @mainpage Getting started with the iOS and OS X Client libraries
 
 The iOS and OS X Client Libraries, from version 2.0 on, follow the Unified Client API model: a common API model used across all Lightstreamer client libraries.
 <br/> Obtaining a connection and subscribing to a table is a simple and straightforward procedure:
 <ul>
   <li> Create an instance of LSLightstreamerClient.
   <li> Set connection parameters in LSLightstreamerClient#connectionDetails and LSLightstreamerClient#connectionOptions.
   <li> Start connecting (<b>note that this operation is now asynchronous</b>).
   <li> Create an LSSubscription and set subscription parameters.
   <li> Subscribe and start receiving updates.
 </ul>
 <br/>
 
 @section create_lsclient Creating an instance of LSLightstreamerClient
 To create an instance of LSLightstreamerClient simply allocate and initialize it:
 <br/>
 <br/>
 <code> LSLightstreamerClient *client= [[LSLightstreamerClient alloc] initWithServerAddress:@@"http://myserver.mydomain.com" adapterSet:@@"MY_ADAPTER_SET"];
 </code>
 <br/>
 <br/>

 @section open_con Setting connection parameters and start connecting
 You can set additional connection parameters on LSLightstreamerClient#connectionDetails and LSLightstreamerClient#connectionOptions. E.g.:
 <br/>
 <br/>
 <code> client.connectionDetails.user= @@"my_user";
 <br/> [client.connectionDetails setPassword:@@"my_password"];
 <br/> client.connectionOptions.maxBandwidth= @@"100";
 </code>
 <br/>
 <br/> Before connecting you may want to add a delegate:
 <br/>
 <br/>
 <code> [client addDelegate:self];
 </code>
 <br/>
 <br/> Done this, connect using LSLightstreamerClient#connect:
 <br/>
 <br/>
 <code> [client connect];
 </code>
 <br/>
 <br/> Please note that this call is now asynchronous: it will <b>not block</b> and return immeditaly. You may safely use it on the main thread.
 Connection progress will be notified through delegate events.
 <br/>
 <br/>
 
 @section checking_con Listening for connection events
 Added delegates will receive the LSClientDelegate#client:didChangeStatus: event each time the connection changes its status:
 <br/>
 <br/>
 <code> - (void) client:(nonnull LSLightstreamerClient *)client didChangeStatus:(nonnull NSString *)status {
 <br/> &nbsp;&nbsp;if ([status hasPrefix:@@"CONNECTED:"]) {
 <br/> &nbsp;&nbsp;&nbsp;&nbsp;// ...
 <br/> &nbsp;&nbsp;}
 <br/> }
 </code>
 <br/>
 <br/> Once the connection is established you will receive a notification with a status beginning with "CONNECTED:". See event documentation for more information.
 <br/>
 <br/>
 
 @section create_sub Creating a subscription
 You don't have to wait for a connection to be established to subscribe. You may safely subscribe in any moment, the subscription will be delivered to the
 server as soon as a session has been created.
 <br/> To create a subscription allocate and initialize an LSSubscription instance and set its properties with the desired values:
 <br/>
 <br/>
 <code> LSSubscription *subscription= [[LSSubscription alloc] initWithSubscriptionMode:@@"MERGE"];
 <br/> subscription.items= @@[@@"my_item_1", @@"my_item_2"];
 <br/> subscription.fields= @@[@@"my_field_1", @@"my_field_2"];
 <br/> subscription.dataAdapter= @@"MY_ADAPTER";
 <br/> subscription.requestedSnapshot= @@"yes";
 <br/> [subscription addDelegate:self];
 </code>
 <br/>
 <br/> Once the subscription is set, subscribe using LSLightstreamerClient#subscribe::
 <br/>
 <br/>
 <code> [client subscribe:subscription];
 </code>
 <br/>
 <br/> The library keeps memory of active subscriptions and automatically resubscribes them if the connection drops.
 <br/>
 <br/>
 
 @section listen_table Listening for table events
 Subscription delegates will receive the LSSubscriptionDelegate#subscription:didUpdateItem: event each time an update is received:
 <br/>
 <br/>
 <code> - (void) subscription:(nonnull LSSubscription *)subscription didUpdateItem:(nonnull LSItemUpdate *)itemUpdate {
 <br/> &nbsp;&nbsp;NSString *value= [itemUpdate valueWithFieldName:@"my_field_1"];
 <br/> &nbsp;&nbsp;// ...
 <br/> }
 </code>
 <br/>
 <br/> Congratulations! Your subscription with Lightstreamer Server is now set up!
 <br/>
 <br/>

 @section close_con Closing the connection
 To close the connection simply call LSLightstreamerClient#disconnect:
 <br/>
 <br/>
 <code> [client disconnect];
 </code>
 <br/>
 <br/>
 */
