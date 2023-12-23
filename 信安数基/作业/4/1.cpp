#include <bits/stdc++.h>
#define MAXN 100000
using namespace std;

int ind_table[MAXN], ind_val[MAXN];
bool vis[MAXN];
int elm[MAXN], lens;

void Eratosthenes(int n){
    memset(vis, false, 4*(n+1));
    lens = 0;
    for(int i=2;i<=n;i++){
        if(!vis[i]){
            if(n%i==0){
                elm[lens] = i;
                while(n%i==0) n/=i;
                lens++;
                if(n==1) break;
            }
            for(int j = 2*i;j <= n;j += i) vis[j] = true;
        }
    }
}

int Quick_mod(int a,int b,int c){
	a%=c;
	long long ans=1, base=a;
	while(b>0){
		if(b&1) ans=(ans*base)%c;
		base=(base*base)%c;
		b>>=1;
	}
	return ans;
}

int Euler(int n){
    Eratosthenes(n);
    int ans = n;
    for(int i=0;i<lens;i++) ans = (ans / elm[i]) * (elm[i] - 1);
    return ans;
}

int get_g(int n){
    int phi = Euler(n);
    Eratosthenes(phi); 
    for(int i=2;i<=phi;i++){
        bool flag = true;
        for(int j=0;j<lens;j++){
            if(Quick_mod(i, phi / elm[j], n) == 1){
                flag = false;
                break;
            }
        }
        if(flag) return i;
    }
    return -1;
}

void get_table(int g, int n){
    memset(ind_table, -1, 4*(n+1));
    ind_val[0] = 1;
    ind_table[1] = 0;
    for(int i=1;i<Euler(n);i++){
        ind_val[i] = (ind_val[i-1] * g) % n;
        ind_table[ind_val[i]] = i;
    }
}

void print_table(int n){
    int y = n / 10;
    printf("     ");
    for(int i=0;i<10;i++) printf("%5d", i);
    printf("\n");
    for(int i=0;i<=y;i++){
        printf("%5d", i);
        for(int j=0;j<10;j++){
            int val = ind_table[i*10+j];
            if(val==-1 || 10*i+j>=n) printf("%5c", '-');
            else printf("%5d", val);
        }
        printf("\n");
    }
}

int main(){
    printf("Please input n(n>0): ");
    int n, g;
    scanf("%d", &n);
    g = get_g(n);
    printf("The min primitive root if %d: g=%d\n", n, g);
    printf("The ind_table if %d based on g=%d is:\n", n, g);
    get_table(g, n);
    print_table(n);
    system("pause");
    return 0;
}