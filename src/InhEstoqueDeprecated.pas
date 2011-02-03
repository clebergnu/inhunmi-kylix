unit InhEstoqueDeprecated;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhDlgUtils;


function InhEstoqueProdutoDSetPopulate (ProdutoID : Integer) : TClientDataSet;
procedure InhEstoqueProdutoCalculateDSet (DSet : TClientDataSet);


var
   AjusteQuery    : TSQLClientDataSet;
   ConsumoQuery   : TSQLClientDataSet;
   MovimentoQuery : TSQLClientDataSet;


implementation

function InhEstoqueProdutoCreateClientDataSet () : TClientDataSet;
var
   DSet : TClientDataSet;
begin
   Dset := TClientDataSet.Create(nil);

   Result := DSet;
end;

function InhEstoqueProdutoDSetPopulate (ProdutoID : Integer) : TClientDataSet;
var
   Matriz : TSQLClientDataSet;
   DSet   : TClientDataSet;
   CamposExtras : String;
begin
   Matriz := TSQLClientDataSet.Create(MainDM.MainConnection);
   Matriz.DBConnection := MainDM.MainConnection;

   CamposExtras :=       '00000000 as ajuste, ' +
                         '00000000 as ajuste_id, ' +
                         '00000000 as consumo, ' +
                         '00000000 as movimento_entrada, ' +
                         '00000000 as movimento_saida, ' +
                         '00000000 as saldo ';

   Matriz.CommandText := '(SELECT consumo.produto AS produto, ' +
	                 'consumo.departamento_venda AS departamento, ' + CamposExtras +
                         'FROM consumo WHERE consumo.departamento_venda IS NOT NULL) ' +

                         'UNION ' +

                         '(SELECT estoque_ajuste_produto.produto AS produto, ' +
                         'estoque_ajuste_produto.departamento AS departamento, ' + CamposExtras +
                         'FROM estoque_ajuste_produto WHERE estoque_ajuste_produto.departamento IS NOT NULL) ' +

                         'UNION ' +

                         '(SELECT estoque_movimento_produto.produto AS produto, ' +
                         'estoque_movimento_produto.departamento_origem AS departamento, ' + CamposExtras +
                         'FROM estoque_movimento_produto ' +
                         'WHERE estoque_movimento_produto.departamento_origem IS NOT NULL) ' +

                         'UNION ' +

                         '(SELECT estoque_movimento_produto.produto AS produto, ' +
                         'estoque_movimento_produto.departamento_destino AS departamento, ' + CamposExtras +
                         'FROM estoque_movimento_produto WHERE estoque_movimento_produto.departamento_destino IS NOT NULL) ' +

                         'ORDER BY produto, departamento';

   Matriz.Open;

   DSet := InhEstoqueProdutoCreateClientDataSet;

   DSet.Data := Matriz.Data;

   Matriz.Close;
   FreeAndNil(Matriz);

   Result := DSet;
end;

procedure InhEstoqueProdutoGetUltimoAjuste (ProdutoID : Integer;
                                           DepartamentoID : Integer;
                                           var Quantidade : Integer;
                                           var AjusteID : Integer);
begin
   AjusteQuery.CommandText := 'SELECT id, quantidade FROM estoque_ajuste_produto ' +
                              'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                              'AND departamento = ' + IntToStr(DepartamentoID) + ' ' +
                              'ORDER BY datahora DESC LIMIT 1';
   AjusteQuery.Open;

   if AjusteQuery.RecordCount = 0 then
      begin
         Quantidade := 0;
         AjusteID := 0;
      end
   else
      begin
         Quantidade := AjusteQuery.FieldByName('quantidade').AsInteger;
         AjusteID := AjusteQuery.FieldByName('id').AsInteger;
      end;

   AjusteQuery.Close;
end;

function InhEstoqueProdutoGetConsumos (ProdutoID : Integer;
                                       DepartamentoID : Integer;
                                       AjusteID : Integer) : Integer;
begin
   if (AjusteID = 0) then
      begin
         ConsumoQuery.CommandText := 'SELECT SUM(produto_quantidade) as quantidade FROM consumo ' +
                                     'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                                     'AND departamento_venda = ' + IntToStr(DepartamentoID);
      end
   else
      begin
         ConsumoQuery.CommandText := 'SELECT SUM(consumo.produto_quantidade) as quantidade FROM consumo, estoque_ajuste_produto ' +
                                     'WHERE (consumo.produto = ' + IntToStr(ProdutoID) + ') ' +
                                     'AND (consumo.departamento_venda = ' + IntToStr(DepartamentoID) + ') ' +
                                     'AND (estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') ' +
                                     'AND (consumo.datahora_inicial > estoque_ajuste_produto.datahora)';
      end;

   ConsumoQuery.Open;

   if ConsumoQuery.RecordCount = 0 then
      Result := 0
   else
      Result := ConsumoQuery.FieldByName('quantidade').AsInteger;

   ConsumoQuery.Close;
end;


function InhEstoqueProdutoGetMovimentosEntrada (ProdutoID : Integer;
                                                DepartamentoID : Integer;
                                                AjusteID : Integer) : Integer;
begin
   if (AjusteID = 0) then
      begin
         MovimentoQuery.CommandText := 'SELECT SUM(estoque_movimento_produto.quantidade) as quantidade_entrada FROM estoque_movimento_produto ' +
                                       'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                                       'AND departamento_destino = ' + IntToStr(DepartamentoID);
      end
   else
      begin
         MovimentoQuery.CommandText := 'SELECT SUM(estoque_movimento_produto.quantidade) as quantidade_entrada FROM estoque_movimento_produto, estoque_ajuste_produto ' +
                                       'WHERE estoque_movimento_produto.produto = ' + IntToStr(ProdutoID) + ' ' +
                                       'AND estoque_movimento_produto.departamento_destino = ' + IntToStr(DepartamentoID) + ' ' +
                                       'AND (estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') ' +
                                       'AND (estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora)';
      end;

   MovimentoQuery.Open;

   if MovimentoQuery.RecordCount = 0 then
      Result := 0
   else
      Result := MovimentoQuery.FieldByName('quantidade_entrada').AsInteger;

   MovimentoQuery.Close;
end;

function InhEstoqueProdutoGetMovimentosSaida (ProdutoID : Integer;
                                              DepartamentoID : Integer;
                                              AjusteID : Integer) : Integer;
begin
   if (AjusteID = 0) then
      begin
         MovimentoQuery.CommandText := 'SELECT SUM(estoque_movimento_produto.quantidade) as quantidade_saida FROM estoque_movimento_produto ' +
                                       'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                                       'AND departamento_origem = ' + IntToStr(DepartamentoID);
      end
   else
      begin
         MovimentoQuery.CommandText := 'SELECT SUM(estoque_movimento_produto.quantidade) as quantidade_saida FROM estoque_movimento_produto, estoque_ajuste_produto ' +
                                       'WHERE estoque_movimento_produto.produto = ' + IntToStr(ProdutoID) + ' ' +
                                       'AND estoque_movimento_produto.departamento_origem = ' + IntToStr(DepartamentoID) + ' ' +
                                       'AND (estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') ' +
                                       'AND (estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora)';
      end;

   MovimentoQuery.Open;

   if MovimentoQuery.RecordCount = 0 then
      Result := 0
   else
      Result := MovimentoQuery.FieldByName('quantidade_saida').AsInteger;

   MovimentoQuery.Close;
end;


procedure InhEstoqueProdutoCalculateDSet (DSet : TClientDataSet);
var
   AjusteQuantidade : Integer;
   AjusteID : Integer;
begin
   DSet.First;

   // Inicializa TSQLClientDataSets usados nas funcoes acima:
   AjusteQuery    := TSQLClientDataSet.Create(nil);
   AjusteQuery.DBConnection := MainDM.MainConnection;
   ConsumoQuery   := TSQLClientDataSet.Create(nil);
   ConsumoQuery.DBConnection := MainDM.MainConnection;
   MovimentoQuery := TSQLClientDataSet.Create(nil);
   MovimentoQuery.DBConnection := MainDM.MainConnection;

   while not DSet.Eof do
      begin
         DSet.Edit;
         // AJUSTE
         InhEstoqueProdutoGetUltimoAjuste (DSet.FieldByName('produto').AsInteger,
                                           DSet.FieldByName('departamento').AsInteger,
                                           AjusteQuantidade, AjusteID);

         DSet.FieldByName('ajuste').AsInteger := AjusteQuantidade;
         DSet.FieldByName('ajuste_id').AsInteger := AjusteID;

         // CONSUMO
         DSet.FieldByName('consumo').AsInteger := InhEstoqueProdutoGetConsumos(DSet.FieldByName('produto').AsInteger,
                                                                               DSet.FieldByName('departamento').AsInteger,
                                                                               DSet.FieldByName('ajuste_id').AsInteger);

         // MOVIMENTO ENTRADA
         DSet.FieldByName('movimento_entrada').AsInteger := InhEstoqueProdutoGetMovimentosEntrada (DSet.FieldByName('produto').AsInteger,
                                                                                                   DSet.FieldByName('departamento').AsInteger,
                                                                                                   DSet.FieldByName('ajuste_id').AsInteger);

         // MOVIMENTO SAIDA
         DSet.FieldByName('movimento_saida').AsInteger := InhEstoqueProdutoGetMovimentosSaida (DSet.FieldByName('produto').AsInteger,
                                                                                               DSet.FieldByName('departamento').AsInteger,
                                                                                               DSet.FieldByName('ajuste_id').AsInteger);

         // SALDO
         DSet.FieldByName('saldo').AsInteger := DSet.FieldByName('ajuste').AsInteger
                                                - DSet.FieldByName('consumo').AsInteger
                                                + DSet.FieldByName('movimento_entrada').AsInteger
                                                - DSet.FieldByName('movimento_saida').AsInteger;

         DSet.Post;
         DSet.Next;
       end;

   // Dá cabo nos TSQLClientDataSets
   FreeAndNil(AjusteQuery);
   FreeAndNil(ConsumoQuery);
   FreeAndNil(MovimentoQuery);

   DSet.First;
end;

end.
