unit InhEstoqueAjusteGrupoUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      QStdCtrls;

function InhEstoqueAjusteGrupoDelete (MovimentoGrupoID : integer) : boolean;

implementation

function InhEstoqueAjusteGrupoDelete (MovimentoGrupoID : integer) : boolean;
var
   Connection : TSQLConnection;

   Commands : array[0..1] of string;
   CurrentCommand : integer;

   StringId : string;
begin
   StringId := IntToStr(MovimentoGrupoID);

   Commands[0] := 'DELETE FROM estoque_ajuste_produto WHERE grupo = ' + StringId;
   Commands[1] := 'DELETE FROM estoque_ajuste_produto_grupo WHERE id = ' + StringId;

   for CurrentCommand := Low(Commands) to High(Commands) do
      begin
         Connection := MainDM.MainConnection.CloneConnection;
         Connection.Execute(Commands[CurrentCommand], nil, nil);
      end;
   Result := True;
end;

end.
