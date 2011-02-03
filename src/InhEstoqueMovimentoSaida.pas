unit InhEstoqueMovimentoSaida;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhDbFastLookUpDlg, InhBiblio, InhDlgUtils,

  InhReportEstoqueMovimentoSimples;

type
  TInhEstoqueMovimentoSaidaForm = class(TInhDbForm)
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
    RelatriodeMovimento1: TMenuItem;
    procedure MasterDataSetAfterScroll (DataSet : TDataSet);
    procedure FormShow(Sender: TObject);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
    procedure RelatriodeMovimento1Click(Sender: TObject);
  private
     ProdutoLookUp : TInhDbFastLookUpDlgForm;
    { Private declarations }
  public
    { Public declarations }
  end;

function EstoqueMovimentoSaidaFormNew() : TInhEstoqueMovimentoSaidaForm;

implementation

uses InhEstoqueMovimentoSaidaDM;

{$R *.xfm}

function EstoqueMovimentoSaidaFormNew() : TInhEstoqueMovimentoSaidaForm;
var
   MyForm : TInhEstoqueMovimentoSaidaForm;
begin
   MyForm := TInhEstoqueMovimentoSaidaForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueMovimentoSaidaDM.Create(Application);

   TEstoqueMovimentoSaidaDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueMovimentoSaidaDM(MyForm.DataModule).MovimentoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.ProdutoButton;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_entrada';

   Result := MyForm;
end;

procedure TInhEstoqueMovimentoSaidaForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueMovimentoSaidaDM(DataModule).DMOpen;
end;

procedure TInhEstoqueMovimentoSaidaForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueMovimentoSaidaForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;
  if (ProdutoLookUp = nil) then
      ProdutoLookUp := InhDbFastLookUpDlgNew (Self,
                                              TEstoqueMovimentoSaidaDM(DataModule).ProdutoDSource,
                                              1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueMovimentoSaidaDM(DataModule) do
            begin
               MovimentoDSet.Edit;
               MovimentoDSet.FieldByName('produto').Value := ProdutoDSet.FieldByName('id').Value;
               ProdutoDSource.DataSet.Filtered := False;
            end;
      end;
end;

procedure TInhEstoqueMovimentoSaidaForm.MasterDataSetBeforePost(
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

procedure TInhEstoqueMovimentoSaidaForm.RelatriodeMovimento1Click(
  Sender: TObject);
begin
  inherited;
  InhReportEstoqueMovimentoSimplesTipoId (ietmSaida,
                                          MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

end.
