import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Float "mo:base/Float";
import List "mo:base/List";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Array "mo:base/Array";

shared(msg) actor class Market() {
    /* Types */

    public type Title = Text;
    public type Description = Text;
    public type Author = Text;
    public type MarketId = Nat32;
    public type UserId = Text;
    public type Shares = Nat64;
    public type Probability = Nat64;
    public type Balance = Nat64;

    public type UserTokens = {
        marketId: MarketId;
        yesBalance: Balance;
        noBalance: Balance;
    };

    public type UserShares = {
        marketId: MarketId;
        shares: Shares;
    };

    public type User = {
        var id: UserId; // Principal.
        var seerBalance: Balance;
        var liquidityProviderFor: [UserShares];
        var marketTokens: [UserTokens];
    };

    public type UserResult = {
        id: UserId; // Principal.
        seerBalance: Balance;
        liquidityProviderFor: [UserShares];
        marketTokens: [UserTokens];
    };

    public type MarketInitData = {
        title: Title;
        description: Description;
        yesProb: Probability;
        noProb: Probability;
        liquidity: Balance;
        endDate: Time.Time;
    };

    public type Market = {
        id: MarketId;    
        title: Title;
        description: Description;
        yesProb: Probability;
        noProb: Probability;
        liquidity: Balance;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        blockTimestampLast: Time.Time;
        reserveYes: Balance;
        reserveNo: Balance;
        kLast: Balance; // sqrt(reserve0 * reserve1)
        totalShares: Shares;
        providers: [Text]; // list of principals
    };  

    /* State */
    
    private stable var nextMarketId: MarketId = 0;
    private stable var anon: Text = "2vxsx-fae";
   
    private stable var markets: Trie.Trie<MarketId, Market> = Trie.empty();
    private stable var users: Trie.Trie<UserId, User> = Trie.empty();

    /* API */

    // Get or create new user.
    public shared(msg) func getOrCreateUser(): async ?UserResult {
        let userId = Principal.toText(msg.caller);
        if (userId == anon) return null; // User needs to login.

        var result: ?User = Trie.find(users, userKey(userId), Text.equal);

        switch (result) {
            case null {
                // Create user because it does not exist.
                let userResult: ?UserResult = ?{
                    id = userId;
                    seerBalance = 1000; // Airdrop
                    liquidityProviderFor = [];
                    marketTokens = [];
                };

                return userResult;
            };
            case (?user) {
                // Copy user as static type.
                let userResult: ?UserResult = ?userToUserResult(user);
                return userResult;
            };
        };

        return null;
    };

    // Read all users.
    public query func readAllUsers(): async [UserResult] {
        let result = Trie.toArray(users, getUserResult);
        return result;
    };

    // Create a market.
    public shared(msg) func createMarket(marketInitData: MarketInitData): async Nat32 {
        let author = Principal.toText(msg.caller);

        // Debug.print("Executing createMarket");

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

        // Update provider.
        let result = Trie.find(users, userKey(author), Text.equal);

        switch (result) {
            case null {
                let r = await getOrCreateUser();
                switch (r) {
                    case null {
                        return 0;
                    };
                    case (?u) {
                        var user: User =  userResultToUser(u);
                        user.liquidityProviderFor := 
                            Array.append(user.liquidityProviderFor, [
                                {
                                    marketId = marketId;
                                    shares = shares;
                                }
                            ]);
                        users := Trie.replace(
                            users,
                            userKey(user.id),
                            Text.equal,
                            ?user,
                        ).0;
                    };
                };
            };
            case (?user) {
                user.liquidityProviderFor := 
                    Array.append(user.liquidityProviderFor, [
                        {
                            marketId = marketId;
                            shares = shares;
                        }
                    ]);
                users := Trie.replace(
                    users,
                    userKey(author),
                    Text.equal,
                    ?user,
                ).0;
            };
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
    public query func readMarket(marketId: MarketId): async ?Market {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        return result;        
    };

    // Read all markets.
    public query func readAllMarkets(): async [Market] {
        let result = Trie.toArray(markets, getMarket);
        return result;
    };

    // Update a market.
    public func updateMarket(marketId: MarketId, market: Market): async Bool {
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
    public func deleteMarket(marketId: MarketId): async Bool {
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

    private func userKey(x: UserId) : Trie.Key<UserId> {
        return { hash = Text.hash(x); key = x };
    };

    private func marketKey(x: MarketId) : Trie.Key<MarketId> {
        return { hash = x; key = x };
    };

    private func getMarket(k: MarketId, v: Market): Market {
        return v;
    };

    private func userResultToUser(u: UserResult): User {
        let user = {
            var id = u.id;
            var seerBalance = u.seerBalance;
            var liquidityProviderFor = u.liquidityProviderFor;
            var marketTokens = u.marketTokens;
        };
        return user;
    };

    private func userToUserResult(u: User): UserResult {
        let userResult = {
            id = u.id;
            seerBalance = u.seerBalance;
            liquidityProviderFor = u.liquidityProviderFor;
            marketTokens = u.marketTokens;
        };
        return userResult;
    };

    private func getUserResult(k: UserId, v: User): UserResult {
        return userToUserResult(v);
    };
};
