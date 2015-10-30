module Paperclip
  class DynamicExtentProcessor < Thumbnail
    def transformation_command
      # if it needs extra space on either side or needs to be cropped (this does cropping too)

      new_image_width_height = "#{ @options[:new_image_width] }x#{ @options[:new_image_height] }"
      crop_offset_x = "#{'+' if @options[:crop_offset_x] >= 0 }#{ @options[:crop_offset_x] }"
      crop_offset_y = "#{'+' if @options[:crop_offset_y] >= 0 }#{ @options[:crop_offset_y] }"

      [
        "-extent #{ new_image_width_height }#{ crop_offset_x }#{ crop_offset_y }",
        "+repage"
      ]
    end
  end
end
