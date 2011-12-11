(function () {

    var buildReportTable = function (errors) {

        errors = errors.sort(function (a, b) {
            return a.line - b.line;
        });

        var table = $('<div class="error_report">');
        $.each(errors, function (index, error) {
            var row = $('<div></div>');
            var lc = $('<span class="lineNumber"></span>').html("Line #" + error.line + ':');
            var rc = $('<span class="reason"></span>').html(error.reason);
            row.append(lc, rc);
            table.append(row);
        });
        return table;
    };

    var displayReport = function (errors) {
        var success = errors.length == 0;

        var title = 'Your code is lint free!';
        var body = '';
        var rowClass = 'success';

        var body = $('.report .diatribe_body').empty();
        if (!success) {
            title = 'Your code has lint.';
            rowClass = 'failure'
            var table = buildReportTable(errors);
            body.append(table);
        }
        $('.report .diatribe_title').text(title);
        $('.report_row').removeClass('success failure').addClass(rowClass).slideDown();
    };

    var runLinter = function () {
        var source = $('.editor').val();
        var errors = coffeelint.lint(source);
        displayReport(errors);
    };

    $(document).ready(function () {
        $('.run').click(runLinter);
    });

})();
