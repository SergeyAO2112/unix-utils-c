#include <stdio.h>
#include <string.h>

typedef struct {
  int n;
  int b;
  int s;
  int e;
  int t;
  int v;
} Options;

void init_options(Options* opt) {
  opt->n = 0;
  opt->b = 0;
  opt->s = 0;
  opt->e = 0;
  opt->t = 0;
  opt->v = 0;
}

void print_char(int c, const Options* opt) {
  unsigned char uc = (unsigned char)c;

  if (c == '\n') {
    if (opt->e) {
      putchar('$');
    }
    putchar('\n');
  } else if (c == '\t' && opt->t) {
    putchar('^');
    putchar('I');
  } else if (opt->v && uc < 32 && uc != '\n' && uc != '\t') {
    putchar('^');
    putchar(uc + '@');
  } else if (opt->v && uc == 127) {
    putchar('^');
    putchar('?');
  } else {
    putchar(c);
  }
}

int parse_options(int argc, char** argv, Options* opt) {
  int i = 1;

  while (i < argc && argv[i][0] == '-' && argv[i][1] != '\0') {
    if (strcmp(argv[i], "-n") == 0 || strcmp(argv[i], "--number") == 0) {
      opt->n = 1;
    } else if (strcmp(argv[i], "-b") == 0 ||
               strcmp(argv[i], "--number-nonblank") == 0) {
      opt->b = 1;
    } else if (strcmp(argv[i], "-s") == 0 ||
               strcmp(argv[i], "--squeeze-blank") == 0) {
      opt->s = 1;
    } else if (strcmp(argv[i], "-e") == 0) {
      opt->e = 1;
      opt->v = 1;
    } else if (strcmp(argv[i], "-E") == 0) {
      opt->e = 1;
    } else if (strcmp(argv[i], "-t") == 0) {
      opt->t = 1;
      opt->v = 1;
    } else if (strcmp(argv[i], "-T") == 0) {
      opt->t = 1;
    } else if (strcmp(argv[i], "-v") == 0) {
      opt->v = 1;
    } else {
      fprintf(stderr, "s21_cat: illegal option %s\n", argv[i]);
      return -1;
    }
    i++;
  }

  return i;
}

void process_file(const char* filename, const Options* opt, int* line_no,
                  int* at_line_start) {
  FILE* f = fopen(filename, "r");
  if (f == NULL) {
    fprintf(stderr, "s21_cat: cannot open %s\n", filename);
    return;
  }

  int c;
  int prev_was_blank = 0;

  while ((c = fgetc(f)) != EOF) {
    if (*at_line_start && opt->s && c == '\n') {
      if (prev_was_blank) {
        continue;
      } else {
        prev_was_blank = 1;
      }
    } else if (*at_line_start && c != '\n') {
      prev_was_blank = 0;
    }

    if (*at_line_start) {
      int need_number = 0;
      if (opt->b) {
        if (c != '\n') {
          need_number = 1;
        }
      } else if (opt->n) {
        need_number = 1;
      }

      if (need_number) {
        printf("%6d\t", *line_no);
        (*line_no)++;
      }

      *at_line_start = 0;
    }

    print_char(c, opt);

    if (c == '\n') {
      *at_line_start = 1;
    }
  }

  fclose(f);
}

int main(int argc, char** argv) {
  int status = 0;
  Options opt;
  init_options(&opt);

  int first_file = parse_options(argc, argv, &opt);

  if (first_file == -1) {
    status = 1;
  } else if (first_file >= argc) {
    fprintf(stderr, "s21_cat: no input files\n");
    status = 1;
  } else {
    int line_no = 1;
    int at_line_start = 1;
    for (int i = first_file; i < argc; i++) {
      process_file(argv[i], &opt, &line_no, &at_line_start);
    }
  }

  return status;
}