# Building a Swift Backend for FoodTracker

This tutorial teaches how to create a Server-Side Swift backend for the [FoodTracker iOS app tutorial](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/) from Apple.

For more information about Swift@IBM, visit https://developer.ibm.com/swift/

## Pre-Requisites:
**Note:** This workshop has been developed for Swift 3.4, Xcode 9.x and Kitura 2.x.

**Install the Kitura CLI:**  
1. Conigure the Kitura homebrew tap 
`brew tap ibm-swift/kitura` 
2. Install the Kiura CLI from homebrew
`brew install kitura-cli`

**Clone this project:**  
1. Clone this project from GitHub to your machine (don't use the Download ZIP option):  
```
cd ~
git clone http://github.com/IBM-Swift/FoodTrackerBackend-Workshop
cd ~/FoodTrackerBackend-Workshop
```

## Getting Started
### 1. Run the Food Tracker App:
The Food Tracker application allows you to store names, photos and ratings for  "meals". The meals are then stored onto the device using `NSKeyedArchiver`. The following shows you how to see the application running.

1. Change into the iOS app directory:  
```
cd ~/FoodTrackerBackend-Workshop/iOS/FoodTracker
```  

2. Open the Xcode Project  
```
open FoodTracker.xcodeproj
```  

3. Run the project to ensure that its working  
    1. Hit the build and run button  
    2. Add a meal in the Simulator  
    3. Check that you receive a “Meals successfully saved.” message in the console

## Building a Kitura Backend
The Food Tracker application stores the meal data to the local device, which means its not possible to share the data with other users, or to build an additonal web interface for the application. The following steps show you have to create a Kitura Backend to allow you to store and share the data.

### 1. Initialize a Kitura Server Project
1. Create a directory for the server project 
```
mkdir ~/FoodTrackerBackend-Workshop/Server
cd ~/FoodTrackerBackend-Workshop/Server
```  

2. Create an empty Kitura project  
```
kitura init
```  
The Kitura CLI will now create and build an empty Kitura application for you. This includes adding best-pratice implementations of capabilities such as configuration, health checking and monitoring to the application for you.
 
### 2. Create an in-memory data store for Meals 
In order to store the data from the FoodTracker application, you need to create a datastore for the meals. This example uses a simple in-memory dictionary to store the data.

1. Copy the Meal.swift file from the FoodTracker app to the Server
```
cd ~/FoodTrackerBackend-Workshop
cp ./cp iOS/FoodTracker/FoodTracker/Meal.swift ./Server/Sources/Application
```
2. Open the FoodServer project in Xcode  
```
cd ~/FoodTrackerBackend-Workshop/Server  
open Server.xcodeproj
```
3. Add the Meal.swift file into the FoodServer project  
  * Select the Sources > Application folder in the left hand explorer menu  
  * Select File > Add Files to "FoodServer"... from the pull down menu  
  * Select the Meal.swift file and click Add
4. Open the Sources > Application > Application.swift file
5. Add a "mealStore" into the App class
On the line below `let cloudEnv = CloudEnv()` add:  
```
private var mealStore: [String: Meal] = [:] 
```

This now provides a simple dictionary to store Meal data passed to the FoodServer from the FoodTracker app.

### 2. Create a REST API to allow FoodTracker to store Meals
REST APIs typically consist of a HTTP request using a verb such as POST, PUT, GET or DELETE along with a URL and an optional data payload. The server then handles the request and responds with an optional data payload.

A request to store data typically consists of a POST request with the data to be stored, which the server then handles and responds with a copy of the data that has just been stored.

1. Register a handler for a `POST` request on `/meals` that stores the data  
Add the following into the `postInit()` function:
```swift
router.post("/meals", handler: storeHandler)
```
2. Implement the storeHandler that receives a Meal, and returns the stored Meal  
Add the following as a function in the App class:  
```swift
    func storeHandler(meal: Meal, completion: (Meal?, ProcessHandlerError?) -> Void ) -> Void {
        mealStore[meal.name] = meal 
        completion(mealStore[meal.name], nil)
    }
```    

As well as being able to store Meals on the FoodServer, the FoodTracker app will also need to be able to access the stored meals. A request load all of the stored data typically consists of a GET request with no data, which the server then handles and responds with an array of the data that has just been stored.

3. Register a handler for a `GET` request on `/meals` that loads the data  
Add the following into the `postInit()` function:  
```swift
	router.get("/meals", handler: loadHandler)
```
4. Implement the loadHandler that receives a Meal, and returns the stored Meal    
Add the following as a function in the App class:
```swift
    func getAllHandler(completion: ([Meal]?, ProcessHandlerError?) -> Void ) -> Void {
	    let meals: [Meal] = self.mealStore.map({ $0.value })
       completion(meals, nil)
    }
```

### 2. Test the newly created REST API


1. Run the server project in Xcode
    1. Edit the scheme and select a Run Executable of “FoodTrackerServer”
    2. Run the project, then "Allow incoming network connections" if you are prompted.

2. Check that some of the standard Kitura URLs are running:
    * Kitura Monitoring: http://localhost:8080/swiftmetrics-dash/
    * Kitura Healthcheck: http://localhost:8080/health

3. Test the GET REST API is running correctly  
There are many utilities for testing REST APIs, such as [Postman](https://www.getpostman.com). Here's we'll use "curl", which is a simple command line utility:  
```
curl -X GET \
  http://localhost:8080/meals \
  -H 'content-type: application/json' 
```
If the GET endpoint is working correctly, this should return an array of JSON data representing the stored Meals. As no data is yet stored, this should return an empty array, ie:  
```
[]
```
4.  Test the POST REST API is running correctly  
In order to test the POST API, we make a similar call, but also sending in a JSON object that matches the Meal data:  
```
curl -X POST \
  http://localhost:8080/meals \
  -H 'content-type: application/json' \
  -d '{
	"name": “test”,
	"photo": "0e430e3a",
	"rating": 1
}'
```
If the POST endpoint is working correctly, this should return the same JSON that was passed in, eg:  
```
{"name":"test","photo":"0e430e3a","rating":1}
``` 

5. Test the GET REST API is returning the stored data correctly  
In order to check that the data is being stored correctly, re-run the GET check:  
```
curl -X GET \
  http://localhost:8080/meals \
  -H 'content-type: application/json' 
```
This should now return a single entry array containng the Meal that was stored by the POST request, eg:  
```
[{"name":"test","photo":"0e430e3a","rating":1}]
```

## Connect FoodTracker to the Kitura FoodServer

Any package that can make REST calls from an iOS app is sufficient to make the connection to the Kitura FoodServer to store and retrieve the Meals. Kitura itself provides a client connector called KituraBuddy that make it easy to connect to Kitura using shared data types, in our case Meals, using an API that is almost identical on the client and the server. In this example we'll use KituraBuddy to make the connection.

### Install KituraBuddy into the FoodTracker app
KituraBuddy is designed to be used both in iOS apps and in server projects. Currently the easiest way to install KituraBuddy into an iOS app it to download a bundling containing KituraBuddy and its depdendencies, and copy it into the app.

1. Download the KituraBuddy for iOS bundle  
KituraBuddy for iOScan be downloaded by any of the following methods, each of which gives you the latest version:  
  * Using this link: 
  <script type="text/javascript">  
    $(document).ready(function () {
        GetLatestReleaseInfo();
    });

    function GetLatestReleaseInfo() {
        $.getJSON("https://api.github.com/repos/seabaylea/pop/releases/latest").done(function (release) {
            var asset = release.assets[0];
            var releaseInfo = release.name;
            $(".sharex-download").attr("href", asset.browser_download_url);
            $(".release-info").text(releaseInfo);
            $(".release-info").fadeIn("slow");
        });
    }
    
</script>  
  * Going to the [KituraBuddy Releases](https://github.com/IBM-Swift/KituraBuddy/releases) page and choosing a "kiturabuddy.tar.gz" file
  * Using the following on the command line:  
  `curl -s https://api.github.com/repos/seabaylea/pop/releases/latest | jq --raw-output '.assets[0] | .browser_download_url' | xargs wget`

**Update FoodTracker to call the FoodTrackerServer:**  
As the iOS SDK is installed as a Pod, the FoodTracker application now needs to be updated to call the provided APIs. The FoodTracker application provided already includes that code. As a result, you only need to uncomment the code that invokes those APIs:

1. If the FoodTracker iOS application is open in Xcode, close it.
2. Open the FoodTracker applications Workspace (not project!):
```
cd ~/FoodTrackerBackend-Workshop/iOS/FoodTracker/
open FoodTracker.xcworkspace
```
3. Edit the `FoodTracker > MealTableViewController.swift` file:
    1. Uncomment the import of `import FoodTrackerServer_iOS_SDK`
    ```swift
    import FoodTrackerServer_iOS_SDK
    ```
    2. Uncomment the following at the start of the saveMeals() function:
    ```swift
            for meal in meals {
                  saveToServer(meal: meal)
              }
    ```
    3. Uncomment the following `saveToServer(meal:)` function towards the end of the file:
    ```swift
    private func saveToServer(meal: Meal) {
        ServerMealAPI.serverMealCreate(data: meal.asServerMeal()) { (returnedData, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            if let result = returnedData {
                print(result)
            }
            if let status = response?.statusCode {
                print("ServerMealAPI.serverMealCreate() finished with status code: \(status)")
            }
        }
    }
    ```
    4. Uncomment the following `asServerMeal()` extension to `Meal` at the end of the file:
    ```swift
    extension Meal {
        func asServerMeal() -> ServerMeal {
            let serverMeal = ServerMeal()
            serverMeal.name = self.name
            serverMeal.photo = UIImageJPEGRepresentation(self.photo!, 0)?.base64EncodedString()
            serverMeal.rating = Double(self.rating)
            return serverMeal
        }
    }
    ```
4. Edit the `Pods > Development Pods > FoodTrackerServer_iOS_SDK > Resources > FoodTrackerServer_iOS_SDK.plist` file to set the hostname and port for the FoodTrackerBackend server (in this case adding a port number of `8080`):
```
FoodTrackerServer_iOS_SDKHost = http://localhost:8080/api
```
5. Update the FoodTracker applications `FoodTracker > Info.plist` file to allow loads from a server:
**note** this step has been done already:
```
    <key>NSAppTransportSecurity</key>
	<dict>
	    <key>NSAllowsArbitraryLoads</key>
        	<true/>
	</dict>
```

**Run the FoodTracker app with storage to the Kitura server**
1. Make sure the Kitura server is still running and you have the Kitura monitoring dashboard open in your browser (http://localhost:8080/swiftmetrics-dash)
2. Build and run the FoodTracker app in the iOS simulator and add or remove a Meal entry
3. View the monitoring panel to see the responsiveness of the API call
4. Check the data has been persisted by the Kitura server
    1. Go the to REST API explorer:    http://localhost:8080/explorer/
    2. From the Kitura REST API explorer select “GET /ServerMeals”
    3. Press the “Try it out!” button
    4. Check for a response body that contains data and a Response Code of 200
    
Congratulations, you have successfully persisted data from an iOS app to a serverside Swift backend!

**Add a Web Application to the Kitura server (bonus content, if you have time)**
1. Update the Kitura server application to save the received images to the local file system:
    1. Open the `Sources/Generated/ServerMealResource.swift` source file that contains the REST API routes
    2. Import Foundation:
    `import Foundation`
    3. Update the `handleCreate()` function to add the following after the `let model = try ServerMeal(json: json)` statement to save the images:
    **note:** `<USER_NAME>` should be substituted with your user name
      ```swift
            let photoData = Data(base64Encoded: model.photo)
            let fileManager = FileManager.default
            let publicDirectory = "/Users/<USER_NAME>/FoodTrackerBackend-Workshop/Server/FoodTrackerServer/public/"
            fileManager.createFile(atPath: publicDirectory + model.name + ".jpg", contents: photoData)
      ```
    4. Create a `~/FoodTrackerBackend-Workshop/Server/FoodTrackerServer/public/jpeg.html` file containing just: 
    `<img src="Caprese Salad.jpg">`
    5. Re-build and run the server

   
**Rerun the FoodTracker iOS App and view the Web App** 
1. Run the iOS app in XCode and add or remove a Meal entry
2. Visit the web application at to see the saved image:
`http://localhost:8080/jpeg.html`

## Next Steps
If you have sufficient time, you can optionally try [Step 2: Deploying to IBM Cloud](2-CloudDeploy.md)
