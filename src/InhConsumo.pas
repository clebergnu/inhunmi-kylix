unit InhConsumo;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhPadrao, InhBiblio, QDBCtrls, QExtCtrls, QButtons, QStdCtrls, QMask,
  QActnList, QDBActns, InhFiltroPadrao;

procedure InhConsumoFormOpen();

type
  TInhConsumoForm = class(TInhPadraoForm)
    IdDBEdit: TDBEdit;
    PortaConsumoDBEdit: TDBEdit;
    DataHoraDBEdit: TDBEdit;
    ProdutoDBLookupComboBox: TDBLookupComboBox;
    QuantidadeDBEdit: TDBEdit;
    ValorDBEdit: TDBEdit;
    IdLabel: TLabel;
    PortaConsumoLabel: TLabel;
    ProdutoLabel: TLabel;
    QuantidadeLabel: TLabel;
    ValorLabel: TLabel;
    DataHoraLabel: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhConsumoForm: TInhConsumoForm;

implementation

uses InhConsumoDM, InhProdutoDM;

{$R *.xfm}

procedure InhConsumoFormOpen();
begin
   if (InhConsumoDMOpen() = true) then
      begin
         if InhConsumoForm = nil then
            InhConsumoForm := TInhConsumoForm.Create(Application);
         InhConsumoForm.Show;
      end
   else
      InhDlgNotApplied ();
end;

procedure TInhConsumoForm.FormCreate(Sender: TObject);
begin
  inherited;
   InhDataSetOpenMaster (ConsumoDM.ConsumoDSet);
   InhDataSetOpen (ConsumoDM.ProdutoDSet);
end;


end.
