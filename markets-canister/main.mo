import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Float "mo:base/Float";
import List "mo:base/List";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Hash "mo:base/Hash";

shared({ caller = initializer }) actor class Market() {
    /* Types */

    public type Title = Text;
    public type Description = Text;
    public type Url = Text;
    public type Author = Text;
    public type MarketId = Nat32;
    public type UserId = Text;
    public type Shares = Int;
    public type Probability = Int;
    public type Balance = Int;

    public type MarketState = {
        #pending: ();
        #open: ();
        #closed: ();
        #resolved: Bool;
    };

    public type UserMarket = {
        marketId: MarketId;
        marketTitle: Title;
        yesBalance: Balance;
        noBalance: Balance;
        shares: Shares;
        state: MarketState;
    };

    public type User = {
        var id: UserId; // Principal.
        var seerBalance: Balance;
        var markets: [UserMarket];
    };

    public type UserResult = {
        id: UserId; // Principal.
        seerBalance: Balance;
        markets: [UserMarket];
    };

    public type MarketInitData = {
        title: Title;
        description: Description;
        yesProb: Probability;
        noProb: Probability;
        liquidity: Balance;
        endDate: Time.Time;
        imageUrl: Url;
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
        var imageUrl: Url;
        var state: MarketState;
        var volume: Balance;
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
        imageUrl: Url;
        state: MarketState;
        volume: Balance;
    };  

    /* State */
    
    private stable var nextMarketId: MarketId = 0;
    private stable var anon: Text = "2vxsx-fae";
    private stable var markets: Trie.Trie<MarketId, Market> = Trie.empty();
    private stable var users: Trie.Trie<UserId, User> = Trie.empty();

    /* API */

    // Read all users.
    public query func readAllUsers(): async [UserResult] {
        let result = Trie.toArray(users, func (id: UserId, u: User): UserResult {
            return userToUserResult(u);
        });
        return result;
    };

    // Delete all users.
    public func deleteAllUsers(): async () {
        users := Trie.empty();
    };

    // Approve a market.
    public shared(msg) func approveMarket(marketId: MarketId): async () {
        assert(msg.caller == initializer); // Root call.
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        switch (marketOpt) {
            case (null) {
                return;
            };
            case (?market) {
                market.state := #open;
            };
        };
    }; 

    public shared(msg) func claimTokens(marketId: MarketId): async Balance {
        let userId = Principal.toText(msg.caller);
        assert(userId != anon);

        let userOpt = Trie.find(users, userKey(userId), Text.equal);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);

        switch (marketOpt) {
            case (null) {
                return 0;
            };
            case (?market) {
                switch (market.state) {
                    case (#resolved(yes)) {
                        switch (userOpt) {
                            case (null) {
                                return 0;
                            };
                            case (?user) {
                                var reward: Balance = 0;
                                user.markets := Array.mapFilter(user.markets, 
                                    func (ut: UserMarket): ?UserMarket {
                                        if (ut.marketId != market.id) {
                                            return ?ut;
                                        } else {
                                            if (yes) {
                                                reward := ut.yesBalance;
                                                user.seerBalance := user.seerBalance + reward;
                                            } else {
                                                reward := ut.noBalance;
                                                user.seerBalance := user.seerBalance + reward;
                                            };
                                            return null;
                                        };
                                    }
                                );
                                return reward;
                            };
                        };
                    };
                    case (_) {
                        return 0;
                    };
                };
            };
        };
    };

    public shared(msg) func resolveMarket(marketId: MarketId, result: Bool): async Bool {
        assert(msg.caller == initializer); // Root call.
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        switch (marketOpt) {
            case (null) {
                return false;
            };
            case (?market) {
                market.state := #resolved(result);
                return true;
            };
        };

        return false;
    };

    // Create a market.
    public shared(msg) func createMarket(marketInitData: MarketInitData): async MarketId {
        let author = Principal.toText(msg.caller);
        assert(author != anon);
        // assert(marketInitData.yesProb + marketInitData.noProb == 100);
        assert(marketInitData.liquidity >= 1000);
        assert(marketInitData.title != "");
        assert(marketInitData.description != "");
        assert(marketInitData.imageUrl != "");
        assert(marketInitData.endDate > Time.now());

        let marketId = nextMarketId;
        let reserveYes = marketInitData.liquidity * 50 / marketInitData.yesProb;
        let reserveNo = marketInitData.liquidity * 50 / marketInitData.noProb;

        let shares = Float.toInt(Float.sqrt(
            Float.fromInt(reserveNo)
            * Float.fromInt(reserveYes)));

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
            var imageUrl = marketInitData.imageUrl;
            var state = #pending;
            var volume = 0;
        };

        // Update provider.
        var user = getOrCreateUser(author);
        
        let userMarket: UserMarket = {
            marketId = marketId;
            marketTitle = marketInitData.title;
            yesBalance = 0;
            noBalance = 0;
            shares = shares;
            state = #pending;
        };

        user.markets := Array.append(user.markets, [userMarket]);
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
        return Array.mapFilter(result, keepOpenMarkets);
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
    public shared(msg) func sellYes(marketId: MarketId, value: Balance, save: Bool): async ?Balance {
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return null;
                };

                var user = getOrCreateUser(caller);
                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
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

                        let newLiquidity1 = Float.toInt(
                            Float.floor(Float.fromInt(market.reserveYes) * Float.fromInt(market.yesProb) / 50.0 + 0.5)
                        );
                        let newLiquidity2 = Float.toInt(
                            Float.floor(Float.fromInt(market.reserveNo) * Float.fromInt(market.noProb) / 50.0 + 0.5)
                        );
                        let newLiquidity = Int.max(newLiquidity1, newLiquidity2);
                        let liquidityOut = market.liquidity - newLiquidity;
                        market.volume := market.volume + liquidityOut;
                        market.liquidity := newLiquidity;

                        
                        user.markets := Array.mapFilter(user.markets, 
                            func (ut: UserMarket): ?UserMarket {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserMarket = {
                                        marketId = market.id;
                                        marketTitle = market.title;
                                        noBalance = ut.noBalance;
                                        yesBalance = ut.yesBalance - value;
                                        shares = ut.shares;
                                        state = ut.state;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );

                        user.seerBalance := user.seerBalance + liquidityOut;

                        return ?liquidityOut;
                    };
                };

                return null;
            };
        };
    };

    // Sell No tokens from caller back to the market.
    public shared(msg) func sellNo(marketId: MarketId, value: Balance, save: Bool): async ?Balance {
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return null;
                };

                var user = getOrCreateUser(caller);
                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
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

                        let newLiquidity1 = Float.toInt(
                            Float.floor(Float.fromInt(market.reserveNo) * Float.fromInt(market.noProb) / 50.0 + 0.5)
                        );
                        let newLiquidity2 = Float.toInt(
                            Float.floor(Float.fromInt(market.reserveYes) * Float.fromInt(market.yesProb) / 50.0 + 0.5)
                        );
                        let newLiquidity = Int.max(newLiquidity1, newLiquidity2);
                        let liquidityOut = market.liquidity - newLiquidity;
                        market.liquidity := newLiquidity;
                        market.volume := market.volume + liquidityOut;

                        user.markets := Array.mapFilter(user.markets, 
                            func (ut: UserMarket): ?UserMarket {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserMarket = {
                                        marketId = market.id;
                                        marketTitle = market.title;
                                        noBalance = ut.noBalance - value;
                                        yesBalance = ut.yesBalance;
                                        shares = ut.shares;
                                        state = ut.state;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );
                        user.seerBalance := user.seerBalance + liquidityOut;

                        return ?liquidityOut;
                    };
                };

                return null;
            };
        };
    };

    public shared(msg) func buyNo(marketId: MarketId, value: Balance, save: Bool): async ?Balance {
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return null;
                };

                let newYesTokens = value * 100 / market.yesProb;
                let newReserveYes = market.reserveYes + newYesTokens;
                let newReserveNo = market.kLast / newReserveYes;
                let tokensOut = market.reserveNo - newReserveNo;

                if (not save) {
                    return ?tokensOut;
                };

                market.reserveYes := newReserveYes;
                market.reserveNo := newReserveNo;
                market.liquidity := market.liquidity + value;
                market.volume := market.volume + value;
                 
                let totalReserve = market.reserveYes + market.reserveNo;
                market.yesProb := market.reserveNo * 100 / totalReserve;
                market.noProb := 100 - market.yesProb;

                var user = getOrCreateUser(caller);
                
                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let newUserMarket: UserMarket = {
                            marketId = market.id;
                            marketTitle = market.title;
                            yesBalance = 0;
                            noBalance = tokensOut;
                            shares = 0;
                            state = market.state;
                        };
                        user.markets := Array.append(user.markets, [newUserMarket]);
                    };
                    case (?marketTokens) {
                        user.markets := Array.mapFilter(user.markets, 
                            func (ut: UserMarket): ?UserMarket {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserMarket: UserMarket = {
                                        marketId = market.id;
                                        marketTitle = market.title;
                                        noBalance = ut.noBalance + tokensOut;
                                        yesBalance = ut.yesBalance;
                                        shares = ut.shares;
                                        state = ut.state;
                                    };
                                    return ?newUserMarket;
                                };
                            }
                        );
                    };
                };

                user.seerBalance := user.seerBalance - value;

                return ?tokensOut;
            };
        };
    };


    public shared(msg) func buyYes(marketId: MarketId, value: Balance, save: Bool): async ?Balance {
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return null;
                };

                let newNoTokens = value * 100 / market.noProb;
                let newReserveNo = market.reserveNo + newNoTokens;
                let newReserveYes = market.kLast / newReserveNo;
                let tokensOut = market.reserveYes - newReserveYes;

                if (not save) {
                    return ?tokensOut;
                };

                market.reserveNo := newReserveNo;
                market.reserveYes := newReserveYes;
                market.liquidity := market.liquidity + value;
                market.volume := market.volume + value;
                
                let totalReserve = market.reserveYes + market.reserveNo;
                market.yesProb := market.reserveNo * 100 / totalReserve;
                market.noProb := 100 - market.yesProb;

                var user = getOrCreateUser(caller);                
                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let newUserToken: UserMarket = {
                            marketId = market.id;
                            marketTitle = market.title;
                            yesBalance = tokensOut;
                            noBalance = 0;
                            shares = 0;
                            state = market.state;
                        };
                        user.markets := Array.append(user.markets, [
                            newUserToken 
                        ]);
                    };
                    case (?marketTokens) {
                        user.markets := Array.mapFilter(user.markets, 
                            func (ut: UserMarket): ?UserMarket {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newUserToken: UserMarket = {
                                        marketId = market.id;
                                        marketTitle = market.title;
                                        yesBalance = ut.yesBalance + tokensOut;
                                        noBalance = ut.noBalance;
                                        shares = ut.shares;
                                        state = ut.state;
                                    };
                                    return ?newUserToken;
                                };
                            }
                        );
                    };
                };

                user.seerBalance := user.seerBalance - value;

                return ?tokensOut;
            };
        };
    };

    // Add liquidity to this market by calling user.
    public shared(msg) func addLiquidity(marketId: MarketId, value: Balance): async Bool {
        let caller = Principal.toText(msg.caller);
        let result = Trie.find(markets, marketKey(marketId), Nat32.equal);
        
        switch (result) {
            case null {
                // Market does not exist? WTF!
                return false;
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return false;
                };

                market.liquidity := market.liquidity + value;
                market.volume := market.volume + value;
                market.reserveYes := market.liquidity * 50 / market.yesProb;
                market.reserveNo := market.liquidity * 50 / market.noProb;
                market.kLast := market.reserveYes * market.reserveNo;

                // TODO: this wraps on overflow. Should I use Int64 directly?
                let newTotalShares = Float.toInt(Float.sqrt(
                    Float.fromInt(market.reserveNo)
                    * Float.fromInt(market.reserveYes)));

                let userShares = newTotalShares - market.totalShares;
                market.totalShares := newTotalShares;
                market.blockTimestampLast := Time.now();

                let callerIsProvider = Array.find(market.providers, func (u: UserId): Bool {
                    u == caller;
                });

                var user = getOrCreateUser(caller);
                
                let userMarket: UserMarket = {
                    marketId = market.id;
                    marketTitle = market.title;
                    yesBalance = 0;
                    noBalance = 0;
                    shares = userShares;
                    state = market.state;
                };

                user.markets := Array.append(user.markets, [userMarket]);
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
    public query func getUserResult(userId: UserId): async ?UserResult {
        return Option.map(getUser(userId), userToUserResult);
    };

    // Create user.
    public shared(msg) func createUserResult(): async UserResult {
        let caller = Principal.toText(msg.caller);        
        return userToUserResult(createUser(caller));
    };

    // Remove all liquidity provided in this market by calling user.
    public shared(msg) func removeLiquidity(marketId: MarketId): async Bool {
        // If user is anon we abort.
        let author = Principal.toText(msg.caller);
        assert(author != anon);

        // Get user and market state.
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        let userOpt = Trie.find(users, userKey(author), Text.equal);

        switch (userOpt) {
            case null {
                // If user is not in state we abort.
                return false;
            };
            case (?user) {

                switch (marketOpt) {
                    case null {
                        // If market is not in state we abort.
                        return false;
                    };
                    case (?market) {
                        if (market.endDate < Time.now()) {
                            market.state := #closed;
                            return false;
                        };
                        // All good, let's do it.
                        // Loop throught user markets and and update this one.
                        
                        let newMarketsBuffer: Buffer.Buffer<UserMarket> 
                            = Buffer.Buffer(user.markets.size() - 1);
                        
                        for (userMarket in user.markets.vals()) {
                            if (userMarket.marketId != marketId) {
                                // Other markets are kept intact.
                                newMarketsBuffer.add(userMarket);
                            } else {
                                // Calculate percentage of user shares from total.
                                let percent = userMarket.shares / market.totalShares;
                                let userLiquidity = market.liquidity * percent;

                                // Remove user liquidity from total.                    
                                market.liquidity := market.liquidity - userLiquidity;
                                market.volume := market.volume + userLiquidity;

                                // Calculate tokens we need to give back.
                                let userYesTokens = market.reserveYes * percent;
                                let userNoTokens = market.reserveNo * percent;
            
                                // Remove tokens from total.
                                market.reserveYes := market.reserveYes - userYesTokens;
                                market.reserveNo := market.reserveNo - userNoTokens; 

                                let newUserMarket: UserMarket = {
                                    marketId = userMarket.marketId;
                                    marketTitle = userMarket.marketTitle;
                                    yesBalance = userYesTokens;
                                    noBalance = userNoTokens;
                                    shares = 0;
                                    state = userMarket.state;
                                };

                                // Remove user shares from total shares.
                                market.totalShares := market.totalShares - userMarket.shares;
                                
                                // Remove user from providers list.
                                market.providers := 
                                    Array.filter(market.providers, func (u: UserId): Bool {
                                        u != author;
                                    });

                                newMarketsBuffer.add(newUserMarket);
                            };
                        };
                        user.markets := newMarketsBuffer.toArray();

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
            var imageUrl = m.imageUrl;
            var state = m.state;
            var volume = m.volume;
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
            imageUrl = m.imageUrl;
            state = m.state;
            volume = m.volume;
        };
        return market;    
    };


    private func keepOpenMarkets(m: Market): ?MarketResult {
        switch (m.state) {
            case (#open) {
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
                    imageUrl = m.imageUrl;
                    state = m.state;
                    volume = m.volume;
                };
                return ?market;
            };
            case (_) {
                return null;
            };
        };
    };

    private func userResultToUser(u: UserResult): User {
        let user = {
            var id = u.id;
            var seerBalance = u.seerBalance;
            var markets = u.markets;
        };
        return user;
    };

    private func userToUserResult(u: User): UserResult {
        let userResult = {
            id = u.id;
            seerBalance = u.seerBalance;
            markets = u.markets;
        };
        return userResult;
    };

    private func getUser(userId: UserId): ?User {
        Trie.find(users, userKey(userId), Text.equal)
    };

    private func createUser(userId: UserId): User {
        let user: User = {
            var id = userId;
            var seerBalance = 1000; // Airdrop
            var markets = [];
        };

        users := Trie.replace(
            users,
            userKey(user.id),
            Text.equal,
            ?user,
        ).0;

        return user;
    };

    private func getOrCreateUser(u: UserId): User {
        let r = getUser(u);
        switch (r) {
            case null {
                return createUser(u);
            };
            case (?user) {
                return user;
            };
        };
    };
};
