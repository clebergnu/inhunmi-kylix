unit InhReportEncomendaProducao;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

// Relatorios Disponiveis:
procedure InhReportEncomendaProducaoResumo (DataInicial : TDateTime; DataFinal : TDateTime);

var
   ProducaoResumo : TSQLDataSet;

implementation

procedure UpdateProducaoResumo (DataInicial : TDateTime; DataFinal : TDateTime);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (ProducaoResumo = nil) then
      begin
         ProducaoResumo := TSQLDataSet.Create(MainDM.MainConnection);
         ProducaoResumo.SQLConnection := MainDM.MainConnection;
      end;

   if (ProducaoResumo.Active) then ProducaoResumo.Close;

   ProducaoResumo.CommandText :=
   'SELECT produto.descricao as produto, SUM(consumo.produto_quantidade) as quantidade ' +
   'FROM  produto, consumo, porta_consumo, encomenda ' +
   'WHERE (produto.id = consumo.produto) AND (encomenda.dono = porta_consumo.id) ' +
   'AND (consumo.dono = porta_consumo.id) AND (porta_consumo.tipo = "Encomenda") ' +
   'AND (porta_consumo.status = "Aberto") ' + 
   'AND (encomenda.datahora_entrega BETWEEN ' + DataInicialString + ' AND ' + DataFinalString + ') ' +
   'GROUP BY produto.descricao ORDER BY produto.grupo, produto.descricao';

   ProducaoResumo.Open;
   ProducaoResumo.First;
end;

function  InhReportEncomendaProducaoResumoGetProdutos (DataInicial : TDateTime; DataFinal : TDateTime) : string;
begin
   Result := '';

   UpdateProducaoResumo (DataInicial, DataFinal);

   while (not ProducaoResumo.Eof) do
      begin
         Result := Result + Format ('%-37s %10u',
                                    [ProducaoResumo.FieldByName('produto').AsString,
                                     ProducaoResumo.FieldByName('quantidade').AsInteger]) + InhLineFeed;
         ProducaoResumo.Next;
      end;
end;

procedure InhReportEncomendaProducaoResumo (DataInicial : TDateTime; DataFinal : TDateTime);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine48);
   Writeln(TF, ' Encomendas - Resumo de Produtos para Producao  ');
   Writeln(TF, InhLine48);
   Writeln(TF, 'Data/Hora Inicial: ' + DateTimeToSQLTimeStampString (DataInicial));
   Writeln(TF, 'Data/Hora Final:   ' + DateTimeToSQLTimeStampString (DataFinal));
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   // Parametros
   Writeln(TF, InhReportEncomendaProducaoResumoGetProdutos (DataInicial, DataFinal));
   Writeln(TF, '');
   Writeln(TF, '');
   CloseFile(TF);
   InhReportViewerOrPrint (Filename, 'EncomendaProducaoResumo');
end;

end.
