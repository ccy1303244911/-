//时钟控制模块，已测试完成
module CTRL_FSM_1 (
input wire clk,
input wire rst_n,
input wire alarm_ready_R_ctrl,   //从闹钟设置模块接收的设置完成信号

input wire CLK_EN_filtered,     //从按键消抖模块接收的消抖后的输入按键信号
input wire TIME_EN_filtered,
input wire PAUSE_filtered,
input wire PREVIOUS_filtered,
input wire CLEAR_filtered,
input wire ALARM_filtered,

output reg EN_FLAG,
output reg TIME_FLAG,
output reg PAUSE_FLAG,
output reg STOP_FLAG,
output reg PRE_FLAG,
output reg CLEAR_FLAG,
output reg ALARM_FLAG   //闹钟设置状态标志
);

reg EN_FLAG_REG;
reg TIME_FLAG_REG;
reg PAUSE_FLAG_REG;
reg STOP_FLAG_REG;
reg PRE_FLAG_REG;
reg CLEAR_FLAG_REG;
reg ALARM_FLAG_REG;

reg [7:0] current_state;
reg [7:0] next_state;

parameter IDLE=7'b0000000;
parameter OPENING=7'b0000001;
parameter COUNTING=7'b000010;
parameter PAUSING=7'b0000100;
parameter STOPPING=7'b0001000; //计时状态下若再次按下计时按钮，进入停止计时状态，此时可以选择清零或者显示上一次计时内容
parameter ZERO=7'b0010000;     //清零态，停止计时状态下按下清零按钮进入清零状态
parameter LAST_TIME=7'b0100000;   //停止计时时候按下PREVIOUS显示上次计时内容
parameter ALARM_SETTING=7'b1000000;  //闹钟设置状态，仅当开机标志标志有效且未进入计时状态时可以进入

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        current_state<=IDLE;
    end    
    else
        current_state<=next_state;
end

always@(*)
begin
    case (current_state)

        IDLE: 
        begin
            if (CLK_EN_filtered) 
            begin
                next_state<=OPENING;    
            end
            else
                next_state<=IDLE;
        end
        OPENING:
        begin
            if (TIME_EN_filtered) 
            begin
                next_state<=COUNTING;    
            end 
            else if (ALARM_filtered) 
            begin
                next_state<=ALARM_SETTING;    
            end
            else
                next_state<=OPENING;
        end
        COUNTING:
        begin
            if (PAUSE_filtered) 
            begin
                next_state<=PAUSING;    
            end
            else if (TIME_EN_filtered) 
            begin
                next_state<=STOPPING;    //计时时再次按下开始建，停止计时
            end
            else
                next_state<=COUNTING;
        end
        PAUSING:
        begin
            if (PAUSE_filtered) 
            begin
                next_state<=COUNTING;  //暂停时再次按下暂停键，继续计时  
            end
            else if (TIME_EN_filtered) 
            begin
                next_state<=STOPPING;    //暂停时按下开始计时键，停止计时，保存当前计时值
            end
            else
                next_state<=PAUSING;
        end
        STOPPING:       //停止即使状态，需寄存该状态时时钟数值以便清零后回到该状态
        begin
            if (CLEAR_filtered) 
            begin
                next_state<=ZERO;    
            end
            else
                next_state<=STOPPING;
        end
        ZERO:  //控制状态和时钟状态均要清零
        begin
            if (PREVIOUS_filtered) 
            begin
                next_state<=LAST_TIME;    
            end
            else if (TIME_EN_filtered) 
            begin
                next_state<=COUNTING;   //清零后可按下开始计时键继续计时    
            end
            else
                next_state<=ZERO;
        end
        LAST_TIME:
            if (CLEAR_filtered) 
            begin
                next_state<=ZERO;    
            end
        ALARM_SETTING:
            if (alarm_ready_R_ctrl) 
            begin
                if (TIME_EN_filtered) 
                begin
                    next_state<=COUNTING;    
                end 
                else
                    next_state<=ALARM_SETTING;   
            end
            default:next_state<=IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        EN_FLAG_REG<=0;
        TIME_FLAG_REG<=0;
        PAUSE_FLAG_REG<=0;
        STOP_FLAG_REG<=0;
        PRE_FLAG_REG<=0;
        CLEAR_FLAG_REG<=0; 
        ALARM_FLAG_REG<=0;
    end
    else case (next_state)
        IDLE:
            begin
                EN_FLAG_REG<=0;
                TIME_FLAG_REG<=0;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=0;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=0;
            end
        OPENING: 
            begin
                EN_FLAG_REG<=1;
                TIME_FLAG_REG<=0;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=0;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=0;
            end
        COUNTING: 
            begin
                EN_FLAG_REG<=1;
                TIME_FLAG_REG<=1;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=0;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=0;
            end
        PAUSING: 
            begin
                EN_FLAG_REG<=1;
                TIME_FLAG_REG<=1;
                PAUSE_FLAG_REG<=1;
                STOP_FLAG_REG<=0;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=0;
            end
        STOPPING: 
            begin
                EN_FLAG_REG<=1;
                TIME_FLAG_REG<=1;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=1;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;//计时状态下按下开始计时进入停止状态
                ALARM_FLAG_REG<=0;
            end
        ZERO:    
            begin 
                EN_FLAG_REG<=1;
                TIME_FLAG_REG<=1;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=1;
                CLEAR_FLAG_REG<=1;   //停止状态下按下清零进入清零状态
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=0;
            end
        LAST_TIME: 
            begin
                EN_FLAG_REG<=1;
                TIME_FLAG_REG<=1;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=1;
                CLEAR_FLAG_REG<=1;
                PRE_FLAG_REG<=1;
                ALARM_FLAG_REG<=0;
            end
        ALARM_SETTING:
        begin
                EN_FLAG_REG<=1;         //开机状态下按下ALARM进入闹钟设置状态
                TIME_FLAG_REG<=0;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=0;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=1;
        end
    
        default:  
            begin
                EN_FLAG_REG<=0;
                TIME_FLAG_REG<=0;
                PAUSE_FLAG_REG<=0;
                STOP_FLAG_REG<=0;
                CLEAR_FLAG_REG<=0;
                PRE_FLAG_REG<=0;
                ALARM_FLAG_REG<=0;
            end
    endcase
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        EN_FLAG<=0;
        TIME_FLAG<=0;
        PAUSE_FLAG<=0;
        STOP_FLAG<=0;
        PRE_FLAG<=0;
        CLEAR_FLAG<=0;
        ALARM_FLAG<=0;
    end    
    else
        EN_FLAG<=EN_FLAG_REG;
        TIME_FLAG<=TIME_FLAG_REG;
        PAUSE_FLAG<=PAUSE_FLAG_REG;
        STOP_FLAG<=STOP_FLAG_REG;
        PRE_FLAG<=PRE_FLAG_REG;
        CLEAR_FLAG<=CLEAR_FLAG_REG;
        ALARM_FLAG<=ALARM_FLAG_REG;
end

endmodule
