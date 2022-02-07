export const idlFactory = ({ IDL }) => {
  const Title = IDL.Text;
  const Time = IDL.Int;
  const Description = IDL.Text;
  const MarketInitData = IDL.Record({
    'title' : Title,
    'noProb' : IDL.Nat32,
    'endDate' : Time,
    'liquidity' : IDL.Nat32,
    'description' : Description,
    'yesProb' : IDL.Nat32,
  });
  const User = IDL.Record({
    'id' : IDL.Text,
    'seerBalance' : IDL.Nat32,
    'marketTokens' : IDL.Vec(IDL.Tuple(IDL.Nat32, IDL.Nat32, IDL.Nat32)),
    'liquidityProviderFor' : IDL.Vec(IDL.Tuple(IDL.Nat32, IDL.Nat32)),
  });
  const Author = IDL.Text;
  const Market__1 = IDL.Record({
    'id' : IDL.Nat32,
    'title' : Title,
    'noProb' : IDL.Nat32,
    'endDate' : Time,
    'liquidity' : IDL.Nat32,
    'description' : Description,
    'author' : Author,
    'yesProb' : IDL.Nat32,
    'reserveNo' : IDL.Nat32,
    'reserveYes' : IDL.Nat32,
    'kLast' : IDL.Nat32,
    'blockTimestampLast' : Time,
    'startDate' : Time,
  });
  const Market = IDL.Service({
    'createMarket' : IDL.Func([MarketInitData], [IDL.Nat32], []),
    'delete' : IDL.Func([IDL.Nat32], [IDL.Bool], []),
    'deleteAll' : IDL.Func([], [], []),
    'getUser' : IDL.Func([], [IDL.Opt(User)], []),
    'read' : IDL.Func([IDL.Nat32], [IDL.Opt(Market__1)], ['query']),
    'readAll' : IDL.Func([], [IDL.Vec(Market__1)], ['query']),
    'update' : IDL.Func([IDL.Nat32, Market__1], [IDL.Bool], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
