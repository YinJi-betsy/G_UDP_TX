bufffer(
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