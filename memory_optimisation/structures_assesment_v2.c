#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_MEMBERS 100
#define TERMINAL_WIDTH 80

typedef struct {
    char type[50];
    char name[50];
    size_t size;
} StructMember;

typedef struct {
    char name[50];
    StructMember members[MAX_MEMBERS];
    size_t member_count;
    size_t total_size;
    size_t padding;
} StructInfo;

size_t get_size_of_type(const char *type) {
    if (strcmp(type, "char") == 0) return sizeof(char);
    if (strcmp(type, "unsigned char") == 0) return sizeof(unsigned char);
    if (strcmp(type, "short") == 0) return sizeof(short);
    if (strcmp(type, "unsigned short") == 0) return sizeof(unsigned short);
    if (strcmp(type, "int") == 0) return sizeof(int);
    if (strcmp(type, "unsigned int") == 0) return sizeof(unsigned int);
    if (strcmp(type, "long") == 0) return sizeof(long);
    if (strcmp(type, "unsigned long") == 0) return sizeof(unsigned long);
    if (strcmp(type, "long long") == 0) return sizeof(long long);
    if (strcmp(type, "unsigned long long") == 0) return sizeof(unsigned long long);
    if (strcmp(type, "size_t") == 0) return sizeof(size_t);
    if (strcmp(type, "float") == 0) return sizeof(float);
    if (strcmp(type, "double") == 0) return sizeof(double);
    if (strcmp(type, "long double") == 0) return sizeof(long double);
    if (strcmp(type, "_Bool") == 0) return sizeof(_Bool);
    return 0;
}

void calculate_structure_size(StructInfo *s) 
{
    size_t current_offset = 0;
    s->total_size = 0;
    s->padding = 0;

    for (size_t i = 0; i < s->member_count; i++) 
    {
        StructMember *m = &s->members[i];
        size_t alignment = m->size;
        size_t padding = (alignment - (current_offset % alignment)) % alignment;

        current_offset += padding;  // Add padding for alignment
        current_offset += m->size; // Add member size
    }

    s->total_size = current_offset;
    size_t alignment = sizeof(void *); // Assume alignment to the largest natural size
    size_t padding = (alignment - (current_offset % alignment)) % alignment;

    s->padding = padding;
    s->total_size += padding; // Include final padding
}

void print_structure(const StructInfo *s, const char *title) 
{
    printf("\n%s:\n", title);
    printf("struct %s {\n", s->name);

    // Calculate alignment for centered comments
    int max_width = 0;
    for (size_t i = 0; i < s->member_count; i++) 
    {
        size_t width = strlen(s->members[i].type) + strlen(s->members[i].name) + 2; // type + name + ";"
        if (width > max_width) max_width = width;
    }
        for (size_t i = 0; i < s->member_count; i++) 
        {
        const StructMember *m = &s->members[i];
        printf("  %-10s %s;", m->type, m->name);
        printf("    // size =   %zu bytes\n", m->size);
        }
    printf("};\n");
    printf("Total size = %zu bytes, with %zu bytes of padding.\n", s->total_size, s->padding);
}

int compare_member_size(const void *a, const void *b) 
{
    const StructMember *m1 = (const StructMember *)a;
    const StructMember *m2 = (const StructMember *)b;
    // Tri descendant : du plus grand au plus petit
    return (m2->size - m1->size);
}

void print_optimized_structure(StructInfo *s) 
{
    // Réorganise les membres en fonction de leur taille
    qsort(s->members, s->member_count, sizeof(StructMember), compare_member_size);
    // Recalcule la taille et le padding
    calculate_structure_size(s);
    print_structure(s, "Optimized Structure");
}

void analyze_file(const char *filename) 
{
    FILE *file = fopen(filename, "r");
    if (!file)
        return (perror("Error opening file"));
    char line[256];
    StructInfo structures[MAX_MEMBERS];
    size_t struct_count = 0;
    StructInfo *current_struct = NULL;
    int inside_struct = 0; // Flag to track if we're inside a struct

    while (fgets(line, sizeof(line), file)) 
    {
        char *token = strtok(line, " \t\n");

        if (!token) continue;
        if (strcmp(token, "typedef") == 0 || strcmp(token, "struct") == 0) 
        {
            if (strcmp(token, "typedef") == 0) 
            {
                token = strtok(NULL, " \t\n");
                if (token && strcmp(token, "struct") != 0) continue;
                token = strtok(NULL, " \t\n");
            } 
            else
                token = strtok(NULL, " \t\n");
            if (token && strcmp(token, "{") != 0) 
            {
                current_struct = &structures[struct_count++];
                strcpy(current_struct->name, token);
                current_struct->member_count = 0;
                inside_struct = 1;
            }
        } 
        else if (inside_struct && strcmp(token, "}") == 0) 
        {
            inside_struct = 0;
            token = strtok(NULL, " \t\n");
            if (token && current_struct)
                strcpy(current_struct->name, token);
            current_struct = NULL;
        } 
        else if (inside_struct && current_struct) 
        {
            char type[50], name[50];
            strcpy(type, token);
            token = strtok(NULL, " ;\t\n");
            if (token) {

                strcpy(name, token);
                StructMember *member = &current_struct->members[current_struct->member_count++];
                strcpy(member->type, type);
                strcpy(member->name, name);
                member->size = get_size_of_type(type);
            }
        }
    }
    fclose(file);
    printf("Structures found in %s:\n", filename);
    for (size_t i = 0; i < struct_count; i++) 
    {
        StructInfo *s = &structures[i];
        calculate_structure_size(s);
        print_structure(s, "Original Structure");
        if (s->padding > 0) 
            print_optimized_structure(s);
    }
}

int main(int argc, char **argv) 
{
    if (argc == 2) 
    {
        analyze_file(argv[1]);
        return (0);
    }
    return(fprintf(stderr, "Usage: %s <filename>\n", argv[0]));
}
