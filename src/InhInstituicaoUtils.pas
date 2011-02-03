unit InhInstituicaoUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS;

function InhInstituicaoDelete (PessoaInstituicaoID : integer) : boolean;

implementation

uses  InhMainDM, InhBiblio, InhConfig, InhLogger, InhDlgUtils;

function InhInstituicaoDelete (PessoaInstituicaoID : integer) : boolean;
var
   Connection : TSQLConnection;

   Commands : array[0..6] of string;
   CurrentCommand : integer;

   StringId : string;
begin
   StringId := IntToStr(PessoaInstituicaoID);

   Commands[0] := 'DELETE FROM pessoa_instituicao WHERE id = ' + StringId;
   Commands[1] := 'DELETE FROM pessoa_instituicao_instituicao WHERE dono = ' + StringId;
   Commands[2] := 'DELETE FROM pessoa_instituicao_telefone WHERE dono = ' + StringId;
   Commands[3] := 'DELETE FROM pessoa_instituicao_endereco WHERE dono = ' + StringId;
   Commands[4] := 'DELETE FROM pessoa_instituicao_email WHERE dono = ' + StringId;
   Commands[5] := 'DELETE FROM pessoa_instituicao_contato_parentesco WHERE dono = ' + StringId;
   Commands[6] := 'UPDATE porta_consumo SET dono = NULL WHERE dono = ' + StringId;

   for CurrentCommand := Low(Commands) to High(Commands) do
      begin
         Connection := MainDM.MainConnection.CloneConnection;
         Connection.Execute(Commands[CurrentCommand], nil, nil);
      end;
   Result := True;
end;

end.
 