
Pod::Spec.new do |s|
    s.name         = 'WPLibrary'
    s.version      = '1.0'
    s.summary      = ' a library for huasheng wedding'
    s.homepage     = 'https://github.com/sliu1126/WPLibrary'
    s.license      = 'MIT'
    s.author       = { "sliu" => "1053209520@qq.com" }
    s.platform     = :ios, "8.0"
    s.ios.deployment_target = "8.0"
    s.source       = {:git => 'https://github.com/sliu1126/WPLibrary.git', :tag => s.version}
    s.source_files = 'WPLibrary/WPLibrary/**/*.{h,m,swift}'
    s.requires_arc = true
    s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    s.dependency 'SwiftyJSON', '~> 2.3.2'
    s.dependency 'SwiftString', '~> 0.5'
end
