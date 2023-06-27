#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "helpers.h"

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("ERROR: Please input date.\nFORMAT: ./howold dd/mm/yyyy\n");
        exit(1);
    }

    int commandLineArgsCheck = checkValidDateInput(argv[1]);
    if (commandLineArgsCheck != 1) {
        printf("ERROR: input date format incorrect.\nFORMAT: dd/mm/yyyy\n");
        exit(2);
    }

    /* PARSE USER INPUT DATE INTO INT ARRAY */
    char *inputDate = strdup(argv[1]);    // copy argv to a new variable
    char *token = strtok(inputDate, "/."); // tokenise it
    int comparatorDate[3];                // this will hold the parsed user input date

    int i = 0;
    while (token != NULL) {
        // parse node date (e.g. 19/9/1999) into comparator
        // by passing in NULL it tells strtok() to remember the last place it left off and continue as before.
        comparatorDate[i] = atoi(token); // pass the token in as an integer
        token = strtok(NULL, "/.");       // get the next token
        i++;
    }

    /* GET TODAY'S DATE */
    int dateToday[3]; // [day, month, year]
    getTodaysDate(dateToday); 

    DateInfo info;
    getDifferenceBetweenDates(dateToday, comparatorDate, &info);

    printf("\n　%i years & %i months old (%i days old)\n\n", info.AGE_YEARS, info.AGE_MONTHS, info.AGE_DAYS);

}
