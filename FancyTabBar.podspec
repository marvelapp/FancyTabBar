Pod::Spec.new do |s|
  s.name         = "FancyTabBar"
  s.version      = "0.0.1"
  s.summary      = "An expandable and customisable tabbar for iOS"

  s.homepage     = "https://github.com/marvelapp/FancyTabBar"

  s.license      = ""
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "marvelapp" => "" }

  s.source       = { :git => "git@github.com:marvelapp/FancyTabBar.git", :tag => "#{s.version}" }

  s.source_files  = "FancyTabBarDelegate", "FancyTabBar/*.{h,m}"

  s.public_header_files = "FancyTabBarDelegate", "FancyTabBar/*.h"

  s.resources = "Resources/*.png"

  s.requires_arc = true
end

