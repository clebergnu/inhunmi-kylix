unit InhReport;

interface

uses  SysUtils, Types, Classes, Variants, QForms, QDialogs, QDBCtrls,
      DBXpress, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, InhMainDM,
      InhBiblio, InhConfig
{$IFDEF LINUX}
,Libc
{$ENDIF LINUX}
;

procedure InhReportRealPrint (ReportFileName : String; Printer : String);
function  InhReportGetBoxedCabecalho () : String;
function  InhReportGetCabecalho () : String;
function  InhReportGetCabecalhoLinha (Linha : integer) : String;

function  InhReportGetBoxedRodape () : String;
function  InhReportGetRodape () : String;
function  InhReportGetRodapeLinha (Linha : integer) : String;

function  InhReportGetTmpFileName () : String;

const
{$IFDEF LINUX}
   InhLineFeed : String = #10;
{$ENDIF LINUX}
{$IFDEF MSWINDOWS}
   InhLineFeed : String = #10 + #13;
{$ENDIF MSWINDOWS}

   InhLine48SubTotal : String = '                                        --------';

   InhLine48 : String = '================================================';
   InhLine80 : String = '================================================================================';

   InhSingleLine48 : String = '------------------------------------------------';
   InhSingleLine80 : String = '--------------------------------------------------------------------------------';

implementation

function InhReportGetTmpFileName () : String;
var
{$IFDEF LINUX}
   p_FileName : PChar;
{$ENDIF LINUX}
begin
{$IFDEF LINUX}
   p_FileName := tempnam (PChar('/tmp'), PChar('inh-'));
   Result := string (p_FileName);
{$ENDIF LINUX}
end;

// Envia arquivo para impressao
procedure InhReportRealPrint (ReportFileName : String; Printer : String);
var
   LinhasAdicionais : integer;
   LinhaAtual : integer;
   Report : TextFile;
begin
   if (Printer = '') then
      Printer := LocalConfig.ReadString('Impressao', 'ImpressoraPadrao', 'lp');

   LinhasAdicionais := GlobalConfig.ReadInteger('Impressora-' + Printer, 'LinhasAdicionais', 0);

   if (LinhasAdicionais > 0) then
      begin
         AssignFile(Report, ReportFileName);
         Append(Report);
         for LinhaAtual := 1 to LinhasAdicionais do
            begin
               WriteLn(Report, '');
            end;
         CloseFile(Report);
      end;

   {$IFDEF LINUX}
   Libc.system (PChar('lp -d ' + Printer + ' ' + ReportFileName));
   {$ENDIF LINUX}
end;

function InhReportGetCabecalhoLinha (Linha : integer) : String;
begin
   Result := GlobalConfig.ReadString('Impressao', 'CabecalhoLinha' + IntToStr(Linha), '') + InhLineFeed;
end;

function InhReportGetCabecalho () : String;
begin
   Result := InhReportGetCabecalhoLinha(1) +
             InhReportGetCabecalhoLinha(2) +
             InhReportGetCabecalhoLinha(3);
end;

function InhReportGetBoxedCabecalho () : String;
begin
   Result := InhLine48 + InhLineFeed +
             InhReportGetCabecalho +
             InhLine48;

end;

function InhReportGetRodapeLinha (Linha : integer) : String;
begin
   Result := GlobalConfig.ReadString('Impressao', 'RodapeLinha' + IntToStr(Linha), '') + InhLineFeed;
end;

function InhReportGetRodape () : String;
begin
   Result := InhReportGetRodapeLinha(1) +
             InhReportGetRodapeLinha(2) +
             InhReportGetRodapeLinha(3);
end;

function InhReportGetBoxedRodape () : String;
begin
   Result := InhLine48 + InhLineFeed +
             InhReportGetRodape +
             InhLine48;

end;


end.
