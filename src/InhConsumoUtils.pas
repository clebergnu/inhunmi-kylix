unit InhConsumoUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhLogger;

procedure InhConsumoDelete (ConsumoId : integer; LogMessage : String);
function  InhConsumoDSetQuantidadeDescricaoValor(ConsumoDSet : TDataSet) : String;

implementation

uses InhDlgUtils;

procedure InhConsumoDelete (ConsumoId : integer; LogMessage : String);
begin
   if (InhDlgRecordDetailDeleteConfirmation('Consumo')) then
      begin
         InhDeleteFromTableWhereFieldValue ('consumo', 'id', IntToStr(ConsumoId));
         InhLog(ildConsumo, ConsumoId, iloDelecao, LogMessage, '');
     end;
end;

function InhConsumoDSetQuantidadeDescricaoValor(ConsumoDSet : TDataSet) : String;
begin
   Result := Format ('%u - %s - %f',
                     [ConsumoDSet.FieldByName('produto_quantidade').AsInteger,
                      Trim(Format('%-50s', [ConsumoDSet.FieldByName('produto_descricao').AsString])),
                      ConsumoDSet.FieldByName('valor').AsFloat]);
end;

end.
