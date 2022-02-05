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

    public type MarketId = Nat32;
    public type Title = Text;
    public type Description = Text;
    public type Probability = Nat32;
    public type Liquidity = Nat32;
    public type Author = Text;

    public type Market = {
        id: MarketId;    
        title: Title;
        description: Description;
        yesProb: Probability;
        noProb: Probability;
        liquidity: Liquidity;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
    };  

    /* State */
    
    private stable var nextMarketId: MarketId = 0;
    private stable var markets: Trie.Trie<MarketId, Market> = Trie.empty();

    /* API */
    
    // Create a market.
    public shared(msg) func create(market: Market): async MarketId {
        if (Principal.toText(msg.caller) == "2vxsx-fae") return 0;

        let marketId: MarketId = nextMarketId;
        let author: Author = Principal.toText(msg.caller);

        let newMarket: Market = {
            id = marketId;
            title = market.title;
            description = market.description;
            yesProb = market.yesProb;
            noProb = market.noProb;
            liquidity = market.liquidity;
            startDate = Time.now();
            endDate = market.endDate;
            author = author;
        };

        nextMarketId += 1;

        markets := Trie.replace(
            markets,
            key(marketId),
            Nat32.equal,
            ?newMarket,
        ).0;

        return marketId;
    };

    // Read a market.
    public query func read(marketId: MarketId): async ?Market {
        let result = Trie.find(markets, key(marketId), Nat32.equal);
        return result;        
    };

    // Read all markets.
    public query func readAll(): async [Market] {
        let result = Trie.toArray(markets, getMarket);
        return result;
    };

    // Update a market.
    public func update(marketId: MarketId, market: Market): async Bool {
        let result = Trie.find(markets, key(marketId), Nat32.equal);
        let exists = Option.isSome(result);
        if (exists) {
            markets := Trie.replace(
                markets,
                key(marketId),
                Nat32.equal,
                ?market,
            ).0;
        };
        return exists;
    };

    // Delete a market.
    public func delete(marketId: MarketId): async Bool {
        let result = Trie.find(markets, key(marketId), Nat32.equal);
        let exists = Option.isSome(result);
        if (exists) {
            markets := Trie.replace(
                markets,
                key(marketId),
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

    // Create a trie key from a market identifier.
    private func key(x: MarketId) : Trie.Key<MarketId> {
        return { hash = x; key = x };
    };

    private func getMarket(k: MarketId, v: Market): Market {
        return v;
    };
};
