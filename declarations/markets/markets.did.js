export const idlFactory = ({ IDL }) => {
  const ICP = IDL.Record({ 'e8s' : IDL.Nat64 });
  const Time = IDL.Int;
  const UserData = IDL.Record({
    'principal' : IDL.Text,
    'name' : IDL.Text,
    'picture' : IDL.Text,
    'handle' : IDL.Text,
  });
  const Like = IDL.Record({ 'createdAt' : Time, 'author' : UserData });
  const CommentStable = IDL.Record({
    'id' : IDL.Nat32,
    'content' : IDL.Text,
    'modifiedAt' : Time,
    'createdAt' : Time,
    'author' : UserData,
    'likes' : IDL.Vec(Like),
  });
  const MarketError = IDL.Variant({
    'callerIsAnon' : IDL.Null,
    'minimalAmountIsOne' : IDL.Null,
    'userAlreadyExist' : IDL.Null,
    'imageMissing' : IDL.Null,
    'profileNotCreated' : IDL.Null,
    'notEnoughBalance' : IDL.Null,
    'optionsMissing' : IDL.Null,
    'descriptionMissing' : IDL.Null,
    'titleMissing' : IDL.Null,
    'marketMissing' : IDL.Null,
    'startDateOld' : IDL.Null,
    'marketNotOpen' : IDL.Null,
    'commentIsEmpty' : IDL.Null,
    'endDateOld' : IDL.Null,
    'newtonFailed' : IDL.Null,
    'endDateOlderThanStartDate' : IDL.Null,
    'notEnoughLiquidity' : IDL.Float64,
  });
  const Result_8 = IDL.Variant({ 'ok' : CommentStable, 'err' : MarketError });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Float64, 'err' : MarketError });
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
  const CollateralType = IDL.Variant({
    'btc' : IDL.Null,
    'icp' : IDL.Null,
    'seers' : IDL.Null,
    'cycles' : IDL.Null,
  });
  const MarketCategory = IDL.Variant({
    'any' : IDL.Null,
    'entertainment' : IDL.Null,
    'self' : IDL.Null,
    'seers' : IDL.Null,
    'crypto' : IDL.Null,
    'business' : IDL.Null,
    'financial' : IDL.Null,
    'sports' : IDL.Null,
    'dfinity' : IDL.Null,
    'science' : IDL.Null,
    'politics' : IDL.Null,
  });
  const MarketInitData = IDL.Record({
    'id' : IDL.Nat32,
    'title' : IDL.Text,
    'probabilities' : IDL.Vec(IDL.Float64),
    'endDate' : Time,
    'labels' : IDL.Vec(IDL.Text),
    'liquidity' : IDL.Float64,
    'collateralType' : CollateralType,
    'description' : IDL.Text,
    'author' : IDL.Text,
    'imageUrl' : IDL.Text,
    'category' : MarketCategory,
    'startDate' : Time,
    'images' : IDL.Vec(IDL.Text),
  });
  const Forecast = IDL.Vec(IDL.Float64);
  const HistPoint = IDL.Record({
    'probabilities' : IDL.Vec(IDL.Float64),
    'createdAt' : Time,
    'liquidity' : IDL.Float64,
  });
  const MarketState = IDL.Variant({
    'any' : IDL.Null,
    'resolved' : IDL.Nat,
    'closed' : IDL.Null,
    'pending' : IDL.Null,
    'invalid' : IDL.Null,
    'open' : IDL.Null,
    'approved' : IDL.Null,
  });
  const MarketStable = IDL.Record({
    'k' : IDL.Float64,
    'id' : IDL.Nat32,
    'forecasts' : IDL.Vec(Forecast),
    'title' : IDL.Text,
    'histPrices' : IDL.Vec(HistPoint),
    'probabilities' : IDL.Vec(IDL.Float64),
    'endDate' : Time,
    'modifiedAt' : Time,
    'labels' : IDL.Vec(IDL.Text),
    'createdAt' : Time,
    'liquidity' : IDL.Float64,
    'reserves' : IDL.Vec(IDL.Float64),
    'collateralType' : CollateralType,
    'description' : IDL.Text,
    'volume' : IDL.Float64,
    'bettors' : IDL.Vec(IDL.Text),
    'author' : IDL.Text,
    'state' : MarketState,
    'imageUrl' : IDL.Text,
    'category' : MarketCategory,
    'providers' : IDL.Vec(IDL.Text),
    'comments' : IDL.Vec(CommentStable),
    'totalShares' : IDL.Float64,
    'startDate' : Time,
    'images' : IDL.Vec(IDL.Text),
  });
  const Result_7 = IDL.Variant({ 'ok' : MarketStable, 'err' : MarketError });
  const UserInitData = IDL.Record({
    'id' : IDL.Text,
    'age' : IDL.Nat,
    'bio' : IDL.Text,
    'twitter' : IDL.Text,
    'city' : IDL.Text,
    'name' : IDL.Text,
    'cover' : IDL.Text,
    'website' : IDL.Text,
    'picture' : IDL.Text,
    'discord' : IDL.Text,
    'handle' : IDL.Text,
  });
  const UserTx = IDL.Record({
    'id' : IDL.Nat32,
    'fee' : IDL.Float64,
    'src' : IDL.Opt(IDL.Nat),
    'dest' : IDL.Opt(IDL.Nat),
    'createdAt' : Time,
    'recv' : IDL.Float64,
    'sent' : IDL.Float64,
    'marketId' : IDL.Nat32,
    'price' : IDL.Float64,
  });
  const Balance = IDL.Record({
    'btc' : IDL.Float64,
    'icp' : IDL.Float64,
    'seers' : IDL.Float64,
    'cycles' : IDL.Float64,
  });
  const Bet = IDL.Record({ 'tx' : UserTx, 'comment' : CommentStable });
  const ParentData = IDL.Record({ 'id' : IDL.Nat32, 'author' : UserData });
  const Retweet = IDL.Record({
    'id' : IDL.Nat32,
    'content' : IDL.Text,
    'createdAt' : Time,
    'author' : UserData,
    'parent' : IDL.Opt(ParentData),
  });
  const PostStable = IDL.Record({
    'id' : IDL.Nat32,
    'retweet' : IDL.Opt(Retweet),
    'isRetweet' : IDL.Opt(UserData),
    'content' : IDL.Text,
    'createdAt' : Time,
    'author' : UserData,
    'likes' : IDL.Vec(Like),
    'replies' : IDL.Vec(IDL.Nat32),
    'market' : IDL.Opt(MarketStable),
    'image' : IDL.Opt(IDL.Text),
    'parent' : IDL.Opt(ParentData),
    'retweeters' : IDL.Vec(UserData),
  });
  const FeedItem = IDL.Variant({
    'bet' : Bet,
    'post' : PostStable,
    'comment' : CommentStable,
    'market' : MarketStable,
  });
  const BrierScore = IDL.Record({ 'createdAt' : Time, 'score' : IDL.Float64 });
  const UserMarket = IDL.Record({
    'brierScores' : IDL.Vec(BrierScore),
    'title' : IDL.Text,
    'shares' : IDL.Float64,
    'modifiedAt' : Time,
    'redeemed' : IDL.Bool,
    'labels' : IDL.Vec(IDL.Text),
    'createdAt' : Time,
    'collateralType' : CollateralType,
    'author' : IDL.Bool,
    'spent' : IDL.Float64,
    'marketId' : IDL.Nat32,
    'balances' : IDL.Vec(IDL.Float64),
  });
  const Followee = IDL.Record({ 'createdAt' : Time, 'user' : IDL.Text });
  const Follower = IDL.Record({ 'createdAt' : Time, 'user' : IDL.Text });
  const DepositAddrs = IDL.Record({
    'btc' : IDL.Text,
    'icp' : IDL.Text,
    'cycles' : IDL.Text,
  });
  const UserStable = IDL.Record({
    'id' : IDL.Text,
    'age' : IDL.Nat,
    'bio' : IDL.Text,
    'txs' : IDL.Vec(UserTx),
    'retweets' : IDL.Vec(IDL.Nat32),
    'expBalances' : Balance,
    'twitter' : IDL.Text,
    'lastSeenAt' : Time,
    'modifiedAt' : Time,
    'city' : IDL.Text,
    'feed' : IDL.Vec(FeedItem),
    'name' : IDL.Text,
    'createdAt' : Time,
    'cover' : IDL.Text,
    'locked' : Balance,
    'markets' : IDL.Vec(UserMarket),
    'website' : IDL.Text,
    'likes' : IDL.Vec(IDL.Nat32),
    'picture' : IDL.Text,
    'replies' : IDL.Vec(IDL.Nat32),
    'discord' : IDL.Text,
    'handle' : IDL.Text,
    'comments' : IDL.Vec(CommentStable),
    'posts' : IDL.Vec(IDL.Nat32),
    'followees' : IDL.Vec(Followee),
    'followers' : IDL.Vec(Follower),
    'depositAddrs' : DepositAddrs,
    'balances' : Balance,
  });
  const UserError = IDL.Variant({
    'callerIsAnon' : IDL.Null,
    'minimalAmountIsOne' : IDL.Null,
    'userAlreadyExist' : IDL.Null,
    'imageMissing' : IDL.Null,
    'profileNotCreated' : IDL.Null,
    'notEnoughBalance' : IDL.Null,
    'optionsMissing' : IDL.Null,
    'descriptionMissing' : IDL.Null,
    'titleMissing' : IDL.Null,
    'handleAlreadyTaken' : IDL.Null,
    'marketMissing' : IDL.Null,
    'startDateOld' : IDL.Null,
    'marketNotOpen' : IDL.Null,
    'commentIsEmpty' : IDL.Null,
    'userDoesNotExist' : IDL.Null,
    'endDateOld' : IDL.Null,
    'cantGetBalance' : IDL.Null,
    'newtonFailed' : IDL.Null,
    'endDateOlderThanStartDate' : IDL.Null,
    'notEnoughLiquidity' : IDL.Float64,
  });
  const Result_3 = IDL.Variant({ 'ok' : UserStable, 'err' : UserError });
  const PostError = IDL.Variant({
    'notLoggedIn' : IDL.Null,
    'parentDoesNotExist' : IDL.Null,
    'postIsEmpty' : IDL.Null,
    'marketNotFound' : IDL.Null,
    'imageNotFound' : IDL.Null,
    'alreadyLiked' : IDL.Null,
    'postDoesNotExist' : IDL.Null,
    'alreadyRetweeted' : IDL.Null,
    'userDoesNotExist' : IDL.Null,
  });
  const Result_6 = IDL.Variant({ 'ok' : PostStable, 'err' : PostError });
  const ThreadStable = IDL.Record({
    'main' : PostStable,
    'ancestors' : IDL.Vec(PostStable),
    'replies' : IDL.Vec(PostStable),
  });
  const Result_5 = IDL.Variant({ 'ok' : ThreadStable, 'err' : PostError });
  const Result_4 = IDL.Variant({
    'ok' : IDL.Tuple(UserStable, IDL.Vec(PostStable)),
    'err' : UserError,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : MarketError });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : PostError });
  const PostInitData = IDL.Record({
    'id' : IDL.Nat32,
    'retweet' : IDL.Opt(Retweet),
    'isRetweet' : IDL.Opt(UserData),
    'content' : IDL.Text,
    'author' : UserData,
    'market' : IDL.Opt(MarketInitData),
    'image' : IDL.Opt(IDL.Text),
    'parent' : IDL.Opt(ParentData),
  });
  const Market = IDL.Service({
    'accountBalance' : IDL.Func([IDL.Text], [IDL.Opt(ICP)], []),
    'addCommentToMarket' : IDL.Func([IDL.Nat32, IDL.Text], [Result_8], []),
    'buyOutcome' : IDL.Func(
        [IDL.Nat32, IDL.Float64, IDL.Nat, IDL.Bool],
        [Result_2],
        [],
      ),
    'callerAccount' : IDL.Func([], [AccountIdentifier], []),
    'canisterAccount' : IDL.Func([], [IDL.Text], ['query']),
    'canisterBalance' : IDL.Func([], [ICP], []),
    'createMarket' : IDL.Func([MarketInitData], [Result_7], []),
    'createUser' : IDL.Func([UserInitData], [Result_3], []),
    'editUser' : IDL.Func([UserInitData], [Result_3], []),
    'getFeed' : IDL.Func([], [IDL.Vec(PostStable)], ['query']),
    'getPost' : IDL.Func([IDL.Nat32], [Result_6], ['query']),
    'getThread' : IDL.Func([IDL.Nat32], [Result_5], ['query']),
    'getUserFromPrincipal' : IDL.Func([IDL.Text], [Result_4], ['query']),
    'getUserStable' : IDL.Func([IDL.Text], [IDL.Opt(UserStable)], ['query']),
    'getUserWithPosts' : IDL.Func([IDL.Text], [Result_4], ['query']),
    'otherAccount' : IDL.Func([], [IDL.Text], ['query']),
    'readAllMarkets' : IDL.Func(
        [MarketCategory, MarketState],
        [IDL.Vec(MarketStable)],
        ['query'],
      ),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserStable)], ['query']),
    'readMarket' : IDL.Func([IDL.Nat32], [IDL.Opt(MarketStable)], ['query']),
    'readUserData' : IDL.Func(
        [IDL.Vec(IDL.Text)],
        [IDL.Vec(UserData)],
        ['query'],
      ),
    'refreshUser' : IDL.Func([], [Result_3], []),
    'resolveMarket' : IDL.Func([IDL.Nat32, IDL.Nat], [IDL.Bool], []),
    'sellOutcome' : IDL.Func(
        [IDL.Nat32, IDL.Float64, IDL.Nat, IDL.Bool],
        [Result_2],
        [],
      ),
    'setMarketState' : IDL.Func([IDL.Nat32, MarketState], [IDL.Bool], []),
    'setUpdating' : IDL.Func([IDL.Bool], [], ['oneway']),
    'submitForecast' : IDL.Func([IDL.Nat32, Forecast], [Result_1], []),
    'submitLike' : IDL.Func([IDL.Nat32], [Result], []),
    'submitPost' : IDL.Func(
        [PostInitData, IDL.Opt(MarketInitData)],
        [Result],
        [],
      ),
    'submitRetweet' : IDL.Func([IDL.Nat32], [Result], []),
    'transferToCanister' : IDL.Func([], [IDL.Text], []),
    'transferToSubaccount' : IDL.Func([], [IDL.Text], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
