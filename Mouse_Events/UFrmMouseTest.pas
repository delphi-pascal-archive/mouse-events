unit UFrmMouseTest;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmTest = class(TForm)
    BtnExecOpenDialog: TButton;
    OpenDialog1: TOpenDialog;
    ListBox1: TListBox;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnExecOpenDialogClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    // La souris est-elle dans la fenêtre ?
    FMouseIn: Boolean;
  protected
    procedure InsertInfo(const S: string);

    procedure BeginTrackEvent(Flags: Cardinal);

    { Interception des messages <!> Interne seulement <!> }
    procedure CreateWnd; override;
    procedure WMDestroy(var Msg: TMessage); message WM_DESTROY;

    procedure HackWMMouseEnter(var Msg: TMessage);
    procedure WMMouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;
    procedure WMMouseMove(var Msg: TMessage); message WM_MOUSEMOVE;

    procedure WMLButtonDown(var Msg: TMessage); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TMessage); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Msg: TMessage); message WM_LBUTTONDBLCLK;

    procedure WMRButtonDown(var Msg: TMessage); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Msg: TMessage); message WM_RBUTTONUP;
    procedure WMRButtonDblClk(var Msg: TMessage); message WM_RBUTTONDBLCLK;

    procedure WMMButtonDown(var Msg: TMessage); message WM_MBUTTONDOWN;
    procedure WMMButtonUp(var Msg: TMessage); message WM_MBUTTONUP;
    procedure WMMButtonDblClk(var Msg: TMessage); message WM_MBUTTONDBLCLK;

    { Procédure qui relayent les messages.
    Ce sont ces procédures que les descendants doivent surcharger }
    procedure NewMouseEnter; virtual;
    procedure NewMouseLeave; virtual;
    procedure NewMouseMove(Shift: TShiftState; const Pos: TPoint); virtual;

    procedure NewMouseDown(Button: TMouseButton; Shift: TShiftState;
      const Pos: TPoint); virtual;
    procedure NewMouseUp(Button: TMouseButton; Shift: TShiftState;
      const Pos: TPoint); virtual;
    procedure NewMouseDoubleClick(Button: TMouseButton; Shift: TShiftState;
      const Pos: TPoint); virtual;
  end;

var
  FrmTest: TFrmTest;

implementation

{$R *.dfm}

{
  ************************* Procédure pour l'exemple ***************************
}
procedure TFrmTest.FormCreate(Sender: TObject);
begin
  ListBox1.Items.Add('');
end;

function ButtonToStr(Button: TMouseButton): string;
begin
  case Button of
    mbLeft: Result := 'mbLeft';
    mbRight: Result := 'mbRight';
    mbMiddle: Result := 'mbMiddle';
  end;
end;

function ShiftToStr(Shift: TShiftState): string;
begin
  Result := '[ ';
  if ssLeft in Shift then Result := Result + 'ssLeft ';
  if ssRight in Shift then Result := Result + 'ssRight ';
  if ssMiddle in Shift then Result := Result + 'ssMiddle ';
  Result := Result + ']';
end;

procedure TFrmTest.InsertInfo(const S: string);
begin
  if ListBox1.Items[0] <> S then
  begin
    ListBox1.Items.Insert(0, S);
    Timer1.Enabled := False;
    Timer1.Enabled := True;
  end;
end;

procedure TFrmTest.BtnExecOpenDialogClick(Sender: TObject);
begin
  OpenDialog1.Execute;
end;

procedure TFrmTest.Timer1Timer(Sender: TObject);
begin
  InsertInfo('');
end;

{
  ************************* Interception des messages **************************
}
function DecodeShiftParam(N: Cardinal): TShiftState;
begin
  Result := [];
  if N and MK_LBUTTON <> 0 then Result := Result + [ssLeft];
  if N and MK_RBUTTON <> 0 then Result := Result + [ssRight];
  if N and MK_MBUTTON <> 0 then Result := Result + [ssMiddle];
end;

procedure TFrmTest.BeginTrackEvent(Flags: Cardinal);
var
  TME: TTrackMouseEvent;
begin
  TME.cbSize := SizeOf(TTrackMouseEvent);
  TME.dwFlags := Flags;
  TME.hwndTrack := Handle;
  TME.dwHoverTime := HOVER_DEFAULT;
  TrackMouseEvent(TME);
end;

procedure TFrmTest.CreateWnd;
begin
  inherited;
  FMouseIn := False;
end;

procedure TFrmTest.WMDestroy(var Msg: TMessage);
begin
  inherited;
  FMouseIn := False;
end;

procedure TFrmTest.HackWMMouseEnter(var Msg: TMessage);
var
  S: TShiftState;
  P: TPoint;
begin
  {>> Déclenche le faux MouseEnter si nécéssaire et demande
  à recevoir un MouseLeave }
  if not FMouseIn then
  begin
    FMouseIn := True;
    NewMouseEnter;
    BeginTrackEvent(TME_LEAVE);

    {>> Crée les messages de souris que la fenêtre n'a pas reçu
    (car elle la souris n'était pas dessus) }
    S := DecodeShiftParam(Msg.WParam);
    P := Point(Msg.LParamLo, Msg.LParamHi);
    if Msg.WParam and MK_LBUTTON <> 0 then
      NewMouseDown(mbLeft, S, P);
    if Msg.WParam and MK_RBUTTON <> 0 then
      NewMouseDown(mbRight, S, P);
    if Msg.WParam and MK_MBUTTON <> 0 then
      NewMouseDown(mbmiddle, S, P);
  end;
end;

procedure TFrmTest.WMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FMouseIn := False;
  NewMouseLeave;
end;

procedure TFrmTest.WMMouseMove(var Msg: TMessage);
begin
  inherited;
  HackWMMouseEnter(Msg);
  NewMouseMove(DecodeShiftParam(Msg.WParam), Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMLButtonDown(var Msg: TMessage);
begin
  inherited;
  NewMouseDown(mbLeft, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMLButtonUp(var Msg: TMessage);
begin
  inherited;
  NewMouseUp(mbLeft, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMLButtonDblClk(var Msg: TMessage);
begin
  inherited;
  NewMouseDoubleClick(mbLeft, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMRButtonDown(var Msg: TMessage);
begin
  inherited;
  NewMouseDown(mbRight, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMRButtonUp(var Msg: TMessage);
begin
  inherited;
  NewMouseUp(mbRight, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMRButtonDblClk(var Msg: TMessage);
begin
  inherited;
  NewMouseDoubleClick(mbRight, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMMButtonDown(var Msg: TMessage);
begin
  inherited;
  NewMouseDown(mbMiddle, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMMButtonUp(var Msg: TMessage);
begin
  inherited;
  NewMouseUp(mbMiddle, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

procedure TFrmTest.WMMButtonDblClk(var Msg: TMessage);
begin
  inherited;
  NewMouseDoubleClick(mbMiddle, DecodeShiftParam(Msg.WParam),
    Point(Msg.LParamLo, Msg.LParamHi));
end;

{
  ******************** Procédure qui relayent les messages *********************
}
procedure TFrmTest.NewMouseEnter;
begin
  InsertInfo('MouseEnter');
end;

procedure TFrmTest.NewMouseLeave;
begin
  InsertInfo('MouseLeave');
end;

procedure TFrmTest.NewMouseMove(Shift: TShiftState; const Pos: TPoint);
begin
  InsertInfo('MouseMove - Shift = ' + ShiftToStr(Shift));
end;

procedure TFrmTest.NewMouseDown(Button: TMouseButton; Shift: TShiftState;
  const Pos: TPoint);
begin
  InsertInfo('MouseDown - Button = ' + ButtonToStr(Button)
    + ' - Shift = ' + ShiftToStr(Shift));
end;

procedure TFrmTest.NewMouseUp(Button: TMouseButton; Shift: TShiftState;
  const Pos: TPoint);
begin
  InsertInfo('MouseUp - Button = ' + ButtonToStr(Button)
    + ' - Shift = ' + ShiftToStr(Shift));
end;

procedure TFrmTest.NewMouseDoubleClick(Button: TMouseButton; Shift: TShiftState;
  const Pos: TPoint);
begin
  InsertInfo('DoubleClick - Button = ' + ButtonToStr(Button)
    + ' - Shift = ' + ShiftToStr(Shift));

  if Button = mbRight then
    OpenDialog1.Execute;
end;

end.

