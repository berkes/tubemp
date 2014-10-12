require "rake"

Gem::Specification.new do |s|
  s.name  = "tubemp"
  s.version = "0.7.0"
  s.summary = "Tubemp. YouTube embeds without third party trackers."
  s.description = "tubemp is a tiny web-application which creates and serves thumbnail-images from YouTube embed-codes. These images link to the video and look like embedded videos."

  s.authors = ["Bèr `berkes` Kessels"]
  s.email = "ber@webschuur.com"
  s.homepage = "http://tubemp.webschuur.com"

  s.files = ([`git ls-files lib/`.split("\n")] + [`git ls-files assets/`.split("\n")] + ["bin/tubemp"]).flatten
  s.executables << 'tubemp'

  s.test_files = `git ls-files spec/`.split("\n")

  s.add_runtime_dependency 'sinatra', '~> 1.4'
  s.add_runtime_dependency 'rmagick', '~> 2.13'
  s.add_runtime_dependency 'video_info', '~> 1.1'
  s.add_runtime_dependency 'json', '~> 1.7.7'

  s.add_development_dependency 'rspec', '~> 2.13'
  s.add_development_dependency 'rack-test', '~> 0.6'
end
