module BurndownsHelper
  def render_burndown(chart, options = {})    
    # Assign some default widths and heights, incase none are specified (FLOT really needs a size!)
    options[:width] ||=200
    options[:height] ||=200
    
    # Pull out the data and format appropriately from the model.
    real_data_dates= chart.dates
    real_data= chart.sprint_data
    ideal_data= chart.ideal_data
    real_data_joined= real_data.join(',');
    real_data_dates_joined= real_data_dates.map {|d| d.to_time.to_i*1000 }.join(',');
    
    # Build up and return the Javascript
    # TODO: Currently we're mapping the two seperate arrays of date and data back together in data
    #   tuples, this could and should be done in the ruby, but I'm still playing...
    return <<EOS
<p><div id="placeholder" style="width:#{options[:width]}px;height:#{options[:height]}px"></div>
<script id="source" language="javascript" type="text/javascript">
	var data= [];
	var remaining_work = [#{real_data_joined}];
	var dates = [#{real_data_dates_joined}];
	for( var i=0;i< dates.length;i++) {
		data.push([dates[i], remaining_work[i]])
	}
	
	var ideal_data=[[dates[0],#{ideal_data[0]}],[dates[dates.length-1],#{ideal_data[1]}]];
	plotChart("placeholder", data, ideal_data);
</script>
</p>
EOS
  end
end