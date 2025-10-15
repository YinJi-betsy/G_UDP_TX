module bufffer(
    input           clk           ,   //时钟信号
    input           rst_n         ,   //复位信号，低电平有效
    input           wr_clk        ,   //写数据时钟
    input [7:0]     wr_data       ,   //缓冲区写入数据，接AD模块输出数据
    input           wr_en         ,   //写使能信号，接AD模块输出数据有效信号

    output          frame_tx_start,   //开始发送信号，接tx_start_en
    input           frame_tx_done ,   //发送结束信号，接tx_done
    input           rd_clk        ,   //读数据时钟，即gmii_tx时钟
    output[7:0]     rd_data       ,   //缓冲区读出数据，接tx_data
    input           rd_en         ,   //读使能信号，接tx_req
    output[15:0]    rd_byte_num       //每帧读出的数据字节数，初步定为1024字节
);
//对于输出信号，先处理reg变量再输出
reg                 r_frame_tx_start;

//对于输入信号，处理打拍信号
wire                w_frame_tx_done;

wire                w_fifo_full;
wire                w_fifo_full_1d

assign              frame_tx_start = r_frame_tx_start;
/*****************读数据*******************/
//信号打拍
always@(posedge rd_clk or negedge rst_n)
begin
    if(!rst_n)begin
        w_frame_tx_done <= 0;
        w_fifo_full_1d <= 0;
    end
    else begin
        w_frame_tx_done <= frame_tx_done;
        w_fifo_full_1d <= w_fifo_full;
    end
end
//r_frame_tx_start
always@(posedge rd_clk or negedge rst_n)
begin
    if(!rst_n)
        r_frame_tx_start <= 0;
    else if()               //当缓冲区满时拉高或者当前帧数据frame_tx_done之后拉高
        r_frame_tx_start <= 1;
    else
        r_frame_tx_start <= 0;
end

endmodule