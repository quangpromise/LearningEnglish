Pod::Spec.new do |s|
  s.name                = 'spatius_avatarkit'
  s.version             = '1.3.6'
  s.summary             = 'The Flutter plugin for AvatarKit.'
  s.description         = 'The Flutter plugin that provides iOS and Android integration for AvatarKit.'
  s.homepage            = 'https://github.com/spatius-ai/avatarkit-flutter'
  s.license             = { :file => '../LICENSE' }
  s.author              = { 'Spatius' => 'hello@spatialwalk.net' }
  s.source              = { :path => '.' }
  s.source_files        = 'Classes/**/*'
  s.vendored_frameworks = 'Frameworks/AvatarKit.xcframework'
  s.platform            = :ios, '16.0'
  s.swift_version       = '6.2'
  s.libraries           = 'z', 'c++'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'ARCHS[sdk=iphoneos*]' => 'arm64',
    'ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'OTHER_LDFLAGS' => '-lz -lc++'
  }
  s.prepare_command = 'set -e
    if [ -d "Frameworks" ]; then
      rm -rf "Frameworks"
    fi
    if [ -d "Resources" ]; then
      rm -rf "Resources"
    fi
    echo "Downloading AvatarKit.xcframework..."
    curl -L --retry 5 --retry-all-errors -C - -o AvatarKit.zip "https://github.com/spatius-ai/avatarkit-ios-release/releases/download/v1.3.4/AvatarKit_202608311739.zip"
    unzip -q AvatarKit.zip
    mkdir -p Frameworks
    mv AvatarKit.xcframework Frameworks/
    rm AvatarKit.zip
    echo "AvatarKit.xcframework downloaded successfully"
  '
  s.script_phase = {
    :name => 'Ensure AvatarKit XCFramework and Resources',
    :script => 'set -e
      XCFRAMEWORK_PATH="${PODS_TARGET_SRCROOT}/Frameworks/AvatarKit.xcframework"
      if [ ! -d "${XCFRAMEWORK_PATH}" ]; then
        echo "AvatarKit.xcframework missing, downloading..."
        cd "${PODS_TARGET_SRCROOT}"
        rm -rf Frameworks
        curl -L --retry 5 --retry-all-errors -C - -o AvatarKit.zip "https://github.com/spatius-ai/avatarkit-ios-release/releases/download/v1.3.4/AvatarKit_202608311739.zip"
        unzip -q AvatarKit.zip
        mkdir -p Frameworks
        mv AvatarKit.xcframework Frameworks/
        rm AvatarKit.zip
        echo "AvatarKit.xcframework prepared at ${XCFRAMEWORK_PATH}"
      else
        echo "AvatarKit.xcframework exists, skip download"
      fi

      if [ "${PLATFORM_NAME}" = "iphonesimulator" ]; then
        if [ -d "${XCFRAMEWORK_PATH}/ios-arm64-simulator" ]; then
          ARCH_DIR="ios-arm64-simulator"
        else
          ARCH_DIR="ios-arm64_x86_64-simulator"
        fi
      else
        ARCH_DIR="ios-arm64"
      fi
      RESOURCE_BUNDLE_SRC="${XCFRAMEWORK_PATH}/${ARCH_DIR}/AvatarKit.framework/Resources/AvatarKitResources.bundle"
      if [ ! -d "${RESOURCE_BUNDLE_SRC}" ]; then
        RESOURCE_BUNDLE_SRC="${XCFRAMEWORK_PATH}/ios-arm64/AvatarKit.framework/Resources/AvatarKitResources.bundle"
      fi
      if [ -d "${RESOURCE_BUNDLE_SRC}" ]; then
        mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/"
        cp -R "${RESOURCE_BUNDLE_SRC}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/"
        echo "Copied AvatarKitResources.bundle to ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework/"
      fi
    ',
    :execution_position => :before_compile
  }
  s.dependency 'Flutter'
end
