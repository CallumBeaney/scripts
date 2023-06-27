#include "helpers.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void getDifferenceBetweenDates(int *date1, int *date2, DateInfo *info)
{
    int daysInMonth[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    int futureDay = date1[0];
    int futureMonth = date1[1];
    int futureYear = date1[2];

    int pastDay = date2[0];
    int pastMonth = date2[1];
    int pastYear = date2[2];

    // Check if present year is a leap year and update days in February
    if ((futureYear % 4 == 0 && futureYear % 100 != 0) || futureYear % 400 == 0) {
        daysInMonth[1] = 29;
    }

    // Calculate the total number of days elapsed for each date
    int presentTotalDays = futureDay;
    for (int i = 0; i < futureMonth - 1; i++) {
        presentTotalDays += daysInMonth[i];
    }
    presentTotalDays += futureYear * 365 + futureYear / 4 - futureYear / 100 + futureYear / 400;

    int pastTotalDays = pastDay;
    for (int i = 0; i < pastMonth - 1; i++) {
        pastTotalDays += daysInMonth[i];
    }
    pastTotalDays += pastYear * 365 + pastYear / 4 - pastYear / 100 + pastYear / 400;

    int daysDifference = presentTotalDays - pastTotalDays;
    
    info->days = daysDifference % 365 % 30;
    info->months = (daysDifference % 365) / 30;
    info->years = daysDifference / 365;
    
    info->raw_days = daysDifference;
}


int checkValidDateInput(const char *date)
{
    const char *slashFormat = "%d/%m/%Y";
    const char *dotFormat = "%d.%m.%Y";

    struct tm timeStruct;
    if (strptime(date, slashFormat, &timeStruct) == NULL && strptime(date, dotFormat, &timeStruct) == NULL) {
        return 0; // Parsing failed
    }
    return 1; // valid
}


void parseDateArgv(int *dateArray, char**argvDate) {
    char *inputDate_1 = strdup(*argvDate); // copy argv to a new variable
    char *token = strtok(inputDate_1, "/."); // tokenise it

    int i = 0;
    while (token != NULL) {
        // parse node date (e.g. 19/9/1999) into comparator
        // by passing in NULL it tells strtok() to remember the last place it left off and continue as before.
        dateArray[i] = atoi(token); // pass the token in as an integer
        token = strtok(NULL, "/."); // get the next token
        i++;
    }
}