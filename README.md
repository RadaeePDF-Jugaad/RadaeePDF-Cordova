# RadaeePDF-Cordova Plugin

This plugin uses the RadaeePDF native library for open PDF files, the plugin wrap the most important library features.
    
## License

This plugin is released under the Apache 2.0 license

**Only the plugin source code is under the license Apache 2.0, the library included in the plugin follow the license of his owner, please check it on:**
http://www.radaeepdf.com/ecommerce/technical-specification

## Installation

    cordova plugin add https://github.com/gearit/RadaeePDF-Cordova.git
    
## Usage

### Android

1. Create the app using the demo package name, to be able to test all the features (standard, professional and premium).  
   `cordova create RadaeePDF-Cordova com.radaee.reader RadaeePDF-Cordova`
	
2. Add the android platform.  
   `cd RadaeePDF-Cordova  
	cordova platform add android --save`
	
3. Add the plugin.  
   `cordova plugin add https://github.com/gearit/RadaeePDF-Cordova.git --save`
	
4. Build the app.  
   `cordova build android`
	

After doing these steps, you will have a ready to use project.

## The JavaScript Interfaces

### License Activation

You need to call this only when you have your own license, as the demo project already have a demo-premium license.
	
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

RadaeePDF library version included:
- Android: v3.6.2b

Contributors:
- This plugin was created based on [PaoloMessina/RadaeeCordova](https://github.com/PaoloMessina/RadaeeCordova)  
   www.paolomessina.it, il mio indirizzo mail è paolo.messina.it@gmail.com

More information about RadaeePDF SDK on http://www.radaeepdf.com.
