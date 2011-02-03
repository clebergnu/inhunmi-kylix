unit InhDlgUtils;

interface

uses
  SysUtils, Types, Classes, Variants, QForms, QDialogs, QDBCtrls,
  DBXpress, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, InhMainDM,
  Libc, QStdCtrls, QComCtrls, QControls, Qt, QDBGrids, SQLTimSt,
  InhStringResources;

procedure InhDlg (MessageText : String);
function  InhDlgYesNo (MessageText : String) : boolean;
procedure InhDlgNotImplemented ();
function  InhDlgRecordMasterDeleteConfirmation (RecordType : String) : boolean;
function  InhDlgRecordDetailDeleteConfirmation (RecordType : String) : boolean;
procedure InhDlgRecordNotApplied ();

//procedure InhDlgNotApplied ();
//function  InhDlgConfirmDelete () : boolean;
//function  InhDlgConfirmDeleteDetail () : boolean;


implementation

procedure InhDlg (MessageText : String);
begin
    MessageDlg(InhStrDlgNotification,
	       MessageText, mtCustom, [mbOk], 0, mbOk);
end;

function InhDlgYesNo (MessageText : String) : boolean;
begin
   Result := False;

   if (MessageDlg(MessageText, mtConfirmation, [mbNo, mbYes], 0, mbNo) = mrYes) then
      Result := True;
end;

procedure InhDlgNotImplemented ();
begin
   InhDlg (InhStrDlgNotImplemented);
end;

function InhDlgRecordMasterDeleteConfirmation (RecordType : String) : boolean;
begin
   Result := InhDlgYesNo(Format(InhStrDlgRecordMasterDeleteConfirmation,
			        [RecordType]));
end;

function InhDlgRecordDetailDeleteConfirmation (RecordType : String) : boolean;
begin
   Result := InhDlgYesNo(Format(InhStrDlgRecordDetailDeleteConfirmation,
			        [RecordType]));
end;

procedure InhDlgRecordNotApplied ();
begin
   InhDlg(InhStrDlgRecordNotApplied);
end;

end.