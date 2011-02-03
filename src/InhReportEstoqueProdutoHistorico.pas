unit InhReportEstoqueProdutoHistorico;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, DateUtils, InhMainDM, InhBiblio,
      InhConfig, InhReport, InhReportViewer, InhEstoqueUtils, InhDlgUtils;

procedure InhReportEstoqueProdutoHistoricoID (ProdutoID : Integer;
                                              ProdutoGrupoID : Integer);

implementation

const
   SubSpace     = '          ';
   SubSeparator = '          ----------------------------------------------------------------------';

function GetProdutoHeader (ProdutoDeptoDSet : TClientDataSet) : String;
begin
   Result := Format (InhSingleLine80 + InhLineFeed +
                     '%8s  %-40s  %-28s' + InhLineFeed +
                     InhSingleLine80 + InhLineFeed,
                     [ProdutoDeptoDSet.FieldByName('produto_id').AsString,
                      ProdutoDeptoDSet.FieldByName('produto').AsString,
                      ProdutoDeptoDSet.FieldByName('departamento').AsString]);
end;

///////////////////////////////////////////////////////////////////////
// GetProdutoAjuste:
///////////////////////////////////////////////////////////////////////
// Retorna uma String com dados de um ajuste,
///////////////////////////////////////////////////////////////////////
function GetProdutoAjuste (AjusteDSet : TClientDataSet;
                           ProdutoId : Integer;
                           DepartamentoId : Integer;
                           var Quantidade : Integer) : String;
var
   StringFormat : String;
begin
   StringFormat := SubSpace + 'Ajuste' + InhLineFeed +
                   SubSeparator + InhLineFeed +
                   SubSpace + 'Código: %-8s' + SubSpace + SubSpace + '         Usuário: %-16s' + InhLineFeed +
                   SubSpace + 'Data/Hora: %s' + SubSpace + '     Quantidade: %-8s' + InhLineFeed +
                   SubSpace + 'Observações: %s' + InhLineFeed + InhLineFeed;

   Result := '';

   AjusteDSet.Filtered := False;
   AjusteDSet.Filter := 'produto_id = ' + IntToStr(ProdutoID) + ' ' +
                           'and departamento_id = ' + IntToStr(DepartamentoID);
   AjusteDSet.Filtered := True;

   if not AjusteDSet.Eof then
      begin
         Quantidade := AjusteDSet.FieldByName('quantidade').AsInteger;
         Result := Format (StringFormat, [AjusteDSet.FieldByName('id').AsString,
                                          AjusteDSet.FieldByName('usuario').AsString,
                                          AjusteDSet.FieldByName('datahora').AsString,
                                          AjusteDSet.FieldByName('quantidade').AsString,
                                          AjusteDSet.FieldByName('observacao').AsString]);
      end;

end;

function GetMovimentoEntrada (MovimentoDSet : TClientDataSet;
                              ProdutoID : Integer;
                              DepartamentoID : Integer;
                              var Quantidade : Integer) : String;

var
   Header : String;
   StringFormat : String;
begin
   Header := SubSpace + 'Movimentos de Entrada                        Total: %-8u' + InhLineFeed;

   StringFormat := SubSeparator + InhLineFeed +
                   SubSpace + 'Código: %-8s' + SubSpace + SubSpace + '         Usuário: %-16s' + InhLineFeed +
                   SubSpace + 'Data/Hora: %s' + SubSpace + '     Quantidade: %-8s' + InhLineFeed +
                   SubSpace + 'Observações: %s' + InhLineFeed;

   Result := '';

   MovimentoDSet.Filtered := False;
   MovimentoDSet.Filter := 'produto_id = ' + IntToStr(ProdutoID) + ' ' +
                           'and departamento_id = ' + IntToStr(DepartamentoID);
   MovimentoDSet.Filtered := True;

   if not MovimentoDSet.Eof then
      begin
         MovimentoDSet.Aggregates[0].Active := True;
         Quantidade := MovimentoDSet.Aggregates[0].Value;
         Result := Format(Header,  [Quantidade]);
         MovimentoDSet.Aggregates[0].Active := False;
      end;

   while not MovimentoDSet.Eof do
      begin
         Result := Result + Format (StringFormat, [MovimentoDSet.FieldByName('id').AsString,
                                                   MovimentoDSet.FieldByName('usuario').AsString,
                                                   MovimentoDSet.FieldByName('datahora').AsString,
                                                   MovimentoDSet.FieldByName('quantidade').AsString,
                                                   MovimentoDSet.FieldByName('observacao').AsString]);
         MovimentoDSet.Next;
      end;
end;

function GetMovimentoSaida (MovimentoDSet : TClientDataSet;
                            ProdutoID : Integer;
                            DepartamentoID : Integer;
                            var Quantidade : Integer) : String;
var
   Header : String;
   StringFormat : String;
begin
   Header := SubSpace + 'Movimentos de Saida                          Total: %-8u' + InhLineFeed;

   StringFormat := SubSeparator + InhLineFeed +
                   SubSpace + 'Código: %-8s' + SubSpace + SubSpace + '         Usuário: %-16s' + InhLineFeed +
                   SubSpace + 'Data/Hora: %s' + SubSpace + '     Quantidade: %-8s' + InhLineFeed +
                   SubSpace + 'Observações: %s' + InhLineFeed;

   Result := '';

   MovimentoDSet.Filtered := False;
   MovimentoDSet.Filter := 'produto_id = ' + IntToStr(ProdutoID) + ' ' +
                           'and departamento_id = ' + IntToStr(DepartamentoID);
   MovimentoDSet.Filtered := True;

   if not MovimentoDSet.Eof then
      begin
         MovimentoDSet.Aggregates[0].Active := True;
         Quantidade := MovimentoDSet.Aggregates[0].Value;
         Result := Format(Header,  [Quantidade]);
         MovimentoDSet.Aggregates[0].Active := False;
      end;

   while not MovimentoDSet.Eof do
      begin
         Result := Result + Format (StringFormat, [MovimentoDSet.FieldByName('id').AsString,
                                                   MovimentoDSet.FieldByName('usuario').AsString,
                                                   MovimentoDSet.FieldByName('datahora').AsString,
                                                   MovimentoDSet.FieldByName('quantidade').AsString,
                                                   MovimentoDSet.FieldByName('observacao').AsString]);
         MovimentoDSet.Next;
      end;
end;

function GetConsumo (ConsumoDSet : TClientDataSet;
                     ProdutoID : Integer;
                     DepartamentoID : Integer;
                     var Quantidade : Integer) : String;
var
   StringFormat : String;
begin
   StringFormat := SubSpace + 'Consumos' + InhLineFeed +
                   SubSeparator + InhLineFeed +
                   SubSpace + 'Produto: %-40s' + 'Quantidade: %-8s' + InhLineFeed;

   Result := '';

   ConsumoDSet.Filtered := False;
   ConsumoDSet.Filter := 'produto_id = ' + IntToStr(ProdutoID) + ' ' +
                         'and departamento_id = ' + IntToStr(DepartamentoID);
   ConsumoDSet.Filtered := True;

   if not ConsumoDSet.Eof then
      begin
         Quantidade := ConsumoDSet.FieldByName('quantidade').AsInteger;
         Result := Format (StringFormat, [ConsumoDSet.FieldByName('produto').AsString,
                                          ConsumoDSet.FieldByName('quantidade').AsString]);
      end;
end;

procedure InhReportEstoqueProdutoHistoricoID (ProdutoID : Integer;
                                              ProdutoGrupoID : Integer);
var
   // Relatorio
   TF : TextFile;
   FileName : String;
   // Matriz Produto x Depto
   ProdutoDeptoDSet     : TClientDataSet;
   // Matrizes Filhas
   AjusteDSet           : TClientDataSet;
   MovimentoEntradaDSet : TClientDataSet;
   MovimentoSaidaDSet   : TClientDataSet;
   ConsumoDSet          : TClientDataSet;

   StringHolder : String;

   QtdAjuste, QtdMovEnt, QtdMovSai, QtdConsumo : Integer;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   ProdutoDeptoDSet := InhEstoqueMatrizProdutoDepartamento (ProdutoID, ProdutoGrupoID);

   if (ProdutoDeptoDSet.RecordCount = 0) then
      begin
         if ((ProdutoID = 0) and (ProdutoGrupoID > 0)) then
            InhDlg('Este grupo não possui possui produtos com registros relacionados a estoque.')
         else if (ProdutoId > 0) then
            InhDlg('Este produto não possui possui produtos com registros relacionados a estoque.')
         else 
            InhDlg('Não existem registros relacionados a estoque no banco de dados.');

         FreeAndNil(ProdutoDeptoDSet);
         exit;
      end;

   AjusteDSet := InhEstoqueMatrizDescritivaAjuste (ProdutoDeptoDSet);
   MovimentoEntradaDSet := InhEstoqueMatrizDescritivaMovimentoEntrada (ProdutoDeptoDSet, AjusteDSet);
   MovimentoSaidaDSet := InhEstoqueMatrizDescritivaMovimentoSaida (ProdutoDeptoDSet, AjusteDSet);
   ConsumoDSet := InhEstoqueMatrizDescritivaConsumo (ProdutoDeptoDSet, AjusteDSet);

   ProdutoDeptoDSet.First;
   while not ProdutoDeptoDset.Eof do
      begin
         QtdAjuste  := 0;
         QtdMovEnt  := 0;
         QtdMovSai  := 0;
         QtdConsumo := 0;


         // PRODUTO DEPTO
         StringHolder := GetProdutoHeader(ProdutoDeptoDSet);
         if (Length (StringHolder) > 0) then
            WriteLn(TF, StringHolder);

         // AJUSTE
         StringHolder := GetProdutoAjuste(AjusteDSet,
                                          ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                          ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger,
                                          QtdAjuste);
         if (Length (StringHolder) > 0) then
            WriteLn(TF, StringHolder);

         // MOVIMENTO ENTRADA
         StringHolder := GetMovimentoEntrada(MovimentoEntradaDSet,
                                             ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                             ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger,
                                             QtdMovEnt);
         if (Length (StringHolder) > 0) then
            WriteLn(TF, StringHolder);

         // MOVIMENTO SAIDA
         StringHolder := GetMovimentoSaida(MovimentoSaidaDSet,
                                           ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                           ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger,
                                           QtdMovSai);
         if (Length (StringHolder) > 0) then
            WriteLn(TF, StringHolder);

         // CONSUMOS
         StringHolder := GetConsumo(ConsumoDSet,
                                    ProdutoDeptoDSet.FieldByName('produto_id').AsInteger,
                                    ProdutoDeptoDSet.FieldByName('departamento_id').AsInteger,
                                    QtdConsumo);
         if (Length (StringHolder) > 0) then
            WriteLn(TF, StringHolder);

         WriteLn(TF, Format(SubSpace + 'Estoque Atual: %d' + InhLineFeed, [InhEstoqueCalcula(QtdAjuste,
                                                                                             QtdMovEnt,
                                                                                             QtdMovSai,
                                                                                             QtdConsumo)]));
         ProdutoDeptoDSet.Next;
      end;

   FreeAndNil(ProdutoDeptoDSet);
   FreeAndNil(AjusteDSet);
   FreeAndNil(MovimentoEntradaDSet);
   FreeAndNil(MovimentoSaidaDSet);
   FreeAndNil(ConsumoDSet);

   CloseFile(TF);
   InhReportViewerOrPrint (Filename, 'EstoqueProdutoHistorico');
end;


end.
