import type { Principal } from '@dfinity/principal';
export type Author = string;
export type Description = string;
export interface Market {
  'createMarket' : (arg_0: MarketInitData) => Promise<number>,
  'delete' : (arg_0: number) => Promise<boolean>,
  'deleteAll' : () => Promise<undefined>,
  'getUser' : () => Promise<[] | [User]>,
  'read' : (arg_0: number) => Promise<[] | [Market__1]>,
  'readAll' : () => Promise<Array<Market__1>>,
  'update' : (arg_0: number, arg_1: Market__1) => Promise<boolean>,
}
export interface MarketInitData {
  'title' : Title,
  'noProb' : number,
  'endDate' : Time,
  'liquidity' : number,
  'description' : Description,
  'yesProb' : number,
}
export interface Market__1 {
  'id' : number,
  'title' : Title,
  'noProb' : number,
  'endDate' : Time,
  'liquidity' : number,
  'description' : Description,
  'author' : Author,
  'yesProb' : number,
  'reserveNo' : number,
  'priceYesCumulativeLast' : number,
  'reserveYes' : number,
  'priceNoCumulativeLast' : number,
  'kLast' : number,
  'blockTimestampLast' : Time,
  'startDate' : Time,
}
export type Time = bigint;
export type Title = string;
export interface User {
  'id' : string,
  'seerBalance' : number,
  'liquidityProviderFor' : Array<[number, number]>,
}
export interface _SERVICE extends Market {}
