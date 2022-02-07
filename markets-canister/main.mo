import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import List "mo:base/List";
import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

shared(msg) actor class Market() {
    /* Types */

    public type Title = Text;
    public type Description = Text;
    public type Author = Text;

    public type User = {
        id: Text; // Principal text.
        seerBalance: Nat32;
        liquidityProviderFor: [(Nat32, Nat32)]; // [(MarketId, Shares)].
        marketTokens: [(Nat32, Nat32, Nat32)]; // [(MarketId, YesTokenBalance, NoTokenBalance)].
    };

    public type MarketInitData = {
        title: Title;
        description: Description;
        yesProb: Nat32;
        noProb: Nat32;
        liquidity: Nat32;
        endDate: Time.Time;
    };

    public type Market = {
        id: Nat32;    
        title: Title;
        description: Description;
        yesProb: Nat32;
        noProb: Nat32;
        liquidity: Nat32;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        blockTimestampLast: Time.Time;
        reserveYes: Nat32;
        reserveNo: Nat32;
        kLast: Nat32; // sqrt(reserve0 * reserve1)
    };  

    /* State */
    
    private stable var nextMarketId: Nat32 = 0;
    private stable var anon: Text = "2vxsx-fae";
   
    private stable var markets: Trie.Trie<Nat32, Market> = Trie.empty();
    private stable var users: Trie.Trie<Text, User> = Trie.empty();

    /* API */

    // Get or create new user.
    public shared(msg) func getUser(): async ?User {
        let userId = Principal.toText(msg.caller);
        if (userId == anon) return null; // User needs to login.

        var result = Trie.find(users, userKey(userId), Text.equal);
        
        if (result != null) {
            // Create user because it does not exist.
            result := ?{
                id = userId;
                seerBalance = 1000; // Airdrop
                liquidityProviderFor = [];
                marketTokens = [];
            };
        };

        return result;
    };

    // Create a market.
    public shared(msg) func createMarket(marketInitData: MarketInitData): async Nat32 {
        assert(Principal.toText(msg.caller) != anon);
        assert(marketInitData.yesProb + marketInitData.noProb == 100);
        assert(marketInitData.liquidity > 0);

        let marketId: Nat32 = nextMarketId;
        let author: Author = Principal.toText(msg.caller);
        let reserveYes = (marketInitData.liquidity * 50) / marketInitData.noProb;
        let reserveNo = (marketInitData.liquidity * 50) / marketInitData.yesProb;

        let newMarket: Market = {
            id = marketId;
            title = marketInitData.title;
            description = marketInitData.description;
            yesProb = marketInitData.yesProb;
            noProb = marketInitData.noProb;
            liquidity = marketInitData.liquidity;
            startDate = Time.now();
            endDate = marketInitData.endDate;
            author = author;
            blockTimestampLast = Time.now();
            reserveYes = reserveYes; 
            reserveNo = reserveNo;
            kLast = reserveNo * reserveYes;
        };

        nextMarketId += 1;

        markets := Trie.replace(
            markets,
            marketKey(marketId),
            Nat32.equal,
            ?newMarket,
        ).0;

        return marketId;
    };

    // Read a market.
    public query func read(marketId: Nat32): async ?Market {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        return result;        
    };

    // Read all markets.
    public query func readAll(): async [Market] {
        let result = Trie.toArray(markets, getMarket);
        return result;
    };

    // Update a market.
    public func update(marketId: Nat32, market: Market): async Bool {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        let exists = Option.isSome(result);
        if (exists) {
            markets := Trie.replace(
                markets,
                marketKey(marketId),
                Nat32.equal,
                ?market,
            ).0;
        };
        return exists;
    };

    // Delete a market.
    public func delete(marketId: Nat32): async Bool {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        let exists = Option.isSome(result);
        if (exists) {
            markets := Trie.replace(
                markets,
                marketKey(marketId),
                Nat32.equal,
                null,
            ).0;
        };
        return exists;
    };

    // Delete all market.
    public func deleteAll(): async () {
        nextMarketId := 0;
        markets := Trie.empty();
    };

    /**
    * Utilities
    */

    private func userKey(x: Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };

    private func marketKey(x: Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };

    private func getMarket(k: Nat32, v: Market): Market {
        return v;
    };
};
