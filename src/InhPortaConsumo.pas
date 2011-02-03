unit InhPortaConsumo;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QDBCtrls, QMask, QGrids, QDBGrids, QComCtrls, InhBiblio,
  QExtCtrls, QButtons, Qt;

const
   imeReadOnly = 'Habilitar edição de dados';
   imeAllowEdit = 'Desabilitar edição de dados';

type
  TInhPortaConsumoForm = class(TForm)
    DetailsPageControl: TPageControl;
    ConsumosTabSheet: TTabSheet;
    DBGrid1: TDBGrid;
    PagamentosTabSheet: TTabSheet;
    DBGrid2: TDBGrid;
    DonoTabSheet: TTabSheet;
    ModoButton: TButton;
    IdDbEdit: TDBEdit;
    NumeroDbEdit: TDBEdit;
    TipoDbEdit: TDBEdit;
    TipoLabel: TLabel;
    StatusLabel: TLabel;
    StatusDbComboBox: TDBComboBox;
    NumeroButton: TButton;
    IdButton: TButton;
    Label1: TLabel;
    TotalConsumosDbEdit: TDBEdit;
    DataHoraLabel: TLabel;
    DataHoraDbEdit: TDBEdit;
    OkSpeedButton: TSpeedButton;
    Bevel1: TBevel;
    SpeedButton1: TSpeedButton;
    PagamentosLabel: TLabel;
    TotalPagamentosDbEdit: TDBEdit;
    Button1: TButton;
    Button2: TButton;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    Button4: TButton;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdButtonClick(Sender: TObject);
    procedure NumeroButtonClick(Sender: TObject);
    procedure ModoButtonClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FormDestroy ();
    procedure FormOpen ();
    procedure FormOpenAtId (Id : integer);
    procedure FormOpenAtNumber (Number : integer);
  end;

var
  InhPortaConsumoForm: TInhPortaConsumoForm;

implementation

uses InhPortaConsumoDM, InhPessoaDM, InhPessoa;

{$R *.xfm}

procedure TInhPortaConsumoForm.FormDestroy ();
begin

end;

procedure TInhPortaConsumoForm.FormOpen ();
begin
   if PortaConsumoDM = nil then
      PortaConsumoDM := TPortaConsumoDM.Create(InhPortaConsumoForm);
   if InhPortaConsumoForm = nil then
      InhPortaConsumoForm := TInhPortaConsumoForm.Create(Application);

   InhPortaConsumoForm.Show;
end;

procedure TInhPortaConsumoForm.FormOpenAtId (Id : integer);
begin
   PortaConsumoDM.DMOpenAtId(Id);
   FormOpen();
end;

procedure TInhPortaConsumoForm.FormOpenAtNumber (Number : integer);
begin
   PortaConsumoDM.DMOpenAtNumber(Number);
   FormOpen();
end;

procedure TInhPortaConsumoForm.Button1Click(Sender: TObject);
begin
  inherited;
   if (PortaConsumoDM.PortaConsumoDSet.ReadOnly) then
      begin
         TButton(Sender).Caption := imeAllowEdit;
         StatusDbComboBox.Enabled := True;
         PortaConsumoDM.DMAllowEdit;
      end
   else
      begin
         TButton(Sender).Caption := imeReadOnly;
         StatusDbComboBox.Enabled := False;
         PortaConsumoDM.DMReadOnly;
      end;
end;

procedure TInhPortaConsumoForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
   PortaConsumoDM.DMClose;
end;

procedure TInhPortaConsumoForm.IdButtonClick(Sender: TObject);
var
   valor : integer;
begin
   valor := InputBox ('Entre com o Código do Porta-Consumo', 'Código:', 0, 1, 99999999);
   if (valor > 0) then
      PortaConsumoDM.DMOpenAtId(valor);
end;

procedure TInhPortaConsumoForm.NumeroButtonClick(Sender: TObject);
var
   valor : integer;
begin
   valor := InputBox ('Entre com o Número do Porta-Consumo', 'Número:', 0, 1, 99999999);
   if (valor > 0) then
      PortaConsumoDM.DMOpenAtNumber(valor);
end;

procedure TInhPortaConsumoForm.ModoButtonClick(Sender: TObject);
begin
   if (PortaConsumoDM.PortaConsumoDSet.ReadOnly) then
      begin
         TButton(Sender).Caption := imeAllowEdit;
         StatusDbComboBox.Enabled := True;
         DataHoraDbEdit.Color := clBase;
         PortaConsumoDM.DMAllowEdit;
      end
   else
      begin
         TButton(Sender).Caption := imeReadOnly;
         StatusDbComboBox.Enabled := False;
         DataHoraDbEdit.Color := clNormalBackground;
         PortaConsumoDM.DMReadOnly;
      end;
end;

procedure TInhPortaConsumoForm.SpeedButton1Click(Sender: TObject);
begin
   Close;
end;

procedure TInhPortaConsumoForm.FormCreate(Sender: TObject);
begin
   Left := 0;
   Top  := 0;
end;

procedure TInhPortaConsumoForm.OkSpeedButtonClick(Sender: TObject);
begin
   PortaConsumoDM.DMApplyUpdates;
   PortaConsumoDM.DMReadOnly;
   Close;
end;

end.
