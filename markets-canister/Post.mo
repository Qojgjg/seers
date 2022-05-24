import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

import Like "Like";
import Utils "Utils";


module {
    public type PostError = {
        #notLoggedIn;
        #postDoesNotExist;
        #userDoesNotExist;
        #alreadyLiked;
    };

    public type PostType = {
        #post;
        #reply: Nat32;
        #retweet: Nat32;
    };

    public type PostInitData = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        postType: PostType;
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
        public var replies: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var likes: Buffer.Buffer<Like.Like> = Buffer.Buffer<Like.Like>(0);
        public var createdAt: Time.Time = Time.now();
        public var postType: PostType = initData.postType;

        public func freeze(): PostStable {
            let ps: PostStable = {
                id = id;
                author = author;
                content = content;
                replies = replies.toArray();
                likes = likes.toArray();
                createdAt = createdAt;
                postType = postType;
            };
            
            return ps;
        };
    };

    public type PostStable = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        replies: [Nat32];
        likes: [Like.Like];
        createdAt: Time.Time;
        postType: PostType;
    };

    public func unFreeze(ps: PostStable): Post {
        let initData: PostInitData = {
            id = ps.id;
            author = ps.author;
            content = ps.content;
            postType = ps.postType;
        };

        var p: Post = Post(initData);
        
        p.replies := Utils.bufferFromArray(ps.replies);
        p.likes := Utils.bufferFromArray(ps.likes);
        p.createdAt := ps.createdAt;

        return p;
    };
}