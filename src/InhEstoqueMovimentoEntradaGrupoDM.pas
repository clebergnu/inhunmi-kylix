unit InhEstoqueMovimentoEntradaGrupoDM;

interface

uses
  SysUtils, Classes, QTypes, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS,

  InhDbForm, InhBiblio, InhStringResources, InhDlgUtils,
  InhEstoqueMovimentoGrupoUtils, InhEstoqueMovimentoEntradaUtils, FMTBcd;

type
  TEstoqueMovimentoEntradaGrupoDM = class(TDataModule)
    MovimentoGrupoDSet: TSQLClientDataSet;
    MovimentoGrupoDSource: TDataSource;
    DepartamentosDSet: TSQLClientDataSet;
    DepartamentosDSource: TDataSource;
    MovimentoGrupoDSetid: TIntegerField;
    MovimentoGrupoDSetdepartamento_destino: TIntegerField;
    MovimentoGrupoDSetdatahora: TSQLTimeStampField;
    MovimentoGrupoDSetobservacao: TStringField;
    MovimentoGrupoDSetusuario: TIntegerField;
    UsuarioDSet: TSQLClientDataSet;
    UsuarioDSource: TDataSource;
    MovimentoGrupoDSetusuario_nome: TStringField;
    ProdutosDSet: TSQLClientDataSet;
    ProdutosDSource: TDataSource;
    ProdutosDSetid: TIntegerField;
    ProdutosDSetdescricao: TStringField;
    MovimentoGrupoDSetfornecedor: TIntegerField;
    FornecedorDSet: TSQLClientDataSet;
    FornecedorDSource: TDataSource;
    MovimentoGrupoDSetfornecedor_nome: TStringField;
    FornecedorDSetid: TIntegerField;
    FornecedorDSetnome: TStringField;
    MovimentosProvider: TDataSetProvider;
    MovimentosSQLDSet: TSQLDataSet;
    MovimentosClientDSet: TClientDataSet;
    MovimentosDSource: TDataSource;
    MovimentosSQLDSetid: TIntegerField;
    MovimentosSQLDSetgrupo: TIntegerField;
    MovimentosSQLDSetproduto: TIntegerField;
    MovimentosSQLDSetdepartamento_destino: TIntegerField;
    MovimentosSQLDSetquantidade: TIntegerField;
    MovimentosSQLDSetdatahora: TSQLTimeStampField;
    MovimentosSQLDSetobservacao: TStringField;
    MovimentosSQLDSetusuario: TIntegerField;
    MovimentosSQLDSetfornecedor: TIntegerField;
    MovimentosSQLDSetvalor: TFloatField;
    MovimentosClientDSetid: TIntegerField;
    MovimentosClientDSetgrupo: TIntegerField;
    MovimentosClientDSetproduto: TIntegerField;
    MovimentosClientDSetdepartamento_destino: TIntegerField;
    MovimentosClientDSetquantidade: TIntegerField;
    MovimentosClientDSetdatahora: TSQLTimeStampField;
    MovimentosClientDSetobservacao: TStringField;
    MovimentosClientDSetusuario: TIntegerField;
    MovimentosClientDSetfornecedor: TIntegerField;
    MovimentosClientDSetvalor: TFloatField;
    MovimentosClientDSetvalor_unitario: TFloatField;
    MovimentosClientDSetproduto_descricao: TStringField;
    MovimentosSQLDSetvalor_unitario: TFloatField;
    MovimentosClientDSetvalor_total: TAggregateField;
    procedure MovimentoGrupoDSetAfterPost(DataSet: TDataSet);
    procedure MovimentoGrupoUpdateChildren();    
    procedure MovimentoGrupoDSetBeforeDelete(DataSet: TDataSet);
    procedure MovimentosSQLDSetCalcFields(DataSet: TDataSet);
    procedure MovimentosClientDSetAfterPost(DataSet: TDataSet);
    procedure MovimentosClientDSetBeforePost(DataSet: TDataSet);
    procedure MovimentosClientDSetCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function DMOpen : boolean;
  end;

var
  EstoqueMovimentoEntradaGrupoDM: TEstoqueMovimentoEntradaGrupoDM;

implementation

uses InhMainDM;

{$R *.xfm}

{ TEstoqueMovimentoEntradaGrupoDM }

function TEstoqueMovimentoEntradaGrupoDM.DMOpen: boolean;
begin
   Result := (InhDataSetOpenMaster(UsuarioDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(ProdutosDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(DepartamentosDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(FornecedorDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(MovimentoGrupoDSet));
   if (Result = False) then exit;

   MovimentosSQLDSet.Params[0].AsInteger := MovimentoGrupoDSet.FieldByName('id').AsInteger;
   MovimentosClientDSet.Active := True;
   Result := MovimentosClientDSet.Active;
   if (Result = False) then exit;

// Result := (InhDataSetOpenDetail(MovimentosDset, MovimentoGrupoDSet));
// if (Result = False) then exit;
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentoGrupoDSetAfterPost(
  DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);

   // Update MovimentosDSet to reflect changes on 'departamento_destino' and 'datahora'
   MovimentoGrupoUpdateChildren();

   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentoGrupoDSetBeforeDelete(
  DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Entrada em Grupo') = True then
      begin
         if InhEstoqueMovimentoGrupoDelete (DataSet.FieldByName('id').AsInteger) then
            begin
               DbForm.StatusBar.SimpleText := Format ('Entrada em Grupo código %u excluída.',
                                                      [DataSet.FieldByName('id').AsInteger]);
               DataSet.AfterScroll(DataSet);
               DataSet.Refresh;               
            end;
      end;
   Abort;
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentoGrupoUpdateChildren();
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(nil);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := 'UPDATE estoque_movimento_produto, estoque_movimento_produto_grupo SET ' +
                        'estoque_movimento_produto.departamento_destino = estoque_movimento_produto_grupo.departamento_destino,' +
                        'estoque_movimento_produto.datahora = estoque_movimento_produto_grupo.datahora, ' +
                        'estoque_movimento_produto.fornecedor = estoque_movimento_produto_grupo.fornecedor ' +
                        'WHERE ' +
                        'estoque_movimento_produto_grupo.id = ' + MovimentoGrupoDSet.FieldByName('id').AsString + ' AND ' +
                        'estoque_movimento_produto_grupo.id = estoque_movimento_produto.grupo';
   Query.ExecSQL(True);

   MovimentosClientDSet.Refresh;

   FreeAndNil(Query);
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentosSQLDSetCalcFields(
  DataSet: TDataSet);
begin
   InhEstoqueMovimentoEntradaCalcValorUnitario(DataSet);
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentosClientDSetAfterPost(
  DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost (DataSet);
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentosClientDSetBeforePost(
  DataSet: TDataSet);
var
   MovimentoGrupoID : Integer;
begin
   MovimentoGrupoID := MovimentoGrupoDSet.FieldByName('id').AsInteger;
   Assert (MovimentoGrupoId <> 0, 'Erro: código do grupo de movimento igual a 0!');

   with DataSet do
      begin
         FieldByName('grupo').AsInteger := MovimentoGrupoID;
         FieldByName('departamento_destino').AsInteger := MovimentoGrupoDSet.FieldByName('departamento_destino').AsInteger;
         FieldByName('datahora').AsDateTime := MovimentoGrupoDSet.FieldByName('datahora').AsDateTime;
         FieldByName('usuario').AsString := InhAccess.id;
         FieldByName('fornecedor').AsInteger := MovimentoGrupoDSet.FieldByName('fornecedor').AsInteger;
      end;
end;

procedure TEstoqueMovimentoEntradaGrupoDM.MovimentosClientDSetCalcFields(
  DataSet: TDataSet);
begin
   InhEstoqueMovimentoEntradaCalcValorUnitario(DataSet);
end;

end.
