//分频产生1khz的时钟来扫描数码管
module clk_1k (
input wire clk,
input wire rst_n,
output reg clk_1k
);
reg [31:0] cnt;
parameter CNT_MAX=50000/2-1;

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        cnt<=0;  
        clk_1k<=0;  
    end    
    else if (cnt==CNT_MAX) 
    begin
        cnt<=0; 
        clk_1k<=~clk_1k;   
    end
    else
        cnt<=cnt+1;
        
end
endmodule
