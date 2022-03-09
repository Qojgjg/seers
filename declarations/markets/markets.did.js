export const idlFactory = ({ IDL }) => {
  const MarketId = IDL.Nat32;
  const Balance = IDL.Nat64;
  const Title = IDL.Text;
  const Probability = IDL.Nat64;
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
  const Shares = IDL.Nat64;
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
    'resolved' : IDL.Null,
    'closed' : IDL.Null,
    'open' : IDL.Null,
  });
  const MarketResult = IDL.Record({
    'id' : MarketId,
    'title' : Title,
    'noProb' : Probability,
    'endDate' : Time,
    'liquidity' : Balance,
    'description' : Description,
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
    'buyNo' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'buyYes' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'createMarket' : IDL.Func([MarketInitData], [IDL.Nat32], []),
    'deleteAllMarkets' : IDL.Func([], [], []),
    'deleteAllUsers' : IDL.Func([], [], []),
    'deleteMarket' : IDL.Func([MarketId], [IDL.Bool], []),
    'getUser' : IDL.Func([UserId], [UserResult], []),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserResult)], ['query']),
    'readMarket' : IDL.Func([MarketId], [IDL.Opt(MarketResult)], ['query']),
    'removeLiquidity' : IDL.Func([MarketId], [IDL.Bool], []),
    'sellNo' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'sellYes' : IDL.Func([MarketId, Balance, IDL.Bool], [IDL.Opt(Balance)], []),
    'updateMarket' : IDL.Func([MarketId, MarketResult], [IDL.Bool], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
