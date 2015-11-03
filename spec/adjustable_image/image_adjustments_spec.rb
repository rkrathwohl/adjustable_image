require 'spec_helper'

describe AdjustableImage::ImageAdjustments do
  describe '.load' do
    let(:adjustments) { described_class.load(json_hsh) }

    context 'when the json is invalid' do
      let(:json_hsh) { "Bad JSON!" }

      it 'returns a new ImageAdjustments model with default attributes' do
        expect(adjustments.crop_x).to eq(0)
        expect(adjustments.crop_y).to eq(0)
        expect(adjustments.crop_width).to eq(0)
        expect(adjustments.crop_height).to eq(0)
        expect(adjustments.image_width).to eq(0)
        expect(adjustments.image_height).to eq(0)
        expect(adjustments.background_color).to eq('#FFFFFF')
      end
    end

    context 'when the json is an empty hash string' do
      let(:json_hsh) { "{}" }

      it 'returns a new ImageAdjustments model with default attributes' do
        expect(adjustments.crop_x).to eq(0)
        expect(adjustments.crop_y).to eq(0)
        expect(adjustments.crop_width).to eq(0)
        expect(adjustments.crop_height).to eq(0)
        expect(adjustments.image_width).to eq(0)
        expect(adjustments.image_height).to eq(0)
        expect(adjustments.background_color).to eq('#FFFFFF')
      end
    end

    context 'when the json has non-ints for values' do
      let(:json_hsh) do
        "{\"crop_x\":-3,\"crop_y\":20,\"crop_width\":\"57\",\"crop_height\":\"height??\"," +
          "\"image_width\":300,\"image_height\":400,\"background_color\":\"infinity\"}"
      end

      it 'sets the appropriate values to 0' do
        expect(adjustments.crop_x).to eq(-3)
        expect(adjustments.crop_y).to eq(20)
        expect(adjustments.crop_width).to eq(57)
        expect(adjustments.crop_height).to eq(0)
        expect(adjustments.image_width).to eq(300)
        expect(adjustments.image_height).to eq(400)
        expect(adjustments.background_color).to eq('#infinity')
      end
    end

    context 'when the json is a hash with the appropriate key/values' do
      let(:json_hsh) do
        "{\"crop_x\":15,\"crop_y\":20,\"crop_width\":100,\"crop_height\":120," +
          "\"image_width\":300,\"image_height\":400,\"background_color\":\"#F71322\"}"
      end

      it 'returns a new ImageAdjustments model with filled attributes' do
        expect(adjustments.crop_x).to eq(15)
        expect(adjustments.crop_y).to eq(20)
        expect(adjustments.crop_width).to eq(100)
        expect(adjustments.crop_height).to eq(120)
        expect(adjustments.image_width).to eq(300)
        expect(adjustments.image_height).to eq(400)
        expect(adjustments.background_color).to eq('#F71322')
      end
    end


    context 'when the json is a hash with the appropriate key/values except the background color has no hash mark' do
      let(:json_hsh) do
        "{\"crop_x\":20,\"crop_y\":20,\"crop_width\":10,\"crop_height\":120," +
          "\"image_width\":100,\"image_height\":100,\"background_color\":\"871322\"}"
      end

      it 'returns a new ImageAdjustments model with filled attributes' do
        expect(adjustments.crop_x).to eq(20)
        expect(adjustments.crop_y).to eq(20)
        expect(adjustments.crop_width).to eq(10)
        expect(adjustments.crop_height).to eq(120)
        expect(adjustments.image_width).to eq(100)
        expect(adjustments.image_height).to eq(100)
        expect(adjustments.background_color).to eq('#871322')
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
        expect(described_class.dump({ crop_x: 5 })).to eq("{\"crop_x\":5}")
      end
    end
  end

  describe '#styles_hash' do
    let(:options) do
      { crop_x: 14, crop_y: 90,
        crop_width: 144, crop_height: 322,
        image_width: 600, image_height: 800,
        background_color: 'CCC'
      }
    end

    it 'returns a hash of the attributes' do
      expect(described_class.new(options).styles_hash).to eq({ crop_x: 14, crop_y: 90,
                                                               crop_width: 144, crop_height: 322,
                                                               image_width: 600, image_height: 800,
                                                               background_color: '#CCC', geometry: '144x322'
                                                             })
    end
  end

  describe '#geometry' do
    let(:options) { { crop_width: 155, crop_height: 140 } }

    it 'returns the crop_width by the crop_height' do
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
      let(:options) { { crop_x: 2 } }

      it 'returns true' do
        expect(described_class.new(options).has_adjustments?).to eq(true)
      end
    end
  end
end
