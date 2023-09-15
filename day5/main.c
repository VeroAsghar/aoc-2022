#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

#define LENGTH 100
#define INST_LENGTH 512
#define START_ROW 50

char grid[LENGTH*LENGTH];

void move(char *grid, int start_row, int start_column, int end_row, int end_column) {
    grid[end_column+LENGTH*end_row] = grid[start_column+LENGTH*start_row];
    //printf("%c", grid[start_column+LENGTH*start_row]);
    grid[start_column+LENGTH*start_row] = ' ';
}

int findTopOfStack(char *grid, int column) {
    for (int i = 0; i < LENGTH; ++i) {
        if (isalpha(grid[column+LENGTH*i])) {
            return i;
        } else if (isdigit(grid[column+LENGTH*i])) {
            return i;
        }
    }
    return -1;
}

typedef struct {
    int amnt;
    int from;
    int to;
} Instruction;

Instruction parseInstruction(char *str) {
    int amnt, from, to;
    char *ch = strtok(str, "movefrmt ");
    size_t pos = strlen(ch);
    amnt = atoi(&ch[pos-2]);;
    ch = strtok(NULL, "movefrmt ");
    pos = strlen(ch);
    from = atoi(&ch[pos-2]);;
    ch = strtok(NULL, "movefrmt ");
    pos = strlen(ch);
    to = atoi(&ch[pos-2]);;
    Instruction inst = {.amnt=amnt, .from=from, .to=to};
    return inst;

}

Instruction inst_grid[INST_LENGTH];

int main(void) {
    for (int i = 0; i < LENGTH*LENGTH; ++i) {
        grid[i] = ' ';
    }
    FILE * input = fopen("input.in", "r");
    char buf[5];

    int row = START_ROW;
    int column = 1;
    while (!feof(input) && (fgets(buf, 5, input) != NULL)) {
        grid[column+LENGTH*row] = buf[1];
        ++column;
        if (buf[3] == '\n') {
            ++row;
            column = 1;
        }
        if (buf[0] == '\n') {
            column = 1;
            break;
        }
    }
    char buffer[23];
    int i = 0;
    while (!feof(input) && (fgets(buffer, 23, input) != NULL)) {
        inst_grid[i] = parseInstruction(buffer);
        ++i;
    }
    /*
    for (int i = 0; i < LENGTH; ++i) {
        for (int j = 0; j < LENGTH; ++j) {
            printf("%c", grid[j + LENGTH*i]);
        }
        printf("\n");
    }
    */

    row = START_ROW;


    for (int i = 0; i < INST_LENGTH; ++i) {
        if (inst_grid[i].amnt == 0) {
            break;
        }
        //printf("%d %d %d\n", inst_grid[i].amnt, inst_grid[i].from, inst_grid[i].to);

        int start_row = findTopOfStack(grid, inst_grid[i].from);
        int end_row = findTopOfStack(grid, inst_grid[i].to);

        for (int boxes = 0; boxes < inst_grid[i].amnt; ++boxes) {
            move(grid, start_row+boxes, inst_grid[i].from, end_row+boxes-inst_grid[i].amnt, inst_grid[i].to);
        }
        //printf("\n");

    }

    for (int i = 0; i < LENGTH; ++i) {
        for (int j = 0; j < LENGTH; ++j) {
            printf("%c", grid[j + LENGTH*i]);
        }
        printf("\n");
    }


        /*
    for (int i = 0; i < INST_LENGTH; ++i) {
        printf("%d %d %d\n", inst_grid[i].amnt, inst_grid[i].from, inst_grid[i].to);
    }
        */
    return 0;
}
