platform :ios, '16.6'

target 'Movies' do
  use_frameworks!
  use_modular_headers!

  # UI & Animation
  pod 'lottie-ios'
  pod 'NVActivityIndicatorView'
  pod 'DropDown'
  pod 'FittedSheets'

  # Analytics
  pod 'Mixpanel-swift'

  # Image/Media
  pod 'Cloudinary'

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'

  # Google Sign-In
  pod 'GoogleSignIn'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
