import { Comment } "Comment"
import { UserTx } "Tx"

module {
    public type Bet = {
        tx: UserTx;
        comment: Comment;
    };
}