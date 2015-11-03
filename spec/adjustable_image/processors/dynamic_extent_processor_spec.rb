require 'spec_helper'

describe Paperclip::DynamicExtentProcessor do
  let(:mock_file) { double('mock file', path: 'mock_file.png') }
  let(:processor) { described_class.new(mock_file, options) }

  let(:base_options) { { geometry: '15x15', file_geometry_parser: MockGeometryParser } }

  describe '#transformation_command' do
    describe 'commands' do
      let(:options) do
        base_options.merge(crop_width: 30, crop_height: 45,
                           crop_x: 2, crop_y: -4)
      end

      let(:commands) { processor.transformation_command }

      it 'returns 3 commands' do
        expect(commands.size).to eq(3)
      end

      it 'adds a background color' do
        expect(commands.first).to eq("-background '#FFFFFF'")
      end

      it 'adds a crop width by crop height extent command' do
        expect(commands.second).to eq('-extent 30x45+2-4')
      end

      it 'adds a repage command' do
        expect(commands.last).to eq('+repage')
      end
    end

    describe 'background color' do
      let(:extent_options) { { crop_width: 10, crop_height: 10, crop_x: 0, crop_y: 0 } }
      context 'when the background color option is set' do

        let(:options) { base_options.merge(extent_options.merge(background_color: '718FFF')) }

        it 'returns -background color' do
          expect(processor.transformation_command.first).to eq("-background '#718FFF'")
        end
      end

      context 'when the background color option is not set' do
        let(:options) { base_options.merge(extent_options) }

        it 'returns -background white' do
          expect(processor.transformation_command.first).to eq("-background '#FFFFFF'")
        end
      end
    end

    describe 'crop offset x' do
      context 'when the crop offset x is positive' do
        let(:options) do
          base_options.merge(crop_width: 50, crop_height: 50,
                             crop_x: 130, crop_y: 0)
        end

        it 'adds a plus crop x to the extent command' do
          expect(processor.transformation_command.second).to eq('-extent 50x50+130+0')
        end
      end

      context 'when the crop offset x is 0' do
        let(:options) do
          base_options.merge(crop_width: 50, crop_height: 50,
                             crop_x: 0, crop_y: 0)
        end

        it 'adds a plus crop x to the extent command' do
          expect(processor.transformation_command.second).to eq('-extent 50x50+0+0')
        end
      end

      context 'when the crop offset x is negative' do
        let(:options) do
          base_options.merge(crop_width: 50, crop_height: 50,
                             crop_x: -30, crop_y: 0)
        end

        it 'adds the crop offset x to the extent command' do
          expect(processor.transformation_command.second).to eq('-extent 50x50-30+0')
        end
      end
    end

    describe 'crop offset y' do
      context 'when the crop offset y is positive' do
        let(:options) do
          base_options.merge(crop_width: 100, crop_height: 100,
                             crop_x: 0, crop_y: 55)
        end

        it 'adds a plus crop y to the extent command' do
          expect(processor.transformation_command.second).to eq('-extent 100x100+0+55')
        end
      end

      context 'when the crop offset y is 0' do
        let(:options) do
          base_options.merge(crop_width: 100, crop_height: 100,
                             crop_x: 0, crop_y: 0)
        end

        it 'adds a plus crop y to the extent command' do
          expect(processor.transformation_command.second).to eq('-extent 100x100+0+0')
        end
      end

      context 'when the crop offset y is negative' do
        let(:options) do
          base_options.merge(crop_width: 100, crop_height: 100,
                             crop_x: 0, crop_y: -74)
        end

        it 'adds the crop offset y to the extent command' do
          expect(processor.transformation_command.second).to eq('-extent 100x100+0-74')
        end
      end
    end
  end
end
