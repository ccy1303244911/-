//闹钟模块，此模块中设置闹钟数值，后输出到时钟模块中，若计时值与闹钟数值相同，输出蜂鸣器
module alarm_clk(
input wire clk,
input wire rst_n,

input wire plus_filtered,   //闹钟数值设置加一按键
input wire alarm_ready_filtered,    //闹钟数值设置完成按键

input wire sw_s_10,         //闹钟数值设置开关，高电平有效
input wire sw_s_6,
input wire sw_m_10,
input wire sw_m_6,
input wire sw_h_4,
input wire sw_h_2,

input wire ALARM_SET,       //闹钟设置开始使能信号，从控制器接收ALARM_FLAG

output reg alarm_ready_flag_clk,     //输出的始终设置完毕标志,传输到数码管输出模块和控制模块，使其清零复位及等待计时,
output reg alarm_ready_flag_ctrl,
output reg [23:0] alarm,           //输出的时钟设定值
output reg [7:0] seg_alarm,       //闹钟数值的数码管显示，段选
output reg [5:0] sel_alarm        //数码管位选

);
reg ALARM_SET_REG;
reg alarm_ready_flag;

reg [3:0] alarm_s_10;
reg [3:0] alarm_s_6;
reg [3:0] alarm_m_10;
reg [3:0] alarm_m_6;
reg [3:0] alarm_h_4;
reg [3:0] alarm_h_2;
wire [5:0] input_sw;

assign input_sw={sw_h_2,sw_h_4,sw_m_6,sw_m_10,sw_s_6,sw_s_10};  //开关状态拼起来

//开关控制数码管位选
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n)
    begin
        alarm_s_10<=0;
        alarm_s_6<=0;
        alarm_m_10<=0;
        alarm_m_6<=0;
        alarm_h_4<=0;
        alarm_h_2<=0;
    end
    if (ALARM_SET_REG) 
    begin
        case (input_sw)
        6'b000001:
        begin
            sel_alarm<=6'b111110;
            if (plus_filtered) 
            begin
                alarm_s_10<=alarm_s_10+1;    
            end
            else if (alarm_s_10==4'd9&&plus_filtered) 
            begin
                alarm_s_10<=0;    
            end
        end 
        6'b000010:
        begin
            sel_alarm<=6'b111101;
            if (plus_filtered) 
            begin
                alarm_s_6<=alarm_s_6+1;    
            end
            else if (alarm_s_6==4'd5&&plus_filtered) 
            begin
                alarm_s_6<=0;    
            end
        end 
        6'b000100:
        begin
            sel_alarm<=6'b111011;
            if (plus_filtered) 
            begin
                alarm_m_10<=alarm_m_10+1;    
            end
            else if (alarm_m_10==4'd9&&plus_filtered) 
            begin
                alarm_m_10<=0;    
            end
        end 
        6'b001000:
        begin
            sel_alarm<=6'b110111;
            if (plus_filtered) 
            begin
                alarm_m_6<=alarm_m_6+1;    
            end
            else if (alarm_m_6==4'd5&&plus_filtered) 
            begin
                alarm_m_6<=0;    
            end
        end 
        6'b010000:
        begin
            sel_alarm<=6'b101111;
            if (plus_filtered) 
            begin
                alarm_h_4<=alarm_h_4+1;    
            end
            else if (alarm_h_4==4'd3&&plus_filtered) 
            begin
                alarm_h_4<=0;    
            end
        end 
        6'b100000:
        begin
            sel_alarm<=6'b011111;
            if (plus_filtered) 
            begin
                alarm_h_2<=alarm_h_2+1;    
            end
            else if (alarm_h_2==4'd2&&plus_filtered) 
            begin
                alarm_h_2<=0;    
            end
        end 
        default:
        begin
            sel_alarm<=sel_alarm;
            seg_alarm<=seg_alarm;
        end
    endcase    
    end
end

//按键输入值控制数码管段选
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        seg_alarm<=0;
    end   
    else if (ALARM_SET_REG) 
    begin
        if (input_sw==6'b000001) 
        begin
            case (alarm_s_10)
                4'h0:seg_alarm=8'b1100_0000;
                4'h1:seg_alarm=8'b1111_1001;
                4'h2:seg_alarm=8'b1010_0100;
                4'h3:seg_alarm=8'b1011_0000;
                4'h4:seg_alarm=8'b1001_1001;
                4'h5:seg_alarm=8'b1001_0010;
                4'h6:seg_alarm=8'b1000_0010;
                4'h7:seg_alarm=8'b1111_1000;
                4'h8:seg_alarm=8'b1000_0000;
                4'h9:seg_alarm=8'b1001_0000;
                default :seg_alarm=8'b1100_0000;
            endcase    
        end
        else if (input_sw==6'b000010) 
        begin
            case (alarm_s_6)
                4'h0:seg_alarm=8'b1100_0000;
                4'h1:seg_alarm=8'b1111_1001;
                4'h2:seg_alarm=8'b1010_0100;
                4'h3:seg_alarm=8'b1011_0000;
                4'h4:seg_alarm=8'b1001_1001;
                4'h5:seg_alarm=8'b1001_0010;
                default :seg_alarm=8'b1100_0000;
            endcase    
        end
        else if (input_sw==6'b000100) 
        begin
            case (alarm_m_10)
                4'h0:seg_alarm=8'b1100_0000;
                4'h1:seg_alarm=8'b1111_1001;
                4'h2:seg_alarm=8'b1010_0100;
                4'h3:seg_alarm=8'b1011_0000;
                4'h4:seg_alarm=8'b1001_1001;
                4'h5:seg_alarm=8'b1001_0010;
                4'h6:seg_alarm=8'b1000_0010;
                4'h7:seg_alarm=8'b1111_1000;
                4'h8:seg_alarm=8'b1000_0000;
                4'h9:seg_alarm=8'b1001_0000;
                default :seg_alarm=8'b1100_0000;
            endcase    
        end
        else if (input_sw==6'b001000) 
        begin
            case (alarm_m_6)
                4'h0:seg_alarm=8'b1100_0000;
                4'h1:seg_alarm=8'b1111_1001;
                4'h2:seg_alarm=8'b1010_0100;
                4'h3:seg_alarm=8'b1011_0000;
                4'h4:seg_alarm=8'b1001_1001;
                4'h5:seg_alarm=8'b1001_0010;
                default :seg_alarm=8'b1100_0000;
            endcase    
        end
        else if (input_sw==6'b010000) 
        begin
            case (alarm_h_4)
                4'h0:seg_alarm=8'b1100_0000;
                4'h1:seg_alarm=8'b1111_1001;
                4'h2:seg_alarm=8'b1010_0100;
                4'h3:seg_alarm=8'b1011_0000;
                default :seg_alarm=8'b1100_0000;
            endcase    
        end
        else if (input_sw==6'b100000) 
        begin
            case (alarm_h_2)
                4'h0:seg_alarm=8'b1100_0000;
                4'h1:seg_alarm=8'b1111_1001;
                4'h2:seg_alarm=8'b1010_0100;
                default :seg_alarm=8'b1100_0000;
            endcase    
        end
    end
end

//闹钟设置开始使能信号寄存器
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n)
    begin
        ALARM_SET_REG<=0;    
    end    
    else if (ALARM_SET) 
    begin
        ALARM_SET_REG<=1;       
    end
end

//设置完成标志alarm_ready_flag
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        alarm_ready_flag_clk<=0;
        alarm_ready_flag_ctrl<=0;
        alarm_ready_flag<=0;     
    end    
    else if (ALARM_SET_REG&&alarm_ready_filtered) 
    begin
        alarm_ready_flag_clk<=1; 
        alarm_ready_flag_ctrl<=1; 
        alarm_ready_flag<=1;   
    end
end

//设置完成后将设置值拼接
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        alarm<=24'b1111_1111_1111_1111_1111_1111;    
    end    
    else if (alarm_ready_flag) 
    begin
        alarm<={alarm_h_2,alarm_h_4,alarm_m_6,alarm_m_10,alarm_s_6,alarm_s_10}; 
    end
end

//设置完毕后数码管清零
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        seg_alarm<=0;    
    end    
    else if (alarm_ready_flag) 
    begin
        seg_alarm<=0;    
    end
end
endmodule

