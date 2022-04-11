
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

module {
    public type MarketError = {
        #callerIsAnon;
        #userNotCreated;
        #notEnoughLiquidity: Float;
        #titleMissing;
        #descriptionMissing;
        #optionsMissing;
        #imageMissing;
        #startDateOld;
        #endDateOld;
        #endDateOlderThanStartDate;

        #notEnoughBalance;
        #marketMissing;
        #marketNotOpen;
        #newtonFailed;

        #commentIsEmpty;

        #userAlreadyExist;
    };

    public type MarketState = {
        #pending: ();
        #approved: ();
        #open: ();
        #closed: ();
        #invalid: ();
        #resolved: Nat;
    };

    public type BrierScore = {
        score: Float;
        createdAt: Time.Time;
    };

    public type UserMarket = {
        marketId: Nat32;
        title: Text;
        labels: [Text];
        balances: [Float];
        brierScores: [BrierScore];
        shares: Float;
        spent: Float;
        redeemed: Bool;
        createdAt: Time.Time;
        modifiedAt: Time.Time;
    };

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

    public type Follower = {
        principal: Text;
        handle: Text;
        picture: Text;
        createdAt: Time.Time;
    };

    public type Followee = {
        principal: Text;
        handle: Text;
        picture: Text;
        createdAt: Time.Time;
    };

    public type FeedItem = {
        #comment: Comment;
        #post: Post;
    };

    public type User = {
        var id: Text;
        var handle: Text;
        var picture: Text;
        var twitter: Text;
        var discord: Text;
        var bio: Text;
        var feed: Buffer.Buffer<FeedItem>;
        var seerBalance: Float;
        var expSeerBalance: Float;
        var icpBalance: Float;
        var expIcpBalance: Float;
        var cyclesBalance: Float;
        var expCyclesBalance: Float;
        var cyclesDepositAddr: Text;
        var icpDepositAddr: Text;        
        var markets: Buffer.Buffer<UserMarket>;
        var txs: Buffer.Buffer<UserTx>;
        var comments: Buffer.Buffer<Comment>;
        var posts: Buffer.Buffer<Post>;
        var followers: Buffer.Buffer<Follower>;
        var followees: Buffer.Buffer<Followee>;
        var createdAt: Time.Time;
        var lastSeenAt: Time.Time;
        var modifiedAt: Time.Time;
    };

    public type AuthorData = {
        principal: Text;
        handle: Text;
        picture: Text;
    };

    public type MarketCategory = {
        #crypto;
        #science;
        #politics;
        #sports;
        #entertainment;
        #business;
        #financial;
        #seers;
        #dfinity;
    };

    public type CollateralType = {
        #seers;
        #icp;
        #cycles;
    };

    public type MarketInputData = {
        title: Text;
        description: Text;
        labels: [Text];
        images: [Text];
        probabilities: [Float];
        category: MarketCategory;
        collateralType: CollateralType;
        liquidity: Float;
        startDate: Time.Time;
        endDate: Time.Time;
        imageUrl: Text;
    };

    public type Like = {
        stars: Nat32;
        authorPrincipal: Text;
        authorHandle: Text;
        authorPicture: Text;
        createdAt: Time.Time;
    };

    public type Comment = {
        id: Nat32;
        marketId: Nat32;
        txId: ?Nat32;
        authorData: AuthorData;
        content: Text;
        replies: Buffer.Buffer<Comment>;
        likes: Buffer.Buffer<Like>;
        createdAt: Time.Time;
    };

    public type Post = {
        id: Nat32;
        marketId: ?Nat32;
        authorData: AuthorData;
        content: Text;
        likes: Buffer.Buffer<Like>;
        createdAt: Time.Time;
    };

    public type HistPoint = {
        probabilities: [Float];
        liquidity: Float;
        createdAt: Time.Time;
    };

    public type Market = {
        id: Nat32;    
        title: Text;
        description: Text;
        startDate: Time.Time;
        endDate: Time.Time;
        authorData: AuthorData;
        labels: [Text];
        images: [Text];
        var probabilities: [Float];
        var liquidity: Float;
        var reserves: [Float];
        var k: Float;
        var providers: Buffer.Buffer<Text>;
        var bettors: Buffer.Buffer<Text>;
        var totalShares: Float;
        var imageUrl: Float;
        var state: MarketState;
        var volume: Float;
        var comments: Buffer.Buffer<Comment>;
        var histPrices: Buffer.Buffer<HistPoint>;
        var createdAt: Time.Time;
        var modifiedAt: Time.Time;
    };
}