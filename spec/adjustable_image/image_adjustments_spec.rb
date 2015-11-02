require 'spec_helper'

describe AdjustableImage::ImageAdjustments do
  describe '.load' do
    let(:adjustments) { described_class.load(json_hsh) }

    context 'when the json is invalid' do
      let(:json_hsh) { "Bad JSON!" }

      it 'returns a new ImageAdjustments model with default attributes' do
        expect(adjustments.crop_offset_x).to eq(0)
        expect(adjustments.crop_offset_y).to eq(0)
        expect(adjustments.new_image_width).to eq(0)
        expect(adjustments.new_image_height).to eq(0)
        expect(adjustments.resize_width_to).to eq(0)
        expect(adjustments.resize_height_to).to eq(0)
        expect(adjustments.background_color).to eq('FFFFFF')
      end
    end

    context 'when the json is an empty hash string' do
      let(:json_hsh) { "{}" }

      it 'returns a new ImageAdjustments model with default attributes' do
        expect(adjustments.crop_offset_x).to eq(0)
        expect(adjustments.crop_offset_y).to eq(0)
        expect(adjustments.new_image_width).to eq(0)
        expect(adjustments.new_image_height).to eq(0)
        expect(adjustments.resize_width_to).to eq(0)
        expect(adjustments.resize_height_to).to eq(0)
        expect(adjustments.background_color).to eq('FFFFFF')
      end
    end

    context 'when the json has non-ints for values' do
      let(:json_hsh) do
        "{\"crop_offset_x\":-3,\"crop_offset_y\":20,\"new_image_width\":\"57\",\"new_image_height\":\"height??\"," +
          "\"resize_width_to\":300,\"resize_height_to\":400,\"background_color\":\"infinity\"}"
      end

      it 'sets the appropriate values to 0' do
        expect(adjustments.crop_offset_x).to eq(-3)
        expect(adjustments.crop_offset_y).to eq(20)
        expect(adjustments.new_image_width).to eq(57)
        expect(adjustments.new_image_height).to eq(0)
        expect(adjustments.resize_width_to).to eq(300)
        expect(adjustments.resize_height_to).to eq(400)
        expect(adjustments.background_color).to eq('infinity')
      end
    end

    context 'when the json is a hash with the appropriate key/values' do
      let(:json_hsh) do
        "{\"crop_offset_x\":15,\"crop_offset_y\":20,\"new_image_width\":100,\"new_image_height\":120," +
          "\"resize_width_to\":300,\"resize_height_to\":400,\"background_color\":\"F71322\"}"
      end

      it 'returns a new ImageAdjustments model with filled attributes' do
        expect(adjustments.crop_offset_x).to eq(15)
        expect(adjustments.crop_offset_y).to eq(20)
        expect(adjustments.new_image_width).to eq(100)
        expect(adjustments.new_image_height).to eq(120)
        expect(adjustments.resize_width_to).to eq(300)
        expect(adjustments.resize_height_to).to eq(400)
        expect(adjustments.background_color).to eq('F71322')
      end
    end
  end

  describe '.dump' do
    context 'with a nil adjustments' do
      it 'returns nil' do
        expect(described_class.dump(nil)).to eq(nil)
      end
    end

    context 'with a non-nil adjustments' do
      it 'returns the to_json version of the adjustments' do
        expect(described_class.dump({ crop_offset_x: 5 })).to eq("{\"crop_offset_x\":5}")
      end
    end
  end

  describe '#styles_hash' do
    let(:options) do
      { crop_offset_x: 14, crop_offset_y: 90,
        new_image_width: 144, new_image_height: 322,
        resize_width_to: 600, resize_height_to: 800,
        background_color: 'CCC'
      }
    end

    it 'returns a hash of the attributes' do
      expect(described_class.new(options).styles_hash).to eq({ crop_offset_x: 14, crop_offset_y: 90,
                                                               new_image_width: 144, new_image_height: 322,
                                                               resize_width_to: 600, resize_height_to: 800,
                                                               background_color: 'CCC', geometry: '144x322'
                                                             })
    end
  end

  describe '#geometry' do
    let(:options) { { new_image_width: 155, new_image_height: 140 } }

    it 'returns the new_image_width by the new_image_height' do
      expect(described_class.new(options).geometry).to eq('155x140')
    end
  end

  describe '#has_adjustments?' do
    context 'when all attrs are 0 (not including background color)' do
      it 'returns false' do
        expect(described_class.new.has_adjustments?).to eq(false)
      end
    end

    context 'when not all attrs are 0 (not including background color)' do
      let(:options) { { crop_offset_x: 2 } }

      it 'returns true' do
        expect(described_class.new(options).has_adjustments?).to eq(true)
      end
    end
  end

  describe 'backporting values' do
    let(:options) do
      { crop_x: 70, crop_y: 60,
        crop_width: 16, crop_height: 32,
        resize_width_to: 600, resize_height_to: 800,
        background_color: 'DDD'
      }
    end

    describe 'crop_y and crop_x/crop_height and crop_width' do
      it 'saves the values into new_image_height and new_image_width/crop_offset_x and crop_offset_y' do
        expect(JSON.parse(described_class.dump(described_class.new(options)))).to eq({
                                                                                       'crop_offset_x' => 70, 'crop_offset_y' => 60,
                                                                                       'new_image_width' => 16, 'new_image_height' => 32,
                                                                                       'resize_width_to' => 600, 'resize_height_to' => 800,
                                                                                       'background_color' => 'DDD'
                                                                                     })
      end
    end
  end
end
