require 'spec_helper'

describe Paperclip::DynamicResizeProcessor do
  let(:mock_file) { double('mock file', path: 'mock_file.png') }
  let(:processor) { described_class.new(mock_file, options) }

  let(:options) do
    { geometry: '5x5', file_geometry_parser: MockGeometryParser,
      resize_width_to: 144, resize_height_to: 224}
  end

  describe '#transformation_command' do
    let(:commands) { processor.transformation_command }

    it 'returns 2 commands' do
      expect(commands.size).to eq(2)
    end

    it 'returns a resize command' do
      expect(commands.first).to eq("-resize '144x224'")
    end

    it 'returns a repage command' do
      expect(commands.last).to eq('+repage')
    end
  end
end
