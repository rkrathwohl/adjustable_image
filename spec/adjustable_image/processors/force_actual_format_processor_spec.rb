require 'spec_helper'

describe Paperclip::ForceActualFormatProcessor do
  let(:processor) { described_class.new(mock_file, {}, mock_attachment) }

  describe '#make' do
    let(:mock_attachment) { nil }

    context 'when the actual format is not present' do
      let(:mock_file) { double('source file', path: '/tmp/image.pretend_this_image_has_no_format') }

      before do
        allow(processor).to receive(:identify).with("-format %m :file", { file: "#{mock_file.path}[0]" }) { nil }
        allow(processor).to receive(:identify).with("-format %e :file", { file: "#{mock_file.path}[0]" }) { 'extension' }
      end

      it 'returns the original file' do
        expect(processor.make).to eq(mock_file)
      end
    end

    context 'when the actual format is present' do
      context 'when the extension is not present' do
        let(:mock_file) { double('source file', path: '/tmp/image.pretend_this_extension_doesnt_exist') }

        before do
          allow(processor).to receive(:identify).with("-format %m :file", { file: "#{mock_file.path}[0]" }) { 'format' }
          allow(processor).to receive(:identify).with("-format %e :file", { file: "#{mock_file.path}[0]" }) { nil }
        end

        it 'returns the original file' do
          expect(processor.make).to eq(mock_file)
        end
      end

      context 'when the extension is present' do
        context 'when the actual format and the extension are the same' do
          let(:mock_file) { double('source file', path: '/tmp/image.png') }

          before do
            allow(processor).to receive(:identify).with("-format %m :file", { file: "#{mock_file.path}[0]" }) { 'png' }
            allow(processor).to receive(:identify).with("-format %e :file", { file: "#{mock_file.path}[0]" }) { 'png' }
          end

          it 'returns the original file' do
            expect(processor.make).to eq(mock_file)
          end
        end


        context 'when the actual format and the extension are different' do
          let(:mock_file) { double('source file', path: '/tmp/image.jpg') }

          before do
            allow(processor).to receive(:identify).with("-format %m :file", { file: "#{mock_file.path}[0]" }) { 'png' }
            allow(processor).to receive(:identify).with("-format %e :file", { file: "#{mock_file.path}[0]" }) { 'jpg' }
          end

          let(:tmp_file) { double('destination file', binmode: nil, path: '/tmp/image.png', size: 1024) }

          it 'creates a new tmp file' do
            allow(processor).to receive(:convert)

            expect(Tempfile).to receive(:new).with(['image.', '.png']).and_return(tmp_file)
            expect(tmp_file).to receive(:binmode)

            processor.make
          end

          it 'calls to convert the source file to the destination file' do
            allow(Tempfile).to receive(:new).and_return(tmp_file)

            expect(processor).to receive(:convert).with("\"#{mock_file.path}[0]\" \"#{tmp_file.path}\"",
                                                        source: "#{mock_file.path}[0]", dest: tmp_file.path)
            processor.make
          end

          it 'returns a new destination file' do
            allow(Tempfile).to receive(:new).and_return(tmp_file)
            allow(processor).to receive(:convert)

            expect(processor.make).to eq(tmp_file)
          end

          context 'when the attachment is present' do
            let(:mock_attachment) { double('mock attachment', original_filename: 'image.jpg') }

            before do
              allow(Tempfile).to receive(:new).and_return(tmp_file)
              allow(processor).to receive(:convert)

              allow(mock_attachment).to receive(:instance_write).with(:file_name, anything)
              allow(mock_attachment).to receive(:instance_write).with(:content_type, anything)
              allow(mock_attachment).to receive(:instance_write).with(:file_size, anything)
            end

            it 'updates the attachment file_name' do
              expect(mock_attachment).to receive(:instance_write).with(:file_name, 'image.png')
              processor.make
            end

            it 'updates the attachment content type' do
              expect(mock_attachment).to receive(:instance_write).with(:content_type, 'image/png')
              processor.make
            end

            it 'updates the attachment filesize' do
              expect(mock_attachment).to receive(:instance_write).with(:file_size, 1024)
              processor.make
            end
          end
        end
      end
    end
  end
end
