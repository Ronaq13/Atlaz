# frozen_string_literal: true

module RuboCop
  module Cop
    module Atlaz
      # Flags obvious ActiveRecord-style reads/writes when the chain starts
      # from a model class constant (e.g. Supplier.find_by, Hotel.where).
      # Normalizers should receive preloaded data instead (batch boundary).
      class NoQueriesInNormalizers < ::RuboCop::Cop::Base
        MSG = "Avoid database access from normalizers: preload and pass data in (e.g. a context object), " \
              "don't query from app/lib normalizers."

        # Relation / model entry points we care about; excludes Hash#count-style names where receiver is not AR.
        RESTRICT_ON_SEND = %i[
          all average calculate count create create! delete delete_all destroy destroy_all distinct eager_load exists?
          find find_by find_by! find_each find_in_batches find_sole_by first from group group_having having includes
          insert last lock many? maximum merge minimum none? offset one? or order pick pluck preload readonly rewhere
          sole take sum unscope update update_all upsert upsert_all where
        ].freeze

        def on_send(node)
          return unless normalizer_source_file?
          return unless RESTRICT_ON_SEND.include?(node.method_name)
          return unless active_record_class_chain?(node)

          add_offense(node, message: MSG)
        end

        private

        def normalizer_source_file?
          path = processed_source.file_path
          return false if path.nil?

          expanded = File.expand_path(path)
          m = %r{/app/lib/(.+)}.match(expanded.tr("\\", "/"))
          return false unless m

          rel = m[1]
          rel.include?("normalizers/") || rel.end_with?("_normalizer.rb")
        end

        def active_record_class_chain?(node)
          receiver = node.receiver
          while receiver&.send_type?
            receiver = receiver.receiver
          end
          receiver&.const_type?
        end
      end
    end
  end
end
