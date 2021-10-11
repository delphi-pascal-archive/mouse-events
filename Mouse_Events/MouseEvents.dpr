program MouseEvents;

uses
  Forms,
  UFrmMouseTest in 'UFrmMouseTest.pas' {FrmTest};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmTest, FrmTest);
  Application.Run;
end.
