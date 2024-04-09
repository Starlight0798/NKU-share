#include "examples.h"
#include <vector>
using namespace std;
using namespace seal;
#define N 3
int main()
{

    // 客户端的视角：要进行计算的数据
    vector<double> x, y, z;
    x = { 1.0, 2.0, 3.0 };
    y = { 2.0, 3.0, 4.0 };
    z = { 3.0, 4.0, 5.0 };
    cout<<"原始向量x是："<<endl;
    print_vector(x);
    cout<<"原始向量y是："<<endl;
    print_vector(y);
    cout<<"原始向量z是："<<endl;
    print_vector(z);
    cout<<endl;
    // 构建参数容器 parms
    EncryptionParameters parms(scheme_type::ckks);
    // 这里的参数都使用官方建议的
    size_t poly_modulus_degree = 8192;
    parms.set_poly_modulus_degree(poly_modulus_degree);
    parms.set_coeff_modulus(CoeffModulus::Create(poly_modulus_degree, { 60, 40, 40, 60 }));
    double scale = pow(2.0, 40);

    // 用参数生成 CKKS 框架 context
    SEALContext context(parms);

    // 构建各模块
    // 生成公钥、私钥和重线性化密钥
    KeyGenerator keygen(context);
    auto secret_key = keygen.secret_key();
    PublicKey public_key;
    keygen.create_public_key(public_key);
    RelinKeys relin_keys;
    keygen.create_relin_keys(relin_keys);
    // 构建编码器，加密模块、运算器和解密模块
    // 注意加密需要公钥 pk；解密需要私钥 sk；编码器需要 scale
    Encryptor encryptor(context, public_key);
    Evaluator evaluator(context);
    Decryptor decryptor(context, secret_key);
    CKKSEncoder encoder(context);

    // 对向量 x、y、z 进行编码
    Plaintext xp, yp, zp;
    encoder.encode(x, scale, xp);
    encoder.encode(y, scale, yp);
    encoder.encode(z, scale, zp);

    // 对明文 xp、yp、zp 进行加密
    Ciphertext xc, yc, zc;
    encryptor.encrypt(xp, xc);
    encryptor.encrypt(yp, yc);
    encryptor.encrypt(zp, zc);


    /*
    下面进入本次实验的核心内容
    计算$x^3+y*z$
    */
    // 步骤1，计算x^2
        print_line(__LINE__);
    cout << "计算 x^2 ." << endl;
    Ciphertext x2;
    evaluator.multiply(xc, xc, x2);
    // 进行 relinearize 和 rescaling 操作
    evaluator.relinearize_inplace(x2, relin_keys);
    evaluator.rescale_to_next_inplace(x2);
    // 然后查看一下此时x^2结果的level
    print_line(__LINE__);
    cout << " + Modulus chain index for x2: "
<< context.get_context_data(x2.parms_id())->chain_index() << endl;

    // 步骤2，计算1.0*x
    // 此时xc本身的层级应该是2，比x^2高，因此这一步解决层级问题
    print_line(__LINE__);
    cout << " + Modulus chain index for xc: "
<< context.get_context_data(xc.parms_id())->chain_index() << endl;
    // 因此，需要对 x 进行一次乘法和 rescaling操作
        print_line(__LINE__);
    cout << "计算 1.0*x ." << endl;
    Plaintext plain_one;
    encoder.encode(1.0, scale, plain_one);
    // 执行乘法和 rescaling 操作：
    evaluator.multiply_plain_inplace(xc, plain_one);
    evaluator.rescale_to_next_inplace(xc);
    // 再次查看 xc 的层级，可以发现 xc 与 x^2 层级变得相同
    print_line(__LINE__);
    cout << " + Modulus chain index for xc new: "
<< context.get_context_data(xc.parms_id())->chain_index() << endl;
    // 那么，此时xc与x^2层级相同，二者可以相乘了

    // 步骤3，计算x^3，即1*x*x^2
    // 先设置新的变量叫x3
        print_line(__LINE__);
    cout << "计算 1.0*x*x^2 ." << endl;
    Ciphertext x3;
    evaluator.multiply_inplace(x2, xc);
    evaluator.relinearize_inplace(x2,relin_keys);
    evaluator.rescale_to_next(x2, x3);
    // 此时观察x^3的层级
    print_line(__LINE__);
cout << " + Modulus chain index for x3: "
<< context.get_context_data(x3.parms_id())->chain_index() << endl;


    // 步骤4，计算y*z
    print_line(__LINE__);
    cout << "计算 y*z ." << endl;
    Ciphertext yz;
    evaluator.multiply(yc, zc, yz);
    // 进行 relinearize 和 rescaling 操作
    evaluator.relinearize_inplace(yz, relin_keys);
    evaluator.rescale_to_next_inplace(yz);
    // 然后查看一下此时y*z结果的level
    print_line(__LINE__);
    cout << " + Modulus chain index for yz: "
<< context.get_context_data(yz.parms_id())->chain_index() << endl;

    // 注意，此时问题在于scales的不统一，可以直接重制。
    print_line(__LINE__);
    cout << "Normalize scales to 2^40." << endl;
    x3.scale() = pow(2.0, 40);
    yz.scale() = pow(2.0, 40);
    // 输出观察，此时的scale的大小已经统一了！
    print_line(__LINE__);
    cout << " + Exact scale in 1*x^3: " << x3.scale() << endl;
    print_line(__LINE__);
    cout << " + Exact scale in  y*z: " << yz.scale() << endl;

    // 但是，此时还有一个问题，就是我们的x^3和yz的层级还不统一！
    // 在官方 examples 中，给出了一个简便的变换层级的方法，如下所示：
    parms_id_type last_parms_id = x3.parms_id();
    evaluator.mod_switch_to_inplace(yz, last_parms_id);
    print_line(__LINE__);
    cout << " + Modulus chain index for yz new: "
<< context.get_context_data(yz.parms_id())->chain_index() << endl;

    // 步骤5，x^3+y*z
        print_line(__LINE__);
    cout << "计算 x^3+y*z ." << endl;
    Ciphertext encrypted_result;
    evaluator.add(x3, yz, encrypted_result);

    // 计算完毕，服务器把结果发回客户端
    Plaintext result_p;
    decryptor.decrypt(encrypted_result, result_p);

    // 注意要解码到一个向量上
    vector<double> result;
    encoder.decode(result_p, result);

    // 输出结果
        print_line(__LINE__);
    cout << "结果是：" << endl;
    print_vector(result, 3 /*precision*/);

    return 0;
}
