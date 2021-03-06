import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
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
import Prim "mo:⛔";

import M "Market";
import U "User";
import Utils "Utils";
import Tx "Tx";
import Post "Post";
import Comment "Comment";
import Like "Like";
import Forecast "Forecast";
import Account "Account";

import Ledger "Ledger";
// import LedgerC "LedgerCandid";
// import XDR "XDR";


shared({ caller = initializer }) actor class Market() = this {
    private let ledger: Ledger.Interface  = actor(Ledger.CANISTER_ID);
    private stable var anon: Text = "2vxsx-fae";

    // Returns the default account identifier of this canister.
    func makeAccountIdentifier(subaccount: Account.Subaccount) : Account.AccountIdentifier {
        Account.accountIdentifier(Principal.fromActor(this), subaccount)
    };


    // Returns the default account identifier of this canister.
    func myAccountId() : Account.AccountIdentifier {
        Account.accountIdentifier(Principal.fromActor(this), Account.defaultSubaccount())
    };

    // Returns the default account identifier of this canister.
    func otherAccountId() : Account.AccountIdentifier {
        Account.accountIdentifier(Principal.fromActor(this), Account.otherSubaccount())
    };

    // Returns current balance on the default account of this canister.
    public func canisterBalance() : async Ledger.ICP {
        await ledger.account_balance({ account = myAccountId() })
    };

    /* Types */

    // Returns canister's default account identifier as text.
    public query func canisterAccount() : async Text {
        Account.toText(myAccountId())
    };

    // Returns canister's default account identifier as text.
    public query func otherAccount() : async Text {
        Account.toText(otherAccountId())
    };

    // Returns current balance on the default account of this canister.
    public func accountBalance(account: Text) : async ?Ledger.ICP {
        switch (Account.fromText(account)) {
            case null {
                return null;
            };
            case (?account) {
                let balance = await ledger.account_balance({ account = account });
                return ?balance;
            };
        }
    };

    public shared(msg) func transferToSubaccount(): async Text {
        // assert(msg.caller == initializer);
        let args = {
            memo = Prim.time();
            amount = { e8s = 90_000 : Nat64 }; // 0.001 ICP 
            fee = { e8s = 10_000 : Nat64 };
            from_subaccount = null;
            to = otherAccountId();
            created_at_time = null;
        };
        switch(await ledger.transfer(args)){
            case(#Ok(idx)){ "transfer successfully on block : " # debug_show(idx) };
            case(#Err(error)){ debug_show(error) };
        }
    };

    public shared(msg) func transferToCanister(): async Text{
        // assert(msg.caller == initializer);
        Debug.print(debug_show(initializer));
        Debug.print(debug_show(msg.caller));

        let args = {
            memo = Prim.time();
            amount = { e8s = 80_000 : Nat64 }; // 0.001 ICP 
            fee = { e8s = 10_000 : Nat64 };
            from_subaccount = ?Account.otherSubaccount();
            to = myAccountId();
            created_at_time = null;
        };
        switch(await ledger.transfer(args)){
            case(#Ok(idx)){ "transfer successfully on block : " # debug_show(idx) };
            case(#Err(error)){ debug_show(error) };
        }
    };



    // Returns canister's default account identifier as a blob.
    public shared(msg) func callerAccount() : async Account.AccountIdentifier {
        let principal = msg.caller;
        return Account.accountIdentifier(principal, Account.defaultSubaccount());
    };
    
    /* State */
    
    private stable var updating: Bool = false;
    private stable var nextMarketId: Nat32 = 0;
    
    private stable var stableUsers: [(Text, U.UserStable)] = [];
    private stable var stableMarkets: [(Nat32, M.MarketStable)] = [];
    private stable var stableFeed: [Post.PostStable] = [];
    private stable var stablePosts: [(Nat32, Post.PostStable)] = [];
    private stable var stableImages: [(Nat32, Text)] = [];
    private stable var stableHandles: [(Text, Text)] = [];

    private var feed: Buffer.Buffer<Post.Post> = Buffer.Buffer<Post.Post>(10);
    
    private var userDataMap: Map.HashMap<Text, Utils.UserData> = do {
        let usersIter = Iter.map<(Text, U.UserStable), (Text, Utils.UserData)>(
            stableUsers.vals(), 
            func (e: (Text, U.UserStable)): (Text, Utils.UserData) {
                let u = U.unFreezeUser(e.1);
                let ud: Utils.UserData = {
                    principal = u.id;
                    name = u.name;
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
                let v = M.unFreeze(e.1);
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

    private var postMap: Map.HashMap<Nat32, Post.Post> = do {
        let postIter = Iter.map<(Nat32, Post.PostStable), (Nat32, Post.Post)>(
            stablePosts.vals(), 
            func (e: (Nat32, Post.PostStable)): (Nat32, Post.Post) {
                let v = Post.unFreeze(e.1);
                return (e.0, v);
            }
        );
        
        Map.fromIter<Nat32, Post.Post>(
            postIter,
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x } 
        )
    };

    private var imageMap: Map.HashMap<Nat32, Text> = do {
        let imageIter = Iter.map<(Nat32, Text), (Nat32, Text)>(
            stableImages.vals(), 
            func (e: (Nat32, Text)): (Nat32, Text) {
                // let v = Post.unFreeze(e.1);
                return e;
            }
        );
        
        Map.fromIter<Nat32, Text>(
            imageIter,
            10, 
            Nat32.equal, 
            func (x: Nat32): Nat32 { x } 
        )
    };
    
    private var handlesMap: Map.HashMap<Text, Text> = do {
        Map.fromIter<Text, Text>(
            stableHandles.vals(),
            stableHandles.size(), 
            Text.equal, 
            Text.hash 
        )
    };

    public type Error = {
        #callerIsAnon;
        #profileNotCreated;
        #notEnoughLiquidity;
        #titleMissing;
        #descriptionMissing;
        #optionsMissing;
        #imageMissing;
        #startDateOld;
        #endDateOld;
        #endDateOlderThanStartDate;
        #notEnoughBalance;
        #marketMissing;
        #marketNotOpen;
        #newtonFailed;
        #lowerThanMinAmount;
        #commentIsEmpty;
        #userAlreadyExist;
        #userDoesNotExist;
        #handleAlreadyTaken;
        #cantGetBalance;

        #notLoggedIn;
        #postDoesNotExist;
        #alreadyLiked;
        #marketNotFound;
        #imageNotFound;
        #parentDoesNotExist;
        #alreadyRetweeted;
        #postIsEmpty;

        #onlyAuthorCanEdit;
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

    // Read user data corresponding to these user principals.
    public query func readUserData(users: [Text]): async [Utils.UserData] {
        return Array.mapFilter<(Text, Utils.UserData), Utils.UserData>(
            Iter.toArray(userDataMap.entries()), 
            func (e: (Text, Utils.UserData)): ?Utils.UserData {
                let exist = Array.find(users, func (p: Text): Bool {
                    return p == e.0;
                });
                switch (exist) {
                    case (null) {
                        return null;
                    };
                    case (?p) {
                        return ?e.1;
                    };
                };
            }
        );
    };

    public shared(msg) func setUpdating(status: Bool): () {
        assert(msg.caller == initializer); // Root call.
        updating := status;
    };

    // Delete all users.
    public shared(msg) func deleteAllUsers(): async Bool {
        assert(msg.caller == initializer); // Root call.
        
        userMap := Map.fromIter<Text, U.User>(
            ([]).vals(),
            0, 
            Text.equal, 
            Text.hash
        );

        handlesMap := Map.fromIter<Text, Text>(
            ([]).vals(),
            0, 
            Text.equal, 
            Text.hash
        );

        return true;
    };

    // Approve a market.
    public shared(msg) func setMarketState(marketId: Nat32, state: M.MarketState): async Bool {
        assert(msg.caller == initializer); // Root call.

        switch (marketMap.get(marketId)) {
            case (null) {
                return false;
            };
            case (?market) {
                market.state := state;
                return true;
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

    private func checkMarketInitData(marketInitData: M.MarketInitData): Result.Result<(), Error> {
        if (marketInitData.liquidity < 10) {
            return #err(#notEnoughLiquidity);
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

        if (marketInitData.endDate < Time.now()) {
            return #err(#endDateOld);
        };

        return #ok(());
    };


    private func _createMarket(author: Text, marketInitData: M.MarketInitData): Result.Result<M.MarketStable, Error> {
        
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

    // Create a new AMM market.
    public shared(msg) func createMarket(marketInitData: M.MarketInitData): async Result.Result<M.MarketStable, Error> {
        assert(not updating);
        let author = Principal.toText(msg.caller);        
        
        if (author == anon) {
            return #err(#callerIsAnon);
        };

        return _createMarket(author, marketInitData);
    };

    // Submit a retweet.
    public shared(msg) func submitRetweet(postId: Nat32): async Result.Result<(), Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#notLoggedIn);
        };
        
        switch (getUser(caller)) {
            case null {
                return #err(#userDoesNotExist);
            };
            case (?author) {
                switch (postMap.get(postId)) {
                    case null {
                        #err(#postDoesNotExist);
                    };
                    case (?post) {
                        var newRetweeters = Buffer.Buffer<Utils.UserData>(post.retweeters.size());
                        var exist: Bool = false;

                        for (r in post.retweeters.vals()) {
                            if (r.principal == caller) {
                                exist := true;
                            } else {
                                newRetweeters.add(r);
                            };
                        };

                        let authorData: Utils.UserData = {
                            principal = author.id;
                            handle = author.handle;
                            name = author.name;
                            picture = author.picture;
                        };
                            

                        // Remove it from user if it exist (un-retweet).
                        if (exist) {
                            var newRetweets = Buffer.Buffer<Nat32>(author.retweets.size());

                            for (r in author.retweets.vals()) {
                                if (r != postId) {
                                    newRetweets.add(r);
                                };
                            };

                            author.retweets := newRetweets;
                        } else {
                        // We add it to the post and the user if it doesn't exist (retweet).
                            newRetweeters.add(authorData);
                            author.retweets.add(post.id);
                        };

                        post.retweeters := newRetweeters;
                        var retweet = post.clone();
                        retweet.isRetweet := ?authorData;
                        
                        // TODO: un-comment after we add followers.
                        // feed.add(retweet);
                        return #ok();
                    };
                };
            };
        };
    };

    // Delete a post.
    public shared(msg) func submitDelete(postId: Nat32): async Result.Result<(), Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#notLoggedIn);
        };

        switch (getUser(caller)) {
            case null {
                return #err(#userDoesNotExist);
            };
            case (?author) {
                switch (postMap.get(postId)) {
                    case null {
                        return #err(#postDoesNotExist);
                    };
                    case (?post) {
                        post.content := "<Post was deleted>";
                        post.retweet := null;
                        post.market := null;
                        post.image := null;
                        post.deleted := true;

                        return #ok();
                    };
                };
            };
        };
    }; 

    // Edit a post of any type.
    public shared(msg) func editPost(initData: Post.PostInitData, marketInitData: ?M.MarketInitData): async Result.Result<(), Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#notLoggedIn);
        };

        if (initData.content == "") {
            return #err(#postIsEmpty);
        };
        
        switch (getUser(caller)) {
            case null {
                return #err(#userDoesNotExist);
            };
            case (?author) {
                switch (postMap.get(initData.id)) {
                    case null {
                        return #err(#postDoesNotExist);
                    };
                    case (?post) {
                        if (post.author.principal != caller) {
                            return #err(#onlyAuthorCanEdit);
                        };

                        post.content :=  initData.content;

                        return #ok();
                    };
                };
            };
        };
    };

    // Submit a post of any type.
    public shared(msg) func submitPost(initData: Post.PostInitData, marketInitData: ?M.MarketInitData): async Result.Result<(), Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#notLoggedIn);
        };

        if (initData.content == "") {
            return #err(#postIsEmpty);
        };
        
        switch (getUser(caller)) {
            case null {
                return #err(#userDoesNotExist);
            };
            case (?author) {

                let id = Nat32.fromNat(postMap.size() + 1);
                var isReply = false;
                switch (initData.parent) {
                    case null {
                        // do nothing
                    };
                    case (?parentData) {
                        switch (postMap.get(parentData.id)) {
                            case null {
                                return #err(#parentDoesNotExist);
                            };
                            case (?parentPost) {
                                isReply := true;
                                parentPost.replies.add(id);
                            };
                        };
                    };
                };
        
                let authorData: Utils.UserData = {
                    principal = author.id;
                    name = author.name;
                    handle = author.handle;
                    picture = author.picture;
                };

                var newInitData: Post.PostInitData = {
                    id = id;
                    author = authorData;
                    content = initData.content;
                    parent = initData.parent;
                    image = initData.image;
                    market = initData.market;
                    retweet = initData.retweet;
                    isRetweet = initData.isRetweet;
                };

                var post: Post.Post = Post.Post(newInitData);
                var isRetweet = false;

                // Retweet.
                switch (initData.retweet) {
                    case null {
                        // do nothing
                    };
                    case (?other) {
                        switch (postMap.get(other.id)) {
                            case null {
                                return #err(#postDoesNotExist);
                            };
                            case (?realOther) {
                                var exist = false;
                                var newRetweeters = Buffer.Buffer<Utils.UserData>(realOther.retweeters.size());

                                for (r in realOther.retweeters.vals()) {
                                    if (r.principal == caller) {
                                        exist := true;
                                    } else {
                                        newRetweeters.add(r);
                                    };
                                };
                                if (not exist) {
                                    let retweeter: Utils.UserData = authorData;
                                    newRetweeters.add(retweeter);
                                };
                                realOther.retweeters := newRetweeters;
                            };
                        };
                    };
                };

                // Image.
                switch (post.image) {
                    case null {
                        // do nothing
                    };
                    case (?image) {
                        imageMap.put(Nat32.fromNat(imageMap.size()), image);
                    };
                };

                // Market.
                switch (marketInitData) {
                    case null {
                        // do nothing
                    };
                    case (?marketInitData) {
                        switch (_createMarket(caller, marketInitData)) {
                            case (#err(e)) {
                                return #err(e);
                            };
                            case (#ok(marketStable)) {
                                post.market := marketMap.get(marketStable.id);
                            };
                        };
                    };
                };

                if (isReply) {
                    author.replies.add(id);
                } else {
                    author.posts.add(id);
                };

                postMap.put(id, post);
                feed.add(post);

                return #ok();
            };
        };
    };

    // Submit a like.
    public shared(msg) func submitLike(postId: Nat32): async Result.Result<(), Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#notLoggedIn);
        };
        
        switch (getUser(caller)) {
            case null {
                return #err(#userDoesNotExist);
            };
            case (?user) {
                switch (postMap.get(postId)) {
                    case null {
                        return #err(#postDoesNotExist);
                    };
                    case (?post) {
                        var newLikes = Buffer.Buffer<Like.Like>(post.likes.size());
                        var found: Bool = false;

                        for (like in post.likes.vals()) {
                            if (like.author.principal != caller) {
                                newLikes.add(like);
                            } else {
                                // Unlike case, we remove.
                                found := true;
                            };
                        };

                        if (not found) {
                            let userData: Utils.UserData = {
                                principal = user.id;
                                name = user.name;
                                handle = user.handle;
                                picture = user.picture;
                            };
                            let newLike: Like.Like = {
                                author = userData;
                                createdAt = Time.now();
                            };
                            newLikes.add(newLike);
                        };

                        post.likes := newLikes;

                        return #ok()
                    };
                };
            };
        };
    };

    // Read a market.
    public query func readMarket(marketId: Nat32): async ?M.MarketStable {
        let result = marketMap.get(marketId);
        return Option.map(result, func (m: M.Market): M.MarketStable {
            return m.freeze();
        });        
    };

    // Read a post.
    public query func getPost(postId: Nat32): async Result.Result<Post.PostStable, Error> {
        switch (postMap.get(postId)) {
            case null {
                return #err(#userDoesNotExist);
            };
            case (?post) {
                return #ok(post.freeze());
            };
        };
    };

    // Read the thread.
    public query func getThread(postId: Nat32): async Result.Result<Post.ThreadStable, Error> {
        switch (postMap.get(postId)) {
            case null {
                return #err(#postDoesNotExist);
            };
            case (?post) {
                var replies = Buffer.Buffer<Post.PostStable>(post.replies.size());

                for (replyId in post.replies.vals()) {
                    switch (postMap.get(replyId)) {
                        case null {
                            // Reply missing, continue. 
                        };
                        case (?reply) {
                            replies.add(reply.freeze());
                        };
                    };
                };

                var exit = false;
                var ancestors = Buffer.Buffer<Post.PostStable>(1);
                var current = post;
                            
                while (not exit) {
                    switch (current.parent) {
                        case null {
                            exit := true;
                        };
                        case (?parent) {
                            switch (postMap.get(parent.id)) {
                                case null {
                                    // This case shouldn't happen, on delete we leave a dummy.
                                    exit := true;
                                };
                                case (?ancestor) {
                                    ancestors.add(ancestor.freeze());
                                    current := ancestor;
                                };
                            };
                        };    
                    };
                };

                let t: Post.ThreadStable = {
                    ancestors = ancestors.toArray();
                    main = post.freeze();
                    replies = replies.toArray();
                };
                
                return #ok(t);
            };
        };
    };

    // Read all markets.
    public query func readAllMarkets(
        category: M.MarketCategory,
        state: M.MarketState,
    ): async [M.MarketStable] {
        return Array.mapFilter<(Nat32, M.Market), M.MarketStable>(
            Iter.toArray(marketMap.entries()),
            func (e: (Nat32, M.Market)): ?M.MarketStable {
                if ((category == #any or e.1.category == category)
                    and (state == #any or e.1.state == state)) {
                        return ?e.1.freeze();
                };
                return null;
            }
        );
    };

    public shared(msg) func refreshUser(): async Result.Result<U.UserStable, Error> {
        assert(not updating);
        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#callerIsAnon);
        };

        switch (getUser(caller)) {
            case (null) {
                return #err(#profileNotCreated);
            };
            case (?user) {
                user.expBalances := {
                    seers = user.balances.seers;
                    icp = user.balances.icp;
                    cycles = user.balances.cycles;
                    btc = user.balances.btc;
                };

                // Query the ledger to update ICP balance.
                switch (await accountBalance(user.depositAddrs.icp)) {
                    case null {
                        return #err(#cantGetBalance);
                    };
                    case (?balance) {
                        user.balances := {
                            seers = user.balances.seers;
                            icp = Float.fromInt64(Int64.fromNat64(balance.e8s));
                            cycles = user.balances.cycles;
                            btc = user.balances.btc;
                        };
                    };
                };

                var markets = user.markets.toArray();
                markets := Array.mapFilter(markets, 
                    func (ut: U.UserMarket): ?U.UserMarket {
                        let marketOpt = marketMap.get(ut.marketId);
                        
                        switch (marketOpt) {
                            case (null) {
                                // Market was deleted so we delete its data from the user.
                                return null;
                            };
                            case (?market) {
                                switch (market.state) {
                                    case (#resolved(i)) {
                                        if (not ut.redeemed) {
                                            let reward = ut.balances[i];

                                            switch (market.collateralType) {
                                                case (#seers) {
                                                    user.balances := {
                                                        seers = user.balances.seers + reward;
                                                        icp = user.balances.icp;
                                                        cycles = user.balances.cycles;
                                                        btc = user.balances.btc;
                                                    };

                                                    user.expBalances := {
                                                        seers = user.expBalances.seers + reward;
                                                        icp = user.expBalances.icp;
                                                        cycles = user.expBalances.cycles;
                                                        btc = user.expBalances.btc;
                                                    };
                                                };
                                                case (#icp) {
                                                    user.balances := {
                                                        seers = user.balances.seers;
                                                        icp = user.balances.icp + reward;
                                                        cycles = user.balances.cycles;
                                                        btc = user.balances.btc;
                                                    };
                                                    user.expBalances := {
                                                        seers = user.expBalances.seers;
                                                        icp = user.expBalances.icp + reward;
                                                        cycles = user.expBalances.cycles;
                                                        btc = user.expBalances.btc;
                                                    };
                                                };
                                                case (#cycles) {
                                                    user.balances := {
                                                        seers = user.balances.seers;
                                                        icp = user.balances.icp;
                                                        cycles = user.balances.cycles + reward;
                                                        btc = user.balances.btc;
                                                    };
                                                    user.expBalances := {
                                                        seers = user.expBalances.seers;
                                                        icp = user.expBalances.icp;
                                                        cycles = user.expBalances.cycles + reward;
                                                        btc = user.expBalances.btc;
                                                    };
                                                };
                                                case (#btc) {
                                                    user.balances := {
                                                        seers = user.balances.seers;
                                                        icp = user.balances.icp;
                                                        cycles = user.balances.cycles;
                                                        btc = user.balances.btc + reward;
                                                    };
                                                    user.expBalances := {
                                                        seers = user.expBalances.seers;
                                                        icp = user.expBalances.icp;
                                                        cycles = user.expBalances.cycles;
                                                        btc = user.expBalances.btc + reward;
                                                    };
                                                };
                                            };

                                            let oldMarket: U.UserMarket = {
                                                marketId = ut.marketId;
                                                title = ut.title;
                                                labels = ut.labels;
                                                balances = ut.balances;
                                                collateralType = ut.collateralType;
                                                brierScores = ut.brierScores;
                                                shares = ut.shares;
                                                spent = ut.spent;
                                                redeemed = true;
                                                author = ut.author;
                                                createdAt = ut.createdAt;
                                                modifiedAt = ut.modifiedAt;
                                            };

                                            return ?oldMarket;
                                        };

                                        return ?ut;
                                    };
                                    case (#open) {
                                        // Market still open. Update expected balance.
                                        let optionsSize = market.probabilities.size();

                                        switch (market.collateralType) {
                                            case (#seers) {
                                                var b = user.expBalances.seers;

                                                for (j in Iter.range(0, optionsSize - 1)) {
                                                    b := b + market.probabilities[j] * ut.balances[j]; 
                                                };

                                                user.expBalances := {
                                                    seers = b;
                                                    icp = user.expBalances.icp;
                                                    cycles = user.expBalances.cycles;
                                                    btc = user.expBalances.btc;
                                                };
                                            };
                                            case (#icp) {
                                                var b = user.expBalances.icp;

                                                for (j in Iter.range(0, optionsSize - 1)) {
                                                    b := b + market.probabilities[j] * ut.balances[j]; 
                                                };

                                                user.expBalances := {
                                                    seers = user.expBalances.seers;
                                                    icp = b;
                                                    cycles = user.expBalances.cycles;
                                                    btc = user.expBalances.btc;
                                                };
                                            };

                                            case (#cycles) {
                                                var b = user.expBalances.cycles;

                                                for (j in Iter.range(0, optionsSize - 1)) {
                                                    b := b + market.probabilities[j] * ut.balances[j]; 
                                                };

                                                user.expBalances := {
                                                    seers = user.expBalances.seers;
                                                    icp = user.expBalances.icp;
                                                    cycles = b;
                                                    btc = user.expBalances.btc;
                                                };
                                            };

                                            case (#btc) {
                                                var b = user.expBalances.btc;

                                                for (j in Iter.range(0, optionsSize - 1)) {
                                                    b := b + market.probabilities[j] * ut.balances[j]; 
                                                };

                                                user.expBalances := {
                                                    seers = user.expBalances.seers;
                                                    icp = user.expBalances.icp;
                                                    cycles = user.expBalances.cycles;
                                                    btc = b;
                                                };
                                            };
                                        };

                                        

                                        return ?ut;
                                    };
                                    case _ {
                                        return ?ut;
                                    };
                                };
                            };
                        };
                    }
                );
                user.markets := Utils.bufferFromArray(markets);
                return #ok(user.freeze());
            };
        };
    };

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
    public shared(msg) func sellOutcome(
        marketId: Nat32,
        value: Float,
        selected: Nat,
        save: Bool
    ): async Result.Result<Float, Error> {
        assert(not updating);
        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#callerIsAnon);
        };

        if (value < 0.1) {
            return #err(#lowerThanMinAmount);
        };

        let marketOpt = marketMap.get(marketId);
        
        switch (marketOpt) {
            case null {
                return #err(#marketMissing);
            };
            case (?market) {
                
                if (market.state != #open) {
                    return #err(#marketNotOpen);
                };

                if (market.endDate < Time.now()) {
                    market.state := #closed;
                    return #err(#marketNotOpen);
                };

                var user = switch (getUser(caller)) {
                    case (null) {
                        return #err(#profileNotCreated);
                    };
                    case (?user) {
                        user;
                    };
                };

                var markets = user.markets.toArray();
                let marketTokensOpt = Array.find<U.UserMarket>(markets,
                    func (ut: U.UserMarket): Bool {
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
                        var newReserves: [var Float] = Array.init(optionsSize, 0.0);
                        
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

                        var rOpt = Utils.newtonMethod(0.0, f);

                        switch (rOpt) {
                            case (null) {
                                return #err(#newtonFailed);
                            };
                            case (?r) {
                                for (i in Iter.range(0, optionsSize - 1)) {
                                    newReserves[i] := newReserves[i] - r;
                                };
                                let newLiquidity = market.liquidity - r;
                                let liquidityOut: Float = r;

                                if (not save) {
                                    return #ok(liquidityOut);
                                };
                                
                                market.volume := market.volume + liquidityOut;
                                market.reserves := Array.freeze(newReserves);

                                let weight: [var Float] = Array.init(optionsSize, 1.0); 
                                let probabilities: [var Float] = Array.init(optionsSize, 0.0);
                                var weightSum: Float  = 0.0;
                                    
                                for (i in Iter.range(0, optionsSize - 1)) {
                                    for (j in Iter.range(0, optionsSize - 1)) {
                                        if (i != j) {
                                            weight[i] := weight[i] * market.reserves[j];
                                        };
                                    };
                                    weightSum := weightSum + weight[i];
                                };

                                for (i in Iter.range(0, optionsSize - 1)) {
                                    probabilities[i] := weight[i] / weightSum;
                                };

                                market.probabilities := Array.freeze(probabilities);

                                markets := Array.mapFilter(markets, 
                                    func (ut: U.UserMarket): ?U.UserMarket {
                                        if (ut.marketId != market.id) {
                                            return ?ut;
                                        } else {
                                            let newBalances = Array.mapEntries(ut.balances,
                                                func (b: Float, i: Nat): Float {
                                                    if (i == selected) {
                                                        return b - value;
                                                    } else {
                                                        return b;
                                                    };
                                                }
                                            );

                                            let newUserMarket: U.UserMarket = {
                                                author = ut.author;
                                                balances = newBalances;
                                                brierScores = ut.brierScores;
                                                collateralType = ut.collateralType;
                                                createdAt = ut.createdAt;
                                                labels = market.labels;
                                                marketId = market.id;
                                                modifiedAt = Time.now();
                                                title = market.title;
                                                shares = ut.shares;
                                                spent = ut.spent - liquidityOut;
                                                redeemed = false;
                                            };

                                            return ?newUserMarket;
                                        };
                                    }
                                );

                                user.markets := Utils.bufferFromArray(markets);
                                let newTx: Tx.UserTx = {
                                    id = Nat32.fromNat(user.txs.size());
                                    marketId = market.id;
                                    src = ?selected;
                                    dest = null;
                                    sent = value;
                                    recv = liquidityOut;
                                    price = liquidityOut / value;
                                    fee = 0.0;
                                    createdAt = Time.now();
                                };
                                user.txs.add(newTx);

                                let newLocked: U.Balance = switch (market.collateralType) {
                                    case (#seers) {
                                        {
                                            seers = user.balances.seers - liquidityOut;
                                            icp = user.balances.icp;
                                            cycles = user.balances.cycles;
                                            btc = user.balances.btc;
                                        }
                                    };
                                    case (#icp) {
                                        {
                                            seers = user.balances.seers;
                                            icp = user.balances.icp - liquidityOut;
                                            cycles = user.balances.cycles;
                                            btc = user.balances.btc;
                                        }
                                    };
                                    case (#cycles) {
                                        {
                                            seers = user.balances.seers;
                                            icp = user.balances.icp;
                                            cycles = user.balances.cycles - liquidityOut;
                                            btc = user.balances.btc;
                                        }
                                    };
                                    case (#btc) {
                                        {
                                            seers = user.balances.seers;
                                            icp = user.balances.icp;
                                            cycles = user.balances.cycles;
                                            btc = user.balances.btc - liquidityOut;
                                        }
                                    };
                                };
                                
                                user.locked := newLocked;

                                return #ok(liquidityOut);
                            };
                        };
                    };
                };
            };
        };
    };

    public shared(msg) func submitForecast(
        marketId: Nat32,
        forecast: Forecast.Forecast
    ): async Result.Result<(), Error> {
        
        assert(not updating);
        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#callerIsAnon);
        };

        let userOpt = userMap.get(caller);
        switch (userOpt) {
            case null {
                return #err(#profileNotCreated);
            };
            case (?user) {
                user.forecasts.add(forecast);
            };
        };

        let marketOpt = marketMap.get(marketId);
        switch (marketOpt) {
            case null {
                return #err(#marketMissing);
            };
            case (?market) {
                market.forecasts.add(forecast);
            };
        };

        return #ok();
    };

    public shared(msg) func buyOutcome(
            marketId: Nat32,
            value: Float,
            selected: Nat,
            save: Bool
        ): async Result.Result<Float, Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);
        
        if (caller == anon) {
            return #err(#callerIsAnon);
        };

        var user = switch (getUser(caller)) {
            case (null) {
                return #err(#profileNotCreated);
            };
            case (?user) {
                user;
            };
        };

        if (value < 0.1) {
            return #err(#lowerThanMinAmount);
        };

        let marketOpt = marketMap.get(marketId);

        switch (marketOpt) {
            case null {
                return #err(#marketMissing);
            };
            case (?market) {
                // Check enough balance.
                switch (market.collateralType) {
                    case (#icp) {
                        if (user.balances.icp - user.locked.icp < value) {
                            return #err(#notEnoughBalance);
                        };
                    };
                    case (#seers) {
                        if (user.balances.seers - user.locked.seers < value) {
                            return #err(#notEnoughBalance);
                        };
                    };
                    case (#cycles) {
                        if (user.balances.cycles - user.locked.cycles < value) {
                            return #err(#notEnoughBalance);
                        };
                    };
                    case (#btc) {
                        if (user.balances.btc - user.locked.btc < value) {
                            return #err(#notEnoughBalance);
                        };
                    };
                };

                if (market.state != #open) { 
                    return #err(#marketNotOpen);
                };

                if (market.startDate > Time.now()) { 
                    return #err(#marketNotOpen);
                };

                if (market.endDate < Time.now()) { 
                    market.state := #closed;
                    return #err(#marketNotOpen);
                };
                
                let optionsSize = market.reserves.size();
                var semiK: Float = 1.0;

                for (i in Iter.range(0, optionsSize - 1)) {
                    if (i != selected) {
                        semiK := semiK * (market.reserves[i] + value);
                    };
                };
                
                let newSelectedReserve: Float = market.k / semiK;
                let tokensOut = market.reserves[selected] - newSelectedReserve + value;
                
                if (not save) { // Dry run.
                    return #ok(tokensOut);
                };

                var newReserves: [var Float] = Array.init(optionsSize, 0.0);
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

                let weight: [var Float] = Array.init(optionsSize, 1.0); 
                let probabilities: [var Float] = Array.init(optionsSize, 0.0);
                var weightSum: Float  = 0.0;
                    
                for (i in Iter.range(0, optionsSize - 1)) {
                    for (j in Iter.range(0, optionsSize - 1)) {
                        if (i != j) {
                            weight[i] := weight[i] * market.reserves[j];
                        };
                    };
                    weightSum := weightSum + weight[i];
                };

                for (i in Iter.range(0, optionsSize - 1)) {
                    probabilities[i] := weight[i] / weightSum;
                };

                market.probabilities :=  Array.freeze(probabilities);
                let histPoint: M.HistPoint = {
                    probabilities = market.probabilities;
                    liquidity = market.liquidity;
                    createdAt = Time.now();
                };
                market.histPrices.add(histPoint);

                var markets = user.markets.toArray();
                let marketTokensOpt = Array.find<U.UserMarket>(markets,
                    func (ut: U.UserMarket): Bool {
                        ut.marketId == market.id
                    }
                );

                switch (marketTokensOpt) {
                    case null {
                        let balances: [var Float] = Array.init(optionsSize, 0.0);
                        balances[selected] := tokensOut;

                        let newUserMarket: U.UserMarket = {
                            author = (market.author == caller);
                            balances = Array.freeze(balances);
                            brierScores = [];
                            collateralType = market.collateralType;
                            createdAt = Time.now();
                            modifiedAt = Time.now();
                            redeemed = false;
                            marketId = market.id;
                            title = market.title;
                            labels = market.labels;
                            shares = 0;
                            spent = value;
                        };
                        user.markets.add(newUserMarket);
                    };
                    case (?marketTokens) {
                        markets := Array.mapFilter(markets, 
                            func (ut: U.UserMarket): ?U.UserMarket {
                                if (ut.marketId != market.id) {
                                    return ?ut;
                                } else {
                                    let newBalances = Array.mapEntries(ut.balances,
                                        func (b: Float, i: Nat): Float {
                                            if (i == selected) {
                                                return b + tokensOut;
                                            } else {
                                                return b;
                                            };
                                        }
                                    );

                                    let newUserMarket: U.UserMarket = {
                                        author = ut.author;
                                        balances = newBalances;
                                        brierScores = ut.brierScores;
                                        collateralType = ut.collateralType;
                                        createdAt = ut.createdAt;
                                        labels = market.labels;
                                        marketId = market.id;
                                        modifiedAt = Time.now();
                                        redeemed = false;
                                        shares = ut.shares;
                                        spent = ut.spent + value;
                                        title = market.title;
                                    };
                                    return ?newUserMarket;
                                };
                            }
                        );
                    };
                };
                user.markets := Utils.bufferFromArray(markets);
                let newLocked: U.Balance = switch (market.collateralType) {
                    case (#seers) {
                        {
                            seers = user.locked.seers + value;
                            icp = user.locked.icp;
                            cycles = user.locked.cycles;
                            btc = user.locked.btc;
                        }
                    };
                    case (#icp) {
                        {
                            seers = user.locked.seers;
                            icp = user.locked.icp + value;
                            cycles = user.locked.cycles;
                            btc = user.locked.btc;
                        }
                    };
                    case (#cycles) {
                        {
                            seers = user.locked.seers;
                            icp = user.locked.icp;
                            cycles = user.locked.cycles + value;
                            btc = user.locked.btc;
                        }
                    };
                    case (#btc) {
                        {
                            seers = user.locked.seers;
                            icp = user.locked.icp;
                            cycles = user.locked.cycles;
                            btc = user.locked.btc + value;
                        }
                    };
                };
                
                
                user.locked := newLocked;
                let newTx: Tx.UserTx = {
                    id = Nat32.fromNat(user.txs.size());
                    marketId = market.id;
                    src = null;
                    dest = ?selected;
                    sent = value;
                    recv = tokensOut;
                    price = value / tokensOut;
                    fee = 0.0;
                    createdAt = Time.now();
                };
                user.txs.add(newTx);

                return #ok(tokensOut);
            };
        };
    };

    // Get user data.
    public query func getUserStable(userId: Text): async ?U.UserStable {
        return Option.map(getUser(userId), func (u: U.User): U.UserStable {
            return u.freeze();
        });
    };


    // Get user with posts.
    public query func getUserWithPosts(handle: Text): async Result.Result<(U.UserStable, [Post.PostStable]), Error> {
        switch (userMap.get(handle)) {
            case null {
                return #err(#profileNotCreated);
            };
            case (?user) {
                var posts = Buffer.Buffer<Post.PostStable>(user.posts.size());

                for (postId in user.posts.vals()) {
                    switch (postMap.get(postId)) {
                        case null {
                            // Shouldn't happen, but it doesn't matter.
                        };
                        case (?post) {
                            if (not post.deleted) {
                                var stablePost = post.freeze();
                                posts.add(stablePost);
                            };
                        };
                    };
                };

                return #ok((user.freeze(), posts.toArray()));
            };
        };
    };

    // Get user with posts from principal.
    public query func getUserFromPrincipal(principal: Text): async Result.Result<(U.UserStable, [Post.PostStable]), Error> {
        switch (handlesMap.get(principal)) {
            case null {
                return #err(#profileNotCreated);
            };
            case (?handle) {
                switch (userMap.get(handle)) {
                    case null {
                        return #err(#profileNotCreated);
                    };
                    case (?user) {
                        var posts = Buffer.Buffer<Post.PostStable>(user.posts.size());

                        for (postId in user.posts.vals()) {
                            switch (postMap.get(postId)) {
                                case null {
                                    // Shouldn't happen, but it doesn't matter.
                                };
                                case (?post) {
                                    if (not post.deleted) {
                                        var stablePost = post.freeze();
                                        posts.add(stablePost);
                                    };
                                };
                            };
                        };

                        return #ok((user.freeze(), posts.toArray()));
                    };
                };
            };
        };
    };


    // Get feed.
    public query func getFeed(): async [Post.PostStable] {
        var posts = Buffer.Buffer<Post.PostStable>(feed.size());
        for (p in feed.vals()) {
            var stablePost = p.freeze();
            posts.add(stablePost);
        };

        return posts.toArray();
    };

    // Create new user.
    public shared(msg) func createUser(initData: U.UserInitData): async Result.Result<U.UserStable, Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);

        if (caller == anon or caller != initData.id) {
            return #err(#callerIsAnon);
        };
        
        switch (_createUser(initData)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(user)) {
                return #ok(user.freeze())
            };
        };
    };

    // Edit user.
    public shared(msg) func editUser(initData: U.UserInitData): async Result.Result<U.UserStable, Error> {
        assert(not updating);

        let caller = Principal.toText(msg.caller);

        if (caller == anon or caller != initData.id) {
            return #err(#callerIsAnon);
        };
        
        switch (_editUser(initData)) {
            case (#err(e)) {
                return #err(e);
            };
            case (#ok(user)) {
                return #ok(user.freeze())
            };
        };
    };
    
    // Add a comment to a market.
    public shared(msg) func addCommentToMarket(marketId: Nat32, content: Text): async Result.Result<Comment.CommentStable, Error> {
        assert(not updating);
        
        let userId = Principal.toText(msg.caller);
        
        if (userId == anon) {
            return #err(#callerIsAnon);
        };

        if (content == "") {
            return #err(#commentIsEmpty);
        };

        let userOpt = getUser(userId);

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
                        let userData: Utils.UserData = {
                            principal = user.id;
                            handle = user.handle;
                            name = user.name;
                            picture = user.picture;
                        };
                        let initData: Comment.CommentInitData = {
                            id = Nat32.fromNat(market.comments.size());
                            author = userData;
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

    private func getUser(userId: Text): ?U.User {
        switch (handlesMap.get(userId)) {
            case null {
                return null;
            };
            case (?handle) {
                return userMap.get(handle);
            };
        };
    };

    private func _editUser(initData: U.UserInitData): Result.Result<U.User, Error> {
        switch (handlesMap.get(initData.id)) {
            case null {
                // No data for this principal.
                return #err(#userDoesNotExist);
            };
            case (?handle) {
                switch (userMap.get(handle)) {
                    case null {
                        // Inconsistency.
                        return #err(#userDoesNotExist);
                    };
                    case (?oldUser) {

                        // Check new handle is ok.
                        switch (userMap.get(initData.handle)) {
                            case null {
                                // Great, the handle does not exist, we can continue.
                            };
                            case (_) {
                                if (initData.handle != handle) {
                                    // Bad, the handle is taken and is not the same as before.
                                    return #err(#userAlreadyExist);
                                };
                            };
                        };

                        oldUser.handle := initData.handle;
                        oldUser.name := initData.name;
                        oldUser.picture := initData.picture;
                        oldUser.cover := initData.cover;
                
                        let userData: Utils.UserData = {
                            principal = oldUser.id;
                            name = oldUser.name;
                            handle = oldUser.handle;
                            picture = oldUser.picture;
                        };

                        handlesMap.put(oldUser.id, oldUser.handle);
                        userMap.put(oldUser.handle, oldUser);
                        userDataMap.put(oldUser.id, userData);

                        return #ok(oldUser);
                    };
                };
            };
        };
    };

    private func _createUser(initData: U.UserInitData): Result.Result<U.User, Error> {
        switch (handlesMap.get(initData.id)) {
            case (null) {
                switch (userMap.get(initData.handle)) {
                    case null {
                        var user: U.User = U.User(initData);
                        let userNum: Nat32 = Nat32.fromNat(userMap.size() + 128); // Reserve some accounts.
                        let account: Text = Account.toText(makeAccountIdentifier(Account.makeSubAccount(userNum)));

                        // Set deposit address.
                        user.depositAddrs := {
                            seers = "";
                            icp = account;
                            cycles = "";
                            btc = "";
                        };

                        let userData: Utils.UserData = {
                            principal = user.id;
                            name = user.name;
                            handle = user.handle;
                            picture = user.picture;
                        };

                        userMap.put(user.handle, user);
                        userDataMap.put(user.id, userData);
                        handlesMap.put(user.id, user.handle);
                        
                        return #ok(user);
                    };
                    case (_) {
                        return #err(#handleAlreadyTaken);
                    };
                };
            };
            case (?userHandle) {
                return #err(#userAlreadyExist);
            };
        };
    };
};
