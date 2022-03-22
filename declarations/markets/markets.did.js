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
    'probabilities' : IDL.Vec(Probability),
    'endDate' : Time,
    'labels' : IDL.Vec(IDL.Text),
    'liquidity' : Balance,
    'description' : Description,
    'imageUrl' : Url,
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
    'labels' : IDL.Vec(IDL.Text),
    'liquidity' : Balance,
    'reserves' : IDL.Vec(Balance),
    'description' : Description,
    'volume' : Balance,
    'author' : Author,
    'state' : MarketState,
    'imageUrl' : Url,
    'providers' : IDL.Vec(IDL.Text),
    'kLast' : Balance,
    'totalShares' : Shares,
    'blockTimestampLast' : Time,
    'startDate' : Time,
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
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
