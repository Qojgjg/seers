import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Option "mo:base/Option";

import Like "Like";
import Utils "Utils";
import Market "Market";


module {
    public type PostError = {
        #notLoggedIn;
        #postDoesNotExist;
        #userDoesNotExist;
        #alreadyLiked;
        #marketNotFound;
        #imageNotFound;
        #parentDoesNotExist;
        #alreadyRetweeted;
    };

    public type ParentData = {
        id: Nat32;
        author: Utils.UserData;
    };

    public type PostInitData = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        parent: ?ParentData;
        retweet: ?Retweet;
        market: ?Market.MarketInitData;
        image: ?Text;
    };

    public type ThreadStable = {
        ancestors: [PostStable];
        main: PostStable;
        replies: [PostStable];
    };

    public class Post (initData: PostInitData) = this {
        public var id: Nat32 = initData.id;
        public var author: Utils.UserData = initData.author;
        public var content: Text = initData.content;
        public var parent: ?ParentData = initData.parent;
        public var replies: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var retweets: Buffer.Buffer<Retweeters> = Buffer.Buffer<Retweeters>(0);
        public var retweet: ?Retweet = initData.retweet;
        public var market: ?Market.Market = null;
        public var image: ?Text = initData.image;
        public var likes: Buffer.Buffer<Like.Like> = Buffer.Buffer<Like.Like>(0);
        public var createdAt: Time.Time = Time.now();
        
        public func freeze(): PostStable {
            let ps: PostStable = {
                id = id;
                author = author;
                content = content;
                parent = parent;
                replies = replies.toArray();
                retweets = retweets.toArray();
                retweet = retweet;
                market = Option.map(market, func (m: Market.Market): Market.MarketStable {
                    m.freeze()
                });
                image = image;
                likes = likes.toArray();
                createdAt = createdAt;
            };
            
            return ps;
        };
    };

    public type Retweeters = {
        id: Nat32;
        author: Utils.UserData;
    };

    public type Retweet = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        parent: ?ParentData;
        createdAt: Time.Time;
    };

    public type PostStable = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        parent: ?ParentData;
        replies: [Nat32];
        retweets: [Retweeters];
        retweet: ?Retweet;
        market: ?Market.MarketStable;
        image: ?Text;
        likes: [Like.Like];
        createdAt: Time.Time;
    };

    public func unFreeze(ps: PostStable): Post {
        let initData: PostInitData = {
            id = ps.id;
            author = ps.author;
            content = ps.content;
            parent = ps.parent;
            retweet = ps.retweet;
            image = ps.image;
            market = null;
        };

        var p: Post = Post(initData);

        p.market := Option.map(ps.market, func (m: Market.MarketStable): Market.Market { Market.unFreeze(m) });
        p.replies := Utils.bufferFromArray(ps.replies);
        p.retweets := Utils.bufferFromArray(ps.retweets);
        p.likes := Utils.bufferFromArray(ps.likes);
        p.createdAt := ps.createdAt;

        return p;
    };
}