//  RadaeePDFPlugin
//  GEAR.it s.r.l., http://www.gear.it, http://www.radaeepdf.com
//  Created by Nermeen Solaiman on 06/06/16.

// modified by Nermeen Solaiman on 09/11/16
//      added getFileState prototype
//  v1.1.0

// modified by Nermeen Solaiman/Emanuele on 31/01/17
//      added config prototypes
//  v1.2.0

// modified by Nermeen Solaiman on 26/04/17
//      added getPageCount, extractTextFromPage and encryptDocAs prototypes
//  v1.3.0

// modified by Nermeen Solaiman/Emanuele on 05/07/17
//      added addToBookmarks, removeBookmark and getBookmarks
//  v1.4.0

// modified by Nermeen Solaiman/Emanuele on 30/08/17
//      added js callbacks
//  v1.5.0

// modified by Nermeen Solaiman/Emanuele on 31/01/17
//      added addAnnotAttachment, renderAnnotToFile
//  v1.6.0

var argscheck = require('cordova/argscheck'),
    exec      = require('cordova/exec');

function RadaeePDFPlugin () {};

RadaeePDFPlugin.prototype.activateLicense = function(params, successCallback, errorCallback) {
        params = params || {};
                exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'activateLicense', [params]);
};

RadaeePDFPlugin.prototype.open = function (params, success, failure) {
        argscheck.checkArgs('*fF', 'RadaeePDFPlugin.show', arguments);

        params = params || {};

        exec(success, failure, 'RadaeePDFPlugin', 'show', [params]);
};

RadaeePDFPlugin.prototype.openFromAssets = function(params, successCallback, errorCallback) {
        params = params || {};
                exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'openFromAssets', [params]);
};

RadaeePDFPlugin.prototype.closeReader = function(params, successCallback, errorCallback) {
       params = params || {};
               exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'closeReader', [params]);
};

RadaeePDFPlugin.prototype.getFileState = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'fileState', [params]);
};

RadaeePDFPlugin.prototype.getPageNumber = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'getPageNumber', [params]);
};

RadaeePDFPlugin.prototype.getJSONFormFields = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'JSONFormFields', [params]);
};

RadaeePDFPlugin.prototype.getJSONFormFieldsAtPage = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'JSONFormFieldsAtPage', [params]);
};

RadaeePDFPlugin.prototype.setFormFieldWithJSON = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setFormFieldWithJSON', [params]);
};

RadaeePDFPlugin.prototype.setThumbnailBGColor = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbnailBGColor', [params]);
};

RadaeePDFPlugin.prototype.setReaderBGColor = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setReaderBGColor', [params]);
};

RadaeePDFPlugin.prototype.setThumbHeight = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbHeight', [params]);
};

RadaeePDFPlugin.prototype.setDebugMode = function (params, successCallback, errorCallback) { //android only
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setDebugMode', [params]);
};

RadaeePDFPlugin.prototype.setFirstPageCover = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setFirstPageCover', [params]);
};

RadaeePDFPlugin.prototype.setReaderViewMode = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setReaderViewMode', [params]);
};

RadaeePDFPlugin.prototype.setIconsBGColor = function (params, successCallback, errorCallback) { //android only
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setIconsBGColor', [params]);
};

RadaeePDFPlugin.prototype.setTitleBGColor = function (params, successCallback, errorCallback) { //android only
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setTitleBGColor', [params]);
};

RadaeePDFPlugin.prototype.setToolbarEnabled = function(params, successCallback, errorCallback) { //iOS only

        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setToolbarEnabled', [params]);
};

RadaeePDFPlugin.prototype.getPageCount = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'getPageCount', [params]);
};

RadaeePDFPlugin.prototype.extractTextFromPage = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'extractTextFromPage', [params]);
};

RadaeePDFPlugin.prototype.encryptDocAs = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'encryptDocAs', [params]);
};

RadaeePDFPlugin.prototype.addToBookmarks = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'addToBookmarks', [params]);
};

RadaeePDFPlugin.prototype.removeBookmark = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'removeBookmark', [params]);
};

RadaeePDFPlugin.prototype.getBookmarks = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'getBookmarks', [params]);
};

RadaeePDFPlugin.prototype.addAnnotAttachment = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'addAnnotAttachment', [params]);
};

RadaeePDFPlugin.prototype.renderAnnotToFile = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'renderAnnotToFile', [params]);
};

RadaeePDFPlugin.prototype.flatAnnotAtPage = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'flatAnnotAtPage', [params]);
};

RadaeePDFPlugin.prototype.flatAnnots = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'flatAnnots', [params]);
};

RadaeePDFPlugin.prototype.saveDocumentToPath = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'saveDocumentToPath', [params]);
};

RadaeePDFPlugin.prototype.getGlobal = function (params, successCallback, errorCallback) {
       params = params || {};

       exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'getGlobal', [params]);
};

RadaeePDFPlugin.prototype.setGlobal = function (params, successCallback, errorCallback) {
       params = params || {};

       exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setGlobal', [params]);
};

// Callbacks
               
RadaeePDFPlugin.prototype.willShowReaderCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'willShowReaderCallback', []);
};

RadaeePDFPlugin.prototype.didShowReaderCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didShowReaderCallback', []);
};

RadaeePDFPlugin.prototype.willCloseReaderCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'willCloseReaderCallback', []);
};

RadaeePDFPlugin.prototype.didCloseReaderCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didCloseReaderCallback', []);
};

RadaeePDFPlugin.prototype.didChangePageCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didChangePageCallback', []);
};

RadaeePDFPlugin.prototype.didSearchTermCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didSearchTermCallback', []);
};

RadaeePDFPlugin.prototype.didTapOnPageCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didTapOnPageCallback', []);
};

RadaeePDFPlugin.prototype.didDoubleTapOnPageCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didDoubleTapOnPageCallback', []);
};

RadaeePDFPlugin.prototype.didLongPressOnPageCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didLongPressOnPageCallback', []);
};

RadaeePDFPlugin.prototype.didTapOnAnnotationOfTypeCallback = function (successCallback) {

	exec(successCallback, function(err){console.log(err)}, 'RadaeePDFPlugin', 'didTapOnAnnotationOfTypeCallback', []);
};

module.exports = new RadaeePDFPlugin();

