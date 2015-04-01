require "bundler/gem_tasks"

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.4.zip"

require 'jettywrapper'

require 'engine_cart/rake_task'
EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

task :configure_jetty do
  FileList['solr_conf/conf/*'].each do |f|  
    cp("#{f}", 'jetty/solr/blacklight-core/conf/', :verbose => true)
  end
end

task :server do
  Rake::Task['engine_cart:generate'].invoke

  unless File.exists? 'jetty'
    Rake::Task['jetty:clean'].invoke
    Rake::Task['configure_jetty'].invoke
  end

  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait]= 60

  Jettywrapper.wrap(jetty_params) do
    within_test_app do
      system "bundle exec rails s"
    end
  end
end
