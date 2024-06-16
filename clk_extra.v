//加入额外功能的时钟模�?
module clk_extra (
input wire clk,
input wire rst_n,

input wire CLK_R,    //从状态控制器接收的状态信号
input wire TIME_R, 
input wire PAUSE_R,
input wire STOP_R,   
input wire CLEAR_R, 
input wire PRE_R, 

input wire alarm_ready_R_clk,   //从闹钟模块接受的闹钟设置完成信号
input wire [23:0] alarm_R, //从闹钟模块接受的闹钟设置值
   
output reg [23:0] data_out,
output reg buzzer   //蜂鸣器输出闹钟
);
reg [23:0] data_out_reg;
reg [23:0] STOPPING_REG;    //计数停止时计数值寄存器
reg alarm_ready_R_reg;  //将闹钟模块发来的设置完成信号寄存
reg [23:0] alarm_R_reg;
reg equal;      //比较器输出变量
reg greater;
reg less;

reg [25:0] cnt;
reg [3:0] cnt_s_10;
reg [3:0] cnt_s_6;
reg [3:0] cnt_m_10;
reg [3:0] cnt_m_6;
reg [3:0] cnt_h_4;
reg [3:0] cnt_h_2;

reg [5:0] STATE_FLAG;   //输入的六个状态标志拼成一�?
parameter CNT_MAX=49999999;

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        STATE_FLAG<=0;    
    end    
    else
        STATE_FLAG<={CLK_R,TIME_R,PAUSE_R,STOP_R,CLEAR_R,PRE_R};
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt<=0;    
    end        
    else if (cnt==CNT_MAX) 
    begin
        cnt<=0;    
    end
    else if (STATE_FLAG==6'b110000) 
    begin
        cnt<=cnt+1;
    end
    else
        cnt<=cnt;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt_s_10<=0;
    end    
    else if (cnt==CNT_MAX&&STATE_FLAG==6'b110000) 
    begin
        cnt_s_10<=cnt_s_10+1;    
    end
    else if (cnt_s_10==10)
    begin
        cnt_s_10<=0;
    end 
    else
        cnt_s_10<=cnt_s_10;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt_s_6<=0;
    end    
    else if (cnt_s_10==10&&STATE_FLAG==6'b110000) 
    begin
        cnt_s_6<=cnt_s_6+1;    
    end
    else if(cnt_s_6==6)
    begin
        cnt_s_6<=0;
    end 
    else
        cnt_s_6<=cnt_s_6;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt_m_10<=0;
    end    
    else if (cnt_s_6==6&&STATE_FLAG==6'b110000) 
    begin
        cnt_m_10<=cnt_m_10+1;    
    end
    else if (cnt_m_10==10)
    begin
        cnt_m_10<=0;
    end
    else
        cnt_m_10<=cnt_m_10;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt_m_6<=0;
    end    
    else if (cnt_m_10==10&&STATE_FLAG==6'b110000) 
    begin
        cnt_m_6<=cnt_m_6+1;    
    end
    else if (cnt_m_6==6)
    begin
        cnt_m_6<=0;
    end 
    else
        cnt_m_6<=cnt_m_6;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt_h_4<=0;    
    end
    else if (cnt_m_6==6&&STATE_FLAG==6'b110000) 
    begin
        cnt_h_4<=cnt_h_4+1;    
    end
    else if (cnt_h_4==10)
    begin
        cnt_h_4<=0;
    end
    else
        cnt_h_4<=cnt_h_4;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt_h_2<=0;    
    end
    else if (cnt_h_4==10&&STATE_FLAG==6'b110000) 
    begin
        cnt_h_2<=cnt_h_2+1;    
    end
    else if (cnt_h_2==2&&cnt_h_4==4)
    begin
        cnt_h_2<=0;
    end
    else
        cnt_h_2<=cnt_h_2;
end
/*--------------------------------------------------------------------------------------------*/

//STOPPING_REG寄存停止计时时的计时值，按下PRE键后显示
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        STOPPING_REG<=0;    
    end    
    else if (STATE_FLAG==6'b110100) 
    begin
        STOPPING_REG<={cnt_h_2,cnt_h_4,cnt_m_6,cnt_m_10,cnt_s_6,cnt_s_10};    
    end   
end

//data_out_reg输出计时值寄存器
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        data_out_reg<=0;    
    end
    else if (STATE_FLAG==6'b110110)   //清零状态到来的时状态暂存器清零
    begin
        data_out_reg<=0;    
    end    
    else if (STATE_FLAG==6'b110111)   //先前状态到来时，停止状态寄存器中的值赋给暂存器
    begin
        data_out_reg<=STOPPING_REG;    
    end
    else if (buzzer==1) 
    begin
        data_out_reg<=data_out_reg;  
    end
    else
        data_out_reg<={cnt_h_2,cnt_h_4,cnt_m_6,cnt_m_10,cnt_s_6,cnt_s_10};
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        data_out<=0;    
    end    
    else
        data_out<=data_out_reg;
end

//alarm_ready_R_reg,闹钟设置完成寄存信号
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        alarm_ready_R_reg<=0;    
    end    
    else if (alarm_ready_R_clk) 
    begin
        alarm_ready_R_reg<=1;
    end
end
//寄存闹钟设置值
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        alarm_R_reg<=0;    
    end    
    else
        alarm_R_reg<=alarm_R;
end

//设置比较器
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        equal<=0;
        greater<=0;
        less<=0;    
    end    
    else if (data_out_reg==alarm_R_reg) 
    begin
        equal<=1; 
        greater<=0;
        less<=0;   
    end
    else if (data_out_reg<alarm_R_reg) 
    begin
        equal<=0; 
        greater<=1;
        less<=0;  
    end
    else if (data_out_reg>alarm_R_reg) 
    begin
        equal<=0; 
        greater<=0;
        less<=1; 
    end  
end

//驱动蜂鸣器buzzer
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        buzzer<=0;    
    end    
    else if (equal&&alarm_ready_R_reg) 
    begin
        buzzer<=1;    
    end
end

endmodule
