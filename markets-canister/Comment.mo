module {
     public type Comment = {
        id: Nat32;
        user: UserData;
        content: Text;
        likes: [Like];
        createdAt: Time.Time;
    };
}