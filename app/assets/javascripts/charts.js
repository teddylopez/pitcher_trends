$(document).ready(function () {
  if ($(".trends-wrapper").length > 0) {
    $(".trends-wrapper").delay(1000).animate({ opacity: "1" }, 700);
    var playerId = $(".trends-wrapper").data("player-id");
    var dropdown = $("#trends-year-select");
    var chartKey = [
      "velo",
      "height",
      "extension",
      "spin",
      "hbreak",
      "vbreak",
      "axis",
    ];

    $.get("/build_charts", function (response) {
      populateDropdown(dropdown, response["data"]["seasons"]);

      $.each(chartKey, function (index, key) {
        buildChart(response["data"]["seasons"][0], response, key);
      });

      $("select").change(function () {
        var year = $(this).val();

        $.each(chartKey, function (index, key) {
          clearChart(key);
          buildChart(year, response, key);
        });
      });
    });
  }

  function populateDropdown(dropdown, response) {
    $.each(response, function (key, entry) {
      dropdown.append($("<option></option>").attr("value", entry).text(entry));
    });
  }

  function clearChart(key) {
    $("#" + key + "-chart").remove();
    $("#" + key + "-container").append(
      "<canvas id='" + key + "-chart'></canvas>"
    );
  }

  function buildChart(year, response, key) {
    var ctx = document.getElementById(key + "-chart").getContext("2d");

    var chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: response["data"]["labels"][year],
        datasets: buildDatasets(year, response, key),
      },
      options: {
        responsive: true,
        legend: {
          position: "bottom",
          onHover: function (e) {
            e.target.style.cursor = "pointer";
          },
        },
        hover: {
          onHover: function (e) {
            var point = this.getElementAtEvent(e);
            if (point.length) e.target.style.cursor = "pointer";
            else e.target.style.cursor = "default";
          },
        },
        scales: {
          yAxes: [
            {
              scaleLabel: {
                display: true,
                labelString: setYAxes(key),
                fontSize: 17,
              },
            },
          ],
          xAxes: [
            {
              scaleLabel: {
                display: true,
                labelString: "Game Date",
                fontSize: 17,
              },
              type: "time",
              distribution: "linear",
              time: {
                displayFormats: {
                  day: "MMM DD, YYYY",
                },
              },
              ticks: {
                autoSkip: true,
                maxTicksLimit: 20,
              },
              gridLines: {
                display: false,
              },
            },
          ],
        },
        plugins: {
          colorschemes: {
            scheme: [
              "#ff4444",
              "#ffeb3b",
              "#4285F4",
              "#9933CC",
              "#2BBBAD",
              "#00C851",
              "#FF8800",
            ],
          },
        },
      },
    });

    function buildDatasets(year, response, key) {
      var output = [];
      $.each(response["data"]["datasets"][key + "_data"], function (
        index,
        value
      ) {
        if (
          response["data"]["datasets"][key + "_data"][index]["season"][year]
        ) {
          output.push({
            label: response["data"]["datasets"][key + "_data"][index]["label"],
            data:
              response["data"]["datasets"][key + "_data"][index]["season"][
                year
              ]["data"],
            fill: false,
            lineTension: 0.5,
            borderDashOffset: 1,
            pointRadius: 2,
            pointHitRadius: 5,
          });
        }
      });
      return output;
    }

    function setYAxes(key) {
      var chart_axes = {
        velo: "MPH",
        height: "Height (Inches)",
        extension: "Extension (Inches)",
        spin: "RPM",
        hbreak: "Horizontal Break (Inches)",
        vbreak: "Vertical Break (Inches)",
        axis: "Axis Degree",
      };
      return chart_axes[key];
    }

    return chart;
  }
});
