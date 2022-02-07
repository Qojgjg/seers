import type { Principal } from '@dfinity/principal';
export type Author = string;
export type Description = string;
export interface Market {
  'createMarket' : (arg_0: MarketInitData) => Promise<number>,
  'deleteAllMarkets' : () => Promise<undefined>,
  'deleteMarket' : (arg_0: number) => Promise<boolean>,
  'getUser' : () => Promise<[] | [User]>,
  'readAllMarkets' : () => Promise<Array<Market__1>>,
  'readMarket' : (arg_0: number) => Promise<[] | [Market__1]>,
  'updateMarket' : (arg_0: number, arg_1: Market__1) => Promise<boolean>,
}
export interface MarketInitData {
  'title' : Title,
  'noProb' : bigint,
  'endDate' : Time,
  'liquidity' : bigint,
  'description' : Description,
  'yesProb' : bigint,
}
export interface Market__1 {
  'id' : number,
  'title' : Title,
  'noProb' : bigint,
  'endDate' : Time,
  'liquidity' : bigint,
  'description' : Description,
  'author' : Author,
  'yesProb' : bigint,
  'reserveNo' : bigint,
  'reserveYes' : bigint,
  'kLast' : bigint,
  'blockTimestampLast' : Time,
  'startDate' : Time,
}
export type Time = bigint;
export type Title = string;
export interface User {
  'id' : string,
  'seerBalance' : bigint,
  'marketTokens' : Array<[bigint, bigint, bigint]>,
  'liquidityProviderFor' : Array<[bigint, bigint]>,
}
export interface _SERVICE extends Market {}
