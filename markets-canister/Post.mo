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

    public type PostInitData = {
        id: Nat32;
        author: Utils.UserData;
        treeAuthor: Text;
        treeId: Nat32;
        treeParent: Nat32;
        content: Text;
    };

    public type ThreadStable = {
        ancestors: [PostStable];
        main: PostStable;
        replies: [PostStable];
    };

    public class Post (initData: PostInitData) = this {
        public var id: Nat32 = initData.id;
        public var author: Utils.UserData = initData.author;
        
        public var treeAuthor: Text = initData.treeAuthor;
        public var treeId: Nat32 = initData.treeId;
        public var treeParent: Nat32 = initData.treeParent;
        
        public var content: Text = initData.content;
        public var replies: Buffer.Buffer<Nat32> = Buffer.Buffer<Nat32>(0);
        public var likes: Buffer.Buffer<Like.Like> = Buffer.Buffer<Like.Like>(0);
        public var createdAt: Time.Time = Time.now();

        public func freeze(): PostStable {
            let ps: PostStable = {
                id = id;
                author = author;

                treeAuthor = treeAuthor;
                treeId = treeId;
                treeParent = treeParent;
                
                content = content;
                replies = replies.toArray();
                likes = likes.toArray();
                createdAt = createdAt;
            };
            
            return ps;
        };
    };

    public type PostStable = {
        id: Nat32;
        author: Utils.UserData;
        
        treeAuthor: Text;
        treeId: Nat32;
        treeParent: Nat32;
        
        content: Text;
        replies: [Nat32];
        likes: [Like.Like];
        createdAt: Time.Time;
    };

    public func unFreeze(ps: PostStable): Post {
        let initData: PostInitData = {
            id = ps.id;
            author = ps.author;

            treeId = ps.treeId;
            treeParent = ps.treeParent;
            treeAuthor = ps.treeAuthor;

            content = ps.content;
        };
        var p: Post = Post(initData);
        p.replies := Utils.bufferFromArray(ps.replies);
        p.likes := Utils.bufferFromArray(ps.likes);
        p.createdAt := ps.createdAt;

        return p;
    };
}