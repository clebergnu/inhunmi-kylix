{InhPortaConsumoDM.pas

 Copyright (C) 2002 Cleber Rodrigues <cleberrrjr@bol.com.br>

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

unit InhPortaConsumoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhBiblio;

type
  TPortaConsumoDM = class(TDataModule)
    PortaConsumoDSet: TSQLClientDataSet;
    PortaConsumoDSource: TDataSource;
    ConsumoDSet: TSQLClientDataSet;
    ConsumoDSource: TDataSource;
    PagamentoDSet: TSQLClientDataSet;
    PagamentoDSource: TDataSource;
    DonoDSet: TSQLClientDataSet;
    DonoDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    FormaPagamentoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    FormaPagamentoDSource: TDataSource;
    ConsumoDSetid: TIntegerField;
    ConsumoDSetdono: TIntegerField;
    ConsumoDSetproduto: TIntegerField;
    ConsumoDSetproduto_quantidade: TIntegerField;
    ConsumoDSetvalor: TFloatField;
    ConsumoDSetdatahora: TSQLTimeStampField;
    ConsumoDSetdatahora_inicial: TSQLTimeStampField;
    ConsumoDSetdepartamento_venda: TIntegerField;
    ConsumoDSetusuario: TIntegerField;
    ConsumoDSetproduto_descricao: TStringField;
    PagamentoDSetid: TIntegerField;
    PagamentoDSetdono: TIntegerField;
    PagamentoDSetforma_pagamento: TIntegerField;
    PagamentoDSetvalor: TFloatField;
    PagamentoDSetdatahora: TSQLTimeStampField;
    PagamentoDSetdatahora_inicial: TSQLTimeStampField;
    PagamentoDSetusuario: TIntegerField;
    PagamentoDSetforma_pagamento_descricao: TStringField;
    ConsumoDSettotal: TAggregateField;
    procedure PortaConsumoDSetAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    State : integer;
    function DMOpen () : boolean;
    procedure DMClose ();
    procedure DMOpenAtId (Id : integer);
    procedure DMOpenAtNumber (Number : integer);
    procedure DMReadOnly ();
    procedure DMAllowEdit ();
    procedure DMApplyUpdates ();
  end;

var
  PortaConsumoDM: TPortaConsumoDM;

implementation

uses InhPortaConsumo, InhMainDM;

{$R *.xfm}

function TPortaConsumoDM.DMOpen () : boolean;
begin
   // DataSets that should always be opened
   if (InhDataSetOpenMaster(PortaConsumoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhPortaConsumoForm = nil) then
      begin
         if (InhDataSetOpenDetail(ConsumoDSet, PortaConsumoDSet) = False) then
            begin
               Result := False;
               exit;
            end;
      end
   else
      case InhPortaConsumoForm.DetailsPageControl.ActivePageIndex of
      0 :
         begin
             if (InhDataSetOpenDetail(ConsumoDSet, PortaConsumoDSet) = False) then
                begin
                   Result := False;
                   exit;
                end;
         end;
      1 :
         begin
           if (InhDataSetOpenDetail(PagamentoDSet, PortaConsumoDSet) = False) then
              begin
                 Result := False;
                 exit;
              end;
         end;
      2 :
         begin
           if (InhDataSetOpenDetail(DonoDSet, PortaConsumoDSet) = False) then
              begin
                 Result := False;
                 exit;
              end;
         end;
      end;
   Result := true;
end;

procedure TPortaConsumoDM.DMClose ();
begin
   PortaConsumoDSet.Close;
   ConsumoDSet.Close;
   PagamentoDSet.Close;
   DonoDSet.Close;
end;

procedure TPortaConsumoDM.DMOpenAtId (Id : integer);
begin
   PortaConsumoDSet.Close;
   PortaConsumoDSet.CommandText := 'SELECT * FROM porta_consumo WHERE id = ' + IntToStr(Id);
   DMOpen();
end;

procedure TPortaConsumoDM.DMOpenAtNumber (Number : integer);
begin
   PortaConsumoDSet.Close;
   PortaConsumoDSet.CommandText := 'SELECT * FROM porta_consumo WHERE numero = ' + IntToStr(Number);
   DMOpen();
end;

procedure TPortaConsumoDM.DMReadOnly ();
begin
   PortaConsumoDSet.ReadOnly := True;
   ConsumoDSet.ReadOnly := True;
   PagamentoDSet.ReadOnly := True;
   DonoDSet.ReadOnly := True;
end;

procedure TPortaConsumoDM.DMAllowEdit ();
begin
   PortaConsumoDSet.ReadOnly := False;
   ConsumoDSet.ReadOnly := False;
   PagamentoDSet.ReadOnly := False;
   DonoDSet.ReadOnly := False;
end;

procedure TPortaConsumoDM.DMApplyUpdates ();
begin
   if PortaConsumoDSet.State = dsEdit then
      PortaConsumoDSet.ApplyUpdates(-1);
   if ConsumoDSet.State = dsEdit then
      ConsumoDSet.ApplyUpdates(-1);
   if PagamentoDSet.State = dsEdit then
      PagamentoDSet.ApplyUpdates(-1);
   if DonoDSet.State = dsEdit then
      DonoDSet.ApplyUpdates(-1);
end;

// Master's AfterPost event handler
procedure TPortaConsumoDM.PortaConsumoDSetAfterPost(DataSet: TDataSet);
begin
   InhDataSetMasterAfterPost (DataSet);
end;

end.
