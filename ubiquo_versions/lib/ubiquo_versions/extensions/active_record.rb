require 'paper_trail'

module UbiquoVersions
  module Extensions
    module ActiveRecord

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Flag that states if a class is versionable
        attr_accessor :is_versionable

        # Add some sugar when asking for this flag
        alias_method :is_versionable?, :is_versionable

        # Class method for ActiveRecord that states that a model is versionable
        #
        # EXAMPLE:
        #
        #   versionable :max_amount => 5
        #
        # possible options:
        #   :max_amount => number of versions that will be stored as a maximum.
        #                  When this limit is reached, the system starts
        #                  deleting older versions as required
        #
        def versionable(options = {})
          @is_versionable = true
          @versionable_options = options

          has_paper_trail options

          define_method('restore') do |old_version_id|
            PaperTrail::Version.find(old_version_id).reify.save
          end

          # delete the older versions if there are too many versions (as defined by max_amount)
          ensure_max_amount_of_versions = lambda do
            if (max_amount = options[:max_amount]) && self.item
              versions_by_number = self.item.versions
              (versions_by_number.size - max_amount).times do |i|
                versions_by_number[i].destroy
              end
            end
          end

          PaperTrail::Version.after_create ensure_max_amount_of_versions
        end

        # Used to execute a block that would create a version without this effect
        def without_versionable
          was_enabled = PaperTrail.enabled?
          PaperTrail.enabled = false
          begin
            yield
          ensure
            PaperTrail.enabled = was_enabled
          end
        end
      end
    end
  end
end
