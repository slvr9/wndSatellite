unit Unit1;

{$mode objfpc}{$H+}

interface

uses  LCLType, LCLIntf, LCLProc, Classes, SysUtils, FileUtil, Forms, Controls,Unit2,
  Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
   //   SM_CXSIZE    The width of a button in a window caption or title bar, in pixels.

//   SM_CXSMICON   49    The recommended width of a small icon, in pixels. Small icons typically appear in window captions and in small icon view.
//  SM_CXSMSIZE  52  The width of small caption buttons, in pixels.
//  SM_CYCAPTION  4  The height of a caption area, in pixels.

  memo1.Clear;
  //---
  memo1.Lines.Add('SM_CYSIZE='+inttostr(GetSystemMetrics(SM_CYSIZE)));
  memo1.Lines.Add('SM_CYSMICON='+inttostr(GetSystemMetrics(SM_CYSMICON)));
  memo1.Lines.Add('SM_CYSMSIZE='+inttostr(GetSystemMetrics(SM_CYSMSIZE)));
  memo1.Lines.Add('SM_CYCAPTION='+inttostr(GetSystemMetrics(SM_CYCAPTION)));
  memo1.Lines.Add('SM_CYFRAME='+inttostr(GetSystemMetrics(SM_CYFRAME)));

  Shape1.Height:=GetSystemMetrics(SM_CYSIZE);
  Shape2.Height:=GetSystemMetrics(SM_CYSMICON);
  Shape3.Height:=GetSystemMetrics(SM_CYSMSIZE);
  Shape4.Height:=GetSystemMetrics(SM_CYCAPTION);

//  Form2.Width :=GetSystemMetrics(SM_CXSMSIZE);
//  Form2.Height:=GetSystemMetrics(SM_CYCAPTION);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form2.toStageT;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Form2.toStageB;
end;


const bH=5;

const cx=bH*3;
const cy=8;


procedure paintHoume(const Canvas:tCanvas; const topX,topY,Base:integer);
var  h    :integer;
    k:array[0..3] of TPoint;
    c0:tColor;
    c1:tColor;
    c2:tColor;
    c3:tColor;
begin
    c0:=clWindowFrame;
    c1:=clBtnShadow;
    c2:=clBtnFace;
    c3:=clWindow;

    with Canvas do begin
        h:=round(0.80*(Base-1));
        //-- ТЕЛО крыши
        pen  .Color:=c3;
        Brush.Color:=c2;
        k[0].x:=topX;
        k[0].y:=topY+1;
        k[1].x:=topX+h-2;
        k[1].y:=topY+h-1;
        k[2].x:=topX-h+2;
        k[2].y:=topY+h-1;
        Polygon(k,3,false);
        //-- ВНЕШНЯЯ чать крыши
        pen.Style:=psSolid;
        pen.Color:=c0;
        Line(topX   ,topY   ,topX+Base  ,topY+Base);
        Line(topX   ,topY   ,topX-Base  ,topY+Base);
        //-- внутренняя чать крыши
        pen.Color:=c1;
        Line(topX   ,topY+1 ,topX+Base-1,topY+Base);
        Line(topX   ,topY+1 ,topX-Base+1,topY+Base);

        //--- ТЕЛО ДОМИКА
        pen.Style:=psSolid;
        // прямоугольник "ТЕЛА" домика
        Brush.Color:=c2;
        pen  .Color:=c3;
        k[0].x:=topX+h-1;    k[0].y:=topY+h   +1;
        k[1].x:=topX+h-1;    k[1].y:=topY+h+Base-1;
        k[2].x:=topX-h+1;    k[2].y:=topY+h+Base-1;
        k[3].x:=topX-h+1;    k[3].y:=topY+h   +1;
        Polygon(k);
        // перевернутая буква "П"
        pen  .Color:=c0;
        k[0].x:=topX+h;      k[0].y:=topY+h   ;
        k[1].x:=topX+h;      k[1].y:=topY+h+Base;
        k[2].x:=topX-h;      k[2].y:=topY+h+Base;
        k[3].x:=topX-h;      k[3].y:=topY+h   ;
        Polyline(k);

    end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
    paintHoume(Canvas,6,6,5);
end;

end.

