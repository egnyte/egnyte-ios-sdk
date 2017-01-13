
Pod::Spec.new do |s|
  s.name             = 'EgnyteSDK'
  s.version          = '1.0.0'
  s.summary          = 'Egnyte SDK for iOS'
  
  s.homepage       		= 'https://github.com/egnyte/egnyte-ios-sdk.git'
  s.license      		= { :type => 'MIT', :file => 'LICENSE' }
  s.author    			= "Egnyte"
  s.source         		= { :git => "https://github.com/egnyte/egnyte-ios-sdk.git", :tag => "v#{s.version}" }
  s.documentation_url	= 'https://developers.egnyte.com/docs'
  
  s.ios.deployment_target = '8.0'

  s.source_files = 'EgnyteSDK/Classes/**/*.swift'
  
  s.resource_bundles = {
    'EgnyteSDK' => ['EgnyteSDK/Resources/*.lproj']
  }
end
