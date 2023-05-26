#ifndef HELPERS_H
#define HELPERS_H

#include <time.h> // required by timeof()

typedef struct {
    // int AGE_HOURS;
    int AGE_DAYS;
    int AGE_MONTHS;
    int AGE_YEARS;
} DateInfo;

void getTodaysDate(int *date);
void getDifferenceBetweenDates(int *today, int *comparisonDate, DateInfo* info);
time_t timeof(int day, int mon, int yr);
int checkValidDateInput(const char*);

#endif