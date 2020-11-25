require 'mkmf'

dir_config("puma_http11")

# Make all warnings into errors
if respond_to? :append_cflags
  append_cflags config_string 'WERRORFLAG'
else
  $CFLAGS += ' ' << (config_string 'WERRORFLAG')
end

if $mingw && RUBY_VERSION >= '2.4'
  append_cflags  '-fstack-protector-strong -D_FORTIFY_SOURCE=2'
  append_ldflags '-fstack-protector-strong -l:libssp.a'
  have_library 'ssp'
end

unless ENV["DISABLE_SSL"]
  dir_config("openssl")

  if %w'crypto libeay32'.find {|crypto| have_library(crypto, 'BIO_read')} and
      %w'ssl ssleay32'.find {|ssl| have_library(ssl, 'SSL_CTX_new')}

    have_header "openssl/bio.h"

    # below is  yes for 1.0.2 & later
    have_func  "DTLS_method"                           , "openssl/ssl.h"

    # below are yes for 1.1.0 & later
    have_func  "TLS_server_method"                     , "openssl/ssl.h"
    have_func  "SSL_CTX_set_min_proto_version(NULL, 0)", "openssl/ssl.h"
  end
end

create_makefile("puma/puma_http11")
