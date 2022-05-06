export const idlFactory = ({ IDL }) => {
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
  const ICP = IDL.Record({ 'e8s' : IDL.Nat64 });
  const Time = IDL.Int;
  const CollateralType = IDL.Variant({
    'icp' : IDL.Null,
    'seers' : IDL.Null,
    'cycles' : IDL.Null,
  });
  const MarketCategory = IDL.Variant({
    'entertainment' : IDL.Null,
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
    'title' : IDL.Text,
    'probabilities' : IDL.Vec(IDL.Float64),
    'endDate' : Time,
    'labels' : IDL.Vec(IDL.Text),
    'liquidity' : IDL.Float64,
    'collateralType' : CollateralType,
    'description' : IDL.Text,
    'nextId' : IDL.Nat32,
    'author' : IDL.Text,
    'imageUrl' : IDL.Text,
    'category' : MarketCategory,
    'startDate' : Time,
    'images' : IDL.Vec(IDL.Text),
  });
  const HistPoint = IDL.Record({
    'probabilities' : IDL.Vec(IDL.Float64),
    'createdAt' : Time,
    'liquidity' : IDL.Float64,
  });
  const MarketState = IDL.Variant({
    'resolved' : IDL.Nat,
    'closed' : IDL.Null,
    'pending' : IDL.Null,
    'invalid' : IDL.Null,
    'open' : IDL.Null,
    'approved' : IDL.Null,
  });
  const UserData = IDL.Record({
    'principal' : IDL.Text,
    'picture' : IDL.Text,
    'handle' : IDL.Text,
  });
  const Like = IDL.Record({
    'authorPicture' : IDL.Text,
    'createdAt' : Time,
    'stars' : IDL.Nat32,
    'authorHandle' : IDL.Text,
    'authorPrincipal' : IDL.Text,
  });
  const Comment = IDL.Record({
    'id' : IDL.Nat32,
    'content' : IDL.Text,
    'createdAt' : Time,
    'user' : UserData,
    'likes' : IDL.Vec(Like),
  });
  const MarketStable = IDL.Record({
    'k' : IDL.Float64,
    'id' : IDL.Nat32,
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
    'comments' : IDL.Vec(Comment),
    'totalShares' : IDL.Float64,
    'startDate' : Time,
    'images' : IDL.Vec(IDL.Text),
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
  const Result_1 = IDL.Variant({ 'ok' : MarketStable, 'err' : MarketError });
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
  const Balance = IDL.Variant({
    'btc' : IDL.Float64,
    'icp' : IDL.Float64,
    'seers' : IDL.Float64,
    'cycles' : IDL.Float64,
  });
  const Bet = IDL.Record({ 'tx' : UserTx, 'comment' : Comment });
  const Post = IDL.Record({
    'id' : IDL.Nat32,
    'content' : IDL.Text,
    'createdAt' : Time,
    'author' : UserData,
    'likes' : IDL.Vec(Like),
    'comments' : IDL.Vec(Comment),
  });
  const FeedItem = IDL.Variant({
    'bet' : Bet,
    'post' : Post,
    'comment' : Comment,
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
  const Like__1 = IDL.Record({
    'authorPicture' : IDL.Text,
    'createdAt' : Time,
    'stars' : IDL.Nat32,
    'authorHandle' : IDL.Text,
    'authorPrincipal' : IDL.Text,
  });
  const Comment__1 = IDL.Record({
    'id' : IDL.Nat32,
    'content' : IDL.Text,
    'createdAt' : Time,
    'user' : UserData,
    'likes' : IDL.Vec(Like__1),
  });
  const Post__1 = IDL.Record({
    'id' : IDL.Nat32,
    'content' : IDL.Text,
    'createdAt' : Time,
    'author' : UserData,
    'likes' : IDL.Vec(Like__1),
    'comments' : IDL.Vec(Comment__1),
  });
  const Followee = IDL.Record({ 'createdAt' : Time, 'user' : UserData });
  const Follower = IDL.Record({ 'createdAt' : Time, 'user' : UserData });
  const DepositAddr = IDL.Variant({
    'btc' : IDL.Text,
    'icp' : IDL.Text,
    'cycles' : IDL.Text,
  });
  const UserStable = IDL.Record({
    'id' : IDL.Text,
    'bio' : IDL.Text,
    'txs' : IDL.Vec(UserTx),
    'expBalances' : IDL.Vec(Balance),
    'twitter' : IDL.Text,
    'lastSeenAt' : Time,
    'modifiedAt' : Time,
    'feed' : IDL.Vec(FeedItem),
    'createdAt' : Time,
    'markets' : IDL.Vec(UserMarket),
    'picture' : IDL.Text,
    'discord' : IDL.Text,
    'handle' : IDL.Text,
    'comments' : IDL.Vec(Comment__1),
    'posts' : IDL.Vec(Post__1),
    'followees' : IDL.Vec(Followee),
    'followers' : IDL.Vec(Follower),
    'depositAddrs' : IDL.Vec(DepositAddr),
    'balances' : IDL.Vec(Balance),
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
    'marketMissing' : IDL.Null,
    'startDateOld' : IDL.Null,
    'marketNotOpen' : IDL.Null,
    'commentIsEmpty' : IDL.Null,
    'endDateOld' : IDL.Null,
    'newtonFailed' : IDL.Null,
    'endDateOlderThanStartDate' : IDL.Null,
    'notEnoughLiquidity' : IDL.Float64,
  });
  const Result = IDL.Variant({ 'ok' : UserStable, 'err' : UserError });
  const Market = IDL.Service({
    'approveMarket' : IDL.Func([IDL.Nat32], [], []),
    'callerAccount' : IDL.Func([], [AccountIdentifier], []),
    'canisterAccount' : IDL.Func([], [IDL.Text], ['query']),
    'canisterFloat' : IDL.Func([], [ICP], []),
    'createMarket' : IDL.Func([MarketInitData], [Result_1], []),
    'createUser' : IDL.Func([IDL.Text], [Result], []),
    'getUserStable' : IDL.Func([IDL.Text], [IDL.Opt(UserStable)], ['query']),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(MarketStable)], ['query']),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserStable)], ['query']),
    'readMarket' : IDL.Func([IDL.Nat32], [IDL.Opt(MarketStable)], ['query']),
    'resolveMarket' : IDL.Func([IDL.Nat32, IDL.Nat], [IDL.Bool], []),
    'setUpdating' : IDL.Func([IDL.Bool], [], ['oneway']),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
