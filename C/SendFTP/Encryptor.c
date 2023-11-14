#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

char* xor_encode(const char* encoded_str) {
    size_t encoded_len = strlen(encoded_str);

    char* decoded_str = (char*)malloc(encoded_len + 1);
    for (size_t i = 0; i < encoded_len; i++) {
        decoded_str[i] = encoded_str[i] ^ 1; // XOR with bit 1
    }
    decoded_str[encoded_len] = '\0';

    return decoded_str;
}

char* hex_encode(const char* str) {
    size_t str_len = strlen(str);
    char* encoded_str = (char*)malloc((str_len * 2) + 1);

    for (size_t i = 0; i < str_len; i++) {
        sprintf(encoded_str + (i * 2), "%02x", str[i]);
    }
    encoded_str[str_len * 2] = '\0';

    return encoded_str;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: ./Encryptor <username:password>\n");
        return 1;
    }

    char* xor_encoded_credentials = xor_encode(argv[1]);
    char* hex_encoded_credentials = hex_encode(xor_encoded_credentials);
    printf("Encoded credentials: %s\n", hex_encoded_credentials);

    free(xor_encoded_credentials);
    free(hex_encoded_credentials);

    return 0;
}