class BurndownChart
  attr_accessor :dates, :version, :start_date, :sprint_data, :ideal_data
  
  class DateHoursPair
    attr_accessor :date, :hours
    def initialize(date, hours)
      self.date= date
      self.hours= hours
    end
  end
  class CachedIssue
      attr_accessor :issue, :ratio_details_map
      def initialize(issue)
        self.issue= issue
        self.ratio_details_map= issue.journals.map(&:details).flatten.select {|detail| 'done_ratio' == detail.prop_key }
        self.ratio_details_map.sort! {|a,b| a.journal.created_on <=> b.journal.created_on }
      end
  end
  
  def initialize(version)
    self.version = version
    @cached_all_issues= all_issues.collect do |issue|
         CachedIssue.new( issue )
    end    
    self.start_date = version.created_on.to_date
    end_date = version.effective_date.to_date
    @dates = (start_date..end_date).inject([]) { |accum, date| accum << date }
    generate_sprint_data
  end
  
  def generate_sprint_data

    
    max_data= nil
    @sprint_data ||= @dates.inject([]) do |data_map, date|
      issues = []
      @cached_all_issues.each do |cached_issue| 
        break if cached_issue.issue.created_on.to_date > date 
        issues<< cached_issue if cached_issue.issue.created_on.to_date <= date
      end
  
      total_hours= issues.inject(0) do |total_hours_left, cached_issue|
        details_today_or_earlier = []
        cached_issue.ratio_details_map.each do |a| 
            break if a.journal.created_on.to_date > date
            details_today_or_earlier<< a if a.journal.created_on.to_date <= date
        end
  
        last_done_ratio_change = details_today_or_earlier.last
  
        ratio = if last_done_ratio_change
          last_done_ratio_change.value
        elsif cached_issue.ratio_details_map.size > 0
          0
        else
          cached_issue.issue.done_ratio.to_i
        end
      
        total_hours_left += (cached_issue.issue.estimated_hours.to_i * (100-ratio.to_i)/100)
      end
      pair= DateHoursPair.new(date, total_hours)
      if max_data.nil? or  ( max_data.hours <= pair.hours and date <= Date.today) 
          max_data= pair
      end
      data_map << DateHoursPair.new(date, total_hours)
    end
    if max_data.nil? 
      @ideal_data= []
    else
      #By this point we should have the most recent day (before and including today) that had the most work outstanding on it
      #As this date is likely not the same date as the start of the sprint, we'll need to track backwards to calculate the 
      #estimated ideal burn-down rate,  that would have adequately covered the peak work (these lines are only guidance lines anyway so 
      #I guess it doesn't really matter, but if you happened to do you estimates *after* starting a sprint it will make those graphs
      # look a little saner.)
      end_data= DateHoursPair.new(@sprint_data.last.date, 0)
      
      if max_data.date == @sprint_data.first.date or max_data.date == @sprint_data.last.date
        start_data= max_data
      else
        # So we've a point on the line, and enough maths to work out the gradient to 'draw' a line back to the start of the sprint to work 
        # what the maximum amount of hours could conceivably have been 
        days_until_end= end_data.date - max_data.date
        days_since_start= max_data.date - @sprint_data.first.date
        hours= max_data.hours
        gradient=  hours / days_until_end
        original_conceivable_hours= hours + (gradient * days_since_start)
        start_data= DateHoursPair.new(@sprint_data.first.date,  original_conceivable_hours )
      end

      @ideal_data =[start_data]
      if start_data.date != end_data.date 
        gradient= start_data.hours / (  start_data.date - end_data.date) 
        d1= start_data.date
        d1 +=1 while (d1.wday != 1)
        gradient= start_data.hours / ( end_data.date - start_data.date) 
        d1.step(end_data.date, 7) do |date|
          hours=  start_data.hours- (gradient * (date-start_data.date))
          @ideal_data << DateHoursPair.new(date- 2,  hours)
          @ideal_data << DateHoursPair.new(date,  hours)
        end
      end
      @ideal_data<< end_data
    end
  end
    
  def all_issues
    issues= version.fixed_issues.find(:all, :include => [{:journals => :details}, :relations_from, :relations_to])
    issues.sort! {|a,b| a.created_on <=> b.created_on }
  end
end