unit InhReportEstoqueMovimentoSimples;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer, InhDlgUtils, InhEstoqueUtils;

// Relatorios Disponiveis
procedure InhReportEstoqueMovimentoSimplesTipoId (Tipo : TInhEstoqueTipoMovimento;
                                                  MovimentoID : Integer);   

implementation

function GetDSet (Tipo : TInhEstoqueTipoMovimento;
                  MovimentoID : Integer) : TSQLClientDataSet;
var
   DSet : TSQLClientDataSet;
begin
   DSet := TSQLClientDataSet.Create(nil);
   DSet.DBConnection := MainDM.MainConnection;

   if (Tipo = ietmEntrada) then
      DSet.CommandText :=
       'SELECT ' +
       'estoque_movimento_produto.id, ' +
       'estoque_movimento_produto.produto AS produto_id, ' +
       'estoque_movimento_produto.departamento_destino AS departamento_id, ' +

       'produto.descricao AS produto, ' +
       'departamento.nome AS departamento, ' +

       'estoque_movimento_produto.quantidade, ' +
       'estoque_movimento_produto.datahora, ' +
       'estoque_movimento_produto.usuario AS usuario_id, ' +
       'estoque_movimento_produto.observacao, ' +

       'acesso.usuario AS usuario ' +
       'FROM ' +
       'estoque_movimento_produto, ' +
       'produto, ' +
       'departamento, ' +
       'acesso ' +
       'WHERE ' +
       '(estoque_movimento_produto.produto = produto.id) AND ' +
       '(estoque_movimento_produto.departamento_origem IS NULL) AND ' +
       '(estoque_movimento_produto.departamento_destino = departamento.id) AND ' +
       '(acesso.id = estoque_movimento_produto.usuario) AND ' +
       '(estoque_movimento_produto.id = ' + IntToStr(MovimentoID) + ')'

   else if (Tipo = ietmSaida) then
      DSet.CommandText :=
       'SELECT ' +
       'estoque_movimento_produto.id, ' +
       'estoque_movimento_produto.produto AS produto_id, ' +
       'estoque_movimento_produto.departamento_origem AS departamento_id, ' +

       'produto.descricao AS produto, ' +
       'departamento.nome AS departamento, ' +

       'estoque_movimento_produto.quantidade, ' +
       'estoque_movimento_produto.datahora, ' +
       'estoque_movimento_produto.usuario AS usuario_id, ' +
       'estoque_movimento_produto.observacao, ' +

       'acesso.usuario AS usuario ' +
       'FROM ' +
       'estoque_movimento_produto, ' +
       'produto, ' +
       'departamento, ' +
       'acesso ' +
       'WHERE ' +
       '(estoque_movimento_produto.produto = produto.id) AND ' +
       '(estoque_movimento_produto.departamento_destino IS NULL) AND ' +
       '(estoque_movimento_produto.departamento_origem = departamento.id) AND ' +
       '(acesso.id = estoque_movimento_produto.usuario) AND ' +
       '(estoque_movimento_produto.id = ' + IntToStr(MovimentoID) + ')'

   else if (Tipo = ietmTransferencia) then
      DSet.CommandText :=
       'SELECT ' +
       'estoque_movimento_produto.id, ' +
       'estoque_movimento_produto.produto AS produto_id, ' +
       'estoque_movimento_produto.departamento_origem AS departamento_origem_id, ' +
       'estoque_movimento_produto.departamento_destino AS departamento_destino_id, ' +

       'produto.descricao AS produto, ' +
       'departamento_origem.nome AS departamento_origem, ' +
       'departamento_destino.nome AS departamento_destino, ' +       

       'estoque_movimento_produto.quantidade, ' +
       'estoque_movimento_produto.datahora, ' +
       'estoque_movimento_produto.usuario AS usuario_id, ' +
       'estoque_movimento_produto.observacao, ' +       

       'acesso.usuario AS usuario ' +
       'FROM ' +
       'estoque_movimento_produto, ' +
       'produto, ' +
       'departamento as departamento_origem, ' +
       'departamento as departamento_destino, ' +
       'acesso ' +
       'WHERE ' +
       '(estoque_movimento_produto.produto = produto.id) AND ' +

       '(estoque_movimento_produto.departamento_origem IS NOT NULL) AND ' +
       '(estoque_movimento_produto.departamento_destino IS NOT NULL) AND ' +

       '(estoque_movimento_produto.departamento_origem = departamento_origem.id) AND ' +
       '(estoque_movimento_produto.departamento_destino = departamento_destino.id) AND ' +       
       '(acesso.id = estoque_movimento_produto.usuario) AND ' +
       '(estoque_movimento_produto.id = ' + IntToStr(MovimentoID) + ')'

   else if (Tipo = ietmAjuste) then
      DSet.CommandText :=
       'SELECT ' +
       'estoque_ajuste_produto.id, ' +
       'estoque_ajuste_produto.produto AS produto_id, ' +
       'estoque_ajuste_produto.departamento AS departamento_id, ' +

       'produto.descricao AS produto, ' +
       'departamento.nome AS departamento, ' +

       'estoque_ajuste_produto.quantidade, ' +
       'estoque_ajuste_produto.datahora, ' +
       'estoque_ajuste_produto.usuario AS usuario_id, ' +
       'estoque_ajuste_produto.observacao, ' +

       'acesso.usuario AS usuario ' +
       'FROM ' +
       'estoque_ajuste_produto, ' +
       'produto, ' +
       'departamento, ' +
       'acesso ' +
       'WHERE ' +
       '(estoque_ajuste_produto.produto = produto.id) AND ' +
       '(estoque_ajuste_produto.departamento = departamento.id) AND ' +
       '(acesso.id = estoque_ajuste_produto.usuario) AND ' +
       '(estoque_ajuste_produto.id = ' + IntToStr(MovimentoID) + ')';

   Result := DSet;
end;

function GetDetails (Tipo : TInhEstoqueTipoMovimento;
                     MovimentoDSet : TSQLClientDataSet) : String;
begin
   Result := '';

   if (MovimentoDSet.RecordCount = 0) then exit;

   if ((Tipo = ietmEntrada) or (Tipo = ietmSaida) or (Tipo = ietmAjuste)) then
      Result := Result +
                'Código: ' + MovimentoDSet.FieldByName('id').AsString + InhLineFeed +
                'Data/Hora: ' + MovimentoDSet.FieldByName('datahora').AsString + InhLineFeed +
                'Usuário: ' + MovimentoDSet.FieldByName('usuario').AsString + InhLineFeed +

                InhLineFeed +

                'Depto.: ' + MovimentoDSet.FieldByName('departamento').AsString + InhLineFeed +
                'Produto: ' + MovimentoDSet.FieldByName('produto').AsString + InhLineFeed +
                'Quantidade: ' + MovimentoDSet.FieldByName('quantidade').AsString + InhLineFeed +
                'Observação: ' + MovimentoDSet.FieldByName('observacao').AsString

   else if (Tipo = ietmTransferencia) then
      Result := Result +
                'Código: ' + MovimentoDSet.FieldByName('id').AsString + InhLineFeed +
                'Data/Hora: ' + MovimentoDSet.FieldByName('datahora').AsString + InhLineFeed +
                'Usuário: ' + MovimentoDSet.FieldByName('usuario').AsString + InhLineFeed +

                InhLineFeed +

                'Depto. Origem: ' + MovimentoDSet.FieldByName('departamento_origem').AsString + InhLineFeed +
                'Depto. Destino: ' + MovimentoDSet.FieldByName('departamento_destino').AsString + InhLineFeed +
                'Produto: ' + MovimentoDSet.FieldByName('produto').AsString + InhLineFeed +
                'Quantidade: ' + MovimentoDSet.FieldByName('quantidade').AsString + InhLineFeed +
                'Observação: ' + MovimentoDSet.FieldByName('observacao').AsString;
end;



///////////////////////////////////////////////////////////////////////
// InhReportEstoqueMovimentoSimplesTipoId:
///////////////////////////////////////////////////////////////////////
// Executa relatorio com as informações de um dado
// estoque_movimento_produto.
//
// "Tipo" é usado para auxiliar a identificação do tipo de movimento,
// ao invés de verificar o valor de departamento_origem/destino
// toda vez.
///////////////////////////////////////////////////////////////////////
procedure InhReportEstoqueMovimentoSimplesTipoId (Tipo : TInhEstoqueTipoMovimento;
                                                  MovimentoID : Integer);
var
   // Relatorio
   TF : TextFile;
   FileName : String;

   DSet : TSQLClientDataSet;
begin

   DSet := GetDSet (Tipo, MovimentoID);
   DSet.Open;
   if (DSet.RecordCount = 0) then
      begin
         InhDlg('Erro: movimento código ' + IntToStr(MovimentoID) +
                ' não existe, impossível gerar relatório.');
         FreeAndNil(DSet);
         exit;
      end;

   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);


   // Cabeçalho
   WriteLn (TF, InhSingleLine48);
   WriteLn (TF, 'Estoque - ' + InhEstoqueGetTipoMovimentoDesc(Tipo) + ' Simples');
   WriteLn (TF, InhSingleLine48 + InhLineFeed);

   WriteLn (TF, GetDetails (Tipo, DSet));

   CloseFile(TF);
   FreeAndNil(DSet);
   
   InhReportViewerOrPrint (Filename, 'EstoqueComprovanteMovimento');
end;

end.
