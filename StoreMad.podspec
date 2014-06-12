Pod::Spec.new do |s|
  s.name         = "StoreMad"
  s.version      = "0.0.1"
  s.summary      = "A collection of helpful categories and controllers that encourage a healthy relationship with Core Data"
  s.license      = 'MIT'
  s.author       = { 
    "Andrew Smith" => "drewsmits@gmail.com"
  }
  s.social_media_url = "http://twitter.com/drewsmits"
  s.requires_arc = true
  s.platform     = :ios, '7.0'
  s.source       = { 
    :git => "https://github.com/Drewsmits/StoreMad.git", 
    :tag => s.version.to_s 
  }
  s.homepage = "http://github.com/Drewsmits/StoreMad"
  s.source_files  = 'StoreMad/*.{h,m}'
  s.public_header_files = 'StoreMad/*.h'
  s.frameworks = 'CoreData', 'Foundation'
end
