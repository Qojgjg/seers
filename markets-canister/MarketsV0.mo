
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

    class Market (initData: MarketInitData) = this {
        public let id: Nat32 = initData.nextId;    
        public var title: Text = initData.title;
        public var description: Text = initData.description;
        public var startDate: Time.Time = initData.startDate;
        public var endDate: Time.Time = initData.endDate;
        public var author: UserData = initData.author;
        public var labels: [Text] = initData.labels;
        public var images: [Text] = initData.images;
        public var category: MarketCategory = initData.category;
        public var collateralType: CollateralType = initData.collateralType;
        public var probabilities: [Float] = initData.probabilities;
        public var liquidity: Float = initData.liquidity;
        public var reserves: [Float] = do {
            let size = initData.labels.size();
            var reserves: [Float] = [];
            for (i in Iter.range(0, size - 1)) {
                reserves := Array.append(reserves, [initData.liquidity]);
            };
            reserves
        };
        public var k: Float = do {
            let size = initData.labels.size();
            var k: Float = 1.0;
            for (i in Iter.range(0, size - 1)) {
                k := k * reserves[i];
            };
            k
        };
        public var providers: Buffer.Buffer<Text> = do {
            var providers = Buffer.Buffer<Text>(1);
            providers.add(initData.author.principal);
            providers
        };
        public var bettors: Buffer.Buffer<Text> = Buffer.Buffer<Text>(10);
        public var totalShares: Float = Float.sqrt(k);
        public var imageUrl: Text = initData.imageUrl;
        public var state: MarketState = #pending;
        public var volume: Float = 0.0;
        public var comments: Buffer.Buffer<Comment> = Buffer.Buffer<Comment>(10);
        public var histPrices: Buffer.Buffer<HistPoint> = Buffer.Buffer<HistPoint>(10);
        public var createdAt: Time.Time = Time.now();
        public var modifiedAt: Time.Time = Time.now();

        public func freeze(): MarketStable {
            return MarketStable(this);
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

    class MarketStable (market: Market) = {
        let id: Nat32 = market.id;    
        let title: Text = market.title;
        let description: Text = market.description;
        let startDate: Time.Time = market.startDate;
        let endDate: Time.Time = market.endDate;
        let author: UserData = market.author;
        let labels: [Text] = market.labels;
        let images: [Text] = market.images;
        let probabilities: [Float] = market.probabilities;
        let liquidity: Float = market.liquidity;
        let reserves: [Float] = market.reserves;
        let category: MarketCategory = market.category;
        let collateralType: CollateralType = market.collateralType;
        let k: Float = market.k;
        let providers: [Text] = market.providers.toArray();
        let bettors: [Text] = market.bettors.toArray();
        let totalShares: Float = market.totalShares;
        let imageUrl: Text = market.imageUrl;
        let state: MarketState = market.state;
        let volume: Float = market.volume;
        let comments: [Comment] = market.comments.toArray();
        let histPrices: [HistPoint] = market.histPrices.toArray();
        let createdAt: Time.Time = market.createdAt;
        let modifiedAt: Time.Time = market.modifiedAt;

        public func unFreeze(): Market {
            let initData: MarketInitData = {
                nextId = id;
                title = title;
                description = description;
                startDate = startDate;
                endDate = endDate;
                author = author;
                labels = labels;
                images = images;
                probabilities = probabilities;
                liquidity = liquidity;
                imageUrl = imageUrl;
                category = category;
                collateralType = collateralType;
            };
            var market: Market = Market(initData);
            market.reserves := reserves;
            market.k := k;
            market.providers := Utils.bufferFromArray(providers);
            market.bettors := Utils.bufferFromArray(bettors);
            market.totalShares := totalShares;
            market.state := state;
            market.volume := volume;
            market.comments := Utils.bufferFromArray(comments);
            market.histPrices := Utils.bufferFromArray(histPrices);
            market.createdAt := createdAt;
            market.modifiedAt := modifiedAt;

            return market;
        }
    }
}