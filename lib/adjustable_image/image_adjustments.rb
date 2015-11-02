module AdjustableImage
  class ImageAdjustments
    extend ActiveModel::Naming

    attr_accessor :crop_x, # crop offset for x
                  :crop_y, # crop offset for y
                  :crop_width, # new image width after crop
                  :crop_height, # new image height after crop
                  :resize_width_to, :resize_height_to,
                  :background_color

    def initialize(opts = {})
      opts = (opts || {}).with_indifferent_access

      self.crop_x = opts[:crop_x].to_i || 0
      self.crop_y = opts[:crop_y].to_i || 0

      self.crop_height = opts[:crop_height].to_i || 0
      self.crop_width = opts[:crop_width].to_i || 0

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
        crop_x: crop_x,
        crop_y: crop_y,
        crop_width: crop_width,
        crop_height: crop_height,
        resize_width_to: resize_width_to,
        resize_height_to: resize_height_to,
        background_color: background_color,
        geometry: geometry
      }
    end

    def geometry
      "#{crop_width}x#{crop_height}"
    end

    def has_adjustments?
      [ crop_x, crop_y, crop_width, crop_height, resize_width_to, resize_width_to ].any?{ |attr| attr != 0 }
    end
  end
end
