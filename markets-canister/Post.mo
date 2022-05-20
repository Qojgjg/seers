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
        public var replies: Buffer.Buffer<Post> = Buffer.Buffer<Post>(0);
        public var likes: [Like.Like] = [];
        public var createdAt: Time.Time = Time.now();

        public func freeze(): PostStable {
        
            var stableReplies = Buffer.Buffer<[PostNode]>(replies.size());
            var children = Buffer.Buffer<Nat32>(replies.size());

            for (reply in replies.vals()) {
                stableReplies.add(reply.freeze());
                children.add(reply.id);
            };
            
            let postData: PostData = {
                id = id;
                author = author;
                content = content;
                likes = likes;
                createdAt = createdAt;
            };

            let newPost: [PostNode] = [(id, postData, children.toArray())];
            stableReplies.add(newPost);

            let postStable: PostStable = Array.flatten(stableReplies.toArray());

            return postStable;
        };
    };

    public type PostData = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        likes: [Like.Like];
        createdAt: Time.Time;
    };

    public type PostNode = (Nat32, PostData, [Nat32]);
    public type PostStable = [PostNode];

    // public func unFreeze(ps: PostStable): Post {
    //     let initData: PostInitData = {
    //         id = ps.id;
    //         author = ps.author;
    //         content = ps.content;
    //     };
    //     var p: Post = Post(initData);
    //     p.comments := Utils.bufferFromArray(Array.map(ps.comments, func (ps: PostStable): Post {
    //         unFreeze(ps)
    //     }));
    //     p.likes := ps.likes;
    //     p.createdAt := ps.createdAt;

    //     return p;
    // };
}