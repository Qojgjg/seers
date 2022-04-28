import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Time "mo:base/Time";

import { Like } "Like"
import { UserData } "Utils"

module {
    public type Comment = {
        id: Nat32;
        user: UserData;
        content: Text;
        likes: [Like];
        createdAt: Time.Time;
    };
}