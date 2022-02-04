import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import List "mo:base/List";
import Option "mo:base/Option";
import Trie "mo:base/Trie";

actor {
    /* Types */

    public type MarketId = Nat32;
    public type Title = Text;
    public type Description = Text;
    public type Probability = Nat32;

    public type Outcome = {
        id: MarketId;
        title: Title;
        probability: Probability; // from 0 to 100.
    };

    public type Market = {
        id: MarketId;    
        title: Title;
        description: Description;
        outcomes: List.List<Outcome>;
    };

    /* State */
    
    private stable var nextMarketId: MarketId = 0;
    private stable var markets: Trie.Trie<MarketId, Market> = Trie.empty();

    /* API */
    
    // Create a market.
    public func create(market: Market): async MarketId {
        let marketId = nextMarketId;
        nextMarketId += 1;

        markets := Trie.replace(
            markets,
            key(nextMarketId),
            Nat32.equal,
            ?market,
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
        let result = Trie.toArray(markets, getTitle);
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

    /**
    * Utilities
    */

    // Create a trie key from a market identifier.
    private func key(x: MarketId) : Trie.Key<MarketId> {
        return { hash = x; key = x };
    };

    private func getTitle(k: MarketId, v: Market): Market {
        return v;
    };
};
