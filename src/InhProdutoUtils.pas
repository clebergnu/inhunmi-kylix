unit InhProdutoUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS;

function InhProdutoDelete (ProdutoID : integer) : boolean;

implementation

uses  InhMainDM, InhBiblio, InhConfig, InhLogger, InhDlgUtils;

function InhProdutoDelete (ProdutoID : integer) : boolean;
var
   Connection : TSQLConnection;

   Commands : array[0..3] of string;
   CurrentCommand : integer;

   StringId : string;
begin
   StringId := IntToStr(ProdutoID);

   Commands[0] := 'DELETE FROM produto WHERE id = ' + StringId;
   Commands[1] := 'DELETE FROM produto_equivalencia WHERE dono = ' + StringId;
   Commands[2] := 'DELETE FROM produto_composicao WHERE dono = ' + StringId;
   Commands[3] := 'UPDATE consumo SET produto = NULL WHERE produto = ' + StringId;

   for CurrentCommand := Low(Commands) to High(Commands) do
      begin
         Connection := MainDM.MainConnection.CloneConnection;
         Connection.Execute(Commands[CurrentCommand], nil, nil);
      end;
   Result := True;
end;


end.
