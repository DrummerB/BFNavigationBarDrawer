
Pod::Spec.new do |s|


  s.name         = "BFNavigationBarDrawer"
  s.version      = "1.0.0"
  s.summary      = "A UIToolbar subclass that can easily be displayed below a UINavigationBar, similarly to the playlist view in the Music app."
  s.homepage     = "https://github.com/DrummerB/BFNavigationBarDrawer"
 
  s.author       = { "Balazs Faludi" => "balazsfaludi@gmail.com" }

  s.source       = { 
    :git => "https://github.com/DrummerB/BFNavigationBarDrawer",
    :tag =>  s.version.to_s
  }

  s.source_files  = 'BFNavigationBarDrawer/*.{h,m}'
  
  s.requires_arc = true


end
