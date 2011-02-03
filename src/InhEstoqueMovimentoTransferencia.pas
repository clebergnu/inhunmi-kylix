unit InhEstoqueMovimentoTransferencia;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhDbFastLookUpDlg, InhBiblio, InhDlgUtils,

  InhReportEstoqueMovimentoSimples, InhEstoqueUtils;

type
  TInhEstoqueMovimentoTransferenciaForm = class(TInhDbForm)
    IDLabel: TLabel;
    IDDbEdit: TDBEdit;
    DepartamentoOrigemLabel: TLabel;
    ProdutoIDDbEdit: TDBEdit;
    ProdutoDbEdit: TDBEdit;
    ProdutoButton: TButton;
    QuantidadeDbEdit: TDBEdit;
    QuantidadeLabel: TLabel;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    DeptoOrigemDbLookupComboBox: TDBLookupComboBox;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    ObservacaoDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    DeptoDestinoLabel: TLabel;
    DeptoDestinoDbLookupComboBox: TDBLookupComboBox;
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

function EstoqueMovimentoTransferenciaFormNew() : TInhEstoqueMovimentoTransferenciaForm;

implementation

uses InhEstoqueMovimentoTransferenciaDM;

{$R *.xfm}

function EstoqueMovimentoTransferenciaFormNew() : TInhEstoqueMovimentoTransferenciaForm;
var
   MyForm : TInhEstoqueMovimentoTransferenciaForm;
begin
   MyForm := TInhEstoqueMovimentoTransferenciaForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueMovimentoTransferenciaDM.Create(Application);

   TEstoqueMovimentoTransferenciaDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueMovimentoTransferenciaDM(MyForm.DataModule).MovimentoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.ProdutoButton;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_transferencia';

   Result := MyForm;
end;

procedure TInhEstoqueMovimentoTransferenciaForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueMovimentoTransferenciaDM(DataModule).DMOpen;
end;

procedure TInhEstoqueMovimentoTransferenciaForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueMovimentoTransferenciaForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;
  if (ProdutoLookUp = nil) then
      ProdutoLookUp := InhDbFastLookUpDlgNew (Self,
                                              TEstoqueMovimentoTransferenciaDM(DataModule).ProdutoDSource,
                                              1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueMovimentoTransferenciaDM(DataModule) do
            begin
               MovimentoDSet.Edit;
               MovimentoDSet.FieldByName('produto').Value := ProdutoDSet.FieldByName('id').Value;
               ProdutoDSource.DataSet.Filtered := False;
            end;
      end;
end;

procedure TInhEstoqueMovimentoTransferenciaForm.MasterDataSetBeforePost(
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

procedure TInhEstoqueMovimentoTransferenciaForm.RelatriodeMovimento1Click(
  Sender: TObject);
begin
  inherited;

  InhReportEstoqueMovimentoSimplesTipoId (ietmTransferencia,
                                          MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

end.
