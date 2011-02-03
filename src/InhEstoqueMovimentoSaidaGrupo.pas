unit InhEstoqueMovimentoSaidaGrupo;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhBiblio, InhDbGridUtils, InhLookupPadrao,

  InhEstoqueMovimentoSaidaGrupoDM, QGrids, QDBGrids;

type
  TInhEstoqueMovimentoSaidaGrupoForm = class(TInhDbForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    DepartamentoLabel: TLabel;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    ObservacaoLabel: TLabel;
    ObservacaoDbEdit: TDBEdit;
    PageControl1: TPageControl;
    SaidasTabSheet: TTabSheet;
    MovimentosDbGrid: TDBGrid;
    DepartamentoDbLookupComboBox: TDBLookupComboBox;
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

function EstoqueMovimentoSaidaGrupoFormNew() : TInhEstoqueMovimentoSaidaGrupoForm;

implementation

{$R *.xfm}

function EstoqueMovimentoSaidaGrupoFormNew() : TInhEstoqueMovimentoSaidaGrupoForm;
var
   MyForm : TInhEstoqueMovimentoSaidaGrupoForm;
begin
   MyForm := TInhEstoqueMovimentoSaidaGrupoForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueMovimentoSaidaGrupoDM.Create(Application);

   TEstoqueMovimentoSaidaGrupoDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueMovimentoSaidaGrupoDM(MyForm.DataModule).MovimentoGrupoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.DepartamentoDbLookupComboBox;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_entrada';

   Result := MyForm;
end;

{ TInhEstoqueMovimentoSaidaGrupoForm }

procedure TInhEstoqueMovimentoSaidaGrupoForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueMovimentoSaidaGrupoForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueMovimentoSaidaGrupoDM(DataModule).DMOpen;
end;

procedure TInhEstoqueMovimentoSaidaGrupoForm.MasterDataSetBeforePost(
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

procedure TInhEstoqueMovimentoSaidaGrupoForm.MovimentosDbGridEditButtonClick(
  Sender: TObject);
begin
  inherited;
   if (TEstoqueMovimentoSaidaGrupoDM(DataModule).MovimentosDSet.FieldByName('produto').AsInteger > 0) then
      TEstoqueMovimentoSaidaGrupoDM(DataModule).ProdutosDSet.Locate('id', VarArrayOf([TEstoqueMovimentoSaidaGrupoDM(DataModule).MovimentosDSet.FieldByName('produto').AsInteger]), []);

   if (InhLookupFromDataSource(TEstoqueMovimentoSaidaGrupoDM(DataModule).ProdutosDSource, 'descricao') = mrOk) then
      begin
          TEstoqueMovimentoSaidaGrupoDM(DataModule).MovimentosDSet.Edit;
          TEstoqueMovimentoSaidaGrupoDM(DataModule).MovimentosDSet.FieldByName('produto').Value := TEstoqueMovimentoSaidaGrupoDM(DataModule).ProdutosDSet.FieldByName('id').AsInteger;
      end;
   TEstoqueMovimentoSaidaGrupoDM(DataModule).ProdutosDSet.Filtered := False;
end;

procedure TInhEstoqueMovimentoSaidaGrupoForm.MovimentosDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

end.
