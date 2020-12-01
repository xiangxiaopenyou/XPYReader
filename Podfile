platform :ios, '9.0'

## ignore warning
inhibit_all_warnings!

target 'XPYReader' do
  
  # 网络请求工具
  pod 'AFNetworking'
  
  # AutoLayout
  pod 'Masonry'

  # 加载提示框
  pod 'MBProgressHUD'
  
  # 数据模型
  pod 'YYModel'

  # 数据库相关
  pod 'WCDB'

  # KVO
  pod 'KVOController'
  
  # 网络图片展示
  pod 'SDWebImage', '~> 5.6.0'
  
  # 全屏侧滑手势
  pod 'FDFullscreenPopGesture'
  
  # AOP
  pod 'Aspects'
  
  # XPYKit
  pod 'XPYKit', :git => 'https://github.com/xiangxiaopenyou/XPYKit.git'
  
  # 消除版本警告
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
      end
    end
  end
end
