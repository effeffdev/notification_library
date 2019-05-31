require 'json'
package = JSON.parse(File.read('../package.json'))

Pod::Spec.new do |s|
  s.name           = "RNNotificationLibrary"
  s.version        = package["version"]
  s.summary        = package["description"]
  s.homepage       = "https://github.com/ffroeschl/notification_library"
  s.author         = { "Fabian Fröschl" => "ffroeschl@phocus.com" }
  s.ios.deployment_target = '7.0'
  s.license        = package["license"]
  s.source_files   = "*.{h,m}"
  s.source         = { :git => "https://github.com/ffroeschl/notification_library.git", :tag => "v#{s.version}" }

  s.dependency 'React'
end