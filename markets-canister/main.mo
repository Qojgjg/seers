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
        var yesProb: Probability;
        var noProb: Probability;
        var liquidity: Balance;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        var blockTimestampLast: Time.Time;
        var reserveYes: Balance;
        var reserveNo: Balance;
        var kLast: Balance; // sqrt(reserve0 * reserve1)
        var totalShares: Shares;
        var providers: [Text]; // list of principals
    };

    public type MarketResult = {
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

    // Read all users.
    public query func readAllUsers(): async [UserResult] {
        let result = Trie.toArray(users, getUserResult);
        return result;
    };

    // Delete all users.
    public func deleteAllUsers(): async () {
        users := Trie.empty();
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
            var yesProb = marketInitData.yesProb;
            var noProb = marketInitData.noProb;
            var liquidity = marketInitData.liquidity;
            startDate = Time.now();
            endDate = marketInitData.endDate;
            author = author;
            var blockTimestampLast = Time.now();
            var reserveYes = reserveYes; 
            var reserveNo = reserveNo;
            var kLast = reserveYes * reserveNo;
            var totalShares = shares;
            var providers = [author];
        };

        // Update provider.
        let userOption = getOrCreateUser(author);
                
        switch (userOption) {
            case null {
                return 0;
            };
            case (?u) {
                var user: User = userResultToUser(u);
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
    public query func readMarket(marketId: MarketId): async ?MarketResult {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        return Option.map(result, marketToMarketResult);        
    };

    // Read all markets.
    public query func readAllMarkets(): async [MarketResult] {
        let result = Trie.toArray(markets, getMarket);
        return Array.map(result, marketToMarketResult);
    };

    // Update a market.
    public func updateMarket(marketId: MarketId, market: MarketResult): async Bool {
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        let exists = Option.isSome(result);
        if (exists) {
            let newMarket = marketResultToMarket(market);
            markets := Trie.replace(
                markets,
                marketKey(marketId),
                Nat32.equal,
                ?newMarket,
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

    // Add liquidity to this market by calling user.
    public shared(msg) func addLiquidity(marketId: MarketId, value: Balance): async Bool {
        Debug.print(Text.concat("addLiquidity to ", Nat32.toText(marketId)));
        let caller = Principal.toText(msg.caller);
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (result) {
            case null {
                // Market does not exist? WTF!
                return false;
            };
            case (?market) {
                let newReserveYes = market.reserveYes + (value * 50) / market.yesProb;
                let newReserveNo = market.reserveNo + (value * 50) / market.noProb;

                // TODO: this wraps on overflow. Should I use Int64 directly?
                let newTotalShares = Int64.toNat64(Float.toInt64(Float.sqrt(
                    Float.fromInt64(Int64.fromNat64(newReserveNo))
                    * Float.fromInt64(Int64.fromNat64(newReserveYes)))));

                let newLiquidity = market.liquidity + value;
                let userShares = newTotalShares - market.totalShares;
                
                let callerIsProvider = Array.find(market.providers, func (u: UserId): Bool {
                    u == caller;
                });

                var newProviders = market.providers;
                let userOption = getOrCreateUser(caller);
                
                switch (userOption) {
                    case null {
                        return false;
                    };
                    case (?u) {
                        var user: User = userResultToUser(u);
                        user.liquidityProviderFor := 
                            Array.append(user.liquidityProviderFor, [
                                {
                                    marketId = market.id;
                                    shares = userShares;
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

                if (callerIsProvider == null) {
                    newProviders := Array.append(newProviders, [caller])
                };

                let newMarket: Market = {
                    id = market.id;
                    title = market.title;
                    description = market.description;
                    var yesProb = market.yesProb;
                    var noProb = market.noProb;
                    var liquidity = newLiquidity;
                    startDate = market.startDate;
                    endDate = market.endDate;
                    author = market.author;
                    var blockTimestampLast = Time.now();
                    var reserveYes = newReserveYes; 
                    var reserveNo = newReserveNo;
                    var kLast = newReserveYes * newReserveNo;
                    var totalShares = newTotalShares;
                    var providers = newProviders;
                };

                markets := Trie.replace(
                    markets,
                    marketKey(newMarket.id),
                    Nat32.equal,
                    ?newMarket,
                ).0;

                return true;
            };
        };
    };

    // Remove all liquidity provided in this market by calling user.
    public shared(msg) func removeLiquidity(marketId: MarketId): async Bool {
        Debug.print(Text.concat("removeLiquidity for ", Nat32.toText(marketId)));

        // If user is anon we abort.
        let author = Principal.toText(msg.caller);
        assert(author != anon);

        // Get user and market state.
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        let userOpt = Trie.find(users, userKey(author), Text.equal);

        switch (userOpt) {
            case null {
                // If user is not in state we abort.
                Debug.print(Text.concat(
                    "User not in state ", 
                    author
                ));
                return false;
            };
            case (?user) {

                switch (marketOpt) {
                    case null {
                        // If market is not in state we abort.
                        Debug.print(Text.concat(
                            "Market not in state ", 
                            ""
                        ));
                        return false;
                    };
                    case (?market) {
                        // All good, let's do it.
                        // Loop throught user shares and find market data.
                        
                        let newSharesBuffer: Buffer.Buffer<UserShares> 
                            = Buffer.Buffer(user.liquidityProviderFor.size() - 1);
                        
                        for (userShare in user.liquidityProviderFor.vals()) {
                            if (userShare.marketId != marketId) {
                                // Other shares are kept.
                                newSharesBuffer.add(userShare);
                            } else {
                                // Calculate percentage of user shares from total.
                                let percent = userShare.shares / market.totalShares;
                                let userLiquidity = market.liquidity * percent;

                                // Remove user liquidity from total.                    
                                market.liquidity := market.liquidity - userLiquidity;

                                // Calculate tokens we need to give back.
                                let userYesTokens = market.reserveYes * percent;
                                let userNoTokens = market.reserveNo * percent;
            
                                // Remove tokens from total.
                                market.reserveYes := market.reserveYes - userYesTokens;
                                market.reserveNo := market.reserveNo - userNoTokens; 

                                // Add tokens to user.
                                let userTokens: UserTokens = {
                                    marketId = marketId;
                                    yesBalance = userYesTokens;
                                    noBalance = userNoTokens;
                                };
                                user.marketTokens := Array.append(user.marketTokens, [userTokens]);

                                // Remove user shares from total shares.
                                market.totalShares := market.totalShares - userShare.shares;
                                
                                // Remove user from providers list.
                                market.providers := 
                                    Array.filter(market.providers, func (u: UserId): Bool {
                                        u != author;
                                    });
                            };
                        };
                        user.liquidityProviderFor := newSharesBuffer.toArray();

                        users := Trie.replace(
                            users,
                            userKey(user.id),
                            Text.equal,
                            ?user,
                        ).0;

                        markets := Trie.replace(
                            markets,
                            marketKey(market.id),
                            Nat32.equal,
                            ?market,
                        ).0;

                        return true;
                    };
                };
            };
        };
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

    private func marketResultToMarket(m: MarketResult): Market {
        let market = {
            id = m.id;    
            title = m.title;
            description = m.description;
            var yesProb = m.yesProb;
            var noProb = m.noProb;
            var liquidity = m.liquidity;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            var blockTimestampLast = m.blockTimestampLast;
            var reserveYes = m.reserveYes;
            var reserveNo = m.reserveNo;
            var kLast = m.kLast;
            var totalShares = m.totalShares;
            var providers = m.providers;
        };

        return market;
    };

    private func marketToMarketResult(m: Market): MarketResult {
        let market = {
            id = m.id;    
            title = m.title;
            description = m.description;
            yesProb = m.yesProb;
            noProb = m.noProb;
            liquidity = m.liquidity;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            blockTimestampLast = m.blockTimestampLast;
            reserveYes = m.reserveYes;
            reserveNo = m.reserveNo;
            kLast = m.kLast;
            totalShares = m.totalShares;
            providers = m.providers;
        };

        return market;
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

    // Get or create new user.
    private func getOrCreateUser(userId: UserId): ?UserResult {
        if (userId == anon) return null;

        var result: ?User = Trie.find(users, userKey(userId), Text.equal);

        switch (result) {
            case null {
                // Create user because it does not exist.
                let user: User = {
                    var id = userId;
                    var seerBalance = 1000; // Airdrop
                    var liquidityProviderFor = [];
                    var marketTokens = [];
                };

                Debug.print(Text.concat("Creating user with id ", userId));

                users := Trie.replace(
                    users,
                    userKey(user.id),
                    Text.equal,
                    ?user,
                ).0;

                return ?userToUserResult(user);
            };
            case (?user) {
                // Copy user as static type.
                let userResult: ?UserResult = ?userToUserResult(user);
                return userResult;
            };
        };

        return null;
    };
};
