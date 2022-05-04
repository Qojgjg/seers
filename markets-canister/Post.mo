import Time "mo:base/Time";

import Comment "Comment";
import Like "Like";
import Utils "Utils";

module {
    public type Post = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        comments: [Comment.Comment];
        likes: [Like.Like];
        createdAt: Time.Time;
    };
}