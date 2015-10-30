module Paperclip
  class BackgroundColorProcessor < Thumbnail
    def transformation_command
      [ "-background '##{ @options[:background_color] || 'FFFFFF' }'" ]
    end
  end
end
