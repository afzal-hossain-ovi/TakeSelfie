
Pod::Spec.new do |spec|

  spec.name         = "TakeSelfie"
  spec.version      = "1.0.0"
  spec.summary      = "Detects face and takes a selfie."
  spec.description  = "An iOS framework that uses the front camera, detects face and takes a selfie."

  spec.homepage     = "https://github.com/afzal-hossain-ovi/TakeSelfie"
  spec.license      = "MIT"
  spec.author             = { "Afzal Hossain" => "afzalhossainovi@gmail.com" }
  spec.platform     = :ios, "13.0"
  
  spec.source       = { :git => "https://github.com/afzal-hossain-ovi/TakeSelfie.git", :tag => spec.version.to_s }

  spec.source_files  = "TakeSelfie/**/*.{swift}"
  spec.swift_versions = "5.0"


end