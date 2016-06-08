# RadaeePDF-Cordova Plugin

This plugin uses the RadaeePDF native library for open PDF files, the plugin wrap the most important library features.
    
## License

This plugin is released under the Apache 2.0 license

**Only the plugin source code is under the license Apache 2.0, the library included in the plugin follow the license of his owner, please check it on:**
http://www.radaeepdf.com/ecommerce/technical-specification

## Installation

    cordova plugins add 
    
## Usage

### Android

	1. Create the app using the dmeo package name, to be able to test all the features (standard, professional and premium).
	2. Add the android platform
	3. Add the plugin
	4. Build the app.
	
	After doing these steps, you will have a ready to use project.

## The JavaScript Interfaces

### License Activation

```javascript
RadaeePDFPlugin.activateLicense(
	{
		licenseType: 1, //0: for standard license, 1: for professional license, 2: for premium license
		company: "", //the company name you entered during license activation
		email: "", //the email you entered during license activation
		key: "" //you license activation key
	},
	function(message) { // _Callback for successful opening._
		 console.log("Success: " + message);
	},
	function(err){ // _Callback in case of error._
		console.log("Failure: " + err);
	});
```

RadaeePDF library version included:
- Android: v3.6.2b
