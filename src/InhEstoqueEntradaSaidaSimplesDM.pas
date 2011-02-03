unit InhEstoqueEntradaSaidaSimplesDM;

interface

uses
  SysUtils, Classes, QTypes, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS, InhDbForm, InhBiblio, InhStringResources, InhDlgUtils;

type
  TEstoqueEntradaSaidaSimplesDM = class(TDataModule)
    MovimentoDSet: TSQLClientDataSet;
    MovimentoDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    DepartamentoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    DepartamentoDSource: TDataSource;
    ProdutoDSetid: TIntegerField;
    ProdutoDSetdescricao: TStringField;
    DepartamentoDSetid: TIntegerField;
    DepartamentoDSetnome: TStringField;
    UsuarioDSet: TSQLClientDataSet;
    UsuarioDSource: TDataSource;
    MovimentoDSetid: TIntegerField;
    MovimentoDSetproduto: TIntegerField;
    MovimentoDSetdepartamento_destino: TIntegerField;
    MovimentoDSetquantidade: TIntegerField;
    MovimentoDSetusuario: TIntegerField;
    MovimentoDSetdatahora: TSQLTimeStampField;
    MovimentoDSetobservacao: TStringField;
    MovimentoDSetusuario_nome: TStringField;
    MovimentoDSetproduto_nome: TStringField;
    procedure MovimentoDSetAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function DMOpen() : boolean;
  end;

function EstoqueEntradaSaidaSimplesDMNew(TipoMovimento : TInhEstoqueTipoMovimento) : TEstoqueEntradaSaidaSimplesDM;

implementation

{$R *.xfm}

{ TEstoqueMovimentoEntradaDM }

function EstoqueEntradaSaidaSimplesDMNew(TipoMovimento : TInhEstoqueTipoMovimento) : TEstoqueEntradaSaidaSimplesDM;
var
   DM : TEstoqueEntradaSaidaSimplesDM;
begin
   DM := TEstoqueEntradaSaidaSimplesDM.CreateNew(nil, 0);

   case TipoMovimento of
      ietmEntrada :
         with DM.MovimentoDSet do
            begin
               CommandText := 'SELECT '+
                              'id, produto, departamento_destino, quantidade, ' +
                              'usuario, datahora, observacao ' +
                              'FROM ' +
                              'estoque_movimento_produto ' +
                              'WHERE '+
                              '(departamento_destino IS NOT NULL) AND '+
                              '(departamento_origem IS NULL) AND ' +
                              '(grupo IS NULL)';
            end;
      ietmSaida :
         with DM.MovimentoDSet do
            begin
               CommandText := 'SELECT '+
                              'id, produto, departamento_destino, quantidade, ' +
                              'usuario, datahora, observacao ' +
                              'FROM ' +
                              'estoque_movimento_produto ' +
                              'WHERE '+
                              '(departamento_origem IS NOT NULL) AND '+
                              '(departamento_destino IS NULL) AND ' +
                              '(grupo IS NULL)';
            end;
   end;

   Result := DM;
end;

function TEstoqueEntradaSaidaSimplesDM.DMOpen: boolean;
begin
   Result := (InhDataSetOpenMaster(MovimentoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(ProdutoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(DepartamentoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(UsuarioDSet));
   if (Result = False) then exit;
end;

procedure TEstoqueEntradaSaidaSimplesDM.MovimentoDSetAfterPost(
  DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);
   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

end.
