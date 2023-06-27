#ifndef HELPERS_H
#define HELPERS_H

typedef struct {
    // int AGE_HOURS;
    int days;
    int months;
    int years;
    int raw_days;
} DateInfo;

int checkValidDateInput(const char* input);
void parseDateArgv(int *dateArray, char **argvDate);
void getDifferenceBetweenDates(int *today, int *comparisonDate, DateInfo *info);

#endif