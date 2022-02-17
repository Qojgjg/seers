export const idlFactory = ({ IDL }) => {
  const Title = IDL.Text;
  const Time = IDL.Int;
  const Description = IDL.Text;
  const MarketInitData = IDL.Record({
    'title' : Title,
    'noProb' : IDL.Nat64,
    'endDate' : Time,
    'liquidity' : IDL.Nat64,
    'description' : Description,
    'yesProb' : IDL.Nat64,
  });
  const UserResult = IDL.Record({
    'id' : IDL.Text,
    'seerBalance' : IDL.Nat64,
    'marketTokens' : IDL.Vec(IDL.Tuple(IDL.Nat64, IDL.Nat64, IDL.Nat64)),
    'liquidityProviderFor' : IDL.Vec(IDL.Tuple(IDL.Nat32, IDL.Nat64)),
  });
  const Author = IDL.Text;
  const Market__1 = IDL.Record({
    'id' : IDL.Nat32,
    'title' : Title,
    'noProb' : IDL.Nat64,
    'endDate' : Time,
    'liquidity' : IDL.Nat64,
    'description' : Description,
    'author' : Author,
    'yesProb' : IDL.Nat64,
    'reserveNo' : IDL.Nat64,
    'providers' : IDL.Vec(IDL.Text),
    'reserveYes' : IDL.Nat64,
    'kLast' : IDL.Nat64,
    'totalShares' : IDL.Nat64,
    'blockTimestampLast' : Time,
    'startDate' : Time,
  });
  const Market = IDL.Service({
    'createMarket' : IDL.Func([MarketInitData], [IDL.Nat32], []),
    'deleteAllMarkets' : IDL.Func([], [], []),
    'deleteMarket' : IDL.Func([IDL.Nat32], [IDL.Bool], []),
    'getUser' : IDL.Func([], [IDL.Opt(UserResult)], []),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(Market__1)], ['query']),
    'readMarket' : IDL.Func([IDL.Nat32], [IDL.Opt(Market__1)], ['query']),
    'updateMarket' : IDL.Func([IDL.Nat32, Market__1], [IDL.Bool], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
