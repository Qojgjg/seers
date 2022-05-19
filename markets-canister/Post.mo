import Time "mo:base/Time";

import Like "Like";
import Utils "Utils";

module {
    public type Post = {
        id: Nat32;
        author: Utils.UserData;
        content: Text;
        comments: [Post];
        likes: [Like.Like];
        createdAt: Time.Time;
    };
}