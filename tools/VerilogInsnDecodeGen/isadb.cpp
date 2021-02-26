/**@file
 * @brief     DB-like structured ISA info.
 * @author    Igor Lesik 2021
 * @copyright Igor Lesik 2021
 */
#include "isadb.h"

#include <fstream>
#include <sstream>


bool isa::Db::read_src_files(const std::string& path)
{
    std::string insn_file = path + "/csv/common_inst.csv";

    if (!read_src_insn_file(insn_file)) {
        return false;
    }

    return true;
}

bool isa::Db::read_src_file(
    const std::string& path,
    isa::Db::PtrLineProcessor processor
)
{
    std::ifstream file;

    file.open(path);

    if (!file.is_open()) {
        fprintf(stderr, "Error: can't open %s\n", path.c_str());
        return false;
    }

    uint32_t line_num{0};
    char line[128];

    // Skip header
    file.getline(line, sizeof(line));
    ++line_num;

    while (!file.eof()) {
        file.getline(line, sizeof(line));
        if (!(this->*processor)(isa::Db::split(line))) {
            fprintf(stderr, "Error: can't process file:%s line num:%u str:%s\n",
                path.c_str(), line_num, line);
            file.close();
            return false;
        }
        ++line_num;
    }

    file.close();

    return true;
}

bool isa::Db::process_insn_file_line(const isa::Db::VectorStr& tokens)
{
    if (tokens.empty() or tokens.size() < 2 or tokens[1].empty()) return true;

    isa::Insn insn;
    insn.id = nr_insns_;
    insn.name = tokens[1];
    insn.grpname = tokens[0];

    //fprintf(stdout, "Insn name:%s\n", insn.name.c_str());

    insns_.push_back(insn);
    ++nr_insns_;

    return true;
}

isa::Db::VectorStr isa::Db::split(const std::string& s, char delimiter)
{
    std::vector<std::string> tokens;
    std::string token;
    std::istringstream token_stream(s);

    while (std::getline(token_stream, token, delimiter))
    {
        tokens.push_back(token);
    }
    return tokens;
}