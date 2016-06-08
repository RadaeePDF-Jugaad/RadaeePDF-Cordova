/**
 * Created by p.messina on 14/10/2015.
 */

module.exports = function (ctx) {

    if (ctx.opts.platforms.indexOf('android') < 0) {
        return;
    }
    /*var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        deferral = ctx.requireCordovaModule('q').defer(); substitute with require to be compatible with cordova 9.0.0*/

	var fs = require('fs'),
        path = require('path'),
		Q = require('q');
	var deferral = new Q.defer();

    function replace_string_in_file(filename, to_replace, replace_with) {
        var data = fs.readFileSync(filename, 'utf8');
        var result = data.replace(new RegExp(to_replace, "g"), replace_with);
        fs.writeFileSync(filename, result, 'utf8');
    }

    function getConfidId(configString){

    	var firstCut = configString.split(" id=");
		//console.log(firstCut);
		var secondCut = firstCut[1].replace(/"/g,"");
		//console.log(secondCut);
		var id = secondCut.slice(0,secondCut.indexOf(" "));
		//console.log(id);
		return id;
    }

    var ourconfigfile = path.join(ctx.opts.projectRoot, "config.xml");
    var configXMLPath = "config.xml";
    var data = fs.readFileSync(ourconfigfile, 'utf8');

    var replaceWith = getConfidId(data) + ".R";

	var platformRoot = path.join(ctx.opts.projectRoot, 'platforms/android');

	var dirSrc = "src/";
	var dirApp = "app/src/main/java/";
	var prefix = "";

	if (fs.existsSync(path.join(platformRoot, dirSrc))) {
		prefix = dirSrc;
	} else {
		prefix = dirApp;
	}

    var fileImportR = [
		{filePath: prefix + 'com/radaee/cordova/RadaeePDFPlugin.java', importStatement: 'com.radaee.reader.R'},
    	{filePath: prefix + 'com/radaee/pdf/Global.java', importStatement: 'com.radaee.viewlib.R'},
    	{filePath: prefix + 'com/radaee/reader/PDFLayoutView.java', importStatement: 'com.radaee.viewlib.R'},
    	{filePath: prefix + 'com/radaee/reader/PDFNavAct.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFViewAct.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFGLViewAct.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/GLView.java', importStatement: 'com.radaee.viewlib.R'},
    	{filePath: prefix + 'com/radaee/reader/PDFViewController.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFPagerAct.java', importStatement: 'com.radaee.reader.R'},
    	{filePath: prefix + 'com/radaee/util/OutlineListAdt.java', importStatement: 'com.radaee.viewlib.R'},
    	{filePath: prefix + 'com/radaee/util/PDFGridItem.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/PopupEditAct.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/CommonUtil.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RadaeePDFManager.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/BookmarkHandler.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/CaptureSignature.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/PDFThumbGrid.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotMenu.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotDlgComm.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotDlgIcon.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotDlgLine.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotDlgMarkup.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotDlgPopup.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotPopCombo.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIAnnotPopEdit.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIColorButton.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UIIconButton.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UILHeadButton.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/annotui/UILStyleButton.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFPagesAct.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/PDFPageGridAdt.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/view/GLLayoutReflow.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFPagerAct.java', importStatement: 'com.radaee.viewlib.R'},
	    {filePath: prefix + 'com/radaee/annotui/UIAnnotDlgSign.java', importStatement: 'com.radaee.viewlib.R'},
        {filePath: prefix + 'com/radaee/annotui/UIAnnotDlgSignProp.java', importStatement: 'com.radaee.viewlib.R'},
	    {filePath: prefix + 'com/radaee/util/FileBrowserAdt.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/PDFPageGridView.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RDGridItem.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/OutlineList.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/FileBrowserView.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RDGridView.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFMenu.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/reader/PDFMainAct.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RDFilesItem.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RDExpView.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RDRecentView.java', importStatement: 'com.radaee.viewlib.R'},
		{filePath: prefix + 'com/radaee/util/RDRecentItem.java', importStatement: 'com.radaee.viewlib.R'}
    ];


    console.log('*****************************************');
    console.log('*       inject file R  ANDROID             *');
    console.log('*****************************************');
	console.log('*       Inject: ' + replaceWith + '    *');

    fileImportR.forEach(function(val) {
    	var fullfilename = path.join(platformRoot, val.filePath);
    	console.log('*  Inject in file: ' + fullfilename + ' the import statemet: ' + val.importStatement + '  *');
    	if (fs.existsSync(fullfilename)) {
    		replace_string_in_file(fullfilename, val.importStatement, replaceWith);
    	} else {
            console.error('* missing file:', fullfilename);
        }
    });

	replace_string_in_file(path.join(platformRoot, prefix + 'com/radaee/reader/PDFViewController.java'), 'private int mNavigationMode = NAVIGATION_SEEK;', 'private int mNavigationMode = NAVIGATION_THUMBS;');

	replace_string_in_file(path.join(platformRoot, prefix + 'com/radaee/reader/PDFViewAct.java'), 'static protected Document ms_tran_doc;', 'static public Document ms_tran_doc;');
}
