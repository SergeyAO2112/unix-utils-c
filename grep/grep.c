#include <ctype.h>
#include <stdio.h>
#include <string.h>

#define MAX_LINE 4096
#define MAX_PATTERNS 128

typedef struct {
  int n;
  int v;
  int i;
  int c;
  int l;
} Options;

void init_options(Options* opt) {
  if (opt != NULL) {
    opt->n = 0;
    opt->v = 0;
    opt->i = 0;
    opt->c = 0;
    opt->l = 0;
  }
}

int parse_options(int argc, char** argv, Options* opt, char* patterns[],
                  int* patterns_count, int* first_file_index) {
  int status = 0;
  int i = 1;

  if (argc < 3) {
    status = 1;
  }

  while (!status && i < argc && argv[i][0] == '-' && argv[i][1] != '\0') {
    if (strcmp(argv[i], "-n") == 0) {
      opt->n = 1;
    } else if (strcmp(argv[i], "-v") == 0) {
      opt->v = 1;
    } else if (strcmp(argv[i], "-i") == 0) {
      opt->i = 1;
    } else if (strcmp(argv[i], "-c") == 0) {
      opt->c = 1;
    } else if (strcmp(argv[i], "-l") == 0) {
      opt->l = 1;
    } else if (strcmp(argv[i], "-e") == 0) {
      i++;
      if (i >= argc) {
        status = 1;
      } else if (*patterns_count >= MAX_PATTERNS) {
        status = 1;
      } else {
        patterns[*patterns_count] = argv[i];
        (*patterns_count)++;
      }
    } else {
      status = 1;
    }
    i++;
  }

  if (!status && *patterns_count == 0) {
    if (i >= argc - 1) {
      status = 1;
    } else if (*patterns_count >= MAX_PATTERNS) {
      status = 1;
    } else {
      patterns[*patterns_count] = argv[i];
      (*patterns_count)++;
      i++;
    }
  }

  if (!status && i >= argc) {
    status = 1;
  }

  if (!status && first_file_index != NULL) {
    *first_file_index = i;
  }

  return status;
}

void prepare_patterns_lower(char* patterns[], char patterns_lower[][MAX_LINE],
                            int patterns_count) {
  for (int p = 0; p < patterns_count; p++) {
    int k = 0;
    while (patterns[p][k] != '\0' && k < MAX_LINE - 1) {
      patterns_lower[p][k] = (char)tolower((unsigned char)patterns[p][k]);
      k++;
    }
    patterns_lower[p][k] = '\0';
  }
}

int match_line(const char* line, const Options* opt, char* patterns[],
               char patterns_lower[][MAX_LINE], int patterns_count) {
  int matched = 0;

  if (opt->i) {
    char line_lower[MAX_LINE];
    int k = 0;

    while (line[k] != '\0' && k < MAX_LINE - 1) {
      line_lower[k] = (char)tolower((unsigned char)line[k]);
      k++;
    }
    line_lower[k] = '\0';

    for (int p = 0; p < patterns_count && !matched; p++) {
      if (strstr(line_lower, patterns_lower[p]) != NULL) {
        matched = 1;
      }
    }
  } else {
    for (int p = 0; p < patterns_count && !matched; p++) {
      if (strstr(line, patterns[p]) != NULL) {
        matched = 1;
      }
    }
  }

  return matched;
}

int process_file(const char* filename, const Options* opt, char* patterns[],
                 char patterns_lower[][MAX_LINE], int patterns_count,
                 int multi_file) {
  int status = 0;
  FILE* f = fopen(filename, "r");

  if (f == NULL) {
    status = 1;
  } else {
    char line[MAX_LINE];
    int line_no = 1;
    int count = 0;
    int file_has_match = 0;

    while (fgets(line, sizeof(line), f) != NULL) {
      int matched =
          match_line(line, opt, patterns, patterns_lower, patterns_count);

      int need_print = opt->v ? !matched : matched;

      if (need_print) {
        if (opt->l) {
          file_has_match = 1;
          break;
        } else if (opt->c) {
          count++;
        } else {
          if (multi_file) {
            if (opt->n) {
              printf("%s:%d:", filename, line_no);
            } else {
              printf("%s:", filename);
            }
          } else {
            if (opt->n) {
              printf("%d:", line_no);
            }
          }

          printf("%s", line);

          size_t len = strlen(line);
          if (len == 0 || line[len - 1] != '\n') {
            putchar('\n');
          }
        }
      }

      line_no++;
    }

    if (opt->l) {
      if (file_has_match) {
        printf("%s\n", filename);
      }
    } else if (opt->c) {
      if (multi_file) {
        printf("%s:%d\n", filename, count);
      } else {
        printf("%d\n", count);
      }
    }

    fclose(f);
  }

  return status;
}

int main(int argc, char** argv) {
  int status = 0;
  Options opt;
  char* patterns[MAX_PATTERNS];
  char patterns_lower[MAX_PATTERNS][MAX_LINE];
  int patterns_count = 0;
  int first_file = 0;

  init_options(&opt);

  if (!status) {
    status =
        parse_options(argc, argv, &opt, patterns, &patterns_count, &first_file);
  }

  if (!status && opt.i) {
    prepare_patterns_lower(patterns, patterns_lower, patterns_count);
  }

  if (!status) {
    int multi_file = (argc - first_file > 1) ? 1 : 0;

    for (int file_index = first_file; file_index < argc; file_index++) {
      int file_status =
          process_file(argv[file_index], &opt, patterns, patterns_lower,
                       patterns_count, multi_file);
      if (file_status != 0) {
        status = 1;
      }
    }
  }

  return status;
}
