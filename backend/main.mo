import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

actor DEX {
    // Token types
    type TokenId = Text;
    type Balance = Float;

    // User balances
    private var balances = HashMap.HashMap<Principal, HashMap.HashMap<TokenId, Balance>>(10, Principal.equal, Principal.hash);

    // Liquidity pool
    private var liquidityPool = HashMap.HashMap<TokenId, Balance>(2, Text.equal, Text.hash);

    // Initialize tokens and liquidity pool
    private func initTokens() {
        liquidityPool.put("TokenA", 1000.0);
        liquidityPool.put("TokenB", 1000.0);
    };
    initTokens();

    // Helper function to get user balance
    private func getBalance(user: Principal, token: TokenId) : Balance {
        switch (balances.get(user)) {
            case null { 0.0 };
            case (?userBalances) {
                switch (userBalances.get(token)) {
                    case null { 0.0 };
                    case (?balance) { balance };
                };
            };
        };
    };

    // Helper function to update user balance
    private func updateBalance(user: Principal, token: TokenId, amount: Balance) {
        let userBalances = switch (balances.get(user)) {
            case null { HashMap.HashMap<TokenId, Balance>(2, Text.equal, Text.hash) };
            case (?ub) { ub };
        };
        userBalances.put(token, amount);
        balances.put(user, userBalances);
    };

    // Mint tokens (for testing purposes)
    public shared(msg) func mintTokens(token: TokenId, amount: Balance) : async () {
        let currentBalance = getBalance(msg.caller, token);
        updateBalance(msg.caller, token, currentBalance + amount);
    };

    // Add liquidity
    public shared(msg) func addLiquidity(tokenA: Balance, tokenB: Balance) : async () {
        assert(tokenA > 0 and tokenB > 0);
        
        let userBalanceA = getBalance(msg.caller, "TokenA");
        let userBalanceB = getBalance(msg.caller, "TokenB");
        
        assert(userBalanceA >= tokenA and userBalanceB >= tokenB);

        updateBalance(msg.caller, "TokenA", userBalanceA - tokenA);
        updateBalance(msg.caller, "TokenB", userBalanceB - tokenB);

        liquidityPool.put("TokenA", (switch (liquidityPool.get("TokenA")) { case null 0.0; case (?v) v }) + tokenA);
        liquidityPool.put("TokenB", (switch (liquidityPool.get("TokenB")) { case null 0.0; case (?v) v }) + tokenB);
    };

    // Remove liquidity
    public shared(msg) func removeLiquidity(tokenA: Balance, tokenB: Balance) : async () {
        assert(tokenA > 0 and tokenB > 0);
        
        let poolBalanceA = switch (liquidityPool.get("TokenA")) { case null 0.0; case (?v) v };
        let poolBalanceB = switch (liquidityPool.get("TokenB")) { case null 0.0; case (?v) v };
        
        assert(poolBalanceA >= tokenA and poolBalanceB >= tokenB);

        liquidityPool.put("TokenA", poolBalanceA - tokenA);
        liquidityPool.put("TokenB", poolBalanceB - tokenB);

        let userBalanceA = getBalance(msg.caller, "TokenA");
        let userBalanceB = getBalance(msg.caller, "TokenB");

        updateBalance(msg.caller, "TokenA", userBalanceA + tokenA);
        updateBalance(msg.caller, "TokenB", userBalanceB + tokenB);
    };

    // Swap tokens
    public shared(msg) func swap(fromToken: TokenId, toToken: TokenId, amount: Balance) : async Balance {
        assert(fromToken != toToken);
        assert(amount > 0);

        let userBalance = getBalance(msg.caller, fromToken);
        assert(userBalance >= amount);

        let poolBalanceFrom = switch (liquidityPool.get(fromToken)) { case null 0.0; case (?v) v };
        let poolBalanceTo = switch (liquidityPool.get(toToken)) { case null 0.0; case (?v) v };

        let swapRate = poolBalanceTo / poolBalanceFrom;
        let receivedAmount = amount * swapRate * 0.997; // 0.3% fee

        updateBalance(msg.caller, fromToken, userBalance - amount);
        updateBalance(msg.caller, toToken, getBalance(msg.caller, toToken) + receivedAmount);

        liquidityPool.put(fromToken, poolBalanceFrom + amount);
        liquidityPool.put(toToken, poolBalanceTo - receivedAmount);

        receivedAmount
    };

    // Get user balances
    public query(msg) func getUserBalances() : async [(TokenId, Balance)] {
        switch (balances.get(msg.caller)) {
            case null { [] };
            case (?userBalances) { Iter.toArray(userBalances.entries()) };
        };
    };

    // Get liquidity pool balances
    public query func getLiquidityPoolBalances() : async [(TokenId, Balance)] {
        Iter.toArray(liquidityPool.entries());
    };
};
