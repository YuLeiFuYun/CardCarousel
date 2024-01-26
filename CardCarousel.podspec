Pod::Spec.new do |s|
    s.name         = 'CardCarousel'
    s.version      = '1.0.0'
    s.summary      = 'The most user-friendly carousel library, supporting configuration through spells.'

    s.homepage     = 'https://github.com/YuLeiFuYun/CardCarousel'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { '玉垒浮云' => 'yuleifuyunn@gmail.com' }
    s.source       = { :git => 'https://github.com/YuLeiFuYun/CardCarousel.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '11.0'
    s.swift_version = '5.9'

    s.source_files = 'Sources/CardCarousel/**/*'
end
