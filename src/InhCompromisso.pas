unit InhCompromisso;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QDBCtrls, QExtCtrls, QButtons, InhCompromissoDM, QStdCtrls,
  QMask, InhBiblio, QComCtrls, QGrids, QDBGrids, InhPessoaInstituicaoLookupDlg,
  InhDbForm, QActnList, QTypes, QMenus;

type
  TInhCompromissoForm = class(TInhDbForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    TipoLabel: TLabel;
    StatusLabel: TLabel;
    SituacaoLabel: TLabel;
    DonoButton: TButton;
    DonoNomeDbEdit: TDBEdit;
    TipoDbComboBox: TDBComboBox;
    StatusDbComboBox: TDBComboBox;
    SituacaoDbComboBox: TDBComboBox;
    Label1: TLabel;
    DocumentoDbEdit: TDBEdit;
    Label2: TLabel;
    DescricaoDbEdit: TDBEdit;
    DataDbEdit: TDBEdit;
    Label3: TLabel;
    DetailsPageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    TabSheet3: TTabSheet;
    DBGrid3: TDBGrid;
    Label4: TLabel;
    ProdutoTotalDbEdit: TDBEdit;
    Label5: TLabel;
    ValorDbEdit: TDBEdit;
    DespesaTotalDbEdit: TDBEdit;
    DespesaTotalLabel: TLabel;
    Label6: TLabel;
    ParcelaTotalDbEdit: TDBEdit;
    procedure DonoButtonClick(Sender: TObject);
  private
  public
  end;

  function CompromissoFormNew() : TInhCompromissoForm;

implementation

{$R *.xfm}

function CompromissoFormNew() : TInhCompromissoForm;
var
   MyForm : TInhCompromissoForm;
begin
   MyForm := TInhCompromissoForm.Create(Application);

   if (CompromissoDM = nil) then
      CompromissoDM := TCompromissoDM.Create(Application);

   MyForm.DataModule := CompromissoDM;
   CompromissoDM.DbForm := MyForm;

   MyForm.MasterDataSource := CompromissoDM.CompromissoDSource;
//   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
//   MyForm.JointDataSource := CompromissoDM.CompromissoDSource;

//   MyForm.FirstControl := MyForm.NomeDbEdit;
//   MyForm.DetailsBox := MyForm.GroupBox;

   MyForm.HelpTopic := 'capitulo_cadastro_compromissos';

   Result := MyForm;
end;


procedure TInhCompromissoForm.DonoButtonClick(Sender: TObject);
begin
  inherited;
//
end;

end.
