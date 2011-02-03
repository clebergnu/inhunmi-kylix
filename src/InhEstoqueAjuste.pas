unit InhEstoqueAjuste;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhDbFastLookUpDlg, InhBiblio, InhDlgUtils,

  InhReportEstoqueMovimentoSimples, InhEstoqueUtils;

type
  TInhEstoqueAjusteForm = class(TInhDbForm)
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
    DeptoDbLookupComboBox: TDBLookupComboBox;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    ObservacaoDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    RelatriodeAjuste1: TMenuItem;
    procedure MasterDataSetAfterScroll (DataSet : TDataSet);
    procedure FormShow(Sender: TObject);
    procedure ProdutoButtonClick(Sender: TObject);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
    procedure RelatriodeAjuste1Click(Sender: TObject);
  private
     ProdutoLookUp : TInhDbFastLookUpDlgForm;
    { Private declarations }
  public
    { Public declarations }
  end;

function EstoqueAjusteFormNew() : TInhEstoqueAjusteForm;

implementation

uses InhEstoqueAjusteDM;

{$R *.xfm}

function EstoqueAjusteFormNew() : TInhEstoqueAjusteForm;
var
   MyForm : TInhEstoqueAjusteForm;
begin
   MyForm := TInhEstoqueAjusteForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueAjusteDM.Create(Application);

   TEstoqueAjusteDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueAjusteDM(MyForm.DataModule).MovimentoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.ProdutoButton;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_ajuste';

   Result := MyForm;
end;

procedure TInhEstoqueAjusteForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueAjusteDM(DataModule).DMOpen;
end;

procedure TInhEstoqueAjusteForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueAjusteForm.ProdutoButtonClick(
  Sender: TObject);
begin
  inherited;
  if (ProdutoLookUp = nil) then
      ProdutoLookUp := InhDbFastLookUpDlgNew (Self,
                                              TEstoqueAjusteDM(DataModule).ProdutoDSource,
                                              1);
   ProdutoLookUp.ShowModal;

   if (ProdutoLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueAjusteDM(DataModule) do
            begin
               MovimentoDSet.Edit;
               MovimentoDSet.FieldByName('produto').Value := ProdutoDSet.FieldByName('id').Value;
               ProdutoDSource.DataSet.Filtered := False;
            end;
      end;
end;

procedure TInhEstoqueAjusteForm.MasterDataSetBeforePost(
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

procedure TInhEstoqueAjusteForm.RelatriodeAjuste1Click(Sender: TObject);
begin
  inherited;
   InhReportEstoqueMovimentoSimplesTipoId (ietmAjuste,
                                           MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

end.
