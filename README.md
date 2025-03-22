# SSL Preload for mitmproxy

A simple LD_PRELOAD library that makes applications accept certificates issued by mitmproxy by intercepting OpenSSL's verification functions.

## Building with Nix

This project includes a Nix flake for building on NixOS:

```bash
nix build
```

## Building with Gnumake

```bash
make
```

## Usage with mitmproxy

1. Start mitmproxy:
   ```bash
   mitmproxy
   ```

2. Run your application with the preload library and proxy configuration:
   ```bash
   # Using the Nix-built wrapper
   HTTPS_PROXY=127.0.0.1:8080 with-ssl-preload application

   # Or manually
   HTTPS_PROXY=127.0.0.1:8080 LD_PRELOAD=./libssl_preload.so application
   ```

## How It Works

This library works by:

1. Intercepting OpenSSL's `SSL_CTX_set_verify` function to inject a custom verification callback
2. Intercepting OpenSSL's `X509_verify_cert` function to bypass certificate validation
3. Always returning success during certificate verification

## Limitations

- This approach only works for applications that use OpenSSL for SSL/TLS
- Applications using other libraries (GnuTLS, NSS) or static linking might not work
- Applications with additional certificate pinning mechanisms may still reject connections

## Security Warning

This library bypasses certificate validation, which is a core security feature of SSL/TLS. Only use this for development, debugging, or testing purposes in controlled environments.

## Related Projects

- [screwmysecurity](https://github.com/shenki/screwmysecurity) - Patches `X509_verify_cert`
- [openssl-hook](https://github.com/sebcat/openssl-hook) - Log data to/from SSL_write/SSL_read to disk using LD_PRELOAD hooks
- [tlsinterposer](https://github.com/Netfuture/tlsinterposer) - OpenSSL library interposer to make existing binary software use more secure TLS protocol variants
