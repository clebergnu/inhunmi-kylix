unit InhReporEstoqueProduto;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

// Relatorios Disponíveis:
procedure InhReportEstoqueProduto (ProdutoID	  : Integer;
     			           UsarAjuste	  : Boolean;
			           UsarConsumo    : Boolean;
			           UsarMovimento  : Boolean;
                                   PorDepartamento: Boolean);

implementation

function InhReportEstoqueProdutoGetProduto (ProdutoID	   : Integer;
              			            UsarAjuste	   : Boolean;
			                    UsarConsumo    : Boolean;
			                    UsarMovimento  : Boolean;
                                            PorDepartamento: Boolean) : string;
var
   // Lista de departamentos com ajustes para o dado produto
   AjusteDepartamentoDSet : TSQLClientDataSet;
   // Lista de ajustes para o dado produto, um departamento por vez
   AjusteDSet : TSQLDataSet;

   ConsumoDSet : TSQLDataSet;
   MovimentoDSet : TSQLDataSet;

   AjusteQtd : Integer;
   AjusteDataHora : TDateTime;
   AjusteDataHoraStr : String;

   ConsumoQtd : Integer;
begin
   if (UsarAjuste) then
      begin
         AjusteDepartamentoDSet := TSQLClientDataSet.Create(MainDM.MainConnection);
         AjusteDepartamentoDSet.DBConnection := MainDM.MainConnection;
         AjusteDepartamentoDSet.CommandText := 'SELECT DISTINCT departamento FROM estoque_ajuste_produto ' +
                                               'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                                               'ORDER BY departamento';
         AjusteDepartamentoDSet.Open;
         if (AjusteDepartamentoDSet.RecordCount > 0) then
            begin
               AjusteDepartamentoDSet.First;

               AjusteDSet := TSQLDataSet.Create(MainDM.MainConnection);
               AjusteDSet.SQLConnection := MainDM.MainConnection;
               AjusteQtd := 0;

               while not (AjusteDepartamentoDSet.Eof) do
                  begin
                     AjusteDSet.CommandText := 'SELECT quantidade, datahora FROM estoque_ajuste_produto ' +
                                               'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                                               'AND departamento = ' + AjusteDepartamentoDSet.FieldByName('departamento').AsString + ' ' +
                                               'ORDER BY datahora DESC LIMIT 1';
                     AjusteDSet.Open;
                     AjusteQtd := AjusteQtd + AjusteDSet.FieldByName('quantidade').AsInteger;
                     AjusteDSet.Close;

                     AjusteDepartamentoDSet.Next;
                  end;
            end;

         AjusteDataHora := AjusteDSet.FieldByName('datahora').AsDateTime;
         AjusteDataHoraStr := DateTimeToSQLTimeStampString(AjusteDataHora);

         FreeAndNil(AjusteDSet);
      end
   else
      begin
         AjusteQtd := 0;
         AjusteDataHora := 0;
         AjusteDataHoraStr := '1900-01-01 00:00:00';
      end;

   if (UsarConsumo) then
      begin
         ConsumoDSet := TSQLDataSet.Create(MainDM.MainConnection);
         ConsumoDSet.SQLConnection := MainDM.MainConnection;
         ConsumoDSet.CommandText := 'SELECT SUM(produto_quantidade) as quantidade FROM consumo ' +
                                    'WHERE produto = ' + IntToStr(ProdutoID) + ' ' +
                                    'AND datahora_inicial > ' + QuotedStr(AjusteDataHoraStr);
         ConsumoDSet.Open;

         ConsumoQtd := ConsumoDSet.FieldByName('quantidade').AsInteger;

         FreeAndNil(ConsumoDSet);
      end
   else
      begin
         ConsumoQtd := 0;
      end;

   if (UsarMovimento) then
   begin
      MovimentoDSet := TSQLDataSet.Create(MainDM.MainConnection);

      FreeAndNil(MovimentoDSet);
   end;

   Result := '';
end;






procedure InhReportEstoqueProduto (ProdutoID	  : Integer;
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

   WriteLn(TF, InhReportEstoqueProdutoGetProduto (ProdutoID, UsarAjuste, UsarConsumo, UsarMovimento, PorDepartamento));
   CloseFile(TF);
   InhReportViewerRun (FileName);
end;


end.
 