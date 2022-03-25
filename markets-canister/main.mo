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
        probabilities: [Probability];
        labels: [Text];
        images: [Text];
        liquidity: Balance;
        endDate: Time.Time;
        imageUrl: Url;
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
        var blockTimestampLast: Time.Time;
        var reserves: [Balance];
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
        labels: [Text];
        images: [Text];
        probabilities: [Probability];
        liquidity: Balance;
        startDate: Time.Time;
        endDate: Time.Time;
        author: Author;
        blockTimestampLast: Time.Time;
        reserves: [Balance];
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
    public shared(msg) func deleteAllUsers(): async () {
        assert(msg.caller == initializer); // Root call.
       
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
                    case (#resolved(i)) {
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
                                            reward := ut.balances[i];
                                            user.seerBalance := user.seerBalance + reward;
                                    
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

    public shared(msg) func resolveMarket(marketId: MarketId, option: Nat): async Bool {
        assert(msg.caller == initializer); // Root call.
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        switch (marketOpt) {
            case (null) {
                return false;
            };
            case (?market) {
                market.state := #resolved(option);
                return true;
            };
        };

        return false;
    };

    // Create a market.
    public shared(msg) func createMarket(marketInitData: MarketInitData): async MarketId {
        let author = Principal.toText(msg.caller);
        
        assert(author != anon);
        assert(marketInitData.liquidity >= 1000);
        assert(marketInitData.title != "");
        assert(marketInitData.description != "");
        assert(marketInitData.imageUrl != "");
        assert(marketInitData.endDate > Time.now());

        let optionsLength = marketInitData.probabilities.size();
        let marketId = nextMarketId;

        var reserves: [var Balance] = Array.init(optionsLength, 0);
        var kLastFloat: Float = 1.0;

        for (i in Iter.range(0, optionsLength - 1)) {
            reserves[i] := marketInitData.liquidity * optionsLength;
            kLastFloat := kLastFloat * Float.fromInt(reserves[i]);
        };
    
        let shares = Float.toInt(Float.sqrt(kLastFloat));
        let kLast = Float.toInt(kLastFloat) * marketInitData.liquidity;

        let newMarket: Market = {
            id = marketId;
            title = marketInitData.title;
            description = marketInitData.description;
            startDate = Time.now();
            endDate = marketInitData.endDate;
            author = author;
            labels = marketInitData.labels;
            images = marketInitData.images;
            var probabilities = marketInitData.probabilities;
            var liquidity = marketInitData.liquidity;
            var blockTimestampLast = Time.now();
            var reserves = Array.freeze(reserves);
            var kLast = kLast;
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
            balances = Array.freeze(Array.init<Balance>(optionsLength, 0));
            shares = shares;
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
        return Array.map(result, marketToMarketResult);
    };

    // Read all open markets.
    public query func readAllOpenMarkets(): async [MarketResult] {
        let result = Trie.toArray(markets, getMarket);
        return Array.mapFilter(result, keepOpenMarkets);
    };

    // Delete a market.
    public shared(msg) func deleteMarket(marketId: MarketId): async Bool {
        assert(msg.caller == initializer); // Root call.
        
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
    public shared(msg) func deleteAllMarkets(): async () {
        assert(msg.caller == initializer); // Root call.
        
        nextMarketId := 0;
        markets := Trie.empty();
    };


    // Sell tokens from caller back to the market.
    public shared(msg) func sellOption(marketId: MarketId, value: Balance, number: Nat, save: Bool): async ?Balance {
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
                        if (marketTokens.balances[number] < value) {
                            // No enought tokens to sell.
                            return null;
                        };

                        let optionsSize = market.reserves.size();
                        var newReserveTokens: [var Balance] = Array.init(optionsSize, 0);
                        newReserveTokens[number] := market.reserves[number] + value * market.probabilities[number] / 1000;
                        
                        var newTotalReserve: Balance = newReserveTokens[number];

                        for (i in Iter.range(0, optionsSize - 1)) {
                            if (i != number) {
                                newTotalReserve := newTotalReserve * market.reserves[i];
                            };
                        };
                       let newLiquidity = market.kLast / newTotalReserve;


                        // let newTotalReserve: Balance = oldTotalReserve + value;
                        // let newLiquidity: Balance = newTotalReserve * market.liquidity / oldTotalReserve;
                        let liquidityOut: Balance = market.liquidity - newLiquidity;

                        // newReserveTokens[number] := market.reserves[number] + value;
                        // let newOthersReserve = market.kLast / market.reserves[number];
                        // var oldOthersReserve: Balance = 1;
                        
                        




                        // var totalReserve: Balance = 0;
                        // for (i in Iter.range(0, optionsSize - 1)) {
                        //     if (i != number) {
                        //         newReserveTokens[i] := (market.reserves[i] * newOthersReserve) / oldOthersReserve;
                        //         totalReserve := totalReserve + newReserveTokens[i];
                        //     };
                        // };

                        // totalReserve := totalReserve + newReserveTokens[number];
                        // let multiplier: Balance = 1000 / optionsSize;
                        // let newLiquidity = newReserveTokens[number] * market.probabilities[number] / multiplier;
                        // let liquidityGGGTTG =  newLiquidity - market.liquidity;

                        if (not save) {
                            return ?liquidityOut;
                        };
                        
                        // market.volume := market.volume + liquidityOut;
                        // market.reserves := Array.freeze(newReserveTokens);

                        // let probab'i'lities: [var Probability] = Array.init(optionsSize, 1);
                        // for (i in Iter.range(0, optionsSize - 1)) {
                        //     probabilities[i] := (totalReserve - market.reserves[i]) * 1000 / ((optionsSize - 1) * totalReserve);
                        // };
                        // market.probabilities :=  Array.freeze(probabilities);
                        
                        // user.markets'''
                        
                        
                        
                        
                        //  := Array.O[]\=][-P0-0-L----------------=[]P0]]]]]mapFilter(user.markets, 
                        //     func (ut: UserMarket): ?UserMarket {
                        //         if (ut.marketId != market.id) {
                        //             return ?ut;
                        //         } else {
                        //             let newBalances = Array.mapEntries(ut.balances,
                        //                 func (b: Balance, i: Nat): Balance {
                        //                     if (i == number) {
                        //                         return b - value;
                        //                     } else {
                        //                         return b;
                        //                     };
                        //                 }
                        //             );

                        //             let newUserMarket: UserMarket = {
                        //                 marketId = market.id;
                        //                 marketTitle = market.title;
                        //                 balances = newBalances;
                        //                 shares = ut.shares;
                        //             };

                        //             return ?newUserMarket;
                        //         };
                        //     }
                        // );

                        user.seerBalance := user.seerBalance + liquidityOut;

                        return ?liquidityOut;
                    };
                };

                return null;
            };
        };
    };

    public shared(msg) func buyOption(marketId: MarketId, value: Balance, number: Nat, save: Bool): async ?Balance {
        let caller = Principal.toText(msg.caller);
        let marketOpt = Trie.find(markets, marketKey(marketId), Nat32.equal);
        var user = getOrCreateUser(caller);

        assert(user.seerBalance >= value);
        
        switch (marketOpt) {
            case null {
                return null;
            };
            case (?market) {
                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return null;
                };

                let optionsSize = market.reserves.size();
                var newReserveTokens: [var Balance] = Array.init(optionsSize, 0);
                
                let newLiquidity = market.liquidity + value;
                var mulOtherReserves = newLiquidity;
                // var sumOtherReserves: Balance = 0;
            
                for (i in Iter.range(0, optionsSize - 1)) {
                    if (i != number) {
                        newReserveTokens[i] := market.reserves[i];
                        mulOtherReserves := mulOtherReserves * newReserveTokens[i];
                        // sumOtherReserves := sumOtherReserves + newReserveTokens[i];
                    };
                };

                let newOptionReserve: Balance = market.kLast / mulOtherReserves;
                let tokensOut = market.reserves[number] - newOptionReserve;

                if (not save) {
                    return ?tokensOut;
                };

                // newReserveTokens[number] := newOptionReserve; 
                market.reserves := Array.freeze(newReserveTokens);
                market.liquidity := newLiquidity;
                market.volume := market.volume + value;
                 
                // let totalReserve = sumOtherReserves + newOptionReserve;
                let probabilities: [var Probability] = Array.init(optionsSize, 0);
                var maxReserve: Balance = 0;

                for (i in Iter.range(0, optionsSize - 1)) {
                    if (maxReserve < market.reserves[i]) {
                        maxReserve := market.reserves[i];
                    };
                };

                let rates: [var Probability] = Array.init(optionsSize, 0);
                var totalRates: Balance = 0;

                for (i in Iter.range(0, optionsSize - 1)) {
                    rates[i] := maxReserve * 1000 / market.reserves[i];
                    totalRates := totalRates + rates[i];
                };

                for (i in Iter.range(0, optionsSize - 1)) {
                    probabilities[i] := rates[i] * 1000 / totalRates;
                };

                market.probabilities :=  Array.freeze(probabilities);

                var marketTokensOpt = Array.find(user.markets,
                    func (ut: UserMarket): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let balances: [var Balance] = Array.init(optionsSize, 0);
                        balances[number] := tokensOut;

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
                                            if (i == number) {
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

                return ?tokensOut;
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
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            labels = m.labels;
            images = m.images;
            var probabilities = m.probabilities;
            var liquidity = m.liquidity;
            var blockTimestampLast = m.blockTimestampLast;
            var reserves = m.reserves;
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
            labels = m.labels;
            images = m.images;
            probabilities = m.probabilities;
            liquidity = m.liquidity;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            blockTimestampLast = m.blockTimestampLast;
            reserves = m.reserves;
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
                    labels = m.labels;
                    images = m.images;
                    probabilities = m.probabilities;
                    liquidity = m.liquidity;
                    startDate = m.startDate;
                    endDate = m.endDate;
                    author = m.author;
                    blockTimestampLast = m.blockTimestampLast;
                    reserves = m.reserves;
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
        assert(userId != anon);
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
