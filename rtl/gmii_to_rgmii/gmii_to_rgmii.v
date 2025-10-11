module gmii_to_rgmii(
    //��̫��GMII�ӿ�
    output             gmii_rx_clk , //GMII����ʱ��
    output             gmii_rx_dv  , //GMII����������Ч�ź�
    output      [7:0]  gmii_rxd    , //GMII��������
    output             gmii_tx_clk , //GMII����ʱ��
    input              gmii_tx_en  , //GMII��������ʹ���ź�
    input       [7:0]  gmii_txd    , //GMII��������            
    //��̫��RGMII�ӿ�   
    input              rgmii_rxc   , //RGMII����ʱ��
    input              rgmii_rx_ctl, //RGMII�������ݿ����ź�
    input       [3:0]  rgmii_rxd   , //RGMII��������
    output             rgmii_txc   , //RGMII����ʱ��    
    output             rgmii_tx_ctl, //RGMII�������ݿ����ź�
    output      [3:0]  rgmii_txd     //RGMII��������          
    );
//wire
wire   pll_lock  ;
wire   gmii_tx_er;
//*****************************************************
//**                    main code
//*****************************************************
assign gmii_tx_clk = gmii_rx_clk;
//RGMII����
rgmii_rx u_rgmii_rx(
    .rgmii_rxc        (rgmii_rxc      ),
    .rgmii_rx_ctl     (rgmii_rx_ctl   ),
    .rgmii_rxd        (rgmii_rxd      ),
                      
    .gmii_rx_clk      (gmii_rx_clk    ),
    .gmii_rx_dv       (gmii_rx_dv     ),
    .gmii_rxd         (gmii_rxd       ),
    .gmii_tx_clk_deg  (gmii_tx_clk_deg),
    .pll_lock         (pll_lock       )
    );

//RGMII����
rgmii_tx u_rgmii_tx(
    .reset            (1'b0           ),

    .gmii_tx_er       (1'b0           ),
    .gmii_tx_clk      (gmii_tx_clk    ),
    .gmii_tx_en       (gmii_tx_en     ),
    .gmii_txd         (gmii_txd       ),
    .gmii_tx_clk_deg  (gmii_tx_clk_deg),
    
    .rgmii_txc        (rgmii_txc      ),
    .rgmii_tx_ctl     (rgmii_tx_ctl   ),
    .rgmii_txd        (rgmii_txd      )
    );

endmodule