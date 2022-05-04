import Comment "Comment";
import Post "Post";

module {

    public type FeedItem = {
        #comment: Comment.Comment;
        #post: Post.Post;
        #bet: Bet;
        #market: MarketStable;
    };

}