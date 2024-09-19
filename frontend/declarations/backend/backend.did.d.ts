import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type Balance = number;
export type TokenId = string;
export interface _SERVICE {
  'addLiquidity' : ActorMethod<[Balance, Balance], undefined>,
  'getLiquidityPoolBalances' : ActorMethod<[], Array<[TokenId, Balance]>>,
  'getUserBalances' : ActorMethod<[], Array<[TokenId, Balance]>>,
  'mintTokens' : ActorMethod<[TokenId, Balance], undefined>,
  'removeLiquidity' : ActorMethod<[Balance, Balance], undefined>,
  'swap' : ActorMethod<[TokenId, TokenId, Balance], Balance>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
