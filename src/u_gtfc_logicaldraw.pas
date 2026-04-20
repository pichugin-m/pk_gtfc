unit u_gtfc_logicaldraw;

//************************************************************
//
//    Модуль компонента Graphic Task Flow Control
//    Copyright (c) 2013  Pichugin M.
//    rev. 0.11
//    Разработчик: Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
//************************************************************

interface

uses
{$IFNDEF FPC}

{$ELSE}

{$ENDIF}
  SysUtils, Variants, Classes, graphics, u_gtfc_const;

type

  { Standard events }

  TSetFontStyleCustomDrawEvent = procedure (FontName: AnsiString; FontSize: Integer; FontStyle: TFontStyles) of object;
  TGetTextWidthEvent = procedure (AText: AnsiString; var AWidth: Integer) of object;
  TGetTextHeightEvent = procedure (AText: AnsiString; var AHeight: Integer) of object;
  TGetIntegerValue    = procedure (var Value: Integer) of object;

  TSetStyleCustomDrawEvent = procedure(LineType:String; LineWidth:TgaLineWeight; Color:TgaColor) of object;
  TPointCustomDrawEvent = procedure(X, Y: Integer) of object;
  TLineCustomDrawEvent = procedure(X1, Y1, X2, Y2: Integer) of object;
  TRectangelCustomDrawEvent = procedure(TopLeftX, TopLeftY, BottomRightX, BottomRightY: Integer) of object;
  TCircleCustomDrawEvent = procedure(X, Y, Radius: Integer) of object;
  TPolygonCustomDrawEvent = procedure(APoints:Array of TPoint) of object;
  TPolylineCustomDrawEvent = procedure(APoints:Array of TPoint) of object;

  TEllipseCustomDrawEvent = procedure(X0, Y0, AxleX, AxleY: Integer) of object;
  TArcCustomDrawEvent = procedure(X0, Y0, X1, Y1, X2, Y2, Radius: Integer) of object;
  TTextCustomDrawEvent = procedure(X0, Y0, AWidth, AHeight: Integer; ARotate:integer; AText:String; AAlign:TgaAttachmentPoint) of object;
  TVertexCustomDrawEvent = procedure(X, Y: Integer; ATypeVertex:Integer) of object;

  TMinMaxPoint = record
    Xmin, Ymin, Zmin: Integer;
    Xmax, Ymax, Zmax: Integer;
  end;

  { TLogicalDraw }

  TLogicalDraw = class
  private
    FDevelop          : Boolean; //Режим отладки
    FOnSetStyle       : TSetStyleCustomDrawEvent;
    FOnSetFontStyle   : TSetFontStyleCustomDrawEvent;
    FOnPointDraw      : TPointCustomDrawEvent;
    FOnLineDraw       : TLineCustomDrawEvent;
    FOnPolylineDraw   : TPolylineCustomDrawEvent;
    FOnLineSDraw      : TPolylineCustomDrawEvent;
    FOnPolygonDraw    : TPolygonCustomDrawEvent;
    FOnRectangelDraw  : TRectangelCustomDrawEvent;
    FOnFillDraw       : TRectangelCustomDrawEvent;
    FOnCircleDraw     : TCircleCustomDrawEvent;
    FOnEllipseDraw    : TEllipseCustomDrawEvent;
    FOnArcDraw        : TArcCustomDrawEvent;
    FOnTextDraw       : TTextCustomDrawEvent;
    FOnVertexDraw     : TVertexCustomDrawEvent;
    FOnGetTextWidth   : TGetTextWidthEvent;
    FOnGetTextHeight  : TGetTextHeightEvent;
    FOnGetGridScale   : TGetIntegerValue;
  protected

  public
    property Develop          : Boolean read FDevelop write FDevelop;
    property OnSetStyle       : TSetStyleCustomDrawEvent read FOnSetStyle write FOnSetStyle;
    property OnSetFontStyle   : TSetFontStyleCustomDrawEvent read FOnSetFontStyle write FOnSetFontStyle;
    property OnPointDraw      : TPointCustomDrawEvent read FOnPointDraw write FOnPointDraw;
    property OnLineDraw       : TLineCustomDrawEvent read FOnLineDraw write FOnLineDraw;
    property OnPolylineDraw   : TPolylineCustomDrawEvent read FOnPolylineDraw write FOnPolylineDraw;
    property OnLineSDraw      : TPolylineCustomDrawEvent read FOnLineSDraw write FOnLineSDraw;
    property OnPolygonDraw    : TPolygonCustomDrawEvent read FOnPolygonDraw write FOnPolygonDraw;
    property OnRectangelDraw  : TRectangelCustomDrawEvent read FOnRectangelDraw write FOnRectangelDraw;
    property OnFillDraw       : TRectangelCustomDrawEvent read FOnFillDraw write FOnFillDraw;
    property OnCircleDraw     : TCircleCustomDrawEvent read FOnCircleDraw write FOnCircleDraw;
    property OnEllipseDraw    : TEllipseCustomDrawEvent read FOnEllipseDraw write FOnEllipseDraw;
    property OnArcDraw        : TArcCustomDrawEvent read FOnArcDraw write FOnArcDraw;
    property OnTextDraw       : TTextCustomDrawEvent read FOnTextDraw write FOnTextDraw;
    property OnVertexDraw     : TVertexCustomDrawEvent read FOnVertexDraw write FOnVertexDraw;
    property OnGetTextWidth   : TGetTextWidthEvent read FOnGetTextWidth write FOnGetTextWidth;
    property OnGetTextHeight  : TGetTextHeightEvent read FOnGetTextHeight write FOnGetTextHeight;
    property OnGetGridScale   : TGetIntegerValue read FOnGetGridScale write FOnGetGridScale;

    procedure SetStyleDraw(LineType:String; LineWidth:TgaLineWeight; Color:TgaColor);
    procedure SetFontStyleDraw(FontName: AnsiString; FontSize: Integer; FontStyle: TFontStyles);
    procedure PointDraw(X, Y: Integer);
    procedure LineDraw(X1, Y1, X2, Y2: Integer);
    procedure LineSDraw(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure PolylineDraw(APoints:Array of TPoint);
    procedure PolylineDraw(AX1, AY1: Integer; APoints:Array of TPoint);
    procedure PolygonDraw(APoints:Array of TPoint);
    procedure PolygonDraw(AX1, AY1: Integer; APoints:Array of TPoint);
    procedure RectangelDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY: Integer);
    procedure FillDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY: Integer);
    procedure CircleDraw(X, Y, Radius: Integer);

    procedure EllipseDraw(X0, Y0, AxleX, AxleY: Integer);
    procedure ArcDraw(X0, Y0, X1, Y1, X2, Y2, Radius: Integer);
    procedure TextDraw(X0, Y0, Width, Height: Integer; Rotate:integer; Text:String; Align:TgaAttachmentPoint);
    procedure GetTextWidth(Text: AnsiString; var Width: Integer);
    procedure GetTextHeight(Text: AnsiString; var Height: Integer);
    procedure GetGridScale(var Value: Integer);

    procedure VertexDraw(X, Y: Integer; ATypeVertex:Integer);
  end;

implementation

{ TLogicalDraw }

procedure TLogicalDraw.ArcDraw(X0, Y0, X1, Y1, X2, Y2, Radius: Integer);
begin
    if Assigned(FOnArcDraw) then FOnArcDraw(X0, Y0, X1, Y1, X2, Y2, Radius);
end;

procedure TLogicalDraw.CircleDraw(X, Y, Radius: Integer);
begin
    if Assigned(FOnCircleDraw) then FOnCircleDraw(X, Y, Radius);
end;

procedure TLogicalDraw.EllipseDraw(X0, Y0, AxleX, AxleY: Integer);
begin
    if Assigned(FOnEllipseDraw) then FOnEllipseDraw(X0, Y0, AxleX, AxleY);
end;

procedure TLogicalDraw.GetTextHeight(Text: AnsiString;
  var Height: Integer);
begin
    if Assigned(OnGetTextHeight) then OnGetTextHeight(Text, Height);
end;

procedure TLogicalDraw.GetGridScale(var Value: Integer);
begin
   if Assigned(OnGetGridScale) then OnGetGridScale(Value);
end;

procedure TLogicalDraw.GetTextWidth(Text: AnsiString; var Width: Integer);
begin
    if Assigned(OnGetTextWidth) then OnGetTextWidth(Text, Width);
end;

procedure TLogicalDraw.LineDraw(X1, Y1, X2, Y2: Integer);
begin
    if Assigned(FOnLineDraw) then FOnLineDraw(X1, Y1, X2, Y2);
end;

procedure TLogicalDraw.LineSDraw(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
var
  SPoints: array of TPoint;
begin
   SPoints:=[Point(X1, Y1),Point(X2, Y2),Point(X3, Y3),Point(X4, Y4)];
   if Assigned(FOnlineSDraw) then
    FOnlineSDraw(SPoints);
end;

procedure TLogicalDraw.PolylineDraw(APoints: array of TPoint);
begin
    if Assigned(FOnPolylineDraw) then
    FOnPolylineDraw(APoints);
end;

procedure TLogicalDraw.PolylineDraw(AX1, AY1: Integer; APoints: array of TPoint
  );
var
  i:integer;
begin
    if Assigned(FOnPolylineDraw) then
    begin
        for i:=0 to high(APoints) do
        begin
          APoints[i].X:=APoints[i].X+AX1;
          APoints[i].Y:=APoints[i].Y+AY1;
        end;
        FOnPolylineDraw(APoints);
    end;
end;

procedure TLogicalDraw.PolygonDraw(APoints: array of TPoint);
begin
    if Assigned(FOnPolygonDraw) then
    FOnPolygonDraw(APoints);
end;

procedure TLogicalDraw.PolygonDraw(AX1, AY1: Integer; APoints: array of TPoint);
var
  i:integer;
begin
    if Assigned(FOnPolygonDraw) then
    begin
        for i:=0 to high(APoints) do
        begin
          APoints[i].X:=APoints[i].X+AX1;
          APoints[i].Y:=APoints[i].Y+AY1;
        end;
        FOnPolygonDraw(APoints);
    end;
end;

procedure TLogicalDraw.PointDraw(X, Y: Integer);
begin
    if Assigned(FOnPointDraw) then FOnPointDraw(X, Y);
end;

procedure TLogicalDraw.RectangelDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY: Integer);
begin
    if Assigned(FOnSetFontStyle) then
    FOnRectangelDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY);
end;

procedure TLogicalDraw.FillDraw(TopLeftX, TopLeftY, BottomRightX,
  BottomRightY: Integer);
begin
    if Assigned(FOnFillDraw) then
    FOnFillDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY);
end;


procedure TLogicalDraw.SetFontStyleDraw(FontName: AnsiString; FontSize: Integer;
  FontStyle: TFontStyles);
begin
    if Assigned(FOnSetFontStyle) then
    FOnSetFontStyle(FontName,FontSize,FontStyle);
end;

procedure TLogicalDraw.SetStyleDraw(LineType:String; LineWidth:TgaLineWeight; Color:TgaColor);
begin
    if Assigned(FOnSetStyle) then
    FOnSetStyle(LineType,LineWidth,Color);
end;

procedure TLogicalDraw.TextDraw(X0, Y0, Width, Height: Integer; Rotate:integer; Text:String; Align:TgaAttachmentPoint);
begin
    if Assigned(FOnTextDraw) then
    FOnTextDraw(X0, Y0, Width, Height, Rotate, Text, Align);
end;

procedure TLogicalDraw.VertexDraw(X, Y: Integer; ATypeVertex: Integer);
begin
    if Assigned(FOnVertexDraw) then
    FOnVertexDraw(X, Y, ATypeVertex);
end;

end.

