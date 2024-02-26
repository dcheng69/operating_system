<mxfile host="app.diagrams.net" modified="2024-02-26T01:44:34.796Z" agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.82" etag="4cw_OSI9W1KLQh2W_YMm" version="23.1.6" type="device">
  <diagram name="Page-1" id="3jJNJnvzM2DXYzioqWPK">
    <mxGraphModel dx="1379" dy="834" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="hSqVNPL862_R4czRoXGe-1" value="Interrupt Vector Table (1 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#6d8764;strokeColor=#3A5431;fontColor=#ffffff;" vertex="1" parent="1">
          <mxGeometry x="360" y="620" width="270" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-2" value="BIOS Data Area (256 bytes)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#6d8764;strokeColor=#3A5431;fontColor=#ffffff;" vertex="1" parent="1">
          <mxGeometry x="360" y="600" width="270" height="20" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-3" value="" style="endArrow=classic;startArrow=classic;html=1;rounded=0;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="60" y="670" as="sourcePoint" />
            <mxPoint x="60" y="170" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-4" value="low address" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="80" y="640" width="80" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-5" value="high address" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="80" y="170" width="80" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-6" value="0x0000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="640" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-7" value="0x0400" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="610" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-8" value="0x0500" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="590" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-9" value="Free (29.75 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
          <mxGeometry x="360" y="520" width="270" height="80" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-10" value="0x7C00" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="510" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-11" value="Loaded Boot Sector (512 bytes)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#60a917;strokeColor=#2D7600;dashed=1;fontColor=#ffffff;" vertex="1" parent="1">
          <mxGeometry x="360" y="490" width="270" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-12" value="Free (638 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
          <mxGeometry x="360" y="330" width="270" height="160" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-13" value="0x7E00" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="480" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-14" value="Extended BIOS Data Area (639 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#6d8764;strokeColor=#3A5431;fontColor=#ffffff;" vertex="1" parent="1">
          <mxGeometry x="360" y="250" width="270" height="80" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-15" value="Video Memory (128 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#6d8764;strokeColor=#3A5431;fontColor=#ffffff;" vertex="1" parent="1">
          <mxGeometry x="360" y="220" width="270" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-16" value="BIOS (256 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#6d8764;strokeColor=#3A5431;fontColor=#ffffff;" vertex="1" parent="1">
          <mxGeometry x="360" y="180" width="270" height="40" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-17" value="" style="shape=document;whiteSpace=wrap;html=1;boundedLbl=1;rotation=-180;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
          <mxGeometry x="360" y="100" width="270" height="80" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-18" value="0x9FC00" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="320" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-19" value="0xA0000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="240" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-20" value="0xC0000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="210" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-21" value="0x100000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="280" y="170" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-22" value="Free (29.75 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
          <mxGeometry x="790" y="520" width="270" height="80" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-23" value="" style="endArrow=classic;html=1;rounded=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1" source="hSqVNPL862_R4czRoXGe-9" target="hSqVNPL862_R4czRoXGe-22">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="630" y="610" as="sourcePoint" />
            <mxPoint x="700.7106781186548" y="560" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-24" value="Stack Space" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];" vertex="1" connectable="0" parent="hSqVNPL862_R4czRoXGe-23">
          <mxGeometry x="-0.1625" relative="1" as="geometry">
            <mxPoint x="13" y="-10" as="offset" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-25" value="" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="1180" y="520" as="sourcePoint" />
            <mxPoint x="1180" y="595" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-26" value="Decreasing" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1210" y="540" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-27" value="ebp" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1120" y="512.5" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-28" value="esp" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1120" y="542.5" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-29" value="" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="1130" y="530" as="sourcePoint" />
            <mxPoint x="1070" y="530" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-30" value="" style="endArrow=classic;html=1;rounded=0;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="1130" y="559.5" as="sourcePoint" />
            <mxPoint x="1070" y="559.5" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-31" value="" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
          <mxGeometry x="790" y="320" width="270" height="160" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-32" value="" style="endArrow=classic;html=1;rounded=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="630" y="409.5" as="sourcePoint" />
            <mxPoint x="790" y="409.5" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-33" value="Loader &amp;amp; Kernel" style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];" vertex="1" connectable="0" parent="hSqVNPL862_R4czRoXGe-32">
          <mxGeometry x="-0.1625" relative="1" as="geometry">
            <mxPoint x="13" y="-10" as="offset" />
          </mxGeometry>
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-34" value="FAT 12 Root Directory (512 bytes)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontColor=#333333;" vertex="1" parent="1">
          <mxGeometry x="790" y="460" width="270" height="20" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-35" value="Space For Loader (4 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" vertex="1" parent="1">
          <mxGeometry x="790" y="380" width="270" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-36" value="0x7E00" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1070" y="470" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-37" value="0x8000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1070" y="450" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-38" value="FAT1 Tables (4.5 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;fontColor=#333333;" vertex="1" parent="1">
          <mxGeometry x="790" y="430" width="270" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-39" value="0x9200" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1070" y="420" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-40" value="0xA000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1070" y="395" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-41" value="0xB000" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1070" y="365" width="60" height="30" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-42" value="Space For Kernel (595 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" vertex="1" parent="1">
          <mxGeometry x="790" y="320" width="270" height="60" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-43" value="Free (3.5 kB)" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
          <mxGeometry x="790" y="410" width="270" height="20" as="geometry" />
        </mxCell>
        <mxCell id="hSqVNPL862_R4czRoXGe-44" value="0x9FC0" style="text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;" vertex="1" parent="1">
          <mxGeometry x="1070" y="310" width="60" height="30" as="geometry" />
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
