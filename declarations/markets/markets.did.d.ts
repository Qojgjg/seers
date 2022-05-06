import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = Array<number>;
export type CollateralType = { 'icp' : null } |
  { 'seers' : null } |
  { 'cycles' : null };
export interface CommentStable {
  'id' : number,
  'content' : string,
  'modifiedAt' : Time,
  'createdAt' : Time,
  'author' : string,
  'likes' : Array<Like>,
}
export interface HistPoint {
  'probabilities' : Array<number>,
  'createdAt' : Time,
  'liquidity' : number,
}
export interface ICP { 'e8s' : bigint }
export interface Like {
  'createdAt' : Time,
  'author' : string,
  'stars' : number,
}
export interface Market {
  'addCommentToMarket' : (arg_0: number, arg_1: string) => Promise<Result_2>,
  'approveMarket' : (arg_0: number) => Promise<undefined>,
  'callerAccount' : () => Promise<AccountIdentifier>,
  'canisterAccount' : () => Promise<string>,
  'canisterFloat' : () => Promise<ICP>,
  'createMarket' : (arg_0: MarketInitData) => Promise<Result_1>,
  'createUser' : (arg_0: string) => Promise<Result>,
  'getUserStable' : (arg_0: string) => Promise<[] | [UserStable]>,
  'readAllMarkets' : () => Promise<Array<MarketStable>>,
  'readAllUsers' : () => Promise<Array<UserStable>>,
  'readMarket' : (arg_0: number) => Promise<[] | [MarketStable]>,
  'resolveMarket' : (arg_0: number, arg_1: bigint) => Promise<boolean>,
  'setUpdating' : (arg_0: boolean) => Promise<undefined>,
}
export type MarketCategory = { 'entertainment' : null } |
  { 'seers' : null } |
  { 'crypto' : null } |
  { 'business' : null } |
  { 'financial' : null } |
  { 'sports' : null } |
  { 'dfinity' : null } |
  { 'science' : null } |
  { 'politics' : null };
export type MarketError = { 'callerIsAnon' : null } |
  { 'minimalAmountIsOne' : null } |
  { 'userAlreadyExist' : null } |
  { 'imageMissing' : null } |
  { 'profileNotCreated' : null } |
  { 'notEnoughBalance' : null } |
  { 'optionsMissing' : null } |
  { 'descriptionMissing' : null } |
  { 'titleMissing' : null } |
  { 'marketMissing' : null } |
  { 'startDateOld' : null } |
  { 'marketNotOpen' : null } |
  { 'commentIsEmpty' : null } |
  { 'endDateOld' : null } |
  { 'newtonFailed' : null } |
  { 'endDateOlderThanStartDate' : null } |
  { 'notEnoughLiquidity' : number };
export interface MarketInitData {
  'title' : string,
  'probabilities' : Array<number>,
  'endDate' : Time,
  'labels' : Array<string>,
  'liquidity' : number,
  'collateralType' : CollateralType,
  'description' : string,
  'nextId' : number,
  'author' : string,
  'imageUrl' : string,
  'category' : MarketCategory,
  'startDate' : Time,
  'images' : Array<string>,
}
export interface MarketStable {
  'k' : number,
  'id' : number,
  'title' : string,
  'histPrices' : Array<HistPoint>,
  'probabilities' : Array<number>,
  'endDate' : Time,
  'modifiedAt' : Time,
  'labels' : Array<string>,
  'createdAt' : Time,
  'liquidity' : number,
  'reserves' : Array<number>,
  'collateralType' : CollateralType,
  'description' : string,
  'volume' : number,
  'bettors' : Array<string>,
  'author' : string,
  'state' : MarketState,
  'imageUrl' : string,
  'category' : MarketCategory,
  'providers' : Array<string>,
  'comments' : Array<CommentStable>,
  'totalShares' : number,
  'startDate' : Time,
  'images' : Array<string>,
}
export type MarketState = { 'resolved' : bigint } |
  { 'closed' : null } |
  { 'pending' : null } |
  { 'invalid' : null } |
  { 'open' : null } |
  { 'approved' : null };
export type Result = { 'ok' : UserStable } |
  { 'err' : UserError };
export type Result_1 = { 'ok' : MarketStable } |
  { 'err' : MarketError };
export type Result_2 = { 'ok' : CommentStable } |
  { 'err' : MarketError };
export type Time = bigint;
export type UserError = { 'callerIsAnon' : null } |
  { 'minimalAmountIsOne' : null } |
  { 'userAlreadyExist' : null } |
  { 'imageMissing' : null } |
  { 'profileNotCreated' : null } |
  { 'notEnoughBalance' : null } |
  { 'optionsMissing' : null } |
  { 'descriptionMissing' : null } |
  { 'titleMissing' : null } |
  { 'marketMissing' : null } |
  { 'startDateOld' : null } |
  { 'marketNotOpen' : null } |
  { 'commentIsEmpty' : null } |
  { 'endDateOld' : null } |
  { 'newtonFailed' : null } |
  { 'endDateOlderThanStartDate' : null } |
  { 'notEnoughLiquidity' : number };
export interface UserStable {
  'id' : string,
  'bio' : string,
  'twitter' : string,
  'lastSeenAt' : Time,
  'modifiedAt' : Time,
  'createdAt' : Time,
  'picture' : string,
  'discord' : string,
  'handle' : string,
}
export interface _SERVICE extends Market {}
