#include <stdio.h>
#include <curl/curl.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

char* hex_decode(const char* encoded_str) {
  size_t encoded_len = strlen(encoded_str);
  size_t decoded_len = encoded_len / 2;

  char* decoded_str = (char*)malloc(decoded_len + 1);
  for (size_t i = 0; i < decoded_len; i++) {
    sscanf(encoded_str + 2 * i, "%2hhx", &decoded_str[i]);
  }
  decoded_str[decoded_len] = '\0';

  return decoded_str;
}

char* xor_decode(const char* encoded_str) {
    size_t encoded_len = strlen(encoded_str);

    char* decoded_str = (char*)malloc(encoded_len + 1);
    for (size_t i = 0; i < encoded_len; i++) {
        decoded_str[i] = encoded_str[i] ^ 1;
    }
    decoded_str[encoded_len] = '\0';

    return decoded_str;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: ./SendFTP <ZIP_file> <FTP_SERVER_URL> <Encrypted Credential>\n");
        return 1;
    }
    printf("Argument 1: %s\n", argv[1]);
    printf("Argument 2: %s\n", argv[2]);
    printf("Argument 3: %s\n", argv[3]);
    char* hex_decoded_credentials = hex_decode(argv[3]);
    char* decoded_credentials = xor_decode(hex_decoded_credentials);
    
    CURL *curl;
    CURLcode res;

    curl_global_init(CURL_GLOBAL_ALL);
    curl = curl_easy_init();
    if (curl) {
        // Set the FTP upload options
        curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
        //curl_easy_setopt(curl, CURLOPT_URL, "<FTP_SERVER_URL>");
        curl_easy_setopt(curl, CURLOPT_USERPWD, decoded_credentials);

        // Set the source file (zip file) and the target folder
        curl_easy_setopt(curl, CURLOPT_READDATA, fopen(argv[1], "rb"));
        curl_easy_setopt(curl, CURLOPT_INFILESIZE_LARGE, (curl_off_t)-1);
        curl_easy_setopt(curl, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
        curl_easy_setopt(curl, CURLOPT_URL, argv[2]);

        // Perform the FTP upload
        res = curl_easy_perform(curl);

        // Check for errors
        if (res != CURLE_OK) {
        fprintf(stderr, "FTP Upload failed: %s\n", curl_easy_strerror(res));
        }

        // Cleanup
        curl_easy_cleanup(curl);
    }

    curl_global_cleanup();
    free(hex_decoded_credentials);
    free(decoded_credentials);
    return 0;
}

