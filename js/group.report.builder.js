window.onload = function() {

    var gDataSets = [
        {
            label: 'Passed',
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 1,
            data: []
        },
        {
            label: 'Failed',
            backgroundColor: 'rgba(255, 99, 132, 0.2)',
            borderColor: 'rgba(255, 99, 132, 1)',
            borderWidth: 1,
            data: []
        },
        {
            label: 'Skipped',
            backgroundColor: 'rgba(255, 206, 86, 0.2)',
            borderColor: 'rgba(255, 206, 86, 1)',
            borderWidth: 1,
            data: []
        },
        {
            label: 'Undefined',
            backgroundColor: 'rgba(255, 206, 86, 0.2)',
            borderColor: 'rgba(255, 206, 86, 1)',
            borderWidth: 1,
            data: []
        },
        {
            label: 'Pending',
            backgroundColor: 'rgba(255, 206, 86, 0.2)',
            borderColor: 'rgba(255, 206, 86, 1)',
            borderWidth: 1,
            data: []
        }];

    var gLabels = [];

    $(".group").each(function () {
        var $this = $(this);

        gLabels.push($this.find('div.collapsible-header>b').get(0).innerText);

        var passed = $this.find(".scenario.passed").length;
        var failed = $this.find(".scenario.failed").length;
        var skipped = $this.find(".scenario.skipped").length;
        var undefined = $this.find(".scenario.undefined").length;
        var pending = $this.find(".scenario.pending").length;

        if (passed > 0) {
            $this.find(">.collapsible-header").append("<span class=\"new badge teal lighten-2\" data-badge-caption=\"Passed\">" + passed + "</span>");
        }
        if (failed > 0) {
            $this.find(">.collapsible-header").append("<span class=\"new badge red lighten-2\" data-badge-caption=\"Failed\">" + failed + "</span>");
        }
        if (skipped > 0) {
            $this.find(">.collapsible-header").append("<span class=\"new badge amber lighten-2\" data-badge-caption=\"Skipped\">" + skipped + "</span>");
        }
        if (undefined > 0) {
            $this.find(">.collapsible-header").append("<span class=\"new badge amber lighten-2\" data-badge-caption=\"Undefined\">" + undefined + "</span>");
        }
        if (pending > 0) {
            $this.find(">.collapsible-header").append("<span class=\"new badge amber lighten-2\" data-badge-caption=\"Pending\">" + pending + "</span>");
        }

        gDataSets[0]['data'].push(passed);
        gDataSets[1]['data'].push(failed);
        gDataSets[2]['data'].push(skipped);
        gDataSets[3]['data'].push(undefined);
        gDataSets[4]['data'].push(pending);
    });

    var ctx = document.getElementById("groupBarChart").getContext("2d");
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: gLabels,
            datasets: gDataSets
        },
        options: {
            title: {
                display: true,
                text: 'Scenarios'
            },
            tooltips: {
                mode: 'index',
                intersect: false
            },
            responsive: true,
            scales: {
                xAxes: [{
                    stacked: true
                }],
                yAxes: [{
                    stacked: true,
                    ticks: {
                        beginAtZero: true
                    }
                }]
            }
        }
    }).draw();

    $(".groupErrorList .groupError").each(function () {
        var $this = $(this);
        var eCount = $this.find(".failedScenarioList .failedScenario").length;
        if (eCount > 0) {
            $this.find(">.collapsible-header").append("<span class=\"new badge blue lighten-2\" data-badge-caption=\"Scenarios\">" + eCount + "</span>");
        } else {
            $this.remove();
        }
    });
};