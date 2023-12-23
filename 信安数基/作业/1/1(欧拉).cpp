#include <iostream>
#include <windows.h>
using namespace std;

struct Node{
    int data;
    Node* next;
    Node(int d=0):data(d){next=NULL;}
}*head, *tail;

inline void insert(int val){
    if(head==NULL) head = tail = new Node(val);
    else{
        Node* tmp = new Node(val);
        tail->next = tmp;
        tail = tmp;
    }
}

const int MAXN = 1000000;
bool vis[MAXN];

void Prime(int n){
    for(int i=2;i<=n;i++){
        if(!vis[i]) insert(i);
        Node* cur = head;
        while(cur!=NULL){
            int p = cur->data;
            if(i*p>n) break;
            vis[i*p] = true;
            if(i%p==0) break;
            cur = cur->next;
        }
    }
}

void write(int x)
{
    if(x<0) putchar('-'),x=-x;
    if(x>9) write(x/10);
    putchar(x%10 +'0');
}

int main(){
    vis[0] = vis[1] = true;
    Prime(MAXN);
    Node* cur = head;
    while(cur!=NULL){
        write(cur->data);
        printf(", ");
        cur = cur->next;
    }
    return 0; 
}