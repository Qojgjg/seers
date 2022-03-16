import type { Principal } from '@dfinity/principal';
export type Author = string;
export type Balance = bigint;
export type Description = string;
export interface Market {
  'addLiquidity' : (arg_0: MarketId, arg_1: Balance) => Promise<boolean>,
  'approveMarket' : (arg_0: MarketId) => Promise<undefined>,
  'buyNo' : (arg_0: MarketId, arg_1: Balance, arg_2: boolean) => Promise<
      [] | [Balance]
    >,
  'buyYes' : (arg_0: MarketId, arg_1: Balance, arg_2: boolean) => Promise<
      [] | [Balance]
    >,
  'createMarket' : (arg_0: MarketInitData) => Promise<MarketId>,
  'createUserResult' : () => Promise<UserResult>,
  'deleteAllMarkets' : () => Promise<undefined>,
  'deleteAllUsers' : () => Promise<undefined>,
  'deleteMarket' : (arg_0: MarketId) => Promise<boolean>,
  'getUserResult' : (arg_0: UserId) => Promise<[] | [UserResult]>,
  'readAllMarkets' : () => Promise<Array<MarketResult>>,
  'readAllUsers' : () => Promise<Array<UserResult>>,
  'readMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'removeLiquidity' : (arg_0: MarketId) => Promise<boolean>,
  'resolveMarket' : (arg_0: MarketId, arg_1: boolean) => Promise<boolean>,
  'sellNo' : (arg_0: MarketId, arg_1: Balance, arg_2: boolean) => Promise<
      [] | [Balance]
    >,
  'sellYes' : (arg_0: MarketId, arg_1: Balance, arg_2: boolean) => Promise<
      [] | [Balance]
    >,
}
export type MarketId = number;
export interface MarketInitData {
  'title' : Title,
  'noProb' : Probability,
  'endDate' : Time,
  'liquidity' : Balance,
  'description' : Description,
  'yesProb' : Probability,
  'imageUrl' : Url,
}
export interface MarketResult {
  'id' : MarketId,
  'title' : Title,
  'noProb' : Probability,
  'endDate' : Time,
  'liquidity' : Balance,
  'description' : Description,
  'volume' : Balance,
  'author' : Author,
  'yesProb' : Probability,
  'reserveNo' : Balance,
  'state' : MarketState,
  'imageUrl' : Url,
  'providers' : Array<string>,
  'reserveYes' : Balance,
  'kLast' : Balance,
  'totalShares' : Shares,
  'blockTimestampLast' : Time,
  'startDate' : Time,
}
export type MarketState = { 'resolved' : boolean } |
  { 'closed' : null } |
  { 'pending' : null } |
  { 'open' : null };
export type Probability = bigint;
export type Shares = bigint;
export type Time = bigint;
export type Title = string;
export type Url = string;
export type UserId = string;
export interface UserMarket {
  'shares' : Shares,
  'noBalance' : Balance,
  'state' : MarketState,
  'marketId' : MarketId,
  'yesBalance' : Balance,
  'marketTitle' : Title,
}
export interface UserResult {
  'id' : UserId,
  'seerBalance' : Balance,
  'markets' : Array<UserMarket>,
}
export interface _SERVICE extends Market {}
