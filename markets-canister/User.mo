
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Map "mo:base/HashMap";
import Nat32 "mo:base/Nat32";

import Utils "Utils";
import Forecast "Forecast";
import Feed "Feed";
import Tx "Tx";
import Tokens "Tokens";
import Post "Post";
import Comment "Comment";

module {
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

        #userDoesNotExist;
        #userAlreadyExist;

        #handleAlreadyTaken;
    };
   
    public type Follower = {
        user: Text;
        createdAt: Time.Time;
    };

    public type Followee = {
        user: Text;
        createdAt: Time.Time;
    };

    public type UserInitData = {
        id: Text;
        handle: Text;
        name: Text;
        age: Nat;
        city: Text;
        picture: Text;
        cover: Text;
        twitter: Text;
        discord: Text;
        bio: Text;
        website: Text;
    };

    public type Balance = {
        seers: Float;
        icp: Float;
        cycles: Float;
        btc: Float;
    };

    public type DepositAddrs = {
        icp: Text;
        cycles: Text;
        btc: Text;
    };

    public type UserMarket = {
        marketId: Nat32;
        title: Text;
        labels: [Text];
        balances: [Float];
        collateralType: Tokens.CollateralType;
        brierScores: [Forecast.BrierScore];
        shares: Float;
        spent: Float;
        redeemed: Bool;
        author: Bool;
        createdAt: Time.Time;
        modifiedAt: Time.Time;
    };

    public class User (initData: UserInitData) = this {
        public var id: Text = initData.id;
        public var handle: Text = initData.handle;
        public var name: Text = initData.name;
        public var picture: Text = initData.picture;
        public var cover: Text = initData.cover;
        public var website: Text = initData.website;
        public var city: Text = initData.city;
        public var age: Nat = initData.age;
        public var twitter: Text = initData.twitter;
        public var discord: Text = initData.discord;
        public var bio: Text = initData.bio;
        public var feed: Buffer.Buffer<Feed.FeedItem> = Buffer.Buffer<Feed.FeedItem>(5);
        public var balances: Balance = {
            seers = 1_000_000.0;
            icp = 0.0;
            cycles = 0.0;
            btc = 0.0;
        };
        public var expBalances: Balance = {
            seers = 1_000_000.0;
            icp = 0.0;
            cycles = 0.0;
            btc = 0.0;
        };
        public var depositAddrs: DepositAddrs = {
            icp = "";
            cycles = "";
            btc = "";
        };
        public var markets: Buffer.Buffer<UserMarket> = Buffer.Buffer<UserMarket>(5);
        public var txs: Buffer.Buffer<Tx.UserTx> = Buffer.Buffer<Tx.UserTx>(5);
        public var forecasts: Buffer.Buffer<Forecast.Forecast> = Buffer.Buffer<Forecast.Forecast>(5);
        public var comments: Buffer.Buffer<Comment.Comment> = Buffer.Buffer<Comment.Comment>(5);

        public var posts: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var replies: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var likes: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var retweets: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        
        public var followers: Buffer.Buffer<Follower> = Buffer.Buffer<Follower>(5);
        public var followees: Buffer.Buffer<Followee> = Buffer.Buffer<Followee>(5);
        public var createdAt: Time.Time = Time.now();
        public var lastSeenAt: Time.Time = Time.now();
        public var modifiedAt: Time.Time = Time.now();

        public func freeze(): UserStable {
            let stableComments = Array.map(comments.toArray(), func (c: Comment.Comment): Comment.CommentStable {
                c.freeze()
            });
            let us: UserStable = {
                id = id;
                name = name;
                handle = handle;
                city = city;
                age = age;
                picture = picture;
                cover = cover;
                website = website;
                twitter = twitter;
                discord = discord;
                bio = bio;
                feed = feed.toArray();
                balances = balances;
                expBalances = expBalances;
                depositAddrs = depositAddrs;  
                markets = markets.toArray();
                txs = txs.toArray();
                comments = stableComments;
                
                posts = posts.toArray();
                replies = replies.toArray();
                retweets = retweets.toArray();
                likes = likes.toArray();
                
                followers = followees.toArray();
                followees = followees.toArray();
                createdAt = createdAt;
                lastSeenAt = lastSeenAt;
                modifiedAt = modifiedAt;
            };
            return us;
        }
    };

    public type UserStable = {
        id: Text;
        name: Text;
        handle: Text;
        age: Nat;
        city: Text;
        picture: Text;
        cover: Text;
        twitter: Text;
        discord: Text;
        bio: Text;
        website: Text;
        feed: [Feed.FeedItem];
        balances: Balance;
        expBalances: Balance;
        depositAddrs: DepositAddrs;  
        markets: [UserMarket];
        txs: [Tx.UserTx];
        comments: [Comment.CommentStable];
        posts: [Nat32];
        replies: [Nat32];
        retweets: [Nat32];
        likes: [Nat32];
        followers: [Follower];
        followees: [Followee];
        createdAt: Time.Time;
        lastSeenAt: Time.Time;
        modifiedAt: Time.Time;
    };

    public func unFreezeUser(u: UserStable): User {
        let initData: UserInitData = {
            id = u.id;
            name = u.name;
            handle = u.handle;
            age = u.age;
            city = u.city;
            picture = u.picture;
            cover = u.cover;
            twitter = u.twitter;
            discord = u.discord;
            bio = u.bio;
            website = u.website;
        };
        let comments = Array.map(u.comments, func (c: Comment.CommentStable): Comment.Comment {
            Comment.unFreeze(c)
        });
        var user: User = User(initData);
        
        user.posts := Utils.bufferFromArray(u.posts);
        user.replies := Utils.bufferFromArray(u.replies);
        user.retweets := Utils.bufferFromArray(u.retweets);
        user.likes := Utils.bufferFromArray(u.likes);
        
        user.feed := Utils.bufferFromArray(u.feed);
        user.balances := u.balances;
        user.expBalances := u.expBalances;
        user.depositAddrs := u.depositAddrs;
        user.markets := Utils.bufferFromArray(u.markets);
        user.txs := Utils.bufferFromArray(u.txs);
        user.comments := Utils.bufferFromArray(comments);
        user.followers := Utils.bufferFromArray(u.followers);
        user.followees := Utils.bufferFromArray(u.followees);
        user.createdAt := u.createdAt;
        user.lastSeenAt := u.lastSeenAt;
        user.modifiedAt := u.modifiedAt;

        return user;
    };
}