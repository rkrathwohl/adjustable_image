module Paperclip
  class DynamicResizeProcessor < Thumbnail
    def transformation_command
      [
        "-resize '#{@options[:image_width]}x#{@options[:image_height]}'",
        "+repage"
      ]
    end
  end
end
