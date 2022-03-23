import type { Principal } from '@dfinity/principal';
export type Author = string;
export type Balance = bigint;
export type Description = string;
export interface Market {
  'approveMarket' : (arg_0: MarketId) => Promise<undefined>,
  'buyOption' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<[] | [Balance]>,
  'claimTokens' : (arg_0: MarketId) => Promise<Balance>,
  'createMarket' : (arg_0: MarketInitData) => Promise<MarketId>,
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
  'sellYes' : (
      arg_0: MarketId,
      arg_1: Balance,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<[] | [Balance]>,
}
export type MarketId = number;
export interface MarketInitData {
  'title' : Title,
  'probabilities' : Array<Probability>,
  'endDate' : Time,
  'labels' : Array<string>,
  'liquidity' : Balance,
  'description' : Description,
  'imageUrl' : Url,
}
export interface MarketResult {
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
  'kLast' : Balance,
  'totalShares' : Shares,
  'blockTimestampLast' : Time,
  'startDate' : Time,
}
export type MarketState = { 'resolved' : bigint } |
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
