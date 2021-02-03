require_relative "lib/t64conv/version"

Gem::Specification.new do |spec|
  spec.name          = "t64conv"
  spec.version       = T64conv::VERSION
  spec.authors       = ["Jonathan Harden"]
  spec.email         = ["jfharden@gmail.com"]

  spec.summary       = "Find all t64 commodore tape images recursively and convert to D64."
  spec.description   = <<-END_OF_DESCRIPTION
    Recursively looks for zip files which contain T64 files, or plain T64, or D64 files.

    Will create an output directory and copy the D64 files, convert the T64 files and extract and convert any
    found in zip files in that directory sorting into alphabetised subdirectories and where needed also into
    further subdirectories with a release/version number.
  END_OF_DESCRIPTION
  spec.homepage      = "https://www.github.com/jfharden/t64-converter"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.github.com/jfharden/t64conv"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|feaures)/}) }
  end

  spec.add_runtime_dependency "optimist", "~> 3.0"
  spec.add_runtime_dependency "rubyzip", "~> 2.3"
end
