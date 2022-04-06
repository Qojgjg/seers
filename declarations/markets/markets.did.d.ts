import type { Principal } from '@dfinity/principal';
export type AddCommentError = { 'userIsAnon' : null } |
  { 'userNotCreated' : null } |
  { 'marketMissing' : null } |
  { 'commentIsEmpty' : null };
export type Author = string;
export type Balance = number;
export interface Comment { 'content' : string, 'author' : string }
export type CreateMarketError = { 'callerIsAnon' : null } |
  { 'imageMissing' : null } |
  { 'optionsMissing' : null } |
  { 'descriptionMissing' : null } |
  { 'titleMissing' : null } |
  { 'userNotCreated' : null } |
  { 'endDateOld' : Time } |
  { 'notEnoughLiquidity' : Balance };
export type CreateUserError = { 'userExist' : null } |
  { 'userIsAnon' : null };
export type Description = string;
export interface Market {
  'addCommentToMarket' : (arg_0: MarketId, arg_1: string) => Promise<Result_5>,
  'approveMarket' : (arg_0: MarketId) => Promise<undefined>,
  'backup' : () => Promise<undefined>,
  'buyOption' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result>,
  'createMarket' : (arg_0: MarketInitData) => Promise<Result_4>,
  'createUserResult' : (arg_0: string) => Promise<Result_3>,
  'createUserResult3' : (arg_0: string) => Promise<Result_2>,
  'deleteAllMarkets' : () => Promise<undefined>,
  'deleteMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'editMarketImage' : (arg_0: MarketId, arg_1: string) => Promise<boolean>,
  'editMarketProbs' : (arg_0: MarketId, arg_1: Array<Balance>) => Promise<
      boolean
    >,
  'getUserResult' : (arg_0: UserId) => Promise<[] | [UserResult2]>,
  'getUserResult3' : (arg_0: UserId) => Promise<[] | [UserResult3]>,
  'importMarkets' : (arg_0: Array<MarketResult>) => Promise<undefined>,
  'importUsers' : (arg_0: Array<UserResult>) => Promise<undefined>,
  'readAllMarkets' : () => Promise<Array<MarketResult>>,
  'readAllOpenMarkets' : () => Promise<Array<MarketResult>>,
  'readAllPendingMarkets' : () => Promise<Array<MarketResult>>,
  'readAllUsers3' : () => Promise<Array<UserResult3>>,
  'readMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'readNewUsers' : () => Promise<Array<[UserId, UserResult3]>>,
  'refreshUser' : () => Promise<Result_1>,
  'resolveMarket' : (arg_0: MarketId, arg_1: bigint) => Promise<boolean>,
  'restore' : () => Promise<undefined>,
  'sellOption' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result>,
  'setUpdating' : (arg_0: boolean) => Promise<undefined>,
  'tip' : (arg_0: UserId, arg_1: Balance) => Promise<[] | [Balance]>,
}
export type MarketId = number;
export interface MarketInitData {
  'title' : Title,
  'endDate' : Time,
  'labels' : Array<string>,
  'liquidity' : Balance,
  'description' : Description,
  'imageUrl' : Url,
  'images' : Array<string>,
}
export interface MarketResult {
  'k' : Balance,
  'id' : MarketId,
  'title' : Title,
  'probabilities' : Array<Probability>,
  'endDate' : Time,
  'labels' : Array<string>,
  'liquidity' : Balance,
  'reserves' : Array<Balance>,
  'description' : Description,
  'volume' : Balance,
  'author' : Author,
  'state' : MarketState,
  'imageUrl' : Url,
  'providers' : Array<string>,
  'comments' : Array<Comment>,
  'totalShares' : Shares,
  'blockTimestampLast' : Time,
  'startDate' : Time,
  'images' : Array<string>,
}
export type MarketState = { 'resolved' : bigint } |
  { 'closed' : null } |
  { 'pending' : null } |
  { 'open' : null };
export type Probability = number;
export type RefreshUserError = { 'callerIsAnon' : null } |
  { 'userNotCreated' : null };
export type Result = { 'ok' : Balance } |
  { 'err' : TradeError };
export type Result_1 = { 'ok' : UserResult3 } |
  { 'err' : RefreshUserError };
export type Result_2 = { 'ok' : UserResult3 } |
  { 'err' : CreateUserError };
export type Result_3 = { 'ok' : UserResult2 } |
  { 'err' : CreateUserError };
export type Result_4 = { 'ok' : MarketResult } |
  { 'err' : CreateMarketError };
export type Result_5 = { 'ok' : Comment } |
  { 'err' : AddCommentError };
export type Shares = bigint;
export type Time = bigint;
export type Title = string;
export type TradeError = { 'callerIsAnon' : null } |
  { 'notEnoughBalance' : null } |
  { 'marketClosed' : null } |
  { 'userNotCreated' : null } |
  { 'marketMissing' : null } |
  { 'newtonFailed' : null };
export type Url = string;
export type UserId = string;
export interface UserMarket {
  'shares' : Shares,
  'marketId' : MarketId,
  'balances' : Array<Balance>,
  'marketTitle' : Title,
}
export interface UserMarket2 {
  'shares' : Shares,
  'used' : boolean,
  'marketId' : MarketId,
  'balances' : Array<Balance>,
  'marketTitle' : Title,
}
export interface UserMarket3 {
  'shares' : Shares,
  'labels' : Array<string>,
  'used' : boolean,
  'marketId' : MarketId,
  'balances' : Array<Balance>,
  'marketTitle' : Title,
}
export interface UserResult {
  'id' : UserId,
  'seerBalance' : Balance,
  'markets' : Array<UserMarket>,
  'expSeerBalance' : Balance,
  'handle' : string,
}
export interface UserResult2 {
  'id' : UserId,
  'seerBalance' : Balance,
  'markets' : Array<UserMarket2>,
  'expSeerBalance' : Balance,
  'handle' : string,
}
export interface UserResult3 {
  'id' : UserId,
  'seerBalance' : Balance,
  'markets' : Array<UserMarket3>,
  'expSeerBalance' : Balance,
  'handle' : string,
}
export interface _SERVICE extends Market {}
