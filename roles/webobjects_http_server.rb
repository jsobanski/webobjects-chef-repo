
name "webobjects_http_server"
description "A server which handles HTTP requests and pass them via wonder adapter to a WebObjects application server"
run_list "recipe[apache2]", "recipe[apache2::mod_ssl]", "recipe[webobjects::build_apache_adaptor]", "recipe[webobjects::modify_apache_config]"