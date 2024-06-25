unit C4D.Conn;

interface

uses
  {$IFDEF C4DConnZeos}
  C4D.Conn.Zeos,
  C4D.Conn.Zeos.Query,
  {$ENDIF}
  System.SysUtils,
  System.Classes,
  C4D.Conn.Interfaces,
  C4D.Conn.Types,
  C4D.Conn.Configs,
  C4D.Conn.Firedac,
  C4D.Conn.Firedac.Query;

type
  IC4DConn = C4D.Conn.Interfaces.IC4DConn;
  IC4DConnQuery = C4D.Conn.Interfaces.IC4DConnQuery;

  TC4DConn = class(TInterfacedObject, IC4DConn)
  private
    FC4DConnConfigs: TC4DConnConfigs;
    FC4DConnInstance: IC4DConnection;
    FCountNameQuery: Integer;
    function CountNameQuery: Integer;
    function QueryInternal(ANameQuery: string): IC4DConnQuery;
  protected
    function Configs: TC4DConnConfigs;
    function Connection: IC4DConnection;
    function Query: IC4DConnQuery; overload;
    function Query(ANameQuery: string): IC4DConnQuery; overload;
  public
    class function New: IC4DConn;
    constructor Create;
    destructor Destroy; override;
  end;

function C4DConn: IC4DConn;

var
  FInstance: IC4DConn;

implementation

uses
 DelphiAIDev.Utils;

class function TC4DConn.New: IC4DConn;
begin
  Result := Self.Create;
end;

constructor TC4DConn.Create;
begin
  FCountNameQuery := 0;
  FC4DConnConfigs := TC4DConnConfigs.New
    .ComponentConnectionFireDac
    .Database(TUtils.GetPathFileBdDefaultsQuestions);
end;

destructor TC4DConn.Destroy;
begin
  FC4DConnConfigs.Free;
  inherited;
end;

function C4DConn: IC4DConn;
begin
  if(not Assigned(FInstance))then
    FInstance := TC4DConn.New;
  Result := FInstance;
end;

function TC4DConn.Configs: TC4DConnConfigs;
begin
  Result := FC4DConnConfigs;
end;

function TC4DConn.CountNameQuery: Integer;
begin
  Inc(FCountNameQuery);
  Result := FCountNameQuery;
end;

function TC4DConn.Connection: IC4DConnection;
begin
  case(FC4DConnConfigs.ComponentConnection)of
    TComponentConnection.Firedac:
    begin
      if(FC4DConnConfigs.ConnectionSingleton)then
      begin
        if(not Assigned(FC4DConnInstance))then
          FC4DConnInstance := TC4DConnFiredac.New(FC4DConnConfigs);
        Result := FC4DConnInstance;
      end
      else
        Result := TC4DConnFiredac.New(FC4DConnConfigs);
    end;
    {$IFDEF C4DConnZeos}
    TComponentConnection.Zeos:
    begin
      if(FC4DConnConfigs.ConnectionSingleton)then
      begin
        if(not Assigned(FC4DConnInstance))then
          FC4DConnInstance := TC4DConnZeos.New(FC4DConnConfigs);
        Result := FC4DConnInstance;
      end
      else
        Result := TC4DConnZeos.New(FC4DConnConfigs);
    end;
    {$ENDIF}
  end;
end;

function TC4DConn.Query: IC4DConnQuery;
begin
  Result := Self.QueryInternal('Query'+ Self.CountNameQuery.ToString);
end;

function TC4DConn.Query(ANameQuery: string): IC4DConnQuery;
begin
  Result := Self.QueryInternal(ANameQuery);
end;

function TC4DConn.QueryInternal(ANameQuery: string): IC4DConnQuery;
begin
  case(FC4DConnConfigs.ComponentConnection)of
    TComponentConnection.Firedac:
      Result := TC4DConnFiredacQuery.New(Self.Connection, ANameQuery);
    {$IFDEF C4DConnZeos}
    TComponentConnection.Zeos:
      Result := TC4DConnZeosQuery.New(Self.Connection, ANameQuery);
    {$ENDIF}
  end;
end;

end.
