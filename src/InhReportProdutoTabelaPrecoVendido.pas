unit InhReportProdutoTabelaPrecoVendido;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QExtCtrls, QButtons, QStdCtrls, QMask, InhReportProduto,
  Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, InhLookupPadrao,
  InhBiblio;

procedure InhReportProdutoTabelaPrecoVendidoDlgRun();

type
  TInhReportProdutoTabelaPrecoVendidoDlgForm = class(TInhOkCancelDlgForm)
    GroupBox1: TGroupBox;
    Button3: TButton;
    Button4: TButton;
    GrupoInicialMaskEdit: TMaskEdit;
    GrupoFinalMaskEdit: TMaskEdit;
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhReportProdutoTabelaPrecoVendidoDlgForm: TInhReportProdutoTabelaPrecoVendidoDlgForm;
  GrupoDSet : TSQLClientDataSet;
  GrupoDSource : TDataSource;

implementation

uses InhMainDM;

{$R *.xfm}

procedure InhReportProdutoTabelaPrecoVendidoDlgRun();
begin
   if InhReportProdutoTabelaPrecoVendidoDlgForm = nil then
      InhReportProdutoTabelaPrecoVendidoDlgForm := TInhReportProdutoTabelaPrecoVendidoDlgForm.Create(Application);
   if GrupoDSet = nil then
      begin
         GrupoDSet := TSQLClientDataSet.Create(Application);
         GrupoDSet.DBConnection := MainDM.MainConnection;
         GrupoDSet.CommandText := 'SELECT descricao, id FROM produto_grupo';
         GrupoDSet.Open;
      end;
   if GrupoDSource = nil then
      begin
         GrupoDSource := TDataSource.Create(Application);
         GrupoDSource.DataSet := GrupoDSet;
      end;

   InhReportProdutoTabelaPrecoVendidoDlgForm.GrupoInicialMaskEdit.Text := InhSelectFirstField('SELECT MIN(id) FROM produto_grupo');      
   InhReportProdutoTabelaPrecoVendidoDlgForm.GrupoFinalMaskEdit.Text := InhSelectFirstField('SELECT MAX(id) FROM produto_grupo');

   InhReportProdutoTabelaPrecoVendidoDlgForm.ShowModal;
end;

procedure TInhReportProdutoTabelaPrecoVendidoDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   InhReportTabelaPrecoProdutosVendidos (StrToInt (GrupoInicialMaskEdit.Text),
                                         StrToInt (GrupoFinalMaskEdit.Text));

end;

procedure TInhReportProdutoTabelaPrecoVendidoDlgForm.Button3Click(
  Sender: TObject);
begin
  inherited;
   if (InhLookupFromDataSource (GrupoDSource, 'descricao') = mrOk) then
      GrupoInicialMaskEdit.Text := GrupoDSource.DataSet.FieldValues['id'];
end;

procedure TInhReportProdutoTabelaPrecoVendidoDlgForm.Button4Click(
  Sender: TObject);
begin
  inherited;
   if (InhLookupFromDataSource (GrupoDSource, 'descricao') = mrOk) then
      GrupoFinalMaskEdit.Text := GrupoDSource.DataSet.FieldValues['id'];
end;

procedure TInhReportProdutoTabelaPrecoVendidoDlgForm.FormClose(
  Sender: TObject; var Action: TCloseAction);
begin
  inherited;
//   FreeAndNil(GrupoDSet);
//   FreeAndNil(GrupoDSource);
   InhReportProdutoTabelaPrecoVendidoDlgForm.Release;
//   InhReportProdutoTabelaPrecoVendidoDlgForm := nil;
end;

end.
