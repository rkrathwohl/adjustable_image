require 'spec_helper'

describe AdjustableImage::HasAdjustableImage do
  describe '.apply_to' do
    let(:image_name) { :pretty_image }

    let(:options) do
      {
        base_style_name: :print,
        force_actual_format: true,
        styles: {
          print: { geometry: '150x150', processors: [:quality_processor] },
          web: { geometry: '100x100', processors: [:minaturize] },
          billboard: { geometry: '1000x1000', processors: [:blow_up] }
        },
        processors: [:default_processor]
      }
    end

    let(:fake_class) do
      double('class',
             has_attached_file: nil,
             define_method: nil,
             serialize: nil,
             class_attribute: nil,
             include: nil,
             'image_style_options=' => nil)
    end

    before { described_class.apply_to(fake_class, image_name, options) }

    it 'adds the styles_for method to the instance methods' do
      expect(fake_class).to have_received(:include).with(AdjustableImage::AdjustableStyles)
    end

    it 'adds serialization to the image adjustments' do
      expect(fake_class).to have_received(:serialize).with(:image_adjustments, AdjustableImage::ImageAdjustments)
    end

    it 'defines an image_adjustments setter' do
      expect(fake_class).to have_received(:define_method).with(:image_adjustments=)
    end

    it 'defines the image_style_options getter helper method' do
      expect(fake_class).to have_received(:define_method).with(:image_style_options)
    end

    it 'sets the image style options hash to the options input' do
      expect(fake_class).to have_received(:image_style_options=).
        with(options.slice(:force_actual_format, :base_style_name).
        merge(static_styles: options[:styles], default_processors: options[:processors]))
    end

    it 'calls to paperclip has attached file' do
      paperclip_options = options.slice(:force_actual_format, :base_style_name, :processors)
      paperclip_options.merge!(styles: kind_of(Proc))

      expect(fake_class).to have_received(:has_attached_file).with(image_name, paperclip_options)
    end
  end
end
