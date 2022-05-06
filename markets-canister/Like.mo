
import Time "mo:base/Time";

module {
    public type Like = {
        stars: Nat32;
        author: Text;
        createdAt: Time.Time;
    };
}