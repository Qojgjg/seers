import Time "mo:base/Time";

import Comment "Comment";
import Like "Like";
import Utils "Utils";

module {
    public type Post = {
        id: Nat32;
        author: Text;
        content: Text;
        comments: [Comment.CommentStable];
        likes: [Like.Like];
        createdAt: Time.Time;
    };
}