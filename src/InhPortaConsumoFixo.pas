unit InhPortaConsumoFixo;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhDbForm, QActnList, QTypes, QMenus, QComCtrls, QDBCtrls, QExtCtrls,
  QButtons, QStdCtrls, QMask,

  InhLookUpPadrao;

type
  TInhPortaConsumoFixoForm = class(TInhDbForm)
    IdDbEdit: TDBEdit;
    NumeroDbEdit: TDBEdit;
    DonoNomeDbEdit: TDBEdit;
    ObservacoesDbEdit: TDBEdit;
    AtributosGroupBox: TGroupBox;
    TipoInvalidoDbCheckBox: TDBCheckBox;
    TipoAutomaticoDbCheckBox: TDBCheckBox;
    IdLabel: TLabel;
    NumeroLabel: TLabel;
    DonoButton: TButton;
    DonoIdDbEdit: TDBEdit;
    Label1: TLabel;
    TipoDbComboBox: TDBComboBox;
    TipoLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure DonoButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

   function PortaConsumoFixoFormNew() : TInhPortaConsumoFixoForm;

implementation

uses InhPortaConsumoFixoDM;

{$R *.xfm}

function PortaConsumoFixoFormNew() : TInhPortaConsumoFixoForm;
var
   MyForm : TInhPortaConsumoFixoForm;
begin
   MyForm := TInhPortaConsumoFixoForm.Create(Application);

   if (PortaConsumoFixoDM = nil) then
      PortaConsumoFixoDM := TPortaConsumoFixoDM.Create(Application);

   MyForm.DataModule := PortaConsumoFixoDM;
   PortaConsumoFixoDM.DbForm := MyForm;

   MyForm.MasterDataSource := PortaConsumoFixoDM.PortaConsumoFixoDSource;
//   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;

   MyForm.FirstControl := MyForm.NumeroDbEdit;
//   MyForm.DetailsBox := MyForm.GroupBox;

   MyForm.HelpTopic := 'capitulo_cadastro_porta_consumos_fixos';

   Result := MyForm;
end;

procedure TInhPortaConsumoFixoForm.FormShow(Sender: TObject);
begin
  inherited;
   TPortaConsumoFixoDM(DataModule).DMOpen;
end;

procedure TInhPortaConsumoFixoForm.DonoButtonClick(Sender: TObject);
begin
  inherited;
   if (InhLookUpFromDataSource(PortaConsumoFixoDM.DonoDSource, 'nome') = mrOK) then
      begin
         MasterDataSource.DataSet.Edit;
         MasterDataSource.DataSet.FieldValues['dono'] := PortaConsumoFixoDM.DonoDSet.FieldValues['id'];
      end;
end;

end.
