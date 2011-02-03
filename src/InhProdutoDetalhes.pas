unit InhProdutoDetalhes;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QGrids, QDBGrids, QComCtrls, QMask, QDBCtrls, Qt,
  QExtCtrls, QButtons, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,

  InhBiblio, InhLookupPadrao, InhDbGridUtils;

type
  TInhProdutoDetalhesForm = class(TForm)
    IdLabel: TLabel;
    DescricaoLabel: TLabel;
    PageControl: TPageControl;
    ComposicaoTabSheet: TTabSheet;
    ComposicaoDBGrid: TDBGrid;
    TabSheet2: TTabSheet;
    EquivalenciaDbGrid: TDBGrid;
    TabSheet3: TTabSheet;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    RendimentoPercaTotalDbEdit: TDBEdit;
    FornecedoresTabSheet: TTabSheet;
    GroupBox1: TGroupBox;
    DBGrid2: TDBGrid;
    StatusBar: TStatusBar;
    SairSpeedButton: TSpeedButton;
    ProdutoDescricaoDbEdit: TDBEdit;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    ProdutoIdDbEdit: TDBEdit;
    ComposicaoDSet: TSQLClientDataSet;
    ComposicaoDSource: TDataSource;
    ComposicaoDSetid: TIntegerField;
    ComposicaoDSetdono: TIntegerField;
    ComposicaoDSetcomposicao: TIntegerField;
    ComposicaoDSetquantidade: TFloatField;
    ProdutosDSet: TSQLClientDataSet;
    ProdutosDSource: TDataSource;
    ComposicaoDSetproduto_descricao: TStringField;
    ComposicaoDSetproduto_unidade: TStringField;
    ProdutosGeneralizadosDSource: TDataSource;
    ProdutosGeneralizadosDSet: TSQLClientDataSet;
    EquivalenciaDSet: TSQLClientDataSet;
    EquivalenciaDSource: TDataSource;
    EquivalenciaDSetid: TIntegerField;
    EquivalenciaDSetdono: TIntegerField;
    EquivalenciaDSetequivalencia: TIntegerField;
    EquivalenciaDSetquantidade: TFloatField;
    EquivalenciaDSetproduto_descricao: TStringField;
    EquivalenciaDSetproduto_unidade: TStringField;
    GroupBox2: TGroupBox;
    ComprasDSet: TSQLClientDataSet;
    ComprasDSource: TDataSource;
    ComprasDSetgrupo_id: TIntegerField;
    ComprasDSetmovimento_id: TIntegerField;
    ComprasDSetfornecedor: TStringField;
    ComprasDSetquantidade: TIntegerField;
    ComprasDSetvalor_total: TFloatField;
    ComprasDSetvalor_unitario: TFloatField;
    ComprasDSetdatahora: TSQLTimeStampField;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SairSpeedButtonClick(Sender: TObject);
    procedure ComposicaoDBGridEditButtonClick(Sender: TObject);
    procedure ComposicaoDBGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComposicaoDSetBeforePost(DataSet: TDataSet);
    procedure ComposicaoDSetAfterPost(DataSet: TDataSet);
    procedure EquivalenciaDSetAfterPost(DataSet: TDataSet);
    procedure EquivalenciaDSetBeforePost(DataSet: TDataSet);
    procedure EquivalenciaDbGridEditButtonClick(Sender: TObject);
    procedure EquivalenciaDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    ProdutoId : integer;
  public
  end;

procedure InhProdutoDetalhesRun (AOwner : TComponent;
                                 ProdutoId : integer);

implementation

{$R *.xfm}

procedure InhProdutoDetalhesRun (AOwner : TComponent;
                                 ProdutoId : integer);
var
   MyForm : TInhProdutoDetalhesForm;
begin
   MyForm := TInhProdutoDetalhesForm.Create(AOwner);

   MyForm.ProdutoId := ProdutoId;

   with MyForm do
      begin
         PageControl.ActivePageIndex := 0;

         ProdutoDSet.Params[0].Value := ProdutoId;
         ProdutoDSet.Open;

         ProdutosDSet.Open;

         ComposicaoDSet.Params[0].Value := ProdutoId;
         ComposicaoDSet.Open;

         ProdutosGeneralizadosDSet.Open;

         EquivalenciaDSet.Params[0].Value := ProdutoId;
         EquivalenciaDSet.Open;

         ComprasDSet.Params[0].Value := ProdutoId;
         ComprasDSet.Open;

         Show;
      end;
end;

procedure TInhProdutoDetalhesForm.SairSpeedButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TInhProdutoDetalhesForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Release;
end;

procedure TInhProdutoDetalhesForm.ComposicaoDBGridEditButtonClick(
  Sender: TObject);
begin
   if (ComposicaoDSet.FieldByName('composicao').AsInteger > 0) then
      ProdutosDSet.Locate('id', VarArrayOf([ComposicaoDSet.FieldByName('composicao').AsInteger]), []);

   if (InhLookupFromDataSource(ProdutosDSource, 'descricao') = mrOk) then
      begin
          ComposicaoDSet.Edit;
          ComposicaoDSet.FieldByName('composicao').Value := ProdutosDSet.FieldByName('id').AsInteger;
      end;
   ProdutosDSet.Filtered := False;
   with Sender as TDBGrid do
      SelectedIndex := SelectedIndex + 1;
end;

procedure TInhProdutoDetalhesForm.ComposicaoDBGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

procedure TInhProdutoDetalhesForm.ComposicaoDSetBeforePost(
  DataSet: TDataSet);
begin
   if (DataSet.State = dsInsert) then
      DataSet.FieldByName('dono').AsInteger := ProdutoDSet.FieldByName('id').AsInteger;
end;

procedure TInhProdutoDetalhesForm.ComposicaoDSetAfterPost(
  DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost(DataSet);
end;

procedure TInhProdutoDetalhesForm.EquivalenciaDSetAfterPost(
  DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost(DataSet);
end;

procedure TInhProdutoDetalhesForm.EquivalenciaDSetBeforePost(
  DataSet: TDataSet);
begin
   if (DataSet.State = dsInsert) then
      DataSet.FieldByName('dono').AsInteger := ProdutoDSet.FieldByName('id').AsInteger;
end;

procedure TInhProdutoDetalhesForm.EquivalenciaDbGridEditButtonClick(
  Sender: TObject);
begin
   if (EquivalenciaDSet.FieldByName('equivalencia').AsInteger > 0) then
      ProdutosDSet.Locate('id', VarArrayOf([EquivalenciaDSet.FieldByName('equivalencia').AsInteger]), []);

   if (InhLookupFromDataSource(ProdutosGeneralizadosDSource, 'descricao') = mrOk) then
      begin
          EquivalenciaDSet.Edit;
          EquivalenciaDSet.FieldByName('equivalencia').Value := ProdutosGeneralizadosDSet.FieldByName('id').AsInteger;
      end;
   ProdutosDSet.Filtered := False;
   with Sender as TDBGrid do
      SelectedIndex := SelectedIndex + 1;
end;


procedure TInhProdutoDetalhesForm.EquivalenciaDbGridKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

end.
