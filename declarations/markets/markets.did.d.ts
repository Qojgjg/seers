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
export type CollateralType = { 'btc' : null } |
  { 'icp' : null } |
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
export interface DepositAddrs {
  'btc' : string,
  'icp' : string,
  'cycles' : string,
}
export type Error = { 'callerIsAnon' : null } |
  { 'userAlreadyExist' : null } |
  { 'notLoggedIn' : null } |
  { 'imageMissing' : null } |
  { 'profileNotCreated' : null } |
  { 'parentDoesNotExist' : null } |
  { 'notEnoughBalance' : null } |
  { 'postIsEmpty' : null } |
  { 'optionsMissing' : null } |
  { 'descriptionMissing' : null } |
  { 'marketNotFound' : null } |
  { 'titleMissing' : null } |
  { 'handleAlreadyTaken' : null } |
  { 'imageNotFound' : null } |
  { 'alreadyLiked' : null } |
  { 'lowerThanMinAmount' : null } |
  { 'marketMissing' : null } |
  { 'startDateOld' : null } |
  { 'marketNotOpen' : null } |
  { 'onlyAuthorCanEdit' : null } |
  { 'postDoesNotExist' : null } |
  { 'alreadyRetweeted' : null } |
  { 'commentIsEmpty' : null } |
  { 'userDoesNotExist' : null } |
  { 'endDateOld' : null } |
  { 'cantGetBalance' : null } |
  { 'newtonFailed' : null } |
  { 'endDateOlderThanStartDate' : null } |
  { 'notEnoughLiquidity' : null };
export type FeedItem = { 'bet' : Bet } |
  { 'post' : PostStable } |
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
export interface Like { 'createdAt' : Time, 'author' : UserData }
export interface Market {
  'accountBalance' : ActorMethod<[string], [] | [ICP]>,
  'addCommentToMarket' : ActorMethod<[number, string], Result_7>,
  'buyOutcome' : ActorMethod<[number, number, bigint, boolean], Result_1>,
  'callerAccount' : ActorMethod<[], AccountIdentifier>,
  'canisterAccount' : ActorMethod<[], string>,
  'canisterBalance' : ActorMethod<[], ICP>,
  'createMarket' : ActorMethod<[MarketInitData], Result_6>,
  'createUser' : ActorMethod<[UserInitData], Result_2>,
  'deleteAllUsers' : ActorMethod<[], boolean>,
  'editPost' : ActorMethod<[PostInitData, [] | [MarketInitData]], Result>,
  'editUser' : ActorMethod<[UserInitData], Result_2>,
  'getFeed' : ActorMethod<[], Array<PostStable>>,
  'getPost' : ActorMethod<[number], Result_5>,
  'getThread' : ActorMethod<[number], Result_4>,
  'getUserFromPrincipal' : ActorMethod<[string], Result_3>,
  'getUserStable' : ActorMethod<[string], [] | [UserStable]>,
  'getUserWithPosts' : ActorMethod<[string], Result_3>,
  'otherAccount' : ActorMethod<[], string>,
  'readAllMarkets' : ActorMethod<
    [MarketCategory, MarketState],
    Array<MarketStable>,
  >,
  'readAllUsers' : ActorMethod<[], Array<UserStable>>,
  'readMarket' : ActorMethod<[number], [] | [MarketStable]>,
  'readUserData' : ActorMethod<[Array<string>], Array<UserData>>,
  'refreshUser' : ActorMethod<[], Result_2>,
  'resolveMarket' : ActorMethod<[number, bigint], boolean>,
  'sellOutcome' : ActorMethod<[number, number, bigint, boolean], Result_1>,
  'setMarketState' : ActorMethod<[number, MarketState], boolean>,
  'setUpdating' : ActorMethod<[boolean], undefined>,
  'submitDelete' : ActorMethod<[number], Result>,
  'submitForecast' : ActorMethod<[number, Forecast], Result>,
  'submitLike' : ActorMethod<[number], Result>,
  'submitPost' : ActorMethod<[PostInitData, [] | [MarketInitData]], Result>,
  'submitRetweet' : ActorMethod<[number], Result>,
  'transferToCanister' : ActorMethod<[], string>,
  'transferToSubaccount' : ActorMethod<[], string>,
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
export interface ParentData { 'id' : number, 'author' : UserData }
export interface PostInitData {
  'id' : number,
  'retweet' : [] | [Retweet],
  'isRetweet' : [] | [UserData],
  'content' : string,
  'author' : UserData,
  'market' : [] | [MarketInitData],
  'image' : [] | [string],
  'parent' : [] | [ParentData],
}
export interface PostStable {
  'id' : number,
  'retweet' : [] | [Retweet],
  'isRetweet' : [] | [UserData],
  'deleted' : boolean,
  'content' : string,
  'createdAt' : Time,
  'author' : UserData,
  'likes' : Array<Like>,
  'replies' : Array<number>,
  'market' : [] | [MarketStable],
  'image' : [] | [string],
  'parent' : [] | [ParentData],
  'retweeters' : Array<UserData>,
}
export type Result = { 'ok' : null } |
  { 'err' : Error };
export type Result_1 = { 'ok' : number } |
  { 'err' : Error };
export type Result_2 = { 'ok' : UserStable } |
  { 'err' : Error };
export type Result_3 = { 'ok' : [UserStable, Array<PostStable>] } |
  { 'err' : Error };
export type Result_4 = { 'ok' : ThreadStable } |
  { 'err' : Error };
export type Result_5 = { 'ok' : PostStable } |
  { 'err' : Error };
export type Result_6 = { 'ok' : MarketStable } |
  { 'err' : Error };
export type Result_7 = { 'ok' : CommentStable } |
  { 'err' : Error };
export interface Retweet {
  'id' : number,
  'content' : string,
  'createdAt' : Time,
  'author' : UserData,
  'parent' : [] | [ParentData],
}
export interface ThreadStable {
  'main' : PostStable,
  'ancestors' : Array<PostStable>,
  'replies' : Array<PostStable>,
}
export type Time = bigint;
export interface UserData {
  'principal' : string,
  'name' : string,
  'picture' : string,
  'handle' : string,
}
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
  'retweets' : Array<number>,
  'expBalances' : Balance,
  'twitter' : string,
  'lastSeenAt' : Time,
  'modifiedAt' : Time,
  'city' : string,
  'feed' : Array<FeedItem>,
  'name' : string,
  'createdAt' : Time,
  'cover' : string,
  'locked' : Balance,
  'markets' : Array<UserMarket>,
  'website' : string,
  'likes' : Array<number>,
  'picture' : string,
  'replies' : Array<number>,
  'discord' : string,
  'handle' : string,
  'comments' : Array<CommentStable>,
  'posts' : Array<number>,
  'followees' : Array<Followee>,
  'followers' : Array<Follower>,
  'depositAddrs' : DepositAddrs,
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
