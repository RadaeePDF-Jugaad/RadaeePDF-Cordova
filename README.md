# RadaeePDF-Cordova Plugin

The repository has been moved to https://github.com/gearit/RadaeePDF-Cordova

The new one contains sources for both Android and iOS.

Official information page: http://www.radaeepdf.com/download/xamarin-module

## License

This plugin is released under the Apache 2.0 license

**Only the plugin source code is under the license Apache 2.0, the library included in the plugin follow the license of his owner, please check it on:**
http://www.radaeepdf.com/ecommerce/technical-specification

## Installation

    cordova plugin add https://github.com/gearit/RadaeePDF-Cordova.git
    
## Usage

1. Create the app using the demo package name, to be able to test all the features (standard, professional and premium).  
   `cordova create RadaeePDF-Cordova com.radaee.reader RadaeePDF-Cordova`
	
2. Add the android/iOS platform.  
   `cd RadaeePDF-Cordova`    
	`cordova platform add android --save` and/or `cordova platform add ios --save`
	
3. Add the plugin.  
   `cordova plugin add https://github.com/gearit/RadaeePDF-Cordova.git --save`
	
4. Build the app.  
   `cordova build`
	

After doing these steps, you will have a ready to use project.

## The JavaScript Interfaces

### License Activation

For Android, you need to call this only when you have your own license, as the demo project already have a demo-premium license.
For iOS, you have to call it before calling any other interface.
	
```javascript
RadaeePDFPlugin.activateLicense(
	{
		licenseType: 0, //0: for standard license, 1: for professional license, 2: for premium license
		company: "", //the company name you entered during license activation
		email: "", //the email you entered during license activation
		key: "" //you license activation key
	},
	function(message) { // Callback for successful opening.
		 console.log("Success: " + message);
	},
	function(err){ // Callback in case of error.
		console.log("Failure: " + err);
	});
```

### Open PDF from file system

```javascript
RadaeePDFPlugin.open(
	{
		url: "", //The path of the pdf to open
		password: "" //password if needed
	},
	function(message) {
		 console.log("Success: " + message);
	},
	function(err){
		console.log("Failure: " + err);
    });
```

- **Example**:

	```javascript
	url: "file:///mnt/sdcard/Download/Test.pdf", //in case of pdf is in the device file system
	```

	```javascript
	url: "http://www.radaeepdf.com/documentation/MRBrochoure.pdf", //in case of pdf is on a remote server
	```

### Open PDF from assets

```javascript
RadaeePDFPlugin.openFromAssets(
	{
		url: "Test.PDF", //the pdf name
		password: "" //password if needed
	},
	function(message) {
		 console.log("Success: " + message);
	},
	function(err){
		console.log("Failure: " + err);
    });
```

### Get last opened file state

Returns the state of the last opened pdf, it can be:
- File has not been modified.
- File has been modified but not saved. (Only for Android)
- File has been modified and saved. 

```javascript
RadaeePDFPlugin.getFileState(
	{},
	function(message) {
		 console.log("Success: " + message);
	},
	function(err){
		console.log("Failure: " + err);
    });
```

RadaeePDF library version included:
- Android: v3.10c
- iOS: v3.8.0

Original development: 
- This plugin was created based on [PaoloMessina/RadaeeCordova](https://github.com/PaoloMessina/RadaeeCordova)  
   www.paolomessina.it, email: paolo.messina.it@gmail.com

More information about RadaeePDF SDK on http://www.radaeepdf.com.
