unit InhLogger;

interface

uses  SysUtils, Types, Classes, Variants, QForms, QDialogs, QDBCtrls,
      DBXpress, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, InhMainDM,
      InhBiblio, InhConfig;

const
   // ild -> Inhunmi Log Domain
   ildPortaConsumo    = 1;
   ildConsumo         = ildPortaConsumo + 1;
   ildPagamento       = ildConsumo + 1;
   ildNaoEspecificado = ildPagamento + 1;

   // ilo -> Inhunmi Log Operation
   iloInclusao        = 1;
   iloAlteracao       = iloInclusao + 1;
   iloDelecao         = iloAlteracao + 1;
   iloNaoEspecificada = iloDelecao + 1;

type
   TInhIld = ildPortaConsumo..ildNaoEspecificado;
   TInhIlo = iloInclusao..iloNaoEspecificada;

procedure InhLogInit ();
procedure InhLog (Dominio : TInhIld;
                  DominioId : integer;
                  Operacao : TInhIlo;
                  MensagemInterna : string;
                  MensagemUsuario : string);

implementation

{$DEFINE INH_LOGGER_ENABLED}

var
   Query : TSQLDataSet;

procedure InhLogInit ();
begin
   Query := TSQLDataSet.Create(Application);
   Query.SQLConnection := MainDM.MainConnection;
end;

procedure InhLog (Dominio : TInhIld;
                  DominioId : integer;
                  Operacao : TInhIlo;
                  MensagemInterna : string;
                  MensagemUsuario : string);
begin
{$IFDEF INH_LOGGER_ENABLED}
   Query.CommandText := 'INSERT INTO log (dominio, dominio_id, operacao, mensagem_interna, mensagem_usuario, usuario) VALUES (' +
                        Format('%u, %u, %u, "%s", "%s", %s',
                               [Dominio,
                                DominioId,
                                Operacao,
                                MensagemInterna,
                                MensagemUsuario,
                                InhAccess.Id]) + ')';
   Query.ExecSQL(True);
{$ENDIF}
end;

end.
