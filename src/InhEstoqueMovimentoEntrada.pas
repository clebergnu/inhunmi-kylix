unit InhEstoqueMovimentoEntrada;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhDbFastLookUpDlg, InhBiblio, InhDlgUtils,

  InhReportEstoqueMovimentoSimples;

type
  TInhEstoqueMovimentoEntradaForm = class(TInhDbForm)
    IDLabel: TLabel;
    IDDbEdit: TDBEdit;
    DepartamentoLabel: TLabel;
    ProdutoIDDbEdit: TDBEdit;
    ProdutoDbEdit: TDBEdit;
    ProdutoButton: TButton;
    QuantidadeDbEdit: TDBEdit;
    QuantidadeLabel: TLabel;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    DBLookupComboBox1: TDBLookupComboBox;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    ObservacaoDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    RelatoriodeMovimento1: TMenuItem;
    FornecedorButton: TButton;
    FornecedorIdDbEdit: TDBEdit;
    FornecedorDbEdit: TDBEdit;
    ValorLabel: TLabel;
    ValorDbEdit: TDBEdit;
    Label1: TLabel;
    ValorUnitarioDbEdit: TDBEdit;
    procedure MasterDataSetAfterScroll (DataSet : TDataSet);
    procedure FormShow(Sender: TObject);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
    procedure RelatoriodeMovimento1Click(Sender: TObject);
    procedure FornecedorButtonClick(Sender: TObject);
  private
     ProdutoLookUp : TInhDbFastLookUpDlgForm;
     FornecedorLookUp : TInhDbFastLookUpDlgForm;
    { Private declarations }
  public
    { Public declarations }
  end;

function EstoqueMovimentoEntradaFormNew() : TInhEstoqueMovimentoEntradaForm;

implementation

uses InhEstoqueMovimentoEntradaDM;

{$R *.xfm}

function EstoqueMovimentoEntradaFormNew() : TInhEstoqueMovimentoEntradaForm;
var
   MyForm : TInhEstoqueMovimentoEntradaForm;
begin
   MyForm := TInhEstoqueMovimentoEntradaForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueMovimentoEntradaDM.Create(Application);

   TEstoqueMovimentoEntradaDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueMovimentoEntradaDM(MyForm.DataModule).MovimentoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.ProdutoButton;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_entrada';

   Result := MyForm;
end;

procedure TInhEstoqueMovimentoEntradaForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueMovimentoEntradaDM(DataModule).DMOpen;
end;

procedure TInhEstoqueMovimentoEntradaForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueMovimentoEntradaForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;
   ProdutoLookUp := InhDbFastLookUpDlgNew (Self,
                                           TEstoqueMovimentoEntradaDM(DataModule).ProdutoDSource,
                                           1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueMovimentoEntradaDM(DataModule) do
            begin
               MovimentoDSet.Edit;
               MovimentoDSet.FieldByName('produto').Value := ProdutoDSet.FieldByName('id').Value;
               ProdutoDSource.DataSet.Filtered := False;
            end;
      end;
end;

procedure TInhEstoqueMovimentoEntradaForm.MasterDataSetBeforePost(
  DataSet: TDataSet);
begin
   with DataSet do
      begin
         if (State = dsInsert) then
            begin
               FieldByName('usuario').AsString := InhAccess.id;
               FieldByName('datahora').AsDateTime := Now();
               Tag := 111
            end;
      end;
end;

procedure TInhEstoqueMovimentoEntradaForm.RelatoriodeMovimento1Click(
  Sender: TObject);
begin
  inherited;

  InhReportEstoqueMovimentoSimplesTipoId (ietmEntrada,
                                          MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

procedure TInhEstoqueMovimentoEntradaForm.FornecedorButtonClick(
  Sender: TObject);
begin
  inherited;
   FornecedorLookUp := InhDbFastLookUpDlgNew (Self,
                                              TEstoqueMovimentoEntradaDM(DataModule).FornecedorDSource,
                                              1);
   FornecedorLookUp.ShowModal;

   if (FornecedorLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueMovimentoEntradaDM(DataModule) do
            begin
               MovimentoDSet.Edit;
               MovimentoDSet.FieldByName('fornecedor').Value := FornecedorDSet.FieldByName('id').Value;
               FornecedorDSource.DataSet.Filtered := False;
            end;
      end;
end;

end.
