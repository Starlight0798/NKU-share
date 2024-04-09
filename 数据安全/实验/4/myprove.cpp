#include <libsnark/common/default_types/r1cs_gg_ppzksnark_pp.hpp>
#include <libsnark/zk_proof_systems/ppzksnark/r1cs_gg_ppzksnark/r1cs_gg_ppzksnark.hpp>
#include <fstream>
#include <cmath>
#include "common.hpp"
using namespace libsnark;
using namespace std;
int main()
{
    // 为私密输入提供具体数值
    double t = (5-primary_input)/2.;
    double delta = sqrt(t*t+1/27.);
    double res = pow(-t+delta,1/3.)-pow(t+delta,1/3.);
    int x = round(res);
    int secret[5];
    secret[0] = primary_input;
    secret[1] = x;
    secret[2] = x*x;
    secret[3] = x*x*x;
    secret[4] = x*x*x+x;
    // 构造面包板
    protoboard<FieldT> pb = build_protoboard(secret);
    const r1cs_constraint_system<FieldT> constraint_system = pb.get_constraint_system();
    cout << "公有输入：" << pb.primary_input() << endl;
    cout << "私密输入：" << pb.auxiliary_input() << endl;
    // 加载证明密钥
    fstream f_pk("pk.raw", ios_base::in);
    r1cs_gg_ppzksnark_proving_key<libff::default_ec_pp> pk;
    f_pk >> pk;
    f_pk.close();
    // 生成证明
    const r1cs_gg_ppzksnark_proof<default_r1cs_gg_ppzksnark_pp> proof = 
        r1cs_gg_ppzksnark_prover<default_r1cs_gg_ppzksnark_pp>(
            pk, pb.primary_input(), pb.auxiliary_input());
    // 将生成的证明保存到 proof.raw 文件
    fstream pr("proof.raw", ios_base::out);
    pr << proof;
    pr.close();
    cout << pb.primary_input() << endl;
    cout << pb.auxiliary_input() << endl;
    return 0;
}
