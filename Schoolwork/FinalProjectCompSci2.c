#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_STATION_LENGTH (25)


/**
 * Struction definition for train routes
 * This is provided
 * Do not make changes to the struction definition
 */
typedef struct train_route_def
{
    int origin_station;
    int dest_station;
    int start_time;
    int end_time;
    int duration;
    struct train_route_def *next;
} train_route;

/**
 * Input functions
 */
void read_file_stations(FILE *file, char stations[][MAX_STATION_LENGTH]);
train_route *read_file_trains(FILE *file, train_route *routes);
train_route *make_route(int origin_station, int dest_station, int start_time, int end_time);
train_route *add_route(train_route *routes, train_route *new_route);

/**
 * Calculation functions
 */
bool direct_route(train_route *routes, int origin_station, int dest_station);
train_route *shortest_time(train_route *routes);
void list_routes(train_route *routes, char stations[][MAX_STATION_LENGTH], int time);
int find_station_number(int num_stations, char stations[][MAX_STATION_LENGTH], char search_str[MAX_STATION_LENGTH]);
void find_station_name(char stations[][MAX_STATION_LENGTH], int station_num, char station_name[MAX_STATION_LENGTH]);

/**
 * Optional functions
 */
int convert_to_24(int minute_time);
int convert_from_24(int time_24);
int line_count(FILE *file);

int main(int argc, char *argv[])
{
    FILE *stationsFile = NULL;
    FILE *trainsFile = NULL;

    stationsFile = fopen(argv[1], "r");     //Opening stationsFile
    trainsFile = fopen(argv[2], "r");       //Opening trainsFile
    char stations[100][25];
    char search_str[25];
    int stationNumberSearch;

    if(argc != 3)                   //Error Checking
    {
        printf("Syntax Error: <exec> <stationsFile.dat> <trainsFile.dat>\n");
        exit(1);
    }

    if(stationsFile == NULL && trainsFile == NULL)          //Error Checking
    {
        printf("Error: stationsFile '%s' and trainsFile '%s' failed to open properly. Exiting.\n", argv[1], argv[2]);
        exit(1);
    }
    else if(stationsFile == NULL)                       //Error Checking
    {
        printf("Error: stationsFile '%s' failed to open properly. Exiting\n", argv[1]);
        exit(1);
    }
    else if(trainsFile == NULL)                         //Error Checking
    {
        printf("Error: trainsFile '%s' failed to open properly. Exiting.\n", argv[2]);
        exit(1);
    }

    read_file_stations(stationsFile, stations);
    train_route *routes = NULL;
    routes = read_file_trains(trainsFile, routes);
    fclose(trainsFile);         //closing trainsFile

    int input = -1;
    int len, num_Stations, statNumTest, originTest, destinationTest, hhmm, s1, s2;
    char input2Stations[25];
    char reset_name[25];
    bool dRoute;
    train_route *shortest = malloc(sizeof(train_route));

    while (input != 0)
    {
        printf("\n\n");
        printf("------------------------------------------------------\n");
        printf("             Welcome to the Train Program\n");
        printf("------------------------------------------------------\n\n");
        printf("   0)  Quit\n");
        printf("   1)  Find a station number\n");
        printf("   2)  Find a station name\n");
        printf("   3)  Is there a direct path between 2 stations?\n");
        printf("   4)  Find shortest time on train for a direct trip\n");
        printf("   5)  List all routes after a specified time (hhmm)\n\n");
        printf("Please pick an option: ");
        scanf("%d", &input);

        if(input < 0 || input > 5)
        {
            exit(1);
        }
        else if(input == 1)
        {
            printf("Enter a station name: ");
            fgets(search_str, 25, stdin);
            fgets(search_str, 25, stdin);
            len = strlen(search_str);
            search_str[(len - 1)] = '\0';
            num_Stations = line_count(stationsFile);
            stationNumberSearch = find_station_number(num_Stations, stations, search_str);

            if(stationNumberSearch == -1)
            {
                printf(" %s station does not exist.\n Make sure there isn't a typing error.\n\n", search_str);
            }
            else
            {
                printf(" %s is station number %d\n\n", search_str, stationNumberSearch);
            }
        }
        else if(input == 2)
        {
            printf("Enter a station #: ");
            scanf("%d", &statNumTest);
            find_station_name(stations, statNumTest, input2Stations);
            strcpy(input2Stations, reset_name);
            printf("\n");
        }
        else if(input == 3)
        {
            printf("Enter origin station number: ");
            scanf("%d", &originTest);
            printf("Enter destination station number: ");
            scanf("%d", &destinationTest);
            dRoute = direct_route(routes, originTest, destinationTest);
            if(dRoute == 0)
            {
                printf("There is NOT a direct path between station %d and station %d\n\n", originTest, destinationTest);
            }
            else
            {
                printf("There is a direct path between station %d and station %d\n\n", originTest, destinationTest);
            }
        }
        else if(input == 4)
        {
            shortest = shortest_time(routes);
            s1 = convert_to_24(shortest->start_time);
            s2 = convert_to_24(shortest->end_time);
            printf("The shortest route is from\n  %d: %s @ %d\n     to\n  %d: %s @ %d\n\n", shortest->origin_station, stations[shortest->origin_station], s1, shortest->dest_station, stations[shortest->dest_station], s2);

        }
        else if(input == 5)
        {
            printf("Enter earliest starting time in 24-hour format (hhmm): ");
            scanf("%d", &hhmm);
            list_routes(routes, stations, hhmm);
        }
    }

    fclose(stationsFile);           //closing stationsFile

    return 0;
}

/***********************
 * Required Functions *
 **********************/

/**
 * Input functions
 */
void read_file_stations(FILE *file, char stations[][MAX_STATION_LENGTH])
{
    int i, lines;
    int tmp;
    lines = line_count(file);

    for(i = 0; i < lines; ++i)
    {
        fscanf(file, "%d", &tmp);
        fscanf(file, "%s", &stations[tmp]);
    }
}

train_route *read_file_trains(FILE *file, train_route *routes)
{
    int lines = line_count(file);
    int i, origin_station, dest_station, start_time, end_time;
    train_route *tmp = NULL;

    for(i = 0; i < lines; i++)
    {
        fscanf(file, "%d", &origin_station);
        fscanf(file, "%d", &dest_station);
        fscanf(file, "%d", &start_time);
        fscanf(file, "%d", &end_time);

        tmp = make_route(origin_station, dest_station, start_time, end_time);
        routes = add_route(routes, tmp);
    }

    return routes;
}

train_route *make_route(int origin_station, int dest_station, int start_time, int end_time)
{
    train_route *new = malloc(sizeof(train_route));
    new->next = NULL;
    new->origin_station = origin_station;
    new->dest_station = dest_station;
    new->start_time = start_time;
    new->end_time = end_time;
    new->duration = end_time - start_time;

    return new;
}

train_route *add_route(train_route *routes, train_route *new_route)
{
    train_route *tmp2 = routes;      //temporary pointer to use to cycle through until one node before the end

    if (routes == NULL)
    {
        routes = new_route;
    }
    else
    {
        while(tmp2->next != NULL)
        {
            tmp2 = tmp2->next;
        }
        tmp2->next = new_route;
    }

    return routes;
}

/**
 * Calculation functions
 */

bool direct_route(train_route *routes, int origin_station, int dest_station)
{
    train_route *temp3 = routes;
    bool tf = false;

    if (temp3 != NULL)
    {
        while(temp3->next != NULL)
        {
            if(temp3->origin_station == origin_station && temp3->dest_station == dest_station)
            tf = true;
            temp3 = temp3->next;
        }

        if(temp3->origin_station == origin_station && temp3->dest_station == dest_station)
        {
            tf = true;
        }
    }
    return tf;
}

train_route *shortest_time(train_route *routes)
{
    train_route *temp4 = routes;
    train_route *shortestTime = routes;

    if (routes != NULL)
    {
        while (temp4->next != NULL)
        {
            if(temp4->duration <= shortestTime->duration)
            {
                shortestTime = temp4;
            }
            temp4 = temp4->next;
        }
        if(temp4->duration <= shortestTime->duration)
        {
            shortestTime = temp4;
        }
    }
    return shortestTime;
}

void list_routes(train_route *routes, char stations[][MAX_STATION_LENGTH], int time)
{
    train_route *temp5 = routes;
    int start_time_temp, end_time_temp;
    int emptyTester = 0;
    if(routes != NULL)
    {
        while(temp5->next != NULL)
        {
            start_time_temp = convert_to_24(temp5->start_time);
            if(start_time_temp >= time)
            {
                emptyTester++;
                end_time_temp = convert_to_24(temp5->end_time);
                printf("%2d: %-15s@ %4d  to  %2d: %-15s@ %4d\n", temp5->origin_station, stations[temp5->origin_station], start_time_temp, temp5->dest_station, stations[temp5->dest_station], end_time_temp);
            }
            temp5 = temp5->next;
        }
        if(start_time_temp >= time)
        {
            emptyTester++;
            end_time_temp = convert_to_24(temp5->end_time);
            printf("%2d: %-15s@ %4d  to  %2d: %-15s@ %4d\n", temp5->origin_station, stations[temp5->origin_station], start_time_temp, temp5->dest_station, stations[temp5->dest_station], end_time_temp);
        }
        if(emptyTester == 0)
        {
            printf("No available routes after specified time\n");
        }
    }
    printf("\n");
}

int find_station_number(int num_stations, char stations[][MAX_STATION_LENGTH], char search_str[MAX_STATION_LENGTH])
{
    int match = -1;
    int i;

    for(i = 0; i < num_stations; ++i)
    {
        if(strcmp(search_str, stations[i]) == 0)
        {
            match = i;
            i = num_stations;
        }
    }
    return match;
}

void find_station_name(char stations[][MAX_STATION_LENGTH], int station_num, char station_name[MAX_STATION_LENGTH])
{
    int i = station_num;
    char reset_station_name[25];
    if(strcmp(stations[i+1], reset_station_name) == 0)
    {
        printf("Station does not exist\n");
    }
    else
    {
        strcpy(station_name, stations[i]);
        printf("Station %d is %s\n", station_num, station_name);
    }
}

int convert_to_24(int minute_time)
{
    int hourTime = 0;
    
    while(minute_time != 0)
    {
        if(minute_time - 60 == 0)
        {
            hourTime = hourTime + 100;
            minute_time = 0;
        }
        else if(minute_time - 60 < 0)
        {
            hourTime = hourTime + minute_time;
            minute_time = 0;
        }
        else
        {
            hourTime = hourTime + 100;
            minute_time = minute_time - 60;
        }
    }
    return hourTime;
}

int convert_from_24(int time_24)
{
    int minute_time = 0;

    while(time_24 != 0)
    {
        if(time_24 - 100 == 0)
        {
            minute_time = minute_time + 60;
            time_24 = 0;
        }
        else if(time_24 - 100 < 0)
        {
            minute_time = minute_time + time_24;
            time_24 = 0;
        }
        else
        {
            minute_time = minute_time + 60;
            time_24 = time_24 - 100;
        }
    }
    return minute_time;
}

int line_count(FILE *file)
{
    rewind(file);
    int lines = 1;
    char k;

    for(k = getc(file); k != EOF; k = getc(file))
    {
        if(k == '\n')
        {
            ++lines;
        }
    }
rewind(file);

return lines;
}