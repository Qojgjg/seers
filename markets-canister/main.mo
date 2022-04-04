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
import Iter "mo:base/Iter";
import Result "mo:base/Result";

shared({ caller = initializer }) actor class Market() {
    /* Types */

    public type Title = Text;
    public type Description = Text;
    public type Url = Text;
    public type Author = Text;
    public type MarketId = Nat32;
    public type UserId = Text;
    public type Shares = Int;
    public type Probability = Float;
    public type Balance = Float;

    public type MarketState = {
        #pending: ();
        #open: ();
        #closed: ();
        #resolved: Nat;
    };

    public type UserMarket = {
        marketId: MarketId;
        marketTitle: Title;
        balances: [Balance];
        shares: Shares;
    };

    public type User = {
        var id: UserId; // Principal.
        var handle: Text;
        var seerBalance: Balance;
        var expSeerBalance: Balance;
        var markets: [UserMarket];
    };

    public type UserResult = {
        id: UserId; // Principal.
        handle: Text;
        seerBalance: Balance;
        expSeerBalance: Balance;
        markets: [UserMarket];
    };

    public type MarketInitData = {
        title: Title;
        description: Description;
        labels: [Text];
        images: [Text];
        liquidity: Balance;
        endDate: Time.Time;
        imageUrl: Url;
    };

    public type Comment = {
        author: Text; // handle.
        content: Text;
    };

    public type Market = {
        id: MarketId;    
        title: Title;
        description: Description;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        labels: [Text];
        images: [Text];
        var probabilities: [Probability];
        var liquidity: Balance;
        var reserves: [Balance];
        var k: Balance;
        var providers: [Text]; // list of principals
        var blockTimestampLast: Time.Time;
        var totalShares: Shares;
        var imageUrl: Url;
        var state: MarketState;
        var volume: Balance;
        var comments: [Comment];
    };

    public type MarketResult = {
        id: MarketId;    
        title: Title;
        description: Description;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        labels: [Text];
        images: [Text];
        probabilities: [Probability];
        liquidity: Balance;
        reserves: [Balance];
        k: Balance;
        providers: [Text]; // list of principals
        blockTimestampLast: Time.Time;
        totalShares: Shares;
        imageUrl: Url;
        state: MarketState;
        volume: Balance;
        comments: [Comment];
    };


    private func userResultToUser(u: UserResult): User {
        let user = {
            var id = u.id;
            var handle = u.handle;
            var seerBalance = u.seerBalance;
            var expSeerBalance = u.expSeerBalance;
            var markets = u.markets;
        };
        return user;
    };

    private func userToUserResult(u: User): UserResult {
        let userResult = {
            id = u.id;
            handle = u.handle;
            seerBalance = u.seerBalance;
            expSeerBalance = u.expSeerBalance;
            markets = u.markets;
        };
        return userResult;
    };


    private func marketResultToMarket(m: MarketResult): Market {
        let market = {
            id = m.id;    
            title = m.title;
            description = m.description;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            labels = m.labels;
            images = m.images;
            var probabilities = m.probabilities;
            var liquidity = m.liquidity;
            var reserves = m.reserves;
            var k = m.k;
            var blockTimestampLast = m.blockTimestampLast;
            var totalShares = m.totalShares;
            var providers = m.providers;
            var imageUrl = m.imageUrl;
            var state = m.state;
            var volume = m.volume;
            var comments = m.comments;
        };

        return market;
    };

    private func marketToMarketResult(m: Market): MarketResult {
        let market = {
            id = m.id;    
            title = m.title;
            description = m.description;
            labels = m.labels;
            images = m.images;
            probabilities = m.probabilities;
            liquidity = m.liquidity;
            reserves = m.reserves;
            k = m.k;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            blockTimestampLast = m.blockTimestampLast;
            totalShares = m.totalShares;
            providers = m.providers;
            imageUrl = m.imageUrl;
            state = m.state;
            volume = m.volume;
            comments = m.comments;
        };
        return market;    
    };
    
    /* State */

    public type State = {
        #v1: ([(UserId, UserResult)], [(MarketId, MarketResult)]);
    };  

    private stable var nextMarketId: MarketId = 0;
    private stable var handles: Trie.Trie<Text, UserId> = Trie.empty();
    
    private stable var stableUsers: [(UserId, UserResult)] = [];
    private stable var stableMarkets: [(MarketId, MarketResult)] = [];
    private stable var state: State = #v1([], []);

    private var userMap: Map.HashMap<UserId, User> = do {
        switch (state) {
            case (#v1(users, markets)) {
                let usersIter = Iter.map<(UserId, UserResult), (UserId, User)>(
                    stableUsers.vals(), 
                    func (e: (UserId, UserResult)): (UserId, User) {
                        return (e.0, userResultToUser(e.1));
                    }
                );
                
                Map.fromIter<UserId, User>(
                    usersIter,
                    10, 
                    Text.equal, 
                    Text.hash
                )
            }
        }
    };
    
    private var marketMap: Map.HashMap<MarketId, Market> = do {
        switch (state) {
            case (#v1(users, markets)) {
                let marketIter = Iter.map<(MarketId, MarketResult), (MarketId, Market)>(
                    stableMarkets.vals(), 
                    func (e: (MarketId, MarketResult)): (MarketId, Market) {
                        return (e.0, marketResultToMarket(e.1));
                    }
                );
                
                Map.fromIter<MarketId, Market>(
                    marketIter,
                    10, 
                    Nat32.equal, 
                    func (x: Nat32): Nat32 { x } 
                )
            }
        }
    };

    /* Upgrade */

    system func preupgrade() {
        stableUsers := Array.map<(UserId, User), (UserId, UserResult)>(
            Iter.toArray(userMap.entries()), 
            func (e: (UserId, User)): (UserId, UserResult) {
                (e.0, userToUserResult(e.1))
            }
        );
        stableMarkets := Array.map<(MarketId, Market), (MarketId, MarketResult)>(
            Iter.toArray(marketMap.entries()), 
            func (e: (MarketId, Market)): (MarketId, MarketResult) {
                (e.0, marketToMarketResult(e.1))
            }
        );

        // state := #v1(stableUsers, stableMarkets);
    };

    system func postupgrade() {
        let marketIter = Iter.map<(MarketId, MarketResult), (MarketId, Market)>(
            stableMarkets.vals(), 
            func (e: (MarketId, MarketResult)): (MarketId, Market) {
                return (e.0, marketResultToMarket(e.1));
            }
        );
        
        marketMap := Map.fromIter<MarketId, Market>(
            marketIter,
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x } 
        );

        let usersIter = Iter.map<(UserId, UserResult), (UserId, User)>(
            stableUsers.vals(), 
            func (e: (UserId, UserResult)): (UserId, User) {
                return (e.0, userResultToUser(e.1));
            }
        );
        
        userMap := Map.fromIter<UserId, User>(
            usersIter,
            10, 
            Text.equal, 
            Text.hash
        );
    };

    
    /* API */

    // Tip all users.
    // public shared(msg) func tipAllUsers(): async () {
    //     assert(msg.caller == initializer); // Root call.

    //     users := Trie.mapFilter(users, func (id: UserId, user: User): ?User {
    //         if (user.markets.size() > 0) {
    //             user.seerBalance := user.seerBalance + 3000 - user.seerBalance;
    //         };
    //         return ?user;
    //     });
    // };

    // Read all users.
    public query func readAllUsers(): async [UserResult] {
        Array.map<(UserId, User), UserResult>(
            Iter.toArray(userMap.entries()), 
            func (e: (UserId, User)): UserResult {
                userToUserResult(e.1)
            }
        )
    };

    public shared(msg) func backup(): async () {
        assert(msg.caller == initializer); // Root call.
        stableUsers := Array.map<(UserId, User), (UserId, UserResult)>(
            Iter.toArray(userMap.entries()), 
            func (e: (UserId, User)): (UserId, UserResult) {
                (e.0, userToUserResult(e.1))
            }
        );
        stableMarkets := Array.map<(MarketId, Market), (MarketId, MarketResult)>(
            Iter.toArray(marketMap.entries()), 
            func (e: (MarketId, Market)): (MarketId, MarketResult) {
                (e.0, marketToMarketResult(e.1))
            }
        );

        state := #v1(stableUsers, stableMarkets);
    };

    public shared(msg) func restore(): async () {
        assert(msg.caller == initializer); // Root call.
        let marketIter = Iter.map<(MarketId, MarketResult), (MarketId, Market)>(
            stableMarkets.vals(), 
            func (e: (MarketId, MarketResult)): (MarketId, Market) {
                return (e.0, marketResultToMarket(e.1));
            }
        );
        
        marketMap := Map.fromIter<MarketId, Market>(
            marketIter,
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x } 
        );

        let usersIter = Iter.map<(UserId, UserResult), (UserId, User)>(
            stableUsers.vals(), 
            func (e: (UserId, UserResult)): (UserId, User) {
                return (e.0, userResultToUser(e.1));
            }
        );
        
        userMap := Map.fromIter<UserId, User>(
            usersIter,
            10, 
            Text.equal, 
            Text.hash
        );
    };


    // Delete all users.
    // public shared(msg) func deleteAllUsers(): async () {
    //     assert(msg.caller == initializer); // Root call.
       
    //     users := Trie.empty();
    // };

    // Approve a market.
    public shared(msg) func approveMarket(marketId: MarketId): async () {
        assert(msg.caller == initializer); // Root call.

        switch (marketMap.get(marketId)) {
            case (null) {
                return;
            };
            case (?market) {
                market.state := #open;
            };
        };
    }; 

    // public shared(msg) func resolveMarket(marketId: MarketId, option: Nat): async Bool {
    //     assert(msg.caller == initializer); // Root call.
    //     let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
    //     switch (marketOpt) {
    //         case (null) {
    //             return false;
    //         };
    //         case (?market) {
    //             market.state := #resolved(option);
    //             return true;
    //         };
    //     };

    //     return false;
    // };

    public type CreateMarketError = {
        #callerIsAnon;
        #userNotCreated;
        #notEnoughLiquidity: Balance;
        #titleMissing;
        #descriptionMissing;
        #optionsMissing;
        #imageMissing;
        #endDateOld: Time.Time;
    };

    private func checkMarketInitData(marketInitData: MarketInitData): Result.Result<(), CreateMarketError> {
        if (marketInitData.liquidity < 100) {
            return #err(#notEnoughLiquidity(100));
        };

        if (marketInitData.title == "") {
            return #err(#titleMissing);
        };

        if (marketInitData.description == "") {
            return #err(#descriptionMissing);
        };

        if (marketInitData.labels.size() == 0) {
            return #err(#optionsMissing);
        };

        if (marketInitData.imageUrl == "") {
            return #err(#imageMissing);
        };

        if (marketInitData.endDate < Time.now()) {
            return #err(#endDateOld(marketInitData.endDate));
        };

        return #ok(());
    };

    // Create a new AMM market.
    public shared(msg) func createMarket(marketInitData: MarketInitData): async Result.Result<MarketResult, CreateMarketError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#callerIsAnon);
        };

        switch (checkMarketInitData(marketInitData)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(_)) { /* all good; continue */};
        };

        let author = Principal.toText(msg.caller);        
        let optionsLength = marketInitData.labels.size();
        let marketId = nextMarketId;
        let liquidity = marketInitData.liquidity;

        var reserves: [var Balance] = Array.init<Balance>(optionsLength, 0);
        let probabilities: [var Probability] = Array.init<Probability>(optionsLength, 1000 / Float.fromInt(optionsLength));
        
        var k: Balance = 1;

        for (i in Iter.range(0, optionsLength - 1)) {
            reserves[i] := liquidity;
            k := k * reserves[i];
        };
    
        // Dummy value.
        let shares = Float.toInt(Float.sqrt(0));

        let newMarket: Market = {
            id = marketId;
            title = marketInitData.title;
            description = marketInitData.description;
            startDate = Time.now();
            endDate = marketInitData.endDate;
            author = author;
            labels = marketInitData.labels;
            images = marketInitData.images;
            var probabilities = Array.freeze(probabilities);
            var liquidity = liquidity;
            var k = k;
            var reserves = Array.freeze(reserves);
            var blockTimestampLast = Time.now();
            var totalShares = shares;
            var providers = [author];
            var imageUrl = marketInitData.imageUrl;
            var state = #pending;
            var volume = 0;
            var comments = [];
        };

        // Update provider.
        var user = switch (getUser(author)) {
            case (null) {
                return #err(#userNotCreated);
            };
            case (?user) {
                user;
            };
        };
        
        let userMarket: UserMarket = {
            marketId = marketId;
            marketTitle = marketInitData.title;
            balances = Array.freeze(Array.init<Balance>(optionsLength, 0));
            shares = shares;
        };

        user.markets := Array.append(user.markets, [userMarket]);
        userMap.put(user.id, user);
        
        nextMarketId += 1;
        marketMap.put(marketId, newMarket);

        return #ok(marketToMarketResult(newMarket));
    };

    // Read a market.
    public query func readMarket(marketId: MarketId): async ?MarketResult {
        let result = marketMap.get(marketId);
        return Option.map(result, marketToMarketResult);        
    };

    // Read all markets.
    public query func readAllMarkets(): async [MarketResult] {
        Array.map<(MarketId, Market), MarketResult>(
            Iter.toArray(marketMap.entries()), 
            func (e: (MarketId, Market)): MarketResult {
                marketToMarketResult(e.1)
            }
        )
    };

    // Read all open markets.
    public query func readAllOpenMarkets(): async [MarketResult] {
        let allMarkets = Array.map<(MarketId, Market), MarketResult>(
            Iter.toArray(marketMap.entries()), 
            func (e: (MarketId, Market)): MarketResult {
                marketToMarketResult(e.1)
            }
        );
        return Array.mapFilter(Iter.toArray(marketMap.entries()), keepOpenMarkets);
    };

    private type RefreshUserError = {
        #callerIsAnon;
        #userNotCreated;
    };

    public shared(msg) func refreshUser(): async Result.Result<UserResult, RefreshUserError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#callerIsAnon);
        };

        let caller = Principal.toText(msg.caller);
        let userOpt = userMap.get(caller);

        switch (userOpt) {
            case (null) {
                return #err(#userNotCreated);
            };
            case (?user) {
                user.expSeerBalance := user.seerBalance;
                user.markets := Array.mapFilter(user.markets, 
                    func (ut: UserMarket): ?UserMarket {
                        
                        let marketOpt = marketMap.get(ut.marketId);
                        
                        switch (marketOpt) {
                            case (null) {
                                // Market was deleted so we delete its data from the user.
                                return null;
                            };
                            case (?market) {
                                switch (market.state) {
                                    case (#resolved(i)) {
                                        let reward = ut.balances[i];
                                        // Give reward to user and delete market.
                                        user.seerBalance := user.seerBalance + reward;
                                        return null;
                                    };
                                    case _ {
                                        // Market still open. Update expected balance.
                                        let optionsSize = market.probabilities.size();

                                        for (j in Iter.range(0, optionsSize - 1)) {
                                            user.expSeerBalance := user.expSeerBalance 
                                                + market.probabilities[j] * ut.balances[j] / 1000.0; 
                                        };

                                        return ?ut;
                                    };
                                };
                            };
                        };
                    }
                );
                return #ok(userToUserResult(user));
            };
        };
    };

    // Delete a market.
    public shared(msg) func deleteMarket(marketId: MarketId): async ?MarketResult {
        assert(msg.caller == initializer); // Root call.
        
        let r = marketMap.remove(marketId);
        switch (r) {
            case (null) {
                return null;
            };
            case (?m) {
                return ?marketToMarketResult(m);
            }
        }
    };

    // Delete all market.
    public shared(msg) func deleteAllMarkets(): async () {
        assert(msg.caller == initializer); // Root call.
        
        nextMarketId := 0;
        marketMap := Map.HashMap<MarketId, Market>(
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x }
        );
    };


    public type TradeError = {
        #callerIsAnon;
        #userNotCreated;
        #notEnoughBalance;
        #marketMissing;
        #marketClosed;
        #newtonFailed;
    };

    // Sell tokens from caller back to the market.
    public shared(msg) func sellOption(
        marketId: MarketId,
        value: Balance,
        selected: Nat,
        save: Bool
    ): async Result.Result<Balance, TradeError> {

        if (Principal.isAnonymous(msg.caller)) {
            return #err(#callerIsAnon);
        };

        let caller = Principal.toText(msg.caller);
        let marketOpt = marketMap.get(marketId);
        
        switch (marketOpt) {
            case null {
                return #err(#marketMissing);
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return #err(#marketClosed);
                };

                var user = switch (getUser(caller)) {
                    case (null) {
                        return #err(#userNotCreated);
                    };
                    case (?user) {
                        user;
                    };
                };
        
                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        // No tokens to sell.
                        return #err(#notEnoughBalance);
                    };
                    case (?marketTokens) {
                        if (marketTokens.balances[selected] < value) {
                            // No enought tokens to sell.
                            return #err(#notEnoughBalance);
                        };

                        let optionsSize = market.reserves.size();
                        var newReserves: [var Balance] = Array.init(optionsSize, 0.0);
                        
                        for (i in Iter.range(0, optionsSize - 1)) {
                            newReserves[i] := market.reserves[i];
                        };
                        newReserves[selected] := newReserves[selected] + value;

                        let f = func (x: Float): Float {
                            var calcK: Float = 1;
                            for (i in Iter.range(0, optionsSize - 1)) {
                                calcK := calcK * (newReserves[i] - x);
                            };

                            return calcK - market.k;               
                        };

                        var rOpt = newtonMethod(0.0, f);

                        switch (rOpt) {
                            case (null) {
                                return #err(#newtonFailed);
                            };
                            case (?r) {
                                for (i in Iter.range(0, optionsSize - 1)) {
                                    newReserves[i] := newReserves[i] - r;
                                };
                                let newLiquidity = market.liquidity - r;
                                let liquidityOut: Balance = r;

                                if (not save) {
                                    return #ok(liquidityOut);
                                };
                                
                                market.volume := market.volume + liquidityOut;
                                market.reserves := Array.freeze(newReserves);

                                let weight: [var Balance] = Array.init(optionsSize, 1.0); 
                                let probabilities: [var Probability] = Array.init(optionsSize, 0.0);
                                var weightSum: Balance  = 0.0;
                                    
                                for (i in Iter.range(0, optionsSize - 1)) {
                                    for (j in Iter.range(0, optionsSize - 1)) {
                                        if (i != j) {
                                            weight[i] := weight[i] * market.reserves[j];
                                        };
                                    };
                                    weightSum := weightSum + weight[i];
                                };

                                for (i in Iter.range(0, optionsSize - 1)) {
                                    probabilities[i] := weight[i] * 1000.0 / weightSum;
                                };

                                market.probabilities := Array.freeze(probabilities);

                                user.markets := Array.mapFilter(user.markets, 
                                    func (ut: UserMarket): ?UserMarket {
                                        if (ut.marketId != market.id) {
                                            return ?ut;
                                        } else {
                                            let newBalances = Array.mapEntries(ut.balances,
                                                func (b: Balance, i: Nat): Balance {
                                                    if (i == selected) {
                                                        return b - value;
                                                    } else {
                                                        return b;
                                                    };
                                                }
                                            );

                                            let newUserMarket: UserMarket = {
                                                marketId = market.id;
                                                marketTitle = market.title;
                                                balances = newBalances;
                                                shares = ut.shares;
                                            };

                                            return ?newUserMarket;
                                        };
                                    }
                                );

                                user.seerBalance := user.seerBalance + liquidityOut;

                                return #ok(liquidityOut);
                            };
                        };
                    };
                };
            };
        };
    };

    public shared(msg) func buyOption(
            marketId: MarketId,
            value: Balance,
            selected: Nat,
            save: Bool
        ): async Result.Result<Balance, TradeError> {

        if (Principal.isAnonymous(msg.caller)) {
            return #err(#callerIsAnon);
        };

        let caller = Principal.toText(msg.caller);
        
        var user = switch (getUser(caller)) {
            case (null) {
                return #err(#userNotCreated);
            };
            case (?user) {
                user;
            };
        };

        if (user.seerBalance < value) {
            return #err(#notEnoughBalance);
        };
        
        let marketOpt = marketMap.get(marketId);

        switch (marketOpt) {
            case null {
                return #err(#marketMissing);
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return #err(#marketClosed);
                };
                
                let optionsSize = market.reserves.size();
                var semiK: Balance = 1.0;

                for (i in Iter.range(0, optionsSize - 1)) {
                    if (i != selected) {
                        semiK := semiK * (market.reserves[i] + value);
                    };
                };
                
                let newSelectedReserve: Balance = market.k / semiK;
                let tokensOut = market.reserves[selected] - newSelectedReserve + value;
                
                if (not save) { // Dry run.
                    return #ok(tokensOut);
                };

                var newReserves: [var Balance] = Array.init(optionsSize, 0.0);
                let newLiquidity = market.liquidity + value;
               
                for (i in Iter.range(0, optionsSize - 1)) {
                    if (i != selected) {
                        newReserves[i] := market.reserves[i] + value;
                    } else {
                        newReserves[i] := newSelectedReserve;
                    };
                };
                
                market.reserves := Array.freeze(newReserves);
                market.liquidity := newLiquidity;
                market.volume := market.volume + value;

                let weight: [var Balance] = Array.init(optionsSize, 1.0); 
                let probabilities: [var Probability] = Array.init(optionsSize, 0.0);
                var weightSum: Balance  = 0.0;
                    
                for (i in Iter.range(0, optionsSize - 1)) {
                    for (j in Iter.range(0, optionsSize - 1)) {
                        if (i != j) {
                            weight[i] := weight[i] * market.reserves[j];
                        };
                    };
                    weightSum := weightSum + weight[i];
                };

                for (i in Iter.range(0, optionsSize - 1)) {
                    probabilities[i] := weight[i] * 1000.0 / weightSum;
                };

                market.probabilities :=  Array.freeze(probabilities);

                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let balances: [var Balance] = Array.init(optionsSize, 0.0);
                        balances[selected] := tokensOut;

                        let newUserMarket: UserMarket = {
                            marketId = market.id;
                            marketTitle = market.title;
                            balances = Array.freeze(balances);
                            shares = 0;
                        };
                        user.markets := Array.append(user.markets, [newUserMarket]);
                    };
                    case (?marketTokens) {
                        user.markets := Array.mapFilter(user.markets, 
                            func (ut: UserMarket): ?UserMarket {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newBalances = Array.mapEntries(ut.balances,
                                        func (b: Balance, i: Nat): Balance {
                                            if (i == selected) {
                                                return b + tokensOut;
                                            } else {
                                                return b;
                                            };
                                        }
                                    );

                                    let newUserMarket: UserMarket = {
                                        marketId = market.id;
                                        marketTitle = market.title;
                                        balances = newBalances;
                                        shares = ut.shares;
                                    };
                                    return ?newUserMarket;
                                };
                            }
                        );
                    };
                };

                user.seerBalance := user.seerBalance - value;

                return #ok(tokensOut);
            };
        };
    };

    // Get user data.
    public query func getUserResult(userId: UserId): async ?UserResult {
        return Option.map(getUser(userId), userToUserResult);
    };

    // Create user.
    public shared(msg) func createUserResult(handle: Text): async Result.Result<UserResult, CreateUserError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#userIsAnon);
        };

        let caller = Principal.toText(msg.caller);

        switch (createUser(caller, handle)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(user)) {
                return #ok(userToUserResult(user))
            };
        };
    };

    // Tip a user
    public shared(msg) func tip(id: UserId, value: Balance): async ?Balance {
        assert(msg.caller == initializer); // Root call.

        var user = switch (getUser(id)) {
            case (null) {
                return null;
            };
            case (?user) {
                user;
            };
        };
        user.seerBalance := user.seerBalance + value;

        return ?user.seerBalance;
    };

    // Edit market image.
    // public shared(msg) func editMarketImage(marketId: MarketId, newImage: Text): async Bool {
    //     assert(msg.caller == initializer); // Root call.

    //     let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);

    //     switch (marketOpt) {
    //         case null {
    //             return false;
    //         };
    //         case (?market) {
    //             market.imageUrl := newImage;
    //             return true;
    //         };
    //     };

    //     return false;
    // };

    private type AddCommentError = {
        #userIsAnon;
        #userNotCreated;
        #marketMissing;
        #commentIsEmpty;
    };

    // Add a comment to a market.
    public shared(msg) func addCommentToMarket(marketId: MarketId, content: Text): async Result.Result<Comment, AddCommentError> {
        if (Principal.isAnonymous(msg.caller)) {
            return #err(#userIsAnon);
        };

        if (content == "") {
            return #err(#commentIsEmpty);
        };

        let userId = Principal.toText(msg.caller);
        let userOpt = userMap.get(userId);

        switch (userOpt) {
            case null {
                return #err(#userNotCreated);
            };
            case (?user) {
                let marketOpt = marketMap.get(marketId);

                switch (marketOpt) {
                    case null {
                        return #err(#marketMissing);
                    };
                    case (?market) {
                        let comment: Comment = {
                            author = user.handle;
                            content = content;
                        };
                        market.comments := Array.append(market.comments, [comment]);
                        
                        return #ok(comment);
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

    private func keepOpenMarkets(o: (MarketId, Market)): ?MarketResult {
        let m = o.1;
        switch (m.state) {
            case (#open) {
                let market = {
                    id = m.id;    
                    title = m.title;
                    description = m.description;
                    labels = m.labels;
                    images = m.images;
                    probabilities = m.probabilities;
                    liquidity = m.liquidity;
                    reserves = m.reserves;
                    k = m.k;
                    startDate = m.startDate;
                    endDate = m.endDate;
                    author = m.author;
                    blockTimestampLast = m.blockTimestampLast;
                    totalShares = m.totalShares;
                    providers = m.providers;
                    imageUrl = m.imageUrl;
                    state = m.state;
                    volume = m.volume;
                    comments = m.comments;
                };
                return ?market;
            };
            case _ {
                return null;
            };
        };
        return null;
    };

    private func getUser(userId: UserId): ?User {
        userMap.get(userId)
    };

    private type CreateUserError = {
        #userExist;
        #userIsAnon;
    };

    private func createUser(userId: UserId, handle: Text): Result.Result<User, CreateUserError> {
        let exist = Trie.find(handles, userKey(handle), Text.equal);

        switch (exist) {
            case (null) {
                let user: User = {
                    var id = userId;
                    var seerBalance = 1000.0; // Airdrop
                    var expSeerBalance = 1000.0;
                    var handle = handle;
                    var markets = [];
                };

                handles := Trie.replace(
                    handles,
                    userKey(handle),
                    Text.equal,
                    ?handle,
                ).0;

                userMap.put(userId, user);

                return #ok(user);
            };
            case (userId) {
                return #err(#userExist);
            };
        };
    };

    private func newtonMethod(x0: Float, f: Float -> Float): ?Float {
        let tolerance = 1e-7;
        let epsylon = 2.220446049250313e-16;
        let h = 1e-4;
        let hr = 1/h;
        let maxIter = 100;
        
        var iter = 0;
        var prev = x0;
        
        while (iter < maxIter) {
            // Compute the value of the function.
            let y = f(prev);

            // Use numerica derivatives.
            let yph = f(prev + h);
            let ymh = f(prev - h);
            let yp2h = f(prev + 2 * h);
            let ym2h = f(prev - 2 * h);

            let yp = ((ym2h - yp2h) + 8 * (yph - ymh)) * hr / 12;

            if (Float.abs(yp) <= epsylon * Float.abs(y)) {
                return null;
            };

            // Update the guess.
            let next = prev - y / yp;

            // Check for convergence:
            if (Float.abs(next - prev) <= tolerance * Float.abs(next)) {
                return ?next;
            };

            prev := next;
            iter := iter + 1;
        };

        return null;
    };
};
