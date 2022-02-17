export const idlFactory = ({ IDL }) => {
  const Title = IDL.Text;
  const Probability = IDL.Nat64;
  const Time = IDL.Int;
  const Balance = IDL.Nat64;
  const Description = IDL.Text;
  const MarketInitData = IDL.Record({
    'title' : Title,
    'noProb' : Probability,
    'endDate' : Time,
    'liquidity' : Balance,
    'description' : Description,
    'yesProb' : Probability,
  });
  const MarketId = IDL.Nat32;
  const UserId = IDL.Text;
  const UserTokens = IDL.Record({
    'noBalance' : Balance,
    'marketId' : MarketId,
    'yesBalance' : Balance,
  });
  const Shares = IDL.Nat64;
  const UserShares = IDL.Record({ 'shares' : Shares, 'marketId' : MarketId });
  const UserResult = IDL.Record({
    'id' : UserId,
    'seerBalance' : Balance,
    'marketTokens' : IDL.Vec(UserTokens),
    'liquidityProviderFor' : IDL.Vec(UserShares),
  });
  const Author = IDL.Text;
  const Market__1 = IDL.Record({
    'id' : MarketId,
    'title' : Title,
    'noProb' : Probability,
    'endDate' : Time,
    'liquidity' : Balance,
    'description' : Description,
    'author' : Author,
    'yesProb' : Probability,
    'reserveNo' : Balance,
    'providers' : IDL.Vec(IDL.Text),
    'reserveYes' : Balance,
    'kLast' : Balance,
    'totalShares' : Shares,
    'blockTimestampLast' : Time,
    'startDate' : Time,
  });
  const Market = IDL.Service({
    'createMarket' : IDL.Func([MarketInitData], [IDL.Nat32], []),
    'deleteAllMarkets' : IDL.Func([], [], []),
    'deleteMarket' : IDL.Func([MarketId], [IDL.Bool], []),
    'getOrCreateUser' : IDL.Func([], [IDL.Opt(UserResult)], []),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(Market__1)], ['query']),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserResult)], ['query']),
    'readMarket' : IDL.Func([MarketId], [IDL.Opt(Market__1)], ['query']),
    'updateMarket' : IDL.Func([MarketId, Market__1], [IDL.Bool], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
