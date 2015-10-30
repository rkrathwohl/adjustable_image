module Paperclip
  class DynamicResizeProcessor < Thumbnail
    def transformation_command
      [
        "-resize '#{@options[:resize_width_to]}x#{@options[:resize_height_to]}'",
        "+repage"
      ]
    end
  end
end
