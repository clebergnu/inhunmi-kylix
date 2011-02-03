unit InhReportPendentes;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, DateUtils,
      InhMainDM, InhBiblio, InhConfig, InhReport, InhReportViewer;

// Relatorios Disponiveis:
procedure InhReportPendentesAReceberResumido ();
procedure InhReportPendentesAReceberPorCliente ();

implementation

var
   PendentesAReceber : TSQLDataSet;

procedure UpdatePendentesAReceber ();
begin
   if (PendentesAReceber = nil) then
      begin
         PendentesAReceber := TSQLDataSet.Create(MainDM.MainConnection);
         PendentesAReceber.SQLConnection := MainDM.MainConnection;
      end;

   if (PendentesAReceber.Active) then PendentesAReceber.Close;
   PendentesAReceber.CommandText := 'SELECT porta_consumo.id, pessoa_instituicao.nome, ' +
                                    'porta_consumo.datahora_inicial as datahora, SUM(consumo.valor) as valor ' +
                                    'FROM porta_consumo, pessoa_instituicao, consumo WHERE ' + 
                                    '(porta_consumo.status = "Pendente") AND ' +
                                    '(porta_consumo.dono = pessoa_instituicao.id) AND ' +
                                    '(consumo.dono = porta_consumo.id) GROUP BY porta_consumo.id ' +
                                    'ORDER BY pessoa_instituicao.nome, porta_consumo.datahora_inicial';
   PendentesAReceber.Open;
   PendentesAReceber.First;
end;

function GetPendentesAReceber () : string;
var
   Total : Currency;
begin
   UpdatePendentesAReceber ();

   Total := 0;

   while not (PendentesAReceber.Eof) do
      begin
         Result := Result + Format ('%8u %10s %-30s %8.2f' + InhLineFeed,
                                    [
                                     PendentesAReceber.FieldByName('id').AsInteger,
                                     DateToStr(DateOf(PendentesAReceber.FieldByName('datahora').AsDateTime)),
                                     Copy(PendentesAReceber.FieldByName('nome').AsString, 0, 31),
                                     PendentesAReceber.FieldByName('valor').AsFloat
                                    ]);

         Total := Total + PendentesAReceber.FieldByName('valor').AsFloat;
         PendentesAReceber.Next;
      end;

   Result := Result +
             InhLineFeed +
             Format('Total: %52.2f', [Total]) + InhLineFeed +
             InhLineFeed;

end;

procedure InhReportPendentesAReceberResumido ();
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine80);
   Writeln(TF, '       Listagem  de  Pendentes  a  Receber      ');
   Writeln(TF, InhLine80);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Emitido Por Usuário: ' + InhAccess.Id);
   WriteLn(TF, 'Data/Hora De Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now()));
   Writeln(TF, InhLine80);
   Writeln(TF, '');
   Writeln(TF, GetPendentesAReceber ());
   Writeln(TF, '');
   CloseFile(TF);
   InhReportViewerRun (Filename);
end;

procedure InhReportPendentesAReceberPorCliente ();
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine80);
   Writeln(TF, '       Listagem  de  Pendentes  a  Receber      ');
   Writeln(TF, InhLine80);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Emitido Por Usuário: ' + InhAccess.Id);
   WriteLn(TF, 'Data/Hora De Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now()));
   Writeln(TF, '');
   Writeln(TF, GetPendentesAReceber ());
   Writeln(TF, '');
   CloseFile(TF);
   InhReportViewerRun (Filename);
end;

end.
