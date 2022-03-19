export const idlFactory = ({ IDL }) => {
  const MarketId = IDL.Nat32;
  const Balance = IDL.Int;
  const Title = IDL.Text;
  const Probability = IDL.Int;
  const Time = IDL.Int;
  const Description = IDL.Text;
  const Url = IDL.Text;
  const MarketInitData = IDL.Record({
    'title' : Title,
    'noProb' : Probability,
    'endDate' : Time,
    'liquidity' : Balance,
    'description' : Description,
    'yesProb' : Probability,
    'imageUrl' : Url,
  });
  const UserId = IDL.Text;
  const Shares = IDL.Int;
  const UserMarket = IDL.Record({
    'shares' : Shares,
    'noBalance' : Balance,
    'marketId' : MarketId,
    'yesBalance' : Balance,
    'marketTitle' : Title,
  });
  const UserResult = IDL.Record({
    'id' : UserId,
    'seerBalance' : Balance,
    'markets' : IDL.Vec(UserMarket),
  });
  const Author = IDL.Text;
  const MarketState = IDL.Variant({
    'resolved' : IDL.Bool,
    'closed' : IDL.Null,
    'pending' : IDL.Null,
    'open' : IDL.Null,
  });
  const MarketResult = IDL.Record({
    'id' : MarketId,
    'title' : Title,
    'noProb' : Probability,
    'endDate' : Time,
    'liquidity' : Balance,
    'description' : Description,
    'volume' : Balance,
    'author' : Author,
    'yesProb' : Probability,
    'reserveNo' : Balance,
    'state' : MarketState,
    'imageUrl' : Url,
    'providers' : IDL.Vec(IDL.Text),
    'reserveYes' : Balance,
    'kLast' : Balance,
    'totalShares' : Shares,
    'blockTimestampLast' : Time,
    'startDate' : Time,
  });
  const Market = IDL.Service({
    'addLiquidity' : IDL.Func([MarketId, Balance], [IDL.Bool], []),
    'approveMarket' : IDL.Func([MarketId], [], []),
    'buyNo' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'buyYes' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'claimTokens' : IDL.Func([MarketId], [Balance], []),
    'createMarket' : IDL.Func([MarketInitData], [MarketId], []),
    'createUserResult' : IDL.Func([], [UserResult], []),
    'deleteAllMarkets' : IDL.Func([], [], []),
    'deleteAllUsers' : IDL.Func([], [], []),
    'deleteMarket' : IDL.Func([MarketId], [IDL.Bool], []),
    'getUserResult' : IDL.Func([UserId], [IDL.Opt(UserResult)], ['query']),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllOpenMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserResult)], ['query']),
    'readMarket' : IDL.Func([MarketId], [IDL.Opt(MarketResult)], ['query']),
    'removeLiquidity' : IDL.Func([MarketId], [IDL.Bool], []),
    'resolveMarket' : IDL.Func([MarketId, IDL.Bool], [IDL.Bool], []),
    'sellNo' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'sellYes' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
