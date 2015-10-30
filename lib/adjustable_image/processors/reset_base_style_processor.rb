module Paperclip
  class ResetBaseStyleProcessor < Thumbnail
    def initialize(_, options = {}, attachment = nil)
      options[:auto_orient] = false

      super(attachment.queued_for_write[options[:base_style_name]], options, attachment)
    end
  end
end
