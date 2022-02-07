export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const MarketId = IDL.Nat32;
  const Title = IDL.Text;
  const Description = IDL.Text;
  const Probability = IDL.Nat32;
  const Outcome = IDL.Record({
    'id' : MarketId,
    'probability' : Probability,
    'title' : Title,
  });
  List.fill(IDL.Opt(IDL.Tuple(Outcome, List)));
  const Market = IDL.Record({
    'id' : MarketId,
    'title' : Title,
    'description' : Description,
    'outcomes' : List,
  });
  return IDL.Service({
    'create' : IDL.Func([Market], [MarketId], []),
    'delete' : IDL.Func([MarketId], [IDL.Bool], []),
    'read' : IDL.Func([MarketId], [IDL.Opt(Market)], ['query']),
    'update' : IDL.Func([MarketId, Market], [IDL.Bool], []),
  });
};
export const init = ({ IDL }) => { return []; };
