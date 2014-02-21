unit Unit2;

{$mode objfpc}{$H+}

interface

uses LMessages, LCLType, LCLIntf,ExtCtrls,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type

  tAnimate_direct=(
    ad_NUL,
    ad_TOT,
    ad_TOB
    );


  { TForm2 }

  TForm2 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormPaint (Sender: TObject);
  protected
    procedure WMEraseBkgnd(var Message: TLMEraseBkgnd); message LM_ERASEBKGND;
//    procedure _pennon_shape(const topX,topY,Base:integer);
//    procedure _shape_houm(const topX,topY,Base:integer);
   // procedure _paint_houm(const topX,topY,Base:integer);
  protected
   _aTimer:TTimer;
   _aDirect:tAnimate_direct;
    procedure _animate_START;
    procedure _aTimer_step(Sender: TObject);
    procedure _animate_STOP;




  protected
   _animateCOUNT:integer;
   _animateSPEED:double;
   _animateSTART:DWord;
  protected
    procedure _animate_reSetSPEEDs(const newDirection:tAnimate_direct);

    procedure _animate_toStageT;
    procedure _animate_toStageB;
    //---
    function  _animate_inStageT:boolean;
    function  _animate_inStageB:boolean;

  protected
   _Pb_,_PtX_,_PtY_:integer; //< текущие состояния
   _PtYT_,_PtYB_   :integer; //< крайние положения
   _animate_PtY_:double;     //< текущее положение анимации
   _animate_PtS_:double;     //< скорость анимации (пиксель/мс)
  protected
   _Hb_,_HtX_,_HtY_:integer; //< текущие состояния
   _HtYT_,_HtYB_   :integer; //< крайние положения
   _animate_HtY_:double;     //< текущее положение анимации
   _animate_HtS_:double;     //< скорость анимации (пиксель/мс)
  protected
    procedure _toStageT_;
    procedure _toStageB_;
  public
    procedure toStageT;
    procedure toStageB;
  public
    procedure _Shape;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor DESTROY; override;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

constructor TForm2.Create(TheOwner: TComponent);
begin
    inherited;
   _aTimer:=tTimer.Create(SELF);
   _aTimer.Enabled:=FALSE;
   _aTimer.OnTimer:=@_aTimer_step;

   _animateCOUNT:=150;
   _aTimer.Interval:=10;
   //--
   //_toStageT_;
end;

destructor TForm2.DESTROY;
begin
   inherited;
end;

//------------------------------------------------------------------------------

procedure TForm2._animate_reSetSPEEDs(const newDirection:tAnimate_direct);
begin
    case newDirection of
        ad_TOT:begin
               _animate_PtS_:=(_PtYT_-_PtYB_)/_animateCOUNT;
               _animate_HtS_:=(_HtYB_-_HtYT_)/_animateCOUNT;
            end;
        ad_TOB:begin
               _animate_PtS_:=(_PtYB_-_PtYT_)/_animateCOUNT;
               _animate_HtS_:=(_HtYT_-_HtYB_)/_animateCOUNT;
            end;
        else begin
               _animate_PtS_:=0;
               _animate_HtS_:=0;
        end;
    end;
end;



procedure TForm2._animate_toStageT;
begin
    if (_aDirect<>ad_TOT)and(not _animate_inStageT) then begin
       _aTimer.Enabled:=FALSE;

       _animate_reSetSPEEDs(ad_TOT);
       _aDirect:=ad_TOT;
       _animateSTART:=GetTickCount;
       _aTimer.Enabled:=true;
    end;
end;

procedure TForm2._animate_toStageB;
begin
    if (_aDirect<>ad_TOB)and(not _animate_inStageB) then begin
       _aTimer.Enabled:=FALSE;

       _animate_reSetSPEEDs(ad_TOB);
       _aDirect:=ad_TOB;
       _animateSTART:=GetTickCount;
       _aTimer.Enabled:=true;
    end;
end;

procedure TForm2._animate_STOP;
begin
   _aTimer.Enabled:=FALSE;
    case _aDirect of
        ad_TOB: if not _animate_inStageB then _toStageB_;
        ad_TOT: if not _animate_inStageT then _toStageT_;
        else  ;
    end;
   _aDirect:=ad_NUL;
end;


//------------------------------------------------------------------------------

function TForm2._animate_inStageT:boolean;
begin
    result:=(_PtY_=_PtYT_)and(_HtY_=_HtYB_);
end;

function TForm2._animate_inStageB:boolean;
begin
    result:=(_PtY_=_PtYB_)and(_HtY_=_HtYT_);
end;

procedure TForm2._animate_START;
begin
   _animateSTART:=GetTickCount;
   _aTimer.Enabled:=true;
end;

procedure TForm2._aTimer_step(Sender:TObject);
var mastRePAINT:boolean;
    d:integer;
begin
   _aTimer.Enabled:=FALSE;
    if ((_aDirect=ad_TOT)and(_animate_inStageT)) or
       ((_aDirect=ad_TOB)and(_animate_inStageB)) or
       (_aDirect=ad_NUL)
    then _animate_STOP
    else begin
        mastRePAINT:=false;
        //---
       _animate_HtY_:=_animate_HtY_+_animate_HtS_*(GetTickCount-_animateSTART);
        d:=round(_animate_HtY_);
        if d<_HtYT_ then d:=_HtYT_ else if _HtYB_<d then d:=_HtYB_;
        if (d<>_HtY_) then begin
           _HtY_:=d;
            mastRePAINT:=true;
        end;
        //---
       _animate_PtY_:=_animate_PtY_+_animate_PtS_*(GetTickCount-_animateSTART);
        d:=round(_animate_PtY_);
        if d<_PtYT_ then d:=_PtYT_ else if _PtYB_<d then d:=_PtYB_;
        if (d<>_PtY_) then begin
           _PtY_:=d;
            mastRePAINT:=true;
        end;
        //---
        if mastRePAINT then begin
           _Shape;
            Repaint;
        end;
       _animateSTART:=GetTickCount;
       _aTimer.Enabled:=true;
    end;
end;


//------------------------------------------------------------------------------


procedure TForm2.WMEraseBkgnd(var Message: TLMEraseBkgnd);
begin
    //inherited;
    Message.Result:=1;
end;

//------------------------------------------------------------------------------

{inkDoc> ВЫМПЕЛ узловые точки [РИСОВАНИЕ]
    расчитать узловые точки для вымпела
    @prm(Points array[0..4]of TPoint)
<inkDoc}
procedure _pennon_clc_hotSpots(var Points:array of TPoint; const BaseLNG:integer; const targetX,targetY:integer); inline;
begin
    Points[0].x:=targetX;               Points[0].y:=0;
    Points[1].x:=targetX+BaseLNG*2-2;   Points[1].y:=0;
    Points[2].x:=targetX+BaseLNG*2-2;   Points[2].y:=targetY+BaseLNG-1;
    Points[3].x:=targetX+BaseLNG-1;     Points[3].y:=targetY;
    Points[4].x:=targetX;               Points[4].y:=targetY+BaseLNG-1;
end;

{inkDoc> ВЫМПЕЛ узловые точки [ВЫРЕЗАНИЕ]
    расчитать узловые точки для вымпела компенсируя особенности ВЫРЕЗАНИЯ региона
    @prm(Points array[0..4]of TPoint)
<inkDoc}
procedure _pennon_clc_forShape(var Points:array of TPoint; const BaseLNG:integer; const targetX,targetY:integer); inline;
begin
   _pennon_clc_hotSpots(Points, BaseLNG,targetX,targetY);
    //---
   {Points[0].x:=Points[0].x+0;}       {Points[0].y:=Points[0].y+0;}
    Points[1].x:=Points[1].x+1;        {Points[1].y:=Points[1].y+0;}
    Points[2].x:=Points[2].x+1;         Points[2].y:=Points[2].y+1;
   {Points[3].x:=Points[3].x+0;}       {Points[3].y:=Points[3].y+0;}
   {Points[4].x:=Points[4].x+0;}        Points[4].y:=Points[4].y+1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure _paint_pennon(const Canvas:tCanvas; const BaseLNG:integer; const targetX,targetY:integer; const c0,c1:tColor);
var Points: array[0..4] of TPoint;
begin
   _pennon_clc_hotspots(Points, BaseLNG,targetX,targetY);
    //---
    Canvas.Brush.Color:=c1;
    Canvas.Pen  .Color:=c0;
    Canvas.Polygon(Points);//,5,false);
end;

//------------------------------------------------------------------------------

function _houme_clc_selfLNG(const BaseLNG:integer):integer; inline;
begin
    result:=round(0.80*(BaseLNG-1));
end;

{inkDoc> ДОМИК узловые точки [РИСОВАНИЕ]
    расчитать узловые точки для домика
    @prm(Points array[0..8]of TPoint)
<inkDoc}
procedure _houme_clc_hotSpots(var Points:array of TPoint; const BaseLNG:integer; const targetX,targetY:integer); inline;
var h:integer;
begin
    h:=_houme_clc_selfLNG(BaseLNG);
    //---
    Points[0].x:=targetX-BaseLNG;       Points[0].y:=targetY+BaseLNG;
    Points[1].x:=targetX;               Points[1].y:=targetY;
    Points[2].x:=targetX+BaseLNG;       Points[2].y:=targetY+BaseLNG;
    //---
    Points[3].x:=Points[2].x-1;         Points[3].y:=Points[2].y;
    //---
    Points[4].x:=targetX+H;             Points[4].y:=targetY+H+1;
    Points[5].x:=targetX+H;             Points[5].y:=targetY+H+BaseLNG;
    Points[6].x:=targetX-H;             Points[6].y:=targetY+H+BaseLNG;
    Points[7].x:=targetX-H;             Points[7].y:=targetY+H+1;
    //---
    Points[8].x:=Points[0].x+1;         Points[8].y:=Points[0].y;
end;

{inkDoc> ДОМИК узловые точки [ВЫРЕЗАНИЕ]
    расчитать узловые точки для вымпела компенсируя особенности ВЫРЕЗАНИЯ региона
    @prm(Points array[0..8]of TPoint)
<inkDoc}
procedure _houme_clc_forShape(var Points:array of TPoint; const BaseLNG:integer; const targetX,targetY:integer); inline;
begin
   _houme_clc_hotSpots(Points, BaseLNG,targetX,targetY);
    //---
   {Points[0].x:=Points[0].x+0;}       {Points[0].y:=Points[0].y-0;}
   {Points[1].x:=Points[1].x+0;}        Points[1].y:=Points[1].y-1;
    Points[2].x:=Points[2].x+1;         Points[2].y:=Points[2].y+1;
    Points[4].x:=Points[4].x+1;         Points[4].y:=Points[4].y+1;
    Points[5].x:=Points[5].x+1;         Points[5].y:=Points[5].y+1;
   {Points[6].x:=Points[6].x-0;}        Points[6].y:=Points[6].y+1;
   {Points[7].x:=Points[7].x-0;}        Points[7].y:=Points[7].y+1;
    Points[8].x:=Points[8].x-0;         Points[8].y:=Points[8].y+1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure _paint_houme(const Canvas:tCanvas; const BaseLNG:integer; const targetX,targetY:integer; const c0,c1,c2,c3:tColor);
var
  pts: array[0..8] of TPoint;
begin
   _houme_clc_hotspots(pts,BaseLNG,targetX,targetY);
    //----
    //pts[9].x:=pts[0].x-0;   pts[9].y:=pts[0].y+0;
    Canvas.Pen.Color:=c0;
    Canvas.Polygon(pts,false);
    //---
    pts[0].x:=pts[7].x+0;   pts[0].y:=pts[7].y-0;
    pts[1].x:=pts[1].x+0;   pts[1].y:=pts[1].y+1;
    pts[2].x:=pts[4].x+1;   pts[2].y:=pts[4].y+1;
    Canvas.Pen.Color:=c1;
    Canvas.Polyline(pts,0,3);
    //---
    pts[0].x:=pts[7].x+1;   pts[0].y:=pts[7].y-0;
    pts[1].x:=pts[1].x+0;   pts[1].y:=pts[1].y+1;
    pts[2].x:=pts[4].x-1;   pts[2].y:=pts[4].y-0;
    Canvas.Brush.Color:=c2;
    Canvas.Pen.Color:=c3;
    Canvas.Polygon(pts,3,false);

    pts[4].x:=pts[4].x-1;   pts[4].y:=pts[4].y-0;
    pts[5].x:=pts[5].x-1;   pts[5].y:=pts[5].y-1;
    pts[6].x:=pts[6].x+1;   pts[6].y:=pts[6].y-1;
    pts[7].x:=pts[7].x+1;   pts[7].y:=pts[7].y-0;

    Canvas.Brush.Color:=c2;
    Canvas.Pen.Color:=c3;
    Canvas.Polygon(pts,true,4,4);
end;


//------------------------------------------------------------------------------


























//------------------------------------------------------------------------------



{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
    Width :=GetSystemMetrics(SM_CXSMSIZE)*1;
    Height:=GetSystemMetrics(SM_CYCAPTION)*1;
    //---
   _Pb_:=trunc(Height/3)+1;
   _PtX_:=00;
   _PtY_:=Height-_Pb_;
    //---
   _Hb_:=trunc(_Pb_*0.7);
   _HtX_:=_Pb_-1;
   _HtY_:=(_PtY_-_Hb_-_houme_clc_selfLNG(_Hb_))div 2;
    //- -
   _HtYT_:=(_PtY_-_Hb_-_houme_clc_selfLNG(_Hb_))div 2;
   _HtYB_:=Height-1-_Hb_-_houme_clc_selfLNG(_Hb_);
    //---
   _PtYT_:=_HtYB_-(_Pb_-_Hb_)*2;
   _PtYB_:=Height-_Pb_;
end;

procedure TForm2.FormMouseEnter(Sender: TObject);
begin
   _animate_toStageB;
end;

procedure TForm2.FormMouseLeave(Sender: TObject);
begin
   _animate_toStageT;
end;

procedure TForm2._shape;
var rgnP,rgnH:HRGN;
    pts: array[0..8] of TPoint;
begin
   _pennon_clc_forShape(pts,_Pb_,_PtX_,_PtY_);
    rgnP:=CreatePolygonRgn(pts, 5, WINDING);
    //---
   _houme_clc_forShape(pts,_Hb_,_HtX_,_HtY_);
    rgnH:=CreatePolygonRgn(pts, 9, WINDING);
    //-----
    CombineRgn (rgnP, rgnP, rgnH, RGN_OR);
    //-----
    SetWindowRgn(Handle, rgnP, True);
    DeleteObject(rgnP);
    DeleteObject(rgnH);
end;


procedure TForm2.FormPaint(Sender: TObject);
var rect:tRect;
begin
   _paint_pennon(Canvas,_Pb_,_PtX_,_PtY_,clWindowFrame,clWindow);
   _paint_houme (Canvas,_Hb_,_HtX_,_HtY_,clWindowFrame,clBtnShadow,clBtnFace,clWindow);
end;

//------------------------------------------------------------------------------

procedure TForm2.toStageT;
begin
   _toStageT_;
   _animate_toStageB;
end;

procedure TForm2.toStageB;
begin
   _toStageB_;
   _animate_toStageT;
end;

//------------------------------------------------------------------------------

procedure TForm2._toStageT_;
begin
   _PtY_:=_PtYT_;
   _animate_PtY_:=_PtY_;
    //---
   _HtY_:=_HtYB_;
   _animate_HtY_:=_HtY_;
    //---
   _shape;
    Paint;
end;

procedure TForm2._toStageB_;
begin
   _PtY_:=_PtYB_;
   _animate_PtY_:=_PtY_;
    //---
   _HtY_:=_HtYT_;
   _animate_HtY_:=_HtY_;
    //---
   _shape;
    Paint;
end;


end.

