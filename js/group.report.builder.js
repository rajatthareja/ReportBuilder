window.onload = function() {
var gLabels = ['G1', 'G2', 'G3'];
var gDataSets = [{
        label: 'Total',
        backgroundColor: 'rgba(255, 206, 86, 0.2)',
        borderColor: 'rgba(255, 206, 86, 1)',
        borderWidth: 1,
        data: [400, 200, 300]
    },
    {
        label: 'Passed',
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        borderColor: 'rgba(75, 192, 192, 1)',
        borderWidth: 1,
        data: [300, 200, 210]
    },
    {
        label: 'Failed',
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1,
        data: [100, 0, 80]
    },
    {
        label: 'Other',
        backgroundColor: 'rgba(255, 206, 86, 0.2)',
        borderColor: 'rgba(255, 206, 86, 1)',
        borderWidth: 1,
        data: [0, 0, 10]
    }];
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
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true
                    }
                }]
            }
        }
    }).draw();
};