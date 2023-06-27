#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "helpers.h"


int main(int argc, char **argv)
{
    if (argc != 3) {
        printf("ERROR:   Please input dates. \nFORMAT:  dd/mm/yyyy \nEXAMPLE: ./between [earlier date] [later date]\n");
        exit(1);
    }

    int commandLineArgsCheck_1 = checkValidDateInput(argv[1]);
    int commandLineArgsCheck_2 = checkValidDateInput(argv[2]);
    
    if (commandLineArgsCheck_1 != 1\
     || commandLineArgsCheck_2 != 1) {
        printf("ERROR:   Input date format(s) incorrect. \nFORMAT:  dd/mm/yyyy \nEXAMPLE: ./between [earlier date] [later date]\n");
        exit(2);
    }

    int date_1[3];  // [0=dd, 1=mm, 2=yyyy]
    int date_2[3];  
    parseDateArgv(date_1, &argv[1]);                
    parseDateArgv(date_2, &argv[2]);            

    DateInfo info;
    getDifferenceBetweenDates(date_2, date_1, &info);

    printf("\nDATE 1 \t\t DATE 2\n");
    printf("%i/%i/%i  - [...%i/%i/%i]\n\n", date_1[0], date_1[1], date_1[2], date_2[0], date_2[1], date_2[2]);

    if (info.years == 0 && info.months != 0) {
        printf(" = %i months, %i days", info.months, info.days);    
    }
    else if (info.years == 0 && info.months == 0) {
        printf(" = %i days\n\n", info.raw_days);
        exit(0);
    } else {
        printf(" = %i years, %i months, %i days", info.years, info.months, info.days);
    }

    printf(" (%i days total)\n\n", info.raw_days);
    exit(0);

}


