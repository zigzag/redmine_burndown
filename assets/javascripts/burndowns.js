

// Figure out FLOT markings to represent weekends in a graph
// TAken from the FLOT examples on the website.
function burndownMarkings(axes) {
    var markings= [];
    var d = new Date(axes.xaxis.min);
    // go to the first Saturday
    d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 1) % 7))
    d.setUTCSeconds(0);
    d.setUTCMinutes(0);
    d.setUTCHours(0);
    var i = d.getTime();
    do {
        // when we don't set yaxis the rectangle automatically
        // extends to infinity upwards and downwards
        markings.push({ xaxis: { from: i, to: i + 2 * 24 * 60 * 60 * 1000 } });
        i += 7 * 24 * 60 * 60 * 1000;
    } while (i < axes.xaxis.max);

	// Add in 'today'
	var today= new Date();
    today.setUTCSeconds(0);
    today.setUTCMinutes(0);
    today.setUTCHours(0);
    i = today.getTime();

	markings.push( { xaxis: {from:i, to: i, lineWidth:6 },color:'#aaa' } )
    return markings;
}
