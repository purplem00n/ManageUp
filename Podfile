# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'ManageUp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ManageUp
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'IQKeyboardManagerSwift'
pod 'iOSDropDown'



post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end




  installer.pods_project.targets.each do |target|
    # Make it build with XCode 14
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
    # Make it work with GoogleDataTransport
    if target.name.start_with? "GoogleDataTransport"
      target.build_configurations.each do |config|
        config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'NO' 
      end
    end
  end

end



end



