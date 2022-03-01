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
        // assert(marketInitData.yesProb + marketInitData.noProb == 100);
        assert(marketInitData.liquidity >= 1000);
        assert(marketInitData.title != "");
        assert(marketInitData.description != "");
        assert(marketInitData.endDate > Time.now());

        let marketId = nextMarketId;
        let reserveYes = marketInitData.liquidity * 50 / marketInitData.yesProb;
        let reserveNo = marketInitData.liquidity * 50 / marketInitData.noProb;

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
        var user = getOrCreateUser(author);
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


    // Sell Yes tokens from caller back to the market.
    public shared(msg) func sellYes(marketId: MarketId, value: Balance): async ?Balance {
        Debug.print(Text.concat("sellYes from ", Nat32.toText(marketId)));
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                var user = getOrCreateUser(caller);
                var marketTokensOpt = Array.find(user.marketTokens,
                    func (ut: UserTokens): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        // No tokens to sell.
                        return null;
                    };
                    case (?marketTokens) {
                        if (marketTokens.yesBalance < value) {
                            // No enought tokens to sell.
                            return null;
                        };

                        market.reserveYes := market.reserveYes + value;
                        let newReserveNo = market.kLast / market.reserveYes;
                        let tokensOut = market.reserveNo - newReserveNo;
                        market.reserveNo := newReserveNo;
                        let totalReserve = market.reserveNo + market.reserveYes;
                        market.noProb := market.reserveYes * 100 / totalReserve;
                        market.yesProb := 100 - market.noProb;

                        let newLiquidity1 = floatToNat64(
                            Float.floor(nat64ToFloat(market.reserveYes) * nat64ToFloat(market.yesProb) / 50.0 + 0.5)
                        );
                        let newLiquidity2 = floatToNat64(
                            Float.floor(nat64ToFloat(market.reserveNo) * nat64ToFloat(market.noProb) / 50.0 + 0.5)
                        );
                        let newLiquidity = Nat64.max(newLiquidity1, newLiquidity2);
                        let liquidityOut = market.liquidity - newLiquidity;
                        market.liquidity := newLiquidity;

                        markets := Trie.replace(
                            markets,
                            marketKey(market.id),
                            Nat32.equal,
                            ?market,
                        ).0;

                        user.marketTokens := Array.mapFilter(user.marketTokens, 
                            func (ut: UserTokens): ?UserTokens {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserTokens = {
                                        marketId = market.id;
                                        noBalance = ut.noBalance;
                                        yesBalance = ut.yesBalance - value;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );

                        users := Trie.replace(
                            users,
                            userKey(user.id),
                            Text.equal,
                            ?user,
                        ).0;

                        return ?liquidityOut;
                    };
                };

                return null;
            };
        };
    };

    // Sell No tokens from caller back to the market.
    public shared(msg) func sellNo(marketId: MarketId, value: Balance): async ?Balance {
        Debug.print(Text.concat("sellNo from ", Nat32.toText(marketId)));
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                var user = getOrCreateUser(caller);
                var marketTokensOpt = Array.find(user.marketTokens,
                    func (ut: UserTokens): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        // No tokens to sell.
                        return null;
                    };
                    case (?marketTokens) {
                        if (marketTokens.noBalance < value) {
                            // No enought tokens to sell.
                            return null;
                        };

                        market.reserveNo := market.reserveNo + value;
                        let newReserveYes = market.kLast / market.reserveNo;
                        let tokensOut = market.reserveYes - newReserveYes;
                        market.reserveYes := newReserveYes;
                        let totalReserve = market.reserveYes + market.reserveNo;
                        market.yesProb := market.reserveNo * 100 / totalReserve;
                        market.noProb := 100 - market.yesProb;

                        let newLiquidity1 = floatToNat64(
                            Float.floor(nat64ToFloat(market.reserveNo) * nat64ToFloat(market.noProb) / 50.0 + 0.5)
                        );
                        let newLiquidity2 = floatToNat64(
                            Float.floor(nat64ToFloat(market.reserveYes) * nat64ToFloat(market.yesProb) / 50.0 + 0.5)
                        );
                        let newLiquidity = Nat64.max(newLiquidity1, newLiquidity2);
                        let liquidityOut = market.liquidity - newLiquidity;
                        market.liquidity := newLiquidity;

                        markets := Trie.replace(
                            markets,
                            marketKey(market.id),
                            Nat32.equal,
                            ?market,
                        ).0;

                        user.marketTokens := Array.mapFilter(user.marketTokens, 
                            func (ut: UserTokens): ?UserTokens {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserTokens = {
                                        marketId = market.id;
                                        noBalance = ut.noBalance - value;
                                        yesBalance = ut.yesBalance;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );

                        users := Trie.replace(
                            users,
                            userKey(user.id),
                            Text.equal,
                            ?user,
                        ).0;

                        return ?liquidityOut;
                    };
                };

                return null;
            };
        };
    };

    public shared(msg) func buyNo(marketId: MarketId, value: Balance): async ?Balance {
        Debug.print(Text.concat("buyNo from ", Nat32.toText(marketId)));
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                let newYesTokens = value * 100 / market.yesProb;
                market.reserveYes := market.reserveYes + newYesTokens;
                let newReserveNo = market.kLast / market.reserveYes;
                let tokensOut = market.reserveNo - newReserveNo;
                market.reserveNo := newReserveNo;
                market.liquidity := market.liquidity + value;
                 
                let totalReserve = market.reserveYes + market.reserveNo;
                market.yesProb := market.reserveNo * 100 / totalReserve;
                market.noProb := 100 - market.yesProb;

                markets := Trie.replace(
                    markets,
                    marketKey(market.id),
                    Nat32.equal,
                    ?market,
                ).0;

                var user = getOrCreateUser(caller);
                
                var marketTokensOpt = Array.find(user.marketTokens,
                    func (ut: UserTokens): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let newUserToken: UserTokens = {
                            marketId = market.id;
                            yesBalance = 0;
                            noBalance = tokensOut;
                        };
                        user.marketTokens := Array.append(user.marketTokens, [
                            newUserToken 
                        ]);
                    };
                    case (?marketTokens) {
                        user.marketTokens := Array.mapFilter(user.marketTokens, 
                            func (ut: UserTokens): ?UserTokens {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserTokens = {
                                        marketId = market.id;
                                        noBalance = ut.noBalance + tokensOut;
                                        yesBalance = ut.yesBalance;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );
                    };
                };

                users := Trie.replace(
                    users,
                    userKey(user.id),
                    Text.equal,
                    ?user,
                ).0;

                return ?tokensOut;
            };
        };
    };


    public shared(msg) func buyYes(marketId: MarketId, value: Balance): async ?Balance {
        Debug.print(Text.concat("buyYes from ", Nat32.toText(marketId)));
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                let newNoTokens = value * 100 / market.noProb;
                market.reserveNo := market.reserveNo + newNoTokens;
                let newReserveYes = market.kLast / market.reserveNo;
                let tokensOut = market.reserveYes - newReserveYes;
                market.reserveYes := newReserveYes;
                market.liquidity := market.liquidity + value;
                
                let totalReserve = market.reserveYes + market.reserveNo;
                market.yesProb := market.reserveNo * 100 / totalReserve;
                market.noProb := 100 - market.yesProb;

                markets := Trie.replace(
                    markets,
                    marketKey(market.id),
                    Nat32.equal,
                    ?market,
                ).0;

                var user = getOrCreateUser(caller);
                
                var marketTokensOpt = Array.find(user.marketTokens,
                    func (ut: UserTokens): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let newUserToken: UserTokens = {
                            marketId = market.id;
                            yesBalance = tokensOut;
                            noBalance = 0;
                        };
                        user.marketTokens := Array.append(user.marketTokens, [
                            newUserToken 
                        ]);
                    };
                    case (?marketTokens) {
                        user.marketTokens := Array.mapFilter(user.marketTokens, 
                            func (ut: UserTokens): ?UserTokens {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserTokens = {
                                        marketId = market.id;
                                        yesBalance = ut.yesBalance + tokensOut;
                                        noBalance = ut.noBalance;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );
                    };
                };

                users := Trie.replace(
                    users,
                    userKey(user.id),
                    Text.equal,
                    ?user,
                ).0;

                return ?tokensOut;
            };
        };
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
                market.liquidity := market.liquidity + value;

                market.reserveYes := market.liquidity * 50 / market.yesProb;
                market.reserveNo := market.liquidity * 50 / market.noProb;
                market.kLast := market.reserveYes * market.reserveNo;

                // TODO: this wraps on overflow. Should I use Int64 directly?
                let newTotalShares = Int64.toNat64(Float.toInt64(Float.sqrt(
                    Float.fromInt64(Int64.fromNat64(market.reserveNo))
                    * Float.fromInt64(Int64.fromNat64(market.reserveYes)))));

                let userShares = newTotalShares - market.totalShares;
                market.totalShares := newTotalShares;
                market.blockTimestampLast := Time.now();

                let callerIsProvider = Array.find(market.providers, func (u: UserId): Bool {
                    u == caller;
                });

                var user = getOrCreateUser(caller);
                
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

                if (callerIsProvider == null) {
                    market.providers := Array.append(market.providers, [caller])
                };

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

    // Get user data.
    public shared(msg) func getUser(userId: UserId): async UserResult {
        let caller = Principal.toText(msg.caller);
        assert(caller == userId);
        let user = getOrCreateUser(userId);
        return userToUserResult(user);
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

    private func floatToNat64(f: Float): Nat64 {
        return Int64.toNat64(Float.toInt64(f));
    };

    private func nat64ToFloat(n: Nat64): Float {
        return Float.fromInt64(Int64.fromNat64(n));
    };

    // Get or create new user.
    private func getOrCreateUser(userId: UserId): User {
        assert(userId != anon);

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

                return user;
            };
            case (?user) {
                return user;
            };
        };
    };
};
