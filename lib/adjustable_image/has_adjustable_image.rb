module AdjustableImage
  class HasAdjustableImage
    def self.apply_to(klass, image_name, options)
      new(klass, image_name, options).apply
    end

    def initialize(klass, image_name, options)
      @klass = klass
      @image_name = image_name
      @options = options.dup
    end

    def apply
      include_instance_style_methods

      serialize_image_adjustments_attr
      define_image_adjustments_setter

      define_image_style_options_class_attr
      define_image_style_options_getter

      set_image_style_options

      override_user_styles_with_dynamic_injection

      add_paperclip_attached_file
    end


    def include_instance_style_methods
      @klass.send(:include, AdjustableStyles)
    end

    def serialize_image_adjustments_attr
      @klass.send(:serialize, :image_adjustments, ImageAdjustments)
    end

    # add setter to parse image adjustments coming in as a hash
    def define_image_adjustments_setter
      @klass.send(:define_method, :image_adjustments=) do |hash|
        self[:image_adjustments] = ImageAdjustments.new(hash)
      end
    end

    def define_image_style_options_class_attr
      @klass.send(:class_attribute, :image_style_options)
    end

    # Helper method to prevent @@ usage
    def define_image_style_options_getter
      @klass.send(:define_method, :image_style_options) do
        self.image_style_options
      end
    end

    def set_image_style_options
      image_options = @options.slice(:force_actual_format, :base_style_name).
        merge(static_styles: @options[:styles] || {}, default_processors: @options[:processors])

      @klass.send(:image_style_options=, image_options)
    end

    def override_user_styles_with_dynamic_injection
      @options[:styles] = lambda{ |attachment| attachment.instance.dynamic_styles }
    end

    def add_paperclip_attached_file
      @klass.send(:has_attached_file, @image_name, @options)
    end

  end
end


# For more than 1 file attached :
#
# Keep other image styles around
# if image_style_options.nil?
#   self.image_style_options = {}
# else]
#   self.image_style_options = self.image_options.dup
# end

# Pull out user styles
# image_style_options[name] = options.slice(:styles, :force_actual_format, :base_style_name, :processors)

