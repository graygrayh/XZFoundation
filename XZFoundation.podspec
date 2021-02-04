#
# Be sure to run `pod lib lint XZFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZFoundation'
  s.version          = '0.1'
  s.summary          = '基础拓展、工具类组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
基础拓展、工具组件库
                       DESC

  s.homepage         = 'https://github.cn/graygrayh/XZfoundation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'graygrayh' => '873557329@qq.com' }
  s.source           = { :git => 'https://github.cn/graygrayh/XZfoundation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'XZFoundation/Classes/**/*'

  s.swift_version = '5.0'
  s.dependency 'KeychainSwift' #19.0.0
  
end
