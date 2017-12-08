var map = L.map('map').setView([37.8, -96], 5);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    id: 'mapbox.outdoors'
}).addTo(map);

// control that shows state info on hover
var info = L.control();
var maxValue = 0;
var minValue = 0;

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
};

info.update = function (props) {
    this._div.innerHTML = '<h4>Patient Data in HANA</h4>' +  (props ?
        '<b>' + props.name + '</b><br />' + props.density + ' '
        : 'Hover over a state');
};

info.addTo(map);

// get color depending on values
function getColor(d) {
    var diff = maxValue - minValue;
    return d > diff * 0.6 + minValue ? '#800026' :
    d > diff * 0.35 + minValue ? '#BD0026' :
    d > diff * 0.25 + minValue ? '#E31A1C' :
    d > diff * 0.10 + minValue ? '#FC4E2A' :
    d > diff * 0.05 + minValue ? '#FD8D3C' :
    d > diff * 0.01 + minValue  ? '#FEB24C' :
    d > diff * 0.001 + minValue  ? '#FED976' :
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

function colorMap(sqlResult) {
    var states = statesData["features"];
    for (var i = 0; i<states.length; i++) {
        var stateName = states[i]["properties"]["name"].toUpperCase();
        var stateAbbrev = stateAbbrevs[stateName];

        states[i]["properties"]["density"] = sqlResult[stateAbbrev];
    }
    updateGeoJson();
}

function sqlRequest(input_string) {
    $.get( "sql_statement/" + input_string, function( data ) {
        maxValue = Math.max.apply(Math, Object.values(data));
        minValue = Math.min.apply(Math, Object.values(data));
        colorMap(data, maxValue);
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

    var dd = "<select id='sql_dropdown' onchange='updateMap()'>"
    var values = ["patients", "doctor_visits", "rel_patients", "rel_doctor_visits", "average_bmi", "smoking_status"];
    for (var i = 0; i < values.length; i++) {
        dd += '<option>' + values[i] + '</option>';
    }
    dd += "</select><br><br>Filters:<br>year of birth: <select id='year_dropdown' onchange='updateMap()'>";

    var years = ["","1922","1923","1924","1925","1926","1927","1928","1929","1930","1931","1932","1933","1934","1935","1936","1937","1938","1939","1940","1941","1942","1943","1944","1945","1946","1947","1948","1949","1950","1951","1952","1953","1954","1955","1956","1957","1958","1959","1960","1961","1962","1963","1964","1965","1966","1967","1968","1969","1970","1971","1972","1973","1974","1975","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989","1990","1991","1992","1993","1994"];
    for (var i = 0; i < years.length; i++) {
        dd += '<option>' + years[i] + '</option>';
    }
    dd += "</select><br>gender: <select id='gender_dropdown' onchange='updateMap()'>";

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
