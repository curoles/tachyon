#include <cstdlib>
#include <cstdio>
#include <string>

#include "isadb.h"

int main(int argc, char* argv[])
{
    if (argc < 3) {
        fprintf(stderr, "Error: too few arguments.\nUsage: executable path-to-isa ouput-file\n\n");
        return EXIT_FAILURE;
    }

    std::string isa_path(argv[1]);
    std::string outfile_path(argv[1]);

    isa::Db db;
    if (!db.read_src_files(isa_path)) {
        fprintf(stderr, "Error: could not read and process ISA files.\n");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}