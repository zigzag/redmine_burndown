

// Figure out FLOT markings to represent weekends in a graph
// TAken from the FLOT examples on the website.
function burndownMarkings(axes) {
    var markings= [];
    var d = new Date(axes.xaxis.min);
    // go to the first Saturday
    d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 1) % 7));
    var i = getUTCMidnight(d);

    do {
        // when we don't set yaxis the rectangle automatically
        // extends to infinity upwards and downwards
        markings.push({ xaxis: { from: i, to: i + 2 * 24 * 60 * 60 * 1000 } });
        i += 7 * 24 * 60 * 60 * 1000;
    } while (i < axes.xaxis.max);

	// Add in 'today'
    i = getUTCMidnight(new Date());
	markings.push( { xaxis: {from:i, to: i, lineWidth:6 },color:'#aaa' } )
    return markings;
}

function getUTCMidnight(date) {
	date.setUTCSeconds(0);
	date.setUTCMinutes(0);
    date.setUTCHours(0);
    return date.getTime();
}
