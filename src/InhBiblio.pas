{InhBiblio.pas - Inhunmi Function Library

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

unit InhBiblio;

interface

uses
  SysUtils, Types, Classes, Variants, QForms, QDialogs, QDBCtrls,
  DBXpress, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS, InhMainDM,
  Libc, QStdCtrls, QComCtrls, QControls, Qt, QDBGrids, SQLTimSt, DateUtils,
  InhStringResources;

type TInhAccess = record
   id : string;
   usuario : string;

   atendimento : boolean;
   caixa : boolean;

   grupo_cadastro : boolean;
   cadastro_pessoa : boolean;
   cadastro_instituicao : boolean;
   cadastro_departamento : boolean;
   cadastro_produto : boolean;
   cadastro_produto_grupo : boolean;
   cadastro_encomenda : boolean;
   cadastro_forma_pagamento : boolean;
   cadastro_compromisso : boolean;

   grupo_relatorio : boolean;

   grupo_gerenciamento : boolean;

   configuracao : boolean;
   acesso : boolean;
   end;

//const
   // ids -> Inhunmi DataSet State
//   idsNormal    = 0;
//   idsInserting = idsNormal + 1;
//   idsOpening   = idsInserting + 1;

type TInhArrayOfInteger = array of integer;

// ifo -> Inhunmi Filter Operation
const
   ifoIgual     = 0;
   ifoDiferente = ifoIgual + 1;
   ifoTexto     = ifoDiferente + 1;
type
   TInhFilterOperations = ifoIgual..ifoTexto;

// ietm -> Inhunmi Estoque Tipo Movimento
const
   ietmEntrada = 0;
   ietmSaida   = ietmEntrada + 1;
type
   TInhEstoqueTipoMovimento = ietmEntrada..ietmSaida;



var
   InhUserName : String;
   InhAccess : TInhAccess;



function  InhSelectFirstField (QueryText : String) : String;
function  InhSelectFieldFromTableWhereId (FieldName : String; TableName : String; IDValue : String) : String;
function  InhSelectNextIdOfTable (TableName : String) : Integer;

procedure InhDeleteFromTableWhereFieldValue (Table : String; Field: String;  Value: String);
procedure InhDeleteFromTableWhereOwner (Table : String; Owner : String);
procedure InhSetNullOnTableWhereOwner (Table : String; Owner : String);
procedure InhDeleteFromTableWhereOwnerTypeAndID (Table : String; OwnerType : String; ID : String);

function  InhDataSetOpen (DataSet : TSQLClientDataSet) : boolean;
function  InhDataSetOpenMaster (DataSet : TSQLClientDataSet) : boolean;
function  InhDataSetOpenDetail (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet) : boolean;
function  InhDataSetOpenJoint (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet) : boolean;
function  InhDataSetOpenDetailIfClosed (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet) : boolean;

procedure InhDataSetOpenOwnerTypeDetail (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet);
procedure InhDataSetMasterAfterPost (DataSet : TDataSet);
procedure InhDataSetDetailAfterPost (DataSet : TDataSet);

function InhDataSetLookUp (DataSet : TSQLClientDataSet; KeyName: String; Key : String) : boolean;

function InhRunQuery (Query : String) : integer;

procedure InhApplyUpdates (DataSet: TDataSet);

function  InhConnectionGetUserName (SQLConnection : TSQLConnection) : String;
function  InhMainConnectionGetUserName () : String;

function  InhValidateCPF (cpf : string) : boolean;
function  InhEditCheckForInt (Edit : TEdit) : boolean;
function  InhEditCheckForFloat (Edit : TEdit) : boolean;

function  InhAccessGetFromUserName (UserName : String) : TInhAccess;

function  InhFilterExecute (DataSet : TDataSet; Campo : String; Texto : String; Operacao : TInhFilterOperations) : boolean;

function  InhArrayOfIntToStrList (IntArray : array of integer; Separator : String) : String;
function  InhDataSetFieldToArrayOfInt (DataSet : TSQLDataSet; FieldName : String) : TInhArrayOfInteger;

function DateTimeToSQLTimeStampString (Data : TDateTime) : string;

procedure InhFormDealWithScreen (Form : TForm);

implementation

uses InhDlgUtils;

function InhRunQuery (Query : String) : integer;
var
   QueryDS : TSQLDataSet;
begin

   QueryDS := TSQLDataSet.Create(MainDM.MainConnection);
   QueryDS.SQLConnection := MainDM.MainConnection;
   QueryDS.CommandText := Query;
   Result := QueryDS.ExecSQL(True);

   FreeAndNil(QueryDS);
end;

//////////////////////////////////////////////
// DataBase Related Functions
//////////////////////////////////////////////
// InhSelect Section
//////////////////////////////////////////////

// InhSelectFirstField:
// Returns a stringified version of the value of the very first
// field returned by the execution of query "QueryText".
function InhSelectFirstField (QueryText : String) : String;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := QueryText;
   Query.Open;
   if Query.RecordCount <> 0 then
      Result := Query.Fields[0].AsString
   else
      Result := '';

   FreeAndNil(Query);
end;

// InhSelectFieldFromTableWhereID:
// Returns a stringified version of the value of "FieldName"
// from "TableName" having id = "IDValue"
function InhSelectFieldFromTableWhereId (FieldName : String; TableName : String; IDValue : String) : String;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'SELECT ' + FieldName + ' FROM ' + TableName + ' WHERE id = ' + IDValue;
   Query.Open;
   if Query.RecordCount = 1 then
      Result := Query.FieldValues[FieldName]
   else
      Result := '';
   Query.Destroy;
end;


// InhSelectNextIdOfTable
// Returns an integer identifying the next applicable
// id of "TableName"
function InhSelectNextIdOfTable (TableName : String) : Integer;
var Query : TSQLDataSet;
    Field : TField;
begin
   Query := TSQLDataSet.Create(mainDM);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'SELECT (id + 1) AS id FROM ' + TableName + ' ORDER BY id DESC LIMIT 1';
   Query.ExecSQL(true);
   Query.Open;
   if (Query.RecordCount = 0) then
      Result:=1
   else
      begin
         Field := Query.FieldByName('id');
         Result := Field.Value;
      end;
   Query.Close;
   Query.Destroy;
end;

//////////////////////////////////////////////
// InhDelete Section
//////////////////////////////////////////////

procedure InhDeleteFromTableWhereFieldValue (Table : String; Field: String;  Value: String);
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'DELETE FROM ' + Table + ' WHERE ' + Field + ' = ' + Value;
   Query.ExecSQL(true);
   Query.Destroy;
end;

procedure InhDeleteFromTableWhereOwner (Table : String; Owner : String);
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'DELETE FROM ' + Table + ' WHERE dono = ' + Owner;
   Query.ExecSQL(true);
   Query.Destroy;
end;

procedure InhSetNullOnTableWhereOwner (Table : String; Owner : String);
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'UPDATE ' + Table + ' SET dono = NULL WHERE dono = ' + Owner;
   Query.ExecSQL(true);
   Query.Destroy;
end;

procedure InhDeleteFromTableWhereOwnerTypeAndID (Table : String; OwnerType : String; ID : String);
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'DELETE FROM ' + Table + ' WHERE dono_tipo = "' + OwnerType + '" AND dono = ' + ID;
   Query.ExecSQL(true);
   Query.Destroy;
end;

// InhApplyUpdates:
// Casts a DataSet as a TSQLClientDataSet and calls ApplyUpdates
// upon it
procedure InhApplyUpdates (DataSet: TDataSet);
begin
   if (TSQLClientDataSet(DataSet).ChangeCount > 0) then 
      TSQLClientDataSet(DataSet).ApplyUpdates(0);
end;

//////////////////////////////////////////////
// InhDataSet Section
//////////////////////////////////////////////
function InhDataSetOpenMaster (DataSet : TSQLClientDataSet) : boolean;
begin
   if DataSet.Active = false then
   try DataSet.Open except
      on ESafecallException do
         begin
            Result := False;
            exit;
         end;
   end;
   Result := DataSet.Active;
end;

function InhDataSetOpen (DataSet : TSQLClientDataSet) : boolean;
begin
   if DataSet.Active = true then
      DataSet.Close;
   try DataSet.Open except
      on ESafecallException do
         begin
         Result := False;
         exit;
         end;
   end;
   Result := DataSet.Active;
end;

function InhDataSetOpenDetail (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet) : boolean;
begin
   if MasterDataSet.RecordCount < 1 then
      begin
         Result := True;
         exit;
      end;
   if DetailDataSet.Active = true then
      DetailDataSet.Close;
   DetailDataSet.Params[0].Value := MasterDataSet.FieldValues['id'];
   try DetailDataSet.Open except
      on ESafecallException do
         begin
            Result := False;
            exit;
         end;
   end;
   Result := DetailDataSet.Active;
end;

function InhDataSetOpenJoint (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet) : boolean;
begin
   if DetailDataSet.Active = true then
      DetailDataSet.Close;
   DetailDataSet.Params[0].Value := MasterDataSet.FieldValues['id'];
   try DetailDataSet.Open except
      on ESafecallException do
         begin
         Result := False;
         exit;
         end;
   end;
   Result := DetailDataSet.Active;
end;


function InhDataSetOpenDetailIfClosed (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet) : boolean;
begin
   if DetailDataSet.Active = False then
      begin
         if MasterDataSet.RecordCount < 1 then
            begin
            Result := True;
            exit;
            end;
         if DetailDataSet.Active = true then
            DetailDataSet.Close;
         DetailDataSet.Params[0].Value := MasterDataSet.FieldValues['id'];
         try DetailDataSet.Open except
            on ESafecallException do
               begin
                  Result := False;
                  exit;
               end;
         end;
      end;
   Result := DetailDataSet.Active;
end;


procedure InhDataSetOpenOwnerTypeDetail (DetailDataSet : TSQLClientDataSet; MasterDataSet : TSQLClientDataSet);
begin
   if MasterDataSet.RecordCount < 1 then exit;
   if DetailDataSet.Active = true then
      DetailDataSet.Close;
   DetailDataSet.Params[0].Value := MasterDataSet.FieldValues['dono_tipo'];
   DetailDataSet.Params[1].Value := MasterDataSet.FieldValues['id'];
   DetailDataSet.Open;
end;

procedure InhDataSetMasterAfterPost (DataSet : TDataSet);
begin
   if (TSQLClientDataSet(DataSet).ChangeCount > 0) then
      begin
         TSQLClientDataSet(DataSet).ApplyUpdates(-1);
         TSQLClientDataSet(DataSet).Refresh;
      if DataSet.Tag = 111 then
         begin
            DataSet.Last;
            DataSet.Tag := 0;
        end;
   end;
end;

procedure InhDataSetDetailAfterPost (DataSet : TDataSet);
begin
   TSQLClientDataSet(DataSet).ApplyUpdates(-1);
   DataSet.Refresh;
   DataSet.Last;
end;

function InhConnectionGetUserName (SQLConnection : TSQLConnection) : String;
begin
   Result := SQLConnection.Params.Values['User_Name'];
end;

function InhMainConnectionGetUserName () : String;
begin
   Result := InhConnectionGetUserName (MainDM.MainConnection);
end;

//////////////////////////////////////////////
// InhValidate Section
//////////////////////////////////////////////

function InhValidateCPF (cpf : string) : boolean;
var dig1, dig2, idig1            : integer;
    s_cpf, s_dve, s_ver, f_cpf  : string;
begin
   f_cpf := cpf;
   s_cpf := copy(cpf, 1,  9);
   s_dve := copy(cpf, 10, 2);
   //---- Calculo do primeiro digito do CPF
   idig1 :=(strtoint(copy(s_cpf, 1 ,1))*1) +
                (strtoint(copy(s_cpf, 2 ,1))*2) +
                (strtoint(copy(s_cpf, 3 ,1))*3) +
                (strtoint(copy(s_cpf, 4 ,1))*4) +
                (strtoint(copy(s_cpf, 5 ,1))*5) +
                (strtoint(copy(s_cpf, 6 ,1))*6) +
                (strtoint(copy(s_cpf, 7 ,1))*7) +
                (strtoint(copy(s_cpf, 8 ,1))*8) +
                (strtoint(copy(s_cpf, 9 ,1))*9);
        dig1 := (idig1 mod 11);
        if dig1 > 10 then dig1 := 0;

        s_cpf := s_cpf + inttostr(dig1);
        s_cpf := copy(s_cpf, 2, 9);

        //---- Calculo do segundo digito do CPF
        idig1 := (strtoint(copy(s_cpf, 1 ,1))*1) +
                 (strtoint(copy(s_cpf, 2 ,1))*2) +
                 (strtoint(copy(s_cpf, 3 ,1))*3) +
                 (strtoint(copy(s_cpf, 4 ,1))*4) +
                 (strtoint(copy(s_cpf, 5 ,1))*5) +
                 (strtoint(copy(s_cpf, 6 ,1))*6) +
                 (strtoint(copy(s_cpf, 7 ,1))*7) +
                 (strtoint(copy(s_cpf, 8 ,1))*8) +
                 (strtoint(copy(s_cpf, 9 ,1))*9) ;
        dig2 := (idig1 mod 11);
        if dig2 > 10 then dig2 := 0;
        s_ver := (concat(inttostr(dig1)) + (inttostr(dig2)));
        if s_ver <> s_dve then
           Result := false
        else
           Result := true
end;

function  InhEditCheckForInt (Edit : TEdit) : boolean;
begin
   Result := True;
   try
      StrToInt (Edit.Text);
         except
            on EConvertError do
               begin
                  InhDlg (InhStrInputInteger);
                  Edit.Text := '';
                  Edit.SetFocus;
                  Result := False;
                  exit;
               end;
         end;
end;

function  InhEditCheckForFloat (Edit : TEdit) : boolean;
begin
   Result := True;
   try
      StrToFloat (Edit.Text);
         except
            on EConvertError do
               begin
                  InhDlg (InhStrInputFloat);
                  Edit.Text := '';
                  Edit.SetFocus;
                  Result := False;
                  exit;
               end;
         end;
end;

//////////////////////////////////////////////
// InhSelect Section
//////////////////////////////////////////////


function InhAccessGetFromUserName (UserName : String) : TInhAccess;
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'SELECT * FROM acesso WHERE usuario = "' + UserName + '"';
   Query.Open;
   if Query.RecordCount <> 0 then
      begin
         Result.id := Query.FieldValues['id'];
         Result.usuario := UserName;

         if Query.FieldValues['atendimento'] = 'Sim' then
            Result.atendimento := true;
         if Query.FieldValues['caixa'] = 'Sim' then
            Result.caixa := true;

         if Query.FieldValues['grupo_cadastro'] = 'Sim' then
            Result.grupo_cadastro := true;

         if Query.FieldValues['cadastro_pessoa'] = 'Sim' then
            Result.cadastro_pessoa := true;
         if Query.FieldValues['cadastro_instituicao'] = 'Sim' then
            Result.cadastro_instituicao := true;
         if Query.FieldValues['cadastro_departamento'] = 'Sim' then
            Result.cadastro_departamento := true;
         if Query.FieldValues['cadastro_produto'] = 'Sim' then
            Result.cadastro_produto := true;
         if Query.FieldValues['cadastro_produto_grupo'] = 'Sim' then
            Result.cadastro_produto_grupo := true;
         if Query.FieldValues['cadastro_encomenda'] = 'Sim' then
            Result.cadastro_encomenda := true;
         if Query.FieldValues['cadastro_forma_pagamento'] = 'Sim' then
            Result.cadastro_forma_pagamento := true;
         if Query.FieldValues['cadastro_compromisso'] = 'Sim' then
            Result.cadastro_compromisso := true;

         if Query.FieldValues['grupo_relatorio'] = 'Sim' then
            Result.grupo_relatorio := true;

         if Query.FieldValues['grupo_gerenciamento'] = 'Sim' then
            Result.grupo_gerenciamento := true;

         if Query.FieldValues['configuracao'] = 'Sim' then
            Result.configuracao := true;
         if Query.FieldValues['acesso'] = 'Sim' then
            Result.acesso := true;
      end;
   Query.Free;
end;

function InhFilterExecute (DataSet : TDataSet; Campo : String; Texto : String; Operacao : TInhFilterOperations) : boolean;
var
   Field : TField;
   TextoDeProcura : String;
   Operador : String;
begin
   DataSet.Filtered := False;

   // se for passado um texto em branco, limpe o filtro.
   if Texto = '' then
      begin
         Result := False;
         Exit;
      end;

   // Filtro não é sensível a caso
   DataSet.FilterOptions := [foCaseInsensitive];

   // Pegue um referencia ao TField
   Field := DataSet.FieldByName(Campo);

   case Operacao of
      ifoIgual : Operador := ' = ';
      ifoDiferente : Operador := ' <> ';
      ifoTexto :
         begin
            Texto := Texto + '*';
            Operador := ' = ';
         end;
   end;

   // Com que tipo de campo estamos lidando?
   // Se for un TIntegerField, tente converter texto para string
   if (Field is TIntegerField) then
      begin
         try
            StrToInt (Texto);
         except
            on EConvertError do
               begin
                  InhDlg (InhStrInputInteger);
                  Result := False;
                  exit;
               end;
         end;
         // Como temos um numero, nao precisamos de aspas
         TextoDeProcura := Texto;
      end
      else if (Field is TFloatField) then
      begin
         try
            StrToFloat (Texto);
         except
            on EConvertError do
               begin
                  InhDlg (InhStrInputInteger);
                  Result := False;
                  exit;
               end;
         end;
         // Como temos um numero, nao precisamos de aspas
         TextoDeProcura := Texto;
      end
   else if (Field is TStringField) then
      // Temos uma string, coloque aspas para nao significar nome
      // de um outro campo
      TextoDeProcura := QuotedStr(Texto)
   else
      TextoDeProcura := QuotedStr(Texto);

   DataSet.Filter := Campo + Operador + TextoDeProcura;
   DataSet.Filtered := True;
   Result := True;
end;

function InhDataSetLookUp (DataSet : TSQLClientDataSet; KeyName: String; Key : String) : boolean;
begin
   with DataSet do
      begin
          EditKey;
          FieldByName(KeyName).AsString := Key;
          Result := GotoKey;
      end;
end;

function InhArrayOfIntToStrList (IntArray : array of integer; Separator : String) : String;
var
   I : integer;
begin
   Result := '';

   for I := 0 to High(IntArray) do
      begin
         Result := Result + IntToStr(IntArray[I]);
         if I <> High(IntArray) then Result := Result + Separator;
      end;
end;

function InhDataSetFieldToArrayOfInt (DataSet : TSQLDataSet; FieldName : String) : TInhArrayOfInteger;
begin
   SetLength(Result, 0);

   if (DataSet.RecordCount = 0) then
      begin
         SetLength (Result, 1);
         Result[0] := 0;
         exit;
      end;

   DataSet.First;
   while (not DataSet.Eof) do
      begin
         SetLength (Result, Length(Result) + 1);
         Result[High(Result)] := DataSet.FieldbyName(FieldName).AsInteger;
         DataSet.Next;
      end;
end;

function InhDateToSQLDate () : String;
begin
  DateSeparator := '/';
  ShortDateFormat := 'dd/mm/yyyy';
  LongTimeFormat := 'hh:mm:ss';
end;

function DateTimeToSQLTimeStampString (Data : TDateTime) : string;
begin
   Result := SQLTimeStampToStr ('yyyymmddhhnnss', DateTimeToSQLTimeStamp (Data));
end;

procedure InhFormDealWithScreen (Form : TForm);
begin
   if (Screen.Width <= 640) and (Screen.Height <= 480) then
      begin
         if (Form.Width > 600) or (Form.Height > 400) then
            begin
               Form.Left := 0;
               Form.Top := 0;
               Form.Position := poDesigned;
            end
         else
            begin
               Form.Left := (Screen.Width - Form.Width) div 2;
               Form.Top  := (Screen.Height - Form.Height) div 2;
            end
      end
   else
      begin
         Form.Position := poDesktopCenter;
      end;
end;

end.