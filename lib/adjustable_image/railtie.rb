require 'adjustable_image'

module AdjustableImage
  require 'rails'

  class Railtie < Rails::Railtie
    initializer 'adjustable_image.insert_into_active_record' do |app|
      ActiveSupport.on_load :active_record do
        AdjustableImage::Railtie.insert
      end
    end
  end

  class Railtie
    def self.insert
      AdjustableImage.options[:logger] = Rails.logger

      if defined?(ActiveRecord)
        AdjustableImage.options[:logger] = ActiveRecord::Base.logger
        ActiveRecord::Base.extend(AdjustableImage::ClassMethods)
      end
    end
  end
end
