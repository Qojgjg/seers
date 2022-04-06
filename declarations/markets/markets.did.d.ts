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
  'addCommentToMarket' : (arg_0: MarketId, arg_1: string) => Promise<Result_4>,
  'approveMarket' : (arg_0: MarketId) => Promise<undefined>,
  'backup' : () => Promise<undefined>,
  'buyOption' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result>,
  'createMarket' : (arg_0: MarketInitData) => Promise<Result_3>,
  'createUserResult' : (arg_0: string) => Promise<Result_2>,
  'deleteAllMarkets' : () => Promise<undefined>,
  'deleteMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'editMarketImage' : (arg_0: MarketId, arg_1: string) => Promise<boolean>,
  'editMarketProbs' : (arg_0: MarketId, arg_1: Array<Balance>) => Promise<
      boolean
    >,
  'getUserResult' : (arg_0: UserId) => Promise<[] | [UserResult]>,
  'importMarkets' : (arg_0: Array<MarketResult>) => Promise<undefined>,
  'importUsers' : (arg_0: Array<OldUserResult>) => Promise<undefined>,
  'moveStables' : () => Promise<undefined>,
  'readAllMarkets' : () => Promise<Array<MarketResult>>,
  'readAllOpenMarkets' : () => Promise<Array<MarketResult>>,
  'readAllPendingMarkets' : () => Promise<Array<MarketResult>>,
  'readAllUsers' : () => Promise<Array<UserResult>>,
  'readMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'readNewUsers' : () => Promise<Array<[UserId, UserResult]>>,
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
export interface OldUserMarket {
  'shares' : Shares,
  'marketId' : MarketId,
  'balances' : Array<Balance>,
  'marketTitle' : Title,
}
export interface OldUserResult {
  'id' : UserId,
  'seerBalance' : Balance,
  'markets' : Array<OldUserMarket>,
  'expSeerBalance' : Balance,
  'handle' : string,
}
export type Probability = number;
export type Result = { 'ok' : Balance } |
  { 'err' : TradeError };
export type Result_1 = { 'ok' : UserResult } |
  { 'err' : UserError };
export type Result_2 = { 'ok' : UserResult } |
  { 'err' : CreateUserError };
export type Result_3 = { 'ok' : MarketResult } |
  { 'err' : CreateMarketError };
export type Result_4 = { 'ok' : Comment } |
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
export type UserError = { 'callerIsAnon' : null } |
  { 'userNotCreated' : null };
export type UserId = string;
export interface UserMarket {
  'shares' : Shares,
  'labels' : Array<string>,
  'used' : boolean,
  'marketId' : MarketId,
  'balances' : Array<Balance>,
  'marketTitle' : Title,
}
export interface UserResult {
  'id' : UserId,
  'txs' : Array<UserTx>,
  'seerBalance' : Balance,
  'markets' : Array<UserMarket>,
  'expSeerBalance' : Balance,
  'handle' : string,
}
export interface UserTx {
  'fee' : Balance,
  'src' : [] | [bigint],
  'dest' : [] | [bigint],
  'seerRecv' : Balance,
  'seerSent' : Balance,
  'marketId' : MarketId,
  'timestamp' : Time,
}
export interface _SERVICE extends Market {}
