module {

    public type Post = {
        id: Nat32;
        author: UserData;
        content: Text;
        comments: [Comment];
        likes: [Like];
        createdAt: Time.Time;
    };

}