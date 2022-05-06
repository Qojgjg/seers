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
import M "Market";
import U "User";
import Utils "Utils";
import Tx "Tx";
import Comment "Comment";
import Like "Like";

// import Array "mo:base/Array";
// import Binary "mo:encoding/Binary";
// import Blob "mo:base/Blob";
// import CRC32 "mo:hash/CRC32";
// import Float "mo:base/Float";
// import Nat64 "mo:base/Nat64";
// import Principal "mo:base/Principal";
import Account "Account";

import Ledger "Ledger";
// import LedgerC "LedgerCandid";
// import XDR "XDR";


shared({ caller = initializer }) actor class Market() = this {
    private let ledger: Ledger.Interface  = actor(Ledger.CANISTER_ID);
    private stable var anon: Text = "2vxsx-fae";

    // Returns the default account identifier of this canister.
    func myAccountId() : Account.AccountIdentifier {
        Account.accountIdentifier(Principal.fromActor(this), Account.defaultSubaccount())
    };

    // Returns current balance on the default account of this canister.
    public func canisterFloat() : async Ledger.ICP {
        await ledger.account_balance({ account = myAccountId() })
    };

    /* Types */

    // Returns canister's default account identifier as text.
    public query func canisterAccount() : async Text {
        Account.toText(myAccountId())
    };

    // Returns canister's default account identifier as a blob.
    public shared(msg) func callerAccount() : async Account.AccountIdentifier {
        let principal = msg.caller;
        return Account.accountIdentifier(principal, Account.defaultSubaccount());
    };
    
    /* State */
    
    private stable var updating: Bool = false;
    private stable var nextMarketId: Nat32 = 0;
    private stable var handles: Trie.Trie<Text, Text> = Trie.empty();
    
    private stable var stableUsers: [(Text, U.UserStable)] = [];
    private stable var stableMarkets: [(Nat32, M.MarketStable)] = [];
    
    private var userDataMap: Map.HashMap<Text, Utils.UserData> = do {
        let usersIter = Iter.map<(Text, U.UserStable), (Text, Utils.UserData)>(
            stableUsers.vals(), 
            func (e: (Text, U.UserStable)): (Text, Utils.UserData) {
                let u = U.unFreezeUser(e.1);
                let ud: Utils.UserData = {
                    principal = u.id;
                    handle = u.handle;
                    picture = u.picture;
                };
                return (e.0, ud);
            }
        );
        
        Map.fromIter<Text, Utils.UserData>(
            usersIter,
            50, 
            Text.equal, 
            Text.hash
        )
    };

    private var userMap: Map.HashMap<Text, U.User> = do {
        let usersIter = Iter.map<(Text, U.UserStable), (Text, U.User)>(
            stableUsers.vals(), 
            func (e: (Text, U.UserStable)): (Text, U.User) {
                let v = U.unFreezeUser(e.1);
                return (e.0, v);
            }
        );
        
        Map.fromIter<Text, U.User>(
            usersIter,
            50, 
            Text.equal, 
            Text.hash
        )
    };
    private var marketMap: Map.HashMap<Nat32, M.Market> = do {
        let marketIter = Iter.map<(Nat32, M.MarketStable), (Nat32, M.Market)>(
            stableMarkets.vals(), 
            func (e: (Nat32, M.MarketStable)): (Nat32, M.Market) {
                let v = M.unFreezeMarket(e.1);
                return (e.0, v);
            }
        );
        
        Map.fromIter<Nat32, M.Market>(
            marketIter,
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x } 
        )
    };
    
    /* Upgrade */

    system func preupgrade() {
        // stableUsers := Array.map<(Text, User), (Text, UserResult)>(
        //     Iter.toArray(userMap.entries()), 
        //     func (e: (Text, User)): (Text, UserResult) {
        //         (e.0, userToUserResult(e.1))
        //     }
        // );
        // stableMarkets := Array.map<(Nat32, Market), (Nat32, MarketResult)>(
        //     Iter.toArray(marketMap.entries()), 
        //     func (e: (Nat32, Market)): (Nat32, MarketResult) {
        //         (e.0, marketToMarketResult(e.1))
        //     }
        // );
    };

    system func postupgrade() {
        // let marketIter = Iter.map<(Nat32, MarketResult), (Nat32, Market)>(
        //     stableMarkets.vals(), 
        //     func (e: (Nat32, MarketResult)): (Nat32, Market) {
        //         return (e.0, marketResultToMarket(e.1));
        //     }
        // );
        
        // marketMap := Map.fromIter<Nat32, Market>(
        //     marketIter,
        //     10, 
        //     Nat32.equal, 
        //     func (x: Nat32): Nat32 { x } 
        // );

        // let usersIter = Iter.map<(Text, UserResult), (Text, User)>(
        //     stableUsers.vals(), 
        //     func (e: (Text, UserResult)): (Text, User) {
        //         return (e.0, userResultToUser(e.1));
        //     }
        // );
        
        // userMap := Map.fromIter<Text, User>(
        //     usersIter,
        //     10, 
        //     Text.equal, 
        //     Text.hash
        // );
    };

    
    /* API */

    // Read all users.
    public query func readAllUsers(): async [U.UserStable] {
        Array.map<(Text, U.User), U.UserStable>(
            Iter.toArray(userMap.entries()), 
            func (e: (Text, U.User)): U.UserStable {
                e.1.freeze()
            }
        )
    };

    public shared(msg) func setUpdating(status: Bool): () {
        assert(msg.caller == initializer); // Root call.
        updating := status;
    };


    // Delete all users.
    // public shared(msg) func deleteAllUsers(): async () {
    //     assert(msg.caller == initializer); // Root call.
       
    //     users := HashMap.empty();
    // };

    // Approve a market.
    public shared(msg) func approveMarket(marketId: Nat32): async () {
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

    public shared(msg) func resolveMarket(marketId: Nat32, option: Nat): async Bool {
        assert(msg.caller == initializer); // Root call.
        let marketOpt = marketMap.get(marketId);
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

    private func checkMarketInitData(marketInitData: M.MarketInitData): Result.Result<(), M.MarketError> {
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
            return #err(#endDateOld);
        };

        return #ok(());
    };

    // Create a new AMM market.
    public shared(msg) func createMarket(marketInitData: M.MarketInitData): async Result.Result<M.MarketStable, M.MarketError> {
        assert(not updating);
        let author = Principal.toText(msg.caller);        
        
        if (author == anon) {
            return #err(#callerIsAnon);
        };

        switch (checkMarketInitData(marketInitData)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(_)) { /* all good; continue */};
        };

        let optionsLength = marketInitData.labels.size();
        let marketId = nextMarketId;
        let liquidity = marketInitData.liquidity;

        var reserves: [var Float] = Array.init<Float>(optionsLength, 0);
        let probabilities: [var Float] = Array.init<Float>(optionsLength, 1000 / Float.fromInt(optionsLength));
        
        var k: Float = 1;

        for (i in Iter.range(0, optionsLength - 1)) {
            reserves[i] := liquidity;
            k := k * reserves[i];
        };
    
        // Dummy value.
        let shares = Float.sqrt(0);

        var newMarket = M.Market(marketInitData);
        newMarket.id := marketId;
        newMarket.author := author;

        // Update provider.
        var user = switch (getUser(author)) {
            case (null) {
                return #err(#profileNotCreated);
            };
            case (?user) {
                user;
            };
        };
        
        let userMarket: U.UserMarket = {
            marketId = marketId;
            title = marketInitData.title;
            labels = marketInitData.labels;
            balances = Array.freeze(Array.init<Float>(optionsLength, 0));
            collateralType = marketInitData.collateralType;
            brierScores = [];
            shares = shares;
            spent = 0.0;
            redeemed = false;
            author = true;
            createdAt = Time.now();
            modifiedAt = Time.now();
        };

        user.markets.add(userMarket);
        userMap.put(user.id, user);
        
        nextMarketId += 1;
        marketMap.put(marketId, newMarket);

        return #ok(newMarket.freeze());
    };

    // Read a market.
    public query func readMarket(marketId: Nat32): async ?M.MarketStable {
        let result = marketMap.get(marketId);
        return Option.map(result, func (m: M.Market): M.MarketStable {
            return m.freeze();
        });        
    };

    // // Read user.
    // public query func readUser(userId: Text): async ?U.UserStable {
    //     let result = userMap.get(userId);
    //     return Option.map(result, func (u: U.User): { return u.freeze(); });        
    // };

    // Read all bets of some market.
    // public query func readBetsOfMarket(marketId: Nat32): async [(Text, Text, [Tx.UserTx])] {
    //     let result = marketMap.get(marketId);
    //     switch (result) {
    //         case (null) {
    //             return [];
    //         };
    //         case (?market) {
    //             return Array.mapFilter<(Text, U.User), (Text, Text, [Tx.UserTx])>(
    //                 Iter.toArray(userMap.entries()), 
    //                 func (u: (Text, User)): ?(Text, Text, [Tx.UserTx]) {
    //                     let txs = Array.mapFilter(u.1.txs, func (tx: M.UserTx): ?M.UserTx {
    //                         if (tx.marketId == market.id) {
    //                             return ?tx;
    //                         };
    //                         return null;
    //                     });
    //                     if (txs.size() > 0) {
    //                         return ?(u.1.id, u.1.handle, txs);
    //                     } else {
    //                         return null;
    //                     };
    //                 }
    //             );
    //         };
    //     };     
    // };


    // Read all markets.
    public query func readAllMarkets(): async [M.MarketStable] {
        Array.map<(Nat32, M.Market), M.MarketStable>(
            Iter.toArray(marketMap.entries()),
            func (e: (Nat32, M.Market)): M.MarketStable {
                e.1.freeze()
            }
        )
    };

    // Read all open markets.
    // public query func readAllOpenMarkets(): async [M.MarketStable] {
    //     let allMarkets = Array.map<(Nat32, M.Market), M.MarketStable>(
    //         Iter.toArray(marketMap.entries()), 
    //         func (e: (Nat32, M.Market)): M.MarketStable {
    //             e.1.freeze()
    //         }
    //     );
    //     return Array.mapFilter(Iter.toArray(marketMap.entries()), keepOpenMarkets);
    // };

    // Read all pending markets.
    // public query func readAllPendingMarkets(): async [M.MarketStable] {
    //     let allMarkets = Array.map<(Nat32, M.Market), M.MarketStable>(
    //         Iter.toArray(marketMap.entries()), 
    //         func (e: (Nat32, M.Market)): M.MarketStable {
    //             e.1.freeze()
    //         }
    //     );
    //     return Array.mapFilter(Iter.toArray(marketMap.entries()), keepPendingMarkets);
    // };

    // public shared(msg) func refreshUser(): async Result.Result<U.UserStable, UserError> {
    //     assert(not updating);
    //     let caller = Principal.toText(msg.caller);
        
    //     if (caller == anon) {
    //         return #err(#callerIsAnon);
    //     };

    //     let userOpt = userMap.get(caller);

    //     switch (userOpt) {
    //         case (null) {
    //             return #err(#userNotCreated);
    //         };
    //         case (?user) {
    //             user.expSeerFloat := user.seerFloat;
    //             user.markets := Array.mapFilter(user.markets, 
    //                 func (ut: UserMarket): ?UserMarket {
                        
    //                     let marketOpt = marketMap.get(ut.marketId);
                        
    //                     switch (marketOpt) {
    //                         case (null) {
    //                             // Market was deleted so we delete its data from the user.
    //                             return null;
    //                         };
    //                         case (?market) {
    //                             switch (market.state) {
    //                                 case (#resolved(i)) {
    //                                     if (not ut.used) {
    //                                         let reward = ut.balances[i];
    //                                         // Give reward to user and set market to old.
    //                                         user.seerFloat := user.seerFloat + reward;
    //                                         user.expSeerFloat := user.expSeerFloat + reward;

    //                                         let oldMarket: UserMarket = {
    //                                             marketId = ut.marketId;
    //                                             marketTitle = ut.marketTitle;
    //                                             balances = ut.balances;
    //                                             labels = ut.labels;
    //                                             shares = ut.shares;
    //                                             used = true;
    //                                         };

    //                                         return ?oldMarket;
    //                                     };

    //                                     return ?ut;
    //                                 };
    //                                 case (#open) {
    //                                     // Market still open. Update expected balance.
    //                                     let optionsSize = market.probabilities.size();

    //                                     for (j in Iter.range(0, optionsSize - 1)) {
    //                                         user.expSeerFloat := user.expSeerFloat 
    //                                             + market.probabilities[j] * ut.balances[j] / 1000.0; 
    //                                     };

    //                                     return ?ut;
    //                                 };
    //                                 case _ {
    //                                     return ?ut;
    //                                 };
    //                             };
    //                         };
    //                     };
    //                 }
    //             );
    //             return #ok(userToUserResult(user));
    //         };
    //     };
    // };

    // Delete a market.
    // public shared(msg) func deleteMarket(marketId: Nat32): async ?M.MarketStable {
    //     assert(msg.caller == initializer); // Root call.
        
    //     let r = marketMap.remove(marketId);
    //     switch (r) {
    //         case (null) {
    //             return null;
    //         };
    //         case (?m) {
    //             return ?marketToMarketResult(m);
    //         }
    //     }
    // };

    // Delete all market.
    // public shared(msg) func deleteAllMarkets(): async () {
    //     assert(msg.caller == initializer); // Root call.
        
    //     nextNat32 := 0;
    //     marketMap := Map.HashMap<Nat32, Market>(
    //         10, 
    //         Nat32.equal, 
    //         func (x: Nat32): Nat32 { x }
    //     );
    // };

    // Sell tokens from caller back to the market.
    // public shared(msg) func sellOption(
    //     marketId: Nat32,
    //     value: Float,
    //     selected: Nat,
    //     save: Bool
    // ): async Result.Result<Float, TradeError> {
    //     assert(not updating);
    //     let caller = Principal.toText(msg.caller);
        
    //     if (caller == anon) {
    //         return #err(#callerIsAnon);
    //     };

    //     if (value < 1.0) {
    //         return #err(#minimalAmountIsOne);
    //     };


    //     let marketOpt = marketMap.get(marketId);
        
    //     switch (marketOpt) {
    //         case null {
    //             return #err(#marketMissing);
    //         };
    //         case (?market) {
                
    //             if (market.state != #open) {
    //                 return #err(#marketClosed);
    //             };

    //             if (market.endDate < Time.now()) {
    //                 market.state := #closed;
    //                 return #err(#marketClosed);
    //             };

    //             var user = switch (getUser(caller)) {
    //                 case (null) {
    //                     return #err(#userNotCreated);
    //                 };
    //                 case (?user) {
    //                     user;
    //                 };
    //             };
        
    //             var marketTokensOpt = Array.find(user.markets,
    //                 func (ut: UserMarket): Bool {
    //                     ut.marketId == market.id
    //                 }
    //             );

    //             switch (marketTokensOpt) {
    //                 case null {
    //                     // No tokens to sell.
    //                     return #err(#notEnoughFloat);
    //                 };
    //                 case (?marketTokens) {
    //                     if (marketTokens.balances[selected] < value) {
    //                         // No enought tokens to sell.
    //                         return #err(#notEnoughFloat);
    //                     };

    //                     let optionsSize = market.reserves.size();
    //                     var newReserves: [var Float] = Array.init(optionsSize, 0.0);
                        
    //                     for (i in Iter.range(0, optionsSize - 1)) {
    //                         newReserves[i] := market.reserves[i];
    //                     };
    //                     newReserves[selected] := newReserves[selected] + value;

    //                     let f = func (x: Float): Float {
    //                         var calcK: Float = 1;
    //                         for (i in Iter.range(0, optionsSize - 1)) {
    //                             calcK := calcK * (newReserves[i] - x);
    //                         };

    //                         return calcK - market.k;               
    //                     };

    //                     var rOpt = Utils.newtonMethod(0.0, f);

    //                     switch (rOpt) {
    //                         case (null) {
    //                             return #err(#newtonFailed);
    //                         };
    //                         case (?r) {
    //                             for (i in Iter.range(0, optionsSize - 1)) {
    //                                 newReserves[i] := newReserves[i] - r;
    //                             };
    //                             let newLiquidity = market.liquidity - r;
    //                             let liquidityOut: Float = r;

    //                             if (not save) {
    //                                 return #ok(liquidityOut);
    //                             };
                                
    //                             market.volume := market.volume + liquidityOut;
    //                             market.reserves := Array.freeze(newReserves);

    //                             let weight: [var Float] = Array.init(optionsSize, 1.0); 
    //                             let probabilities: [var Probability] = Array.init(optionsSize, 0.0);
    //                             var weightSum: Float  = 0.0;
                                    
    //                             for (i in Iter.range(0, optionsSize - 1)) {
    //                                 for (j in Iter.range(0, optionsSize - 1)) {
    //                                     if (i != j) {
    //                                         weight[i] := weight[i] * market.reserves[j];
    //                                     };
    //                                 };
    //                                 weightSum := weightSum + weight[i];
    //                             };

    //                             for (i in Iter.range(0, optionsSize - 1)) {
    //                                 probabilities[i] := weight[i] * 1000.0 / weightSum;
    //                             };

    //                             market.probabilities := Array.freeze(probabilities);

    //                             user.markets := Array.mapFilter(user.markets, 
    //                                 func (ut: UserMarket): ?UserMarket {
    //                                     if (ut.marketId != market.id) {
    //                                         return ?ut;
    //                                     } else {
    //                                         let newFloats = Array.mapEntries(ut.balances,
    //                                             func (b: Float, i: Nat): Float {
    //                                                 if (i == selected) {
    //                                                     return b - value;
    //                                                 } else {
    //                                                     return b;
    //                                                 };
    //                                             }
    //                                         );

    //                                         let newUserMarket: UserMarket = {
    //                                             marketId = market.id;
    //                                             marketTitle = market.title;
    //                                             labels = market.labels;
    //                                             balances = newFloats;
    //                                             shares = ut.shares;
    //                                             used = ut.used;
    //                                         };

    //                                         return ?newUserMarket;
    //                                     };
    //                                 }
    //                             );

    //                             let newTx: UserTx = {
    //                                 marketId = market.id;
    //                                 src = ?selected;
    //                                 dest = null;
    //                                 seerSent = value;
    //                                 seerRecv = liquidityOut;
    //                                 fee = 0.0;
    //                                 timestamp = Time.now();
    //                             };
    //                             user.txs := Array.append(user.txs, [newTx]);

    //                             user.seerFloat := user.seerFloat + liquidityOut;

    //                             return #ok(liquidityOut);
    //                         };
    //                     };
    //                 };
    //             };
    //         };
    //     };
    // };

    // public shared(msg) func buyOption(
    //         marketId: Nat32,
    //         value: Float,
    //         selected: Nat,
    //         save: Bool
    //     ): async Result.Result<Float, TradeError> {
    //     assert(not updating);

    //     let caller = Principal.toText(msg.caller);
        
    //     if (caller == anon) {
    //         return #err(#callerIsAnon);
    //     };

    //     var user = switch (getUser(caller)) {
    //         case (null) {
    //             return #err(#userNotCreated);
    //         };
    //         case (?user) {
    //             user;
    //         };
    //     };

    //     if (user.seerFloat < value) {
    //         return #err(#notEnoughFloat);
    //     };


    //     if (value < 1.0) {
    //         return #err(#minimalAmountIsOne);
    //     };

    //     let marketOpt = marketMap.get(marketId);

    //     switch (marketOpt) {
    //         case null {
    //             return #err(#marketMissing);
    //         };
    //         case (?market) {
    //             if (market.state != #open) { 
    //                 return #err(#marketClosed);
    //             };

    //             if (market.endDate < Time.now()) { 
    //                 market.state := #closed;
    //                 return #err(#marketClosed);
    //             };
                
    //             let optionsSize = market.reserves.size();
    //             var semiK: Float = 1.0;

    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 if (i != selected) {
    //                     semiK := semiK * (market.reserves[i] + value);
    //                 };
    //             };
                
    //             let newSelectedReserve: Float = market.k / semiK;
    //             let tokensOut = market.reserves[selected] - newSelectedReserve + value;
                
    //             if (not save) { // Dry run.
    //                 return #ok(tokensOut);
    //             };

    //             var newReserves: [var Float] = Array.init(optionsSize, 0.0);
    //             let newLiquidity = market.liquidity + value;
               
    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 if (i != selected) {
    //                     newReserves[i] := market.reserves[i] + value;
    //                 } else {
    //                     newReserves[i] := newSelectedReserve;
    //                 };
    //             };
                
    //             market.reserves := Array.freeze(newReserves);
    //             market.liquidity := newLiquidity;
    //             market.volume := market.volume + value;

    //             let weight: [var Float] = Array.init(optionsSize, 1.0); 
    //             let probabilities: [var Probability] = Array.init(optionsSize, 0.0);
    //             var weightSum: Float  = 0.0;
                    
    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 for (j in Iter.range(0, optionsSize - 1)) {
    //                     if (i != j) {
    //                         weight[i] := weight[i] * market.reserves[j];
    //                     };
    //                 };
    //                 weightSum := weightSum + weight[i];
    //             };

    //             for (i in Iter.range(0, optionsSize - 1)) {
    //                 probabilities[i] := weight[i] * 1000.0 / weightSum;
    //             };

    //             market.probabilities :=  Array.freeze(probabilities);

    //             var marketTokensOpt = Array.find(user.markets,
    //                 func (ut: UserMarket): Bool {
    //                     ut.marketId == market.id
    //                 }
    //             );

    //             switch (marketTokensOpt) {
    //                 case null {
    //                     let balances: [var Float] = Array.init(optionsSize, 0.0);
    //                     balances[selected] := tokensOut;

    //                     let newUserMarket: UserMarket = {
    //                         marketId = market.id;
    //                         marketTitle = market.title;
    //                         labels = market.labels;
    //                         balances = Array.freeze(balances);
    //                         shares = 0;
    //                         used = false;
    //                     };
    //                     user.markets := Array.append(user.markets, [newUserMarket]);
    //                 };
    //                 case (?marketTokens) {
    //                     user.markets := Array.mapFilter(user.markets, 
    //                         func (ut: UserMarket): ?UserMarket {
    //                             if (ut.marketId != market.id) {
    //                                 return ?ut;
    //                             } else {
    //                                 let newFloats = Array.mapEntries(ut.balances,
    //                                     func (b: Float, i: Nat): Float {
    //                                         if (i == selected) {
    //                                             return b + tokensOut;
    //                                         } else {
    //                                             return b;
    //                                         };
    //                                     }
    //                                 );

    //                                 let newUserMarket: UserMarket = {
    //                                     marketId = market.id;
    //                                     marketTitle = market.title;
    //                                     labels = market.labels;
    //                                     balances = newFloats;
    //                                     shares = ut.shares;
    //                                     used = ut.used;
    //                                 };
    //                                 return ?newUserMarket;
    //                             };
    //                         }
    //                     );
    //                 };
    //             };

    //             user.seerFloat := user.seerFloat - value;
    //             let newTx: UserTx = {
    //                 marketId = market.id;
    //                 src = null;
    //                 dest = ?selected;
    //                 seerSent = value;
    //                 seerRecv = tokensOut;
    //                 fee = 0.0;
    //                 timestamp = Time.now();
    //             };
    //             user.txs := Array.append(user.txs, [newTx]);

    //             return #ok(tokensOut);
    //         };
    //     };
    // };

    // Get user data.
    public query func getUserStable(userId: Text): async ?U.UserStable {
        return Option.map(getUser(userId), func (u: U.User): U.UserStable {
            return u.freeze();
        });
    };

    // public shared(msg) func cleanTxs(userId: Text): async () {
    //     assert(msg.caller == initializer); // Root call.
    //     switch (userMap.get(userId)) {
    //         case (null) {

    //         };
    //         case (?user) {
    //             user.txs := [];
    //         };
    //     };
    // };

    // Create user.
    public shared(msg) func createUser(handle: Text): async Result.Result<U.UserStable, U.UserError> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);

        if (caller == anon) {
            return #err(#callerIsAnon);
        };
        
        switch (_createUser(caller, handle)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(user)) {
                return #ok(user.freeze())
            };
        };
    };


    // Tip a user
    // public shared(msg) func tip(id: Text, value: Float): async ?Float {
    //     assert(msg.caller == initializer); // Root call.

    //     var user = switch (getUser(id)) {
    //         case (null) {
    //             return null;
    //         };
    //         case (?user) {
    //             user;
    //         };
    //     };
    //     user.seerFloat := user.seerFloat + value;

    //     return ?user.seerFloat;
    // };

    // Edit market image.
    // public shared(msg) func editMarketImage(marketId: Nat32, newImage: Text): async Bool {
    //     assert(msg.caller == initializer); // Root call.

    //     let marketOpt = marketMap.get(marketId);

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

    // Edit market probabilities.
    // public shared(msg) func editMarketProbs(marketId: Nat32, newProbs: [Float]): async Bool {
    //     assert(msg.caller == initializer); // Root call.

    //     let marketOpt = marketMap.get(marketId);

    //     switch (marketOpt) {
    //         case null {
    //             return false;
    //         };
    //         case (?market) {
    //             market.probabilities := newProbs;
    //             return true;
    //         };
    //     };

    //     return false;
    // };

    // Add a comment to a market.
    public shared(msg) func addCommentToMarket(marketId: Nat32, content: Text): async Result.Result<Comment.CommentStable, M.MarketError> {
        assert(not updating);
        
        let userId = Principal.toText(msg.caller);
        
        if (userId == anon) {
            return #err(#callerIsAnon);
        };

        if (content == "") {
            return #err(#commentIsEmpty);
        };

        let userOpt = userMap.get(userId);

        switch (userOpt) {
            case null {
                return #err(#profileNotCreated);
            };
            case (?user) {
                let marketOpt = marketMap.get(marketId);

                switch (marketOpt) {
                    case null {
                        return #err(#marketMissing);
                    };
                    case (?market) {
                        let initData: Comment.CommentInitData = {
                            id = Nat32.fromNat(market.comments.size());
                            author = user.id;
                            content = content;
                        };
                        let comment: Comment.Comment = Comment.Comment(initData);
                        market.comments.add(comment);
                        
                        return #ok(comment.freeze());
                    };
                };
            };
        };
    };

    /**
    * Utilities
    */

    // private func marketKey(x: Nat32) : Trie.Key<Nat32> {
    //     return { hash = x; key = x };
    // };

    // private func getMarket(k: Nat32, v: Market): Market {
    //     return v;
    // };

    // private func keepOpenMarkets(o: (Nat32, Market)): ?M.MarketStable {
    //     let m = o.1;
    //     switch (m.state) {
    //         case (#open) {
    //             let market = {
    //                 id = m.id;    
    //                 title = m.title;
    //                 description = m.description;
    //                 labels = m.labels;  
    //                 images = m.images;
    //                 probabilities = m.probabilities;
    //                 liquidity = m.liquidity;
    //                 reserves = m.reserves;
    //                 k = m.k;
    //                 startDate = m.startDate;
    //                 endDate = m.endDate;
    //                 author = m.author;
    //                 blockTimestampLast = m.blockTimestampLast;
    //                 totalShares = m.totalShares;
    //                 providers = m.providers;
    //                 imageUrl = m.imageUrl;
    //                 state = m.state;
    //                 volume = m.volume;
    //                 comments = m.comments;
    //             };
    //             return ?market;
    //         };
    //         case _ {
    //             return null;
    //         };
    //     };
    //     return null;
    // };

    // private func keepPendingMarkets(o: (Nat32, Market)): ?M.MarketStable {
    //     let m = o.1;
    //     switch (m.state) {
    //         case (#pending) {
    //             let market = {
    //                 id = m.id;    
    //                 title = m.title;
    //                 description = m.description;
    //                 labels = m.labels;
    //                 images = m.images;
    //                 probabilities = m.probabilities;
    //                 liquidity = m.liquidity;
    //                 reserves = m.reserves;
    //                 k = m.k;
    //                 startDate = m.startDate;
    //                 endDate = m.endDate;
    //                 author = m.author;
    //                 blockTimestampLast = m.blockTimestampLast;
    //                 totalShares = m.totalShares;
    //                 providers = m.providers;
    //                 imageUrl = m.imageUrl;
    //                 state = m.state;
    //                 volume = m.volume;
    //                 comments = m.comments;
    //             };
    //             return ?market;
    //         };
    //         case _ {
    //             return null;
    //         };
    //     };
    //     return null;
    // };

    private func getUser(userId: Text): ?U.User {
        userMap.get(userId)
    };

    // private type CreateUserError = {
    //     #userExist;
    //     #userIsAnon;
    // };


    private func _createUser(userId: Text, handle: Text): Result.Result<U.User, U.UserError> {
        switch (userMap.get(handle)) {
            case (null) {
                let user: U.User = U.User({
                    id = userId;
                    handle = handle;
                    picture = "";
                    twitter = "";
                    discord = "";
                    bio = "";
                });

                handles := Trie.replace(
                    handles,
                    U.userKey(handle),
                    Text.equal,
                    ?handle,
                ).0;

                userMap.put(userId, user);

                return #ok(user);
            };
            case (userId) {
                return #err(#userAlreadyExist);
            };
        };
    };
};
