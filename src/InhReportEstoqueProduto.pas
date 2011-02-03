unit InhReportEstoqueProduto;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

// Relatorios Disponíveis:
procedure InhReportEstoqueProdutoID (ProdutoID	    : Integer;
     			             UsarAjuste	    : Boolean;
			             UsarConsumo    : Boolean;
			             UsarMovimento  : Boolean;
                                     PorDepartamento: Boolean);

implementation

{
function PrintProdutoHeader (ProdutoID	    : Integer;
  	                     UsarAjuste	    : Boolean;
			     UsarConsumo    : Boolean;
			     UsarMovimento  : Boolean) : String;
var
   // Informacoes completas sobre o produto
   ProdutoDSet : TSQLClientDataSet;
begin


end;
}

function GetProdutoHeader () : string;
begin
   Result := '    --------   ----------------------------------------   -----------' + InhLineFeed +
             '     Código    Descrição                                   Qtd Total ' + InhLineFeed +
             '    --------   ----------------------------------------   -----------' + InhLineFeed;
end;

// Retorna string se Detalhado for pedido
// Retorna
{function GetProdutoAjuste (ProdutoID      : Integer;
                           DepartamentoID : Integer;
                           var Quantidade : Integer;
                           Detalhadado    : Boolean) : string;
}


procedure InhReportEstoqueProdutoID (ProdutoID	  : Integer;
     			           UsarAjuste	  : Boolean;
			           UsarConsumo    : Boolean;
			           UsarMovimento  : Boolean;
                                   PorDepartamento: Boolean);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

//   WriteLn(TF, InhReportEstoqueProdutoGetProduto (ProdutoID, UsarAjuste, UsarConsumo, UsarMovimento, PorDepartamento));
   CloseFile(TF);
   InhReportViewerRun (FileName);
end;


end.
 