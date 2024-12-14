
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>

#define BUFFER_SIZE 1000
#define CHAR_OCTET 1

char	*get_next_line(int fd);
char	*fill_line_buffer(int fd, char *left_c, char *buffer);
char	*set_line(char *line_buffer);
char	*ft_realloc(char *ptr, size_t size);
char    *free_static_buffer(char *overread);

char	*ft_strchr(char *s, int c);
char	*ft_strdup(char *s);
char	*ft_substr(char *s, unsigned int start, size_t len);
char	*ft_strjoin(char *s1, char *s2);
size_t	ft_strlen(char *string);


int *parse_string(char *string, int *count)
{
    int index;
    int number;
    int *numbers;

    index = 0;
    *count = 1;
    number = 0;
    numbers = (int *)malloc(sizeof(int));
    while (string[index] != '\0')
    {
        if (string[index] == ',')
        {
            numbers[(*count) - 1] = number;
            (*count) =+ 1;
            number = 0;
            numbers = realloc(numbers, (*count));
        }
        else if (isalpha(string[index]))
            number = number * 10 + string[index] - '0';
        index++;
    }
    return (numbers);
}
//This function read all the content of the fd and returns a string.
char    *read_fd(int fd)
{
    char    *temp;
    char    *line;
    char    *joined;

    joined = NULL;
    line = get_next_line(fd);
    while (line != NULL)
    {
        temp = joined;
        joined = ft_strjoin(joined, line);
        if (temp)
        {
            free (temp);
            temp = NULL;
        }
        free(line);
        line = NULL;
        line = get_next_line(fd);
    }
    return (line);
}
//This program tkaes a filename as paraemeter. The file should contain
//the Leetcode input you're trying to parse.
//The file should be in the current directory and at least have 
//O_RDONLY permission.
int main(int argc, char **argv)
{
    int     fd;
    int     count;
    int     index;
    char    *fd_content;
    int     *parsed_input;

    index = 0;
    if (argc == 2)
    {
        fd = open(argv[1], O_RDONLY);
        if (fd)
        {
            fd_content = read_fd(fd);
            close (fd);
            parsed_input = parse_string(fd_content, &count);
            free(fd_content);
            while (index < count)
            {
                printf("%d\n", parsed_input[index]);
                index++;
            }
            free(parsed_input);
            return (0);
        }
        return (-1);
    }
    return (-1);
}
