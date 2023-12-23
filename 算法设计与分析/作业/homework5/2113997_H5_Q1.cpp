#include <iostream>
#include <vector>
#include <algorithm>
#include <limits>
using namespace std;

vector<int> eviction_schedule(int k, vector<int> &cache, vector<int> &requests) {
    vector<int> evict;
    for (size_t i = 0; i < requests.size(); ++i) {
        int req = requests[i];
        if (find(cache.begin(), cache.end(), req) == cache.end()) {
            if (cache.size() < k) {
                cache.push_back(req);
            } else {
                vector<int> dist;
                for (int x : cache) {
                    auto it = find(requests.begin() + i + 1, requests.end(), x);
                    int d = (it != requests.end()) ? (it - requests.begin() - i) : numeric_limits<int>::max();
                    dist.push_back(d);
                }
                int idx_max = -1;
                int dis_max = -1;
                for (size_t j = 0; j < dist.size(); ++j) {
                    int d = dist[j];
                    auto it1 = find(requests.rbegin() + requests.size() - i, requests.rend(), cache[j]);
                    auto it2 = (idx_max != -1) ? find(requests.rbegin() + requests.size() - i, requests.rend(), cache[idx_max]) : requests.rend();

                    if (d > dis_max || (d == dis_max && it1 < it2)) {
                        idx_max = j;
                        dis_max = d;
                    }
                }
                evict.push_back(cache[idx_max]);
                cache[idx_max] = req;
            }
        }
    }

    return evict;
}

int main() {
    int k, n, s;
    cin >> k >> n >> s;
    vector<int> initial_blocks(n);
    for (int i = 0; i < n; ++i) {
        cin >> initial_blocks[i];
    }
    vector<int> requests(s);
    for (int i = 0; i < s; ++i) {
        cin >> requests[i];
    }
    vector<int> ans = eviction_schedule(k, initial_blocks, requests);
    for (int i : ans) cout << i << " ";
    return 0;
}
