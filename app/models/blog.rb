class Blog < ApplicationRecord
  has_one_attached :image, dependent: :destroy
end
