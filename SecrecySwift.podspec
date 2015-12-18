Pod::Spec.new do |s|

  s.name         = "SecrecySwift"
  s.version      = "0.1.0"
  s.summary      = "RSA/AES/Digest/HMAC for Swift"

  s.description  = <<-DESC
		   RSA/AES/Digest/HMAC for Swift
                   DESC

  s.homepage     = "https://github.com/adow/SecrecySwift"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "adow" => "reynoldqin@gmail.com" }
  s.social_media_url   = "http://twitter.com/reynoldqin"

  s.ios.deployment_target = "8.0"
  s.module_name = s.name
  s.source       = { :git => "git@github.com:adow/SecrecySwift.git", :tag => s.version }
  s.source_files  = ["SecrecySwift/*.swift","SecrecySwift/*.h"]
  s.requires_arc = true
  s.framework = "SystemConfiguration","Security"
  s.library = "CommonCrypto"
  #s.libraries = "CommonCrypto"
  s.module_map = "$(PODS_ROOT)/CommonCrypto/module.modulemap"
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/CommonCrypto '}
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/CommonCrypto $(PODS_ROOT)/CommonCrypto' }
end


