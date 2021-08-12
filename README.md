# RadaeePDF-Cordova Plugin

The repository has been moved to https://github.com/RadaeePDF-Jugaad/RadaeePDF-Cordova

The new one contains sources for both Android and iOS.

Official information page: http://www.radaeepdf.com/download/cordova-plugin

## License

This plugin is released under the Apache 2.0 license

**Only the plugin source code is under the license Apache 2.0, the library included in the plugin follow the license of his owner, please check it on:**
http://www.radaeepdf.com/ecommerce/technical-specification

Jugaad s.r.l. and Radaee Studio distribute the plugin as-is for free. Jugaad s.r.l. is the maintainer of the plug-in project.
Jugaad s.r.l. is the maintainer of the plug-in project.

If you, as user and developer need new features or fixes you shall submit them here on GitHub.

## Installation

    cordova plugin add https://github.com/RadaeePDF-Jugaad/RadaeePDF-Cordova.git
    
## Usage

1. Create the app using the demo package name, to be able to test all the features (standard, professional and premium).  
   `cordova create RadaeePDF-Cordova com.radaee.reader RadaeePDF-Cordova` (Android)  
   `cordova create RadaeePDF-Cordova com.radaee.pdf.PDFViewer RadaeePDF-Cordova` (iOS)
	
2. Add the android/iOS platform.  
   `cd RadaeePDF-Cordova`    
	`cordova platform add android@8.0 --save` and/or `cordova platform add ios --save`
	
3. Add the plugin.  
   `cordova plugin add https://github.com/RadaeePDF-Jugaad/RadaeePDF-Cordova.git --save`
	
4. Build the app.  
   `cordova build`	

After doing these steps, you will have a ready to use project.

## Compatibility

We now support Cordova 6,7,8 and 9 for both Android and iOS platforms.  
For cordova-android, latest supported version is 8.0.0, We support cordova-android@7 from version 7.1.4 onwards.  
Make sure to update to latest plugin version and to use the command `cordova platform add android@latest`

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
		password: "", //password if needed
		engine: 0 //for Android, 0: for GPU based layout(OpenGL), 1: for CPU based layout.
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

For more examples, check demo/js/index.js  

### Framework Rendering

- Android: OpenGL and CPU rendering flavors.
- iOS: CALayer based tiled rendering.

RadaeePDF library version included:
- Android: v3.53.1
- iOS: v4.5

Original development: 
- This plugin was created based on [PaoloMessina/RadaeeCordova](https://github.com/PaoloMessina/RadaeeCordova)  
   www.paolomessina.it, email: paolo.messina.it@gmail.com

More information about RadaeePDF SDK on http://www.radaeepdf.com.  
For guide please check [Knowledge Base articles](http://www.radaeepdf.com/support/knowledge-base?view=kb&catid=4)
