#include "helpers.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void getTodaysDate(int *date)
{
    time_t t = time(NULL);               // get current time data
    struct tm *timeData = localtime(&t); // parse into fields using time.h lib fn

    date[0] = timeData->tm_mday;
    date[1] = timeData->tm_mon + 1;     // add 1 to the tm_mon field
    date[2] = timeData->tm_year + 1900; // add 1900 to tm_year field to get actual year value
    // printf("Today's Date: %i - %i - %i\n", date[2], date[1], date[0]);
}

time_t timeof(int day, int mon, int yr)
{
    struct tm tm;
    time_t tod;

    memset(&tm, 0, sizeof(tm));

    tm.tm_year = yr - 1900;
    tm.tm_mon = mon - 1;
    tm.tm_mday = day;
    tm.tm_hour = 0;   // set to midnight to avoid issues with DST crossover or leap seconds
    tm.tm_isdst = -1; // let mktime() determine the correct DST offset

    char buffer[80];
    strftime(buffer, 80, "%Y-%m-%d %H:%M:%S", &tm);
    // printf("tm: %s\n", buffer);

    tod = mktime(&tm);

    strftime(buffer, 80, "%Y-%m-%d %H:%M:%S", localtime(&tod));
    // printf("tod: %s\n", buffer);

    return tod;
}

void getDifferenceBetweenDates(int *today, int *comparisonDate, DateInfo *info)
{
    // This implementation a bit rough; purely needed to get the number of days since a date.
    // See daysBetweenTwoDates for a more rigorous algorithm.
    time_t presentDate = timeof(today[0], today[1], today[2]);
    time_t pastDate = timeof(comparisonDate[0], comparisonDate[1], comparisonDate[2]);
    time_t daysDifference = (presentDate - pastDate) / (24 * 60 * 60);

    info->AGE_DAYS = (int)daysDifference;

    int ageMonths = 0;
    if (today[1] < comparisonDate[1]) {
        ageMonths = (12 - comparisonDate[1]) + today[1]; // Calculate remaining months
    }
    else if (today[1] > comparisonDate[1]) {
        ageMonths = today[1] - comparisonDate[1];
    } else {
        if (today[0] >= comparisonDate[0]) {
            ageMonths = 0; // No remaining months if same month and present day is equal or greater
        } else {
            ageMonths = 11; // 11 remaining months if same month but present day is less
        }
    }
    info->AGE_MONTHS = ageMonths;

    int ageYears = today[2] - comparisonDate[2]; // difference in years only
    if (today[1] < comparisonDate[1]) {
        ageYears--; // subtract if younger by month
    }
    else if (today[1] == comparisonDate[1]) {
        if (today[0] < comparisonDate[0]) {
            ageYears--; // subtract if younger by day but not by month
        }
    }
    info->AGE_YEARS = ageYears;
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
