#include <libsnark/common/default_types/r1cs_gg_ppzksnark_pp.hpp>
#include <libsnark/zk_proof_systems/ppzksnark/r1cs_gg_ppzksnark/r1cs_gg_ppzksnark.hpp>
#include <fstream>
#include "common.hpp"
using namespace libsnark;
using namespace std;
int main()
{
    // 构造面包板
    protoboard<FieldT> pb = build_protoboard(NULL);
    const r1cs_constraint_system<FieldT> constraint_system = pb.get_constraint_system();
    // 生成证明密钥和验证密钥
    const r1cs_gg_ppzksnark_keypair<default_r1cs_gg_ppzksnark_pp> keypair = 
        r1cs_gg_ppzksnark_generator<default_r1cs_gg_ppzksnark_pp>(constraint_system);
    // 保存证明密钥到文件 pk.raw
    fstream pk("pk.raw", ios_base::out);
    pk << keypair.pk;
    pk.close();
    // 保存验证密钥到文件 vk.raw
    fstream vk("vk.raw", ios_base::out);
    vk << keypair.vk;
    vk.close();
    return 0;
}
