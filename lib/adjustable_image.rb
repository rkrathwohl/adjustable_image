require "adjustable_image/version"

require 'adjustable_image/has_adjustable_image'
require 'adjustable_image/adjustable_styles'

require 'paperclip'

module AdjustableImage
  def self.options
    @options ||= {}
  end

  # Assume it can only have 1 attachment for now
  module ClassMethods
    def has_adjustable_image(image_name, options)
      HasAdjustableImage.apply_to(self, image_name, options)
    end
  end
end
