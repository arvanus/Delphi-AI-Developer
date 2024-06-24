unit C4D.Conn.Zeos;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  ZAbstractConnection,
  ZConnection,
  C4D.Conn.Interfaces,
  C4D.Conn.Configs;

type
  TC4DConnZeos = class(TInterfacedObject, IC4DConnection)
  private
    [weak]
    FC4DConnConfigs: TC4DConnConfigs;
    FConnection: TZConnection;
    function TestFieldsComponentConnection: IC4DConnection;
  protected
    function Component: TComponent;
    function Open: IC4DConnection;
    function Close: IC4DConnection;
    function StartTransaction: IC4DConnection;
    function Commit: IC4DConnection;
    function Rollback: IC4DConnection;
    function TestConnection: Boolean;
    function TestConnectionOnly: Boolean;
    function LoadConnectionConfig: IC4DConnection;
  public
    class function New(AC4DConnConfigs: TC4DConnConfigs): IC4DConnection;
    constructor Create(AC4DConnConfigs: TC4DConnConfigs);
    destructor Destroy; override;
  end;

implementation

class function TC4DConnZeos.New(AC4DConnConfigs: TC4DConnConfigs): IC4DConnection;
begin
  Result := Self.Create(AC4DConnConfigs);
end;

constructor TC4DConnZeos.Create(AC4DConnConfigs: TC4DConnConfigs);
begin
  FC4DConnConfigs := AC4DConnConfigs;
  if(FC4DConnConfigs.ComponentOfConnectionExisting <> nil)then //(TC4DConnConfigs.GetInstance.ComponentOfConnectionExisting <> nil)then
    FConnection := TZConnection(FC4DConnConfigs.ComponentOfConnectionExisting)
  else
  begin
    FConnection := TZConnection.Create(nil);
    Self.LoadConnectionConfig;
  end;
end;

destructor TC4DConnZeos.Destroy;
begin
  if(FC4DConnConfigs.ComponentOfConnectionExisting = nil)then
  begin
    FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;
  inherited;
end;

function TC4DConnZeos.LoadConnectionConfig: IC4DConnection;
begin
  Result := Self;
  FConnection.Connected := False;
  FConnection.Protocol := 'mysql';
  FConnection.Database := FC4DConnConfigs.Database;
  FConnection.User := FC4DConnConfigs.UserName;
  FConnection.Password := FC4DConnConfigs.Password;
  FConnection.HostName := FC4DConnConfigs.Host;
  FConnection.Port := FC4DConnConfigs.Port;
  //FConnection.TransactIsolationLevel := tiReadCommitted;
end;

function TC4DConnZeos.Component: TComponent;
begin
  Result := FConnection;
end;

function TC4DConnZeos.Open: IC4DConnection;
begin
  Result := Self;
  Self.TestFieldsComponentConnection;
  FConnection.Connected := True;
end;

function TC4DConnZeos.Close: IC4DConnection;
begin
  Result := Self;
  FConnection.Connected := False;
end;

function TC4DConnZeos.StartTransaction: IC4DConnection;
begin
  FConnection.StartTransaction;
end;

function TC4DConnZeos.Commit: IC4DConnection;
begin
  FConnection.Commit;
end;

function TC4DConnZeos.Rollback: IC4DConnection;
begin
  FConnection.Rollback;
end;

function TC4DConnZeos.TestConnection: Boolean;
var
  LConnectedOld: Boolean;
begin
  Self.TestFieldsComponentConnection;
  try
    LConnectedOld := FConnection.Connected;
    FConnection.Connected := True;
    Result := FConnection.Connected;
    if(FConnection.Connected <> LConnectedOld)then
      FConnection.Connected := LConnectedOld;
  except
    on E: exception do
      raise exception.Create('Conex�o n�o pode ser realizada: ' + E.Message);
  end;
end;

function TC4DConnZeos.TestConnectionOnly: Boolean;
var
  LConnectedOld: Boolean;
begin
  Result := False;
  try
    LConnectedOld := FConnection.Connected;
    FConnection.Connected := True;
    Result := FConnection.Connected;
    if(FConnection.Connected <> LConnectedOld)then
      FConnection.Connected := LConnectedOld;
  except
  end;
end;

function TC4DConnZeos.TestFieldsComponentConnection: IC4DConnection;
var
  LCamposSemPreenchar: string;
begin
  Result := Self;
  LCamposSemPreenchar := '';
  if(FConnection.HostName.Trim.IsEmpty)then
    LCamposSemPreenchar := LCamposSemPreenchar + 'Host. ';

  if(FConnection.User.Trim.IsEmpty)then
    LCamposSemPreenchar := LCamposSemPreenchar + 'Usu�rio. ';

  if(FConnection.Password.Trim.IsEmpty)then
    LCamposSemPreenchar := LCamposSemPreenchar + 'Senha. ';

  if(Trim(FConnection.Database).IsEmpty)then
    LCamposSemPreenchar := LCamposSemPreenchar + 'Nome banco.';

  if(not LCamposSemPreenchar.IsEmpty)then
    raise exception.Create('Para realizar a conex�o com o banco de dados, os seguintes dados devem ser preenchidos: ' + LCamposSemPreenchar);
end;

end.
