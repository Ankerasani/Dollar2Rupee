platform :ios, '11.0'

target 'Dollar2Rupee' do

  use_frameworks!

  pod 'HandyUIKit'
  # pod 'SwiftSoup'  # Removed - scraping now done on backend
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'Pastel'

  target 'Dollar2RupeeTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# Fix libarclite issue by setting minimum deployment target for all pods
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end

