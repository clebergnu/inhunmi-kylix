unit InhReportEstoqueComprovanteMovimento;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer, InhEstoqueUtils, InhDlgUtils;

implementation


function GetDSet (EstoqueMovimentoID : Integer) : TSQLCLientDataSet;
var
   DSet : TSQLClientDataSet;
begin
   DSet := TSQLClientDataSet.Create(nil);
   DSet.DBConnection := MainDM.MainConnection;

   DSet.CommandText := 'SELECT ' +
                       'produto_estoque_movimento.id, ' +
                       'produto_estoque_movimento.produto as produto_id, ' +
                       'produto.descricao as produto, ' +
                       'produto_estoque_movimento.departamento_origem as departamento_origem_id, ' +
                       'departamento.descricao as departamento_origem, ' +
                       'produto_estoque_movimento.departamento_destino as departamento_destino_id, ' +
                       'departamento.descricao as departamento_destino, ' +
                       'produto_estoque_movimento.quantidade, ' +
                       'produto_estoque_movimento.datahora, ' +
                       'produto_estoque_movimento.observacao,' +
                       'acesso.usuario ' +
                       'FROM ' +
                       'produto_estoque_movimento, produto, departamento, acesso ' +
                       'WHERE ' +
                       '(produto_estoque_movimento.id = ' + IntToStr(EstoqueMovimentoID) + ') AND' +
                       '(produto_estoque_movimento.produto = produto.id) AND' +
                       '((produto_estoque_movimento.departamento_origem = departamento.id) OR ' +
                       ' (produto_estoque_movimento.departamento_destino = departamento.id) AND )' +
                       '(produto_estoque_movimento.usuario = acesso.id)';

   Result := DSet;
end;

procedure InhReportEstoqueComprovanteMovimentoSimples (EstoqueMovimentoID : Integer);
var
   // Relatorio
   TF : TextFile;
   FileName : String;

   DSet : TSQLClientDataSet;
begin

   DSet := GetDSet (EstoqueMovimentoID);
   DSet.Open;
   if (DSet.RecordCount = 0) then
      begin
         InhDlg('Erro: movimento código ' + IntToStr(EstoqueMovimentoID) +
                ' não existe, impossível gerar comprovante');
         FreeAndNil(DSet);
         exit;
      end;

   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);


   // Cabeçalho
   WriteLn (TF, InhSingleLine48 + InhLineFeed);
   WriteLn (TF, 'Comprovante De Movimento');
   WriteLn (TF, InhSingleLine48 + InhLineFeed);

   CloseFile(TF);
   InhReportViewerOrPrint (Filename, 'EstoqueComprovanteMovimento');
end;

end.
