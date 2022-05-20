import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

import Like "Like";
import Utils "Utils";


module {
    public type PostInitData = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
    };

    public class Post (initData: PostInitData) = this {
        public var id: Nat32 = initData.id;
        public var author: Utils.UserData = initData.author;
        public var content: Text = initData.content;
        public var comments: Buffer.Buffer<Post> = Buffer.Buffer<Post>(0);
        public var likes: [Like.Like] = [];
        public var createdAt: Time.Time = Time.now();

        public func freeze(): PostStable {
            let stableComments = Array.map<Post, PostStable>(comments.toArray(), func (c: Post): PostStable {
                c.freeze()
            });
            
            let ps: PostStable = {
                id = id;
                author = author;
                content = content;
                comments = stableComments;
                likes = likes;
                createdAt = createdAt;
            };
        };
    };

    public type PostStable = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        comments: [PostStable];
        likes: [Like.Like];
        createdAt: Time.Time;
    };

    public func unFreeze(ps: PostStable): Post {
        let initData: PostInitData = {
            id = ps.id;
            author = ps.author;
            content = ps.content;
        };
        var p: Post = Post(initData);
        p.comments := Utils.bufferFromArray(Array.map(ps.comments, func (ps: PostStable): Post {
            unFreeze(ps)
        }));
        p.likes := ps.likes;
        p.createdAt := ps.createdAt;

        return p;
    };
}