// =============================================================================
//                                  Config 
// =============================================================================

// sets up web3.js
if (typeof web3 !== 'undefined')  {
	web3 = new Web3(web3.currentProvider);
} else {
	web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}

// Default account is the first one
web3.eth.defaultAccount = web3.eth.accounts[0];
// Constant we use later
var GENESIS = '0x0000000000000000000000000000000000000000000000000000000000000000';

// This is the ABI for your contract (get it from Remix, in the 'Compile' tab)
// ============================================================
var abi = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "creditor",
				"type": "address"
			},
			{
				"name": "amount",
				"type": "uint32"
			},
			{
				"name": "path",
				"type": "address[]"
			},
			{
				"name": "min_on_cycle",
				"type": "uint32"
			}
		],
		"name": "add_IOU",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "debtor",
				"type": "address"
			},
			{
				"name": "creditor",
				"type": "address"
			}
		],
		"name": "lookup",
		"outputs": [
			{
				"name": "ret",
				"type": "uint32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
];

// ============================================================
abiDecoder.addABI(abi);
// call abiDecoder.decodeMethod to use this - see 'getAllFunctionCalls' for more

// Reads in the ABI
var BlockchainSplitwiseContractSpec = web3.eth.contract(abi);

// This is the address of the contract you want to connect to; copy this from Remix
var contractAddress = '0xF8e43b77a79acEEbc85d27218D3863F9EA98A0cA'

var BlockchainSplitwise = BlockchainSplitwiseContractSpec.at(contractAddress)


// =============================================================================
//                            Functions To Implement 
// =============================================================================

// TODO: Add any helper functions here!
/**
 * 获取调用数据
 * @param {Function} extractor_fn - 用于提取数据的函数
 * @param {Function} early_stop_fn - 用于提前停止的函数
 * @returns {Array} - 提取的数据数组
 */
function getCallData(extractor_fn, early_stop_fn) {
	const results = new Set();
	const all_calls = getAllFunctionCalls(contractAddress, 'add_IOU', early_stop_fn);
	for (var i = 0; i < all_calls.length; i++) {
		const extracted_values = extractor_fn(all_calls[i]);
		for (var j = 0; j < extracted_values.length; j++) {
			results.add(extracted_values[j]);
		}
	}
	return Array.from(results);
}

/**
 * 获取债权人列表
 * @returns {Array} 债权人列表
 */
function getCreditors() {
	return getCallData((call) => {
		// call.args[0] is the creditor.
		return [call.args[0]];
	}, /*early_stop_fn=*/null);
}

/**
 * 获取用户的债权人列表
 * @param {string} user - 用户名
 * @returns {Array} - 债权人列表
 */
function getCreditorsForUser(user) {
	var creditors = []
	const all_creditors = getCreditors()
	for (var i = 0; i < all_creditors.length; i++) {
		const amountOwed = BlockchainSplitwise.lookup(user, all_creditors[i]).toNumber();
		if (amountOwed > 0) {
			creditors.push(all_creditors[i])
		}
	}
	return creditors;
}


/**
 * 在给定路径上查找最小欠款金额。
 *
 * @param {Array} path - 路径数组，表示债务人和债权人之间的关系。
 * @returns {number} - 最小欠款金额。
 */
function findMinOnPath(path) {
	var minOwed = null;
	for (var i = 1; i < path.length; i++) {
		const debtor = path[i-1]
		const creditor = path[i];
		const amountOwed = BlockchainSplitwise.lookup(debtor, creditor).toNumber();
		if (minOwed == null || minOwed > amountOwed) {
			minOwed = amountOwed;
		}
	}
	return minOwed;
}


// TODO: Return a list of all users (creditors or debtors) in the system
// You can return either:
//   - a list of everyone who has ever sent or received an IOU
// OR
//   - a list of everyone currently owing or being owed money
/**
 * 获取用户信息。
 * @returns {Array} 包含债务人和债权人的数组。
 */
function getUsers() {
	return getCallData((call) => {
		// call.from is debtor and call.args[0] is creditor.
		return [call.from, call.args[0]]
	}, /*early_stop_fn=*/null);
}

// TODO: Get the total amount owed by the user specified by 'user'
/**
 * 计算用户欠款总额
 * @param {string} user - 用户名
 * @returns {number} - 用户欠款总额
 */
function getTotalOwed(user) {
	// We assume lookup is up-to-date (all cycles removed).
	var totalOwed = 0;
	const all_creditors = getCreditors();
	for (var i = 0; i < all_creditors.length; i++) {
		totalOwed += BlockchainSplitwise.lookup(user, all_creditors[i]).toNumber();
	}
	return totalOwed;
}

// TODO: Get the last time this user has sent or received an IOU, in seconds since Jan. 1, 1970
// Return null if you can't find any activity for the user.
// HINT: Try looking at the way 'getAllFunctionCalls' is written. You can modify it if you'd like.
/**
 * 获取用户最后活跃时间戳
 * @param {string} user - 用户名
 * @returns {number} - 最后活跃时间戳
 */
function getLastActive(user) {
	const all_timestamps = getCallData((call) => {
		if (call.from == user || call.args[0] == user) {
			return [call.timestamp];
		}
		return [];
	}, (call) => {
		// Return early as soon as you find this user.
		return call.from == user || call.args[0] == user;
	});
	return Math.max(all_timestamps);

}

// TODO: add an IOU ('I owe you') to the system
// The person you owe money is passed as 'creditor'
// The amount you owe them is passed as 'amount'
/**
 * 添加债务。
 * @param {string} creditor - 债权人的地址。
 * @param {number} amount - 债务金额。
 * @returns {void}
 */
function add_IOU(creditor, amount) {
	// 假设债务人是发起交易的人。
	const debtor = web3.eth.defaultAccount;
	// 如果债权人 -> 债务人之间存在路径（例如，债权人欠债务人债务），
	// 而不是立即添加债务，先找到路径并找到路径上的最小欠款金额。
	const path = doBFS(creditor, debtor, getCreditorsForUser);
	if (path != null) {
		const min_on_cycle = Math.min(findMinOnPath(path), amount);
		// 现在添加债务，让合约知道可能存在的循环。
		return BlockchainSplitwise.add_IOU(creditor, amount, path, min_on_cycle);
	}
	// 没有循环，直接添加债务。
	var x = BlockchainSplitwise.add_IOU(creditor, amount, [], /*min_on_cycle=*/0);
	return;
}

// =============================================================================
//                              Provided Functions 
// =============================================================================
// Reading and understanding these should help you implement the above

// This searches the block history for all calls to 'functionName' (string) on the 'addressOfContract' (string) contract
// It returns an array of objects, one for each call, containing the sender ('from'), arguments ('args')
// and timestamp (unix micros) of block collation ('timestamp').
// Stops retrieving function calls as soon as the earlyStopFn is found. earlyStop takes
// as input a candidate function call and must return a truth value.
// The chain is processed from head to genesis block.
function getAllFunctionCalls(addressOfContract, functionName, earlyStopFn) {
	var curBlock = web3.eth.blockNumber;
	var function_calls = [];
	while (curBlock !== GENESIS) {
	  var b = web3.eth.getBlock(curBlock, true);
	  var txns = b.transactions;
	  for (var j = 0; j < txns.length; j++) {
	  	var txn = txns[j];
	  	// check that destination of txn is our contract
	  	if (txn.to === addressOfContract.toLowerCase()) {
	  		var func_call = abiDecoder.decodeMethod(txn.input);
	  		// check that the function getting called in this txn is 'functionName'
	  		if (func_call && func_call.name === functionName) {
	  			var args = func_call.params.map(function (x) {return x.value});
	  			function_calls.push({
	  				from: txn.from,
	  				args: args,
	  				timestamp: b.timestamp,
	  			})
	  			if (earlyStopFn &&
	  					earlyStopFn(function_calls[function_calls.length-1])) {
	  				return function_calls;
	  			}
	  		}
	  	}
	  }
	  curBlock = b.parentHash;
	}
	return function_calls;
}

// We've provided a breadth-first search implementation for you, if that's useful
// It will find a path from start to end (or return null if none exists)
// You just need to pass in a function ('getNeighbors') that takes a node (string) and returns its neighbors (as an array)
function doBFS(start, end, getNeighbors) {
	var queue = [[start]];
	while (queue.length > 0) {
		var cur = queue.shift();
		var lastNode = cur[cur.length-1]
		if (lastNode === end) {
			return cur;
		} else {
			var neighbors = getNeighbors(lastNode);
			for (var i = 0; i < neighbors.length; i++) {
				queue.push(cur.concat([neighbors[i]]));
			}
		}
	}
	return null;
}
// =============================================================================
//                                      UI 
// =============================================================================

// This code updates the 'My Account' UI with the results of your functions
$("#total_owed").html("$"+getTotalOwed(web3.eth.defaultAccount));
$("#last_active").html(timeConverter(getLastActive(web3.eth.defaultAccount)));
$("#myaccount").change(function() {
	web3.eth.defaultAccount = $(this).val();
	$("#total_owed").html("$"+getTotalOwed(web3.eth.defaultAccount));
	$("#last_active").html(timeConverter(getLastActive(web3.eth.defaultAccount)))
});

// Allows switching between accounts in 'My Account' and the 'fast-copy' in 'Address of person you owe
var opts = web3.eth.accounts.map(function (a) { return '<option value="'+a+'">'+a+'</option>' })
$(".account").html(opts);
$(".wallet_addresses").html(web3.eth.accounts.map(function (a) { return '<li>'+a+'</li>' }))

// This code updates the 'Users' list in the UI with the results of your function
$("#all_users").html(getUsers().map(function (u,i) { return "<li>"+u+"</li>" }));

// This runs the 'add_IOU' function when you click the button
// It passes the values from the two inputs above
$("#addiou").click(function() {
  add_IOU($("#creditor").val(), $("#amount").val());
  window.location.reload(false); // refreshes the page after
});

// This is a log function, provided if you want to display things to the page instead of the JavaScript console
// Pass in a discription of what you're printing, and then the object to print
function log(description, obj) {
	$("#log").html($("#log").html() + description + ": " + JSON.stringify(obj, null, 2) + "\n\n");
}