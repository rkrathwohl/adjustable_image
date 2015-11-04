module AdjustableImage
  class ImageAdjustments
    extend ActiveModel::Naming

    attr_accessor :crop_x, # crop offset for x
                  :crop_y, # crop offset for y
                  :crop_width, # new image width after crop
                  :crop_height, # new image height after crop
                  :image_width, # resize the image width to
                  :image_height, # resize the image height to
                  :background_color,
                  :has_adjustments

    def initialize(opts = {})
      opts = (opts || {}).with_indifferent_access
      self.has_adjustments = opts.present?

      self.crop_x = opts[:crop_x].to_i || 0
      self.crop_y = opts[:crop_y].to_i || 0

      self.crop_height = opts[:crop_height].to_i || 0
      self.crop_width = opts[:crop_width].to_i || 0

      self.image_width = (opts[:image_width] || opts[:resize_width_to]).to_i || 0
      self.image_height = (opts[:image_height] || opts[:resize_height_to]).to_i || 0

      if opts[:background_color].present?
        self.background_color = opts[:background_color] =~ /#/ ? opts[:background_color] : "##{opts[:background_color]}"
      end

       self.background_color ||= '#FFFFFF'
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
        image_width: image_width,
        image_height: image_height,
        background_color: background_color,
        geometry: geometry
      }
    end

    def geometry
      "#{crop_width}x#{crop_height}"
    end

    def has_adjustments?
      [ crop_x, crop_y, crop_width, crop_height, image_width, image_height ].any?{ |attr| attr != 0 }
    end
  end
end
