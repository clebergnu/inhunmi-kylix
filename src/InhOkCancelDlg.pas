unit InhOkCancelDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QButtons, Qt, InhBiblio;

type
  TInhOkCancelDlgForm = class(TForm)
    CancelarSpeedButton: TSpeedButton;
    OkSpeedButton: TSpeedButton;
    Bevel1: TBevel;
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhOkCancelDlgForm: TInhOkCancelDlgForm;

implementation

{$R *.xfm}

procedure TInhOkCancelDlgForm.OkSpeedButtonClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TInhOkCancelDlgForm.CancelarSpeedButtonClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TInhOkCancelDlgForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Shift = []) and ((Key = Key_Enter) or (Key = Key_Return)) then
      TInhOkCancelDlgForm(Sender).OkSpeedButton.Click
   else if (Shift = []) and (Key = Key_Escape) then
      CancelarSpeedButtonClick(Self)
end;

procedure TInhOkCancelDlgForm.FormCreate(Sender: TObject);
begin
   InhFormDealWithScreen(Self);
end;

end.
