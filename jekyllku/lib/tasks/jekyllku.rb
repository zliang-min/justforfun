Dir[File.join(File.dirname(__FILE__), '*.rake')].each { |rake_file| load rake_file }
