import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

import Like "Like";
import Utils "Utils";


module {
    public type PostError = {
        #postDoesNotExist;
        #userDoesNotExist;
    };

    public type PostInitData = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        parent: Nat32;
    };

    public class Post (initData: PostInitData) = this {
        public var id: Nat32 = initData.id;
        public var author: Utils.UserData = initData.author;
        public var content: Text = initData.content;
        public var parent: Nat32 = initData.parent;
        public var replies: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var likes: [Like.Like] = [];
        public var createdAt: Time.Time = Time.now();

        public func freeze(): PostStable {
            let ps: PostStable = {
                id = id;
                author = author;
                content = content;
                parent = parent;
                replies = replies.toArray();
                likes = likes;
                createdAt = createdAt;
            };
            
            return ps;
        };
    };

    public type PostStable = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        parent: Nat32;
        replies: [Nat32];
        likes: [Like.Like];
        createdAt: Time.Time;
    };

    public func unFreeze(ps: PostStable): Post {
        let initData: PostInitData = {
            id = ps.id;
            author = ps.author;
            content = ps.content;
            parent = ps.parent;
        };
        var p: Post = Post(initData);
        p.replies := Utils.bufferFromArray(ps.replies);
        p.likes := ps.likes;
        p.createdAt := ps.createdAt;

        return p;
    };
}