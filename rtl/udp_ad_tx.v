module udp_ad_tx#(
    //parameter define
    //开发板MAC地址 00-11-22-33-44-55
    parameter BOARD_MAC = 48'h00_11_22_33_44_55,
    //开发板IP地址 192.168.1.123     
    parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd123},
    //目的MAC地址 ff_ff_ff_ff_ff_ff
    parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff,
    //目的IP地址 192.168.1.102     
    parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102}
)(
    input              sys_clk   , //系统时钟
    input              sys_rst_n , //系统复位信号，低电平有效
    //前端AD模块接口
    input              ad_clk    , //AD模块输出数据时钟
    input       [7:0]  ad_data   , //AD模块输出数据
    input              ad_data_en, //AD模块输出数据有效
    //以太网RGMII接口 
    //接受端，可接可不接  
    input              eth_rxc   , //RGMII接收数据时钟
    input              eth_rx_ctl, //RGMII输入数据有效信号
    input       [3:0]  eth_rxd   , //RGMII输入数据
    //发送端
    output             eth_txc   , //RGMII发送数据时钟    
    output             eth_tx_ctl, //RGMII输出数据有效信号
    output      [3:0]  eth_txd   , //RGMII输出数据          
    output             eth_rst_n   //以太网芯片复位信号，低电平有效
);

wire                gmii_tx_clk;
wire                gmii_tx_en ;
wire [7:0]          gmii_txd   ;

wire [7:0]          crc_d8     ;
wire                crc_en     ;
wire                crc_clr    ;
wire [31:0]         crc_data   ;
wire [31:0]         crc_next   ;

wire                frame_tx_start;
wire                frame_tx_done ;
wire [7:0]          buffer_rd_data    ;
wire                buffer_rd_en      ;
wire [15:0]         buffer_rd_byte_num;

assign crc_d8 = gmii_txd;

//只需要输入rgmii_rxc时钟  
gmii_to_rgmii gumii_to_rgmii_u0(
    .gmii_rx_clk         (), //output         GMII接收时钟
    .gmii_rx_dv          (), //output         GMII接收数据有效信号
    .gmii_rxd            (), //output[7:0]    GMII接收数据

    .gmii_tx_clk         (gmii_tx_clk), //output         GMII发送时钟
    .gmii_tx_en          (gmii_tx_en ), //input          GMII发送数据使能信号
    .gmii_txd            (gmii_txd   ), //input [7:0]    GMII发送数据            
    .//以太网RGMI接口   
    .rgmii_rxc           (eth_rxc   ), //input         RGMII接收时钟
    .rgmii_rx_ctl        (eth_rx_ctl), //input         RGMII接收数据控制信号
    .rgmii_rxd           (eth_rxd   ), //input [3:0]   RGMII接收数据
    .rgmii_txc           (eth_txc   ), //output        RGMII发送时钟    
    .rgmii_tx_ctl        (eth_tx_ctl), //output        RGMII发送数据控制信号
    .rgmii_txd           (eth_txd   )  //output[3:0]   RGMII发送数据
);

udp_tx#(
.BOARD_MAC              (BOARD_MAC),
.BOARD_IP               (BOARD_IP ),
.DES_MAC                (DES_MAC  ),
.DES_IP                 (DES_IP   )
)
udp_tx_u0
(
    .clk        (gmii_tx_clk), //input         时钟信号
    .rst_n      (sys_rst_n), //input         复位信号，低电平有效

    .tx_start_en(frame_tx_start), //input         以太网开始发送信号
	.tx_data    (buffer_rd_data), //input [ 7:0]  以太网待发送数据 
    .tx_byte_num(buffer_rd_byte_num), //input [15:0]  以太网发送的有效字节数
    //设置为0是使用的是DES_MAC和DES_IP
    .des_mac    (48'd0), //input [47:0]  发送的目标MAC地址
    .des_ip     (32'd0), //input [31:0]  发送的目标IP地址  

    .crc_data   (crc_data), //input [31:0]  CRC校验数据
    .crc_next   (crc_next[31:25]), //input [ 7:0]  CRC下次校验完成数据，接crc_next高八位

    .tx_done    (frame_tx_done ), //output        以太网发送完成信号

    .tx_req     (buffer_rd_en), //output        读数据请求信号

    .gmii_tx_en (gmii_tx_en  ), //output        GMII输出数据有效信号
    .gmii_txd   (gmii_txd    ), //output [7:0]  GMII输出数据
    .crc_en     (crc_en      ), //output        CRC开始校验使能
    .crc_clr    (crc_clr     )  //output        CRC数据复位信号 
);

//例化以太网发送CRC校验模块
crc32_d8 crc_u0(
    .clk             (gmii_tx_clk), //input          时钟信号                     
    .rst_n           (sys_rst_n  ), //input          复位信号，低电平有效                         
    .data            (crc_d8     ), //input [7:0]    接gmii_txd         
    .crc_en          (crc_en     ), //input          CRC开始校验使能                         
    .crc_clr         (crc_clr    ), //input          CRC数据复位信号                        
    .crc_data        (crc_data   ), //output[31:0]   CRC校验数据                       
    .crc_next        (crc_next   )  //output[31:0]   CRC下次校验完成数据                       
);

//编写缓冲模块处理tx_start_en、tx_data、tx_byte_num信号
bufffer buffer_u0(
    .clk             (sys_clk), //input         时钟信号
    .rst_n           (sys_rst_n), //input         复位信号，低电平有效
    .wr_clk          (ad_clk), //input         写数据时钟
    .wr_data         (ad_data   ), //input [7:0]   缓冲区写入数据，接AD模块输出数据
    .wr_en           (ad_data_en), //input         写使能信号，接AD模块输出数据有效信号

    .frame_tx_start  (frame_tx_start), //output        开始发送信号，接tx_start_en
    .frame_tx_done   (frame_tx_done ), //input         发送结束信号，接tx_done
    .rd_clk          (gmii_tx_clk), //input         读数据时钟，即gmii_tx时钟
    .rd_data         (buffer_rd_data    ), //output[7:0]   缓冲区读出数据，接tx_data
    .rd_en           (buffer_rd_en      ), //input         读使能信号，接tx_req
    .rd_byte_num     (buffer_rd_byte_num)  //output[15:0]  每帧读出的数据字节数，初步定为1024字节
);
endmodule