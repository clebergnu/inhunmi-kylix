unit InhEstoqueUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhDlgUtils;

function InhEstoqueCalcula (Ajuste           : Integer;
                            MovimentoEntrada : Integer;
                            MovimentoSaida   : Integer;
                            Consumo          : Integer) : Integer;      

// MATRIZES
function InhEstoqueMatrizProdutoDepartamento (ProdutoID : Integer;
                                              ProdutoGrupoID : Integer) : TClientDataSet;
function InhEstoqueMatrizDescritivaAjuste(ProdutoDeptoDSet : TClientDataSet) : TClientDataSet;
function InhEstoqueMatrizDescritivaMovimentoEntrada(ProdutoDeptoDSet : TClientDataSet;
                                                    AjusteDSet       : TClientDataSet) : TClientDataSet;
function InhEstoqueMatrizDescritivaMovimentoSaida(ProdutoDeptoDSet : TClientDataSet;
                                                  AjusteDSet       : TClientDataSet) : TClientDataSet;
function InhEstoqueMatrizDescritivaConsumo (ProdutoDeptoDSet : TClientDataSet;
                                            AjusteDSet       : TClientDataSet) : TClientDataSet;

// "GET" Functions                                            
function InhEstoqueMatrizMovimentoGetQuantidade (MovimentoDSet  : TClientDataSet;
                                                 ProdutoID      : Integer;
                                                 DepartamentoID : Integer) : Integer;

// ietm -> Inhunmi Estoque Tipo Movimento
const
   ietmEntrada       = 0;
   ietmSaida         = ietmEntrada + 1;
   ietmTransferencia = ietmSaida + 1;
   ietmAjuste        = ietmTransferencia + 1;

type
   TInhEstoqueTipoMovimento = ietmEntrada..ietmAjuste;

// Utility Functions
function InhEstoqueGetTipoMovimentoDesc (Tipo : TInhEstoqueTipoMovimento) : String;

implementation

///////////////////////////////////////////////////////////////////////
// InhEstoqueMatrizProdutoDepartamento :
///////////////////////////////////////////////////////////////////////
// Retorna uma matriz simples de Produto x Departamento, quando estes
// forem relevantes para calculo de estoque, ou seja, existirem em
// consumo, estoque_ajuste_produto ou estoque_movimento_produto
///////////////////////////////////////////////////////////////////////
function InhEstoqueMatrizProdutoDepartamento (ProdutoID : Integer;
                                              ProdutoGrupoID : Integer) : TClientDataSet;
var
   Query : TSQLClientDataSet;
   DSet  : TClientDataSet;
   WhereProduto : String;
   WhereProdutoGrupo : String;
begin
   Query := TSQLCLientDataSet.Create(nil);
   Query.DBConnection := MainDM.MainConnection;

   DSet := TClientDataSet.Create(nil);

   ////////////////////////////////////////////////////////////////////////
   // Se ProdutoID não for 0, limitar query a produto especificado
   ////////////////////////////////////////////////////////////////////////
   if (ProdutoID > 0) then
      WhereProduto := '(produto = ' + IntToStr(ProdutoID) + ') AND '
   else
      WhereProduto := '';

   ////////////////////////////////////////////////////////////////////////
   // Se ProdutoGrupoID não for 0, limitar query a produtos do grupo
   // especificado
   ////////////////////////////////////////////////////////////////////////
   if (ProdutoGrupoID > 0) then
      WhereProdutoGrupo := '(produto.grupo = ' + IntToStr(ProdutoGrupoID) + ') AND '
   else
      WhereProdutoGrupo := '';

   Query.CommandText := '(SELECT consumo.produto AS produto_id, ' +
                        'produto.descricao as produto, ' +
	                'consumo.departamento_venda AS departamento_id, ' +
                        'departamento.nome as departamento ' +
                        'FROM consumo, produto, departamento WHERE ' +
                         WhereProduto +
                         WhereProdutoGrupo +
                        '(produto.id = consumo.produto) AND ' +
                        '(departamento.id = consumo.departamento_venda)) ' +

                        'UNION ' +

                        '(SELECT estoque_ajuste_produto.produto AS produto_id, ' +
                        'produto.descricao as produto, ' +
                        'estoque_ajuste_produto.departamento AS departamento_id, ' +
                        'departamento.nome as departamento ' +
                        'FROM estoque_ajuste_produto, produto, departamento WHERE ' +
                         WhereProduto +
                         WhereProdutoGrupo +
                        '(produto.id = estoque_ajuste_produto.produto) AND ' +
                        '(departamento.id = estoque_ajuste_produto.departamento)) ' +

                        'UNION ' +

                        '(SELECT estoque_movimento_produto.produto AS produto_id, ' +
                        'produto.descricao as produto, ' +
                        'estoque_movimento_produto.departamento_origem AS departamento_id, ' +
                        'departamento.nome as departamento ' +
                        'FROM estoque_movimento_produto, produto, departamento WHERE ' +
                         WhereProduto +
                         WhereProdutoGrupo +
                        '(produto.id = estoque_movimento_produto.produto) AND ' +
                        '(departamento.id = estoque_movimento_produto.departamento_origem)) ' +

                        'UNION ' +

                        '(SELECT estoque_movimento_produto.produto AS produto_id, ' +
                        'produto.descricao as produto, ' +
                        'estoque_movimento_produto.departamento_destino AS departamento_id, ' +
                        'departamento.nome as departamento ' +
                        'FROM estoque_movimento_produto, produto, departamento WHERE ' +
                         WhereProduto +
                         WhereProdutoGrupo +
                        '(produto.id = estoque_movimento_produto.produto) AND ' +
                        '(departamento.id = estoque_movimento_produto.departamento_destino)) ' +
 
                        'ORDER BY produto_id, departamento_id';

   Query.Open;
   DSet.Data := Query.Data;
   Query.Close;

   FreeAndNil(Query);

   Result := DSet;
end;

///////////////////////////////////////////////////////////////////////
// InhEstoqueMatrizDescritivaAjuste :
///////////////////////////////////////////////////////////////////////
// Retorna uma matriz com dados relevantes e descritivos
// do ajuste dos produtos e departamentos, listados em
// ProdutoDeptoDSet.
///////////////////////////////////////////////////////////////////////
function InhEstoqueMatrizDescritivaAjuste(ProdutoDeptoDSet : TClientDataSet) : TClientDataSet;
var
   Query : TSQLClientDataSet;
   DSet  : TClientDataSet;
   QueryFormat : String;
begin
   Query := TSQLCLientDataSet.Create(nil);
   Query.DBConnection := MainDM.MainConnection;

   DSet := TClientDataSet.Create(nil);

   QueryFormat := 'SELECT ' +
                  'estoque_ajuste_produto.id, ' +
                  'estoque_ajuste_produto.grupo, ' +
                  'estoque_ajuste_produto.produto as produto_id, ' +
                  'produto.descricao as produto, ' +
                  'estoque_ajuste_produto.departamento as departamento_id, ' +
                  'departamento.nome as departamento, ' +
                  'estoque_ajuste_produto.quantidade, ' +
                  'estoque_ajuste_produto.datahora, ' +
                  'estoque_ajuste_produto.observacao, ' +
                  'acesso.usuario as usuario ' +
                  'FROM ' +
                  'estoque_ajuste_produto, produto, departamento, acesso ' +
                  'WHERE ' +
                  '(produto.id = %u AND departamento.id = %u) AND ' +
                  '(estoque_ajuste_produto.produto = produto.id) AND ' +
                  '(estoque_ajuste_produto.departamento = departamento.id) AND ' +
                  '(estoque_ajuste_produto.usuario = acesso.id) ' +
                  'ORDER BY estoque_ajuste_produto.datahora DESC LIMIT 1';

   if (ProdutoDeptoDSet.RecordCount > 1) then
      begin
         QueryFormat := '(' + QueryFormat + ')';
         ProdutoDeptoDSet.First;

         while not ProdutoDeptoDSet.Eof do
            begin
               Query.CommandText := Query.CommandText + Format(QueryFormat, [ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                                             ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
               if (ProdutoDeptoDSet.RecordCount <> ProdutoDeptoDSet.RecNo) then
                  Query.CommandText := Query.CommandText + ' UNION '
               else
                  Query.CommandText := Query.CommandText + ' ORDER BY produto_id, departamento_id';

               ProdutoDeptoDSet.Next;
            end;
      end
   else if (ProdutoDeptoDSet.RecordCount = 1) then
      begin
         Query.CommandText := Query.CommandText + Format(QueryFormat, [ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                                       ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
      end;

   Query.Open;

   ProdutoDeptoDSet.First;

   DSet.Data := Query.Data;
   DSet.AddIndex('produto_departamento_index',
                 'produto_id;departamento_id',
                 [], '', '', 0);
   DSet.IndexName := 'produto_departamento_index';

   Query.Close;
   FreeAndNil(Query);

   Result := DSet;
end;

function GetAjusteID (AjusteDSet     : TClientDataSet;
                      ProdutoID      : Integer;
                      DepartamentoID : Integer) : Integer;
begin
   if (AjusteDSet.FindKey([ProdutoID, DepartamentoID])) then
      Result := AjusteDSet.FieldByName('id').AsInteger
   else
      Result := 0;
end;


///////////////////////////////////////////////////////////////////////
// InhEstoqueMatrizDescritivaMovimentoEntrada :
///////////////////////////////////////////////////////////////////////
// Retorna uma matriz com dados relevantes e descritivos
// dos movimentos de produtos, levando em conta o departamento
// destino.
///////////////////////////////////////////////////////////////////////
function InhEstoqueMatrizDescritivaMovimentoEntrada(ProdutoDeptoDSet : TClientDataSet;
                                                    AjusteDSet       : TClientDataSet) : TClientDataSet;
var
   Query : TSQLClientDataSet;
   DSet  : TClientDataSet;
   QueryFormat : String;

   AjusteID : Integer;
   FromAjuste  : String;
   WhereAjuste : String;
begin
   Query := TSQLCLientDataSet.Create(nil);
   Query.DBConnection := MainDM.MainConnection;

   DSet := TClientDataSet.Create(nil);

   QueryFormat := 'SELECT ' +
                  'estoque_movimento_produto.id, ' +
                  'estoque_movimento_produto.grupo, ' +
                  'estoque_movimento_produto.produto as produto_id, ' +
                  'produto.descricao as produto, ' +
                  'estoque_movimento_produto.departamento_destino as departamento_id, ' +
                  'departamento.nome as departamento, ' +
                  'estoque_movimento_produto.quantidade, ' +
                  'estoque_movimento_produto.observacao as observacao, ' +
                  'estoque_movimento_produto.datahora, ' +
                  'acesso.usuario as usuario ' +
                  'FROM ' +
                  '%s ' + // From estoque_ajuste_produto
                  'estoque_movimento_produto, produto, departamento, acesso ' +
                  'WHERE ' +
                  '%s ' + // Where estoque_ajuste_produto
                  '(produto.id = %u AND departamento.id = %u) AND ' +
                  '(estoque_movimento_produto.produto = produto.id) AND ' +
                  '(estoque_movimento_produto.departamento_destino = departamento.id) AND ' +

                  // departamento_origem = NULL para excluir transferencias
                  //'(estoque_movimento_produto.departamento_origem IS NULL) AND ' +

                  '(estoque_movimento_produto.usuario = acesso.id) ';

   ProdutoDeptoDSet.First;
   AjusteDSet.First;

   if (ProdutoDeptoDSet.RecordCount > 1) then
      begin
         QueryFormat := '(' + QueryFormat + ')';

         while not ProdutoDeptoDSet.Eof do
            begin
               AjusteID := GetAjusteID(AjusteDSet,
                                       ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                       ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger);

               if (AjusteID <> 0) then
                  begin
                     FromAjuste  := 'estoque_ajuste_produto, ';
                     WhereAjuste := '(estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora) AND ' +
                                    '(estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') AND ';
                  end
               else
                  begin
                     FromAjuste  := '';
                     WhereAjuste := '';
                  end;

               Query.CommandText := Query.CommandText + Format(QueryFormat, [FromAjuste, WhereAjuste,
                                                                             ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                                             ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
               if (ProdutoDeptoDSet.RecordCount <> ProdutoDeptoDSet.RecNo) then
                  Query.CommandText := Query.CommandText + ' UNION '
               else
                  Query.CommandText := Query.CommandText + ' ORDER BY produto_id, departamento_id';

               ProdutoDeptoDSet.Next;
            end;
      end
   else if (ProdutoDeptoDSet.RecordCount = 1) then
      begin
         AjusteID := GetAjusteID(AjusteDSet,
                                 ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                 ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger);

         if (AjusteID <> 0) then
            begin
               FromAjuste  := 'estoque_ajuste_produto, ';
               WhereAjuste := '(estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora) AND ' +
                              '(estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') AND ';
            end
         else
            begin
               FromAjuste  := '';
               WhereAjuste := '';
            end;

         Query.CommandText := Format(QueryFormat, [FromAjuste, WhereAjuste,
                                                   ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                   ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
      end;

   Query.Open;

   DSet.Data := Query.Data;
   DSet.AddIndex('produto_departamento_index',
                 'produto_id;departamento_id',
                 [], '', '', 0);
   DSet.IndexName := 'produto_departamento_index';

   DSet.Aggregates.Add;
   DSet.Aggregates[0].AggregateName := 'total_quantidade';
   DSet.Aggregates[0].Expression := 'SUM(quantidade)';
   DSet.AggregatesActive := True;

   Query.Close;
   FreeAndNil(Query);

   Result := DSet;
end;


///////////////////////////////////////////////////////////////////////
// InhEstoqueMatrizDescritivaMovimentoSaida :
///////////////////////////////////////////////////////////////////////
// Retorna uma matriz com dados relevantes e descritivos
// dos movimentos de produtos, levando em conta o departamento
// destino.
///////////////////////////////////////////////////////////////////////
function InhEstoqueMatrizDescritivaMovimentoSaida(ProdutoDeptoDSet : TClientDataSet;
                                                  AjusteDSet       : TClientDataSet) : TClientDataSet;
var
   Query : TSQLClientDataSet;
   DSet  : TClientDataSet;
   QueryFormat : String;

   AjusteID : Integer;
   FromAjuste  : String;
   WhereAjuste : String;
begin
   Query := TSQLCLientDataSet.Create(nil);
   Query.DBConnection := MainDM.MainConnection;

   DSet := TClientDataSet.Create(nil);

   QueryFormat := 'SELECT ' +
                  'estoque_movimento_produto.id, ' +
                  'estoque_movimento_produto.grupo, ' +
                  'estoque_movimento_produto.produto as produto_id, ' +
                  'produto.descricao as produto, ' +
                  'estoque_movimento_produto.departamento_origem as departamento_id, ' +
                  'departamento.nome as departamento, ' +
                  'estoque_movimento_produto.quantidade, ' +
                  'estoque_movimento_produto.observacao as observacao, ' +
                  'estoque_movimento_produto.datahora, ' +
                  'acesso.usuario as usuario ' +
                  'FROM ' +
                  '%s ' + // From estoque_ajuste_produto
                  'estoque_movimento_produto, produto, departamento, acesso ' +
                  'WHERE ' +
                  '%s ' + // Where estoque_ajuste_produto
                  '(produto.id = %u AND departamento.id = %u) AND ' +
                  '(estoque_movimento_produto.produto = produto.id) AND ' +
                  '(estoque_movimento_produto.departamento_origem = departamento.id) AND ' +

                  // departamento_destino = NULL para excluir transferencias
                  //'(estoque_movimento_produto.departamento_destino IS NULL) AND ' +

                  '(estoque_movimento_produto.usuario = acesso.id) ';

   ProdutoDeptoDSet.First;
   AjusteDSet.First;

   if (ProdutoDeptoDSet.RecordCount > 1) then
      begin
         QueryFormat := '(' + QueryFormat + ')';

         while not ProdutoDeptoDSet.Eof do
            begin
               AjusteID := GetAjusteID(AjusteDSet,
                                       ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                       ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger);

               if (AjusteID <> 0) then
                  begin
                     FromAjuste  := 'estoque_ajuste_produto, ';
                     WhereAjuste := '(estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora) AND ' +
                                    '(estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') AND ';
                  end
               else
                  begin
                     FromAjuste  := '';
                     WhereAjuste := '';
                  end;

               Query.CommandText := Query.CommandText + Format(QueryFormat, [FromAjuste, WhereAjuste,
                                                                             ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                                             ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
               if (ProdutoDeptoDSet.RecordCount <> ProdutoDeptoDSet.RecNo) then
                  Query.CommandText := Query.CommandText + ' UNION '
               else
                  Query.CommandText := Query.CommandText + ' ORDER BY produto_id, departamento_id';

               ProdutoDeptoDSet.Next;
            end;
      end
   else if (ProdutoDeptoDSet.RecordCount = 1) then
      begin
         AjusteID := GetAjusteID(AjusteDSet,
                                 ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                 ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger);

         if (AjusteID <> 0) then
            begin
               FromAjuste  := 'estoque_ajuste_produto, ';
               WhereAjuste := '(estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora) AND ' +
                              '(estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') AND ';
            end
         else
            begin
               FromAjuste  := '';
               WhereAjuste := '';
            end;

         Query.CommandText := Format(QueryFormat, [FromAjuste, WhereAjuste,
                                                   ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                   ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
      end;

   Query.Open;

   DSet.Data := Query.Data;
   DSet.AddIndex('produto_departamento_index',
                 'produto_id;departamento_id',
                 [], '', '', 0);
   DSet.IndexName := 'produto_departamento_index';

   DSet.Aggregates.Add;
   DSet.Aggregates[0].AggregateName := 'total_quantidade';
   DSet.Aggregates[0].Expression := 'SUM(quantidade)';
   DSet.AggregatesActive := True;

   Query.Close;
   FreeAndNil(Query);

   Result := DSet;
end;



///////////////////////////////////////////////////////////////////////
// InhEstoqueMatrizDescritivaConsumo :
///////////////////////////////////////////////////////////////////////
// Retorna uma matriz com dados relevantes e descritivos
// relativos a consumos.
///////////////////////////////////////////////////////////////////////
function InhEstoqueMatrizDescritivaConsumo (ProdutoDeptoDSet : TClientDataSet;
                                            AjusteDSet       : TClientDataSet) : TClientDataSet;
var
   Query : TSQLClientDataSet;
   DSet  : TClientDataSet;
   QueryFormat : String;

   AjusteID : Integer;
   FromAjuste  : String;
   WhereAjuste : String;
begin
   Query := TSQLCLientDataSet.Create(nil);
   Query.DBConnection := MainDM.MainConnection;

   DSet := TClientDataSet.Create(nil);

   QueryFormat := 'SELECT ' +
                  'consumo.produto as produto_id, ' +
                  'produto.descricao as produto, ' +
                  'consumo.departamento_venda as departamento_id, ' +
                  'departamento.nome as departamento, ' +
                  'SUM(consumo.produto_quantidade) as quantidade, ' +
                  'acesso.usuario as usuario ' +
                  'FROM ' +
                  '%s ' + // From estoque_ajuste_produto
                  'consumo, produto, departamento, acesso ' +
                  'WHERE ' +
                  '%s ' + // Where estoque_ajuste_produto
                  '(produto.id = %u AND departamento.id = %u) AND ' +
                  '(consumo.produto = produto.id) AND ' +
                  '(consumo.departamento_venda = departamento.id) AND ' +
                  '(consumo.usuario = acesso.id) ' +
                  'GROUP BY consumo.produto, consumo.departamento_venda';

   ProdutoDeptoDSet.First;
   AjusteDSet.First;

   if (ProdutoDeptoDSet.RecordCount > 1) then
      begin
         QueryFormat := '(' + QueryFormat + ')';

         while not ProdutoDeptoDSet.Eof do
            begin
               AjusteID := GetAjusteID(AjusteDSet,
                                       ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                       ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger);

               if (AjusteID <> 0) then
                  begin
                     FromAjuste  := 'estoque_ajuste_produto, ';
                     WhereAjuste := '(consumo.datahora_inicial > estoque_ajuste_produto.datahora) AND ' +
                                    '(estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') AND ';
                  end
               else
                  begin
                     FromAjuste  := '';
                     WhereAjuste := '';
                  end;

               Query.CommandText := Query.CommandText + Format(QueryFormat, [FromAjuste, WhereAjuste,
                                                                             ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                                             ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
               if (ProdutoDeptoDSet.RecordCount <> ProdutoDeptoDSet.RecNo) then
                  Query.CommandText := Query.CommandText + ' UNION '
               else
                  Query.CommandText := Query.CommandText + ' ORDER BY produto_id, departamento_id';

               ProdutoDeptoDSet.Next;
            end;
      end
   else if (ProdutoDeptoDSet.RecordCount = 1) then
      begin
         AjusteID := GetAjusteID(AjusteDSet,
                                 ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                 ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger);

         if (AjusteID <> 0) then
            begin
               FromAjuste  := 'estoque_ajuste_produto, ';
               WhereAjuste := '(estoque_movimento_produto.datahora > estoque_ajuste_produto.datahora) AND ' +
                              '(estoque_ajuste_produto.id = ' + IntToStr(AjusteID) + ') AND ';
            end
         else
            begin
               FromAjuste  := '';
               WhereAjuste := '';
            end;

         Query.CommandText := Format(QueryFormat, [FromAjuste, WhereAjuste,
                                                   ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                                   ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger]);
      end;

   Query.Open;

   DSet.Data := Query.Data;
   DSet.AddIndex('produto_departamento_index',
                 'produto_id;departamento_id',
                 [], '', '', 0);
   DSet.IndexName := 'produto_departamento_index';

   Query.Close;
   FreeAndNil(Query);

   Result := DSet;
end;

procedure InhFilterByProdutoIdDepartamentoID (MovimentoDSet  : TClientDataSet;
                                              ProdutoID      : Integer;
                                              DepartamentoID : Integer);
begin
   with MovimentoDSet do
      begin
         Filtered := False;
         Filter   := 'produto_id = ' + IntToStr(ProdutoID) + ' ' +
                     'and departamento_id = ' + IntToStr(DepartamentoID);
         Filtered := True;
      end;
end;


///////////////////////////////////////////////////////////////////////
// InhEstoqueMatrizMovimentoGetQuantidade
///////////////////////////////////////////////////////////////////////
// Pode ser usada com MovimentoEntrada ou MovimentoSaida
// Retorna somatoria das quantidades dos movimentos
///////////////////////////////////////////////////////////////////////
function InhEstoqueMatrizMovimentoGetQuantidade (MovimentoDSet  : TClientDataSet;
                                                 ProdutoID      : Integer;
                                                 DepartamentoID : Integer) : Integer;
begin
   InhFilterByProdutoIdDepartamentoID (MovimentoDSet, ProdutoID, DepartamentoID);

   Result := MovimentoDSet.Aggregates[0].Value;

   MovimentoDSet.Filtered := False;
end;

function InhEstoqueMatrizConsumoGetQuantidade (ConsumoDSet : TClientDataSet;
                                               ProdutoID : Integer;
                                               DepartamentoID : Integer) : Integer;
begin
   with ConsumoDSet do
      begin
         Filtered := False;
         Filter   := 'produto_id = ' + IntToStr(ProdutoID) + ' ' +
                     'and departamento_id = ' + IntToStr(DepartamentoID);
         Filtered := True;
      end;

   if not ConsumoDSet.Eof then
      Result := ConsumoDSet.FieldByName('quantidade').AsInteger
   else
      Result := 0;
end;


function InhEstoqueCalcula (Ajuste           : Integer;
                            MovimentoEntrada : Integer;
                            MovimentoSaida   : Integer;
                            Consumo          : Integer) : Integer;
begin
   Result := (Ajuste + MovimentoEntrada) - (MovimentoSaida + Consumo);
end;


///////////////////////////////////////////////////////////////////////
// InhEstoqueGetTipoMovimentoDesc :
///////////////////////////////////////////////////////////////////////
// Retorna uma string descritiva para o dado Tipo
///////////////////////////////////////////////////////////////////////
function InhEstoqueGetTipoMovimentoDesc (Tipo : TInhEstoqueTipoMovimento) : String;
begin
   case Tipo of
      ietmEntrada : Result := 'Entrada';
      ietmSaida : Result := 'Saída';
      ietmTransferencia : Result := 'Transferência';
      ietmAjuste : Result := 'Ajuste';
   end;
end;


///////////////////////////////////////////////////////////////////////
// InhEstoqueProdutoQuantidadeData :
///////////////////////////////////////////////////////////////////////
// Retorna o estoque de um determinado produto, em um determinado
// departamento, em uma determinada data/hora.
///////////////////////////////////////////////////////////////////////
function InhEstoqueProdutoQuantidadeData (ProdutoId : Integer;
                                          DepartamentoId : Integer;
                                          DataHora  : TDateTime) : Integer;
begin

   Result := 0;
end;

end.