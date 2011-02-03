unit InhReportEstoqueMovimentoGrupo;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer, InhDlgUtils, InhEstoqueUtils;

// Relatorios Disponiveis
procedure InhReportEstoqueMovimentoGrupoTipoId (Tipo : TInhEstoqueTipoMovimento;
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
      DSet.CommandText := '';

   Result := DSet;
end;


///////////////////////////////////////////////////////////////////////
// InhReportEstoqueMovimentoGrupoTipoId:
///////////////////////////////////////////////////////////////////////
// Executa relatorio com cabecalho informativo de um dado
// estoque_movimento_produto_grupo, seguido por todos os registros
// filhos (estoque_movimento_produto).
//
// "Tipo" � usado para auxiliar a identifica��o do tipo de movimento,
// ao inv�s de verificar o valor de departamento_origem/destino
// toda vez.
///////////////////////////////////////////////////////////////////////
procedure InhReportEstoqueMovimentoGrupoTipoId (Tipo : TInhEstoqueTipoMovimento;
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
         InhDlg('Erro: movimento c�digo ' + IntToStr(MovimentoID) +
                ' n�o existe, imposs�vel gerar relat�rio.');
         FreeAndNil(DSet);
         exit;
      end;

   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);


   // Cabe�alho
   WriteLn (TF, InhSingleLine48);
   WriteLn (TF, 'Estoque - ' + InhEstoqueGetTipoMovimentoDesc(Tipo) + ' Simples');
   WriteLn (TF, InhSingleLine48 + InhLineFeed);

//   WriteLn (TF, GetDetails (Tipo, DSet));

   CloseFile(TF);
   FreeAndNil(DSet);
   
   InhReportViewerOrPrint (Filename, 'EstoqueComprovanteMovimento');
end;



end.
 