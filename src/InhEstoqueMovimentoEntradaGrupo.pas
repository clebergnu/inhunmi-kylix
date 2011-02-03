unit InhEstoqueMovimentoEntradaGrupo;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhBiblio, InhDbGridUtils, InhLookupPadrao,
  InhDbFastLookUpDlg,

  InhEstoqueMovimentoEntradaGrupoDM, QGrids, QDBGrids;

type
  TInhEstoqueMovimentoEntradaGrupoForm = class(TInhDbForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    DepartamentoLabel: TLabel;
    DepartamentoDbLookupComboBox: TDBLookupComboBox;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    ObservacaoDbEdit: TDBEdit;
    PageControl1: TPageControl;
    EntradasTabSheet: TTabSheet;
    MovimentosDbGrid: TDBGrid;
    Button1: TButton;
    FornecedorIdDbEdit: TDBEdit;
    FornecedorDbEdit: TDBEdit;
    DBEdit1: TDBEdit;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure MasterDataSetAfterScroll (DataSet : TDataSet);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
    procedure MovimentosDbGridEditButtonClick(Sender: TObject);
    procedure MovimentosDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
  private
     FornecedorLookUp : TInhDbFastLookUpDlgForm;
  public
    { Public declarations }
  end;

function EstoqueMovimentoEntradaGrupoFormNew() : TInhEstoqueMovimentoEntradaGrupoForm;

implementation

{$R *.xfm}

function EstoqueMovimentoEntradaGrupoFormNew() : TInhEstoqueMovimentoEntradaGrupoForm;
var
   MyForm : TInhEstoqueMovimentoEntradaGrupoForm;
begin
   MyForm := TInhEstoqueMovimentoEntradaGrupoForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueMovimentoEntradaGrupoDM.Create(Application);

   TEstoqueMovimentoEntradaGrupoDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueMovimentoEntradaGrupoDM(MyForm.DataModule).MovimentoGrupoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.DepartamentoDbLookupComboBox;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_entrada';

   Result := MyForm;
end;

{ TInhEstoqueMovimentoEntradaGrupoForm }

procedure TInhEstoqueMovimentoEntradaGrupoForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueMovimentoEntradaGrupoForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueMovimentoEntradaGrupoDM(DataModule).DMOpen;
end;

procedure TInhEstoqueMovimentoEntradaGrupoForm.MasterDataSetBeforePost(
  DataSet: TDataSet);
begin
   with DataSet do
      begin
         if (State = dsInsert) then
            begin
               FieldByName('usuario').AsString := InhAccess.id;
               if (FieldByName('datahora').IsNull) then
                  FieldByName('datahora').AsDateTime := Now();
               Tag := 111
            end;
      end;
end;

procedure TInhEstoqueMovimentoEntradaGrupoForm.MovimentosDbGridEditButtonClick(
  Sender: TObject);
begin
  inherited;
   if (TEstoqueMovimentoEntradaGrupoDM(DataModule).MovimentosClientDSet.FieldByName('produto').AsInteger > 0) then
      TEstoqueMovimentoEntradaGrupoDM(DataModule).ProdutosDSet.Locate('id', VarArrayOf([TEstoqueMovimentoEntradaGrupoDM(DataModule).MovimentosClientDSet.FieldByName('produto').AsInteger]), []);

   if (InhLookupFromDataSource(TEstoqueMovimentoEntradaGrupoDM(DataModule).ProdutosDSource, 'descricao') = mrOk) then
      begin
          TEstoqueMovimentoEntradaGrupoDM(DataModule).MovimentosClientDSet.Edit;
          TEstoqueMovimentoEntradaGrupoDM(DataModule).MovimentosClientDSet.FieldByName('produto').Value := TEstoqueMovimentoEntradaGrupoDM(DataModule).ProdutosDSet.FieldByName('id').AsInteger;
      end;
   TEstoqueMovimentoEntradaGrupoDM(DataModule).ProdutosDSet.Filtered := False;

//   with Sender as TDBGrid do
//      SelectedIndex := SelectedIndex + 1;
end;

procedure TInhEstoqueMovimentoEntradaGrupoForm.MovimentosDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

procedure TInhEstoqueMovimentoEntradaGrupoForm.Button1Click(
  Sender: TObject);
begin
  inherited;
   FornecedorLookUp := InhDbFastLookUpDlgNew (Self,
                                              TEstoqueMovimentoEntradaGrupoDM(DataModule).FornecedorDSource,
                                              1);
   FornecedorLookUp.ShowModal;

   if (FornecedorLookUp.ModalResult = mrOK) then
      begin
         with TEstoqueMovimentoEntradaGrupoDM(DataModule) do
            begin
               MovimentoGrupoDSet.Edit;
               MovimentoGrupoDSet.FieldByName('fornecedor').Value := FornecedorDSet.FieldByName('id').Value;
               FornecedorDSet.DataSet.Filtered := False;
            end;
      end;
end;

end.
