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
    
    self.start_date = version.created_on.to_date
    end_date = version.effective_date.to_date
    @dates = (start_date..end_date).inject([]) { |accum, date| accum << date }
    generate_sprint_data
  end
  
  def generate_sprint_data
    cached_all_issues= all_issues.collect do |issue|
         CachedIssue.new( issue )
    end
    @sprint_data ||= @dates.inject([]) do |data_map, date|
      issues = []
      cached_all_issues.each do |cached_issue| 
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
      data_map << DateHoursPair.new(date, total_hours)
    end
    
    @ideal_data= [@sprint_data.first, DateHoursPair.new(@sprint_data.last.date, 0)]
  end
    
  def all_issues
    issues= version.fixed_issues.find(:all, :include => [{:journals => :details}, :relations_from, :relations_to])
    issues.sort! {|a,b| a.created_on <=> b.created_on }
  end
end