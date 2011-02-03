unit InhCaixaFechamentoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBXpress, DBClient, DBLocal, DBLocalS,
  InhBiblio, FMTBcd, InhCaixa;

type
  TCaixaFechamentoDM = class(TDataModule)
    PortaConsumoDSet: TSQLClientDataSet;
    FormaPagamentoDSet: TSQLClientDataSet;
    FormaPagamentoDSource: TDataSource;
    PortaConsumoDSource: TDataSource;
    ClientePendenteDSet: TSQLClientDataSet;
    ClientePendenteDSource: TDataSource;
    PortaConsumoDSetid: TIntegerField;
    PortaConsumoDSetnumero: TSmallintField;
    PortaConsumoDSetdono: TIntegerField;
    PortaConsumoDSetstatus: TStringField;
    PortaConsumoDSettipo: TStringField;
    PortaConsumoDSetdatahora: TSQLTimeStampField;
    PortaConsumoDSetusuario: TIntegerField;
    TotalConsumoDSet: TSQLClientDataSet;
    TotalConsumoDSource: TDataSource;
    TotalConsumoDSetdono: TIntegerField;
    PagoPreviamenteDSet: TSQLClientDataSet;
    PagoPreviamenteDSource: TDataSource;
    PagoPreviamenteDSetdono: TIntegerField;
    PagoPreviamenteDSetvalor: TFloatField;
    TotalConsumoDSetvalor: TFloatField;
    TotalConsumoDSettotal: TAggregateField;
    PagoPreviamenteDSettotal: TAggregateField;
    PendentesDSet: TSQLClientDataSet;
    PendentesDSource: TDataSource;
    PendentesDSetdatahora_inicial: TSQLTimeStampField;
    PendentesDSetnome: TStringField;
    PendentesDSettipo: TStringField;
    PendentesDSetid: TIntegerField;
    PortaConsumoDSettotal_consumo: TCurrencyField;
    PortaConsumoDSettotal_pagamento: TCurrencyField;
    PortaConsumoDSetdatahora_inicial: TSQLTimeStampField;
    procedure PortaConsumoDSetCalcFields(DataSet: TDataSet);
  private
  public
    procedure UpdateAll ();
    procedure TotalConsumoUpdateCommandText ();
    procedure PagoPreviamenteUpdateCommandText ();
    procedure FecharPendente (DonoId : String);
    procedure ExecutarFechamento (PortaConsumos : array of integer);
    function  ExecutarPagamentos (Pagamentos : TInhDBPayments) : boolean;

    function  DMOpen () : boolean;
    procedure DMClose();
  end;

function CaixaFechamentoDMNew (AOwner : TComponent) : TCaixaFechamentoDM;

implementation

uses InhMainDM, InhCaixaFechamento;

{$R *.xfm}

function CaixaFechamentoDMNew (AOwner : TComponent) : TCaixaFechamentoDM;
var
   MyDM : TCaixaFechamentoDM;
begin
   MyDM := TCaixaFechamentoDM.Create(AOwner);

   Result := MyDM;
end;

function TCaixaFechamentoDM.DMOpen() : boolean;
begin
   Self.PortaConsumoDSet.Params[0].Value := InhAccess.id;
   if (InhDataSetOpenMaster(Self.PortaConsumoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(Self.FormaPagamentoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   Self.UpdateAll;
   Result := True;
end;

procedure TCaixaFechamentoDM.DMClose ();
begin
   FormaPagamentoDSet.Close;
end;

procedure TCaixaFechamentoDM.UpdateAll ();
begin
   TotalConsumoUpdateCommandText ();
   PagoPreviamenteUpdateCommandText ();
end;

procedure TCaixaFechamentoDM.TotalConsumoUpdateCommandText ();
const
   ComandoInicial = ' SELECT dono, SUM(valor) as valor FROM consumo WHERE dono IN (';
   ComandoFormatoDados = '%s';
   ComandoSeparador = ', ';
   ComandoFinal = ') GROUP BY dono';
var
   Comando : String;
begin
   if (PortaConsumoDSet.RecordCount = 0) then
      begin
         TotalConsumoDSet.Close;
         exit;
      end;

   TotalConsumoDSet.Close;
   Comando := ComandoInicial;
   PortaConsumoDSet.First;

   while not PortaConsumoDSet.Eof do
      begin
         Comando := Comando + Format(ComandoFormatoDados, [PortaConsumoDSet.FieldByName('id').AsString]);
         if (PortaConsumoDset.RecNo < PortaConsumoDset.RecordCount) then
            Comando := Comando + ComandoSeparador;
         PortaConsumoDSet.Next;
      end;

   Comando := Comando + ComandoFinal;

   TotalConsumoDSet.CommandText := Comando;
   TotalCOnsumoDSet.Open;

   PortaConsumoDSet.First;
end;

procedure  TCaixaFechamentoDM.PagoPreviamenteUpdateCommandText ();
var
   Comando : String;
const
   ComandoInicial = 'SELECT dono, SUM(valor) as valor FROM porta_consumo_pagamento WHERE dono IN (';
   ComandoFormatoDados = '%s';
   ComandoSeparador = ', ';
   ComandoFinal = ') GROUP BY dono';
begin
   if (PortaConsumoDSet.RecordCount = 0) then
      begin
         PagoPreviamenteDSet.Close;
         exit;
      end;

   PagoPreviamenteDSet.Close;
   Comando := ComandoInicial;
   PortaConsumoDSet.First;

   while not PortaConsumoDSet.Eof do
      begin
         Comando := Comando + Format(ComandoFormatoDados, [PortaConsumoDSet.FieldByName('id').AsString]);
         if (PortaConsumoDset.RecNo < PortaConsumoDset.RecordCount) then
            Comando := Comando + ComandoSeparador;
         PortaConsumoDSet.Next;
      end;

   Comando := Comando + ComandoFinal;

   PagoPreviamenteDSet.CommandText := Comando;
   PagoPreviamenteDSet.Open;

   PortaConsumoDSet.First;
end;

procedure  TCaixaFechamentoDM.FecharPendente (DonoId : String);
var
   Comando : String;
   Query : TSQLDataSet;
const
   ComandoFormatoDados = '%s';
   ComandoSeparador = ', ';
   ComandoFinal = ')';
begin
   if (PortaConsumoDSet.RecordCount = 0) then
      begin
         TotalConsumoDSet.Close;
         exit;
      end;

   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;

   Comando := 'UPDATE porta_consumo SET dono = ' + DonoId +
              ', status = "Pendente" WHERE id IN (';

   PortaConsumoDSet.First;

   while not PortaConsumoDSet.Eof do
      begin
         Comando := Comando + Format(ComandoFormatoDados, [PortaConsumoDSet.FieldByName('id').AsString]);
         if (PortaConsumoDset.RecNo < PortaConsumoDset.RecordCount) then
            Comando := Comando + ComandoSeparador;
         PortaConsumoDSet.Next;
      end;

   Comando := Comando + ComandoFinal;
   Query.CommandText := Comando;
   Query.ExecSQL(True);
   Query.Free;

   PortaConsumoDSet.First;
end;

procedure TCaixaFechamentoDM.ExecutarFechamento (PortaConsumos : array of integer);
var
   Comando : String;
   Query : TSQLDataSet;
const
   ComandoInicial = 'UPDATE porta_consumo SET status = "Fechado", datahora_final = NOW() WHERE id IN (';
   ComandoFormatoDados = '%s';
   ComandoSeparador = ', ';
   ComandoFinal = ')';
begin
   if (Length (PortaConsumos) = 0) then exit;

   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;

   Comando := ComandoInicial + InhArrayOfIntToStrList (PortaConsumos, ', ') + ComandoFinal;

   Query.CommandText := Comando;
   Query.ExecSQL(True);
   Query.Free;
end;

procedure TCaixaFechamentoDM.PortaConsumoDSetCalcFields(DataSet: TDataSet);
var
   Key : String;
begin
   if (DataSet.RecordCount = 0) then exit;
   Key := DataSet.FieldByName('id').AsString;

   if (TotalConsumoDSet.Active = False) then exit;
   if (TotalConsumoDSet.Locate('dono', Key, []) and (TotalConsumoDSet.FieldByName('valor').AsFloat <> 0) ) then
      DataSet.FieldByName('total_consumos').AsFloat := TotalConsumoDSet.FieldByName('valor').AsFloat
   else
      DataSet.FieldByName('total_consumos').AsFloat := 0;

   if (PagoPreviamenteDset.Active = False) then exit;
   if (PagoPreviamenteDSet.Locate('dono', Key, []) and (PagoPreviamenteDSet.FieldByName('valor').AsFloat <> 0) ) then
      DataSet.FieldByName('total_pagamentos').AsFloat := PagoPreviamenteDSet.FieldByName('valor').AsFloat
   else
      DataSet.FieldByName('total_pagamentos').AsFloat := 0;
end;

function TCaixaFechamentoDM.ExecutarPagamentos (Pagamentos : TInhDBPayments) : boolean;
var
   PCPQ : TSQLDataSet;
   Comando : String;
   Contador : Integer;
const
   ComandoInicial = 'INSERT INTO porta_consumo_pagamento (dono, forma_pagamento, valor, usuario, datahora_inicial) ' +
                    'VALUES ';
   ComandoFormatoDados = '(%d, %d, "%f", %s, NOW())';
   ComandoSeparador = ', ';
   ComandoFinal = '';
begin
   PCPQ := TSQLDataSet.Create(MainDM.MainConnection);
   PCPQ.SQLConnection := MainDM.MainConnection;

   Comando := ComandoInicial;

   for Contador := 0 to High (Pagamentos) do
      begin
         Comando := Comando + Format (ComandoFormatoDados, [Pagamentos[Contador].PortaConsumo,
                                                            Pagamentos[Contador].FormaPagamento,
                                                            Pagamentos[Contador].Valor,
                                                            InhAccess.Id]);
         if Contador <> High (Pagamentos) then
            Comando := Comando + ComandoSeparador;
      end;

   Comando := Comando + ComandoFinal;

   PCPQ.CommandText := Comando;
   Result := (PCPQ.ExecSQL(True) > 0);
   PCPQ.Free;
end;

{
function TCaixaFechamentoDM.ExecutarPortaConsumoPagamentos (PortaConsumoPagamentos : TInhPortaConsumoPagamentos) : boolean;
var
   PCPQ : TSQLDataSet;
   Comando : String;
   Contador : Integer;
const
   ComandoInicial = 'INSERT INTO porta_consumo_pagamento (dono, forma_pagamento, valor, usuario) ' +
                    'VALUES ';
   ComandoFormatoDados = '(%d, %d, "%f", %s)';
   ComandoSeparador = ', ';
   ComandoFinal = '';
begin
   PCPQ := TSQLDataSet.Create(MainDM.MainConnection);
   PCPQ.SQLConnection := MainDM.MainConnection;

   Comando := ComandoInicial;

   for Contador := 0 to High (PortaConsumoPagamentos) do
      begin
         Comando := Comando + Format (ComandoFormatoDados, [PortaConsumoPagamentos[Contador].PortaConsumo,
                                                            PortaConsumoPagamentos[Contador].FormaPagamento,
                                                            PortaConsumoPagamentos[Contador].Valor,
                                                            InhAccess.Id]);
         if Contador <> High (PortaConsumoPagamentos) then
            Comando := Comando + ComandoSeparador;
      end;

   Comando := Comando + ComandoFinal;

   PCPQ.CommandText := Comando;
   Result := (PCPQ.ExecSQL(True) > 0);
   PCPQ.Free;
end;
}


end.
