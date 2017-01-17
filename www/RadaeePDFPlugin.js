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

RadaeePDFPlugin.prototype.JSONFormFields = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'JSONFormFields', [params]);
};

RadaeePDFPlugin.prototype.JSONFormFieldsAtPage = function (params, successCallback, errorCallback) {
        params = params || {};

        exec(successCallback, errorCallback, 'RadaeePDFPlugin', 'JSONFormFieldsAtPage', [params]);
};

module.exports = new RadaeePDFPlugin();
