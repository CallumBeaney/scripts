// SUPPORT: Linux, MacOS

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXCHARS 500000 // about 0.5MB of space

int checkOS(void);
char *getClipboardContent(int);

/*
  This accesses your clipboard and does a wordcount operation on the text therein. It does so because some terminals --in my case ZSH-- interrupt I/O operations on running scripts if the user pastes in text containing newlines.  This is a conservative parser and reports any whitespace-delimited unit of text as a "word" (so "whitespace-delimited" is 1 word).
*/

int main()
{

    int OS = checkOS();
    char *clipboardRead = getClipboardContent(OS);
    if (clipboardRead == NULL)
    {
        // printf("Clipboard content: %s\n\n", clipboardRead);
        fprintf(stderr, "Error: Failed to get clipboard content.\n");
        exit(1);
    }

    int counter = 0;
    int index = 0;
    // printf("Read: ");
    while (clipboardRead[index] != '\0')
    {
        // printf("%c", clipboardRead[index]);
        if (clipboardRead[index] == ' ' /* Single quotes represent a single character, while double quotes represent a string literal */)
        {
            counter++;
        }
        index++;
    }

    printf("%i / %i", counter+1, index);

    free(clipboardRead);
    return 0;
}

char *getClipboardContent(int os)
{
    char *content = NULL;
    FILE *pipe;

    if (os == 2) { // macOS
        pipe = popen("pbpaste", "r");
    }
    else if (os == 1) { // Linux
        pipe = popen("xclip -selection clipboard -o", "r");
    }
    

    if (pipe != NULL) {
        char buffer[MAXCHARS];
        size_t totalSize = 0;
        size_t bytesRead;

        if (os == 2) { // macOS
            while ((bytesRead = fread(buffer, 1, sizeof(buffer), pipe)) > 0) {
                content = realloc(content, totalSize + bytesRead + 1);
                if (content == NULL) {
                    fprintf(stderr, "Error: Memory allocation failed.\n");
                    pclose(pipe);
                    return NULL;
                }

                memcpy(content + totalSize, buffer, bytesRead);
                totalSize += bytesRead;
            }

            content[totalSize] = '\0';
        }
        else if (os == 1) { // Linux
            while ((bytesRead = fread(buffer, 1, sizeof(buffer) - 1, pipe)) > 0)
            {
                buffer[bytesRead] = '\0';
                content = realloc(content, totalSize + bytesRead + 1);
                if (content == NULL)
                {
                    fprintf(stderr, "Error: Memory allocation failed.\n");
                    pclose(pipe);
                    return NULL;
                }

                strcat(content, buffer);
                totalSize += bytesRead;
            }
        }

        pclose(pipe);
    }

    return content;
}

int checkOS()
{
#ifdef __linux__
    printf("Running on Linux\n");
    return 1;
#elif defined(__APPLE__)
    printf("Running on macOS\n");
    return 2;
#else
    printf("Running on an unsupported operating system\n");
    exit(1);
#endif
}