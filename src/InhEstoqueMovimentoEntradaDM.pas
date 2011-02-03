unit InhEstoqueMovimentoEntradaDM;

interface

uses
  SysUtils, Classes, QTypes, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS, InhDbForm, InhBiblio, InhStringResources, InhDlgUtils,

  InhEstoqueMovimentoEntradaUtils;

type
  TEstoqueMovimentoEntradaDM = class(TDataModule)
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
    MovimentoDSetfornecedor: TIntegerField;
    FornecedorDSet: TSQLClientDataSet;
    FornecedorDSource: TDataSource;
    FornecedorDSetid: TIntegerField;
    FornecedorDSetnome: TStringField;
    MovimentoDSetfornecedor_nome: TStringField;
    MovimentoDSetvalor_unitario: TCurrencyField;
    MovimentoDSetvalor: TFloatField;
    procedure MovimentoDSetAfterPost(DataSet: TDataSet);
    procedure MovimentoDSetBeforeDelete(DataSet: TDataSet);
    procedure MovimentoDSetCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function DMOpen() : boolean;
  end;

implementation

{$R *.xfm}

{ TEstoqueMovimentoEntradaDM }

function TEstoqueMovimentoEntradaDM.DMOpen: boolean;
begin
   Result := (InhDataSetOpenMaster(MovimentoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(ProdutoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(FornecedorDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(DepartamentoDSet));
   if (Result = False) then exit;

   Result := (InhDataSetOpenMaster(UsuarioDSet));
   if (Result = False) then exit;
end;

procedure TEstoqueMovimentoEntradaDM.MovimentoDSetAfterPost(
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

procedure TEstoqueMovimentoEntradaDM.MovimentoDSetBeforeDelete(
  DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Entrada Simples') <> True then
      Abort;
end;

procedure TEstoqueMovimentoEntradaDM.MovimentoDSetCalcFields(
  DataSet: TDataSet);
begin
   InhEstoqueMovimentoEntradaCalcValorUnitario(DataSet);
end;

end.
