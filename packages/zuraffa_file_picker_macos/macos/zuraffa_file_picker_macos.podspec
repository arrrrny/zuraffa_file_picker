#
# ZuraffaFilePicker macOS podspec — the macOS native plugin.
#
Pod::Spec.new do |s|
  s.name             = 'zuraffa_file_picker_macos'
  s.version          = '1.0.0'
  s.summary          = 'The macOS implementation of zuraffa_file_picker.'
  s.description      = 'Typed file picking: pick files, save documents and pick directories via NSOpenPanel and NSSavePanel.'
  s.homepage         = 'https://zuraffa.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Zuraffa' => 'https://github.com/arrrrny' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '11.0'
  s.swift_version    = '5.9'
end
