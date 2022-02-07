import type { Principal } from '@dfinity/principal';
export type Description = string;
export type List = [] | [[Outcome, List]];
export interface Market {
  'id' : MarketId,
  'title' : Title,
  'description' : Description,
  'outcomes' : List,
}
export type MarketId = number;
export interface Outcome {
  'id' : MarketId,
  'probability' : Probability,
  'title' : Title,
}
export type Probability = number;
export type Title = string;
export interface _SERVICE {
  'create' : (arg_0: Market) => Promise<MarketId>,
  'delete' : (arg_0: MarketId) => Promise<boolean>,
  'read' : (arg_0: MarketId) => Promise<[] | [Market]>,
  'update' : (arg_0: MarketId, arg_1: Market) => Promise<boolean>,
}
