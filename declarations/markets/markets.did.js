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
    'notEnoughBalance' : IDL.Null,
    'marketClosed' : IDL.Null,
    'userNotCreated' : IDL.Null,
    'marketMissing' : IDL.Null,
    'newtonFailed' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : Balance, 'err' : TradeError });
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
  const UserId = IDL.Text;
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
    'expSeerBalance' : Balance,
    'handle' : IDL.Text,
  });
  const CreateUserError = IDL.Variant({
    'userExist' : IDL.Null,
    'userIsAnon' : IDL.Null,
  });
  const Result_2 = IDL.Variant({ 'ok' : UserResult, 'err' : CreateUserError });
  const RefreshUserError = IDL.Variant({
    'callerIsAnon' : IDL.Null,
    'userNotCreated' : IDL.Null,
  });
  const Result_1 = IDL.Variant({ 'ok' : UserResult, 'err' : RefreshUserError });
  const Market = IDL.Service({
    'addCommentToMarket' : IDL.Func([MarketId, IDL.Text], [Result_4], []),
    'approveMarket' : IDL.Func([MarketId], [], []),
    'buyOption' : IDL.Func(
        [MarketId, Balance, IDL.Nat, IDL.Bool],
        [Result],
        [],
      ),
    'createMarket' : IDL.Func([MarketInitData], [Result_3], []),
    'createUserResult' : IDL.Func([IDL.Text], [Result_2], []),
    'deleteMarket' : IDL.Func([MarketId], [IDL.Opt(MarketResult)], []),
    'getUserResult' : IDL.Func([UserId], [IDL.Opt(UserResult)], ['query']),
    'readAllMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllOpenMarkets' : IDL.Func([], [IDL.Vec(MarketResult)], ['query']),
    'readAllUsers' : IDL.Func([], [IDL.Vec(UserResult)], ['query']),
    'readMarket' : IDL.Func([MarketId], [IDL.Opt(MarketResult)], ['query']),
    'refreshUser' : IDL.Func([], [Result_1], []),
    'sellOption' : IDL.Func(
        [MarketId, Balance, IDL.Nat, IDL.Bool],
        [Result],
        [],
      ),
    'tip' : IDL.Func([UserId, Balance], [IDL.Opt(Balance)], []),
  });
  return Market;
};
export const init = ({ IDL }) => { return []; };
