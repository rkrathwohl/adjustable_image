module AdjustableImage
  class ImageAdjustments
    extend ActiveModel::Naming

    attr_accessor :crop_offset_x, :crop_offset_y,
                  # :crop_x, :crop_y, # synonymous to crop_offset_x, :crop_offset_y -> backport
                  :new_image_width, :new_image_height,
                  # :crop_height, :crop_width, # synonymous to new_image_height, new_image_width -> backport
                  :resize_width_to, :resize_height_to,
                  :background_color

    def initialize(opts = {})
      opts = (opts || {}).with_indifferent_access

      # crop_x is synonymous to crop_offset_x -> backport
      if opts[:crop_x].present?
        self.crop_offset_x = opts[:crop_x].to_i || 0
      else
        self.crop_offset_x = opts[:crop_offset_x].to_i || 0
      end

      # crop_y is synonymous to crop_offset_y -> backport
      if opts[:crop_y].present?
        self.crop_offset_y = opts[:crop_y].to_i || 0
      else
        self.crop_offset_y = opts[:crop_offset_y].to_i || 0
      end

      # crop_height is synonymous to new_image_height -> backport
      if opts[:crop_height].present?
        self.new_image_height = opts[:crop_height].to_i || 0
      else
        self.new_image_height = opts[:new_image_height].to_i || 0
      end

      # crop_width is synonymous to new_image_width -> backport
      if opts[:crop_width].present?
        self.new_image_width = opts[:crop_width].to_i || 0
      else
        self.new_image_width = opts[:new_image_width].to_i || 0
      end

      self.resize_width_to = opts[:resize_width_to].to_i || 0
      self.resize_height_to = opts[:resize_height_to].to_i || 0

      self.background_color = opts[:background_color] || 'FFFFFF'
    end

    def self.load(json)
      begin
        adjustment = self.new(JSON.parse(json))
      rescue => e
      end

      adjustment || self.new
    end

    def self.dump(adjustments)
      adjustments.to_json if adjustments
    end

    def styles_hash
      {
        crop_offset_x: crop_offset_x,
        crop_offset_y: crop_offset_y,
        new_image_width: new_image_width,
        new_image_height: new_image_height,
        resize_width_to: resize_width_to,
        resize_height_to: resize_height_to,
        background_color: background_color,
        geometry: geometry
      }
    end

    def geometry
      "#{new_image_width}x#{new_image_height}"
    end

    def has_adjustments?
      [ crop_offset_x, crop_offset_y, new_image_width, new_image_height, resize_width_to, resize_width_to ].any?{ |attr| attr != 0 }
    end
  end
end
