unit InhLogin;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QButtons, QStdCtrls, InhMainDM, Qt, QImgList, QComCtrls;

type
  TInhLoginForm = class(TForm)
    Bevel1: TBevel;
    CancelarSpeedButton: TSpeedButton;
    OkSpeedButton: TSpeedButton;
    UserNameEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    PasswordEdit: TEdit;
    LogoImage: TImage;
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure PasswordEditKeyPress(Sender: TObject; var Key: Char);
    procedure UserNameEditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhLoginForm: TInhLoginForm;

implementation

{$R *.xfm}

procedure InhLoginDoLogin ();
begin
   MainDM.MainConnection.Params.Values['User_Name'] :=  InhLoginForm.UserNameEdit.Text;
   MainDM.MainConnection.Params.Values['Password']  :=  InhLoginForm.PasswordEdit.Text;
   InhLoginForm.ModalResult := mrOK;
end;

procedure TInhLoginForm.CancelarSpeedButtonClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TInhLoginForm.OkSpeedButtonClick(Sender: TObject);
begin
   InhLoginDoLogin ();
end;

procedure TInhLoginForm.PasswordEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #13) then
      InhLoginDoLogin ();
end;

procedure TInhLoginForm.UserNameEditKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #13) then
      InhLoginDoLogin ();
end;

end.
