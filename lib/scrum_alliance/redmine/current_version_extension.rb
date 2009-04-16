module ScrumAlliance
  module Redmine
    module CurrentVersionExtension
      def current_version
        my_versions= versions.sort {|a,b| a.effective_date <=> b.effective_date }
        my_versions.detect {|version| version.created_on.to_date <= Date.current && version.effective_date >= Date.current }
      end
    end # CurrentVersionExtension
  end # Redmine
end # ScrumAlliance