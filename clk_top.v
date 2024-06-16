module clk_top (
input wire clk,
input wire rst_n,

input wire CLK_EN,      //总状态输入按键
input wire TIME_EN, 
input wire PAUSE,   
input wire PREVIOUS,
input wire CLEAR,   
input wire ALARM,   

input wire plus,        //设置闹钟加一输入按键
input wire alarm_ready, //设置闹钟完成输入按键

input wire sw_s_10,     //设置闹钟位数选择开关
input wire sw_s_6,
input wire sw_m_10,
input wire sw_m_6,
input wire sw_h_4,
input wire sw_h_2,

output wire [7:0] seg,  
output wire [5:0] sel,
output wire [7:0] seg_alarm,  
output wire [5:0] sel_alarm,
output wire buzzer,     

);
wire CLK_EN_filtered;   
wire TIME_EN_filtered;
wire PAUSE_filtered;
wire PREVIOUS_filtered;
wire CLEAR_filtered;
wire ALARM_filtered;

wire plus_filtered;      
wire alarm_ready_filtered;

wire alarm_ready_flag_clk;
wire alarm_ready_flag_ctrl;     

wire CLK_R;             
wire TIME_R; 
wire PAUSE_R;
wire STOP_R; 
wire CLEAR_R;
wire PRE_R;

wire clk_1k;
wire key_state;
    CTRL_FSM_1 CTRL_FSM_1_u(
        .clk(clk),
        .rst_n(rst_n),
        .alarm_ready_R_ctrl(alarm_ready_flag_ctrl),  
        .EN_FLAG(EN_FLAG),
        .TIME_FLAG(TIME_FLAG),
        .PAUSE_FLAG(PAUSE_FLAG),
        .STOP_FLAG(STOP_FLAG),
        .PRE_FLAG(PRE_FLAG),
        .CLEAR_FLAG(CLEAR_FLAG),
        .ALARM_FLAG(ALARM_FLAG),
        .CLK_EN_filtered(CLK_EN_filtered),  
        .TIME_EN_filtered(TIME_EN_filtered),
        .PAUSE_filtered(PAUSE_filtered),
        .PREVIOUS_filtered(PREVIOUS_filtered),
        .CLEAR_filtered(CLEAR_filtered),
        .ALARM_filtered(ALARM_filtered)
        
    );
    clk_extra clk_extra_u(
        .clk(clk),
        .rst_n(rst_n),
        .CLK_R(EN_FLAG),    
        .TIME_R(TIME_FLAG), 
        .PAUSE_R(PAUSE_FLAG),
        .STOP_R(STOP_FLAG),   
        .CLEAR_R(CLEAR_FLAG), 
        .PRE_R(PRE_FLAG), 
        .alarm_R(alarm), 
        .alarm_ready_R_clk(alarm_ready_flag_clk),
        .data_out(data_out),
        .buzzer(buzzer)
    );
    digital_tube_driver digital_tube_driver_u(
        .clk(clk),
        .rst_n(rst_n),
        .clk_1k(clk_1k),
        .data_in(data_out),
        .seg(seg),
        .sel(sel)
    );
    alarm_clk alarm_clk_u(
        .clk(clk),
        .rst_n(rst_n),   
        .plus_filtered(plus_filtered),
        .alarm_ready_filtered(alarm_ready_filtered),
        .sw_s_10(sw_s_10),         
        .sw_s_6(sw_s_6),
        .sw_m_10(sw_m_10),
        .sw_m_6(sw_m_6),
        .sw_h_4(sw_h_4),
        .sw_h_2(sw_h_2),
        .ALARM_SET(ALARM_FLAG),       
        .alarm_ready_flag_clk(alarm_ready_flag_clk),
        .alarm_ready_flag_ctrl(alarm_ready_flag_ctrl),    
        .alarm(alarm),
        .seg_alarm(seg_alarm),
        .sel_alarm(sel_alarm)
    );

    clk_1k clk_1k_u(
        .clk(clk),
        .rst_n(rst_n),
        .clk_1k(clk_1k)
    );
    keypress keypress_u_1(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(CLK_EN),
        .KEY_FLAG(CLK_EN_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_2(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(TIME_EN),
        .KEY_FLAG(TIME_EN_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_3(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(PAUSE),
        .KEY_FLAG(PAUSE_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_4(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(CLEAR),
        .KEY_FLAG(CLEAR_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_5(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(PREVIOUS),
        .KEY_FLAG(PREVIOUS_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_6(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(ALARM),
        .KEY_FLAG(ALARM_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_7(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(plus),
        .KEY_FLAG(plus_filtered),
        .KEY_STATE(key_state)

    );
        keypress keypress_u_8(
        .clk(clk),
        .rst_n(rst_n),
        .KEY_IN(alarm_ready),
        .KEY_FLAG(alarm_ready_filtered),
        .KEY_STATE(key_state)

    );

endmodule

