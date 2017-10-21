$(document).ready(function () {
    $(".passed").addClass("teal lighten-2");
    $(".failed").addClass("red lighten-2");
    $(".skipped").addClass("amber lighten-2");
    $(".undefined").addClass("amber lighten-2");
    $(".pending").addClass("amber lighten-2");

    var passed = $(".scenario.passed");
    var failed = $(".scenario.failed");
    var skipped = $(".scenario.skipped");
    var undefined = $(".scenario.undefined");
    var pending = $(".scenario.pending");
    var scenarios = $(".scenario");

    var working = $(".feature.working");
    var broken = $(".feature.broken");
    var incomplete = $(".feature.incomplete");
    var features = $(".feature");

    passed.prepend("<i class=\"material-icons\">done_all</i>");
    failed.prepend("<i class=\"material-icons\">highlight_off</i>");
    skipped.prepend("<i class=\"material-icons\">error_outline</i>");
    undefined.prepend("<i class=\"material-icons\">error_outline</i>");
    pending.prepend("<i class=\"material-icons\">error_outline</i>");

    features.each(function () {
        var $this = $(this);
        var pCount = $this.find(".scenario.passed").length;
        var fCount = $this.find(".scenario.failed").length;
        var sCount = $this.find(".scenario.skipped").length;
        var uCount = $this.find(".scenario.undefined").length;
        var ppCount = $this.find(".scenario.pending").length;
        if (pCount > 0) {
            $this.find(".collapsible-header").append("<span class=\"new badge teal lighten-2\" data-badge-caption=\"Passed\">" + pCount + "</span>");
        }
        if (fCount > 0) {
            $this.find(".collapsible-header").append("<span class=\"new badge red lighten-2\" data-badge-caption=\"Failed\">" + fCount + "</span>");
        }
        if (sCount > 0) {
            $this.find(".collapsible-header").append("<span class=\"new badge amber lighten-2\" data-badge-caption=\"Skipped\">" + sCount + "</span>");
        }
        if (uCount > 0) {
            $this.find(".collapsible-header").append("<span class=\"new badge amber lighten-2\" data-badge-caption=\"Undefined\">" + uCount + "</span>");
        }
        if (ppCount > 0) {
            $this.find(".collapsible-header").append("<span class=\"new badge amber lighten-2\" data-badge-caption=\"Pending\">" + ppCount + "</span>");
        }
    });

    $(".errorList .error").each(function () {
        var $this = $(this);
        var eCount = $this.find(".failedScenarioList .failedScenario").length;
        if (eCount > 0) {
            $this.find(".collapsible-header").append("<span class=\"new badge blue lighten-2\" data-badge-caption=\"Scenarios\">" + eCount + "</span>");
        } else {
            $this.remove();
        }
    });

    $(".tabs .tab").click(function () {
        $(".tabs a").removeClass("blue-text").addClass("white-text");
        $(this).find('a').removeClass("white-text").addClass("blue-text");
    });

    var passedCount = passed.length;
    var failedCount = failed.length;
    var skippedCount = skipped.length;
    var undefinedCount = undefined.length;
    var pendingCount = pending.length;
    var scenariosCount = scenarios.length;

    var workingCount = working.length;
    var brokenCount = broken.length;
    var incompleteCount = incomplete.length;
    var featuresCount = features.length;

    var metaTableFeatures = $("table#metaDataFeatures tbody");
    var metaTableScenarios = $("table#metaDataScenarios tbody");

    metaTableFeatures.append("<tr><th>Total Features</th><td>" + featuresCount + "</td></tr>");
    metaTableScenarios.append("<tr><th>Total Scenarios</th><td>" + scenariosCount + "</td></tr>");

    var featuresDoughnut = document.getElementById("featuresDoughnut").getContext('2d');
    var featuresDoughnutCountData = [];
    var featuresDoughnutLabels = [];
    var featuresDoughnutBackgroundColor = [];
    var featuresDoughnutBorderColor = [];
    if (workingCount > 0) {
        metaTableFeatures.append("<tr><th>Working</th><td>" + ((workingCount / featuresCount) * 100).toFixed(1) + " %</td></tr>");
        featuresDoughnutCountData.push(workingCount);
        featuresDoughnutLabels.push("Working");
        featuresDoughnutBackgroundColor.push('rgba(75, 192, 192, 0.2)');
        featuresDoughnutBorderColor.push('rgba(75, 192, 192, 1)');
    }
    if (brokenCount > 0) {
        metaTableFeatures.append("<tr><th>Broken</th><td>" + ((brokenCount / featuresCount) * 100).toFixed(1) + " %</td></tr>");
        featuresDoughnutCountData.push(brokenCount);
        featuresDoughnutLabels.push("Broken");
        featuresDoughnutBackgroundColor.push('rgba(255, 99, 132, 0.2)');
        featuresDoughnutBorderColor.push('rgba(255, 99, 132, 1)');
    }
    if (incompleteCount > 0) {
        metaTableFeatures.append("<tr><th>Incomplete</th><td>" + ((incompleteCount / featuresCount) * 100).toFixed(1) + " %</td></tr>");
        featuresDoughnutCountData.push(incompleteCount);
        featuresDoughnutLabels.push("Incomplete");
        featuresDoughnutBackgroundColor.push('rgba(255, 206, 86, 0.2)');
        featuresDoughnutBorderColor.push('rgba(255, 206, 86, 1)');
    }
    var featuresDoughnutData = {
        labels: featuresDoughnutLabels,
        datasets: [
            {
                label: '# of Votes',
                data: featuresDoughnutCountData,
                backgroundColor: featuresDoughnutBackgroundColor,
                borderColor: featuresDoughnutBorderColor,
                borderWidth: 1
            }
        ]
    };
    var featuresDoughnutOptions = {
        title: {
            display: true,
            text: 'Features'
        }
    };
    var featuresDoughnutChart = new Chart(featuresDoughnut, {
        type: 'doughnut',
        data: featuresDoughnutData,
        options: featuresDoughnutOptions
    });

    if (featuresDoughnutCountData.length > 0) {
        featuresDoughnutChart.draw();
    }

    var scenariosDoughnut = document.getElementById("scenariosDoughnut").getContext('2d');
    var scenariosDoughnutCountData = [];
    var scenariosDoughnutLabels = [];
    var scenariosDoughnutBackgroundColor = [];
    var scenariosDoughnutBorderColor = [];
    if (passedCount > 0) {
        metaTableScenarios.append("<tr><th>Passed</th><td>" + ((passedCount / scenariosCount) * 100).toFixed(1) + " %</td></tr>");
        scenariosDoughnutCountData.push(passedCount);
        scenariosDoughnutLabels.push("Passed");
        scenariosDoughnutBackgroundColor.push('rgba(75, 192, 192, 0.2)');
        scenariosDoughnutBorderColor.push('rgba(75, 192, 192, 1)');
    }
    if (failedCount > 0) {
        metaTableScenarios.append("<tr><th>Failed</th><td>" + ((failedCount / scenariosCount) * 100).toFixed(1) + " %</td></tr>");
        scenariosDoughnutCountData.push(failedCount);
        scenariosDoughnutLabels.push("Failed");
        scenariosDoughnutBackgroundColor.push('rgba(255, 99, 132, 0.2)');
        scenariosDoughnutBorderColor.push('rgba(255,99,132,1)');
    }
    if (skippedCount > 0) {
        metaTableScenarios.append("<tr><th>Skipped</th><td>" + ((skippedCount / scenariosCount) * 100).toFixed(1) + " %</td></tr>");
        scenariosDoughnutCountData.push(skippedCount);
        scenariosDoughnutLabels.push("Skipped");
        scenariosDoughnutBackgroundColor.push('rgba(255, 206, 86, 0.2)');
        scenariosDoughnutBorderColor.push('rgba(255, 206, 86, 1)');
    }
    if (undefinedCount > 0) {
        metaTableScenarios.append("<tr><th>Undefined</th><td>" + ((undefinedCount / scenariosCount) * 100).toFixed(1) + " %</td></tr>");
        scenariosDoughnutCountData.push(undefinedCount);
        scenariosDoughnutLabels.push("Undefined");
        scenariosDoughnutBackgroundColor.push('rgba(255, 206, 86, 0.2)');
        scenariosDoughnutBorderColor.push('rgba(255, 206, 86, 1)');
    }
    if (pendingCount > 0) {
        metaTableScenarios.append("<tr><th>Pending</th><td>" + ((pendingCount / scenariosCount) * 100).toFixed(1) + " %</td></tr>");
        scenariosDoughnutCountData.push(pendingCount);
        scenariosDoughnutLabels.push("Pending");
        scenariosDoughnutBackgroundColor.push('rgba(255, 206, 86, 0.2)');
        scenariosDoughnutBorderColor.push('rgba(255, 206, 86, 1)');
    }
    var scenariosDoughnutData = {
        labels: scenariosDoughnutLabels,
        datasets: [
            {
                label: '# of Votes',
                data: scenariosDoughnutCountData,
                backgroundColor: scenariosDoughnutBackgroundColor,
                borderColor: scenariosDoughnutBorderColor,
                borderWidth: 1
            }
        ]
    };
    var scenariosDoughnutOptions = {
        title: {
            display: true,
            text: 'Scenarios'
        }
    };
    var scenariosDoughnutChart = new Chart(scenariosDoughnut, {
        type: 'doughnut',
        data: scenariosDoughnutData,
        options: scenariosDoughnutOptions
    });

    if (scenariosDoughnutCountData.length > 0) {
        scenariosDoughnutChart.draw();
    }

    $.when($('#summaryTable').DataTable({
        "language": {
            "search": "<i class=\"material-icons\">search</i> Search",
            "searchPlaceholder": "Search",
            "lengthMenu": "Show _MENU_",
            "info": "Showing _START_ to _END_ of _TOTAL_ scenarios",
            "infoFiltered": "filtered from _MAX_ total scenarios"
        }
    })).done(function () {
        $('select').material_select();
    });
});