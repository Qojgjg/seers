import Time "mo:base/Time";

module {
    public type UserTx = {
        id: Nat32;
        marketId: Nat32;
        src: ?Nat;
        dest: ?Nat;
        sent: Float;
        recv: Float;
        fee: Float;
        price: Float;
        createdAt: Time.Time;
    };
}