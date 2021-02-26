/**@file
 * @brief     DB-like structured ISA info.
 * @author    Igor Lesik 2021
 * @copyright Igor Lesik 2021
 */
#pragma once

#include <string>
#include <vector>
#include <cstdint>

namespace isa {

struct Insn
{
    uint32_t id;
    std::string name;
    std::string grpname;
    std::string unit;
    std::string signature;
    std::string ximm;
};

class Db
{
    using VectorStr = std::vector<std::string>;
    using Insns = std::vector<Insn>;

    uint32_t nr_insns_ = 0;
    Insns insns_;

public:

    bool read_src_files(const std::string& path);

private:
    static VectorStr split(const std::string& s, char delimiter=',');

    using PtrLineProcessor = bool (Db::*)(const VectorStr&);
    bool read_src_file(const std::string& path, PtrLineProcessor processor);

    bool process_insn_file_line(const VectorStr& tokens);
    bool read_src_insn_file(const std::string& path) {
        return read_src_file(path, &Db::process_insn_file_line);
    }
};



}