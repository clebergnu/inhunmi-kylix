unit InhReportEncomendaListagem;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, DateUtils, InhMainDM, InhBiblio,
      InhConfig, InhReport, InhReportViewer, InhReportEncomenda;

// Relatorios Disponiveis:
procedure InhReportEncomendaListagemHora (DataInicial : TDateTime; DataFinal : TDateTime);

var
   ListagemDSet : TSQLDataSet;

implementation

procedure UpdateListagemDSet (DataInicial : TDateTime; DataFinal : TDateTime);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (ListagemDSet = nil) then
      begin
         ListagemDSet := TSQLDataSet.Create(MainDM.MainConnection);
         ListagemDSet.SQLConnection := MainDM.MainConnection;
      end;

   if (ListagemDSet.Active) then ListagemDSet.Close;

   ListagemDSet.CommandText :=
   'SELECT porta_consumo.id, encomenda.datahora_entrega ' +
   'FROM porta_consumo, encomenda ' +
   'WHERE (porta_consumo.id = encomenda.dono) ' +
   'AND (encomenda.datahora_entrega BETWEEN ' + DataInicialString + ' AND ' + DataFinalString + ') ' +
   'ORDER BY datahora_entrega';

   ListagemDSet.Open;
   ListagemDSet.First;
end;

function PrintHeaderDate (Data : TDateTime) : string;
begin
   Result := '';

   Result := InhSingleLine80 + InhLineFeed +
             'Encomendas do Dia : ' + DateTimeToStr(DateOf(Data)) + InhLineFeed +
             InhSingleLine80 + InhLineFeed;
end;

function InhReportEncomendaGetListagemHora (DataInicial : TDateTime; DataFinal : TDateTime) : String;
var
   CurrentDay : TDateTime;
begin
   Result := '';
   UpdateListagemDSet (DataInicial, DataFinal);

   CurrentDay := DateOf (StrToDateTime (ListagemDSet.FieldByName('datahora_entrega').AsString));
   Result := Result + PrintHeaderDate (StrToDateTime (ListagemDSet.FieldByName('datahora_entrega').AsString));
   while (not ListagemDSet.Eof) do
      begin
         // Date Header
         if (DayOf (CurrentDay) <> DayOf (StrToDateTime (ListagemDSet.FieldByName('datahora_entrega').AsString))) then
            Result := Result + PrintHeaderDate (StrToDateTime (ListagemDSet.FieldByName('datahora_entrega').AsString));

         // Detalhes Desta Encomenda
         Result := Result + InhReportEncomendaGetDetails (ListagemDSet.FieldByName('id').AsInteger);
         // Produtos Desta Encomenda
         Result := Result + InhReportEncomendaGetConsumos (ListagemDSet.FieldByName('id').AsInteger);

         Result := Result + InhLineFeed + InhLineFeed + InhLineFeed;

        CurrentDay := DateOf (StrToDateTime (ListagemDSet.FieldByName('datahora_entrega').AsString));
        ListagemDSet.Next;
      end;
end;


procedure InhReportEncomendaListagemHora (DataInicial : TDateTime; DataFinal : TDateTime);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine80);
   Writeln(TF, 'Encomendas - Listagem de Encomendas');
   Writeln(TF, InhLine80);
   Writeln(TF, 'Data/Hora Inicial: ' + DateTimeToSQLTimeStampString (DataInicial));
   Writeln(TF, 'Data/Hora Final:   ' + DateTimeToSQLTimeStampString (DataFinal));
   Writeln(TF, InhLine80 + InhLineFeed);
   // Fim de cabecalho

   // Parametros
   Writeln(TF, InhReportEncomendaGetListagemHora (DataInicial, DataFinal));
   Writeln(TF, '');
   Writeln(TF, '');
   CloseFile(TF);
   InhReportViewerOrPrint (Filename, 'EncomendaProducaoResumo');
end;

end.
