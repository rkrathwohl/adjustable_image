# AdjustableImage

For use with Paperclip and the cropper_tool (jrac).

Scenario:
You have an image you would like to adjust (crop, resize, background color, extent) and then
 have that image as the base for any other size thumbnails you'd like.

### Requirements:

Rails >= 3.23
Paperclip >= 3.4.2


## Installation

Add this line to your application's Gemfile:

    gem 'adjustable_image'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adjustable_image


## Usage

Make sure that there's a text column on your model called `image_adjustments` - this will hold the attributes
to be adjusted and will be serialized to json.

Add `has_adjustable_image(attachment_image_name, options)` to your ActiveRecord model.

The only required attribute is:
 * `base_style_name` - the name of the size you'll be dynamically adjusted and will use as a base for the thumbnails

For the `styles` attribute of the `options` hash:
- Non-base styles needs to have a `geometry` key (same as for paperclip thumbnails)
- Processors that are applicable to all styles will be overriden by individual styles' processors (same as paperclip)

On upload of the image, you can have the `ForceActualFormatProcessor` run (add `force_actual_format: true` to the options).
This will adjust the image to have the correct extension (upload something.png which is actually a .jpg and this will
convert the image to something.jpg).  It will also add the appropriate extension if it is missing.  This will update the
`file_name`, `content_type`, and `file_size` Paperclip columns.


The adjusted image will have the following processors applied before any processors specified (for that style or all styles):
* `DynamicResizeProcessor` - needs `image_width` and `image_height`
* `DynamicExtentProcessor` -
  1) needs `background_color` - in hex without the hash sign.  Defaults to FFFFFF
  2) needs `crop_width`, `crop_height`, `crop_x`, `crop_y` - using the
 resized image (from the dynamic resize processor), readjust the image using the new height & width, and crop using the offsets,
 adds in the background color to the parts that aren't from the original image

All thumbnails will have the following processor applied before any other processers as specified (for that style or all styles):
* `ResetBaseStyleProcessor` - this will cause all further processors to use the base style file rather than the original for
 creating the thumbnail



## Contributing

1. Fork it ( https://github.com/[my-github-username]/adjustable_image/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
