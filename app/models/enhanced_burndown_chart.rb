class EnhancedBurndownChart
  attr_accessor :version
  DateHoursPair = Struct.new(:date, :hours)
  TODO_FIELD_ID = CustomField.find_by_name('TODO').id

  module TrackableIssue
    def self.extended(base)
      base.class_eval do 
        def planned_hours 
          # Only collect the issues which have not children because the parent issue's estimated time 
          # is already caculated by summing up children's by subtask plugin.
          (children_count == 0) ? estimated_hours : 0
        end 
        def done_hours_till(date)
          time_entries_till(date).sum(&:hours)
        end
        def todo_hours_till(date)
          return 0 unless (children_count == 0)
          last_entry = time_entries_till(date).sort_by(&:spent_on).sort_by(&:updated_on).last
          last_todo_wrapper = last_entry.custom_value_for(TODO_FIELD_ID) if last_entry
          last_todo_wrapper ? last_todo_wrapper.value.to_f : planned_hours
        end
        def insight_hours_till(date)
          done_hours_till(date) + todo_hours_till(date)
        end

        private 
        def time_entries_till(date)
          time_entries.select{ |entry| entry.spent_on < date}
        end
        def children_count
          @children_count ||= children.count
        end
      end 
    end
  end
  
  TrackedIssue = Issue.clone.extend(TrackableIssue)

  def initialize(version)
    @version = version
    @start_date = @version.created_on.to_date
    @effective_date = @version.effective_date.to_date
  end
  
  def planned_data
    (@start_date..@effective_date).inject([]) do |planned_data, date| 
      planned_data << DateHoursPair.new(date,all_issues.sum(&:planned_hours))
    end
  end

  def insight_data
    (@start_date..@effective_date).inject([]) do |insight_data, date| 
      insight_data << DateHoursPair.new(date,all_issues.sum { |issue| issue.insight_hours_till(date)})
    end
  end

  def todo_data
    (@start_date..@effective_date).inject([]) do |todo_data, date| 
      todo_data << DateHoursPair.new(date,all_issues.sum { |issue| issue.todo_hours_till(date)})
    end
  end

  private 
  def all_issues
    @all_issues ||= EnhancedBurndownChart::TrackedIssue.find_all_by_fixed_version_id(@version.id,:include=>[:time_entries])
  end

end