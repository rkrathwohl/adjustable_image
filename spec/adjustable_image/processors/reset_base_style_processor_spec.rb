require 'spec_helper'

describe Paperclip::ResetBaseStyleProcessor do
  let(:original_file) { double('original image') }
  let(:mock_attachment) { double('mock attachment', queued_for_write: queued_for_write_hsh) }

  describe '.new' do
    context 'when the base style name has not been specified' do
      let(:queued_for_write_hsh) { { file_name: 'pretend this is a file thing' } }

      it 'raises an exception' do
        expect do
          described_class.new(original_file, { geometry: '5x5' }, mock_attachment)
        end.to raise_error(Paperclip::Errors::NotIdentifiedByImageMagickError)
      end
    end

    context 'when the base style name has been specified' do
      context 'when the base style image file has not been queued for write' do
        let(:queued_for_write_hsh) { { not_base_style_name: 'pretend this is a file thing'} }

        it 'raises an exception' do
          expect do
            described_class.new(original_file, { geometry: '5x5', base_style_name: 'base_style_name' }, mock_attachment)
          end.to raise_error(Paperclip::Errors::NotIdentifiedByImageMagickError)
        end
      end

      context 'when the base style image file has been queued for write' do
        let(:mock_base_file) { double('mock base file', path: '/tmp/image.gif') }
        let(:queued_for_write_hsh) { { 'base_style_name' => mock_base_file } }

        it 'passes that image file to the thumbnail processor' do
          expect(Paperclip::Geometry).to receive(:from_file).with(mock_base_file).and_return(Paperclip::Geometry.new)

          processor = described_class.new(original_file, { geometry: '5x5', base_style_name: 'base_style_name' }, mock_attachment)

          expect(processor).to be_a_kind_of(Paperclip::Thumbnail)
        end
      end
    end
  end
end
