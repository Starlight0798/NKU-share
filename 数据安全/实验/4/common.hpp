// 代码开头引用了三个头文件：第一个头文件是为了引入 default_r1cs_gg_ppzksnark_pp 类型；第二个则为了引入证明相关的各个接口；pb_variable 则是用来定义电    路相关的变量。
#include <libsnark/common/default_types/r1cs_gg_ppzksnark_pp.hpp>
#include <libsnark/zk_proof_systems/ppzksnark/r1cs_gg_ppzksnark/r1cs_gg_ppzksnark.hpp>
#include <libsnark/gadgetlib1/pb_variable.hpp>
using namespace libsnark;
using namespace std;
constexpr auto primary_input = 35;
// 定义使用的有限域
typedef libff::Fr<default_r1cs_gg_ppzksnark_pp> FieldT;
// 定义创建面包板的函数
protoboard<FieldT> build_protoboard(int *secret)
{
    // 初始化曲线参数
    default_r1cs_gg_ppzksnark_pp::init_public_params();
    // 创建面包板
    protoboard<FieldT> pb;
    // 定义所有需要外部输入的变量以及中间变量
    pb_variable<FieldT> x;
    pb_variable<FieldT> sym_1;
    pb_variable<FieldT> y;
    pb_variable<FieldT> sym_2;
    pb_variable<FieldT> out;
    // 下面将各个变量与 protoboard 连接，相当于把各个元器件插到“面包板”上。    allocate() 函数的第二个 string 类型变量仅是用来方便 DEBUG 时的注释，方便 DEBUG 时查看日志。
    out.allocate(pb, "out");
    x.allocate(pb, "x");
    sym_1.allocate(pb, "sym_1");
    y.allocate(pb, "y");
    sym_2.allocate(pb, "sym_2");
    // 定义公有的变量的数量，set_input_sizes(n)用来声明与 protoboard 连接的 public 变量的个数 n。在这里 n = 1，表明与 pb 连接的前 n = 1 个变量是 public 的，其余都是 private 的。因此，要将 public 的变量先与 pb 连接（前面 out 是公开的）。
    pb.set_input_sizes(1);
    // 为公有变量赋值
    pb.val(out) = primary_input;
    // 至此，所有变量都已经顺利与 protoboard 相连，下面需要确定的是这些变量间的约束关系。

    // Add R1CS constraints to protoboard

    // x*x = sym_1
    pb.add_r1cs_constraint(r1cs_constraint<FieldT>(x, x, sym_1));

    // sym_1 * x = y
    pb.add_r1cs_constraint(r1cs_constraint<FieldT>(sym_1, x, y));

    // y + x = sym_2
    pb.add_r1cs_constraint(r1cs_constraint<FieldT>(y + x, 1, sym_2));

    // sym_2 + 5 = ~out
    pb.add_r1cs_constraint(r1cs_constraint<FieldT>(sym_2 + 5, 1, out));
    
    // 证明者在生成证明阶段传入私密输入，为私密变量赋值，其他阶段为 NULL
    if (secret != NULL)
    {
		pb.val(out) = secret[0];

		pb.val(x) = secret[1];
		pb.val(sym_1) = secret[2];
		pb.val(y) = secret[3];
		pb.val(sym_2) = secret[4];
    }
    return pb;
}
