import Float "mo:base/Float";
import Time "mo:base/Time";

module {
    public type BrierScore = {
        score: Float;
        createdAt: Time.Time;
    };
}