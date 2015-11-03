module AdjustableImage
  module AdjustableStyles

    BASE_STYLE_PROCESSORS = [:dynamic_resize_processor, :dynamic_extent_processor]
    NON_BASE_STYLE_PROCESSORS = [:reset_base_style_processor]

    def dynamic_styles
      if self.new_record?
        style_for_new_instance
      elsif self.image_adjustments.has_adjustments?
        adjusted_styles
      else
        {}
      end
    end

    private

    def style_for_new_instance
      if self.image_style_options[:force_actual_format].present?
        { original: { processors: [:force_actual_format_processor] } }
      else
        {}
      end
    end

    def adjusted_styles
      adjusted_styles = ActiveSupport::OrderedHash.new

      if base_style_name.present?
        adjusted_styles[base_style_name] = adjusted_base_style_hash

        self.image_style_options[:static_styles].each_pair do |style_name, style_hash|
          next if style_name == base_style_name
          adjusted_styles[style_name] = adjusted_style_hash_for(style_name, style_hash)
        end
      end

      adjusted_styles
    end

    def adjusted_base_style_hash
      base_style = self.image_style_options[:static_styles][base_style_name] || {}

      all_processors = add_necessary_processors(base_style, BASE_STYLE_PROCESSORS)

      base_style.merge(self.image_adjustments.styles_hash).merge(processors: all_processors)
    end

    def adjusted_style_hash_for(style_name, style_hash)
      all_processors = add_necessary_processors(style_hash, NON_BASE_STYLE_PROCESSORS)

      style_hash.merge(processors: all_processors, base_style_name: base_style_name)
    end

    def add_necessary_processors(style_hash, adjusting_processors)
      if (style_processors = style_hash[:processors]).present?
        adjusting_processors + style_processors
      else
        adjusting_processors + default_processors
      end
    end

    def default_processors
      self.image_style_options[:default_processors] || []
    end

    def base_style_name
      self.image_style_options[:base_style_name]
    end

  end
end
