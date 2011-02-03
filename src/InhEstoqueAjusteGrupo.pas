unit InhEstoqueAjusteGrupo;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhDbForm, QActnList, QMenus, QComCtrls, QDBCtrls,
  QExtCtrls, QButtons, QMask, DB, InhBiblio, InhDbGridUtils, InhLookupPadrao,

  InhEstoqueAjusteGrupoDM, QGrids, QDBGrids;

type
  TInhEstoqueAjusteGrupoForm = class(TInhDbForm)
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
    AjustesTabSheet: TTabSheet;
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

function EstoqueAjusteGrupoFormNew() : TInhEstoqueAjusteGrupoForm;

implementation

{$R *.xfm}

function EstoqueAjusteGrupoFormNew() : TInhEstoqueAjusteGrupoForm;
var
   MyForm : TInhEstoqueAjusteGrupoForm;
begin
   MyForm := TInhEstoqueAjusteGrupoForm.Create(Application);

   if (MyForm.DataModule = nil) then
      MyForm.DataModule := TEstoqueAjusteGrupoDM.Create(Application);

   TEstoqueAjusteGrupoDM(MyForm.DataModule).DbForm := MyForm;

   MyForm.MasterDataSource := TEstoqueAjusteGrupoDM(MyForm.DataModule).AjusteGrupoDSource;

   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.MasterDataSource.DataSet.BeforePost := MyForm.MasterDataSetBeforePost;

   MyForm.FirstControl := MyForm.DepartamentoDbLookupComboBox;

   MyForm.HelpTopic := 'capitulo_cadastro_estoque_movimento_entrada';

   Result := MyForm;
end;

{ TInhEstoqueAjusteGrupoForm }

procedure TInhEstoqueAjusteGrupoForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEstoqueAjusteGrupoForm.MasterDataSetAfterScroll(
  DataSet: TDataSet);
begin
   TEstoqueAjusteGrupoDM(DataModule).DMOpen;
end;

procedure TInhEstoqueAjusteGrupoForm.MasterDataSetBeforePost(
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

procedure TInhEstoqueAjusteGrupoForm.MovimentosDbGridEditButtonClick(
  Sender: TObject);
begin
  inherited;
   if (TEstoqueAjusteGrupoDM(DataModule).AjustesDSet.FieldByName('produto').AsInteger > 0) then
      TEstoqueAjusteGrupoDM(DataModule).ProdutosDSet.Locate('id', VarArrayOf([TEstoqueAjusteGrupoDM(DataModule).AjustesDSet.FieldByName('produto').AsInteger]), []);

   if (InhLookupFromDataSource(TEstoqueAjusteGrupoDM(DataModule).ProdutosDSource, 'descricao') = mrOk) then
      begin
          TEstoqueAjusteGrupoDM(DataModule).AjustesDSet.Edit;
          TEstoqueAjusteGrupoDM(DataModule).AjustesDSet.FieldByName('produto').Value := TEstoqueAjusteGrupoDM(DataModule).ProdutosDSet.FieldByName('id').AsInteger;
      end;
   TEstoqueAjusteGrupoDM(DataModule).ProdutosDSet.Filtered := False;
end;

procedure TInhEstoqueAjusteGrupoForm.MovimentosDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

end.
