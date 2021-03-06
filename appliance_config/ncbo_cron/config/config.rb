#local IP address lookup. This hack doesn't make connection to external hosts
require 'socket'
  def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '8.8.8.8', 1 #google
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

$LOCAL_IP = local_ip


begin
  LinkedData.config do |config|
    config.goo_host           = "localhost"
    config.goo_port           = 8081
    config.rest_url_prefix    = "http://#{$LOCAL_IP}:8080/"
    config.replace_url_prefix = false
    config.ui_host            = "http://#{$LOCAL_IP}"
    config.search_server_url  = "http://localhost:8983/solr/term_search_core1"
    config.property_search_server_url = "http://localhost:8983/solr/prop_search_core1"
    config.repository_folder  = "/srv/ncbo/repository"
    config.enable_security    = false

    #Caches
    Goo.use_cache             = true
    config.goo_redis_host     = "localhost"
    config.goo_redis_port     = 6381
    config.enable_http_cache  = true
    config.http_redis_host    = "localhost"
    config.http_redis_port    = 6380

    # PURL server config parameters
    config.enable_purl            = false
    config.purl_host              = "purl.example.org"
    config.purl_port              = 80
    config.purl_username          = "admin"
    config.purl_password          = "password"
    config.purl_maintainers       = "admin"
    config.purl_target_url_prefix = "http://example.org"

    # Email notifications
    config.enable_notifications   = false
    config.email_sender           = "admin@example.org" # Default sender for emails
    config.email_override         = "override@example.org" # all email gets sent here. Disable with email_override_disable.
    config.email_disable_override = true
    config.smtp_host              = "localhost"
    config.smtp_port              = 25
    config.smtp_auth_type         = :none # :none, :plain, :login, :cram_md5
    config.smtp_domain            = "example.org"

    # Ontology Google Analytics Redis
    # disabled
    config.ontology_analytics_redis_host = "localhost"
    config.ontology_analytics_redis_port = 6379
end
rescue NameError
  puts "(CNFG) >> LinkedData not available, cannot load config"
end
begin
  Annotator.config do |config|
    config.mgrep_dictionary_file   = "/srv/mgrep/dictionary/dictionary.txt"
    config.stop_words_default_file = "./config/default_stop_words.txt"
    config.mgrep_host              = "localhost"
    config.mgrep_port              = 55555
    config.mgrep_alt_host          = "localhost"
    config.mgrep_alt_port          = 55555
    config.annotator_redis_host    = "localhost"
    config.annotator_redis_port    = 6379
end
rescue NameError
  puts "(CNFG) >> Annotator not available, cannot load config"
end

begin
  OntologyRecommender.config do |config|
end
rescue NameError
  puts "(CNFG) >> OntologyRecommender not available, cannot load config"
end

begin
  LinkedData::OntologiesAPI.config do |config|
    config.enable_unicorn_workerkiller = true
    config.enable_throttling           = false
    config.http_redis_host             = LinkedData.settings.http_redis_host
    config.http_redis_port             = LinkedData.settings.http_redis_port
    config.restrict_download           = []
    #config.ontology_rank               = ""
end
rescue NameError
  puts "(CNFG) >> OntologiesAPI not available, cannot load config"
end

begin
  NcboCron.config do |config|
    config.redis_host           = Annotator.settings.annotator_redis_host
    config.redis_port           = Annotator.settings.annotator_redis_port
    config.enable_ontology_analytics = false
    config.search_index_all_url = "http://localhost:8983/solr/term_search_core2"
    config.property_search_server_index_all_url = "http://localhost:8983/solr/prop_search_core2"
    config.ontology_report_path = "/srv/ncbo/reports/ontologies_report.json"
  end
rescue NameError
  puts "(CNFG) >> NcboCron not available, cannot load config"
end
