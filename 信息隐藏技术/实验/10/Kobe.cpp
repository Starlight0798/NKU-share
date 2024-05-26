#include <iostream>
#include <opencv2/opencv.hpp>
#include <vector>
using namespace std;
using namespace cv;


// 所有秘密字符串的长度
int SECRET_STR_LEN = 7;
// 秘密信息转化为8进制时的长度
int SECRET_LEN = (SECRET_STR_LEN * 8 + 2) / 3;

bool checkIdenticalImgs(const Mat &img1, const Mat &img2)
{
    if (img1.type() != img2.type() || img1.size() != img2.size())
        return false;

    double sum = cv::sum(cv::abs(img1 - img2))[0];
    return sum == 0;
}

class LSB
{
    public:
        static void hide(const Mat &origin, const string &secret_str, Mat &I);
        static void extract(const Mat &I, string &secret_str);
};

class Kobe
{
    public:
        static void hide(const Mat &origin, const vector<uchar> &secrets, Mat &I, vector<uchar> &marks);
        static void extract(const Mat &I, const vector<uchar> &marks, Mat &recover, vector<uchar> &secrets);
        static void hide(const Mat &origin1, const Mat &origin2, const vector<uchar> &secrets, Mat &I1, Mat &I2);
        static void extract(const Mat &I1, const Mat &I2, vector<uchar> &secrets, Mat &recover);
        static vector<uchar> str2oct(const string &str);   // 将字符串str转换成八进制数字的数组
        static string oct2str(const vector<uchar> &octs);        // 将八进制数字的数组转换成字符串
    private:
        static uchar getCW(const uchar *p);   // 从图像中某一位置获取并计算一个码字
        static uchar getFlag(uchar &CW);  // 从一个码字中获取标志位(一个八进制数)
};

int main()
{
    // vector<string> secret_strs = {"2112492", "2112515", "2113997", "2111408", "2111698"};
    // // 先把前四个用LSB嵌入到前四张图片
    // vector<Mat> origins(5);
    // origins[0] = imread("resource/beila.webp", 0);
    // origins[1] = imread("resource/xiangwan.webp", 0);
    // origins[2] = imread("resource/nailin.webp", 0);
    // origins[3] = imread("resource/jiale.webp", 0);
    // origins[4] = imread("resource/jiaran.webp", 0);
    // vector<Mat> shares(5);
    // for (int i = 0; i < 4; ++i)
    //     LSB::hide(origins[i], secret_strs[i], shares[i]);
    // shares[4] = origins[4];
    // // 把最后一个嵌入到第一幅图片中，产生的标记位嵌入到第二幅，以此类推
    // vector<uchar> secrets = Kobe::str2oct(secret_strs[4]);
    // for (int i = 0; i < 5; ++i)
    // {
    //     vector<uchar> marks;
    //     Kobe::hide(shares[i], secrets, shares[i], marks);
    //     secrets = marks;
    // }
    // // 至此嵌入过程结束，下面尝试提取出全部5个学号
    // vector<string> results;
    // for (int i = 0; i < 4; ++i)
    // {
    //     Mat recover;
    //     vector<uchar> secrets;
    //     Kobe::extract(shares[i], shares[i+1], secrets, recover);
    //     if (i == 0)
    //         results.push_back(Kobe::oct2str(secrets));
    //     string str_recover;
    //     LSB::extract(recover, str_recover);
    //     results.push_back(str_recover);
    // }
    // // 打印恢复出的学号
    // for (int i = 0; i < results.size(); ++i)
    //     cout << results[i] << endl;

    int len = 5;
    vector<string> secret_strs = {"2112492", "2112515", "2113997", "2111408", "2111698"};
    vector<Mat> origins(len);
    origins[0] = imread("resource/beila.webp", 0);
    origins[1] = imread("resource/xiangwan.webp", 0);
    origins[2] = imread("resource/nailin.webp", 0);
    origins[3] = imread("resource/jiale.webp", 0);
    origins[4] = imread("resource/jiaran.webp", 0);
    // 嵌入
    for (int i = 0; i < len; ++i)
    {
        vector<uchar> secrets = Kobe::str2oct(secret_strs[i]);
        for (int j = 0; j <= i; ++j)
        {
            vector<uchar> marks;
            Kobe::hide(origins[j], secrets, origins[j], marks);
            secrets = marks;
        }
    }
    // 提取
    vector<string> results(len);
    vector<uchar> secrets;
    Mat recover;
    for (int i = len-1; i > 0; --i)
    {
        for (int j = 0; j < i; ++j)
        {
            Kobe::extract(origins[j], origins[j+1], secrets, recover);
            if (j == 0)
                results[i] = Kobe::oct2str(secrets);
            origins[j] = recover;
        }
    }
    Kobe::extract(origins[0], origins[1], secrets, recover);
    results[0] = Kobe::oct2str(secrets);
    // 打印
    for (int i = 0; i < len; ++i)
        cout << results[i] << endl;
}

void Kobe::extract(const Mat &I1, const Mat &I2, vector<uchar> &secrets, Mat &recover)
{
    secrets.clear();
    recover = I1.clone();
    const uchar *p1 = I1.ptr<uchar>(), *p2 = I2.ptr<uchar>();
    uchar *p = recover.ptr<uchar>();
    for (int i = 0; i < SECRET_LEN; ++i)
    {
        // 获取需要用到的码字
        uchar CW1 = getCW(p1);
        uchar CW2 = getCW(p2);

        // 复原secret
        uchar s = getFlag(CW1);
        secrets.push_back(s);
        // 复原图像
        uchar z1 = getFlag(CW2);
        if (z1 > 0)
            *(p + z1 - 1) ^= 1;
        // 光栅扫描方式
        p += 7;
        p1 += 7;
        p2 += 7;
    }
}

void Kobe::extract(const Mat &I, const vector<uchar> &marks, Mat &recover, vector<uchar> &secrets)
{
    secrets.clear();
    recover = I.clone();
    const uchar *p = I.ptr<uchar>();
    uchar *p_recover = recover.ptr<uchar>();
    for (int i = 0; i < SECRET_LEN; ++i)
    {
        uchar CW = getCW(p);
        secrets.push_back(getFlag(CW));
        if (marks[i] > 0)
            *(p_recover + marks[i] - 1) ^= 1;
        p += 7;
        p_recover += 7;
    }
}


void Kobe::hide(const Mat &origin1, const Mat &origin2, const vector<uchar> &secrets, Mat &I1, Mat &I2)
{
    I1 = origin1.clone();
    I2 = origin2.clone();
    // const uchar *p = origin1.ptr<uchar>();
    uchar *p1 = I1.ptr<uchar>(), *p2 = I2.ptr<uchar>();
    for (int i = 0; i < secrets.size(); ++i)
    {
        // 获取需要用到的码字
        uchar CW1 = getCW(p1);
        // 计算z1
        uchar z1 = getFlag(CW1) ^ secrets[i];
        // 翻转I1中的对应像素
        if (z1 > 0)
            *(p1 + z1 - 1) ^= 1;
        // 计算z2
        uchar CW2 = getCW(p2);
        uchar z2 = getFlag(CW2) ^ z1;
        // 翻转I2中的对应像素
        if (z2 > 0) 
            *(p2 + z2 - 1) ^= 1;
        // 光栅扫描方式
        // p += 7;
        p1 += 7;
        p2 += 7;
    }
}

void Kobe::hide(const Mat &origin, const vector<uchar> &secrets, Mat &I, vector<uchar> &marks)
{
    marks.clear();
    I = origin.clone();
    uchar *p = I.ptr<uchar>();
    for (int i = 0; i < secrets.size(); ++i)
    {
        uchar CW = getCW(p);
        uchar z = getFlag(CW) ^ secrets[i];
        marks.push_back(z);
        if (z > 0)
            *(p + z - 1) ^= 1;
        p += 7;
    }
}

uchar Kobe::getCW(const uchar *p)
{
    // 7个像素是一组，一组产生一个码字CW，一个码字是一个一维二进制数组(长度为7)，这里用一个uchar类型整数存
    uchar CW = 0;
    for (int j = 0; j < 7; ++j, ++p)
        CW = (CW << 1) | (*p & 1);
    return CW;
}

uchar Kobe::getFlag(uchar &CW)
{
    uchar res = 0;
    for (uchar i = 0; i < 7; ++i)
    {
        if ((CW >> (6-i) & 1) == 1)
            res ^= i+1;
    }
    return res;
}

vector<uchar> Kobe::str2oct(const string &str)
{
    vector<uchar> octs;
    int cnt = 0;
    uchar cur = 0;
    for (const uchar &c : str)
    {
        for (int i = 0; i < 8; ++i)
        {
            cur = (cur << 1) | ((c >> (7-i)) & 1);
            if (++cnt == 3)
            {
                octs.push_back(cur);
                cur = 0;
                cnt = 0;
            }
        }
    }
    if (cnt)
        octs.push_back(cur << (3-cnt));

    return octs;
}

string Kobe::oct2str(const vector<uchar> &octs)
{
    string str = "";
    uchar byte = 0;
    int cnt = 0;
    for (const uchar &oct : octs)
    {
        for (int i = 0; i < 3; ++i)
        {
            byte = (byte << 1) | (oct >> (2-i) & 1);
            if (++cnt == 8)
            {
                str += char(byte);
                byte = 0;
                cnt = 0;
            }
        }
    }
    return str;
}

void LSB::hide(const Mat &origin, const string &secret_str, Mat &I)
{
    I = origin.clone();
    uchar *p = I.ptr<uchar>();
    for (int i = 0; i < SECRET_STR_LEN; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            if (((secret_str[i] >> (7-j)) & 1) != (*p & 1))
                *p ^= 1;
            ++p;
        }
    }
}

void LSB::extract(const Mat &I, string &secret_str)
{
    secret_str.clear();
    const uchar *p = I.ptr<uchar>();
    for (int i = 0; i < SECRET_STR_LEN; ++i)
    {
        uchar c = 0;
        for (int j = 0; j < 8; ++j)
        {
            c = (c << 1) | (*p & 1);
            ++p;
        }
        secret_str += c;
    }
}