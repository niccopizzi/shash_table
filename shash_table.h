#ifndef SHASH_TABLE_H
#define SHASH_TABLE_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#define HASH_INITIAL_CAPACITY 10000

typedef struct 
{
    char**      table;
    uint64_t    (*hashing_func)(char *);
    size_t      capacity;
    size_t      size;
} hash_table;

extern __attribute__((sysv_abi)) 
uint64_t default_hash_func(char* key);

extern __attribute__((sysv_abi))
void shash_table_insert(hash_table* ht, char* key, char* value);

extern __attribute__((sysv_abi))
char* shash_table_find(hash_table* ht, char* key);

extern __attribute__((sysv_abi))
bool shash_table_init(hash_table* ht, uint64_t (*hash_func) (char *), 
                        size_t capacity);

extern __attribute__((sysv_abi))
void shash_table_clear(hash_table* ht);
#endif

