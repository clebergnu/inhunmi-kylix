unit InhEncomendaLookUpDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, DB, DBLocalS,
  SqlExpr, InhBiblio;

type
  TInhEncomendaLookUpDlgForm = class(TInhOkCancelDlgForm)
    Label1: TLabel;
    TipoComboBox: TComboBox;
    EncomendaEdit: TEdit;
    procedure FormShow(Sender: TObject);
  private
    DataSource : TDataSource;
  public
    function Run(UserInput: String): boolean;
  end;

function InhEncomendaLookUpDlgFormNew (AOwner : TComponent;
                                       DSource : TDataSource) : TInhEncomendaLookUpDlgForm;

var
  PortaConsumoDSet: TSQLDataSet;

implementation

uses InhMainDM;

{$R *.xfm}

procedure UpdatePortaConsumoDSet (Tipo : String; UserInput : String);
begin
   if (PortaConsumoDSet = nil) then
      begin
         PortaConsumoDSet := TSQLDataSet.Create(MainDM.MainConnection);
         PortaConsumoDSet.SQLConnection := MainDM.MainConnection;
      end;

   if (PortaConsumoDSet.Active) then PortaConsumoDSet.Close;

   if (Tipo = 'Telefone') then
      PortaConsumoDSet.CommandText := 'SELECT porta_consumo.id FROM porta_consumo, ' +
                                      'encomenda, pessoa_instituicao, pessoa_instituicao_telefone ' +
                                      'WHERE (porta_consumo.id = encomenda.dono) ' +
                                      'AND (porta_consumo.dono = pessoa_instituicao.id) ' +
                                      'AND (pessoa_instituicao_telefone.dono = pessoa_instituicao.id) ' +
                                      'AND (porta_consumo.tipo = "Encomenda") ' +
//                                      'AND (porta_consumo.status = "Aberto") ' +
                                      'AND (pessoa_instituicao_telefone.numero = "' + UserInput + '") ' +
                                      'ORDER BY porta_consumo.id DESC'
   else if (Tipo = 'Nome') then
      PortaConsumoDSet.CommandText := 'SELECT porta_consumo.id FROM porta_consumo, ' +
                                      'encomenda, pessoa_instituicao ' +
                                      'WHERE (porta_consumo.id = encomenda.dono) ' +
                                      'AND (porta_consumo.dono = pessoa_instituicao.id) ' +
                                      'AND (porta_consumo.tipo = "Encomenda") ' +
//                                      'AND (porta_consumo.status = "Aberto") ' +
                                      'AND (pessoa_instituicao.nome LIKE "' + UserInput + '%")' +
                                      'ORDER BY porta_consumo.id DESC';

   PortaConsumoDSet.Open;
   PortaConsumoDSet.First;
end;

function InhEncomendaLookUpDlgFormNew (AOwner : TComponent;
                                       DSource : TDataSource) : TInhEncomendaLookUpDlgForm;
var
   MyForm : TInhEncomendaLookUpDlgForm;
begin
   MyForm := TInhEncomendaLookUpDlgForm.Create(AOwner);

   MyForm.DataSource := DSource;

   Result := MyForm;
end;


function TInhEncomendaLookUpDlgForm.Run(UserInput: String): boolean;
var
   DataSet : TSQLClientDataSet;
begin
   Result := True;
   // Easier access to the DataSet
   DataSet := TSQLClientDataSet (Self.DataSource.DataSet);
   EncomendaEdit.Text := UserInput;

   // if the user hits '<ok>' then we go on trying to find the record
   if (Self.ShowModal = mrOk) then
      begin
         DataSource.DataSet.Refresh;
         // Código
         if (TipoComboBox.ItemIndex = 0) then
            begin
               if (InhEditCheckForInt(EncomendaEdit) = True) then
                  Result := DataSet.Locate('id', VarArrayOf([EncomendaEdit.Text]), []);
            end

         // Telefone Cliente
         else if (TipoComboBox.ItemIndex = 1) then
            begin
               if (InhEditCheckForInt(EncomendaEdit) = True) then
                  begin
                     UpdatePortaConsumoDSet ('Telefone', EncomendaEdit.Text);
                     Result := False;
                     while (not PortaConsumoDSet.Eof) do
                        begin
                           Result := DataSet.Locate('id', VarArrayOf([PortaConsumoDSet.FieldValues['id']]), []);
                           PortaConsumoDSet.Next;
                           if (Result = True) then break;
                        end;
                  end
            end

         // Nome Cliente
         else if (TipoComboBox.ItemIndex = 2) then
            begin
               UpdatePortaConsumoDSet ('Nome', EncomendaEdit.Text);
               Result := False;
               while (not PortaConsumoDSet.Eof) do
                  begin
                     Result := DataSet.Locate('id', VarArrayOf([PortaConsumoDSet.FieldValues['id']]), []);
                     PortaConsumoDSet.Next;
                     if (Result = True) then break;
                  end;
            end
      end;
end;

procedure TInhEncomendaLookUpDlgForm.FormShow(Sender: TObject);
begin
  inherited;
     EncomendaEdit.SetFocus;
end;

end.
