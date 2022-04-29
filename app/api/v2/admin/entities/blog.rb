# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Blog < API::V2::Entities::Blog
          expose(
            :text,
            documentation: {
              type: String,
              desc: 'Text'
            }
          )

          expose(
            :image,
            documentation: {
              type: String,
              desc: 'Image'
            }
          )
        end
      end
    end
  end
end
