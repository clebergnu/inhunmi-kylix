unit InhPortaConsumoLookUpDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QStdCtrls, QExtCtrls, QButtons, DB, DBLocalS, InhBiblio;

type
  TInhPortaConsumoLookUpDlgForm = class(TInhOkCancelDlgForm)
    TipoLabel: TLabel;
    NumeroCodigoComboBox: TComboBox;
    PortaConsumoEdit: TEdit;
    procedure FormShow(Sender: TObject);
  private
    DataSource : TDataSource;
  public
    function Run(PortaConsumo: String): boolean;
  end;

function InhPortaConsumoLookUpDlgFormNew (AOwner : TComponent;
                                          PortaConsumoDSource : TDataSource) : TInhPortaConsumoLookUpDlgForm;

implementation

{$R *.xfm}

function InhPortaConsumoLookUpDlgFormNew (AOwner : TComponent;
                                          PortaConsumoDSource : TDataSource) : TInhPortaConsumoLookUpDlgForm;
var
   MyForm : TInhPortaConsumoLookUpDlgForm;
begin
   MyForm := TInhPortaConsumoLookUpDlgForm.Create(AOwner);

   MyForm.DataSource := PortaConsumoDSource;

   Result := MyForm;
end;



function TInhPortaConsumoLookUpDlgForm.Run(PortaConsumo: String): boolean;
var
   DataSet : TSQLClientDataSet;
begin
   Result := True;
   // Easier access to the DataSet
   DataSet := TSQLClientDataSet (Self.DataSource.DataSet);
   Self.PortaConsumoEdit.Text := PortaConsumo;

   // if the user hits '<ok>' then we go on trying to find the record
   if (Self.ShowModal = mrOk) then
      if(InhEditCheckForInt(Self.PortaConsumoEdit) = True) then
         case Self.NumeroCodigoComboBox.ItemIndex of
            0 :
              Result := DataSet.Locate('numero', VarArrayOf([Self.PortaConsumoEdit.Text]), []);
            1 :
              Result := DataSet.Locate('id', VarArrayOf([Self.PortaConsumoEdit.Text]), []);
         end;

   if Result = False then
      begin
         Self.DataSource.DataSet.Refresh;
         if(InhEditCheckForInt(Self.PortaConsumoEdit) = True) then
         case Self.NumeroCodigoComboBox.ItemIndex of
            0 :
              Result := DataSet.Locate('numero', VarArrayOf([Self.PortaConsumoEdit.Text]), []);
            1 :
              Result := DataSet.Locate('id', VarArrayOf([Self.PortaConsumoEdit.Text]), []);
         end;
      end;
end;

procedure TInhPortaConsumoLookUpDlgForm.FormShow(Sender: TObject);
begin
  inherited;
   PortaConsumoEdit.SetFocus;
end;

end.
