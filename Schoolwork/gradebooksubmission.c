#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NAME_LENGTH 10

void getGrades(FILE *ifp, int assigns, int stus, int grades[assigns][stus]);
void printGrades(int assigns, int stus, int grades[assigns][stus]);
void getStudents(FILE *ifp, int stus, char students[stus][NAME_LENGTH]);
void printStudents(int stus, char students[stus][NAME_LENGTH]);
void calcGrades(int assigns, int stus, int grades[assigns][stus], double final_grades[]);
void printFinalLetterGrades(int stus, double final_grades[]);
void printPercentageGrades(int stus, char students[stus][NAME_LENGTH], double final_grades[]);

int main(int argc, char *argv[])
{
	FILE *ifp = NULL;
	int assigns, stus;

	ifp = fopen(argv[1], "r");

	if(argc != 2)											// Error Checking
	{
		printf("Syntax Error: <exec> <file.txt>\n");
		exit(1);
	}

	if(ifp == NULL)											//Error Checking
	{
		printf("Error: file failed to open properly. Exiting.\n");
		exit(1);
	}

	fscanf(ifp, "%d", &assigns);
	fscanf(ifp, "%d", &stus);

	char students[stus][NAME_LENGTH];
	int grades[assigns][stus];
	double final_grades[stus];

	getStudents(ifp, stus, students);
	printStudents(stus, students);
	getGrades(ifp, assigns, stus, grades);
	printGrades(assigns, stus, grades);
	calcGrades(assigns, stus, grades, final_grades);
	printFinalLetterGrades(stus, final_grades);
	printPercentageGrades(stus, students, final_grades);

	fclose(ifp);

	return 0;
}

void getGrades(FILE *ifp, int assigns, int stus, int grades[assigns][stus])
{
	int i, j;

	for(j = 0; j < assigns; j++)
	{
		for(i = 0; i < stus; i++)
		{
			fscanf(ifp, "%d", &grades[j][i]);
		}
	}
}

void printGrades(int assigns, int stus, int grades[assigns][stus])
{
	int i, j;

	for(i = 0; i < assigns; i++)
	{
		for(j = 0; j < stus; j++)
		{
			printf("%10d", grades[i][j]);
		}
		printf("\n");
	}
}

void getStudents(FILE *ifp, int stus, char students[stus][NAME_LENGTH])
{
	int i;
	for(i = 0; i < stus; i++)
	{
		fscanf(ifp, "%s", students[i]);
	}
}

void printStudents(int stus, char students[stus][NAME_LENGTH])
{
	int i;
	for(i = 0; i < stus; i++)
	{
		printf("%10s", students[i]);
	}
	printf("\n\n");
}

void calcGrades(int assigns, int stus, int grades[assigns][stus], double final_grades[])
{
	int i, j;
	double sum;
	double avg;

	for(i = 0; i < stus; i++)
	{
		sum = 0;
		avg = 0;
		for(j = 0; j < assigns; j++)
		{
			sum = sum + (grades[j][i]);
		}

		avg = sum / (assigns);

		final_grades[i] = avg;
	}
}

void printFinalLetterGrades(int stus, double final_grades[])
{
	int i;

	for(i = 0; i < stus; i++)
	{
		if(final_grades[i] >= 90)
		{
			printf("         A");
		}
		else if(final_grades[i] >= 80)
		{
			printf("         B");
		}
		else if (final_grades[i] >= 70)
		{
			printf("         C");
		}
		else if(final_grades[i] >= 60)
		{
			printf("         D");
		}
		else
			printf("         F");
	}
	printf("\n\n\n\n");
}

void printPercentageGrades(int stus, char students[stus][NAME_LENGTH], double final_grades[])
{
	int i;

	for(i = 0; i < stus; i++)
	{
		printf("%10s : %.2f %%\n", students[i], final_grades[i]);
	}
}