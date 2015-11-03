require 'spec_helper'

describe AdjustableImage::AdjustableStyles do

  describe '#reprocess_thumbnails' do
    let(:image) { double('image') }
    let(:subject) { StylesContainer.new({}, nil, false, image) }

    it 'reassigns the image to itself (force thumbnail reprocessing)' do
      expect(subject).to receive(:image=).with(image)
      subject.reprocess_thumbnails
    end
  end

  describe '#dynamic_styles' do
    context 'when the attached-to object is a new record' do
      let(:subject) { StylesContainer.new(image_style_options, nil, true) }

      context 'when the force_actual_format option is true' do
        let(:image_style_options) { { force_actual_format: true } }

        it 'returns a hash with a processor for the original style' do
          expect(subject.dynamic_styles).to eq({ original: { processors: [:force_actual_format_processor] } })
        end
      end

      context 'when the force_actual_format option is false' do
        let(:image_style_options) { {} }

        it 'returns an empty hash' do
          expect(subject.dynamic_styles).to eq({})
        end
      end
    end

    context 'when the attached-to object is not a new record' do
      context 'with no existing image adjustments' do
        let(:subject) { StylesContainer.new({}, nil, false) }

        it 'returns an empty hash' do
          expect(subject.dynamic_styles).to eq({})
        end
      end

      context 'with existing image adjustments' do
        let(:image_adjustments) do
          AdjustableImage::ImageAdjustments.new(crop_x: 1, crop_y: 1,
                                                crop_width: 1, crop_height: 1,
                                                image_width: 1, image_height: 1)
        end

        context 'with no base style name' do
          let(:subject) { StylesContainer.new({}, image_adjustments, false) }

          it 'returns an empty hash' do
            expect(subject.dynamic_styles).to eq({})
          end
        end

        context 'with a base style name' do
          let(:adjusted_styles) { subject.dynamic_styles }
          let(:subject) { StylesContainer.new(image_style_options, image_adjustments, false) }

          let(:base_style_name) { :teapot_size }

          describe 'base style' do
            describe 'processors' do
              let(:base_image_processors) { adjusted_styles[base_style_name][:processors] }

              context 'with default processors' do
                context 'with no style specific processors' do
                  let(:image_style_options) do
                    { base_style_name: base_style_name,
                      static_styles: { teacup_size: { geometry: '2x2' } },
                      default_processors: [:make_smaller] }
                  end

                  it 'adds the base style processors before the options processors' do
                    expect(base_image_processors).to eq(AdjustableImage::AdjustableStyles::BASE_STYLE_PROCESSORS + [:make_smaller])
                  end
                end

                context 'with style specific processors' do
                  let(:image_style_options) do
                    { base_style_name: base_style_name,
                      static_styles: { base_style_name => { processors: [:make_teapot_size] },
                                       teacup_size: { geometry: '2x2' } },
                      default_processors: [:make_smaller] }
                  end

                  it 'adds the base style processors before the style specific processors' do
                    expect(base_image_processors).to eq(AdjustableImage::AdjustableStyles::BASE_STYLE_PROCESSORS + [:make_teapot_size])
                  end
                end
              end

              context 'with no default processors' do
                context 'with style specific processors' do
                  let(:image_style_options) do
                    { base_style_name: base_style_name,
                      static_styles: { base_style_name => { processors: [:make_kettle_size] },
                                       teacup_size: { geometry: '2x2' } } }
                  end

                  it 'adds the base style processors before the style specific processors' do
                    expect(base_image_processors).to eq(AdjustableImage::AdjustableStyles::BASE_STYLE_PROCESSORS + [:make_kettle_size])
                  end
                end
              end

              context 'with no processors' do
                let(:image_style_options) do
                  { base_style_name: base_style_name,
                    static_styles: { teacup_size: { geometry: '2x2' } } }
                end

                it 'adds the base style processors' do
                  expect(base_image_processors).to eq(AdjustableImage::AdjustableStyles::BASE_STYLE_PROCESSORS)
                end
              end
            end

            describe 'styles' do
              let(:image_style_options) do
                { base_style_name: base_style_name,
                  static_styles: { base_style_name => { geometry: '120x120' },
                                   teacup_size: { geometry: '2x2' } } }
              end

              let(:base_image_styles) { adjusted_styles[base_style_name] }

              it 'adds the styles from the image adjustment' do
                base_image_styles.delete(:processors)

                expect(base_image_styles).to eq({ crop_x: 1, crop_y: 1,
                                                  crop_width: 1, crop_height: 1,
                                                  image_width: 1, image_height: 1,
                                                  background_color: 'FFFFFF', geometry: '1x1' })
              end
            end
          end

          describe 'all other styles' do
            describe 'processors' do
              let(:non_base_processors) { AdjustableImage::AdjustableStyles::NON_BASE_STYLE_PROCESSORS }

              context 'with default processors' do
                let(:image_style_options) do
                  { base_style_name: base_style_name,
                    static_styles: {
                      teacup: { geometry: '15x15' },
                      mug: { geometry: '72x72', processors: [:make_tea_sized] }
                    },
                    default_processors: [:make_larger] }
                end

                it 'adds the non-base style processors before the options processors' do
                  teacup_processors = adjusted_styles[:teacup][:processors]

                  expect(teacup_processors).to eq(non_base_processors + [:make_larger])
                end

                context 'with style specific processors' do
                  it 'adds the non-base style processors before the style specific processors' do
                    mug_processors = adjusted_styles[:mug][:processors]

                    expect(mug_processors).to eq(non_base_processors + [:make_tea_sized])
                  end
                end
              end

              context 'without default processors' do
                context 'with style specific processors' do
                  let(:image_style_options) do
                    {
                      base_style_name: base_style_name,
                      static_styles: { mug: { geometry: '71x71', processors: [:make_cup_sized] } }
                    }
                  end

                  it 'adds the non-base style processors before the style specific processors' do
                    expect(adjusted_styles[:mug][:processors]).to eq(non_base_processors + [:make_cup_sized])
                  end
                end
              end

              context 'with no processors' do
                let(:image_style_options) do
                  { base_style_name: base_style_name, static_styles: { mug: { geometry: '17x17' } } }
                end

                it 'adds the non-base style processors' do
                  expect(adjusted_styles[:mug][:processors]).to eq(non_base_processors)
                end
              end
            end

            describe 'styles' do
              let(:image_style_options) do
                { base_style_name: base_style_name,
                  static_styles: {
                    coffee_mug: { geometry: '50x51' },
                  } }
              end

              it 'returns the passed-in style for that style name' do
                coffee_mug_styles = adjusted_styles[:coffee_mug]
                coffee_mug_styles.delete(:processors)

                expect(coffee_mug_styles).to eq(geometry: '50x51', base_style_name: base_style_name)
              end
            end
          end
        end
      end
    end
  end
end

class StylesContainer
  include AdjustableImage::AdjustableStyles

  attr_accessor :image_style_options, :image_adjustments, :new_record, :image

  def initialize(options, adjustments, new_record, image = nil)
    self.image_style_options = options
    self.image_adjustments = adjustments || AdjustableImage::ImageAdjustments.new
    self.new_record = new_record
    self.image = image
  end

  def new_record?
    self.new_record
  end
end
