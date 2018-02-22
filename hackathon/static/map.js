var map = L.map('map').setView([37.8, -96], 5);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    id: 'mapbox.outdoors'
}).addTo(map);

// control that shows state info on hover
var info = L.control();
var maxValue1 = 0;
var maxValue2 = 0;
var minValue1 = 1;
var minValue2 = 1;
var circles = [];

var filterYear = -1;
var currentSqlResult1;
var currentSqlResult2;

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
};

info.update = function (props) {
    this._div.innerHTML = '<h4>Depression Data in the USA</h4>' +  (props ?
        '<b>' + props.name + '</b><br />' + props.density + ' '
        : 'Hover over a state');
};

info.addTo(map);

// get color depending on values
function getColor(d) {
    var diff = maxValue1 - minValue1;
    return d > diff * 0.75 + minValue1 ? '#800026' :
    d > diff * 0.7 + minValue1 ? '#BD0026' :
    d > diff * 0.5 + minValue1 ? '#E31A1C' :
    d > diff * 0.35 + minValue1 ? '#FC4E2A' :
    d > diff * 0.3 + minValue1 ? '#FD8D3C' :
    d > diff * 0.25 + minValue1  ? '#FEB24C' :
    d > diff * 0.2 + minValue1  ? '#FED976' :
    '#FFEDA0';
}

function style(feature) {
    return {
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.7,
        fillColor: getColor(feature.properties.density)
    };
}

function highlightFeature(e) {
    var layer = e.target;

    layer.setStyle({
        weight: 5,
        color: '#666',
        dashArray: '',
        fillOpacity: 0.7
    });

    if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        // layer.bringToFront();
    }

    info.update(layer.feature.properties);
}

var geojson;

function resetHighlight(e) {
    geojson.resetStyle(e.target);
    info.update();
}

function zoomToFeature(e) {
    map.fitBounds(e.target.getBounds());
}

function onEachFeature(feature, layer) {
    layer.on({
        mouseover: highlightFeature,
        mouseout: resetHighlight,
        click: zoomToFeature
    });
}

function updateGeoJson() {
    map.removeLayer(geojson);
    geojson = L.geoJson(statesData, {
        style: style,
        onEachFeature: onEachFeature
    }).addTo(map);
}

function calcAvg(list) {
    var total = 0;
    for(var i = 0; i < list.length; i++) {
        total += list[i];
    }
    return total / list.length;
}


function setRadius() {
    for (var i = 0; i < circles.length; i++) {
            map.removeLayer(circles[i]);

    }
    var states = statesData["features"];
    for (var i = 0; i < statesData["features"].length; i++) {
        var center = L.polygon(statesData["features"][i]["geometry"]["coordinates"]).getBounds().getCenter();
        var stateName = states[i]["properties"]["name"];
        var value;

        if (stateName in currentSqlResult2) {
            if (filterYear == -1) {
                value = calcAvg(currentSqlResult2[stateName]);
            } else {
                value = currentSqlResult2[stateName][filterYear - 2013];
            }
            if (value != undefined) {
                var circle = L.rectangle([[center["lng"], center["lat"] - 0.25], [center["lng"] + ((value - minValue2) / (maxValue2 - minValue2)) * 3, center["lat"] + 0.25]], {color: "blue", weight: 2}).addTo(map);


                // L.circle([center["lng"], center["lat"]], {
                //     color: 'blue',
                //     fillColor: 'blue',
                //     fillOpacity: 0.5,
                //     radius: ((value - minValue2) / (maxValue2 - minValue2)) * 100000
                // }).addTo(map);
                circles.push(circle);
            }
        }
    }
}

function colorMap() {
    var states = statesData["features"];
    for (var i = 0; i<states.length; i++) {
        var stateName = states[i]["properties"]["name"];
        if (stateName in currentSqlResult1) {
            var value;
            if (filterYear == -1) {
                value = calcAvg(currentSqlResult1[stateName]);
            } else {
                value = currentSqlResult1[stateName][filterYear - 2013];
            }
            states[i]["properties"]["density"] = value;
        }
    }

    updateGeoJson();
}

function sqlRequest1(input_string) {
    $.get( "sql_statement/" + input_string, function( data ) {
        maxValue1 = 0;
        minValue1 = 1;
        for (var key in data) {
          var max = Math.max(...data[key]);
          var min = Math.min(...data[key]);
          if (max > maxValue1) maxValue1 = max;
          if (min < minValue1) minValue1 = min;
        }
        currentSqlResult1 = data;

        // console.log(minValue, maxValue);
        colorMap();
    });
}

function sqlRequest2(input_string) {
    $.get( "sql_statement/" + input_string, function( data ) {
        maxValue2 = 0;
        minValue2 = 1;
        for (var key in data) {
          var max = Math.max(...data[key]);
          var min = Math.min(...data[key]);
          if (max > maxValue2) maxValue2 = max;
          if (min < minValue2) minValue2 = min;
        }
        // console.log(minValue, maxValue);
        currentSqlResult2 = data;

        setRadius();
    });
}

function initMap() {
    sqlRequest1("depression days");
    sqlRequest2("unable or unemployed");
}

function updateDropdown() {
    document.getElementById("myRange").value = 50;
    var output = document.getElementById("demo");
    output.innerHTML = "all years";
    filterYear = -1;

    var dd1 = document.getElementById("d_dropdown1");
    var dd2 = document.getElementById("d_dropdown2");
    console.log(dd1.value, dd2.value);

    sqlRequest1(dd1.value);
    sqlRequest2(dd2.value);


}

geojson = L.geoJson(statesData, {
    style: style,
    onEachFeature: onEachFeature
}).addTo(map);

var dropdowns = L.control({position: 'bottomright'});

dropdowns.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'info dropdowns');

    var dd = `<div class="slidecontainer">
  <input type="range" min="1" max="100" value="50" class="slider" id="myRange">
  <p>Year: <span id="demo"></span></p>
</div>`

    dd += "<select id='d_dropdown1' onchange='updateDropdown()'>";
    var genders = ["depression diagnosis", "depression days", "unable or unemployed"];
    for (var i = 0; i < genders.length; i++) {
        dd += '<option>' + genders[i] + '</option>';
    }
    dd += "</select>";

    dd += "<select id='d_dropdown2' onchange='updateDropdown()'>";
    var genders = ["unable or unemployed", "depression diagnosis", "depression days"];
    for (var i = 0; i < genders.length; i++) {
        dd += '<option>' + genders[i] + '</option>';
    }
    dd += "</select>";

    div.innerHTML = dd;
    return div;
};

dropdowns.addTo(map);

initMap();
var slider = document.getElementById("myRange");
var output = document.getElementById("demo");
output.innerHTML = "all years";

slider.oninput = function() {
  map.dragging.disable();
  output.innerHTML = Math.round(this.value / 33 + 2013);
  filterYear = Math.round(this.value / 33 + 2013);
  colorMap();
  setRadius();
}

slider.onmouseup = function() {
  map.dragging.enable();
}
