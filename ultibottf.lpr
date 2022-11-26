program ultibottf;

{$mode objfpc}{$H+}

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  ShellFilesystem,
  ShellUpdate,
  RemoteShell,
  Ultibo,
  vgshapes,
  openvg,
  dispmanx,
  fontman,
  console,
  Services,
  logging;

const
  SECS = 10;

var
  Width, Height : integer;
  InternalLCDFontLayer0 : PVGShapesFontInfo;
  InternalLCDFontLayer1 : PVGShapesFontInfo;
  LoadedFont : PVGShapesFontInfo;
  SearchRec : TSearchRec;
  FontManager : TFontManager;
  i : integer;
  fontname : string;

  {$include lcdphone2.inc}

begin

  ConsoleWindowCreate(ConsoleDeviceGetDefault, CONSOLE_POSITION_FULL, true);
  // Set up OpenVG layer 0
  VGShapesSetLayer(0);
  VGShapesInit(Width,Height);

  // let's load an application font into layer 0.
  // this one is compiled directly into the binary.
  InternalLCDFontLayer0 := VGShapesLoadAppFont('lcd',
                       @lcdphone2_glyphPoints,
                       @lcdphone2_glyphPointIndices,
                       @lcdphone2_glyphInstructions,
                       @lcdphone2_glyphInstructionIndices,
                       @lcdphone2_glyphInstructionCounts,
                       @lcdphone2_glyphAdvances,
                       @lcdphone2_characterMap,
                       lcdphone2_glyphCount,
                       lcdphone2_descender_height,
                       lcdphone2_font_height);

  // set up layer 1. We're just using a second layer to prove the font loading
  // work on multiple layers. The second layer has alpha so it doesn't obstruct
  // the layer below.
  VGShapesSetLayer(1);
  VGShapesInit(Width,Height, DISPMANX_FLAGS_ALPHA_FROM_SOURCE);

  // let's load the same application font into layer 1.
  // this is necessary because OpenVG does not allow any graphics handles to be
  // shared between layers.
  InternalLCDFontLayer1 := VGShapesLoadAppFont('lcd',
                       @lcdphone2_glyphPoints,
                       @lcdphone2_glyphPointIndices,
                       @lcdphone2_glyphInstructions,
                       @lcdphone2_glyphInstructionIndices,
                       @lcdphone2_glyphInstructionCounts,
                       @lcdphone2_glyphAdvances,
                       @lcdphone2_characterMap,
                       lcdphone2_glyphCount,
                       lcdphone2_descender_height,
                       lcdphone2_font_height);

  // Now let's display some text using the font compiled into the binary on layer 0.
  // black background, white text.
  VGShapesSetLayer(0);
  VGShapesStart(Width, Height);
  VGShapesBackground(0,0,0);
  VGShapesStroke(255, 255, 255, 1.0);
  VGShapesFill(255, 255, 255, 1.0);
  VGShapesTextMid(Width div 2, Height div 2, 'This is the LCD font Layer 0', InternalLCDFontLayer0, 40);
  VGShapesEnd;

  // Now same thing but on layer 1.
  VGShapesSetLayer(1);
  VGShapesStart(Width, Height);
  // layer 1 has to be cleared with an alpha of 0 making it transparent.
  // otherwise layer 0 would not be visible.
  VGShapesBackgroundRGB(0,0,0,0);
  VGShapesStroke(255, 255, 255, 1.0);
  VGShapesFill(255, 255, 255, 1.0);
  VGShapesTextMid(Width div 2, Height div 2, 'This is the LCD font Layer 0', InternalLCDFontLayer0, 40);
  VGShapesEnd;

  for i := SECS downto 1 do
  begin
    VGShapesSetLayer(1);
    VGShapesStart(Width, Height, true);

    //black background
    VGShapesBackgroundRGB(0, 0, 0, 0);

    //white text
    VGShapesStroke(255, 255, 255, 1.0);
    VGShapesFill(255, 255, 255, 1.0);

    VGShapesTextMid(Width div 2, Height div 2 - 70, 'This is the LCD font Layer 1', InternalLCDFontLayer1, 40);
    VGShapesTextMid(Width div 2, Height div 2 - 140, inttostr(i), InternalLCDFontLayer1, 40);
    VGShapesEnd;

    Sleep(1000);
  end;

  // Next, create the Font Manager so that we can use it to load in a TTF font.
  FontManager := TFontManager.Create('c:\fonts');

  // Finally, sit in a loop looking at the list of fonts on the disk and every time
  // we find a new one, load it up and draw some text with it.
  while (true) do
  begin
    LoggingOutputEx(0, 0, 'ultibottf', 'Starting file search.');
    if FindFirst('c:\fonts\*.ttf', faNormal, SearchRec) = 0 then
    begin
      repeat
        fontname := ExtractFileName(SearchRec.Name);
        fontname := LeftStr(fontname, pos('.', fontname)-1);

        LoggingOutputEx(0, 0, 'ultibottf', 'Found font ' + fontname + ' in ' + SearchRec.Name);

        VGShapesSetLayer(0);
        LoadedFont := FontManager.GetFont(fontname);

        for i := SECS downto 1 do
        begin
          VGShapesStart(Width, Height, true);

          //black background
          VGShapesBackground(0, 0, 0);

          // white text
          VGShapesStroke(255, 255, 255, 1.0);
          VGShapesFill(255, 255, 255, 1.0);

          VGShapesTextMid(Width div 2, Height div 2, 'This is the ' + fontname + ' font, Layer 0', LoadedFont, 40);
          VGShapesTextMid(Width div 2, Height div 2 + 70, inttostr(i), LoadedFont, 40);
          VGShapesEnd;

          Sleep(1000);
        end;

        VGShapesSetLayer(1);
        LoadedFont := FontManager.GetFont(fontname);

        for i := SECS downto 1 do
        begin
          VGShapesStart(Width, Height, true);

          //black background
          VGShapesBackgroundRGB(0, 0, 0, 0);

          // white text
          VGShapesStroke(255, 255, 255, 1.0);
          VGShapesFill(255, 255, 255, 1.0);

          VGShapesTextMid(Width div 2, Height div 2 - 70, 'This is the ' + fontname + ' font, Layer 1', LoadedFont, 40);
          VGShapesTextMid(Width div 2, Height div 2 - 140, inttostr(i), LoadedFont, 40);
          VGShapesEnd;

          Sleep(1000);
        end;

      until (FindNext(SearchRec) <> 0);

      FindClose(SearchRec);
    end;
  end;

end.

