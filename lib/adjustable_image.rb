require "adjustable_image/version"

require 'adjustable_image/has_adjustable_image'
require 'adjustable_image/adjustable_styles'
require 'adjustable_image/image_adjustments'

require 'paperclip'

require 'adjustable_image/processors/background_color_processor'
require 'adjustable_image/processors/dynamic_extent_processor'
require 'adjustable_image/processors/dynamic_resize_processor'
require 'adjustable_image/processors/force_actual_format_processor'
require 'adjustable_image/processors/reset_base_style_processor'

require 'adjustable_image/railtie'

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
