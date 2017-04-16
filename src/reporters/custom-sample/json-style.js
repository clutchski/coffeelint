/* jshint node: true */
"use strict";

var JsonReporter = function(errorReport) {
    this.errorReport = errorReport;
};

JsonReporter.prototype.getErrors = function(errors, path) {
    return errors.map(function(error) {
        return {
            Line: error.lineNumber,
            Message: "CoffeeLint: " + error.message,
            FileName: path
        };
    });
};

JsonReporter.prototype.publish = function() {
    var paths = this.errorReport.paths;
    var errorItems = [];

    for (var path in paths) {
        if (paths.hasOwnProperty(path)) {
            errorItems.push(this.getErrors(paths[path], path));
        }
    }

    process.stdout.write(JSON.stringify(errorItems));
};

module.exports = JsonReporter;
