#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned long long ull;

typedef struct {
  void* data;
  size_t len;
  size_t cap;
  size_t esize;
} Vec;

void Vec_init(Vec *v, size_t esize) {
  // Initial capacity of 32
  v->cap = 32;
  v->len = 0;
  v->esize = esize;
  v->data = malloc(v->cap * v->esize);
}

void *Vec_free(Vec* v) {
  free(v->data);
  v->data = NULL;
}

void Vec_push(Vec *v, const void *data) {
  if (v->len + 1 >= v->cap) {
    v->cap *= 2;
    v->data = realloc(v->data, v->cap * v->esize);
  }

  unsigned char *base = (unsigned char *)v->data;
  void *dest = base + v->len * v->esize;
  memcpy(dest, data, v->esize);
  v->len++;
}

void *Vec_at(Vec *v, size_t idx) {
  unsigned char *base = (unsigned char *)v->data;
  return (void *)(base + idx * v->esize);
}

void Vec_sort(Vec *v, int (*cmp)(const void *, const void *)) {
  qsort(v->data, v->len, v->esize, cmp);
}

typedef struct {
  ull lo;
  ull hi;
} IDRange;

int cmpIDRange(const void *a, const void *b) {
  IDRange *r1 = (IDRange *)a;
  IDRange *r2 = (IDRange *)b;
  if (r1->lo < r2->lo) {
    return -1;
  } else if (r1->lo == r2->lo) {
    return r1->hi - r2->hi;
  } else {
    return 1;
  }
}

bool contains(Vec *ranges, ull n) {
  for (size_t i = 0; i < ranges->len; ++i) {
    IDRange *r = (IDRange *)Vec_at(ranges, i);
    if (n >= r->lo && n <= r->hi) {
      return true;
    }
  }
  return false;
}

int main(int argc, char **argv) {
  Vec fresh, available, merged;
  Vec_init(&fresh, sizeof(IDRange));
  Vec_init(&merged, sizeof(IDRange));
  Vec_init(&available, sizeof(ull));

  bool inFresh = true;
  char *line = NULL;
  size_t size;
  while (getline(&line, &size, stdin) != -1) {
    if (strcmp(line, "\n") == 0) {
      inFresh = false;
      continue;
    }

    if (inFresh) {
      ull lo, hi;
      sscanf(line, "%llu-%llu\n", &lo, &hi);
      // Vec uses memcpy so this is okay
      IDRange r = {lo, hi};
      Vec_push(&fresh, &r);
    } else {
      ull id;
      sscanf(line, "%llu\n", &id);
      Vec_push(&available, &id);
    }
  }

  Vec_sort(&fresh, cmpIDRange);
  IDRange *first = (IDRange *)Vec_at(&fresh, 0);
  ull lo = first->lo;
  ull hi = first->hi;
  for (size_t i = 1; i < fresh.len; ++i) {
    IDRange *r = (IDRange *)Vec_at(&fresh, i);
    // Should merge
    if (r->lo <= hi) {
      hi = hi >= r->hi ? hi : r->hi;
    } else {
      IDRange next = {lo, hi};
      Vec_push(&merged, &next);
      lo = r->lo;
      hi = r->hi;
    }
  }
  // Add the final interval
  IDRange final = {lo, hi};
  Vec_push(&merged, &final);

  ull part1 = 0;
  for (size_t i = 0; i < available.len; ++i) {
    ull n = *(ull *)Vec_at(&available, i);
    if (contains(&merged, n)) {
      ++part1;
    }
  }
  printf("%llu\n", part1);

  ull part2 = 0;
  for (size_t i = 0; i < merged.len; ++i) {
    IDRange *r = (IDRange *)Vec_at(&merged, i);
    part2 += r->hi - r->lo + 1;
  }
  printf("%llu\n", part2);

  Vec_free(&fresh);
  Vec_free(&available);
  Vec_free(&merged);
  return 0;
}
