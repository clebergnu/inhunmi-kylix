unit InhEncomenda;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhDbForm, QActnList, QTypes, QMenus, QComCtrls, QDBCtrls, QExtCtrls,
  QButtons, QStdCtrls, QMask, QGrids, QDBGrids, DB,
  InhLookUpPadrao, InhBiblio, Qt;

type
  TInhEncomendaForm = class(TInhDbForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    DonoButton: TButton;
    DonoIdDbEdit: TDBEdit;
    DonoNomeDbEdit: TDBEdit;
    RelatorioProducao: TAction;
    Relatriodeprodutosparaproduo1: TMenuItem;
    DetalhesEncomenda: TAction;
    DetalhesdaEncomenda1: TMenuItem;
    DetalhesProdutosEncomenda: TAction;
    DetalhesProdutosDaEncomenda1: TMenuItem;
    DetailsGroupBox: TGroupBox;
    PageControl1: TPageControl;
    ProdutosTabSheet: TTabSheet;
    StatusDbComboBox: TDBComboBox;
    StatusLabel: TLabel;
    ProdutosDbGrid: TDBGrid;
    EntregaGroupBox: TGroupBox;
    TipoEntregaDbCheckBox: TDBCheckBox;
    DataHoraEntregaLabel: TLabel;
    DataHoraEntregaDbEdit: TDBEdit;
    EnderecoEntregaDbMemo: TDBMemo;
    EnderecoEntregaButton: TButton;
    TotalProdutosLabel: TLabel;
    TotalProdutosDbEdit: TDBEdit;
    TaxaEntregaLabel: TLabel;
    TaxaEntregaDbEdit: TDBEdit;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    DBMemo1: TDBMemo;
    DetahesProdutosProducao: TAction;
    DetalhesProdutosProduo1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure RelatorioProducaoExecute(Sender: TObject);
    procedure DetalhesEncomendaExecute(Sender: TObject);
    procedure DetalhesProdutosEncomendaExecute(Sender: TObject);
    procedure DonoButtonClick(Sender: TObject);
    procedure EnderecoEntregaButtonClick(Sender: TObject);
    procedure MasterDataSetAfterScroll(DataSet : TDataSet);
    procedure DetahesProdutosProducaoExecute(Sender: TObject);
    procedure ProdutosDbGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    // Temporarily Removed
    //    DonoLookUp     : TInhDbFastLookUpDlgForm;
    //    EnderecoLookUp : TInhDbFastLookUpDlgForm;
   public
    { Public declarations }
  end;

  function EncomendaFormNew () : TInhEncomendaForm;

implementation

uses InhEncomendaDM, InhReportEncomenda, InhDbGridUtils, InhDlgUtils;

{$R *.xfm}

function EncomendaFormNew () : TInhEncomendaForm;
var
   MyForm : TInhEncomendaForm;
begin
   MyForm := TInhEncomendaForm.Create(Application);

   if (EncomendaDM = nil) then
      EncomendaDM := TEncomendaDM.Create(Application);

   MyForm.DataModule := EncomendaDM;
   EncomendaDM.DbForm := MyForm;

   MyForm.MasterDataSource := EncomendaDM.PortaConsumoDSource;
   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.JointDataSource := EncomendaDM.EncomendaDSource;

   MyForm.FirstControl := MyForm.DonoButton;
   MyForm.DetailsBox := MyForm.DetailsGroupBox;

   MyForm.HelpTopic := 'capitulo_cadastro_encomendas';

   Result := MyForm;
end;

procedure TInhEncomendaForm.FormShow(Sender: TObject);
begin
   MasterDataSource.DataSet.AfterInsert := TInhDbForm(Self).MasterDataSetAfterInsert;
   MasterDataSource.DataSet.AfterEdit   := TInhDbForm(Self).MasterDataSetAfterEdit;
   MasterDataSource.DataSet.AfterDelete := TInhDbForm(Self).MasterDataSetAfterDelete;
   if (JointDataSource <> nil) then
      JointDataSource.DataSet.AfterEdit := TInhDbForm(Self).JointDataSetAfterEdit;
   //Navigator setup
   Navigator.DataSource := MasterDataSource;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

procedure TInhEncomendaForm.RelatorioProducaoExecute(Sender: TObject);
begin
  inherited;
   InhReportEncomendaProducao (MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

procedure TInhEncomendaForm.DetalhesEncomendaExecute(Sender: TObject);
begin
  inherited;
   InhReportEncomendaDetails (MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

procedure TInhEncomendaForm.DetalhesProdutosEncomendaExecute(
  Sender: TObject);
begin
  inherited;
   InhReportEncomendaDetailsAndProducts (MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

procedure TInhEncomendaForm.DonoButtonClick(Sender: TObject);
begin
  inherited;
   // Temporarily Removed
{   if (DonoLookUp = nil) then
      DonoLookUp := InhDbFastLookUpDlgNew (Self, EncomendaDM.NomeTelefoneDSource);
   DonoLookUp.ShowModal;}

   if (EncomendaDM.NomeTelefoneDSet.Active = true) then
      EncomendaDM.NomeTelefoneDSet.Close;

   EncomendaDM.NomeTelefoneDSet.Open;

   if (InhLookUpFromDataSource (EncomendaDM.NomeTelefoneDSource, 'nome') = mrOK) then
      begin
         MasterDataSource.DataSet.Edit;
         MasterDataSource.DataSet.FieldValues['dono'] := EncomendaDM.NomeTelefoneDSet.FieldValues['id'];
      end;
end;

procedure TInhEncomendaForm.EnderecoEntregaButtonClick(Sender: TObject);
begin
  inherited;
   if (EncomendaDM.EnderecoDSet.Active = true) then
      EncomendaDM.EnderecoDSet.Close;

   EncomendaDM.EnderecoDSet.Params[0].Value := EncomendaDM.PortaConsumoDSet.FieldValues['dono'];
   EncomendaDM.EnderecoDSet.Open;

   if EncomendaDM.EnderecoDSet.RecordCount = 0 then
      InhDlg ('Desculpe, mas este cliente não possui endereços cadastrados.')
   else if (InhLookUpFromDataSource (EncomendaDM.EnderecoDSource, 'endenreco') = mrOK) then
      begin
        EncomendaDM.EncomendaDSet.Edit;
        EncomendaDM.EncomendaDSet.FieldValues['local_entrega'] := EncomendaDM.EnderecoDSet.FieldValues['endereco'];
      end;

   // Temporarily Removed
{   if EnderecoLookUp = nil then
      EnderecoLookUp := InhDbFastLookUpDlgNew (Self, EncomendaDM.EnderecoDSource);
   EnderecoLookUp.ShowModal;}
end;

procedure TInhEncomendaForm.MasterDataSetAfterScroll(DataSet: TDataSet);
begin
   TEncomendaDM(DataModule).DMOpen;
end;

procedure TInhEncomendaForm.DetahesProdutosProducaoExecute(
  Sender: TObject);
begin
  inherited;
   InhReportEncomendaDetailsAndProductsAndProducao (MasterDataSource.DataSet.FieldByName('id').AsInteger);
end;

procedure TInhEncomendaForm.ProdutosDbGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

end.
