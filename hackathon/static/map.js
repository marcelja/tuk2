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
        states[i]["properties"]["density"] = currentSqlResult[stateName][filterYear - 2013];
    }
    updateGeoJson();

}

function colorMap(sqlResult) {
    currentSqlResult = sqlResult;
    var states = statesData["features"];
    for (var i = 0; i<states.length; i++) {
        var stateName = states[i]["properties"]["name"];
        if (filterYear == -1) {
            states[i]["properties"]["density"] = calcAvg(sqlResult[stateName]);
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
    var value = document.getElementById("sql_dropdown").value;
    var yearValue = document.getElementById("year_dropdown").value;
    var genderValue = document.getElementById("gender_dropdown").value;

    var filters = [];
    if (yearValue != "") {
        filters.push("yearofbirth=" + yearValue);
    }
    if (genderValue != "") {
        filters.push("gender=" + genderValue);
    }
    if (filters.length == 0) {
        sqlRequest(value);
    } else {
        sqlRequest(value + "/" + filters.join());
    }
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
</div>

    <select id='sql_dropdown' onchange='updateMap()' style="display: none;">`

    var values = ["patients", "doctor_visits", "rel_patients", "rel_doctor_visits", "average_bmi", "smoking_status"];
    for (var i = 0; i < values.length; i++) {
        dd += '<option>' + values[i] + '</option>';
    }
    dd += "</select><select id='year_dropdown' onchange='updateMap()' style='display: none;'>";

    var years = ["","1922","1923","1924","1925","1926","1927","1928","1929","1930","1931","1932","1933","1934","1935","1936","1937","1938","1939","1940","1941","1942","1943","1944","1945","1946","1947","1948","1949","1950","1951","1952","1953","1954","1955","1956","1957","1958","1959","1960","1961","1962","1963","1964","1965","1966","1967","1968","1969","1970","1971","1972","1973","1974","1975","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989","1990","1991","1992","1993","1994"];
    for (var i = 0; i < years.length; i++) {
        dd += '<option>' + years[i] + '</option>';
    }
    dd += "</select><select id='gender_dropdown' onchange='updateMap()' style='display: none;'>";

    var genders = ["", "F", "M"];
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
