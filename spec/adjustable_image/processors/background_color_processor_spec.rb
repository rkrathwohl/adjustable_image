require 'spec_helper'

describe Paperclip::BackgroundColorProcessor do
  let(:mock_file) { double('mock file', path: 'mock_file.png') }
  let(:processor) { described_class.new(mock_file, options) }

  let(:base_options) { { geometry: '5x5', file_geometry_parser: MockGeoParser } }

  describe '#transformation_command' do
    let(:options) { base_options.merge(background_color: '718FFF') }

    context 'when the background color option is set' do
      it 'returns -background color' do
        expect(processor.transformation_command).to eq(["-background '#718FFF'"])
      end
    end

    context 'when the background color option is not set' do
      let(:options) { base_options }

      it 'returns -background white' do
        expect(processor.transformation_command).to eq(["-background '#FFFFFF'"])
      end
    end
  end
end
