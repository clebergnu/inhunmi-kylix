unit InhEstoqueMovimentoTransferenciaGrupoDM;

interface

uses
  SysUtils, Classes, QTypes, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS,

  InhDbForm, InhBiblio, InhStringResources, InhDlgUtils,
  InhEstoqueMovimentoGrupoUtils;

type
  TEstoqueMovimentoTransferenciaGrupoDM = class(TDataModule)
    MovimentoGrupoDSet: TSQLClientDataSet;
    MovimentoGrupoDSource: TDataSource;
    MovimentosDSet: TSQLClientDataSet;
    MovimentosDSource: TDataSource;
    DepartamentosDSet: TSQLClientDataSet;
    DepartamentosDSource: TDataSource;
    MovimentoGrupoDSetid: TIntegerField;
    MovimentoGrupoDSetdatahora: TSQLTimeStampField;
    MovimentoGrupoDSetobservacao: TStringField;
    MovimentoGrupoDSetusuario: TIntegerField;
    UsuarioDSet: TSQLClientDataSet;
    UsuarioDSource: TDataSource;
    MovimentoGrupoDSetusuario_nome: TStringField;
    MovimentosDSetid: TIntegerField;
    MovimentosDSetgrupo: TIntegerField;
    MovimentosDSetproduto: TIntegerField;
    MovimentosDSetquantidade: TIntegerField;
    MovimentosDSetdatahora: TSQLTimeStampField;
    MovimentosDSetobservacao: TStringField;
    MovimentosDSetusuario: TIntegerField;
    ProdutosDSet: TSQLClientDataSet;
    ProdutosDSource: TDataSource;
    ProdutosDSetid: TIntegerField;
    ProdutosDSetdescricao: TStringField;
    MovimentosDSetproduto_descricao: TStringField;
    MovimentoGrupoDSetdepartamento_origem: TIntegerField;
    MovimentosDSetdepartamento_origem: TIntegerField;
    MovimentoGrupoDSetdepartamento_destino: TIntegerField;
    MovimentosDSetdepartamento_destino: TIntegerField;
    procedure MovimentoGrupoDSetAfterPost(DataSet: TDataSet);
    procedure MovimentosDSetBeforePost(DataSet: TDataSet);
    procedure MovimentosDSetAfterPost(DataSet: TDataSet);
    procedure MovimentosUpdateDepartamentoDataHora();
    procedure MovimentoGrupoDSetBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function DMOpen : boolean;
  end;

var
  EstoqueMovimentoTransferenciaGrupoDM: TEstoqueMovimentoTransferenciaGrupoDM;

implementation

uses InhMainDM;

{$R *.xfm}

{ TEstoqueMovimentoTransferenciaGrupoDM }

function TEstoqueMovimentoTransferenciaGrupoDM.DMOpen: boolean;
begin
   Result := (InhDataSetOpenMaster(UsuarioDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(ProdutosDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(DepartamentosDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(MovimentoGrupoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenDetail(MovimentosDset, MovimentoGrupoDSet));
   if (Result = False) then exit;
end;

procedure TEstoqueMovimentoTransferenciaGrupoDM.MovimentoGrupoDSetAfterPost(
  DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);

   // Update MovimentosDSet to reflect changes on 'departamento_destino' and 'datahora'
   MovimentosUpdateDepartamentoDataHora();

   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

procedure TEstoqueMovimentoTransferenciaGrupoDM.MovimentosDSetBeforePost(
  DataSet: TDataSet);
var
   MovimentoGrupoID : Integer;
begin
   MovimentoGrupoID := MovimentoGrupoDSet.FieldByName('id').AsInteger;
   Assert (MovimentoGrupoId <> 0, 'Erro: código do grupo de movimento igual a 0!');

   with DataSet do
      begin
         FieldByName('grupo').AsInteger := MovimentoGrupoID;
         FieldByName('departamento_origem').AsInteger := MovimentoGrupoDSet.FieldByName('departamento_origem').AsInteger;
         FieldByName('departamento_destino').AsInteger := MovimentoGrupoDSet.FieldByName('departamento_destino').AsInteger;
         FieldByName('datahora').AsDateTime := MovimentoGrupoDSet.FieldByName('datahora').AsDateTime;
         FieldByName('usuario').AsString := InhAccess.id;
      end;
end;

procedure TEstoqueMovimentoTransferenciaGrupoDM.MovimentosDSetAfterPost(
  DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost (DataSet);
end;


procedure TEstoqueMovimentoTransferenciaGrupoDM.MovimentoGrupoDSetBeforeDelete(
  DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Saída em Grupo') = True then
      begin
         if InhEstoqueMovimentoGrupoDelete (DataSet.FieldByName('id').AsInteger) then
            begin
               DbForm.StatusBar.SimpleText := Format ('Saída em Grupo código %u excluída.',
                                                      [DataSet.FieldByName('id').AsInteger]);
               DataSet.AfterScroll(DataSet);
               DataSet.Refresh;               
            end;
      end;
   Abort;
end;

procedure TEstoqueMovimentoTransferenciaGrupoDM.MovimentosUpdateDepartamentoDataHora;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := 'UPDATE estoque_movimento_produto, estoque_movimento_produto_grupo SET ' + 
                        'estoque_movimento_produto.departamento_origem = estoque_movimento_produto_grupo.departamento_origem,' +
                        'estoque_movimento_produto.departamento_destino = estoque_movimento_produto_grupo.departamento_destino,' +
                        'estoque_movimento_produto.datahora = estoque_movimento_produto_grupo.datahora ' +
                        'WHERE ' +
                        'estoque_movimento_produto_grupo.id = ' + MovimentoGrupoDSet.FieldByName('id').AsString + ' AND ' +
                        'estoque_movimento_produto_grupo.id = estoque_movimento_produto.grupo';
   Query.ExecSQL(True);

   MovimentosDSet.Refresh;

   FreeAndNil(Query);
end;

end.
