
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Trie "mo:base/Trie";
import Text "mo:base/Text";

import Utils "Utils";
import BrierScore "BrierScore";
import Feed "Feed";
import Tx "Tx";

module {
    public func userKey(x: Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };

    public type UserError = {
        #callerIsAnon;
        #profileNotCreated;
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
        #minimalAmountIsOne;

        #commentIsEmpty;

        #userAlreadyExist;
    };
   
    public type BrierScore = {
        score: Float;
        createdAt: Time.Time;
    };

    public type Follower = {
        user: Utils.UserData;
        createdAt: Time.Time;
    };

    public type Followee = {
        user: Utils.UserData;
        createdAt: Time.Time;
    };

    public type Bet = {
        tx: Tx.UserTx;
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

    public type UserMarket = {
        marketId: Nat32;
        title: Text;
        labels: [Text];
        balances: [Float];
        brierScores: [BrierScore.BrierScore];
        shares: Float;
        spent: Float;
        redeemed: Bool;
        createdAt: Time.Time;
        modifiedAt: Time.Time;
    };

    public class User (initData: UserInitData) = this {
        public var id: Text = initData.id;
        public var handle: Text = initData.handle;
        public var picture: Text = initData.picture;
        public var twitter: Text = initData.twitter;
        public var discord: Text = initData.discord;
        public var bio: Text = initData.bio;
        public var feed: Buffer.Buffer<Feed.FeedItem> = Buffer.Buffer<Feed.FeedItem>(5);
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
        public var txs: Buffer.Buffer<Tx.UserTx> = Buffer.Buffer<Tx.UserTx>(5);
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
        user: Utils.UserData;
        content: Text;
        likes: [Like];
        createdAt: Time.Time;
    };

    public type Post = {
        id: Nat32;
        author: Utils.UserData;
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

    public type UserStable = {
        id: Text;
        handle: Text;
        picture: Text;
        twitter: Text;
        discord: Text;
        bio: Text;
        feed: [Feed.FeedItem];
        balances: Balances;
        expBalances: ExpBalances;
        depositAddrs: DepositAddrs;  
        markets: [UserMarket];
        txs: [Tx.UserTx];
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
}