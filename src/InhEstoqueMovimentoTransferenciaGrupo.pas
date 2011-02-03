unit InhEstoqueMovimentoTransferenciaGrupo;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhBiblio, InhDbGridUtils, InhLookupPadrao,

  InhEstoqueMovimentoTransferenciaGrupoDM, QGrids, QDBGrids;

type
  TInhEstoqueMovimentoTransferenciaGrupoForm = class(TInhDbForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    DeptoOrigemLabel: TLabel;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    ObservacaoDbEdit: TDBEdit;
    PageControl1: TPageControl;
    TransferenciasTabSheet: TTabSheet;
    MovimentosDbGrid: TDBGrid;
    DeptoOrigemDbLookupComboBox: TDBLookupComboBox;
    Label1: TLabel;
    DeptoDestinoDbLookupComboBox: TDBLookupComboBox;
    procedure FormShow(Sender: TObject);
    procedure MasterDataSetAfterScroll (DataSet : TDataSet);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
    procedure MovimentosDbGridEditButtonClick(Sender: TObject);
    procedure MovimentosDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function EstoqueMovimentoTransferenciaGrupoFormNew() : TInhEstoqueMovimentoTransferenciaGrupoForm;

implementation

{$R *.xfm}

function EstoqueMovimentoTransferenciaGrupoFormNew() : TInhEstoqueMovimentoTransferenciaGrupoForm;
var
   MyForm : TInhEstoqueMovimentoTransferenciaGrupoForm;
begin
   MyForm := TInhEstoqueMovimentoTransferenciaGrupoForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueMovimentoTransferenciaGrupoDM.Create(Application);

   TEstoqueMovimentoTransferenciaGrupoDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueMovimentoTransferenciaGrupoDM(MyForm.DataModule).MovimentoGrupoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.DeptoOrigemDbLookupComboBox;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_entrada';

   Result := MyForm;
end;

{ TInhEstoqueMovimentoTransferenciaGrupoForm }

procedure TInhEstoqueMovimentoTransferenciaGrupoForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueMovimentoTransferenciaGrupoForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueMovimentoTransferenciaGrupoDM(DataModule).DMOpen;
end;

procedure TInhEstoqueMovimentoTransferenciaGrupoForm.MasterDataSetBeforePost(
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

procedure TInhEstoqueMovimentoTransferenciaGrupoForm.MovimentosDbGridEditButtonClick(
  Sender: TObject);
begin
  inherited;
   if (TEstoqueMovimentoTransferenciaGrupoDM(DataModule).MovimentosDSet.FieldByName('produto').AsInteger > 0) then
      TEstoqueMovimentoTransferenciaGrupoDM(DataModule).ProdutosDSet.Locate('id', VarArrayOf([TEstoqueMovimentoTransferenciaGrupoDM(DataModule).MovimentosDSet.FieldByName('produto').AsInteger]), []);

   if (InhLookupFromDataSource(TEstoqueMovimentoTransferenciaGrupoDM(DataModule).ProdutosDSource, 'descricao') = mrOk) then
      begin
          TEstoqueMovimentoTransferenciaGrupoDM(DataModule).MovimentosDSet.Edit;
          TEstoqueMovimentoTransferenciaGrupoDM(DataModule).MovimentosDSet.FieldByName('produto').Value := TEstoqueMovimentoTransferenciaGrupoDM(DataModule).ProdutosDSet.FieldByName('id').AsInteger;
      end;
   TEstoqueMovimentoTransferenciaGrupoDM(DataModule).ProdutosDSet.Filtered := False;
end;

procedure TInhEstoqueMovimentoTransferenciaGrupoForm.MovimentosDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

end.
