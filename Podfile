platform :ios, '15.0'

target 'GIS' do
  use_frameworks!

  pod 'DropDown'
  pod 'Alamofire'
  pod 'NVActivityIndicatorView'
  pod 'MaterialComponents/Snackbar'
  pod 'SwiftyGif'
  pod 'IQKeyboardManagerSwift'
  pod 'RSSelectionMenu'
  pod 'UIDrawer', :git => 'https://github.com/Que20/UIDrawer.git', :tag => '1.0'
  pod 'SDWebImageSVGCoder'
  pod 'SVGKit'
  pod 'SKCountryPicker'

  target 'GISTests' do
    inherit! :search_paths
  end

  target 'GISUITests' do
  end

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
      end
    end
  end
end
