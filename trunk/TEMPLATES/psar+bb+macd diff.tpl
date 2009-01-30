<chart>
symbol=EURUSD
period=5
leftpos=64923
digits=4
scale=8
graph=0
fore=0
grid=1
volume=0
scroll=1
shift=0
ohlc=1
askline=1
days=1
descriptions=0
shift_size=20
fixed_pos=0
window_left=22
window_top=22
window_right=519
window_bottom=264
window_type=3
background_color=16777215
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=16777215
bearcandle_color=0
chartline_color=0
volumes_color=32768
grid_color=12632256
askline_color=17919
stops_color=17919

<window>
height=100
<indicator>
name=main
</indicator>
<indicator>
name=Moving Average
period=20
shift=0
method=0
apply=0
color=16711680
style=0
weight=1
period_flags=0
show_data=1
</indicator>
<indicator>
name=Parabolic SAR
step=0.0200
end=0.2000
color=255
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Bollinger Bands
period=10
shift=0
deviations=2
apply=0
color=42495
style=0
weight=1
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
<indicator>
name=Custom Indicator
<expert>
name=MACD+HistogramDiff+SignalDiff
flags=275
window_num=1
<inputs>
FastEMA=10
SlowEMA=20
SignalSMA=9
MacdDiffMultiply=5
SignalMacdDiffMultiply=1
MacdDiffDiffMultiply=1
</inputs>
</expert>
shift_0=0
draw_0=2
color_0=12632256
style_0=0
weight_0=5
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=0
shift_2=0
draw_2=2
color_2=16711680
style_2=0
weight_2=2
shift_3=0
draw_3=0
color_3=32768
style_3=0
weight_3=2
shift_4=0
draw_4=0
color_4=65535
style_4=0
weight_4=2
shift_5=0
draw_5=0
color_5=0
style_5=0
weight_5=1
period_flags=0
show_data=1
</indicator>
</window>
</chart>
