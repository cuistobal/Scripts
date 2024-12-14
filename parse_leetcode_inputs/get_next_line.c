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

char	*ft_strchr(char *s, int c);
char	*ft_strdup(char *s);
char	*ft_substr(char *s, unsigned int start, size_t len);
char	*ft_strjoin(char *s1, char *s2);
size_t	ft_strlen(char *string);

char    *free_static_buffer(char *overread)
{
	if (overread) 
    {
		free(overread);
		overread = NULL;
	}
    return (NULL);
}
//Cette fonction doit recuperer le buffer et le separer entre la ligne renvoyee
//et le trop lu dans la statique.
char	*set_line(char *line)
{
	char	*overread;
	int		i;

	i = 0;
	while (line[i] != '\0' && line[i] != '\n')
		i++;
	if (line[i] == '\0' || line[1] == '\0')
		return (NULL);
	overread = ft_substr(line, i + 1, ft_strlen(line) - i);
	if (*overread == '\0')
	{
		free (overread);
		return (NULL);
	}
	line[i + 1] = '\0';
	return (overread);
}
//Cette fonction lis le fichier jusqu'a trouver un '\n' dans le buffer.
char	*fill_line_buffer(int fd, char *overread, char *buffer)
{
	ssize_t	read_file;
	char	*temp;

	read_file = 1;
	while (read_file > 0)
	{
		read_file = read(fd, buffer, BUFFER_SIZE);
		if (read_file == -1)
		{
			free(overread);
			return (NULL);
		}
		else if (read_file == 0)
			break ;
		if (!overread)
			overread = ft_strdup("");
		buffer[read_file] = '\0';
		temp = overread;
		overread = ft_strjoin(temp, buffer);
		free (temp);
		temp = NULL;
		if (ft_strchr(buffer, '\n'))
			break ;
	}
	return (overread);
}
//Cette fonction fais le parsing, malloc et renvoie les lignes.
char	*get_next_line(int fd)
{
	static char	*overread;
	char		*buffer;
	char		*line;

	buffer = (char *)malloc(sizeof(char) * (BUFFER_SIZE + 1));
	if (!buffer)
		return (NULL);
	if (fd < 0 || BUFFER_SIZE <= 0 || read(fd, 0, 0) < 0)
	{
		free(overread);
		free(buffer);
		overread = NULL;
		buffer = NULL;
		return (NULL);
	}
	line = fill_line_buffer(fd, overread, buffer);
	free (buffer);
	buffer = NULL;
	if (!line)
		return (free_static_buffer(overread));
	overread = set_line(line);
	return (line);
}
