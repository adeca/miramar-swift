Pod::Spec.new do |s|
  s.name             = 'Miramar'
  s.version          = '1.0.0'
  s.summary          = 'This is an implementation of observable streams and values.'
  s.homepage         = 'https://github.com/adeca/miramar-swift'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Agustín de Cabrera' => 'agustindc@gmail.com' }
  s.source           = { :git => 'https://github.com/adeca/miramar-swift.git' }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Miramar/**/*.swift'
  
end
