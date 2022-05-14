import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = Array<number>;
export interface Balance {
  'btc' : number,
  'icp' : number,
  'seers' : number,
  'cycles' : number,
}
export interface Bet { 'tx' : UserTx, 'comment' : CommentStable }
export interface BrierScore { 'createdAt' : Time, 'score' : number }
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
export type DepositAddr = { 'btc' : string } |
  { 'icp' : string } |
  { 'cycles' : string };
export type FeedItem = { 'bet' : Bet } |
  { 'post' : Post } |
  { 'comment' : CommentStable } |
  { 'market' : MarketStable };
export interface Followee { 'createdAt' : Time, 'user' : string }
export interface Follower { 'createdAt' : Time, 'user' : string }
export type Forecast = Array<number>;
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
  'addCommentToMarket' : (arg_0: number, arg_1: string) => Promise<Result_4>,
  'buyOutcome' : (
      arg_0: number,
      arg_1: number,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result_1>,
  'callerAccount' : () => Promise<AccountIdentifier>,
  'canisterAccount' : () => Promise<string>,
  'canisterFloat' : () => Promise<ICP>,
  'createMarket' : (arg_0: MarketInitData) => Promise<Result_3>,
  'createUser' : (arg_0: string) => Promise<Result_2>,
  'getUserStable' : (arg_0: string) => Promise<[] | [UserStable]>,
  'readAllMarkets' : (arg_0: MarketCategory, arg_1: MarketState) => Promise<
      Array<MarketStable>
    >,
  'readAllUsers' : () => Promise<Array<UserStable>>,
  'readMarket' : (arg_0: number) => Promise<[] | [MarketStable]>,
  'readUserData' : (arg_0: Array<string>) => Promise<Array<UserData>>,
  'refreshUser' : () => Promise<Result_2>,
  'resolveMarket' : (arg_0: number, arg_1: bigint) => Promise<boolean>,
  'sellOutcome' : (
      arg_0: number,
      arg_1: number,
      arg_2: bigint,
      arg_3: boolean,
    ) => Promise<Result_1>,
  'setMarketState' : (arg_0: number, arg_1: MarketState) => Promise<boolean>,
  'setUpdating' : (arg_0: boolean) => Promise<undefined>,
  'submitForecast' : (arg_0: number, arg_1: Forecast) => Promise<Result>,
}
export type MarketCategory = { 'any' : null } |
  { 'entertainment' : null } |
  { 'self' : null } |
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
  'id' : number,
  'title' : string,
  'probabilities' : Array<number>,
  'endDate' : Time,
  'labels' : Array<string>,
  'liquidity' : number,
  'collateralType' : CollateralType,
  'description' : string,
  'author' : string,
  'imageUrl' : string,
  'category' : MarketCategory,
  'startDate' : Time,
  'images' : Array<string>,
}
export interface MarketStable {
  'k' : number,
  'id' : number,
  'forecasts' : Array<Forecast>,
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
export type MarketState = { 'any' : null } |
  { 'resolved' : bigint } |
  { 'closed' : null } |
  { 'pending' : null } |
  { 'invalid' : null } |
  { 'open' : null } |
  { 'approved' : null };
export interface Post {
  'id' : number,
  'content' : string,
  'createdAt' : Time,
  'author' : string,
  'likes' : Array<Like>,
  'comments' : Array<CommentStable>,
}
export type Result = { 'ok' : null } |
  { 'err' : MarketError };
export type Result_1 = { 'ok' : number } |
  { 'err' : MarketError };
export type Result_2 = { 'ok' : UserStable } |
  { 'err' : UserError };
export type Result_3 = { 'ok' : MarketStable } |
  { 'err' : MarketError };
export type Result_4 = { 'ok' : CommentStable } |
  { 'err' : MarketError };
export type Time = bigint;
export interface UserData {
  'principal' : string,
  'picture' : string,
  'handle' : string,
}
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
export interface UserMarket {
  'brierScores' : Array<BrierScore>,
  'title' : string,
  'shares' : number,
  'modifiedAt' : Time,
  'redeemed' : boolean,
  'labels' : Array<string>,
  'createdAt' : Time,
  'collateralType' : CollateralType,
  'author' : boolean,
  'spent' : number,
  'marketId' : number,
  'balances' : Array<number>,
}
export interface UserStable {
  'id' : string,
  'bio' : string,
  'txs' : Array<UserTx>,
  'expBalances' : Balance,
  'twitter' : string,
  'lastSeenAt' : Time,
  'modifiedAt' : Time,
  'feed' : Array<FeedItem>,
  'createdAt' : Time,
  'markets' : Array<UserMarket>,
  'picture' : string,
  'discord' : string,
  'handle' : string,
  'comments' : Array<CommentStable>,
  'posts' : Array<Post>,
  'followees' : Array<Followee>,
  'followers' : Array<Follower>,
  'depositAddrs' : Array<DepositAddr>,
  'balances' : Balance,
}
export interface UserTx {
  'id' : number,
  'fee' : number,
  'src' : [] | [bigint],
  'dest' : [] | [bigint],
  'createdAt' : Time,
  'recv' : number,
  'sent' : number,
  'marketId' : number,
  'price' : number,
}
export interface _SERVICE extends Market {}
