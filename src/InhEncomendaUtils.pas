unit InhEncomendaUtils;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS;

procedure InhEncomendaNova (PortaConsumoID : integer);
function InhEncomendaDelete (PortaConsumoID : integer) : boolean;


implementation

uses  InhMainDM, InhBiblio, InhConfig, InhLogger, InhPortaConsumoUtils;

procedure InhEncomendaNova (PortaConsumoID : integer);
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := 'INSERT INTO encomenda (dono, usuario) values (' +
                        IntToStr(PortaConsumoID) + ', ' + InhAccess.id + ')';
   Query.ExecSQL(True);
   Query.Free;
end;

function InhEncomendaDelete (PortaConsumoID : integer) : boolean;
var
   Connection : TSQLConnection;

   StringId : string;
begin
   StringId := IntToStr(PortaConsumoID);

   InhPortaConsumoDelete (PortaConsumoID);

   Connection := MainDM.MainConnection.CloneConnection;
   Connection.Execute('DELETE FROM encomenda WHERE dono = ' + StringId, nil, nil);

   Result := True;
end;

end.
 