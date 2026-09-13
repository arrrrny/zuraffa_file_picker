#
# ZuraffaFilePicker iOS podspec — the iOS native plugin.
#
Pod::Spec.new do |s|
  s.name             = 'zuraffa_file_picker_ios'
  s.version          = '1.0.0'
  s.summary          = 'The iOS implementation of zuraffa_file_picker.'
  s.description      = 'Typed file picking: pick files, save documents and pick directories via UIDocumentPickerViewController.'
  s.homepage         = 'https://zuraffa.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Zuraffa' => 'https://github.com/arrrrny' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '14.0'
  s.swift_version    = '5.9'
end
