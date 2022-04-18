export const idlFactory = ({ IDL }) => {
  const MarketId = IDL.Nat32;
  const Comment = IDL.Record({ 'content' : IDL.Text, 'author' : IDL.Text });
  const AddCommentError = IDL.Variant({
    'userIsAnon' : IDL.Null,
    'userNotCreated' : IDL.Null,
    'marketMissing' : IDL.Null,
    'commentIsEmpty' : IDL.Null,
  });
  const Result_4 = IDL.Variant({ 'ok' : Comment, 'err' : AddCommentError });
  const Balance = IDL.Float64;
  const TradeError = IDL.Variant({
    'callerIsAnon' : IDL.Null,
    'minimalAmountIsOne' : IDL.Null,
    'notEnoughBalance' : IDL.Null,
    'marketClosed' : IDL.Null,
    'userNotCreated' : IDL.Null,
    'marketMissing' : IDL.Null,
    'newtonFailed' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : Balance, 'err' : TradeError });
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
  const ICP = IDL.Record({ 'e8s' : IDL.Nat64 });
  const UserId = IDL.Text;
  const Title = IDL.Text;
  const Time = IDL.Int;
  const Description = IDL.Text;
  const Url = IDL.Text;
  const MarketInitData = IDL.Record({
    'title' : Title,
    'endDate' : Time,
    'labels' : IDL.Vec(IDL.Text),
    'liquidity' : Balance,
    'description' : Description,
    'imageUrl' : Url,
    'images' : IDL.Vec(IDL.Text),
  });
  const Probability = IDL.Float64;
  const Author = IDL.Text;
  const MarketState = IDL.Variant({
    'resolved' : IDL.Nat,
    'closed' : IDL.Null,
    'pending' : IDL.Null,
    'open' : IDL.Null,
  });
  const Shares = IDL.Int;
  const MarketResult = IDL.Record({
    'k' : Balance,
    'id' : MarketId,
    'title' : Title,
    'probabilities' : IDL.Vec(Probability),
    'endDate' : Time,
    'labels' : IDL.Vec(IDL.Text),
    'liquidity' : Balance,
    'reserves' : IDL.Vec(Balance),
    'description' : Description,
    'volume' : Balance,
    'author' : Author,
    'state' : MarketState,
    'imageUrl' : Url,
    'providers' : IDL.Vec(IDL.Text),
    'comments' : IDL.Vec(Comment),
    'totalShares' : Shares,
    'blockTimestampLast' : Time,
    'startDate' : Time,
    'images' : IDL.Vec(IDL.Text),
  });
  const CreateMarketError = IDL.Variant({
    'callerIsAnon' : IDL.Null,
    'imageMissing' : IDL.Null,
    'optionsMissing' : IDL.Null,
    'descriptionMissing' : IDL.Null,
    'titleMissing' : IDL.Null,
    'userNotCreated' : IDL.Null,
    'endDateOld' : Time,
    'notEnoughLiquidity' : Balance,
  });
  const Result_3 = IDL.Variant({
    'ok' : MarketResult,
    'err' : CreateMarketError,
  });
  const UserTx = IDL.Record({
    'fee' : Balance,
    'src' : IDL.Opt(IDL.Nat),
    'dest' : IDL.Opt(IDL.Nat),
    'seerRecv' : Balance,
    'seerSent' : Balance,
    'marketId' : MarketId,
    'timestamp' : Time,
  });
  const UserMarket = IDL.Record({
    'shares' : Shares,
    'labels' : IDL.Vec(IDL.Text),
    'used' : IDL.Bool,
    'marketId' : MarketId,
    'balances' : IDL.Vec(Balance),
    'marketTitle' : Title,
  });
  const UserResult = IDL.Record({
    'id' : UserId,
    'txs' : IDL.Vec(UserTx),
    'seerBalance' : Balance,
    'markets' : IDL.Vec(UserMarket),
    'expSeerBalance' : Balance,
    'handle' : IDL.Text,
  });
  const CreateUserError = IDL.Variant({
    'userExist' : IDL.Null,
    'userIsAnon' : IDL.Null,
  });
  const Result_2 = IDL.Variant({ 'ok' : UserResult, 'err' : CreateUserError });
  const OldUserMarket = IDL.Record({
    'shares' : Shares,
    'marketId' : MarketId,
    'balances' : IDL.Vec(Balance),
    'marketTitle' : Title,
  });
  const OldUserResult = IDL.Record({
    'id' : UserId,
    'seerBalance' : Balance,
    'markets' : IDL.Vec(OldUserMarket),
    'expSeerBalance' : Balance,
    'handle' : IDL.Text,
  });
  const UserError = IDL.Variant({
    'callerIsAnon' : IDL.Null,
    'userNotCreated' : IDL.Null,
  });
  const Result_1 = IDL.Variant({ 'ok' : UserResult, 'err' : UserError });
  const Market = IDL.Service({
    'addCommentToMarket' : IDL.Func([MarketId, IDL.Text], [Result_4], []),
    'approveMarket' : IDL.Func([MarketId], [], []),
    'backup' : IDL.Func([], [], []),
    'buyOption' : IDL.Func(
        [MarketId, Balance, IDL.Nat, IDL.Bool],
        [Result],
        [],
      ),
    'callerAccount' : IDL.Func([], [AccountIdentifier], []),
    'canisterAccount' : IDL.Func([], [IDL.Text], ['query']),
    'canisterBalance' : IDL.Func([], [ICP], []),
    'cleanTxs' : IDL.Func([UserId], [], []),
    'createMarket' : IDL.Func([MarketInitData], [Result_3], []),
    'createUserResult' : IDL.Func([IDL.Text], [Result_2], []),
    'deleteAllMarkets' : IDL.Func([], [], []),
    'deleteMarket' : IDL.Func([MarketId], [IDL.Opt(MarketResult)], []),
    'editMarketImage' : IDL.Func([MarketId, IDL.Text], [IDL.Bool], []),
    'editMarketProbs' : IDL.Func([MarketId, IDL.Vec(Balance)], [IDL.Bool], []),
    'getUserResult' : IDL.Func([UserId], [IDL.Opt(UserResult)], ['query']),
    'importMarkets' : IDL.Func([IDL.Vec(MarketResult)], [], ['oneway']),
    'importUsers' : IDL.Func([IDL.Vec(OldUserResult)], [], ['oneway']),
    'increaseMarketCounter' : IDL.Func([MarketId], [MarketId], []),
    'moveStables' : IDL.Func([], [], []),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllOpenMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllPendingMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserResult)], ['query']),
    'readBetsOfMarket' : IDL.Func(
        [MarketId],
        [IDL.Vec(IDL.Tuple(UserId, IDL.Text, IDL.Vec(UserTx)))],
        ['query'],
      ),
    'readMarket' : IDL.Func([MarketId], [IDL.Opt(MarketResult)], ['query']),
    'readNewUsers' : IDL.Func([], [IDL.Vec(IDL.Tuple(UserId, UserResult))], []),
    'readUser' : IDL.Func([UserId], [IDL.Opt(UserResult)], ['query']),
    'refreshUser' : IDL.Func([], [Result_1], []),
    'resolveMarket' : IDL.Func([MarketId, IDL.Nat], [IDL.Bool], []),
    'restore' : IDL.Func([], [], []),
    'sellOption' : IDL.Func(
        [MarketId, Balance, IDL.Nat, IDL.Bool],
        [Result],
        [],
      ),
    'setUpdating' : IDL.Func([IDL.Bool], [], ['oneway']),
    'tip' : IDL.Func([UserId, Balance], [IDL.Opt(Balance)], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
