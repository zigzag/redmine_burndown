//TODO: STick these methods into a prototype/namespace to avoid conflicts.


// Figure out FLOT markings to represent weekends in a graph
// TAken from the FLOT examples on the website.
function weekendAreas(axes) {
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

    return markings;
}

// Plot a FLOT chart passing a particular div element to base the canvas on 
// and the real + ideal data to render.
function plotChart(elementId, real_data, ideal_data) {
	var config= { xaxis: { mode: "time" },
				  lines: { show: true },
				  points: { show: true },
				  grid: { markings: weekendAreas }};
				
	jQuery.plot(jQuery("#" + elementId),  
				[{  label:"Est. Remaining Time",
	            	data: real_data}, {
					label:"Ideal Burn-down",
					data: ideal_data}],
				config);
};