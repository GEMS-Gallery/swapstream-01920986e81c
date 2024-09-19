export const idlFactory = ({ IDL }) => {
  const Balance = IDL.Float64;
  const TokenId = IDL.Text;
  return IDL.Service({
    'addLiquidity' : IDL.Func([Balance, Balance], [], []),
    'getLiquidityPoolBalances' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenId, Balance))],
        ['query'],
      ),
    'getUserBalances' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenId, Balance))],
        ['query'],
      ),
    'mintTokens' : IDL.Func([TokenId, Balance], [], []),
    'removeLiquidity' : IDL.Func([Balance, Balance], [], []),
    'swap' : IDL.Func([TokenId, TokenId, Balance], [Balance], []),
  });
};
export const init = ({ IDL }) => { return []; };
