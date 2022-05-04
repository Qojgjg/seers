import Comment "Comment";
import Post "Post";
import Bet "Bet";
import Market "Market";

module {

    public type FeedItem = {
        #comment: Comment.Comment;
        #post: Post.Post;
        #bet: Bet.Bet;
        #market: Market.MarketStable;
    };

}