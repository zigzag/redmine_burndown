module ScrumAlliance
  module Redmine
    module CurrentVersionExtension
      def current_version
        my_versions= versions.select(&:effective_date).sort {|a,b| a.effective_date <=> b.effective_date }
        my_versions.detect{|version| version.created_on.to_date <= Date.current && version.effective_date >= Date.current } || my_versions.last
      end
    end # CurrentVersionExtension
  end # Redmine
end # ScrumAlliance