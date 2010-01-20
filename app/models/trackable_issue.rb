module TrackableIssue
  TODO_FIELD_ID = CustomField.find_by_name('TODO').id

  def self.extended(base)
    base.class_eval do 
      def planned_hours 
        # Only collect the issues which have not children because the parent issue's estimated time 
        # is already caculated by summing up children's by subtask plugin.
        (children_count == 0) ? (estimated_hours || 0) : 0
      end 
      def done_hours_till(date)
        time_entries_till(date).sum(&:hours)
      end
      def todo_hours_till(date)
        last_entry = time_entries_till(date).sort_by(&:spent_on).sort_by(&:updated_on).last
        last_todo_wrapper = last_entry.custom_value_for(TODO_FIELD_ID) if last_entry
        last_todo_wrapper ? last_todo_wrapper.value.to_f : planned_hours
      end
      def insight_hours_till(date)
        done_hours_till(date) + todo_hours_till(date)
      end
      def latest_entry_date
        time_entries.map(&:spent_on).sort.last
      end
      def first_entry_date
        time_entries.map(&:spent_on).sort.first
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
