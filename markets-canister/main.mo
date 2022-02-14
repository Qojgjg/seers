import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Float "mo:base/Float";
import List "mo:base/List";
import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

shared(msg) actor class Market() {
    /* Types */

    public type Title = Text;
    public type Description = Text;
    public type Author = Text;

    public type User = {
        id: Text; // Principal text.
        seerBalance: Nat64;
        liquidityProviderFor: [(Nat64, Nat64)]; // [(MarketId, Shares)].
        marketTokens: [(Nat64, Nat64, Nat64)]; // [(MarketId, YesTokenBalance, NoTokenBalance)].
    };

    public type MarketInitData = {
        title: Title;
        description: Description;
        yesProb: Nat64;
        noProb: Nat64;
        liquidity: Nat64;
        endDate: Time.Time;
    };

    public type Market = {
        id: Nat32;    
        title: Title;
        description: Description;
        yesProb: Nat64;
        noProb: Nat64;
        liquidity: Nat64;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        blockTimestampLast: Time.Time;
        reserveYes: Nat64;
        reserveNo: Nat64;
        kLast: Nat64; // sqrt(reserve0 * reserve1)
        totalShares: Nat64;
        providers: [Text]; // list of principals
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
        let author = Principal.toText(msg.caller);

        assert(author != anon);
        assert(marketInitData.yesProb + marketInitData.noProb == 100);
        assert(marketInitData.liquidity >= 1000);
        assert(marketInitData.title != "");
        assert(marketInitData.description != "");
        assert(marketInitData.endDate > Time.now());

        let marketId = nextMarketId;
        let reserveYes = (marketInitData.liquidity * 50) / marketInitData.yesProb;
        let reserveNo = (marketInitData.liquidity * 50) / marketInitData.noProb;

        // TODO: this wraps on overflow. Should I use Int64 directly?
        let shares = Int64.toNat64(Float.toInt64(Float.sqrt(
            Float.fromInt64(Int64.fromNat64(reserveNo))
            * Float.fromInt64(Int64.fromNat64(reserveYes)))));

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
            kLast = reserveYes * reserveNo;
            totalShares = shares;
            providers = [author];
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
    public query func readMarket(marketId: Nat32): async ?Market {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        return result;        
    };

    // Read all markets.
    public query func readAllMarkets(): async [Market] {
        let result = Trie.toArray(markets, getMarket);
        return result;
    };

    // Update a market.
    public func updateMarket(marketId: Nat32, market: Market): async Bool {
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
    public func deleteMarket(marketId: Nat32): async Bool {
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
    public func deleteAllMarkets(): async () {
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
