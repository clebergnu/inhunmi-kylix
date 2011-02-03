{InhDbForm.pas - Inhunmi default form for editing database data

 Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA 02111-1307, USA.
}

unit InhDbForm;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QExtCtrls, QButtons, QDBCtrls, DBLocalS, InhBiblio, Qt, QComCtrls, DB,
  InhAjuda, InhFiltroPadrao, QActnList, QTypes, QMenus, InhStringResources;

type
  TInhDbForm = class(TForm)
    ToolbarPanel: TPanel;
    PrintButton: TSpeedButton;
    LogoImage: TImage;
    FilterButton: TSpeedButton;
    ExitButton: TSpeedButton;
    HelpButton: TSpeedButton;
    Navigator: TDBNavigator;
    StatusBar: TStatusBar;
    PrintMenu: TPopupMenu;
    PrintActionList: TActionList;
    LimparFiltroButton: TSpeedButton;
    procedure ExitButtonClick(Sender: TObject);
    procedure FilterButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrintButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LimparFiltroButtonClick(Sender: TObject);
  private
  public
    FirstControl     : TWidgetControl;
    DetailsBox       : TWidgetControl;
    DataModule       : TDataModule;
    MasterDataSource : TDataSource;
    JointDataSource  : TDataSource;
    HelpTopic : string;

    procedure MasterDataSetAfterInsert (DataSet : TDataSet);
    procedure MasterDataSetAfterInsertPost (DataSet : TDataSet);
    procedure MasterDataSetAfterEdit (DataSet : TDataSet);
    procedure MasterDataSetAfterDelete (DataSet : TDataSet);
    procedure MasterDataSetBeforePost (DataSet : TDataSet);
    procedure JointDataSetAfterEdit (DataSet : TDataSet);
  end;

implementation

uses InhDlgUtils;

{$R *.xfm}

procedure TInhDbForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Shift = [ssCtrl] then
      begin
         case Key of

            Key_Left   :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then Beep
               else MasterDataSource.DataSet.Prior;

            Key_Right  :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then Beep
               else MasterDataSource.DataSet.Next;

            Key_Home   :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then Beep
               else MasterDataSource.DataSet.First;

            Key_End    :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then Beep
               else MasterDataSource.DataSet.Last;

            Key_Insert :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then Beep
               else MasterDataSource.DataSet.Insert;

            Key_Delete :
               if (MasterDataSource.DataSet.RecordCount > 0) then
                  MasterDataSource.DataSet.Delete;

            Key_Enter  :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then
                  MasterDataSource.DataSet.Post;
            Key_Return :
               if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then
                  MasterDataSource.DataSet.Post;

            Key_Escape :
               begin
                  TSQLClientDataSet(MasterDataSource.DataSet).Cancel;
               end;
         end;
      Key := 0;
      end;
end;

procedure TInhDbForm.FilterButtonClick(Sender: TObject);
begin
   InhSearchFromDataSource(MasterDataSource);
end;

procedure TInhDbForm.ExitButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TInhDbForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
   CompIndex : integer;
begin
   // Default action is to hide the form
   Action := caHide;
   if MasterDataSource.DataSet.State in [dsEdit, dsInsert] then
      // Give the user a chance to save its work
      if not (InhDlgYesNo (InhStrRecordModifiedSaveConfirmation)) then
         Action := caNone;

   // Do this if we're really closing (meaning hiding) the form
   if (Action = caHide) then
      begin
         for CompIndex := 0 to DataModule.ComponentCount - 1 do
            if DataModule.Components[CompIndex] is TSQLClientDataSet then
               TSQLClientDataSet(DataModule.Components[CompIndex]).Close;
         if(DetailsBox is TWidgetControl) then DetailsBox.Visible := True;
         StatusBar.SimpleText := '';
      end;
end;

procedure TInhDbForm.HelpButtonClick(Sender: TObject);
begin
   InhAjudaRun (HelpTopic);
end;

procedure TInhDbForm.FormCreate(Sender: TObject);
begin
   InhFormDealWithScreen (Self);
   Navigator.DataSource := MasterDataSource;
end;

procedure TInhDbForm.PrintButtonClick(Sender: TObject);
begin
   if (PrintMenu.Items.Count = 0) then
      InhDlgNotImplemented ()
   else
      PrintMenu.Popup(Self.Left + Self.PrintButton.Left + Self.PrintButton.Width + 10,
                      Self.Top + Self.PrintButton.Top + 10);
end;

procedure TInhDbForm.MasterDataSetAfterInsert(DataSet: TDataSet);
begin
   StatusBar.SimpleText := InhStrRecordAdding;
   FirstControl.SetFocus;

   if (DetailsBox <> nil) then
      DetailsBox.Visible := False;
end;

procedure TInhDbForm.MasterDataSetAfterInsertPost(DataSet: TDataSet);
begin
   StatusBar.SimpleText := Format(InhStrRecordAdded, [DataSet.FieldByName('id').AsString]);

   if (DetailsBox <> nil) then
      DetailsBox.Visible := True;
end;

procedure TInhDbForm.MasterDataSetAfterEdit(DataSet: TDataSet);
begin
   StatusBar.SimpleText := Format(InhStrRecordModified, [DataSet.FieldByName('id').AsString]);
end;

procedure TInhDbForm.MasterDataSetAfterDelete(DataSet: TDataSet);
begin
   InhDataSetMasterAfterPost (DataSet);
end;

procedure TInhDbForm.JointDataSetAfterEdit(DataSet: TDataSet);
begin
   MasterDataSource.DataSet.Edit;
end;

procedure TInhDbForm.MasterDataSetBeforePost(DataSet: TDataSet);
begin
   if DataSet.State = dsInsert then
      DataSet.Tag := 111
   else if DataSet.State = dsEdit then
      StatusBar.SimpleText := Format(InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

procedure TInhDbForm.FormShow(Sender: TObject);
begin
   // Eventos
   if not assigned(MasterDataSource.DataSet.BeforePost) then
      MasterDataSource.DataSet.BeforePost := MasterDataSetBeforePost;

   MasterDataSource.DataSet.AfterInsert := MasterDataSetAfterInsert;
   MasterDataSource.DataSet.AfterEdit   := MasterDataSetAfterEdit;
   MasterDataSource.DataSet.AfterDelete := MasterDataSetAfterDelete;
   if (JointDataSource <> nil) then
      JointDataSource.DataSet.AfterEdit := JointDataSetAfterEdit;

   InhFormDealWithScreen (Self);
   Navigator.DataSource := MasterDataSource;
end;

procedure TInhDbForm.LimparFiltroButtonClick(Sender: TObject);
begin
   MasterDataSource.DataSet.Filtered := False;
end;

end.
