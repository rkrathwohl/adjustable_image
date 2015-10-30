# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adjustable_image/version'

Gem::Specification.new do |specification|
  specification.name          = "adjustable_image"
  specification.version       = AdjustableImage::VERSION
  specification.authors       = ["Rebecca Krathwohl"]
  specification.email         = ["rkrathwohl@charitybuzz.com"]
  specification.summary       = %q{In conjection with cropper-tool jquery plugin, upload & crop images appropriately.}
  specification.description   = %q{Optional means it doesn't need to show up.}
  specification.homepage      = ""
  specification.license       = "MIT"

  specification.files         = `git ls-files -z`.split("\x0")
  specification.executables   = specification.files.grep(%r{^bin/}) { |f| File.basename(f) }
  specification.test_files    = specification.files.grep(%r{^(test|spec|features)/})
  specification.require_paths = ["lib"]

  specification.add_development_dependency "bundler", "~> 1.6"
  specification.add_development_dependency "rake"

  specification.add_dependency 'paperclip', '~> 3.4.2'
  specification.add_development_dependency 'rspec'
  specification.add_development_dependency 'sqlite3'
end
