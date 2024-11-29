{ lib, config, pkgs, ... }:
with lib;
let
  appUser = "nginx";
  name = "panel";
  cfg = config.modules.nginx.${name};
  serverName = "${name}.${config.modules.nginx.domainName}";
  port = cfg.port;
  enableSSL = cfg.enableSSL;
  dir = "${config.modules.pelican-panel.directory}/public";
in
{
  options.modules.nginx.${name} = {
    enable = mkEnableOption "Enable ${name}";

    port = mkOption {
      type = types.int;
      default = 443;
      description = ''
        The port to use for this virtual host.
      '';
    };

    enableSSL = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable SSL for this virtual host.
      '';
    };
  };

  config = mkIf cfg.enable {
    modules.pelican-panel.enable = true;
    networking.firewall.allowedTCPPorts = [ port ];

    services.phpfpm.pools.${appUser} = {
      user = appUser;
      settings = {
        "listen.owner" = appUser;
        "listen.group" = appUser;
        "listen.mode" = "0600";
        "pm" = "dynamic";
        "pm.max_children" = 75;
        "pm.start_servers" = 10;
        "pm.min_spare_servers" = 5;
        "pm.max_spare_servers" = 20;
        "pm.max_requests" = 500;
        "catch_workers_output" = 1;
      };
    };

    services.nginx.virtualHosts."${serverName}" = {
      root = "${dir}";
      listen = [{ inherit port; addr="0.0.0.0"; ssl=enableSSL; }];

      forceSSL = enableSSL;
      enableACME = enableSSL;

      # These two lines are not needed when using ACME
      # sslCertificate = "/var/lib/acme/${serverName}/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/${serverName}/key.pem";
      
      extraConfig = ''
        index index.html index.htm index.php;
        charset utf-8;

        access_log off;
        error_log  /var/log/nginx/pelican.app-error.log error;

        client_max_body_size 100m;
        client_body_timeout 120s;

        sendfile off;

        ssl_session_cache shared:SSL:10m;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
        ssl_prefer_server_ciphers on;

        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header Content-Security-Policy "frame-ancestors 'self'";
        add_header X-Frame-Options DENY;
        add_header Referrer-Policy same-origin;
      '';

      locations = {
        "/" = {
          extraConfig = ''       
            try_files $uri $uri/ /index.php?$query_string;
          '';
	      };

        "/favicon.ico".extraConfig = ''
          access_log off;
          log_not_found off;
        '';

        "/robots.txt".extraConfig = ''
          access_log off;
          log_not_found off;
        '';
      
        "~ \\.php$"  = {         
          extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.${appUser}.socket};
            fastcgi_index index.php;
            include ${config.services.nginx.package}/conf/fastcgi_params;
            fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param HTTP_PROXY "";
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;      
          '';
        };

        "~ /\\.ht".extraConfig = ''
          deny all;
        '';
      };
    };
  };
}
