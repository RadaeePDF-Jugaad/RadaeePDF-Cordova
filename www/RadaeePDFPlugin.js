//  RadaeePDFPlugin
//  GEAR.it s.r.l., http://www.gear.it, http://www.radaeepdf.com
//  Created by Nermeen Solaiman on 06/06/16.

// modified by Nermeen Solaiman on 09/11/16
//      added getFileState prototype
//  v1.1.0

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

RadaeePDFPlugin.prototype.setThumbnailBGColor = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbnailBGColor', [params]);
};

RadaeePDFPlugin.prototype.setThumbGridBGColor = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbGridBGColor', [params]);
};

RadaeePDFPlugin.prototype.setThumbGridElementHeight = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbGridElementHeight', [params]);
};

RadaeePDFPlugin.prototype.setThumbGridGap = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbGridGap', [params]);
};

RadaeePDFPlugin.prototype.setThumbGridViewMode = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbGridViewMode', [params]);
};

RadaeePDFPlugin.prototype.setReaderBGColor = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setReaderBGColor', [params]);
};

RadaeePDFPlugin.prototype.setThumbHeight = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setThumbHeight', [params]);
};

RadaeePDFPlugin.prototype.setFirstPageCover = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'setFirstPageCover', [params]);
};

module.exports = new RadaeePDFPlugin();
