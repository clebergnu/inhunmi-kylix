unit InhPortaConsumoUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhLogger, QStdCtrls;

const
   // itp -> Inhunmi Tipo Porta-Consumo
   itpCartao    = 1;
   itpMesa      = itpCartao + 1;
   itpBalcao    = itpMesa   + 1;
   itpEncomenda = itpBalcao + 1;

   itpDescricao : array[itpCartao..itpEncomenda] of string = ('Cartão',
                                                              'Mesa',
                                                              'Balcão',
                                                              'Encomenda');
type
TInhItp = itpCartao..itpEncomenda;


procedure InhPortaConsumoNovo (Tipo : TInhItp;
                               Dono : integer;
                               Numero: integer;
                               Usuario : integer);
function InhPortaConsumoDelete (PortaConsumoID : integer) : boolean;

procedure InhPortaConsumoTipoComboBoxPopulate (ComboBox : TComboBox);

implementation

uses InhDlgUtils;

procedure InhPortaConsumoNovo (Tipo : TInhItp;
                               Dono : integer;
                               Numero: integer;
                               Usuario : integer);
var
   Query : TSQLDataSet;
   NumeroStr : String;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   if Numero = 0 then NumeroStr := 'NULL'
   else NumeroStr := IntToStr(Numero);

   Query.CommandText := 'INSERT INTO porta_consumo (tipo, dono, numero, usuario, datahora_inicial) VALUES (' +
                        IntToStr(Tipo) + ', ' + IntToStr(Dono) + ', ' +
                        NumeroStr + ', ' + IntToStr(Usuario) + ', NULL' + ')';
   Query.ExecSQL(True);
   Query.Free;
end;

function InhPortaConsumoDelete (PortaConsumoID : integer) : boolean;
var
   Connection : TSQLConnection;

   Commands : array[0..2] of string;
   CurrentCommand : integer;

   StringId : string;
begin
   StringId := IntToStr(PortaConsumoID);

   Commands[0] := 'DELETE FROM porta_consumo_pagamento WHERE dono = ' + StringId;
   Commands[1] := 'DELETE FROM consumo WHERE dono = ' + StringId;
   Commands[2] := 'DELETE FROM porta_consumo WHERE id = ' + StringId;

   for CurrentCommand := Low(Commands) to High(Commands) do
      begin
         Connection := MainDM.MainConnection.CloneConnection;
         Connection.Execute(Commands[CurrentCommand], nil, nil);
      end;
   Result := True;
end;


procedure InhPortaConsumoTipoComboBoxPopulate (ComboBox : TComboBox);
var
   Contador : integer;
begin
   ComboBox.Items.Add('Todos');
   for Contador := itpCartao to itpEncomenda do
      ComboBox.Items.Add(itpDescricao[Contador]);
   ComboBox.ItemIndex := 0;
end;


end.
