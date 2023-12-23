#include <iostream>
using namespace std;

int main(){
    int n;
    cin>>n;
    // 如果银行账户为正数，则不需要删除数字，直接输出即可
    if(n>=0){
        cout<<n;
        return 0;
    }
    // 如果银行账户为负数，先取其绝对值，方便操作
    n = -n;
    // a为删除个位后的结果，b为删除十位后的结果
    int a = n/10;
    int b = (n/100)*10 + n%10;
    // 取删除个位和删除十位的结果中的最小值
    int ans = min(a,b);
    // 如果结果不为0，则说明需要输出负号
    if(ans!=0) cout<<'-';
    cout<<ans;
    return 0;
}
