module RedmineBurndown
    module TimeEntryExtension
      TODO_FIELD_ID = CustomField.find_by_name('TODO').id

      def self.included(base)
        puts "TimeEntryExtension Inclued"
        base.class_eval {
          alias_method :__old_after_initialize__, :after_initialize
          def after_initialize
            puts "HACKING HERE..."
            __old_after_initialize__
            hours = 8.0
          end
        }
      end
    end 
end