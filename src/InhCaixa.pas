unit InhCaixa;

interface

type TInhUserPayment = record
   FormaPagamento : integer;
   FormaPagamentoDescricao : string[40];
   Valor : real;
   TipoTrocoNormal : boolean;
end;

type TInhUserPayments = array of TInhUserPayment;

type TInhDBPayment = record
   PortaConsumo : integer;
   FormaPagamento : integer;
   Valor : real;
end;

type TInhDBPayments = array of TInhDBPayment;

implementation

end.
