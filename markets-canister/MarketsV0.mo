
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";

import Utils "Utils";

module {
    public type MarketError = {
        #callerIsAnon;
        #userNotCreated;
        #notEnoughLiquidity: Float;
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

        #commentIsEmpty;

        #userAlreadyExist;
    };

    public type MarketState = {
        #pending: ();
        #approved: ();
        #open: ();
        #closed: ();
        #invalid: ();
        #resolved: Nat;
    };

    public type BrierScore = {
        score: Float;
        createdAt: Time.Time;
    };

    public type UserMarket = {
        marketId: Nat32;
        title: Text;
        labels: [Text];
        balances: [Float];
        brierScores: [BrierScore];
        shares: Float;
        spent: Float;
        redeemed: Bool;
        createdAt: Time.Time;
        modifiedAt: Time.Time;
    };

    public type UserTx = {
        id: Nat32;
        marketId: Nat32;
        src: ?Nat;
        dest: ?Nat;
        sent: Float;
        recv: Float;
        fee: Float;
        price: Float;
        createdAt: Time.Time;
    };

    public type Follower = {
        user: UserData;
        createdAt: Time.Time;
    };

    public type Followee = {
        user: UserData;
        createdAt: Time.Time;
    };

    public type FeedItem = {
        #comment: Comment;
        #post: Post;
        #bet: Bet;
        #market: MarketStable;
    };

    public type Bet = {
        tx: UserTx;
        comment: Comment;
    };

    public type UserInitData = {
        id: Text;
        handle: Text;
        picture: Text;
        twitter: Text;
        discord: Text;
        bio: Text;
    };

    public type Balances = {
        seers: Float;
        icp: Float;
        cycles: Float;
        btc: Float;
    };

    public type ExpBalances = {
        expSeers: Float;
        expIcp: Float;
        expCycles: Float;
        expBtc: Float;
    };

    public type DepositAddrs = {
        icp: ?Text;
        cycles: ?Text;
        btc: ?Text;
    };

    class User (initData: UserInitData) = this {
        public var id: Text = initData.id;
        public var handle: Text = initData.handle;
        public var picture: Text = initData.picture;
        public var twitter: Text = initData.twitter;
        public var discord: Text = initData.discord;
        public var bio: Text = initData.bio;
        public var feed: Buffer.Buffer<FeedItem> = Buffer.Buffer<FeedItem>(5);
        public var balances: Balances = {
            seers = 500.0;
            icp = 0.0;
            cycles = 0.0;
            btc = 0.0;
        };
        public var expBalances: ExpBalances = {
            expSeers = 500.0;
            expIcp = 0.0;
            expCycles = 0.0;
            expBtc = 0.0;    
        };
        public var depositAddrs: DepositAddrs = {
            icp = null;
            cycles = null;
            btc = null;
        };
        public var markets: Buffer.Buffer<UserMarket> = Buffer.Buffer<UserMarket>(5);
        public var txs: Buffer.Buffer<UserTx> = Buffer.Buffer<UserTx>(5);
        public var comments: Buffer.Buffer<Comment> = Buffer.Buffer<Comment>(5);
        public var posts: Buffer.Buffer<Post> = Buffer.Buffer<Post>(5);
        public var followers: Buffer.Buffer<Follower> = Buffer.Buffer<Follower>(5);
        public var followees: Buffer.Buffer<Followee> = Buffer.Buffer<Followee>(5);
        public var createdAt: Time.Time = Time.now();
        public var lastSeenAt: Time.Time = Time.now();
        public var modifiedAt: Time.Time = Time.now();

        public func freeze(): UserStable {
            return UserStable(this);
        }
    };

    public type UserData = {
        principal: Text;
        handle: Text;
        picture: Text;
    };

    public type MarketCategory = {
        #crypto;
        #science;
        #politics;
        #sports;
        #entertainment;
        #business;
        #financial;
        #seers;
        #dfinity;
    };

    public type CollateralType = {
        #seers;
        #icp;
        #cycles;
    };

    public type MarketInitData = {
        nextId: Nat32;
        title: Text;
        description: Text;
        labels: [Text];
        images: [Text];
        probabilities: [Float];
        category: MarketCategory;
        collateralType: CollateralType;
        liquidity: Float;
        startDate: Time.Time;
        endDate: Time.Time;
        imageUrl: Text;
        author: UserData;
    };

    public type Like = {
        stars: Nat32;
        authorPrincipal: Text;
        authorHandle: Text;
        authorPicture: Text;
        createdAt: Time.Time;
    };

    public type Comment = {
        id: Nat32;
        marketId: Nat32;
        txId: ?Nat32;
        user: UserData;
        content: Text;
        replies: Buffer.Buffer<Comment>;
        likes: Buffer.Buffer<Like>;
        createdAt: Time.Time;
    };

    public type Post = {
        id: Nat32;
        marketId: ?Nat32;
        author: UserData;
        content: Text;
        likes: Buffer.Buffer<Like>;
        createdAt: Time.Time;
    };

    public type HistPoint = {
        probabilities: [Float];
        liquidity: Float;
        createdAt: Time.Time;
    };

    class Market (initData: MarketInitData) {
        let id: Nat32 = initData.nextId;    
        var title: Text = initData.title;
        var description: Text = initData.description;
        var startDate: Time.Time = initData.startDate;
        var endDate: Time.Time = initData.endDate;
        var author: UserData = initData.author;
        var labels: [Text] = initData.labels;
        var images: [Text] = initData.images;
        var probabilities: [Float] = initData.probabilities;
        var liquidity: Float = initData.liquidity;
        var reserves: [Float] = do {
            let size = initData.labels.size();
            var reserves: [Float] = [];
            for (i in Iter.range(0, size - 1)) {
                reserves := Array.append(reserves, [initData.liquidity]);
            };
            reserves
        };
        var k: Float = do {
            let size = initData.labels.size();
            var k: Float = 1.0;
            for (i in Iter.range(0, size - 1)) {
                k := k * reserves[i];
            };
            k
        };
        var providers: Buffer.Buffer<Text> = do {
            var providers = Buffer.Buffer<Text>(1);
            providers.add(initData.author.principal);
            providers
        };
        var bettors: Buffer.Buffer<Text> = Buffer.Buffer<Text>(10);
        var totalShares: Float = Float.sqrt(k);
        var imageUrl: Text = initData.imageUrl;
        var state: MarketState = #pending;
        var volume: Float = 0.0;
        var comments: Buffer.Buffer<Comment> = Buffer.Buffer<Comment>(10);
        var histPrices: Buffer.Buffer<HistPoint> = Buffer.Buffer<HistPoint>(10);
        var createdAt: Time.Time = Time.now();
        var modifiedAt: Time.Time = Time.now();

        public func freeze(): MarketStable {
            let stableMarket: MarketStable = {
                id = id;    
                title = title;
                description = description;
                startDate = startDate;
                endDate = endDate;
                author = author;
                labels = labels;
                images = images;
                probabilities = probabilities;
                liquidity = liquidity;
                reserves = reserves;
                k = k;
                providers = providers.toArray();
                bettors = bettors.toArray();
                totalShares = totalShares;
                imageUrl = imageUrl;
                state = state;
                volume = volume;
                comments = comments.toArray();
                histPrices = histPrices.toArray();
                createdAt = createdAt;
                modifiedAt = modifiedAt;
            };
            return stableMarket;
        }
    };

    class UserStable(user: User) {
        let id: Text = user.id;
        let handle: Text = user.handle;
        let picture: Text = user.picture;
        let twitter: Text = user.twitter;
        let discord: Text = user.discord;
        let bio: Text = user.bio;
        let feed: [FeedItem] = user.feed.toArray();
        let balances: Balances = user.balances;
        let expBalances: ExpBalances = user.expBalances;
        let depositAddrs: DepositAddrs = user.depositAddrs;  
        let markets: [UserMarket] = user.markets.toArray();
        let txs: [UserTx] = user.txs.toArray();
        let comments: [Comment] = user.comments.toArray();
        let posts: [Post] = user.posts.toArray();
        let followers: [Follower] = user.followers.toArray();
        let followees: [Followee] = user.followees.toArray();
        let createdAt: Time.Time = user.createdAt;
        let lastSeenAt: Time.Time = user.lastSeenAt;
        let modifiedAt: Time.Time = user.modifiedAt;

        public func unFreeze(): User {
            let initData: UserInitData = {
                id = id;
                handle = handle;
                picture = picture;
                twitter = twitter;
                discord = discord;
                bio = bio;
            };
            var user: User = User(initData);
            user.feed := Utils.bufferFromArray(feed);
            user.balances := balances;
            user.expBalances := expBalances;
            user.depositAddrs := depositAddrs;
            user.markets := Utils.bufferFromArray(markets);
            user.txs := Utils.bufferFromArray(txs);
            user.comments := Utils.bufferFromArray(comments);
            user.posts := Utils.bufferFromArray(posts);
            user.followers := Utils.bufferFromArray(followers);
            user.followees := Utils.bufferFromArray(followees);
            user.createdAt := createdAt;
            user.lastSeenAt := lastSeenAt;
            user.modifiedAt := modifiedAt;

            return user;
        }
    };

    public type MarketStable = {
        id: Nat32;    
        title: Text;
        description: Text;
        startDate: Time.Time;
        endDate: Time.Time;
        author: UserData;
        labels: [Text];
        images: [Text];
        probabilities: [Float];
        liquidity: Float;
        reserves: [Float];
        k: Float;
        providers: [Text];
        bettors: [Text];
        totalShares: Float;
        imageUrl: Text;
        state: MarketState;
        volume: Float;
        comments: [Comment];
        histPrices: [HistPoint];
        createdAt: Time.Time;
        modifiedAt: Time.Time;
    }
}