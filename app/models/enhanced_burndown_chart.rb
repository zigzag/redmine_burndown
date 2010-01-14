class EnhancedBurndownChart
  attr_accessor :version
  DateHoursPair = Struct.new(:date, :hours)
  TrackedIssue = Issue.clone.extend(TrackableIssue)

  def initialize(version)
    @version = version
  end
  
  def planned_data
    [start_date,effective_date].inject([]) do |planned_data, date| 
      planned_data << DateHoursPair.new(date,all_issues.sum(&:planned_hours))
    end
  end

  def insight_data
    (start_date..latest_entry_date).inject([]) do |insight_data, date| 
      insight_data << DateHoursPair.new(date,sum_up_hours(:insight_hours_till,date))
    end
  end

  def todo_data
    (start_date..latest_entry_date).inject([]) do |todo_data, date| 
      todo_data << DateHoursPair.new(date,sum_up_hours(:todo_hours_till,date))
    end
  end
  
  def predict_data
    # (latest_entry_date..effective_date).inject([]) do |predict_data, date|
    #   hours = start_date_todo_hours - (velocity * (date - start_date))
    #   predict_data << DateHoursPair.new(date,hours)
    # end
    predict_data = []
    date = latest_entry_date
    todo = latest_date_todo_hours
    begin
      predict_data << DateHoursPair.new(date,todo)
      todo -= velocity unless [0,6].include?(date.wday)
      date += 1.day
    end until todo < 0
    predict_data << DateHoursPair.new(date,0)
    predict_data
  end

  private 
  def all_issues
    @all_issues ||= EnhancedBurndownChart::TrackedIssue.find_all_by_fixed_version_id(version.id,:include=>[:time_entries])
  end
  def sum_up_hours(hours_method,till_date)
    all_issues.sum { |issue| issue.send(hours_method,till_date)}
  end
  def count_working_days(from,to)
    (from..to).reject { |d| [0,6].include? d.wday }.count
  end
  
  def start_date
    @start_date ||= version.created_on.to_date
  end
  def effective_date
    @effective_date ||= version.effective_date.to_date
  end
  def latest_entry_date
    @latest_entry_date ||= all_issues.map(&:latest_entry_date).compact.sort.last || effective_date
  end
  def start_date_todo_hours
    @start_date_todo_hours ||= sum_up_hours(:todo_hours_till,start_date)
  end
  def latest_date_todo_hours
    @latest_date_todo_hours ||= sum_up_hours(:todo_hours_till,latest_entry_date)
  end
  
  def velocity
    @velocity ||= (start_date_todo_hours - latest_date_todo_hours) / count_working_days(start_date,latest_entry_date)
  end
end