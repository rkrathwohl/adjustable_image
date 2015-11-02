module Paperclip
  class DynamicExtentProcessor < Thumbnail
    def transformation_command
      # if it needs extra space on either side or needs to be cropped (this does cropping too)

      crop_width_height = "#{ @options[:crop_width] }x#{ @options[:crop_height] }"
      crop_x = "#{'+' if @options[:crop_x] >= 0 }#{ @options[:crop_x] }"
      crop_y = "#{'+' if @options[:crop_y] >= 0 }#{ @options[:crop_y] }"

      [
        "-extent #{ crop_width_height }#{ crop_x }#{ crop_y }",
        "+repage"
      ]
    end
  end
end
