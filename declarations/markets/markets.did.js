export const idlFactory = ({ IDL }) => {
  const MarketId = IDL.Nat32;
  const Balance = IDL.Int;
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
  const UserId = IDL.Text;
  const Shares = IDL.Int;
  const UserMarket = IDL.Record({
    'shares' : Shares,
    'marketId' : MarketId,
    'balances' : IDL.Vec(Balance),
    'marketTitle' : Title,
  });
  const UserResult = IDL.Record({
    'id' : UserId,
    'seerBalance' : Balance,
    'markets' : IDL.Vec(UserMarket),
  });
  const Probability = IDL.Int;
  const Author = IDL.Text;
  const MarketState = IDL.Variant({
    'resolved' : IDL.Nat,
    'closed' : IDL.Null,
    'pending' : IDL.Null,
    'open' : IDL.Null,
  });
  const MarketResult = IDL.Record({
    'id' : MarketId,
    'title' : Title,
    'probabilities' : IDL.Vec(Probability),
    'endDate' : Time,
    'liquidities' : IDL.Vec(Balance),
    'labels' : IDL.Vec(IDL.Text),
    'reserves' : IDL.Vec(Balance),
    'description' : Description,
    'volume' : Balance,
    'author' : Author,
    'state' : MarketState,
    'imageUrl' : Url,
    'providers' : IDL.Vec(IDL.Text),
    'kLasts' : IDL.Vec(Balance),
    'totalShares' : Shares,
    'blockTimestampLast' : Time,
    'startDate' : Time,
    'images' : IDL.Vec(IDL.Text),
  });
  const Market = IDL.Service({
    'approveMarket' : IDL.Func([MarketId], [], []),
    'buyOption' : IDL.Func(
        [MarketId, Balance, IDL.Nat, IDL.Bool],
        [IDL.Opt(Balance)],
        [],
      ),
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
    'resolveMarket' : IDL.Func([MarketId, IDL.Nat], [IDL.Bool], []),
    'sellOption' : IDL.Func(
        [MarketId, Balance, IDL.Nat, IDL.Bool],
        [IDL.Opt(Balance)],
        [],
      ),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
