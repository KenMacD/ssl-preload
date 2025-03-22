#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <openssl/x509_vfy.h>

typedef void (*orig_SSL_CTX_set_verify_t)(SSL_CTX *ctx, int mode, SSL_verify_cb verify_callback);
typedef int (*orig_X509_verify_cert_t)(X509_STORE_CTX *ctx);

int custom_verify_callback(int preverify_ok, X509_STORE_CTX *ctx) {
    fprintf(stderr, "[ssl_preload] Certificate verification requested (preverify_ok=%d)\n", preverify_ok);
    
    // Return 1 to indicate valid
    return 1;
}

// Hook for SSL_CTX_set_verify
void SSL_CTX_set_verify(SSL_CTX *ctx, int mode, SSL_verify_cb verify_callback) {
    fprintf(stderr, "[ssl_preload] SSL_CTX_set_verify called\n");
    
    // Get the original function
    orig_SSL_CTX_set_verify_t original_function = dlsym(RTLD_NEXT, "SSL_CTX_set_verify");
    
    if (mode & SSL_VERIFY_PEER) {
        fprintf(stderr, "[ssl_preload] Replacing verify callback\n");
        // Replace the verification mode and callback
        original_function(ctx, mode, custom_verify_callback);
    } else {
        // Call the original function
        original_function(ctx, mode, verify_callback);
    }
}

int X509_verify_cert(X509_STORE_CTX *ctx) {
    fprintf(stderr, "[ssl_preload] X509_verify_cert called\n");

    // Return 1 to indicate valid
    return 1;
}
