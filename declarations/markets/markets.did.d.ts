import type { Principal } from '@dfinity/principal';
export type Author = string;
export type Balance = bigint;
export type Description = string;
export interface Market {
  'addLiquidity' : (arg_0: MarketId, arg_1: Balance) => Promise<boolean>,
  'buyNo' : (arg_0: MarketId, arg_1: Balance) => Promise<[] | [Balance]>,
  'buyYes' : (arg_0: MarketId, arg_1: Balance) => Promise<[] | [Balance]>,
  'createMarket' : (arg_0: MarketInitData) => Promise<number>,
  'deleteAllMarkets' : () => Promise<undefined>,
  'deleteAllUsers' : () => Promise<undefined>,
  'deleteMarket' : (arg_0: MarketId) => Promise<boolean>,
  'getUser' : (arg_0: UserId) => Promise<UserResult>,
  'readAllMarkets' : () => Promise<Array<MarketResult>>,
  'readAllUsers' : () => Promise<Array<UserResult>>,
  'readMarket' : (arg_0: MarketId) => Promise<[] | [MarketResult]>,
  'removeLiquidity' : (arg_0: MarketId) => Promise<boolean>,
  'sellNo' : (arg_0: MarketId, arg_1: Balance) => Promise<[] | [Balance]>,
  'sellYes' : (arg_0: MarketId, arg_1: Balance) => Promise<[] | [Balance]>,
  'updateMarket' : (arg_0: MarketId, arg_1: MarketResult) => Promise<boolean>,
}
export type MarketId = number;
export interface MarketInitData {
  'title' : Title,
  'noProb' : Probability,
  'endDate' : Time,
  'liquidity' : Balance,
  'description' : Description,
  'yesProb' : Probability,
}
export interface MarketResult {
  'id' : MarketId,
  'title' : Title,
  'noProb' : Probability,
  'endDate' : Time,
  'liquidity' : Balance,
  'description' : Description,
  'author' : Author,
  'yesProb' : Probability,
  'reserveNo' : Balance,
  'providers' : Array<string>,
  'reserveYes' : Balance,
  'kLast' : Balance,
  'totalShares' : Shares,
  'blockTimestampLast' : Time,
  'startDate' : Time,
}
export type Probability = bigint;
export type Shares = bigint;
export type Time = bigint;
export type Title = string;
export type UserId = string;
export interface UserResult {
  'id' : UserId,
  'seerBalance' : Balance,
  'marketTokens' : Array<UserTokens>,
  'liquidityProviderFor' : Array<UserShares>,
}
export interface UserShares { 'shares' : Shares, 'marketId' : MarketId }
export interface UserTokens {
  'noBalance' : Balance,
  'marketId' : MarketId,
  'yesBalance' : Balance,
}
export interface _SERVICE extends Market {}
