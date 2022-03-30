import type { Principal } from '@dfinity/principal';
export type Author = string;
export type Balance = number;
export type CreateMarketError = { 'callerIsAnon' : null } |
  { 'imageMissing' : null } |
  { 'optionsMissing' : null } |
  { 'descriptionMissing' : null } |
  { 'titleMissing' : null } |
  { 'endDateOld' : Time } |
  { 'notEnoughLiquidity' : Balance };
export type Description = string;
export interface Market {
  'approveMarket' : (arg_0: MarketId) => Promise<undefined>,
  'buyOption' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result>,
  'claimTokens' : (arg_0: MarketId) => Promise<Balance>,
  'createMarket' : (arg_0: MarketInitData) => Promise<Result_1>,
  'createUserResult' : () => Promise<UserResult>,
  'deleteAllMarkets' : () => Promise<undefined>,
  'deleteAllUsers' : () => Promise<undefined>,
  'deleteMarket' : (arg_0: MarketId) => Promise<boolean>,
  'getUserResult' : (arg_0: UserId) => Promise<[] | [UserResult]>,
  'readAllMarkets' : () => Promise<Array<MarketResult>>,
  'readAllOpenMarkets' : () => Promise<Array<MarketResult>>,
  'readAllUsers' : () => Promise<Array<UserResult>>,
  'readMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'resolveMarket' : (arg_0: MarketId, arg_1: bigint) => Promise<boolean>,
  'sellOption' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result>,
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
export type Result = { 'ok' : Balance } |
  { 'err' : TradeError };
export type Result_1 = { 'ok' : MarketResult } |
  { 'err' : CreateMarketError };
export type Shares = bigint;
export type Time = bigint;
export type Title = string;
export type TradeError = { 'callerIsAnon' : null } |
  { 'notEnoughBalance' : null } |
  { 'marketClosed' : null } |
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
export interface UserResult {
  'id' : UserId,
  'seerBalance' : Balance,
  'markets' : Array<UserMarket>,
}
export interface _SERVICE extends Market {}
