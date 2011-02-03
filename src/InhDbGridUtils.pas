unit InhDbGridUtils;

interface

uses Classes, Qt, DB, DBLocalS, QGrids, QDBGrids, InhBiblio;

procedure InhDbGridEaseNavigation(Grid : TDBGrid; var Key: Word; Shift: TShiftState);
procedure InhDbGridConfirmDelete (Grid : TDBGrid; var Key: Word; Shift: TShiftState);

implementation

uses InhDlgUtils;

procedure InhDbGridEaseNavigation(Grid : TDBGrid; var Key: Word; Shift: TShiftState);
var
   DataSet : TSQLClientDataSet;
begin
   DataSet := TSQLClientDataSet(Grid.DataSource.DataSet);

if (Shift = []) and
      ((Key = Key_Enter) or (Key = Key_Return)) and
      // Wheter we're browsing or already editing the grid
      (Grid.EditorMode) then
      begin
         if (Grid.Columns[Grid.SelectedIndex].ButtonStyle = cbsEllipsis) and
            (Assigned(Grid.OnEditButtonClick)) then
            Grid.OnEditButtonClick(Grid);

         if (Grid.SelectedIndex < Grid.FieldCount - 1) then
            begin
               Grid.SelectedIndex := Grid.SelectedIndex + 1;
            end
         else if (Grid.SelectedIndex = Grid.FieldCount - 1) then
            begin
               if (DataSet.State in [dsEdit]) then DataSet.Post;
               if (DataSet.RecNo = -1) or (DataSet.RecNo = DataSet.RecordCount) then
                  DataSet.Append
               else
                  DataSet.Next;

               Grid.SelectedIndex := 0;
            end;
      end;
end;

procedure InhDbGridConfirmDelete (Grid : TDBGrid; var Key: Word; Shift: TShiftState);
begin
   if (Shift = [ssShift]) and (Key = Key_Delete) then
      if (InhDlgRecordDetailDeleteConfirmation('registro')) then
         begin
            Grid.DataSource.DataSet.Delete;
            InhApplyUpdates (Grid.DataSource.DataSet);
         end;
end;


end.
