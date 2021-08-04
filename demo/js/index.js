/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        var parentElement = document.getElementById('deviceready');
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: deviceready');

		registerCallbacks();

        document.getElementById("activateLicense").addEventListener("click", this.activateLicense, false);
        document.getElementById("open").addEventListener("click", this.open, false);
        document.getElementById("openHttp").addEventListener("click", this.openHttp, false);
        document.getElementById("openFromAssets").addEventListener("click", this.openAssets, false);

		function registerCallbacks()
        {
            RadaeePDFPlugin.willShowReaderCallback(willShowReader);
            RadaeePDFPlugin.didShowReaderCallback(didShowReader);
            RadaeePDFPlugin.willCloseReaderCallback(willCloseReader);
            RadaeePDFPlugin.didCloseReaderCallback(didCloseReader);
            RadaeePDFPlugin.didChangePageCallback(function(message){didChangePage(message);});
            RadaeePDFPlugin.didSearchTermCallback(function(message){didSearchTerm(message);});
            RadaeePDFPlugin.didTapOnPageCallback(function(message){didTapOnPage(message);});
            RadaeePDFPlugin.didTapOnAnnotationOfTypeCallback(function(message){didTapOnAnnotationOfType(message);});
			RadaeePDFPlugin.didDoubleTapOnPageCallback(function(message){didDoubleTapOnPage(message);});
            RadaeePDFPlugin.didLongPressOnPageCallback(function(message){didLongPressOnPage(message);});
        }

        function willShowReader()
        {
            console.log("--- Callback: willShowReader");
        }
        function didShowReader()
        {
            console.log("--- Callback: didShowReader");
        }
        function willCloseReader()
        {
            console.log("--- Callback: willCloseReader");
        }
        function didCloseReader()
        {
            console.log("--- Callback: didCloseReader");
        }
        function didChangePage(page)
        {
            console.log("--- Callback: didChangePage: " + page);
        }
        function didSearchTerm(term)
        {
            console.log("--- Callback: didSearchTerm: " + term);
        }
        function didTapOnPage(page)
        {
            console.log("--- Callback: didTapOnPage: " + page);
            /*RadaeePDFPlugin.renderAnnotToFile(
                        {
                            page: 4,
                            annotIndex: 3,
                            renderPath: "/mnt/sdcard/signature.png"
                        },
                        function(message) {
                             console.log("Success: " + message);
                        },
                        function(err){
                            console.log("Failure: " + err);}
                    );*/
        }
        function didTapOnAnnotationOfType(info)
        {
            console.log("--- Callback: didTapOnAnnotationOfType: " + info['type'] + " and index: " + info['index']);
        }
		function didDoubleTapOnPage(page)
        {
            console.log("--- Callback: didDoubleTapOnPage: " + page);
        }
        function didLongPressOnPage(page)
        {
            console.log("--- Callback: didLongPressOnPage: " + page);
        }
		/*RadaeePDFPlugin.addToBookmarks(
            {
                pdfPath: "file:///mnt/sdcard/Download/pdf/License.pdf",
                page: 1,
                label: ""
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/

        /*RadaeePDFPlugin.removeBookmark(
            {
            page: 1,
                pdfPath: "file:///mnt/sdcard/Download/pdf/License.pdf"
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/

        /*RadaeePDFPlugin.getBookmarks(
            {
                pdfPath: "file:///mnt/sdcard/Download/pdf/License.pdf"
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/

        /*RadaeePDFPlugin.addAnnotAttachment(
            {
                path: "/mnt/sdcard/untitled.png"
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );*/
    },

    //activate license
    activateLicense: function() {
        console.log("Activating license");

        RadaeePDFPlugin.activateLicense(
            {   //iOS's demo premium license for other license check:
                //http://www.radaeepdf.com/support/knowledge-base?view=kb&kbartid=4
                //http://www.radaeepdf.com/support/knowledge-base?view=kb&kbartid=8
                licenseType: 2, //0: for standard license, 1: for professional license, 2: for premium license
                company: "Radaee", //the company name you entered during license activation
                email: "radaee_com@yahoo.cn", //the email you entered during license activation
                key: "89WG9I-HCL62K-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO" //your license activation key
            },
            function(message)
            {
                console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);
            }
        );
    },

    //open pdf from path
    open: function() {
        console.log("Opening PDF...");

        RadaeePDFPlugin.open(
            {
                url: "file:///mnt/sdcard/test.pdf",
                password: "" //password if needed
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );
    },

    //open pdf from http url
    openHttp: function() {
        console.log("Opening PDF...");

        RadaeePDFPlugin.open(
            {
		url: "https://www.radaeepdf.com/documentation/readeula/eula/eula.pdf",
                password: "" //password if needed
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );
    },

    //open pdf from assets
    openAssets: function() {
        console.log("Opening PDF from assets...");

        RadaeePDFPlugin.openFromAssets(
            {
                url: "www/test.PDF",
                password: "" //password if needed
            },
            function(message) {
                 console.log("Success: " + message);
            },
            function(err){
                console.log("Failure: " + err);}
        );
    },
};

app.initialize();
