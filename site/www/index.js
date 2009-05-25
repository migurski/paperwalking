// "import" the namespace
var mm = com.modestmaps;

var tileURL = function(coord) {
    return 'http://tile.cloudmade.com/f1fe9c2761a15118800b210c0eda823c/997/256/' + coord.zoom + '/' + coord.column + '/' + coord.row + '.png';
}

function formatDegree(value, axis)
{
    var dir = value;
    var val = Math.abs(value);
    
    var deg = Math.floor(val);
    val = (val - deg) * 60;
    
    var min = Math.floor(val);
    val = (val - min) * 60;
    
    var sec = Math.floor(val);
    
    var str = deg + '°';
    
    if(min <= 9)
        str += '0';

    str += min + "'";
    
    if(sec <= 9)
        str += '0';

    str += sec + '"';
    
    if(axis == 'lat') {
        str += (dir >= 0) ? 'N' : 'S';
    
    } else {
        str += (dir >= 0) ? 'E' : 'W';
    }
    
    return str;
}

function onMapChanged(map)
{
    var center = map.getCenter();
    var info = document.getElementById('info');
    var warn = document.getElementById('zoom-warning');

    info.innerHTML = formatDegree(center.lat, 'lat') + ', ' + formatDegree(center.lon, 'lon') + ' at zoom level ' + map.coordinate.zoom + '.';
    warn.style.display = (map.getZoom() < 14) ? 'inline' : 'none';
    
    var northwest = map.pointLocation(new mm.Point(0, 0));
    var southeast = map.pointLocation(map.dimensions);
    var form = document.forms['bounds'];
    
    form.elements['north'].value = northwest.lat;
    form.elements['south'].value = southeast.lat;
    form.elements['east'].value = southeast.lon;
    form.elements['west'].value = northwest.lon;
    form.elements['zoom'].value = map.coordinate.zoom;
}

function makeMap(elementID)
{
    var map = new mm.Map(elementID, new mm.MapProvider(tileURL), new mm.Point(360, 456))

    map.addCallback('zoomed',    function(m, a) { return onMapChanged(m); });
    map.addCallback('centered',  function(m, a) { return onMapChanged(m); });
    map.addCallback('extentset', function(m, a) { return onMapChanged(m); });
    map.addCallback('panned',    function(m, a) { return onMapChanged(m); });

    map.setCenterZoom(new mm.Location(37.660, -122.168), 9);
    map.draw();
    
    return map;
}