unit InhConsumoPropriedadesDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QExtCtrls, QButtons, QStdCtrls, QMask, QDBCtrls, InhMainDM,
  FMTBcd, DB, SqlExpr, Provider, DBClient, DBLocal, DBLocalS, InhBiblio;

type
  TInhConsumoPropriedadesDlgForm = class(TInhOkCancelDlgForm)
    IdLabel: TLabel;
    IdDbEdit: TDBEdit;
    QuantidadeLabel: TLabel;
    QuantidadeDbEdit: TDBEdit;
    ValorDbEdit: TDBEdit;
    ValorLabel: TLabel;
    ConsumoDSource: TDataSource;
    DataHoraInicialLabel: TLabel;
    DataHoraFinalLabel: TLabel;
    DataHoraInicialDbEdit: TDBEdit;
    DataHoraFinalDbEdit: TDBEdit;
    ConsumoDSet: TSQLClientDataSet;
    UsuarioLabel: TLabel;
    UsuarioDbEdit: TDBEdit;
    procedure OkSpeedButtonClick(Sender: TObject);
  private
     ID : integer;
     procedure UpdateQuery;
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure ConsumoPropriedadesDlgNewRun (AOwner : TComponent; ID : integer);

implementation

{$R *.xfm}

function ConsumoPropriedadesDlgNew(AOwner : TComponent; ID : integer) : TInhConsumoPropriedadesDlgForm;
var
   MyForm : TInhConsumoPropriedadesDlgForm;
begin
   MyForm := TInhConsumoPropriedadesDlgForm.Create(AOwner);
   MyForm.ID := ID;

   MyForm.UpdateQuery;

   Result := MyForm;
end;

procedure ConsumoPropriedadesDlgNewRun (AOwner : TComponent; ID : integer);
var
   MyForm : TInhConsumoPropriedadesDlgForm;
begin
   MyForm := ConsumoPropriedadesDlgNew(AOwner, ID);
   MyForm.ShowModal;
   MyForm.Release;
end;

{ TInhConsumoPropriedadesDlgForm }

procedure TInhConsumoPropriedadesDlgForm.UpdateQuery;
begin
   ConsumoDSet.Params[0].AsInteger := ID;
   ConsumoDset.Open;
end;

procedure TInhConsumoPropriedadesDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   ConsumoDSet.Post;
   ConsumoDSet.ApplyUpdates(-1);
end;

end.
