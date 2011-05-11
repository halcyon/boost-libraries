define 'boost' do
  project.version = '1.39.0'
  boost_version=project.version.gsub(/\./,'_')
  boost_archive="boost_"+"#{boost_version}"+".tar.bz2"
  boost_dir="boost_#{boost_version}"
  BUILD_LIB="date_time,filesystem,program_options,regex,serialization,signals,system,test,thread"
  ARCH=['64']

  build do
    if not file("target/#{boost_dir}").exist?
      if not file(boost_archive).exist?
        system "wget http://downloads.sourceforge.net/project/boost/boost/#{project.version}/#{boost_archive}"
      end
      system 'mkdir -p target'
      cd 'target'
      system "tar jxf ../#{boost_archive}"
      mv Dir.glob("#{boost_dir}/*"), '.'
      system "sh bootstrap.sh --with-libraries=$BUILD_LIB"
      ARCH.each do |arch|
        stagedir = "x#{arch}"
        flags="cxxflags=-m#{arch} linkflags=-m#{arch} cflags=-m#{arch}"
        mkdir_p stagedir
        system "./bjam -a --toolset=gcc #{flags} address-model=#{arch} --stagedir=#{stagedir} --build-type=complete stage"
      end
    end
  end

  boost=artifact("org.boost:libraries:tar.bz2:x64-linux-gcc:#{project.version}").from(file("target/#{boost_dir}_x64-linux-gcc.tar.bz2"))
  upload boost

  clean { rm_rf 'target' }
end
