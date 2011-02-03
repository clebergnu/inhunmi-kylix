unit InhEstoqueAjusteGrupoDM;

interface

uses
  SysUtils, Classes, QTypes, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS,

  InhDbForm, InhBiblio, InhStringResources, InhDlgUtils,
  InhEstoqueAjusteGrupoUtils;

type
  TEstoqueAjusteGrupoDM = class(TDataModule)
    AjusteGrupoDSet: TSQLClientDataSet;
    AjusteGrupoDSource: TDataSource;
    AjustesDSet: TSQLClientDataSet;
    AjustesDSource: TDataSource;
    DepartamentosDSet: TSQLClientDataSet;
    DepartamentosDSource: TDataSource;
    AjusteGrupoDSetid: TIntegerField;
    AjusteGrupoDSetdatahora: TSQLTimeStampField;
    AjusteGrupoDSetobservacao: TStringField;
    AjusteGrupoDSetusuario: TIntegerField;
    UsuarioDSet: TSQLClientDataSet;
    UsuarioDSource: TDataSource;
    AjusteGrupoDSetusuario_nome: TStringField;
    AjustesDSetid: TIntegerField;
    AjustesDSetgrupo: TIntegerField;
    AjustesDSetproduto: TIntegerField;
    AjustesDSetquantidade: TIntegerField;
    AjustesDSetdatahora: TSQLTimeStampField;
    AjustesDSetobservacao: TStringField;
    AjustesDSetusuario: TIntegerField;
    ProdutosDSet: TSQLClientDataSet;
    ProdutosDSource: TDataSource;
    ProdutosDSetid: TIntegerField;
    ProdutosDSetdescricao: TStringField;
    AjustesDSetproduto_descricao: TStringField;
    AjusteGrupoDSetdepartamento: TIntegerField;
    AjustesDSetdepartamento: TIntegerField;
    procedure AjusteGrupoDSetAfterPost(DataSet: TDataSet);
    procedure AjustesDSetBeforePost(DataSet: TDataSet);
    procedure AjustesDSetAfterPost(DataSet: TDataSet);
    procedure MovimentosUpdateDepartamentoDataHora();
    procedure AjusteGrupoDSetBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function DMOpen : boolean;
  end;

var
  EstoqueAjusteGrupoDM: TEstoqueAjusteGrupoDM;

implementation

uses InhMainDM;

{$R *.xfm}

{ TEstoqueAjusteGrupoDM }

function TEstoqueAjusteGrupoDM.DMOpen: boolean;
begin
   Result := (InhDataSetOpenMaster(UsuarioDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(ProdutosDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(DepartamentosDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(AjusteGrupoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenDetail(AjustesDset, AjusteGrupoDSet));
   if (Result = False) then exit;
end;

procedure TEstoqueAjusteGrupoDM.AjusteGrupoDSetAfterPost(
  DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);

   // Update MovimentosDSet to reflect changes on 'departamento' and 'datahora'
   MovimentosUpdateDepartamentoDataHora();

   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

procedure TEstoqueAjusteGrupoDM.AjustesDSetBeforePost(
  DataSet: TDataSet);
var
   AjusteGrupoID : Integer;
begin
   AjusteGrupoID := AjusteGrupoDSet.FieldByName('id').AsInteger;
   Assert (AjusteGrupoID <> 0, 'Erro: código do grupo de movimento igual a 0!');

   with DataSet do
      begin
         FieldByName('grupo').AsInteger := AjusteGrupoID;
         FieldByName('departamento').AsInteger := AjusteGrupoDSet.FieldByName('departamento').AsInteger;
         FieldByName('datahora').AsDateTime := AjusteGrupoDSet.FieldByName('datahora').AsDateTime;
         FieldByName('usuario').AsString := InhAccess.id;
      end;
end;

procedure TEstoqueAjusteGrupoDM.AjustesDSetAfterPost(
  DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost (DataSet);
end;


procedure TEstoqueAjusteGrupoDM.AjusteGrupoDSetBeforeDelete(
  DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Ajuste em Grupo') = True then
      begin
         if InhEstoqueAjusteGrupoDelete (DataSet.FieldByName('id').AsInteger) then
            begin
               DbForm.StatusBar.SimpleText := Format ('Ajuste em Grupo código %u excluído.',
                                                      [DataSet.FieldByName('id').AsInteger]);
               DataSet.AfterScroll(DataSet);
               DataSet.Refresh;               
            end;
      end;
   Abort;
end;

procedure TEstoqueAjusteGrupoDM.MovimentosUpdateDepartamentoDataHora;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := 'UPDATE estoque_ajuste_produto, estoque_ajuste_produto_grupo SET ' +
                        'estoque_ajuste_produto.departamento = estoque_ajuste_produto_grupo.departamento,' +
                        'estoque_ajuste_produto.datahora = estoque_ajuste_produto_grupo.datahora ' +
                        'WHERE ' +
                        'estoque_ajuste_produto_grupo.id = ' + AjusteGrupoDSet.FieldByName('id').AsString + ' AND ' +
                        'estoque_ajuste_produto_grupo.id = estoque_ajuste_produto.grupo';
   Query.ExecSQL(True);

   AjustesDSet.Refresh;

   FreeAndNil(Query);
end;

end.
