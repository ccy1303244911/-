//数码管驱动模块 
`timescale 1ns/1ps
module digital_tube_driver(
input wire clk,
input wire rst_n,
input wire clk_1k,  //由clk_1k模块输入进来的分频时钟信号
input wire [23:0] data_in,
output reg [7:0] seg,   //数码管段选,abcdef顺时针排列，g为中间的横
output reg [5:0] sel    //数码管位选(即片选)

);

wire START_EN;         //开始显示输出的标志信号，当输入数据到来后拉高，状态机从空闲态转跳到S0
reg data_in_d0;//对输入信号进行寄存打拍，方便边沿检测
reg data_in_d1;
reg EN_FLAG;    //寄存使能脉冲信号的状态寄存器

reg [5:0] current_state;
reg [5:0] next_state;
reg [3:0] data_temp;    //寄存输入24位数据的某四位，即对应某个数码管

parameter cnt_MAX=50000/2-1;
parameter  [5:0] IDLE=6'b000000;   
parameter  [5:0] S0=6'b011111;       
parameter  [5:0] S1=6'b101111;
parameter  [5:0] S2=6'b110111;
parameter  [5:0] S3=6'b111011;
parameter  [5:0] S4=6'b111101;
parameter  [5:0] S5=6'b111110;

//对输入信号进行边沿检测
always @(posedge clk_1k or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        data_in_d0<=0;
        data_in_d1<=0;    
    end    
    else 
        data_in_d0<=data_in;
        data_in_d1<=data_in_d0;
end
assign START_EN=data_in_d0&&~data_in_d1;
//寄存边沿检测值到使能寄存器中
always @(posedge clk_1k or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        EN_FLAG<=0;    
    end    
    else if (START_EN) 
    begin
        EN_FLAG<=1;    
    end
end

//数码管位选扫描状态机
always @(posedge clk_1k or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        current_state<=IDLE;    
    end    
    else
        current_state<=next_state;
end
//状态转移
always @(posedge clk_1k or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        next_state<=IDLE;    
    end    
    else case (current_state)
        IDLE:begin
        if (EN_FLAG) 
        begin
            next_state<=S0;    
        end
        end
        S0: next_state<=S1;
        S1: next_state<=S2;
        S2: next_state<=S3;
        S3: next_state<=S4;
        S4: next_state<=S5;
        S5: next_state<=S0;
        default: next_state<=IDLE;
    endcase
end
//由寄存的四位数据译码选出数码管
always @(posedge clk_1k or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        sel<=6'b111111;
        data_temp<=4'b0000;    
    end    
    else case (current_state)
        S0:begin 
            sel<=S0;
            data_temp<=data_in[23:20];
        end
        S1:begin 
            sel<=S1;
            data_temp<=data_in[19:16];
        end
        S2:begin 
            sel<=S2;
            data_temp<=data_in[15:12];
        end
        S3:begin 
            sel<=S3;
            data_temp<=data_in[11:8];
        end
        S4:begin 
            sel<=S4;
            data_temp<=data_in[7:4];
        end
        S5:begin 
            sel<=S5;
            data_temp<=data_in[3:0];
        end
        default:begin 
        sel<=S0; data_temp<=data_in[23:20];
        end
    endcase
end
//输出(数码管译码)
always @(*)  
begin
    if(!rst_n)
    begin
        seg=8'h0;
    end
    else 
    case(data_temp)
        4'h0:seg=8'b1100_0000;
        4'h1:seg=8'b1111_1001;
        4'h2:seg=8'b1010_0100;
        4'h3:seg=8'b1011_0000;
        4'h4:seg=8'b1001_1001;
        4'h5:seg=8'b1001_0010;
        4'h6:seg=8'b1000_0010;
        4'h7:seg=8'b1111_1000;
        4'h8:seg=8'b1000_0000;
        4'h9:seg=8'b1001_0000;
        default :seg=8'b1100_0000;
   endcase
end

    clk_1k clk_1k_u(
        .clk(clk),
        .rst_n(rst_n),
        .clk_1k(clk_1k)
    );
endmodule

