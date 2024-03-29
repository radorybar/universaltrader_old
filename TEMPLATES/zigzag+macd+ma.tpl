<chart>
symbol=EURUSD
period=60
leftpos=62230
digits=4
scale=4
graph=1
fore=0
grid=0
volume=0
scroll=1
shift=1
ohlc=1
askline=1
days=1
descriptions=0
shift_size=20
fixed_pos=0
window_left=22
window_top=22
window_right=746
window_bottom=426
window_type=3
background_color=0
foreground_color=16777215
barup_color=2263842
bardown_color=36095
bullcandle_color=2263842
bearcandle_color=36095
chartline_color=16777215
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=129
<indicator>
name=main
<object>
type=2
object_name=Trendline 11584
period_flags=0
create_time=1229073728
color=6908265
style=0
weight=1
background=0
time_0=1228485600
value_0=1.262700
time_1=1228878000
value_1=1.284629
ray=0
</object>
<object>
type=2
object_name=Trendline 2100
period_flags=0
create_time=1228998708
color=6908265
style=0
weight=1
background=0
time_0=1228831200
value_0=1.279900
time_1=1229126400
value_1=1.320414
ray=0
</object>
<object>
type=2
object_name=Trendline 2115
period_flags=0
create_time=1228998723
color=6908265
style=0
weight=1
background=0
time_0=1228773600
value_0=1.296600
time_1=1229004000
value_1=1.303663
ray=0
</object>
<object>
type=2
object_name=Trendline 2294
period_flags=0
create_time=1229326582
color=6908265
style=0
weight=1
background=0
time_0=1228906800
value_0=1.290200
time_1=1229472000
value_1=1.373322
ray=0
</object>
<object>
type=2
object_name=Trendline 7119
period_flags=0
create_time=1229593551
color=6908265
style=0
weight=1
background=0
time_0=1229457600
value_0=1.377000
time_1=1229619600
value_1=1.443651
ray=0
</object>
<object>
type=2
object_name=Trendline 7124
period_flags=0
create_time=1229593556
color=6908265
style=0
weight=1
background=0
time_0=1229522400
value_0=1.404400
time_1=1229644800
value_1=1.461528
ray=0
</object>
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=ZigZag
flags=19
window_num=0
<inputs>
ExtDepth=12
ExtDeviation=5
ExtBackstep=3
</inputs>
</expert>
shift_0=0
draw_0=1
color_0=255
style_0=0
weight_0=0
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=20
shift=0
method=1
apply=1
color=11829830
style=0
weight=1
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=39
<indicator>
name=Custom Indicator
<expert>
name=MACD+HistogramDiff+SignalDiff
flags=275
window_num=1
<inputs>
FastEMA=12
SlowEMA=26
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
color_5=42495
style_5=0
weight_5=2
period_flags=0
show_data=1
</indicator>
</window>
</chart>

