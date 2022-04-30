
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";

import Utils "Utils";

module {
   
    public type BrierScore = {
        score: Float;
        createdAt: Time.Time;
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

    public class User (initData: UserInitData) = this {
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
            let us: UserStable = {
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
                followers = followees.toArray();
                followees = followees.toArray();
                createdAt = createdAt;
                lastSeenAt = lastSeenAt;
                modifiedAt = modifiedAt;
            };
            return us;
        }
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
        user: UserData;
        content: Text;
        likes: [Like];
        createdAt: Time.Time;
    };

    public type Post = {
        id: Nat32;
        author: UserData;
        content: Text;
        comments: [Comment];
        likes: [Like];
        createdAt: Time.Time;
    };

    public type HistPoint = {
        probabilities: [Float];
        liquidity: Float;
        createdAt: Time.Time;
    };

    public class Market (initData: MarketInitData) = this {
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
            let ms: MarketStable = {
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
                category = category;
                collateralType = collateralType;
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
            return ms;
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

    public func unFreezeUser(u: UserStable): User {
        let initData: UserInitData = {
            id = u.id;
            handle = u.handle;
            picture = u.picture;
            twitter = u.twitter;
            discord = u.discord;
            bio = u.bio;
        };
        var user: User = User(initData);
        user.feed := Utils.bufferFromArray(u.feed);
        user.balances := u.balances;
        user.expBalances := u.expBalances;
        user.depositAddrs := u.depositAddrs;
        user.markets := Utils.bufferFromArray(u.markets);
        user.txs := Utils.bufferFromArray(u.txs);
        user.comments := Utils.bufferFromArray(u.comments);
        user.posts := Utils.bufferFromArray(u.posts);
        user.followers := Utils.bufferFromArray(u.followers);
        user.followees := Utils.bufferFromArray(u.followees);
        user.createdAt := u.createdAt;
        user.lastSeenAt := u.lastSeenAt;
        user.modifiedAt := u.modifiedAt;

        return user;
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
        category: MarketCategory;
        collateralType: CollateralType;
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

    public func unFreezeMarket(m: MarketStable): Market {
        let initData: MarketInitData = {
            nextId = m.id;
            title = m.title;
            description = m.description;
            startDate = m.startDate;
            endDate = m.endDate;
            author = m.author;
            labels = m.labels;
            images = m.images;
            probabilities = m.probabilities;
            liquidity = m.liquidity;
            imageUrl = m.imageUrl;
            category = m.category;
            collateralType = m.collateralType;
        };
        var market: Market = Market(initData);
        market.reserves := m.reserves;
        market.k := m.k;
        market.providers := Utils.bufferFromArray(m.providers);
        market.bettors := Utils.bufferFromArray(m.bettors);
        market.totalShares := m.totalShares;
        market.state := m.state;
        market.volume := m.volume;
        market.comments := Utils.bufferFromArray(m.comments);
        market.histPrices := Utils.bufferFromArray(m.histPrices);
        market.createdAt := m.createdAt;
        market.modifiedAt := m.modifiedAt;

        return market;
    };
}