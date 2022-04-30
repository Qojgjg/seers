import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Like "Like";
import Utils "Utils";

module {
    public type Comment = {
        id: Nat32;
        user: Utils.UserData;
        content: Text;
        likes: [Like.Like];
        createdAt: Time.Time;
    };
}