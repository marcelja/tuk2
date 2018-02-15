var map = L.map('map').setView([37.8, -96], 5);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    id: 'mapbox.outdoors'
}).addTo(map);

// control that shows state info on hover
var info = L.control();
var maxValue = 0;
var minValue = 1;

var filterYear = -1;
var currentSqlResult;

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
    var diff = maxValue - minValue;
    return d > diff * 0.75 + minValue ? '#800026' :
    d > diff * 0.7 + minValue ? '#BD0026' :
    d > diff * 0.5 + minValue ? '#E31A1C' :
    d > diff * 0.35 + minValue ? '#FC4E2A' :
    d > diff * 0.3 + minValue ? '#FD8D3C' :
    d > diff * 0.25 + minValue  ? '#FEB24C' :
    d > diff * 0.2 + minValue  ? '#FED976' :
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
        layer.bringToFront();
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

function updateYearFilter(year) {
    filterYear = year;

    var states = statesData["features"];
    for (var i = 0; i<states.length; i++) {
        var stateName = states[i]["properties"]["name"];
        if (stateName in currentSqlResult) {
            states[i]["properties"]["density"] = currentSqlResult[stateName][filterYear - 2013];
        }
    }
    updateGeoJson();

}

function colorMap(sqlResult) {
    currentSqlResult = sqlResult;
    var states = statesData["features"];
    for (var i = 0; i<states.length; i++) {
        var stateName = states[i]["properties"]["name"];
        if (filterYear == -1) {
            if (stateName in sqlResult) {
                states[i]["properties"]["density"] = calcAvg(sqlResult[stateName]);
            }
        }
    }
    updateGeoJson();
}

function sqlRequest(input_string) {
    $.get( "sql_statement/" + input_string, function( data ) {
        maxValue = 0;
        minValue = 1;
        for (var key in data) {
          var max = Math.max(...data[key]);
          var min = Math.min(...data[key]);
          if (max > maxValue) maxValue = max;
          if (min < minValue) minValue = min;
        }
        console.log(minValue, maxValue);
        colorMap(data);
    });
}

function updateMap() {
    var value = document.getElementById("d_dropdown").value;
    // var yearValue = document.getElementById("year_dropdown").value;
    // var genderValue = document.getElementById("gender_dropdown").value;

    // var filters = [];
    console.log(value);
    if (value == "employment") {
        sqlRequest("employment");
        
    } else if (value == "depression diagnosis") {
        sqlRequest("depr")
    }
    else {
        sqlRequest("deprdays");
    }
    //  else {
    //     sqlRequest(value + "deprdays/" + filters.join());
    // }
}

function updateDropdown() {
    document.getElementById("myRange").value = 50;
    var output = document.getElementById("demo");
    output.innerHTML = "all years";
    updateYearFilter(-1);
    updateMap();
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

    dd += "<select id='d_dropdown' onchange='updateDropdown()'>";

    var genders = ["depression days", "depression diagnosis", "employment"];
    for (var i = 0; i < genders.length; i++) {
        dd += '<option>' + genders[i] + '</option>';
    }
    dd += "</select>";


    div.innerHTML = dd;
    return div;
};

dropdowns.addTo(map);

updateMap();
var slider = document.getElementById("myRange");
var output = document.getElementById("demo");
output.innerHTML = "all years";

slider.oninput = function() {
  map.dragging.disable();
  output.innerHTML = Math.round(this.value / 33 + 2013);
  updateYearFilter(Math.round(this.value / 33 + 2013))
}

slider.onmouseup = function() {
  map.dragging.enable();
}
