import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = Array<number>;
export type Balance = { 'btc' : number } |
  { 'icp' : number } |
  { 'seers' : number } |
  { 'cycles' : number };
export interface Bet { 'tx' : UserTx, 'comment' : Comment__1 }
export interface BrierScore { 'createdAt' : Time, 'score' : number }
export type CollateralType = { 'icp' : null } |
  { 'seers' : null } |
  { 'cycles' : null };
export interface Comment {
  'id' : number,
  'content' : string,
  'createdAt' : Time,
  'user' : UserData,
  'likes' : Array<Like>,
}
export interface Comment__1 {
  'id' : number,
  'content' : string,
  'createdAt' : Time,
  'user' : UserData,
  'likes' : Array<Like__1>,
}
export type DepositAddr = { 'btc' : string } |
  { 'icp' : string } |
  { 'cycles' : string };
export type FeedItem = { 'bet' : Bet } |
  { 'post' : Post } |
  { 'comment' : Comment__1 } |
  { 'market' : MarketStable };
export interface Followee { 'createdAt' : Time, 'user' : UserData }
export interface Follower { 'createdAt' : Time, 'user' : UserData }
export interface HistPoint {
  'probabilities' : Array<number>,
  'createdAt' : Time,
  'liquidity' : number,
}
export interface ICP { 'e8s' : bigint }
export interface Like {
  'authorPicture' : string,
  'createdAt' : Time,
  'stars' : number,
  'authorHandle' : string,
  'authorPrincipal' : string,
}
export interface Like__1 {
  'authorPicture' : string,
  'createdAt' : Time,
  'stars' : number,
  'authorHandle' : string,
  'authorPrincipal' : string,
}
export interface Market {
  'approveMarket' : (arg_0: number) => Promise<undefined>,
  'callerAccount' : () => Promise<AccountIdentifier>,
  'canisterAccount' : () => Promise<string>,
  'canisterFloat' : () => Promise<ICP>,
  'createMarket' : (arg_0: MarketInitData) => Promise<Result_1>,
  'createUser' : (arg_0: string) => Promise<Result>,
  'getUserStable' : (arg_0: string) => Promise<[] | [UserStable]>,
  'readAllUsers' : () => Promise<Array<UserStable>>,
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
  'comments' : Array<Comment__1>,
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
export interface Post {
  'id' : number,
  'content' : string,
  'createdAt' : Time,
  'author' : UserData,
  'likes' : Array<Like__1>,
  'comments' : Array<Comment__1>,
}
export interface Post__1 {
  'id' : number,
  'content' : string,
  'createdAt' : Time,
  'author' : UserData,
  'likes' : Array<Like>,
  'comments' : Array<Comment>,
}
export type Result = { 'ok' : UserStable } |
  { 'err' : UserError };
export type Result_1 = { 'ok' : MarketStable } |
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
  'expBalances' : Array<Balance>,
  'twitter' : string,
  'lastSeenAt' : Time,
  'modifiedAt' : Time,
  'feed' : Array<FeedItem>,
  'createdAt' : Time,
  'markets' : Array<UserMarket>,
  'picture' : string,
  'discord' : string,
  'handle' : string,
  'comments' : Array<Comment>,
  'posts' : Array<Post__1>,
  'followees' : Array<Followee>,
  'followers' : Array<Follower>,
  'depositAddrs' : Array<DepositAddr>,
  'balances' : Array<Balance>,
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
