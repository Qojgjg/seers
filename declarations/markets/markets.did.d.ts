import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

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
  'author' : UserData,
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
  'addCommentToMarket' : ActorMethod<[number, string], Result_5>,
  'buyOutcome' : ActorMethod<[number, number, bigint, boolean], Result_2>,
  'callerAccount' : ActorMethod<[], AccountIdentifier>,
  'canisterAccount' : ActorMethod<[], string>,
  'canisterFloat' : ActorMethod<[], ICP>,
  'createMarket' : ActorMethod<[MarketInitData], Result_4>,
  'createUser' : ActorMethod<[UserInitData], Result_3>,
  'getFeed' : ActorMethod<[], Array<Post>>,
  'getUserStable' : ActorMethod<[string], [] | [UserStable]>,
  'readAllMarkets' : ActorMethod<
    [MarketCategory, MarketState],
    Array<MarketStable>,
  >,
  'readAllUsers' : ActorMethod<[], Array<UserStable>>,
  'readMarket' : ActorMethod<[number], [] | [MarketStable]>,
  'readUserData' : ActorMethod<[Array<string>], Array<UserData>>,
  'refreshUser' : ActorMethod<[], Result_3>,
  'resolveMarket' : ActorMethod<[number, bigint], boolean>,
  'sellOutcome' : ActorMethod<[number, number, bigint, boolean], Result_2>,
  'setMarketState' : ActorMethod<[number, MarketState], boolean>,
  'setUpdating' : ActorMethod<[boolean], undefined>,
  'submitForecast' : ActorMethod<[number, Forecast], Result_1>,
  'submitPost' : ActorMethod<[string], Result>,
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
  'author' : UserData,
  'likes' : Array<Like>,
  'comments' : Array<Post>,
}
export type Result = { 'ok' : null } |
  { 'err' : UserError };
export type Result_1 = { 'ok' : null } |
  { 'err' : MarketError };
export type Result_2 = { 'ok' : number } |
  { 'err' : MarketError };
export type Result_3 = { 'ok' : UserStable } |
  { 'err' : UserError };
export type Result_4 = { 'ok' : MarketStable } |
  { 'err' : MarketError };
export type Result_5 = { 'ok' : CommentStable } |
  { 'err' : MarketError };
export type Time = bigint;
export interface UserData {
  'principal' : string,
  'name' : string,
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
export interface UserInitData {
  'id' : string,
  'age' : bigint,
  'bio' : string,
  'twitter' : string,
  'city' : string,
  'name' : string,
  'cover' : string,
  'website' : string,
  'picture' : string,
  'discord' : string,
  'handle' : string,
}
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
  'age' : bigint,
  'bio' : string,
  'txs' : Array<UserTx>,
  'expBalances' : Balance,
  'twitter' : string,
  'lastSeenAt' : Time,
  'modifiedAt' : Time,
  'city' : string,
  'feed' : Array<FeedItem>,
  'name' : string,
  'createdAt' : Time,
  'cover' : string,
  'markets' : Array<UserMarket>,
  'website' : string,
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
