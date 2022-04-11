
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";

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

    class User (initData: UserInitData) = {
        var id: Text = initData.id;
        var handle: Text = initData.handle;
        var picture: Text = initData.picture;
        var twitter: Text = initData.twitter;
        var discord: Text = initData.discord;
        var bio: Text = initData.bio;
        var feed: Buffer.Buffer<FeedItem> = Buffer.Buffer<FeedItem>(5);
        var balances: Balances = {
            seers = 500.0;
            icp = 0.0;
            cycles = 0.0;
            btc = 0.0;
        };
        var expBalances: ExpBalances = {
            expSeers = 500.0;
            expIcp = 0.0;
            expCycles = 0.0;
            expBtc = 0.0;    
        };
        var depositAddrs: DepositAddrs = {
            icp = null;
            cycles = null;
            btc = null;
        };
        var markets: Buffer.Buffer<UserMarket> = Buffer.Buffer<UserMarket>(5);
        var txs: Buffer.Buffer<UserTx> = Buffer.Buffer<UserTx>(5);
        var comments: Buffer.Buffer<Comment> = Buffer.Buffer<Comment>(5);
        var posts: Buffer.Buffer<Post> = Buffer.Buffer<Post>(5);
        var followers: Buffer.Buffer<Follower> = Buffer.Buffer<Follower>(5);
        var followees: Buffer.Buffer<Followee> = Buffer.Buffer<Followee>(5);
        var createdAt: Time.Time = Time.now();
        var lastSeenAt: Time.Time = Time.now();
        var modifiedAt: Time.Time = Time.now();

        public func freeze(): UserStable {
            let stableUser: UserStable = {  
                id = id;
                handle = handle;
                picture = picture;
                twitter = twitter;
                discord = discord;
                bio = bio;
                feed = feed.toArray();
                balances = balances;
                expBalances = expBalances;
                depositAddrs = depositAddrs;
                markets = markets.toArray();
                txs = txs.toArray();
                comments = comments.toArray();
                posts = posts.toArray();
                followers = followers.toArray();
                followees = followees.toArray();
                createdAt = createdAt;
                lastSeenAt = lastSeenAt;
                modifiedAt = modifiedAt;
            };
            return stableUser;
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

    public type UserStable = {
        id: Text;
        handle: Text;
        picture: Text;
        twitter: Text;
        discord: Text;
        bio: Text;
        feed: [FeedItem];
        balances: Balances;
        expBalances: ExpBalances;
        depositAddrs: DepositAddrs;  
        markets: [UserMarket];
        txs: [UserTx];
        comments: [Comment];
        posts: [Post];
        followers: [Follower];
        followees: [Followee];
        createdAt: Time.Time;
        lastSeenAt: Time.Time;
        modifiedAt: Time.Time;
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
    };
}