unit InhReportPessoaInstituicao;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhReport,
      InhReportViewer;

// Relatorios Disponíveis:
procedure InhReportPITelefones (PIInicial : integer;
                                PIFinal   : integer;
                                Tipo      : string);
var
   Telefones : TSQLDataSet;

implementation

procedure UpdateTelefones (PIInicial     : integer;
                           PIFinal       : integer;
                           Tipo          : string);
var
   WhereTipo : string;
begin
   if (Telefones = nil) then
      begin
         Telefones := TSQLDataSet.Create(MainDM.MainConnection);
         Telefones.SQLConnection := MainDM.MainConnection;
      end;

   if (Tipo <> '') then
      WhereTipo := 'AND pessoa_instituicao.tipo = "' + Tipo + '" '
   else
      WhereTipo := '';

   with Telefones do
      begin
         if Active then Close;
         CommandText := 'SELECT pessoa_instituicao.id as id, pessoa_instituicao.nome as nome, ' +
                        'CONCAT("(", pessoa_instituicao_telefone.ddd, ")", " ", pessoa_instituicao_telefone.numero, " (", pessoa_instituicao_telefone.tipo, ")") as telefone ' +
                        'FROM pessoa_instituicao, pessoa_instituicao_telefone ' +
                        'WHERE pessoa_instituicao_telefone.dono = pessoa_instituicao.id ' +
                        WhereTipo +
                        'ORDER BY nome';
         Open;
         First;
      end
end;

function  InhReportPITelefonesGetTelefones (PIInicial : integer;
                                            PIFinal   : integer;
                                            Tipo      : string) : string;
var
   PIAtual : integer;
   PIAnterior : integer;
begin
   UpdateTelefones (PIInicial, PIFinal, Tipo);

   PIAnterior := 0;

   while not (Telefones.Eof) do
      begin
         PIAtual := Telefones.FieldValues['id'];

         if (PIAtual <> PIAnterior) then
               Result := Result + Telefones.FieldByName('nome').AsString + InhLineFeed;

         Result := Result + InhLine48 + InhLinefeed;
         while (PIAtual = Telefones.FieldValues['id']) and not (Telefones.Eof) do
            begin
               Result := Result + Telefones.FieldByName('telefone').AsString + InhLineFeed;
               Telefones.Next;
            end;
         Result := Result + InhLineFeed;
         PIAnterior := PIAtual;
      end;
      Result := Result + InhLineFeed;
end;

procedure InhReportPITelefones (PIInicial : integer;
                                PIFinal   : integer;
                                Tipo      : string);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine48);
   Writeln(TF, 'Agenda de Telefones');
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   // Parametros
//   WriteLn(TF, 'Pessoa/Instituicao Inicial: ' + IntToStr(PIInicial));
//   WriteLn(TF, 'Pessoa/Instituicao Final:   ' + IntToStr(PIFinal));
//   WriteLn(TF, InhLine48);
   WriteLn(TF, '');

   WriteLn(TF, InhReportPITelefonesGetTelefones (PIInicial, PIFinal, Tipo));

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

end.
